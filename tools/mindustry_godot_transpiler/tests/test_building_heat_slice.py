import json
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))


class BuildingHeatSliceTests(unittest.TestCase):
    def test_generated_calculate_heat_overloads_delegate_to_one_canonical_module(self):
        generated = (ROOT / "godot-mindustry" / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
        expected = {
            "java_method_calculateHeat_22": "source_building_heat_state.calculate_heat_default_state",
            "java_method_calculateHeat_23": "source_building_heat_state.calculate_heat_state",
        }
        for method, delegate in expected.items():
            with self.subTest(method=method):
                body = generated.split(f"func {method}", 1)[1].split("\nfunc ", 1)[0]
                self.assertIn(delegate, body)
                self.assertNotIn("return null", body)

    def test_heat_module_uses_canonical_navigation_and_math_dependencies(self):
        module = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingHeatState.gd").read_text(encoding="utf-8")
        self.assertIn("source_building_navigation_state.relative_to_building_state", module)
        self.assertIn("source_math_state.source_mod_float", module)
        for token in (
            "side_heat[index] = 0.0",
            "came_from.clear()",
            "not split_heat",
            "came_from.has(building_id)",
            "contact_points",
            "add /= 3.0",
            "update_heat_callback.call()",
        ):
            self.assertIn(token, module)

    def test_heat_source_parity_and_registry_are_source_backed(self):
        from mindustry_port import source_parity

        self.assertTrue(hasattr(source_parity, "verify_building_calculate_heat_source"))
        self.assertEqual(source_parity.verify_building_calculate_heat_source(ROOT / "mindustry-upstream")["missing"], [])
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        for slice_id, prefix, owner in (
            ("N1921", "building_calculate_heat_default", "PortGame.source_building_calculate_heat_default_state"),
            ("N1922", "building_calculate_heat", "PortGame.source_building_calculate_heat_state"),
        ):
            with self.subTest(slice_id=slice_id):
                self.assertEqual(ledger[slice_id]["status"], "done")
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertEqual(registry[prefix + ".method"]["godot_owner"], owner)
                self.assertEqual(contracts[owner]["source_slice"], slice_id)

    def test_heat_runtime_proof_covers_split_cycles_and_update_heat(self):
        proof = (ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "BuildingHeatStateModuleProof.gd").read_text(encoding="utf-8")
        for token in ("split_heat", "came_from", "update_heat", "generated_matches", "one_headquarter_per_ssot"):
            self.assertIn(token, proof)


if __name__ == "__main__":
    unittest.main()
