import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"
SOURCE = ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "type" / "UnitType.java"


class UnitTypeStanceCommandSliceTests(unittest.TestCase):
    def test_exact_upstream_block_is_present(self):
        source = SOURCE.read_text(encoding="utf-8")
        for expression in (
            "public void getUnitStances(Unit unit, Seq<UnitStance> out){",
            "if(!(unit.controller() instanceof CommandAI ai)) return;",
            "if(current == UnitCommand.mineCommand){",
            "out.add(UnitStance.mineAuto);",
            "out.addAll(current.extraStances);",
            "public boolean allowStance(Unit unit, UnitStance stance){",
            "if(stance == UnitStance.stop) return true;",
            "getUnitStances(unit, tmpStances);",
            "return tmpStances.contains(stance);",
            "public boolean allowCommand(Unit unit, UnitCommand command){",
            "return commands.contains(command);",
        ):
            self.assertIn(expression, source)

    def test_generated_block_and_module_are_source_backed(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "type" / "UnitType.gd").read_text(encoding="utf-8")
        module = (PROJECT / "src" / "game" / "SourceUnitTypeState.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitTypeSourceTextState.gd").read_text(encoding="utf-8")
        for method, delegate in (
            ("getUnitStances_14", "source_unit_type_state.get_unit_stances_state"),
            ("allowStance_15", "source_unit_type_state.allow_stance_state"),
            ("allowCommand_16", "source_unit_type_state.allow_command_state"),
        ):
            self.assertIn(f"func java_method_{method}(_args: Array = []) -> Variant:", generated)
            self.assertIn(delegate, generated)
        self.assertIn("get_unit_stances_state", module)
        self.assertIn("allow_stance_state", module)
        self.assertIn("allow_command_state", module)
        self.assertIn("SOURCE_UNIT_TYPE_GET_UNIT_STANCES_METHOD", source_text)
        self.assertIn("SOURCE_UNIT_TYPE_ALLOW_STANCE_STOP_GUARD", source_text)
        self.assertIn("SOURCE_UNIT_TYPE_ALLOW_COMMAND_RETURN", source_text)

    def test_registry_contracts_and_shards_have_single_owners(self):
        generated = PROJECT / "src" / "generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        symbols = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        expected = {
            "N1876": "PortGame.source_unit_type_get_unit_stances_state",
            "N1877": "PortGame.source_unit_type_allow_stance_state",
            "N1878": "PortGame.source_unit_type_allow_command_state",
        }
        for slice_id, owner in expected.items():
            with self.subTest(slice_id=slice_id):
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertEqual(contracts[owner]["source_slice"], slice_id)
                self.assertEqual(ledger[slice_id]["java_source"], "core/src/mindustry/type/UnitType.java")
        for symbol_name in (
            "unit_type_get_unit_stances.method",
            "unit_type_get_unit_stances.command_guard",
            "unit_type_get_unit_stances.mine_auto",
            "unit_type_get_unit_stances.extra",
            "unit_type_allow_stance.method",
            "unit_type_allow_stance.stop_guard",
            "unit_type_allow_stance.return",
            "unit_type_allow_command.method",
            "unit_type_allow_command.return",
        ):
            self.assertEqual(symbols[symbol_name]["status"], "source-backed")

    def test_module_and_proof_reference_the_canonical_headquarter(self):
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitTypeCoreModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("one_headquarter_per_ssot", proof)
        self.assertIn('runtime_proof_state.write_proof("UnitTypeCoreModuleProof", proof)', proof)

