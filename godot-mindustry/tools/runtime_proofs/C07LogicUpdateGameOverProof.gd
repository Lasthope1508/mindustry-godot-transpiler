extends Node

const main_scene := preload("res://scenes/Main.tscn")
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

	# --- Logic.updateGameOver() :429 + Logic.gameOver() :436 (N2443):
	# Logic.updateGameOver() (Logic.java:426-431) and
	# Logic.gameOver() (Logic.java:434-439) share the one
	# body expr `state.won = player.team() == winner;`
	# (:429 and :436) -- a twin slice (batch 39 slot 3).
	# The game-over func records won as data: the player
	# team compared against the winner team. The proof
	# calls the PortGame wrapper with synthetic inputs
	# (no live tick, no event bus): same team wins,
	# another team loses, the envelope gains exactly the
	# two new keys, the winner key is untouched, and a
	# second call is idempotent.

	# Same team as the winner wins; the envelope has
	# exactly the 11 old keys plus won_expr and won.
	var result: Dictionary = game.source_game_over_core_destroyed_state(100.0, false, false, "sharded", "sharded")
	proof["won_same_team_true"] = result.get("won", false) == true
	proof["won_returns_thirteen_keys"] = result.size() == 13
	proof["won_expr_exact"] = result.get("won_expr", "") == "state.won = player.team() == winner;"

	# Another team loses, even with a healthy core and
	# no game over yet.
	var lost: Dictionary = game.source_game_over_core_destroyed_state(100.0, false, false, "sharded", "crux")
	proof["won_other_team_false"] = lost.get("won", true) == false

	# The winner key is untouched by the new keys: a
	# destroyed core still reports waveTeam as winner,
	# and a living core still reports no winner.
	var destroyed: Dictionary = game.source_game_over_core_destroyed_state(0.0, false, false, "sharded", "waveTeam")
	proof["won_preserves_winner"] = result.get("winner", "x") == "" and destroyed.get("winner", "") == "waveTeam" and destroyed.get("won", true) == false

	# A second call on the same inputs yields the same
	# 13 values: the func is pure, with no hidden state.
	var second: Dictionary = game.source_game_over_core_destroyed_state(100.0, false, false, "sharded", "sharded")
	proof["won_idempotent_second_call"] = second.get("won", false) == true and second.get("winner", "x") == "" and second.size() == 13 and second.get("won_expr", "") == "state.won = player.team() == winner;"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LogicUpdateGameOverProof", proof)
