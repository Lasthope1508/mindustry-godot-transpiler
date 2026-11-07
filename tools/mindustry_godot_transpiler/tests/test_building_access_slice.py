import json
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

ROOT = Path(__file__).resolve().parents[3]


class BuildingAccessSliceTests(unittest.TestCase):
    def test_building_access_generated_methods_are_source_backed(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
        source = generated.read_text(encoding="utf-8")
        self.assertIn("func java_method_floor_47(_args: Array = []) -> Variant:", source)
        self.assertIn("return source_block_geometry.tile_reference_state(floor_value)", source)
        self.assertIn("func java_method_interactable_48(_args: Array = []) -> Variant:", source)
        self.assertIn("return source_block_geometry.tile_interactable_state(can_interact)", source)

    def test_building_status_generated_method_is_source_backed(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
        source = generated.read_text(encoding="utf-8")
        self.assertIn("func java_method_status_55(_args: Array = []) -> Variant:", source)
        self.assertIn("return source_building_access_state.status_state", source)
        self.assertIn("func java_method_sleep_56(_args: Array = []) -> Variant:", source)
        self.assertIn("return source_building_access_state.sleep_state", source)
        self.assertIn("func java_method_noSleep_57(_args: Array = []) -> Variant:", source)
        self.assertIn("return source_building_access_state.no_sleep_state", source)

    def test_building_payload_access_predicates_are_source_backed(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
        source = generated.read_text(encoding="utf-8")
        expected = {
            "java_method_canWithdraw_64": "can_withdraw_state()",
            "java_method_canUnload_65": "can_unload_state(block_unloadable)",
            "java_method_canResupply_66": "can_resupply_state(block_allow_resupply)",
            "java_method_payloadCheck_67": "payload_check_state(block_rotate, rotation, conveyor_rotation)",
            "java_method_allowDeposit_69": "allow_deposit_state(block_always_allow_deposit, only_deposit_core)",
            "java_method_shouldConsume_73": "should_consume_state(enabled)",
            "java_method_productionValid_74": "production_valid_state()",
            "java_method_consumeTriggerValid_75": "consume_trigger_valid_state()",
        }
        for method, delegate in expected.items():
            with self.subTest(method=method):
                body = source.split(f"func {method}", 1)[1].split("\nfunc ", 1)[0]
                self.assertNotIn("return null", body)
                self.assertIn("source_building_access_state." + delegate, body)

    def test_building_access_slice_registry_and_ledger(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        for slice_id, prefix, method in (("N1883", "building_floor", "floor()"), ("N1884", "building_interactable", "interactable(Team)"), ("N1888", "building_status", "status()"), ("N1889", "building_sleep", "sleep()"), ("N1890", "building_no_sleep", "noSleep()"), ("N1891", "building_can_withdraw", "public boolean canWithdraw(){"), ("N1892", "building_can_unload", "public boolean canUnload(){"), ("N1893", "building_can_resupply", "public boolean canResupply(){"), ("N1894", "building_payload_check", "public boolean payloadCheck(int conveyorRotation){"), ("N1895", "building_allow_deposit", "public boolean allowDeposit(){"), ("N1896", "building_should_consume", "public boolean shouldConsume(){"), ("N1897", "building_production_valid", "public boolean productionValid(){"), ("N1898", "building_consume_trigger_valid", "public boolean consumeTriggerValid(){")):
            self.assertEqual(ledger[slice_id]["status"], "done")
            self.assertEqual(ledger[slice_id]["java_method"], method)
            self.assertEqual(ledger[slice_id]["runtime_proof"], "/root/Main.BuildingAccessStateModuleProof")
            self.assertIn(prefix + ".method", registry)
            self.assertEqual(registry[prefix + ".method"]["status"], "source-backed")

    def test_building_access_modules_reuse_existing_canonical_geometry(self):
        access = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingAccessState.gd").read_text(encoding="utf-8")
        bridge = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingAccessPortBridge.gd").read_text(encoding="utf-8")
        self.assertIn("source_block_geometry.tile_reference_state(floor_value)", access)
        self.assertIn("source_block_geometry.tile_interactable_state(can_interact)", access)
        self.assertIn("func generated_building_comp_floor_bridge_state", bridge)
        self.assertIn("func generated_building_comp_interactable_bridge_state", bridge)

    def test_building_access_source_text_is_upstream_backed(self):
        source_text = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingSourceTextState.gd").read_text(encoding="utf-8")
        upstream = (ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "entities" / "comp" / "BuildingComp.java").read_text(encoding="utf-8")
        for expr in ("public Floor floor(){", "return tile.floor();", "public boolean interactable(Team team){", "return state.teams.canInteract(team, team());", "public BlockStatus status(){", "return BlockStatus.logicDisable;", "return BlockStatus.noOutput;", "return BlockStatus.noInput;", "return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;", "public void sleep(){", "sleepTime += Time.delta;", "if(!sleeping && sleepTime >= timeToSleep){", "remove();", "sleeping = true;", "sleepingEntities++;", "public void noSleep(){", "sleepTime = 0f;", "if(sleeping){", "add();", "sleeping = false;", "sleepingEntities--;", "public boolean canWithdraw(){", "return true;", "public boolean canUnload(){", "return block.unloadable;", "public boolean canResupply(){", "return block.allowResupply;", "public boolean payloadCheck(int conveyorRotation){", "return block.rotate && (rotation + 2) % 4 == conveyorRotation;", "public boolean allowDeposit(){", "return block.alwaysAllowDeposit || !state.rules.onlyDepositCore;"):
            self.assertIn(expr, upstream)
            self.assertIn(expr, source_text)

    def test_building_status_module_preserves_source_branches(self):
        module = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingAccessState.gd").read_text(encoding="utf-8")
        self.assertIn("static func status_state(enabled: bool", module)
        self.assertIn("SOURCE_BUILDING_STATUS_LOGIC_DISABLE", module)
        self.assertIn("SOURCE_BUILDING_STATUS_NO_OUTPUT", module)
        self.assertIn("SOURCE_BUILDING_STATUS_NO_INPUT", module)
        self.assertIn("SOURCE_BUILDING_STATUS_ACTIVE", module)

    def test_building_sleep_module_preserves_side_effects(self):
        module = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingAccessState.gd").read_text(encoding="utf-8")
        self.assertIn("static func sleep_state(sleep_time: float", module)
        self.assertIn('"remove_called": should_sleep', module)
        self.assertIn("static func no_sleep_state(sleeping: bool", module)
        self.assertIn('"add_called": should_wake', module)

    def test_building_access_runtime_proof_covers_sleep_side_effects(self):
        proof = (ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "BuildingAccessStateModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("sleep_state", proof)
        self.assertIn("no_sleep_state", proof)
        self.assertIn("sleep_matches", proof)
        self.assertIn("no_sleep_matches", proof)

    def test_building_access_runtime_proof_covers_status(self):
        proof = (ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "BuildingAccessStateModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("status_logic_disable_module", proof)
        self.assertIn("status_no_output_module", proof)
        self.assertIn("status_no_input_module", proof)
        self.assertIn("status_active_module", proof)
        self.assertIn("generated_status_matches", proof)

    def test_building_access_runtime_proof_covers_payload_access_predicates(self):
        proof = (ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "BuildingAccessStateModuleProof.gd").read_text(encoding="utf-8")
        for name in ("can_withdraw", "can_unload", "can_resupply", "payload_check", "allow_deposit", "generated_payload_access_matches"):
            self.assertIn(name, proof)

    def test_building_consumption_predicates_match_upstream_source(self):
        from mindustry_port import source_parity
        report = source_parity.verify_building_consumption_predicates_source(ROOT / "mindustry-upstream")
        self.assertEqual(report["missing"], [])


if __name__ == "__main__":
    unittest.main()
