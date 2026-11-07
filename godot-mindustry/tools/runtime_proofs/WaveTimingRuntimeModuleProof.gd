extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_wave_timing_runtime_state := preload("res://src/game/SourceWaveTimingRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.wave_cooldown = 0.5
	game.enemy_units = []
	var seconds := 1.0
	var wrapper_state: Dictionary = game.source_wave_timing_runtime_state(seconds)
	var module_state: Dictionary = source_wave_timing_runtime_state.game_wave_timer_state(game, seconds)
	var primitive_state: Dictionary = source_wave_timing_runtime_state.wave_timer_state(
		0.5,
		seconds * source_time_defaults.TICK_RATE,
		source_playable_scenario_defaults.PLAYABLE_WAVE_SPACING_SECONDS * source_time_defaults.TICK_RATE,
		0
	)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "WAVE_TIMING_RUNTIME_MODULE_PROOF",
		"game_wrapper_matches": wrapper_state == module_state,
		"primitive_matches": module_state == primitive_state,
		"spawn_matches": bool(module_state.get("should_spawn", false)),
		"cooldown_matches": is_equal_approx(float(module_state.get("wavetime", 0.0)), source_playable_scenario_defaults.PLAYABLE_WAVE_SPACING_SECONDS * source_time_defaults.TICK_RATE),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["game_wrapper_matches"] and proof["primitive_matches"] and proof["spawn_matches"] and proof["cooldown_matches"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	runtime_proof_state.write_proof("WaveTimingRuntimeModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

