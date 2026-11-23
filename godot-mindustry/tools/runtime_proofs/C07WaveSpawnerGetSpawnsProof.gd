extends Node

const wave_spawner_state := preload("res://src/game/SourceWaveSpawnerState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- WaveSpawner.getSpawns() (N2446):
	# WaveSpawner.getSpawns() (WaveSpawner.java:53-55). One method
	# slice (batch 41 slot 1): exactly the 1 body expr
	# `return spawns;` (:54). `spawns` is the WaveSpawner field
	# `private Seq<Tile> spawns = new Seq<>(false);`
	# (WaveSpawner.java:26); GD takes it as an Array input and
	# returns it as-is (precedent N2442 countSpawns, same field;
	# N2123/N2297 micro-accessors). The proof calls the pure
	# function with synthetic frame inputs (no live tick, no
	# spawner): 0 spawns -> []; n spawns -> the exact input
	# array, order preserved; exactly 1 result key, and a
	# second call on the same inputs yields the same value.

	# 0 spawns -> [].
	proof["spawns_empty_when_no_spawns"] = Array(wave_spawner_state.source_wave_spawner_get_spawns_state([]).get("spawns", [1])) == []

	# n spawns -> the exact input array.
	var spawns: Array = ["tile_a", "tile_b", "tile_c"]
	proof["spawns_returns_input_array"] = Array(wave_spawner_state.source_wave_spawner_get_spawns_state(spawns).get("spawns", [])) == spawns

	# Order preserved: first and last entries match the input.
	var returned: Array = Array(wave_spawner_state.source_wave_spawner_get_spawns_state(spawns).get("spawns", []))
	proof["spawns_preserves_order"] = returned.size() == 3 and returned[0] == "tile_a" and returned[2] == "tile_c"

	# Exactly 1 result key: spawns.
	proof["spawns_returns_one_key"] = wave_spawner_state.source_wave_spawner_get_spawns_state(spawns).size() == 1

	# A second call on the same inputs yields the same value:
	# getSpawns is a pure function of its inputs, with no
	# hidden state.
	var second: Dictionary = wave_spawner_state.source_wave_spawner_get_spawns_state(spawns)
	proof["spawns_idempotent_second_call"] = Array(second.get("spawns", [])) == spawns and second.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WaveSpawnerGetSpawnsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
