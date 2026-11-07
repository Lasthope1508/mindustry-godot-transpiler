extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_build_update_tile_flow_state := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileFlowState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var existing_target := {"id": 1, "team": "sharded"}
	var closest_enemy_result := {"id": 2, "team": "crux"}
	var retarget_bridge := game.generated_tractor_beam_turret_build_update_tile_retarget_bridge_state(0.0, 1.0, 0.75, 1.5, 2.0, true, existing_target, closest_enemy_result, "sharded", 16.0, 24.0, 120.0, true, false)
	var proof := {
		"module": "SourceTractorBeamTurretBuildUpdateTileFlowState",
		"retarget_bridge_matches": retarget_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_retarget_bridge_state(0.0, 1.0, 0.75, 1.5, 2.0, true, existing_target, closest_enemy_result, "sharded", 16.0, 24.0, 120.0, true, false) and bool(retarget_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["retarget_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TRACTOR_BEAM_UPDATE_TILE_RETARGET_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TractorBeamUpdateTileRetargetModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

