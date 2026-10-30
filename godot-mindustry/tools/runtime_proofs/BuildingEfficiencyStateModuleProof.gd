extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var update_consumption_call_bridge := game.generated_building_comp_update_consumption_call_bridge_state()
	var update_consumption_initial_bridge := game.generated_building_comp_update_consumption_initial_bridge_state(false, false, true, true, true, 1.0)
	var update_consumption_disabled_bridge := game.generated_building_comp_update_consumption_disabled_bridge_state(false)
	var update_consumption_setup_bridge := game.generated_building_comp_update_consumption_setup_bridge_state(true, true)
	var update_consumption_non_optional_bridge := game.generated_building_comp_update_consumption_non_optional_bridge_state([{"result": 0.5, "is_power": false}, {"result": 0.0, "is_power": true}])
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_EFFICIENCY_STATE_MODULE_PROOF",
		"update_consumption_call_bridge": update_consumption_call_bridge,
		"update_consumption_call_bridge_matches": update_consumption_call_bridge == source_building_efficiency_state.generated_update_consumption_call_bridge_state(),
		"update_consumption_initial_branch_matches": update_consumption_initial_bridge.get("result") == update_consumption_initial_bridge.get("canonical"),
		"update_consumption_disabled_branch_matches": update_consumption_disabled_bridge.get("result") == update_consumption_disabled_bridge.get("canonical"),
		"update_consumption_setup_branch_matches": update_consumption_setup_bridge.get("result") == update_consumption_setup_bridge.get("canonical"),
		"update_consumption_non_optional_branch_matches": update_consumption_non_optional_bridge.get("result") == update_consumption_non_optional_bridge.get("canonical"),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["update_consumption_call_bridge_matches"] and proof["update_consumption_initial_branch_matches"] and proof["update_consumption_disabled_branch_matches"] and proof["update_consumption_setup_branch_matches"] and proof["update_consumption_non_optional_branch_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_EFFICIENCY_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingEfficiencyStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
