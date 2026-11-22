extends Node

const main_scene := preload("res://scenes/Main.tscn")
const game_wave_state := preload("res://src/game/SourceGameWaveState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- Logic.runWave() (N2437):
	# Logic.runWave() (Logic.java:319-325). One method
	# slice (batch 37 slot 3): exactly the 4 body exprs.
	# The wavetime formula in play() (Logic.java:272,
	# with initialWaveSpacing + `* 2`) is NOT in this
	# slice, nor is skipWave() (Logic.java:315-317, a
	# later 1-expr slice once runWave lands) nor the
	# gameOver() wavesLasted line (Logic.java:434, a
	# different method). The two call-sites are deferred
	# as data in the returned Dictionary:
	# spawner.spawnEnemies() waits for a WaveSpawner
	# slice (WaveSpawner.java unscanned, 0-hit both
	# ledgers) and Events.fire(new WaveEvent()) waits
	# for an event bus (method Events.on 0-hit both
	# ledgers; no bus in the port). The proof calls the
	# pure function with synthetic inputs (no live tick,
	# no spawner, no event bus): one call increments
	# the wave, returns exactly the 4 result keys,
	# computes wavetime from the campaign multiplier
	# (or 1.0 outside campaign), records the two
	# deferred call-sites as data, and is idempotent on
	# a second call.

	# One call increments the wave and returns exactly
	# the 4 result keys, nothing else.
	var result: Dictionary = game_wave_state.source_game_wave_run_state(3, 10.0, true, 0.5)
	proof["run_increments_wave"] = result.get("wave", 0) == 4
	proof["run_returns_only_four_keys"] = result.size() == 4

	# Campaign: wavetime is waveSpacing times the
	# difficulty multiplier (10.0 * 0.5 = 5.0).
	proof["run_wavetime_campaign"] = result.get("wavetime", 0.0) == 5.0

	# Outside campaign the multiplier is ignored: the
	# factor is 1.0, so wavetime equals waveSpacing
	# (10.0) and the wave still increments (7 -> 8).
	var plain: Dictionary = game_wave_state.source_game_wave_run_state(7, 10.0, false, 0.5)
	proof["run_wavetime_non_campaign"] = plain.get("wavetime", 0.0) == 10.0 and plain.get("wave", 0) == 8

	# The two deferred call-sites are recorded as data:
	# the spawner call and the WaveEvent fire.
	proof["run_spawn_enemies_true"] = result.get("spawn_enemies", false) == true
	proof["run_fired_event_wave"] = result.get("fired_event", "") == "WaveEvent"

	# Wavetime is the float 5.0 (10.0 * 0.5), not an
	# int and not 10.0.
	proof["run_wavetime_is_float"] = result.get("wavetime", 0.0) == 5.0 and typeof(result.get("wavetime", 0)) == TYPE_FLOAT

	# A second call on the same inputs yields the same
	# 4 values: runWave is a pure function of its
	# inputs, with no hidden state.
	var second: Dictionary = game_wave_state.source_game_wave_run_state(3, 10.0, true, 0.5)
	proof["run_idempotent_second_call"] = second.get("wave", 0) == 4 and second.get("wavetime", 0.0) == 5.0 and second.get("spawn_enemies", false) == true and second.get("fired_event", "") == "WaveEvent" and second.size() == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LogicRunWaveProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
