extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_turret_placement_state := preload("res://src/game/SourceTurretPlacementState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var draw_place := game.source_turret_draw_place_state(1, 2, 3, true, true, 8.0, 0.0, 0.0)
	var rotated_output := game.source_turret_rotated_output_state(1, 2)
	var place_ended := game.source_turret_place_ended_state(null, null, 0, null, true, true, 90.0, 45.0)
	var draw_place_bridge := game.generated_turret_draw_place_bridge_state(1, 2, 3, true, true, 8.0, 0.0, 0.0)
	var draw_place_bridge_module := source_turret_placement_state.generated_draw_place_bridge_state(1, 2, 3, true, true, 8.0, 0.0, 0.0)
	var draw_place_default_bridge := game.generated_turret_draw_place_source_tilesize_default_bridge_state(1, 2, 3, true, true)
	var draw_place_default_bridge_module := source_turret_placement_state.generated_draw_place_source_tilesize_default_bridge_state(1, 2, 3, true, true, 8.0)
	var rotated_output_bridge := game.generated_turret_rotated_output_bridge_state(1, 2)
	var rotated_output_bridge_module := source_turret_placement_state.generated_rotated_output_bridge_state(1, 2)
	var place_ended_bridge := game.generated_turret_place_ended_bridge_state(null, null, 0, null, true, true, 90.0, 45.0)
	var place_ended_bridge_module := source_turret_placement_state.generated_place_ended_bridge_state(null, null, 0, null, true, true, 90.0, 45.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTurretPlacementState",
		"draw_place_matches": draw_place.get("dash_circle_called", false),
		"rotated_output_matches": rotated_output.get("rotated_output", true) == false,
		"place_ended_matches": place_ended.get("rotation_assigned", false) and place_ended.get("turret_rotation_after", null) == 45.0,
		"draw_place_bridge_matches": draw_place_bridge == draw_place_bridge_module and bool(draw_place_bridge.get("matches", false)),
		"draw_place_default_bridge_matches": draw_place_default_bridge == draw_place_default_bridge_module and bool(draw_place_default_bridge.get("matches", false)),
		"rotated_output_bridge_matches": rotated_output_bridge == rotated_output_bridge_module and bool(rotated_output_bridge.get("matches", false)),
		"place_ended_bridge_matches": place_ended_bridge == place_ended_bridge_module and bool(place_ended_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["draw_place_matches"] and proof["rotated_output_matches"] and proof["place_ended_matches"]
	proof["matches"] = proof["module_matches"] and proof["draw_place_bridge_matches"] and proof["draw_place_default_bridge_matches"] and proof["rotated_output_bridge_matches"] and proof["place_ended_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TURRET_PLACEMENT_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TurretPlacementModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

