extends Node

const game_stats_state := preload("res://src/game/SourceGameStatsRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- GameStats.getPlaced(Block) + getDestroyed(Block) (N2460):
	# GameStats.getPlaced(Block) + getDestroyed(Block)
	# (GameStats.java:30-36): each is a single
	# `map.get(block, 0)` on its own ObjectIntMap -- placed
	# reads placedBlockCount (:21), destroyed reads
	# destroyedBlockCount (:24). TRAP: the two maps are
	# independent -- a block present in one map only still
	# returns 0 from the other, and getDestroyed is never
	# derived from placed counts (no `placed - destroyed`,
	# no cross-map read). TRAP: a missing block returns 0
	# (the default of `get(block, 0)`), never KeyError or
	# null. The proof calls the pure functions with synthetic
	# stats dicts (no live tick, no game state); block keys
	# are String names, the data-driven equivalent of Java
	# Block identity for named content.

	var stats: Dictionary = {
		"placedBlockCount": {"copper-wall": 3, "titanium-wall": 5},
		"destroyedBlockCount": {"copper-wall": 2, "titanium-wall": 1},
	}

	# A missing block returns 0 from both maps (Java :31/:35,
	# the `0` default of `get(block, 0)`), and each result has
	# exactly 1 key.
	var missing_placed: Dictionary = game_stats_state.source_game_stats_get_placed_state(stats, "lead-wall")
	var missing_destroyed: Dictionary = game_stats_state.source_game_stats_get_destroyed_state(stats, "lead-wall")
	proof["missing_block_returns_zero"] = missing_placed.get("placed") == 0 and missing_placed.size() == 1 and missing_destroyed.get("destroyed") == 0 and missing_destroyed.size() == 1

	# Placed counts read back from the placed map.
	proof["placed_counts"] = game_stats_state.source_game_stats_get_placed_state(stats, "copper-wall").get("placed") == 3 and game_stats_state.source_game_stats_get_placed_state(stats, "titanium-wall").get("placed") == 5

	# Destroyed counts read back from the destroyed map.
	proof["destroyed_counts"] = game_stats_state.source_game_stats_get_destroyed_state(stats, "copper-wall").get("destroyed") == 2 and game_stats_state.source_game_stats_get_destroyed_state(stats, "titanium-wall").get("destroyed") == 1

	# TRAP: the two maps are independent -- the same block has
	# different counts in each map, and a block present only
	# in the placed map still returns 0 from getDestroyed.
	var placed_only: Dictionary = {
		"placedBlockCount": {"duo": 7},
		"destroyedBlockCount": {},
	}
	proof["independent_maps"] = game_stats_state.source_game_stats_get_placed_state(stats, "copper-wall").get("placed") == 3 and game_stats_state.source_game_stats_get_destroyed_state(stats, "copper-wall").get("destroyed") == 2 and game_stats_state.source_game_stats_get_placed_state(placed_only, "duo").get("placed") == 7 and game_stats_state.source_game_stats_get_destroyed_state(placed_only, "duo").get("destroyed") == 0

	# Repeat calls return the same value (pure lookup, no map
	# mutation).
	proof["idempotent_second_call"] = game_stats_state.source_game_stats_get_placed_state(stats, "copper-wall").get("placed") == game_stats_state.source_game_stats_get_placed_state(stats, "copper-wall").get("placed") and game_stats_state.source_game_stats_get_destroyed_state(stats, "copper-wall").get("destroyed") == game_stats_state.source_game_stats_get_destroyed_state(stats, "copper-wall").get("destroyed")

	# Empty stats return 0 from both maps.
	var empty: Dictionary = {}
	proof["empty_stats_zero"] = game_stats_state.source_game_stats_get_placed_state(empty, "copper-wall").get("placed") == 0 and game_stats_state.source_game_stats_get_destroyed_state(empty, "copper-wall").get("destroyed") == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07GameStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
