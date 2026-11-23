extends Node

const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Logic.checkCampaignStats() (Logic.java:251-253):
	# `return state.isCampaign() && !net.client();` —
	# whether campaign stats should be recorded (a campaign
	# game, not a net client). Pure predicate over the frame
	# inputs; `state.isCampaign()` and `net.client()` are
	# read as-is and never resolved here (their live reads
	# are later slices).

	# Campaign game, not a client -> stats are recorded.
	proof["campaign_stats_campaign_not_client"] = bool(game_loop_state.source_game_loop_check_campaign_stats_state(true, false).get("campaign_stats", false)) == true

	# Not a campaign game -> no stats even when not a
	# client (the `state.isCampaign()` conjunct).
	proof["campaign_stats_not_campaign"] = bool(game_loop_state.source_game_loop_check_campaign_stats_state(false, false).get("campaign_stats", true)) == false

	# A net client -> no stats even in a campaign game
	# (the `!net.client()` conjunct).
	proof["campaign_stats_client"] = bool(game_loop_state.source_game_loop_check_campaign_stats_state(true, true).get("campaign_stats", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LogicCheckCampaignStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
