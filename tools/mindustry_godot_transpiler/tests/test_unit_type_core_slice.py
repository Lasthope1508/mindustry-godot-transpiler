import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"
GENERATED = PROJECT / "src" / "generated"
SOURCE = ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "type" / "UnitType.java"


class UnitTypeCoreSliceTests(unittest.TestCase):
    def test_exact_upstream_block_is_present(self):
        source = SOURCE.read_text(encoding="utf-8")
        for expression in ("public UnitController createController(Unit unit){", "return controller.get(unit);", "public boolean hasWeapons(){", "return weapons.size > 0;", "public boolean targetable(Unit unit, Team targeter){", "public boolean killable(Unit unit){", "return killable;", "public boolean hittable(Unit unit){"):
            self.assertIn(expression, source)

    def test_generated_unit_type_block_is_source_backed(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "type" / "UnitType.gd").read_text(encoding="utf-8")
        for method in ("createController_1", "hasWeapons_10", "targetable_11", "killable_12", "hittable_13"):
            self.assertIn(f"func java_method_{method}(_args: Array = []) -> Variant:", generated)
            self.assertNotIn(f"func java_method_{method}(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn('const source_unit_type_state := preload("res://src/game/SourceUnitTypeState.gd")', generated)

    def test_registry_contracts_and_shards_have_single_owners(self):
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        symbols = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        expected = {
            "N1871": "PortGame.source_unit_type_create_controller_state",
            "N1872": "PortGame.source_unit_type_has_weapons_state",
            "N1873": "PortGame.source_unit_type_targetable_state",
            "N1874": "PortGame.source_unit_type_killable_state",
            "N1875": "PortGame.source_unit_type_hittable_state",
        }
        for slice_id, owner in expected.items():
            with self.subTest(slice_id=slice_id):
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertEqual(contracts[owner]["source_slice"], slice_id)
                self.assertEqual(ledger[slice_id]["java_source"], "core/src/mindustry/type/UnitType.java")
        for symbol_name in ("unit_type_create_controller.call", "unit_type_has_weapons.return", "unit_type_targetable.return", "unit_type_killable.return", "unit_type_hittable.return"):
            self.assertEqual(symbols[symbol_name]["status"], "source-backed")

    def test_module_and_proof_exist(self):
        module = (PROJECT / "src" / "game" / "SourceUnitTypeState.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitTypeSourceTextState.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitTypeCoreModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("class_name SourceUnitTypeState", module)
        self.assertIn("class_name SourceUnitTypeSourceTextState", source_text)
        self.assertIn('runtime_proof_state.write_proof("UnitTypeCoreModuleProof", proof)', proof)
        self.assertIn("one_headquarter_per_ssot", proof)

