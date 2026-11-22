extends Node

const wave_spawner_state := preload("res://src/game/SourceWaveSpawnerState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- WaveSpawner.countSpawns() (N2442):
	# WaveSpawner.countSpawns() (WaveSpawner.java:49-51). One method
	# slice (batch 39 slot 2): exactly the 1 body expr
	# `return spawns.size;` (:50). `spawns` is the WaveSpawner
	# field `private Seq<Tile> spawns = new Seq<>(false);`
	# (WaveSpawner.java:26); GD takes it as an Array input and
	# does not recompute it from the world. The proof calls the
	# pure function with synthetic spawn lists (no live tick, no
	# world scan, no spawner): 0 spawns -> 0, 1 spawn -> 1, n
	# spawns -> n, exactly 1 result key, and a second call on
	# the same inputs yields the same value.

	# 0 spawns -> 0.
	proof["count_zero_spawns"] = int(wave_spawner_state.source_wave_spawner_count_spawns_state([]).get("count", -1)) == 0

	# 1 spawn -> 1.
	proof["count_one_spawn"] = int(wave_spawner_state.source_wave_spawner_count_spawns_state([{}]).get("count", -1)) == 1

	# n spawns -> n.
	proof["count_many_spawns"] = int(wave_spawner_state.source_wave_spawner_count_spawns_state([{}, {}, {}, {}, {}]).get("count", -1)) == 5

	# Exactly 1 result key: count.
	proof["count_returns_one_key"] = wave_spawner_state.source_wave_spawner_count_spawns_state([{}, {}]).size() == 1

	# A second call on the same inputs yields the same value:
	# countSpawns is a pure function of its inputs, with no
	# hidden state.
	var second: Dictionary = wave_spawner_state.source_wave_spawner_count_spawns_state([{}, {}, {}])
	proof["count_idempotent_second_call"] = int(second.get("count", -1)) == 3 and second.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WaveSpawnerCountSpawnsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
