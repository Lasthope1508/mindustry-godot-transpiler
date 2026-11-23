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

	# --- Logic.skipWave() (N2439):
	# Logic.skipWave() (Logic.java:315-317). One method
	# slice (batch 38 slot 2): exactly the 1 body expr
	# `runWave();` (:316). skipWave forwards to runWave()
	# (Logic.java:319-325, owned N2437); the envelope adds
	# skipped_wave: true to runWave's 4 result keys. The
	# runWave body exprs (:320-324) are NOT re-registered
	# here. The proof calls the pure function with
	# synthetic inputs (no live tick, no spawner, no
	# event bus): one call increments the wave, returns
	# exactly the 5 result keys with skipped_wave true,
	# computes wavetime from the campaign multiplier
	# (or 1.0 outside campaign), records the two deferred
	# call-sites as data, and is idempotent on a second
	# call.

	# One call increments the wave and returns exactly
	# the 5 result keys, with skipped_wave true.
	var result: Dictionary = game_wave_state.source_game_wave_skip_state(3, 10.0, true, 0.5)
	proof["skip_increments_wave"] = result.get("wave", 0) == 4
	proof["skip_returns_five_keys"] = result.size() == 5
	proof["skip_skipped_wave_true"] = result.get("skipped_wave", false) == true

	# Campaign: wavetime is waveSpacing times the
	# difficulty multiplier (10.0 * 0.5 = 5.0).
	proof["skip_wavetime_campaign"] = result.get("wavetime", 0.0) == 5.0

	# Outside campaign the multiplier is ignored: the
	# factor is 1.0, so wavetime equals waveSpacing
	# (10.0) and the wave still increments (7 -> 8),
	# with skipped_wave still true.
	var plain: Dictionary = game_wave_state.source_game_wave_skip_state(7, 10.0, false, 0.5)
	proof["skip_wavetime_non_campaign"] = plain.get("wavetime", 0.0) == 10.0 and plain.get("wave", 0) == 8 and plain.get("skipped_wave", false) == true

	# The two deferred call-sites are recorded as data:
	# the spawner call and the WaveEvent fire.
	proof["skip_spawn_enemies_true"] = result.get("spawn_enemies", false) == true
	proof["skip_fired_event_wave"] = result.get("fired_event", "") == "WaveEvent"

	# A second call on the same inputs yields the same
	# 5 values: skipWave is a pure function of its
	# inputs, with no hidden state.
	var second: Dictionary = game_wave_state.source_game_wave_skip_state(3, 10.0, true, 0.5)
	proof["skip_idempotent_second_call"] = second.get("skipped_wave", false) == true and second.get("wave", 0) == 4 and second.get("wavetime", 0.0) == 5.0 and second.get("spawn_enemies", false) == true and second.get("fired_event", "") == "WaveEvent" and second.size() == 5

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LogicSkipWaveProof", proof)
