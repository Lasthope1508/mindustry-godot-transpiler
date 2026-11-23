extends Node

const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- GameState.hasSpawns() (N2448):
	# GameState.hasSpawns() (GameState.java:68-70). One method
	# slice (batch 41 slot 3): exactly the 1 body expr
	# `return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);`
	# (:69). Pure predicate: this map has a spawn point for a
	# wave when waves are on AND (the wave team still has a
	# core in attack mode OR there are spawn groups).
	# `rules.waveTeam.cores()` arrives as the frame input
	# wave_team_core_count (the count, not the cores() call --
	# Team.cores() is a later slice) and `rules.spawns` as
	# spawn_group_count. The proof calls the pure function
	# with synthetic frame inputs (no live tick, no game):
	# waves off -> false; waves + spawn groups -> true;
	# waves + attack mode + wave-team core -> true; waves +
	# neither -> false; exactly the payload key plus the
	# source_owner envelope key, and a second call on the
	# same inputs yields the same value.

	# Waves off -> false (even with cores and spawn groups).
	proof["has_spawns_false_when_waves_off"] = bool(game_loop_state.source_game_loop_has_spawns_state(false, 5, true, 3).get("has_spawns", true)) == false

	# Waves on + spawn groups -> true (no core, no attack mode).
	proof["has_spawns_true_when_spawn_groups"] = bool(game_loop_state.source_game_loop_has_spawns_state(true, 0, false, 2).get("has_spawns", false)) == true

	# Waves on + attack mode + wave-team core -> true (no spawn groups).
	proof["has_spawns_true_when_attack_mode_and_core"] = bool(game_loop_state.source_game_loop_has_spawns_state(true, 1, true, 0).get("has_spawns", false)) == true

	# Waves on + no spawn groups + no core -> false.
	proof["has_spawns_false_when_no_spawns_no_core"] = bool(game_loop_state.source_game_loop_has_spawns_state(true, 0, false, 0).get("has_spawns", true)) == false

	# Exactly the payload key plus the source_owner envelope key.
	var one_call: Dictionary = game_loop_state.source_game_loop_has_spawns_state(true, 1, true, 0)
	proof["has_spawns_returns_owner_plus_one_key"] = one_call.size() == 2 and one_call.has("has_spawns") and one_call.has("source_owner")

	# A second call on the same inputs yields the same value:
	# hasSpawns is a pure function of its inputs, with no
	# hidden state.
	var second: Dictionary = game_loop_state.source_game_loop_has_spawns_state(true, 1, true, 0)
	proof["has_spawns_idempotent_second_call"] = bool(second.get("has_spawns", false)) == true and second.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07GameLoopHasSpawnsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
