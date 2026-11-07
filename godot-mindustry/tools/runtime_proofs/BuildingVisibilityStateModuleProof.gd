extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_visibility_state := preload("res://src/game/SourceBuildingVisibilityState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var discovered_tiles := {Vector2i(12, 18): true}
	var fog_discovered_lookup := func(x: int, y: int) -> bool: return bool(discovered_tiles.get(Vector2i(x, y), false))
	var is_discovered_bridge := game.generated_building_comp_is_discovered_bridge_state(false, 0.0, true, true, true, 4, 10, 20, fog_discovered_lookup)
	var map_darkness_bridge := game.generated_building_comp_is_discovered_bridge_state(true, 3.0, true, true, true, 4, 10, 20, fog_discovered_lookup)
	var initial_bridge := game.generated_building_comp_in_fog_initial_gate_bridge_state(false, true)
	var discovery_bridge := game.generated_building_comp_in_fog_discovery_gate_bridge_state(2, -1, 10, 20, false)
	var visibility_bridge := game.generated_building_comp_in_fog_visibility_loop_bridge_state(2, -1, 10, 20, [{"x": 10, "y": 19}])
	var update_fog_bridge := game.generated_building_comp_update_fog_visibility_bridge_state(false, false, 1, 3, {"self": true}, {"tile": true})
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_VISIBILITY_STATE_MODULE_PROOF",
		"is_discovered_bridge": is_discovered_bridge,
		"map_darkness_bridge": map_darkness_bridge,
		"initial_bridge": initial_bridge,
		"discovery_bridge": discovery_bridge,
		"visibility_bridge": visibility_bridge,
		"update_fog_bridge": update_fog_bridge,
		"initial_bridge_matches": initial_bridge == source_building_visibility_state.generated_in_fog_initial_gate_bridge_state(false, true),
		"is_discovered_bridge_matches": bool(is_discovered_bridge.get("matches", false)) and bool(is_discovered_bridge.get("canonical", {}).get("is_discovered", false)),
		"map_darkness_bridge_matches": bool(map_darkness_bridge.get("matches", false)) and not bool(map_darkness_bridge.get("canonical", {}).get("is_discovered", true)),
		"discovery_bridge_matches": discovery_bridge == source_building_visibility_state.generated_in_fog_discovery_gate_bridge_state(2, -1, 10, 20, false),
		"visibility_bridge_matches": visibility_bridge == source_building_visibility_state.generated_in_fog_visibility_loop_bridge_state(2, -1, 10, 20, [{"x": 10, "y": 19}]),
		"update_fog_bridge_matches": update_fog_bridge == source_building_visibility_state.generated_update_fog_visibility_bridge_state(false, false, 1, 3, {"self": true}, {"tile": true}),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["is_discovered_bridge_matches"] and proof["map_darkness_bridge_matches"] and proof["initial_bridge_matches"] and proof["discovery_bridge_matches"] and proof["visibility_bridge_matches"] and proof["update_fog_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_VISIBILITY_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingVisibilityStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
