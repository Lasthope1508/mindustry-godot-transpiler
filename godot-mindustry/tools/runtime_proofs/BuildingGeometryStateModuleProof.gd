extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var hitbox_bridge := game.generated_building_comp_hitbox_bridge_state(10.0, 20.0, 2, 8.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_GEOMETRY_STATE_MODULE_PROOF",
		"hitbox_bridge": hitbox_bridge,
		"hitbox_bridge_matches": hitbox_bridge == source_block_geometry.generated_building_hitbox_bridge_state(10.0, 20.0, 2, 8.0),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["hitbox_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_GEOMETRY_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingGeometryStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

