extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_runtime_geometry_state := preload("res://src/game/SourceBlockRuntimeGeometryState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var new_building_bridge := game.generated_block_new_building_bridge_state("building-factory")
	var update_clip_radius_bridge := game.generated_block_update_clip_radius_bridge_state(12.0, 2, 8.0, 5.0)
	var bounds_bridge := game.generated_block_bounds_bridge_state(3, 4, 2, 8.0, 4.0, {"kind": "rect"})
	var direct_source_facades_match: bool = \
		game.source_block_new_building_state("building-factory") == source_block_runtime_geometry_state.new_building_state("building-factory") \
		and game.source_block_update_clip_radius_state(12.0, 2, 8.0, 5.0) == source_block_runtime_geometry_state.update_clip_radius_state(12.0, 2, 8.0, 5.0) \
		and game.source_block_bounds_state(3, 4, 2, 8.0, 4.0, {"kind": "rect"}) == source_block_runtime_geometry_state.bounds_state(3, 4, 2, 8.0, 4.0, {"kind": "rect"})
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_RUNTIME_GEOMETRY_MODULE_PROOF",
		"new_building_bridge": new_building_bridge,
		"update_clip_radius_bridge": update_clip_radius_bridge,
		"bounds_bridge": bounds_bridge,
		"direct_source_facades_match": direct_source_facades_match,
		"new_building_bridge_matches": new_building_bridge == source_block_runtime_geometry_state.generated_block_new_building_bridge_state("building-factory"),
		"update_clip_radius_bridge_matches": update_clip_radius_bridge == source_block_runtime_geometry_state.generated_block_update_clip_radius_bridge_state(12.0, 2, 8.0, 5.0),
		"bounds_bridge_matches": bounds_bridge == source_block_runtime_geometry_state.generated_block_bounds_bridge_state(3, 4, 2, 8.0, 4.0, {"kind": "rect"}),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(new_building_bridge.get("matches", false)) \
		and bool(update_clip_radius_bridge.get("matches", false)) \
		and bool(bounds_bridge.get("matches", false)) \
		and proof["new_building_bridge_matches"] \
		and proof["update_clip_radius_bridge_matches"] \
		and proof["bounds_bridge_matches"] \
		and proof["direct_source_facades_match"] \
		and proof["registry_valid"] \
		and proof["one_headquarter_per_ssot"]
	print("BLOCK_RUNTIME_GEOMETRY_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BlockRuntimeGeometryModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
