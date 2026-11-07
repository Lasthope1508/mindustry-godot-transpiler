extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var update_calls: Array = []
	var update_heat_callback := func() -> void: update_calls.append(true)
	var normal := {"id": 2, "team_id": 1, "is_heat_block": true, "is_heat_conductor": false, "x": 1.0, "y": 0.0, "block_rotate": false, "heat": 9.0, "block_size": 1}
	var split := {"id": 3, "team_id": 1, "is_heat_block": true, "is_heat_conductor": true, "split_heat": true, "x": 0.0, "y": 1.0, "block_rotate": false, "heat": 12.0, "block_size": 1}
	var cycle := {"id": 4, "team_id": 1, "is_heat_block": true, "is_heat_conductor": true, "split_heat": false, "x": -1.0, "y": 0.0, "block_rotate": false, "heat": 50.0, "block_size": 1, "came_from": [7]}
	var side_heat := [4.0, 4.0, 4.0, 4.0]
	var canonical := game.source_building_calculate_heat_state(side_heat, [8], [normal, split, cycle], 1, 0.0, 0.0, 1, 8.0, 7, update_heat_callback)
	var default_state := game.source_building_calculate_heat_default_state([2.0, 2.0, 2.0, 2.0], [normal], 1, 0.0, 0.0, 1, 8.0, 7, null)
	var generated := game.generated_building_comp_calculate_heat_bridge_state([4.0, 4.0, 4.0, 4.0], [8], [normal, split, cycle], 1, 0.0, 0.0, 1, 8.0, 7, null)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingHeatState",
		"split_heat": float(canonical.get("heat", 0.0)) == 13.0,
		"came_from": canonical.get("came_from", []).has(2) and canonical.get("came_from", []).has(3) and canonical.get("came_from", []).has(4) and canonical.get("came_from", []).has(7),
		"update_heat": int(canonical.get("update_heat_calls", []).size()) == 2 and update_calls.size() == 2,
		"cycle_ignored": canonical.get("contact_traces", []).size() == 3 and float(canonical.get("contact_traces", [])[2].get("add", 1.0)) == 0.0,
		"default_delegates": float(default_state.get("heat", -1.0)) == 9.0,
		"generated_matches": bool(generated.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["split_heat"] and proof["came_from"] and proof["update_heat"] and proof["cycle_ignored"] and proof["default_delegates"] and proof["generated_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_HEAT_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingHeatStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
