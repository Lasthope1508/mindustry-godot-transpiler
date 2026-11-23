extends Node

const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Logic.isWaitingWave() (Logic.java:605-607):
	# `return (state.rules.waitEnemies || (state.wave >=
	# state.rules.winWave && state.rules.winWave > 0)) &&
	# state.enemies > 0;` — whether the wave timer is paused
	# due to enemies (javadoc :604). Pure predicate over the
	# frame inputs; `state.enemies` is read as-is and never
	# counted here (the count leg lives in Logic.update, a
	# later slice).

	# waitEnemies with enemies still alive -> the wave
	# timer is paused, the wave is waiting.
	proof["waiting_wait_enemies"] = bool(game_loop_state.source_game_loop_is_waiting_wave_state(true, 1, 0, 3).get("waiting", false)) == true

	# No waitEnemies, but the wave reached winWave (10/10)
	# with enemies still alive -> waiting.
	proof["waiting_win_wave_reached"] = bool(game_loop_state.source_game_loop_is_waiting_wave_state(false, 10, 10, 2).get("waiting", false)) == true

	# No enemies left -> not waiting even with waitEnemies
	# (the `state.enemies > 0` conjunct).
	proof["waiting_no_enemies"] = bool(game_loop_state.source_game_loop_is_waiting_wave_state(true, 1, 0, 0).get("waiting", true)) == false

	# Wave short of winWave (5/10) with enemies -> not
	# waiting (the `wave >= winWave` disjunct is false).
	proof["waiting_win_wave_not_reached"] = bool(game_loop_state.source_game_loop_is_waiting_wave_state(false, 5, 10, 2).get("waiting", true)) == false

	# winWave 0 means no win wave: `wave >= winWave`
	# holds but the `winWave > 0` guard fails -> not
	# waiting.
	proof["waiting_win_wave_zero"] = bool(game_loop_state.source_game_loop_is_waiting_wave_state(false, 5, 0, 2).get("waiting", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LogicIsWaitingWaveProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
