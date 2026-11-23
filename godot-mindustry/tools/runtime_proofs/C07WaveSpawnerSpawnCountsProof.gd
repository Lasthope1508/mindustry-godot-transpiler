extends Node

const wave_spawner_state := preload("res://src/game/SourceWaveSpawnerState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- WaveSpawner.countGroundSpawns() + countFlyerSpawns() (N2453):
	# WaveSpawner.countGroundSpawns() (WaveSpawner.java:201-205) +
	# WaveSpawner.countFlyerSpawns() (WaveSpawner.java:207-211). One
	# combined slice (batch 43 slot 2): exactly the 4 distinct body
	# exprs -- `tmpCount = 0;` (:202/:208, shared),
	# `eachGroundSpawn((x, y) -> tmpCount ++);` (:203),
	# `eachFlyerSpawn(-1, (x, y) -> tmpCount ++);` (:209) and
	# `return tmpCount;` (:204/:210, shared). Each Java method resets
	# tmpCount, counts one callback invocation per enumerated spawn
	# point, and returns the total -- so the count IS the size of the
	# enumerated list. GD takes the two already-enumerated lists as
	# Array inputs (option (A) data-driven, decided at spawn) and
	# does not enumerate them itself: eachGroundSpawn / eachFlyerSpawn
	# are NOT ported and belong to later slices. The proof calls the
	# pure function with synthetic spawn-point lists (no live tick,
	# no spawner, no world scan): 2 counts x 3 cases each (empty -> 0,
	# 1 point -> 1, N points -> N), exactly 2 result keys, and a
	# second call on the same inputs yields the same values.

	# Ground: 0 points -> 0.
	proof["ground_count_zero_when_empty"] = int(wave_spawner_state.source_wave_spawner_spawn_counts_state([], []).get("ground_spawn_count", -1)) == 0

	# Ground: 1 point -> 1.
	proof["ground_count_one_when_one_point"] = int(wave_spawner_state.source_wave_spawner_spawn_counts_state([{}], []).get("ground_spawn_count", -1)) == 1

	# Ground: N points -> N.
	proof["ground_count_many_points"] = int(wave_spawner_state.source_wave_spawner_spawn_counts_state([{}, {}, {}, {}], []).get("ground_spawn_count", -1)) == 4

	# Flyer: 0 points -> 0.
	proof["flyer_count_zero_when_empty"] = int(wave_spawner_state.source_wave_spawner_spawn_counts_state([], []).get("flyer_spawn_count", -1)) == 0

	# Flyer: 1 point -> 1.
	proof["flyer_count_one_when_one_point"] = int(wave_spawner_state.source_wave_spawner_spawn_counts_state([], [{}]).get("flyer_spawn_count", -1)) == 1

	# Flyer: N points -> N.
	proof["flyer_count_many_points"] = int(wave_spawner_state.source_wave_spawner_spawn_counts_state([], [{}, {}, {}]).get("flyer_spawn_count", -1)) == 3

	# Exactly 2 result keys: ground_spawn_count + flyer_spawn_count.
	proof["spawn_counts_returns_two_keys"] = wave_spawner_state.source_wave_spawner_spawn_counts_state([{}], [{}, {}]).size() == 2

	# A second call on the same inputs yields the same values:
	# spawn counts are a pure function of their inputs, with no
	# hidden state (no tmpCount field is kept between calls).
	var second: Dictionary = wave_spawner_state.source_wave_spawner_spawn_counts_state([{}, {}], [{}, {}, {}])
	proof["spawn_counts_idempotent_second_call"] = int(second.get("ground_spawn_count", -1)) == 2 and int(second.get("flyer_spawn_count", -1)) == 3 and second.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WaveSpawnerSpawnCountsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
