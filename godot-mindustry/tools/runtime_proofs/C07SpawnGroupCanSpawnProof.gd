extends Node

const wave_spawn_runtime_state := preload("res://src/game/SourceWaveSpawnRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- SpawnGroup.canSpawn(int) (N2447):
	# SpawnGroup.canSpawn(int) (SpawnGroup.java:62-64). One method
	# slice (batch 41 slot 2): exactly the 1 body expr
	# `return spawn == -1 || spawn == position;` (:63). `spawn` is the
	# SpawnGroup field `public int spawn = -1;`
	# (SpawnGroup.java:44, "If not -1, the unit will only spawn in
	# spawnpoints with these packed coordinates."): -1 means every
	# position. The proof calls the pure function with synthetic
	# frame inputs (no live tick, no spawner): spawn == -1 -> true
	# for any position; spawn == position -> true; spawn different
	# from position (both >= 0) -> false; exactly 1 result key, and
	# a second call on the same inputs yields the same value.

	# spawn == -1 -> true for any position.
	proof["can_spawn_true_when_spawn_minus_one"] = bool(wave_spawn_runtime_state.source_wave_spawn_can_spawn_state(-1, 12345).get("can_spawn", false)) == true

	# spawn == position -> true.
	proof["can_spawn_true_when_spawn_equals_position"] = bool(wave_spawn_runtime_state.source_wave_spawn_can_spawn_state(42, 42).get("can_spawn", false)) == true

	# spawn different from position (both >= 0) -> false.
	proof["can_spawn_false_when_different"] = bool(wave_spawn_runtime_state.source_wave_spawn_can_spawn_state(42, 43).get("can_spawn", true)) == false

	# Exactly 1 result key: can_spawn.
	proof["can_spawn_returns_one_key"] = wave_spawn_runtime_state.source_wave_spawn_can_spawn_state(-1, 0).size() == 1

	# A second call on the same inputs yields the same value:
	# canSpawn is a pure function of its inputs, with no
	# hidden state.
	var second: Dictionary = wave_spawn_runtime_state.source_wave_spawn_can_spawn_state(-1, 12345)
	proof["can_spawn_idempotent_second_call"] = bool(second.get("can_spawn", false)) == true and second.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SpawnGroupCanSpawnProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
