extends Node

const port_game_script := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_build_update_tile_sound_loop_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileSoundLoopState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := port_game_script.new()
	var target := {"x": 18.0, "y": 24.0}
	var wrapper := game.source_tractor_beam_turret_build_update_tile_sound_loop_state(true, false, "tractor-beam-loop", 0.75)
	var module := source_tractor_beam_turret_build_update_tile_sound_loop_state_script.sound_loop_state(true, false, "tractor-beam-loop", 0.75)
	var generated_wrapper := game.generated_tractor_beam_turret_build_update_tile_sound_loop_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, target, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, false, "tractor-beam-loop", 0.75)
	var generated_module := source_tractor_beam_turret_build_update_tile_sound_loop_state_script.generated_sound_loop_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, target, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, false, "tractor-beam-loop", 0.75)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretBuildUpdateTileSoundLoopState",
		"module_matches": wrapper == module,
		"generated_wrapper_matches": generated_wrapper == generated_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("TRACTOR_BEAM_SOUND_LOOP_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
