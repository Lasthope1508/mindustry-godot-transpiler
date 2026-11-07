extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_plan_state := preload("res://src/game/SourceBuildingPlanState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var old_plans := [{"x": 3, "y": 4, "block": "old"}, {"x": 9, "y": 9, "block": "other"}]
	var normal_bridge := game.generated_building_comp_add_plan_default_bridge_state(true, true, false, false, true, false, false, false, null, null, "router", "config", 3, 4, 2, old_plans)
	var construct_bridge := game.generated_building_comp_add_plan_bridge_state(false, false, true, false, false, true, true, true, true, "synthetic-block", "saved-config", "construct", "ignored-config", 7, 8, 1, [])
	var blocked_bridge := game.generated_building_comp_add_plan_bridge_state(false, false, false, false, false, true, false, false, false, null, null, "wall", null, 1, 2, 0, [])
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_PLAN_STATE_MODULE_PROOF",
		"normal_bridge_matches": bool(normal_bridge.get("matches", false)) and bool(normal_bridge.get("canonical", {}).get("removed_previous", false)) and int(normal_bridge.get("canonical", {}).get("plans", []).size()) == 2,
		"construct_bridge_matches": bool(construct_bridge.get("matches", false)) and construct_bridge.get("canonical", {}).get("plan", {}).get("block", null) == "synthetic-block" and construct_bridge.get("canonical", {}).get("plan", {}).get("config", null) == "saved-config",
		"blocked_bridge_matches": bool(blocked_bridge.get("matches", false)) and not bool(blocked_bridge.get("canonical", {}).get("added", true)),
		"module_matches": normal_bridge == source_building_plan_state.generated_add_plan_default_bridge_state(true, true, false, false, true, false, false, false, null, null, "router", "config", 3, 4, 2, old_plans),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["normal_bridge_matches"] and proof["construct_bridge_matches"] and proof["blocked_bridge_matches"] and proof["module_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_PLAN_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingPlanStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
