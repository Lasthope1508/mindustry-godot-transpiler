extends Node

const wave_spawner_state := preload("res://src/game/SourceWaveSpawnerState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- WaveSpawner.getFirstSpawn() (N2455):
	# WaveSpawner.getFirstSpawn() (WaveSpawner.java:40-47): the 3
	# distinct body exprs only -- `firstSpawn = null;` (:42),
	# `eachGroundSpawn((cx, cy) -> { firstSpawn = world.tile(cx, cy); });`
	# (:43-45) and `return firstSpawn;` (:46). TRAP: despite the
	# name, the callback overwrites firstSpawn UNCONDITIONALLY on
	# every enumerated ground spawn point, so the method returns
	# the LAST enumerated tile, not the first. GD takes the
	# already-enumerated ground spawn tiles as an Array input
	# (option (A) data-driven, precedent N2453) and does not
	# enumerate them itself: eachGroundSpawn is NOT ported and
	# belongs to a later slice. The proof calls the pure function
	# with synthetic tile dicts (no live tick, no spawner, no
	# world scan).

	var tile_a := {"x": 1, "y": 2}
	var tile_b := {"x": 3, "y": 4}
	var tile_c := {"x": 5, "y": 6}

	# Empty list -> null (the :42 reset stands, callback never runs).
	var empty_result: Dictionary = wave_spawner_state.source_wave_spawner_get_first_spawn_state([])
	proof["empty_list_returns_null"] = empty_result.has("first_spawn") and empty_result.get("first_spawn") == null

	# 1 tile -> that tile.
	proof["single_tile_returns_that_tile"] = wave_spawner_state.source_wave_spawner_get_first_spawn_state([tile_a]).get("first_spawn") == tile_a

	# TRAP: >=2 tiles -> the LAST tile, NOT the first.
	proof["last_tile_wins_not_first"] = wave_spawner_state.source_wave_spawner_get_first_spawn_state([tile_a, tile_b, tile_c]).get("first_spawn") == tile_c

	# Reversing the enumeration order flips the result to the
	# other end: the result depends on order, not tile content.
	proof["order_sensitivity_reversed"] = wave_spawner_state.source_wave_spawner_get_first_spawn_state([tile_c, tile_b, tile_a]).get("first_spawn") == tile_a

	# Exactly 1 result key: first_spawn.
	proof["get_first_spawn_returns_one_key"] = wave_spawner_state.source_wave_spawner_get_first_spawn_state([tile_a, tile_b]).size() == 1

	# A second call on the same inputs yields the same value:
	# getFirstSpawn is a pure function of its inputs, with no
	# hidden state (no firstSpawn field is kept between calls).
	var second: Dictionary = wave_spawner_state.source_wave_spawner_get_first_spawn_state([tile_a, tile_b, tile_c])
	proof["get_first_spawn_idempotent_second_call"] = second.get("first_spawn") == tile_c and second.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WaveSpawnerGetFirstSpawnProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
