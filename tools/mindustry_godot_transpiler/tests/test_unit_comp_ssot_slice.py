import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"
GENERATED = PROJECT / "src" / "generated"
UNIT_COMP_SOURCE = "core/src/mindustry/entities/comp/UnitComp.java"


class UnitCompSsotSliceTests(unittest.TestCase):
    def test_unit_comp_shards_mirror_only_unit_comp_canonical_entries(self):
        manifest = json.loads((GENERATED / "source_ssot_modules.json").read_text(encoding="utf-8"))["modules"]
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        unit_slices = json.loads((GENERATED / "source_modules" / "unit_comp_slices.json").read_text(encoding="utf-8"))["slices"]
        unit_contracts = json.loads((GENERATED / "source_modules" / "unit_comp_api_contracts.json").read_text(encoding="utf-8"))["contracts"]

        self.assertEqual(manifest["unit_comp_slices"]["selection"]["value"], UNIT_COMP_SOURCE)
        expected_ids = {slice_id for slice_id, entry in ledger.items() if entry["java_source"] == UNIT_COMP_SOURCE}
        self.assertEqual(set(unit_slices), expected_ids)
        self.assertEqual(set(unit_contracts), {entry["godot_owner"] for entry in unit_slices.values()})
        for slice_id, entry in unit_slices.items():
            with self.subTest(slice_id=slice_id):
                self.assertEqual(entry["canonical_ledger"], f"source_slice_ledger.{slice_id}")
                for field in manifest["unit_comp_slices"]["mirror_fields"]:
                    self.assertEqual(entry[field], ledger[slice_id][field])
                owner = entry["godot_owner"]
                self.assertEqual(unit_contracts[owner]["canonical_contract"], f"source_api_contracts.{owner}")
                for field in manifest["unit_comp_api_contracts"]["mirror_fields"]:
                    self.assertEqual(unit_contracts[owner][field], contracts[owner][field])

    def test_unit_comp_source_file_is_present_and_has_the_canonical_class(self):
        source = (ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "entities" / "comp" / "UnitComp.java").read_text(encoding="utf-8")
        self.assertIn("abstract class UnitComp", source)
        self.assertIn("public void update(){", source)

    def test_unit_comp_controller_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitControllerSourceTextState.gd").read_text(encoding="utf-8")
        controller = (PROJECT / "src" / "game" / "SourceUnitControllerState.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        expected = {
            "N1858": "PortGame.source_unit_collision_state",
            "N1859": "PortGame.source_unit_controller_set_state",
            "N1860": "PortGame.source_unit_controller_get_state",
            "N1861": "PortGame.source_unit_reset_controller_state",
            "N1862": "PortGame.source_unit_set_state",
            "N1863": "PortGame.source_unit_collision_layer_state",
        }
        for slice_id, owner in expected.items():
            with self.subTest(slice_id=slice_id):
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertEqual(contracts[owner]["source_slice"], slice_id)
        for method in (
            "java_method_collision_40", "java_method_controller_43", "java_method_controller_44",
            "java_method_resetController_45", "java_method_set_46", "java_method_collisionLayer_47",
        ):
            self.assertIn(f"func {method}(_args: Array = []) -> Variant:", generated)
        for constant in (
            "SOURCE_UNIT_COLLISION_METHOD", "SOURCE_UNIT_CONTROLLER_SET_METHOD",
            "SOURCE_UNIT_RESET_CONTROLLER_CREATE", "SOURCE_UNIT_COLLISION_LAYER_RETURN",
            "SOURCE_UNIT_COLLISION_LAYER_LEGS_VALUE", "SOURCE_UNIT_COLLISION_LAYER_GROUND_VALUE",
            "SOURCE_UNIT_COLLISION_LAYER_FLYING_VALUE",
        ):
            self.assertIn(constant, source_text)
        self.assertIn("class_name SourceUnitControllerState", controller)
        for symbol in (
            "unit_collision.controller_hit", "unit_controller_set.assign", "unit_controller_get.return",
            "unit_reset_controller.create", "unit_set.controller_call", "unit_collision_layer.return",
        ):
            self.assertEqual(registry[symbol]["status"], "source-backed")

    def test_unit_comp_generated_runtime_proof_covers_canonical_movement_block(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        for method in (
            "java_method_moveAt_6",
            "java_method_floorSpeedMultiplier_7",
            "java_method_movePref_11",
            "java_method_moveAt_12",
            "java_method_approach_13",
            "java_method_rotateMove_14",
            "java_method_physicSize_18",
            "java_method_inRange_20",
            "java_method_hasWeapons_21",
            "java_method_speed_22",
            "java_method_ammof_24",
            "java_method_displayable_25",
            "java_method_isSyncHidden_26",
            "java_method_handleSyncHidden_27",
            "java_method_range_29",
        ):
            with self.subTest(method=method):
                self.assertIn(f"func {method}(_args: Array = []) -> Variant:", generated)
        self.assertIn("UNIT_COMP_GENERATED_RUNTIME_MODULE_PROOF", proof)
        self.assertIn('"registry_valid": bool(registry_state.get("errors", []).is_empty())', proof)
        self.assertIn('"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false))', proof)
        self.assertIn('runtime_proof_state.write_proof("UnitCompGeneratedRuntimeModuleProof", proof)', proof)
        self.assertIn('"ammof_matches"', proof)
        self.assertIn('"displayable_matches"', proof)
        self.assertIn('"ammof_owner_matches"', proof)
        self.assertIn('"displayable_owner_matches"', proof)
        self.assertIn('"sync_hidden_matches"', proof)
        self.assertIn('"handle_sync_hidden_matches"', proof)
        self.assertIn('"range_matches"', proof)
        self.assertIn('"range_owner_matches"', proof)

    def test_unit_comp_navigation_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        navigation = (PROJECT / "src" / "game" / "SourceUnitNavigationState.gd").read_text(encoding="utf-8")
        self.assertIn("func java_method_isPathImpassable_17(_args: Array = []) -> Variant:", generated)
        self.assertIn("func java_method_canLand_19(_args: Array = []) -> Variant:", generated)
        self.assertIn("func java_method_prefRotation_23(_args: Array = []) -> Variant:", generated)
        self.assertIn("class_name SourceUnitNavigationState", navigation)
        self.assertIn("SOURCE_UNIT_IS_PATH_IMPASSABLE_RETURN", source_text)
        self.assertIn("SOURCE_UNIT_CAN_LAND_RETURN", source_text)
        self.assertIn("SOURCE_UNIT_PREF_ROTATION_RETURN", source_text)
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        self.assertEqual(ledger["N1837"]["godot_owner"], "PortGame.source_unit_is_path_impassable_state")
        self.assertEqual(ledger["N1838"]["godot_owner"], "PortGame.source_unit_can_land_state")
        self.assertEqual(ledger["N1839"]["godot_owner"], "PortGame.source_unit_pref_rotation_state")
        self.assertEqual(contracts["PortGame.source_unit_can_land_state"]["return_keys"], ["can_land"])
        for symbol in (
            "unit_is_path_impassable.return",
            "unit_can_land.return",
            "unit_pref_rotation.return",
        ):
            with self.subTest(symbol=symbol):
                self.assertEqual(registry[symbol]["status"], "source-backed")

    def test_unit_comp_lifecycle_predicates_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        lifecycle = (PROJECT / "src" / "game" / "SourceUnitLifecycleState.gd").read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        expected = {
            "N796": "PortGame.source_unit_player_controllable_state",
            "N801": "PortGame.source_unit_targetable_state",
            "N787": "PortGame.source_unit_killable_state",
            "N781": "PortGame.source_unit_hittable_state",
        }
        methods = ("playerControllable_60", "targetable_61", "killable_62", "hittable_63")
        for method in methods:
            with self.subTest(method=method):
                self.assertIn(f"func java_method_{method}(_args: Array = []) -> Variant:", generated)
                self.assertNotIn(f"func java_method_{method}(_args: Array = []) -> Variant:\n\treturn null", generated)
        for slice_id, owner in expected.items():
            with self.subTest(slice_id=slice_id):
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertIn(owner, contracts)
        for constant in (
            "SOURCE_UNIT_PLAYER_CONTROLLABLE_GENERATED_OWNER",
            "SOURCE_UNIT_TARGETABLE_GENERATED_OWNER",
            "SOURCE_UNIT_KILLABLE_GENERATED_OWNER",
            "SOURCE_UNIT_HITTABLE_GENERATED_OWNER",
        ):
            self.assertIn(constant, source_text)
        for function in (
            "static func player_controllable_state(",
            "static func targetable_state(",
            "static func killable_state(",
            "static func hittable_state(",
        ):
            self.assertIn(function, lifecycle)
        for owner_constant in (
            "PORT_GAME_SOURCE_UNIT_PLAYER_CONTROLLABLE_STATE",
            "PORT_GAME_SOURCE_UNIT_TARGETABLE_STATE",
            "PORT_GAME_SOURCE_UNIT_KILLABLE_STATE",
            "PORT_GAME_SOURCE_UNIT_HITTABLE_STATE",
        ):
            self.assertIn(owner_constant, registry_source)
        for proof_key in (
            "player_controllable_normal_matches",
            "player_controllable_privileged_matches",
            "targetable_payload_matches",
            "killable_false_matches",
            "hittable_payload_matches",
            "player_controllable_owner_matches",
            "targetable_owner_matches",
            "killable_owner_matches",
            "hittable_owner_matches",
        ):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_read_lifecycle_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        lifecycle = (PROJECT / "src" / "game" / "SourceUnitLifecycleState.gd").read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        expected = {
            "N755": "PortGame.source_unit_after_sync_state",
            "N754": "PortGame.source_unit_after_read_state",
            "N753": "PortGame.source_unit_after_read_all_state",
        }
        for method in ("afterSync_64", "afterRead_65", "afterReadAll_66"):
            with self.subTest(method=method):
                self.assertIn(f"func java_method_{method}(_args: Array = []) -> Variant:", generated)
                self.assertNotIn(f"func java_method_{method}(_args: Array = []) -> Variant:\n\treturn null", generated)
        for slice_id, owner in expected.items():
            with self.subTest(slice_id=slice_id):
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertEqual(contracts[owner]["source_slice"], slice_id)
        for constant in (
            "SOURCE_UNIT_AFTER_SYNC_GENERATED_OWNER",
            "SOURCE_UNIT_AFTER_READ_GENERATED_OWNER",
            "SOURCE_UNIT_AFTER_READ_ALL_GENERATED_OWNER",
        ):
            self.assertIn(constant, source_text)
        for function in ("static func after_sync_state(", "static func after_read_state(", "static func after_read_all_state("):
            self.assertIn(function, lifecycle)
        for owner_constant in (
            "PORT_GAME_SOURCE_UNIT_AFTER_SYNC_STATE",
            "PORT_GAME_SOURCE_UNIT_AFTER_READ_STATE",
            "PORT_GAME_SOURCE_UNIT_AFTER_READ_ALL_STATE",
        ):
            self.assertIn(owner_constant, registry_source)
        for proof_key in ("after_sync_matches", "after_read_reset_matches", "after_read_keep_matches", "after_read_all_matches", "after_sync_owner_matches", "after_read_owner_matches", "after_read_all_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_add_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        lifecycle = (PROJECT / "src" / "game" / "SourceUnitLifecycleState.gd").read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        self.assertIn("func java_method_add_67(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_add_67(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertEqual(ledger["N752"]["godot_owner"], "PortGame.source_unit_add_state")
        self.assertEqual(contracts["PortGame.source_unit_add_state"]["source_slice"], "N752")
        self.assertIn("SOURCE_UNIT_ADD_GENERATED_OWNER", source_text)
        self.assertIn("static func add_state(", lifecycle)
        self.assertIn("PORT_GAME_SOURCE_UNIT_ADD_STATE", registry_source)
        for proof_key in ("add_over_cap_matches", "add_guard_false_matches", "add_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_remove_landed_heal_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        destroy_state = (PROJECT / "src" / "game" / "SourceUnitDestroyState.gd").read_text(encoding="utf-8")
        boosting_state = (PROJECT / "src" / "game" / "SourceUnitBoostingState.gd").read_text(encoding="utf-8")
        runtime_state = (PROJECT / "src" / "game" / "SourceUnitRuntimeState.gd").read_text(encoding="utf-8")
        destroy_registry = (PROJECT / "src" / "game" / "SourceRuntimeOwnerUnitDestroyRegistry.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]

        expected = {
            "N797": ("remove_68", "PortGame.source_unit_remove_state", "SOURCE_UNIT_REMOVE_GENERATED_OWNER"),
            "N789": ("landed_69", "PortGame.source_unit_landed_state", "SOURCE_UNIT_LANDED_GENERATED_OWNER"),
            "N778": ("heal_70", "PortGame.source_unit_heal_state", "SOURCE_UNIT_HEAL_GENERATED_OWNER"),
        }
        for slice_id, (method, owner, generated_owner) in expected.items():
            with self.subTest(slice_id=slice_id):
                self.assertIn(f"func java_method_{method}(_args: Array = []) -> Variant:", generated)
                self.assertNotIn(f"func java_method_{method}(_args: Array = []) -> Variant:\n\treturn null", generated)
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertEqual(contracts[owner]["source_slice"], slice_id)
                self.assertIn(generated_owner, source_text)

        self.assertIn("static func remove_state(", destroy_state)
        self.assertIn("static func landed_state(", boosting_state)
        self.assertIn("static func heal_state(", runtime_state)
        self.assertIn("PORT_GAME_SOURCE_UNIT_REMOVE_STATE", destroy_registry)
        for proof_key in ("remove_with_trail_matches", "remove_without_trail_matches", "landed_shake_matches", "landed_no_shake_matches", "heal_partial_matches", "heal_full_matches", "remove_owner_matches", "landed_owner_matches", "heal_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_update_drowning_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        runtime_state = (PROJECT / "src" / "game" / "SourceUnitRuntimeState.gd").read_text(encoding="utf-8")
        owner_registry = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        self.assertIn("func java_method_updateDrowning_71(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_updateDrowning_71(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertEqual(ledger["N813"]["godot_owner"], "PortGame.source_unit_update_drowning_state")
        self.assertEqual(contracts["PortGame.source_unit_update_drowning_state"]["source_slice"], "N813")
        self.assertIn("SOURCE_UNIT_UPDATE_DROWNING_GENERATED_OWNER", source_text)
        self.assertIn("static func drowning_state(", runtime_state)
        self.assertIn("PORT_GAME_SOURCE_UNIT_UPDATE_DROWNING_STATE", owner_registry)
        for proof_key in ("drowning_liquid_matches", "drowning_net_client_matches", "drowning_dry_matches", "drowning_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_update_orchestration_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        update_state = (PROJECT / "src" / "game" / "SourceUnitUpdateState.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]

        self.assertIn("func java_method_update_72(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_update_72(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn("SOURCE_UNIT_UPDATE_GENERATED_OWNER", source_text)
        self.assertIn("SOURCE_UNIT_UPDATE_CALL_ORDER", source_text)
        self.assertIn("static func update_state(context: Dictionary) -> Dictionary:", update_state)
        self.assertIn("SOURCE_UNIT_UPDATE_REQUIRED_KEYS", update_state)
        self.assertEqual(ledger["N1870"]["godot_owner"], "PortGame.source_unit_update_state")
        self.assertEqual(contracts["PortGame.source_unit_update_state"]["source_slice"], "N1870")
        self.assertEqual(contracts["PortGame.source_unit_update_state"]["return_keys"], ["deferred", "missing_dependencies", "call_order", "stages"])
        for symbol in ("unit_update.method", "unit_update.type_hook", "unit_update.drowning", "unit_update.ability_loop", "unit_update.drag", "unit_update.falling", "unit_update.controller", "unit_update.core_despawn"):
            with self.subTest(symbol=symbol):
                self.assertEqual(registry[symbol]["status"], "source-backed")
        for proof_key in ("update_orchestration_matches", "update_orchestration_order_matches", "update_orchestration_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_should_update_controller_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        runtime_state = (PROJECT / "src" / "game" / "SourceUnitRuntimeState.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("func java_method_shouldUpdateController_73(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_shouldUpdateController_73(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn("SOURCE_UNIT_SHOULD_UPDATE_CONTROLLER_GENERATED_OWNER", source_text)
        self.assertIn("static func ai_controller_server_gate_state(", runtime_state)
        for proof_key in ("should_update_controller_matches", "should_update_controller_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_icon_block_reuses_registered_canonical_state(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitMetadataState.gd").read_text(encoding="utf-8")
        metadata = (PROJECT / "src" / "game" / "SourceUnitMetadataState.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]

        self.assertIn("func java_method_icon_74(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_icon_74(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn("SOURCE_UNIT_ICON_GENERATED_OWNER", source_text)
        self.assertIn("static func unit_icon_state(type_ui_icon: String) -> Dictionary:", metadata)
        self.assertEqual(ledger["N782"]["godot_owner"], "PortGame.source_unit_icon_state")
        self.assertEqual(contracts["PortGame.source_unit_icon_state"]["source_slice"], "N782")
        for proof_key in ("icon_matches", "icon_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_destroy_block_orchestrates_registered_canonical_states(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        destroy = (PROJECT / "src" / "game" / "SourceUnitDestroyState.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitDestroySourceTextState.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("func java_method_destroy_75(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_destroy_75(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn("static func destroy_state(input_state: Dictionary) -> Dictionary:", destroy)
        self.assertIn("SOURCE_UNIT_DESTROY_GENERATED_OWNER", source_text)
        for phase in ("explosion_dispatch", "visual_effects", "sound_and_event", "suicide_bomb_trigger", "shoot_on_death_mounts", "crash_landing_damage", "wreck_decal", "ability_death", "type_killed_remove"):
            self.assertIn(f'"{phase}"', destroy)
        for proof_key in ("destroy_matches", "destroy_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_controller_name_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitControllerSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src" / "game" / "SourceUnitControllerState.gd").read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("func java_method_getControllerName_76(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_getControllerName_76(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn("SOURCE_UNIT_GET_CONTROLLER_NAME_GENERATED_OWNER", source_text)
        self.assertIn("static func get_controller_name_state(", state)
        self.assertIn("PORT_GAME_SOURCE_UNIT_GET_CONTROLLER_NAME_STATE", registry_source)
        for proof_key in ("controller_name_player_matches", "controller_name_logic_matches", "controller_name_none_matches", "controller_name_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_display_draw_dispatch_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitControllerSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src" / "game" / "SourceUnitControllerState.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("func java_method_display_77(_args: Array = []) -> Variant:", generated)
        self.assertIn("func java_method_draw_78(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_display_77(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertNotIn("func java_method_draw_78(_args: Array = []) -> Variant:\n\treturn null", generated)
        for constant in ("SOURCE_UNIT_DISPLAY_CALL", "SOURCE_UNIT_DRAW_CALL", "SOURCE_UNIT_DISPLAY_GENERATED_OWNER", "SOURCE_UNIT_DRAW_GENERATED_OWNER"):
            self.assertIn(constant, source_text)
        self.assertIn("static func display_state(table: Variant) -> Dictionary:", state)
        self.assertIn("static func draw_state() -> Dictionary:", state)
        for proof_key in ("display_matches", "draw_matches", "display_owner_matches", "draw_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_player_projection_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitControllerSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src" / "game" / "SourceUnitControllerState.gd").read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        for method in ("isPlayer_79", "getPlayer_80"):
            self.assertIn(f"func java_method_{method}(_args: Array = []) -> Variant:", generated)
            self.assertNotIn(f"func java_method_{method}(_args: Array = []) -> Variant:\n\treturn null", generated)
        for constant in ("SOURCE_UNIT_IS_PLAYER_GENERATED_OWNER", "SOURCE_UNIT_GET_PLAYER_GENERATED_OWNER"):
            self.assertIn(constant, source_text)
        for function in ("static func is_player_state(", "static func get_player_state("):
            self.assertIn(function, state)
        for owner in ("PORT_GAME_SOURCE_UNIT_IS_PLAYER_STATE", "PORT_GAME_SOURCE_UNIT_GET_PLAYER_STATE"):
            self.assertIn(owner, registry_source)
        for proof_key in ("is_player_matches", "get_player_matches", "is_player_owner_matches", "get_player_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_death_terminal_block_reuses_registered_canonical_states(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitDestroySourceTextState.gd").read_text(encoding="utf-8")
        destroy = (PROJECT / "src" / "game" / "SourceUnitDestroyState.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]

        for method in ("killed_81", "kill_82"):
            self.assertIn(f"func java_method_{method}(_args: Array = []) -> Variant:", generated)
            self.assertNotIn(f"func java_method_{method}(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn("SOURCE_UNIT_KILLED_GENERATED_OWNER", source_text)
        self.assertIn("SOURCE_UNIT_KILL_SYNC_GENERATED_OWNER", source_text)
        self.assertIn("static func killed_state(", destroy)
        self.assertIn("static func kill_sync_state(", destroy)
        self.assertEqual(ledger["N788"]["godot_owner"], "PortGame.source_unit_killed_state")
        self.assertEqual(ledger["N786"]["godot_owner"], "PortGame.source_unit_kill_sync_state")
        for proof_key in ("killed_destroy_matches", "killed_wreck_matches", "kill_dispatch_matches", "kill_guard_matches", "killed_owner_matches", "kill_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_to_string_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitControllerSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src" / "game" / "SourceUnitControllerState.gd").read_text(encoding="utf-8")
        proof = (PROJECT / "tools" / "runtime_proofs" / "UnitCompGeneratedRuntimeModuleProof.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        self.assertIn("func java_method_toString_83(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_toString_83(_args: Array = []) -> Variant:\n\treturn null", generated)
        for constant in ("SOURCE_UNIT_TO_STRING_METHOD", "SOURCE_UNIT_TO_STRING_RETURN", "SOURCE_UNIT_TO_STRING_GENERATED_OWNER"):
            self.assertIn(constant, source_text)
        self.assertIn("static func to_string_state(", state)
        self.assertEqual(ledger["N1869"]["godot_owner"], "PortGame.source_unit_to_string_state")
        for proof_key in ("to_string_matches", "to_string_owner_matches"):
            self.assertIn(f'"{proof_key}"', proof)

    def test_unit_comp_ammo_and_displayability_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        metadata = (PROJECT / "src" / "game" / "SourceUnitMetadataState.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]

        self.assertIn("func java_method_ammof_24(_args: Array = []) -> Variant:", generated)
        self.assertIn("func java_method_displayable_25(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_ammof_24(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertNotIn("func java_method_displayable_25(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn("SOURCE_UNIT_AMMOF_RETURN", source_text)
        self.assertIn("SOURCE_UNIT_DISPLAYABLE_RETURN", source_text)
        self.assertIn("static func ammof_state() -> Dictionary:", metadata)
        self.assertIn("static func displayable_state(type_hoverable: bool) -> Dictionary:", metadata)
        self.assertEqual(ledger["N1840"]["godot_owner"], "PortGame.source_unit_ammof_state")
        self.assertEqual(ledger["N1841"]["godot_owner"], "PortGame.source_unit_displayable_state")
        self.assertEqual(contracts["PortGame.source_unit_ammof_state"]["return_keys"], ["ammof"])
        self.assertEqual(contracts["PortGame.source_unit_displayable_state"]["return_keys"], ["displayable"])
        for symbol in ("unit_ammof.return", "unit_displayable.return"):
            with self.subTest(symbol=symbol):
                self.assertEqual(registry[symbol]["status"], "source-backed")

    def test_unit_comp_sync_hidden_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        lifecycle = (PROJECT / "src" / "game" / "SourceUnitLifecycleState.gd").read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]

        for method in ("java_method_isSyncHidden_26", "java_method_handleSyncHidden_27"):
            with self.subTest(method=method):
                self.assertIn(f"func {method}(_args: Array = []) -> Variant:", generated)
                self.assertNotIn(f"func {method}(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn("SOURCE_UNIT_IS_SYNC_HIDDEN_RETURN", source_text)
        self.assertIn("SOURCE_UNIT_HANDLE_SYNC_HIDDEN_CLEAR_REMOVED_ENTITY", source_text)
        self.assertIn("static func is_sync_hidden_state(is_shooting_value: bool, in_fog_to_value: bool) -> Dictionary:", lifecycle)
        self.assertIn("static func handle_sync_hidden_state(unit_id: int) -> Dictionary:", lifecycle)
        self.assertIn('const PORT_GAME_SOURCE_UNIT_IS_SYNC_HIDDEN_STATE := "port_game.source_unit_is_sync_hidden_state"', registry_source)
        self.assertIn('const PORT_GAME_SOURCE_UNIT_HANDLE_SYNC_HIDDEN_STATE := "port_game.source_unit_handle_sync_hidden_state"', registry_source)
        self.assertEqual(ledger["N1842"]["godot_owner"], "PortGame.source_unit_is_sync_hidden_state")
        self.assertEqual(ledger["N1843"]["godot_owner"], "PortGame.source_unit_handle_sync_hidden_state")
        self.assertEqual(contracts["PortGame.source_unit_is_sync_hidden_state"]["return_keys"], ["is_sync_hidden"])
        self.assertEqual(contracts["PortGame.source_unit_handle_sync_hidden_state"]["return_keys"], ["handled", "remove", "clear_removed_entity"])
        for symbol in ("unit_is_sync_hidden.return", "unit_handle_sync_hidden.clear_removed_entity"):
            with self.subTest(symbol=symbol):
                self.assertEqual(registry[symbol]["status"], "source-backed")

    def test_unit_comp_in_fog_to_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        lifecycle = (PROJECT / "src" / "game" / "SourceUnitLifecycleState.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]

        self.assertIn("func java_method_inFogTo_28(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_inFogTo_28(_args: Array = []) -> Variant:\n\treturn null", generated)
        for constant in ("SOURCE_UNIT_IN_FOG_TO_METHOD", "SOURCE_UNIT_IN_FOG_TO_INITIAL_GATE", "SOURCE_UNIT_IN_FOG_TO_D8_LOOP", "SOURCE_UNIT_IN_FOG_TO_GEOMETRY_SOURCE"):
            self.assertIn(constant, source_text)
        self.assertIn("static func in_fog_to_state(", lifecycle)
        self.assertEqual(ledger["N1844"]["godot_owner"], "PortGame.source_unit_in_fog_to_state")
        self.assertEqual(contracts["PortGame.source_unit_in_fog_to_state"]["return_keys"], ["in_fog"])
        for symbol in ("unit_in_fog_to.method", "unit_in_fog_to.initial_gate", "unit_in_fog_to.center_visible", "unit_in_fog_to.d8_visible", "unit_in_fog_to.in_fog"):
            with self.subTest(symbol=symbol):
                self.assertEqual(registry[symbol]["status"], "source-backed" if symbol.endswith((".method", ".initial_gate", ".in_fog")) else "explicit-input")

    def test_unit_comp_range_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        metadata = (PROJECT / "src" / "game" / "SourceUnitMetadataState.gd").read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]

        self.assertIn("func java_method_range_29(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_range_29(_args: Array = []) -> Variant:\n\treturn null", generated)
        self.assertIn("SOURCE_UNIT_RANGE_METHOD", source_text)
        self.assertIn("SOURCE_UNIT_RANGE_RETURN", source_text)
        self.assertIn("static func range_state(type_max_range: float) -> Dictionary:", metadata)
        self.assertIn('const PORT_GAME_SOURCE_UNIT_RANGE_STATE := "port_game.source_unit_range_state"', registry_source)
        self.assertEqual(ledger["N1845"]["godot_owner"], "PortGame.source_unit_range_state")
        self.assertEqual(contracts["PortGame.source_unit_range_state"]["return_keys"], ["range"])
        for symbol in ("unit_range.method", "unit_range.return", "unit_range.type_max_range", "unit_range.range"):
            with self.subTest(symbol=symbol):
                self.assertEqual(registry[symbol]["status"], "source-backed" if symbol in ("unit_range.method", "unit_range.return", "unit_range.range") else "explicit-input")

    def test_unit_comp_clip_size_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitUpdateSourceTextState.gd").read_text(encoding="utf-8")
        metadata = (PROJECT / "src" / "game" / "SourceUnitMetadataState.gd").read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]

        self.assertIn("func java_method_clipSize_30(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_clipSize_30(_args: Array = []) -> Variant:\n\treturn null", generated)
        for constant in (
            "SOURCE_UNIT_CLIP_SIZE_METHOD",
            "SOURCE_UNIT_CLIP_SIZE_BUILDING_GATE",
            "SOURCE_UNIT_CLIP_SIZE_MINING_GATE",
            "SOURCE_UNIT_CLIP_SIZE_RETURN",
        ):
            self.assertIn(constant, source_text)
        self.assertIn("static func clip_size_state(", metadata)
        self.assertIn('const PORT_GAME_SOURCE_UNIT_CLIP_SIZE_STATE := "port_game.source_unit_clip_size_state"', registry_source)
        self.assertEqual(ledger["N1846"]["godot_owner"], "PortGame.source_unit_clip_size_state")
        self.assertEqual(contracts["PortGame.source_unit_clip_size_state"]["return_keys"], ["clip_size"])
        for symbol in (
            "unit_clip_size.method",
            "unit_clip_size.building_gate",
            "unit_clip_size.infinite_resources",
            "unit_clip_size.type_clip_size",
            "unit_clip_size.mining_gate",
            "unit_clip_size.clip_size",
        ):
            with self.subTest(symbol=symbol):
                self.assertEqual(registry[symbol]["status"], "source-backed" if symbol not in ("unit_clip_size.infinite_resources", "unit_clip_size.type_clip_size") else "explicit-input")

    def test_unit_comp_laccess_sensor_block_is_registered_and_generated(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "UnitComp.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src" / "game" / "SourceUnitSensorSourceTextState.gd").read_text(encoding="utf-8")
        sensor_state = (PROJECT / "src" / "game" / "SourceUnitSensorState.gd").read_text(encoding="utf-8")
        update_state = (PROJECT / "src" / "game" / "SourceUnitUpdateState.gd").read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        registry = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]

        self.assertIn("func java_method_sense_31(_args: Array = []) -> Variant:", generated)
        self.assertNotIn("func java_method_sense_31(_args: Array = []) -> Variant:\n\treturn null", generated)
        for constant in (
            "SOURCE_UNIT_SENSE_LACCESS_METHOD",
            "SOURCE_UNIT_SENSE_LACCESS_TOTAL_ITEMS_CASE",
            "SOURCE_UNIT_SENSE_LACCESS_CONTROLLED_CASE",
            "SOURCE_UNIT_SENSE_LACCESS_DEFAULT_CASE",
            "SOURCE_UNIT_SENSE_LACCESS_GENERATED_METHOD",
        ):
            self.assertIn(constant, source_text)
        self.assertIn("class_name SourceUnitSensorState", sensor_state)
        self.assertIn("static func laccess_state(sensor: String, unit_state: Dictionary, source_tilesize: float) -> Dictionary:", sensor_state)
        self.assertIn("source_unit_sensor_state.laccess_state(sensor, unit_state, source_tilesize)", update_state)
        self.assertIn('const PORT_GAME_SOURCE_UNIT_SENSE_LACCESS_STATE := "port_game.source_unit_sense_laccess_state"', registry_source)
        self.assertEqual(ledger["N1847"]["godot_owner"], "PortGame.source_unit_sense_laccess_state")
        self.assertEqual(contracts["PortGame.source_unit_sense_laccess_state"]["return_keys"], ["value"])
        for symbol in ("unit_sense_laccess.method", "unit_sense_laccess.sensor", "unit_sense_laccess.value"):
            with self.subTest(symbol=symbol):
                self.assertIn(symbol, registry)

        self.assertEqual(ledger["N1848"]["godot_owner"], "PortGame.source_unit_sense_object_state")
        self.assertEqual(ledger["N1849"]["godot_owner"], "PortGame.source_unit_sense_content_state")
        self.assertIn("func java_method_senseObject_32(_args: Array = []) -> Variant:", generated)
        self.assertIn("func java_method_sense_33(_args: Array = []) -> Variant:", generated)
        for constant in (
            "SOURCE_UNIT_SENSE_OBJECT_METHOD",
            "SOURCE_UNIT_SENSE_OBJECT_TYPE_CASE",
            "SOURCE_UNIT_SENSE_OBJECT_DEFAULT_CASE",
            "SOURCE_UNIT_SENSE_CONTENT_METHOD",
            "SOURCE_UNIT_SENSE_CONTENT_STACK_CASE",
            "SOURCE_UNIT_SENSE_CONTENT_DEFAULT_CASE",
        ):
            self.assertIn(constant, source_text)
        self.assertEqual(contracts["PortGame.source_unit_sense_object_state"]["return_keys"], ["value"])
        self.assertEqual(contracts["PortGame.source_unit_sense_content_state"]["return_keys"], ["value"])
        for symbol in ("unit_sense_object.method", "unit_sense_object.value", "unit_sense_content.method", "unit_sense_content.value"):
            with self.subTest(symbol=symbol):
                self.assertIn(symbol, registry)

        self.assertEqual(ledger["N1850"]["godot_owner"], "PortGame.source_unit_set_prop_laccess_double_state")
        self.assertEqual(ledger["N1851"]["godot_owner"], "PortGame.source_unit_set_prop_laccess_object_state")
        self.assertEqual(ledger["N1852"]["godot_owner"], "PortGame.source_unit_set_prop_content_state")
        for method in ("setProp_34", "setProp_35", "setProp_36"):
            self.assertIn(f"func java_method_{method}(_args: Array = []) -> Variant:", generated)
        for constant in (
            "SOURCE_UNIT_SET_PROP_LACCESS_DOUBLE_METHOD",
            "SOURCE_UNIT_SET_PROP_HEALTH_CASE",
            "SOURCE_UNIT_SET_PROP_LACCESS_OBJECT_METHOD",
            "SOURCE_UNIT_SET_PROP_PAYLOAD_TYPE_CASE",
            "SOURCE_UNIT_SET_PROP_CONTENT_METHOD",
            "SOURCE_UNIT_SET_PROP_ITEM_CASE",
        ):
            self.assertIn(constant, (PROJECT / "src" / "game" / "SourceUnitSetPropSourceTextState.gd").read_text(encoding="utf-8"))
        for owner in ("PortGame.source_unit_set_prop_laccess_double_state", "PortGame.source_unit_set_prop_laccess_object_state", "PortGame.source_unit_set_prop_content_state"):
            self.assertEqual(contracts[owner]["return_keys"], ["value"] if owner != "PortGame.source_unit_set_prop_content_state" else ["value"])
        for symbol in ("unit_set_prop_laccess_double.method", "unit_set_prop_laccess_double.action", "unit_set_prop_laccess_object.method", "unit_set_prop_laccess_object.action", "unit_set_prop_content.method", "unit_set_prop_content.action"):
            with self.subTest(symbol=symbol):
                self.assertIn(symbol, registry)

        for slice_id, owner in {
            "N1853": "PortGame.source_unit_can_shoot_state",
            "N1854": "PortGame.source_unit_is_enemy_state",
            "N1855": "PortGame.source_unit_collides_state",
            "N1856": "PortGame.source_unit_item_capacity_state",
            "N1857": "PortGame.source_unit_bounds_state",
        }.items():
            self.assertEqual(ledger[slice_id]["godot_owner"], owner)
        for method in ("canShoot_37", "isEnemy_38", "collides_39", "itemCapacity_41", "bounds_42"):
            self.assertNotIn(f"func java_method_{method}(_args: Array = []) -> Variant:\n\treturn null", generated)


if __name__ == "__main__":
    unittest.main()
