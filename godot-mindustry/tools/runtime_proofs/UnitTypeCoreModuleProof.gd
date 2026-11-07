extends Node

const UnitTypeScript := preload("res://src/generated/classes/mindustry/type/UnitType.gd")
const source_unit_type_state := preload("res://src/game/SourceUnitTypeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _controller_factory(unit: Variant) -> Variant:
	return {"controller_for": unit}

func _ready() -> void:
	var generated := UnitTypeScript.new()
	var unit := {"id": "dagger"}
	var controller_bridge := source_unit_type_state.generated_create_controller_bridge_state(Callable(self, "_controller_factory"), unit)
	var weapons_empty := source_unit_type_state.generated_has_weapons_bridge_state([])
	var weapons_present := source_unit_type_state.generated_has_weapons_bridge_state([{"id": "weapon"}])
	var targetable_direct := source_unit_type_state.generated_targetable_bridge_state(true, false, false, false, unit, {"id": 1})
	var targetable_payload := source_unit_type_state.generated_targetable_bridge_state(false, true, true, true, unit, {"id": 1})
	var targetable_non_payload := source_unit_type_state.generated_targetable_bridge_state(false, true, true, false, unit, {"id": 1})
	var killable := source_unit_type_state.generated_killable_bridge_state(true, unit)
	var hittable_payload := source_unit_type_state.generated_hittable_bridge_state(false, true, true, true, unit)
	var hittable_non_payload := source_unit_type_state.generated_hittable_bridge_state(false, true, true, false, unit)
	var stances_non_command := source_unit_type_state.generated_get_unit_stances_bridge_state(false, false, false, false, [], [], [], [])
	var stances_mining := source_unit_type_state.generated_get_unit_stances_bridge_state(true, true, true, false, [{"can_mine": true, "has_ore": true, "has_wall_ore": false, "item_stance": "copper"}], [], ["boost"], [])
	var stances_compatible := source_unit_type_state.generated_get_unit_stances_bridge_state(true, false, false, false, [], [{"compatible": true, "stance": "hold"}, {"compatible": false, "stance": "move"}], ["assist"], [])
	var allow_stop := source_unit_type_state.generated_allow_stance_bridge_state("UnitStance.stop", false, false, false, false, [], [], [], [])
	var allow_mine := source_unit_type_state.generated_allow_stance_bridge_state("copper", true, true, true, false, [{"can_mine": true, "has_ore": true, "item_stance": "copper"}], [], [], [])
	var command_allowed := source_unit_type_state.generated_allow_command_bridge_state(["mine", "move"], "mine")
	var command_blocked := source_unit_type_state.generated_allow_command_bridge_state(["mine", "move"], "assist")
	var update_hook := source_unit_type_state.generated_update_bridge_state(unit)
	var update_payload_hook := source_unit_type_state.generated_update_payload_bridge_state(unit, {"id": "carrier"}, {"id": "factory"})
	var killed_hook := source_unit_type_state.generated_killed_bridge_state(unit)
	var landed_hook := source_unit_type_state.generated_landed_bridge_state(unit)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "UnitTypeCoreModuleProof",
		"create_controller_matches": bool(controller_bridge.get("matches", false)),
		"has_weapons_empty_matches": bool(weapons_empty.get("matches", false)),
		"has_weapons_present_matches": bool(weapons_present.get("matches", false)),
		"targetable_direct_matches": bool(targetable_direct.get("matches", false)),
		"targetable_payload_matches": bool(targetable_payload.get("matches", false)),
		"targetable_non_payload_matches": bool(targetable_non_payload.get("matches", false)),
		"killable_matches": bool(killable.get("matches", false)),
		"hittable_payload_matches": bool(hittable_payload.get("matches", false)),
		"hittable_non_payload_matches": bool(hittable_non_payload.get("matches", false)),
		"stances_non_command_matches": bool(stances_non_command.get("matches", false)) and bool(stances_non_command.get("canonical", {}).get("returned_early", false)),
		"stances_mining_matches": bool(stances_mining.get("matches", false)) and stances_mining.get("canonical", {}).get("out", []) == ["UnitStance.mineAuto", "copper", "boost"],
		"stances_compatible_matches": bool(stances_compatible.get("matches", false)) and stances_compatible.get("canonical", {}).get("out", []) == ["hold", "assist"],
		"allow_stop_matches": bool(allow_stop.get("matches", false)) and bool(allow_stop.get("canonical", {}).get("allowed", false)),
		"allow_mine_matches": bool(allow_mine.get("matches", false)) and bool(allow_mine.get("canonical", {}).get("allowed", false)),
		"command_allowed_matches": bool(command_allowed.get("matches", false)) and bool(command_allowed.get("canonical", {}).get("allowed", false)),
		"command_blocked_matches": bool(command_blocked.get("matches", false)) and not bool(command_blocked.get("canonical", {}).get("allowed", true)),
		"update_hook_matches": bool(update_hook.get("matches", false)) and bool(update_hook.get("canonical", {}).get("no_op", false)),
		"update_payload_hook_matches": bool(update_payload_hook.get("matches", false)) and bool(update_payload_hook.get("canonical", {}).get("no_op", false)),
		"killed_hook_matches": bool(killed_hook.get("matches", false)) and bool(killed_hook.get("canonical", {}).get("no_op", false)),
		"landed_hook_matches": bool(landed_hook.get("matches", false)) and bool(landed_hook.get("canonical", {}).get("no_op", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"generated_methods_present": generated.has_method("java_method_createController_1") and generated.has_method("java_method_hasWeapons_10") and generated.has_method("java_method_targetable_11") and generated.has_method("java_method_killable_12") and generated.has_method("java_method_hittable_13") and generated.has_method("java_method_getUnitStances_14") and generated.has_method("java_method_allowStance_15") and generated.has_method("java_method_allowCommand_16") and generated.has_method("java_method_update_17") and generated.has_method("java_method_updatePayload_18") and generated.has_method("java_method_killed_19") and generated.has_method("java_method_landed_20"),
	}
	proof["matches"] = true
	for key in proof.keys():
		if str(key).ends_with("_matches") or key == "registry_valid" or key == "one_headquarter_per_ssot" or key == "generated_methods_present":
			proof["matches"] = proof["matches"] and bool(proof[key])
	runtime_proof_state.write_proof("UnitTypeCoreModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
