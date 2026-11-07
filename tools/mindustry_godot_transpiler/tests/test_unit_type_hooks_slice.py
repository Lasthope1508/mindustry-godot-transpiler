import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"
SOURCE = ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "type" / "UnitType.java"


class UnitTypeHooksSliceTests(unittest.TestCase):
    def test_exact_upstream_no_op_hooks_are_present(self):
        source = SOURCE.read_text(encoding="utf-8")
        for expression in (
            "public void update(Unit unit){\n\n    }",
            "public void updatePayload(Unit unit, @Nullable Unit unitHolder, @Nullable Building buildingHolder){\n\n    }",
            "public void killed(Unit unit){}",
            "public void landed(Unit unit){}",
        ):
            self.assertIn(expression, source)

    def test_generated_methods_delegate_to_canonical_no_op_modules(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "type" / "UnitType.gd").read_text(encoding="utf-8")
        module = (PROJECT / "src" / "game" / "SourceUnitTypeState.gd").read_text(encoding="utf-8")
        for generated_method, delegate in (
            ("update_17", "source_unit_type_state.update_state"),
            ("updatePayload_18", "source_unit_type_state.update_payload_state"),
            ("killed_19", "source_unit_type_state.killed_state"),
            ("landed_20", "source_unit_type_state.landed_state"),
        ):
            self.assertIn(f"func java_method_{generated_method}(_args: Array = []) -> Variant:", generated)
            self.assertIn(delegate, generated)
        self.assertEqual(module.count('"no_op": true'), 4)

    def test_registry_contracts_and_shards_have_single_owners(self):
        generated = PROJECT / "src" / "generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        expected = {
            "N1879": "PortGame.source_unit_type_update_state",
            "N1880": "PortGame.source_unit_type_update_payload_state",
            "N1881": "PortGame.source_unit_type_killed_state",
            "N1882": "PortGame.source_unit_type_landed_state",
        }
        for slice_id, owner in expected.items():
            with self.subTest(slice_id=slice_id):
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertEqual(contracts[owner]["source_slice"], slice_id)
        symbols = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        for method in ("update", "updatePayload", "killed", "landed"):
            self.assertEqual(symbols[f"unit_type_{method}.no_op"]["status"], "source-backed")

