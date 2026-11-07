extends Node

const port_game_script := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_build_update_tile_impulse_net_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileImpulseNetState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := port_game_script.new()
	var target := {"x": 18.0, "y": 24.0}
	var wrapper := game.source_tractor_beam_turret_build_update_tile_impulse_net_state(true, target, 0.0, 0.0, 80.0, 0.25, 0.3, 0.0)
	var module := source_tractor_beam_turret_build_update_tile_impulse_net_state_script.impulse_net_state(true, target, 0.0, 0.0, 80.0, 0.25, 0.3, 0.0)
	var generated_wrapper := game.generated_tractor_beam_turret_build_update_tile_impulse_net_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, target, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, false, "tractor-beam-loop", 0.75, 10.0, 4.0, 2.0, 3.0, 1.0, 6.0, 2.0, 0.25, 1.0, "shocked", 30.0, 0.3, 0.0)
	var generated_module := source_tractor_beam_turret_build_update_tile_impulse_net_state_script.generated_impulse_net_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, target, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, false, "tractor-beam-loop", 0.75, 10.0, 4.0, 2.0, 3.0, 1.0, 6.0, 2.0, 0.25, 1.0, "shocked", 30.0, 0.3, 0.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretBuildUpdateTileImpulseNetState",
		"module_matches": wrapper == module,
		"generated_wrapper_matches": generated_wrapper == generated_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["generated_wrapper_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TRACTOR_BEAM_IMPULSE_NET_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TractorBeamImpulseNetStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

