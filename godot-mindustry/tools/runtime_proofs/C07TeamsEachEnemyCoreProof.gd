extends Node

const main_scene := preload("res://scenes/Main.tscn")
const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
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

	# --- Each enemy core (N2365):
	# Teams.eachEnemyCore() scans the active teams, skipping the
	# calling team, and hands each enemy team's cores to the
	# callback (`public void eachEnemyCore(Team team,
	# Cons<Building> ret){` / `for(TeamData data : active){` /
	# `if(team != data.team){` / `for(Building tile : data.cores){`
	# / `ret.get(tile);`, Teams.java:86-94). GDScript has no Java
	# Cons, so the port returns the enemy cores as data
	# (main-thread decision 2026-11-21): each core is
	# [team_id, x, y] and the caller iterates them instead of a
	# callback. The payload is the "cores" Array inside the
	# family-convention Dictionary envelope (the SSOT validator
	# accepts only return_type Dictionary or void). Unlike N2361 (anyEnemyCoresWithin),
	# there is no protectCores condition and no radius -- every
	# enemy team's cores are collected, in active-team order then
	# enemy_cores order. The cores stored in teams_state are opaque
	# refs with no position, so the enemy cores arrive as explicit
	# {"team_id", "x", "y"} records. The proof calls the pure
	# function with synthetic teams_state dicts (no live tick, no
	# Cons callback).

	# Team 1 (sharded) has enemy teams 2 (crux) with two cores and
	# 6 (neoplastic) with one core; team 1's own core must not
	# appear in the result.
	var state: Dictionary = {"teams": {1: {"cores": ["own"], "buildings": [], "units": [], "core_enemies": [2, 6]}, 2: {"cores": ["a", "b"], "buildings": [], "units": [], "core_enemies": [1]}, 6: {"cores": ["c"], "buildings": [], "units": [1], "core_enemies": [1]}}, "active": [1, 2, 6], "rules": {"wave_team": 2, "waves": true}}
	var cores: Array = [{"team_id": 1, "x": 1.0, "y": 0.0}, {"team_id": 2, "x": 30.0, "y": 40.0}, {"team_id": 2, "x": 3.0, "y": 4.0}, {"team_id": 6, "x": 500.0, "y": 600.0}]
	var result: Dictionary = teams_state.source_teams_each_enemy_core_state(state, 1, cores)
	var found: Array = result.get("cores", [])
	proof["enemy_cores_collected"] = found.size() == 3 and found[0][0] == 2 and is_equal_approx(float(found[0][1]), 30.0) and is_equal_approx(float(found[0][2]), 40.0) and found[1][0] == 2 and is_equal_approx(float(found[1][1]), 3.0) and is_equal_approx(float(found[1][2]), 4.0) and found[2][0] == 6 and is_equal_approx(float(found[2][1]), 500.0) and is_equal_approx(float(found[2][2]), 600.0)

	# No entry in the result has the calling team's id, even
	# though team 1's core sits in the input records.
	var same_team_seen := false
	for entry in found:
		if int(entry[0]) == 1:
			same_team_seen = true
	proof["same_team_excluded"] = not same_team_seen

	# Order follows the active list, then the enemy_cores order:
	# team 2's cores come before team 6's, and team 2's (30, 40)
	# core comes before its (3, 4) core.
	proof["order_active_then_cores"] = found.size() == 3 and int(found[0][0]) == 2 and int(found[1][0]) == 2 and int(found[2][0]) == 6 and is_equal_approx(float(found[0][1]), 30.0) and is_equal_approx(float(found[1][1]), 3.0)

	# No enemy cores at all: only the calling team's records are
	# given, so the result is an empty Array.
	var own_only: Array = [{"team_id": 1, "x": 1.0, "y": 0.0}]
	var none_result: Dictionary = teams_state.source_teams_each_enemy_core_state(state, 1, own_only)
	var none_found: Array = none_result.get("cores", [-1])
	proof["no_enemy_cores_empty"] = none_found.is_empty()

	# An empty teams_state returns an empty Array without crashing.
	var empty_result: Dictionary = teams_state.source_teams_each_enemy_core_state({}, 1, cores)
	var empty_found: Array = empty_result.get("cores", [-1])
	proof["empty_teams_state"] = empty_found.is_empty()

	# The call mutates neither the teams_state nor the enemy-core
	# records.
	proof["input_unmutated"] = int(state["teams"][1]["core_enemies"].size()) == 2 and int(state["teams"][1]["core_enemies"][0]) == 2 and int(state["teams"][1]["core_enemies"][1]) == 6 and int(state["active"].size()) == 3 and is_equal_approx(float(cores[0].get("x", -1.0)), 1.0) and is_equal_approx(float(cores[1].get("y", -1.0)), 40.0) and is_equal_approx(float(cores[3].get("x", -1.0)), 500.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsEachEnemyCoreProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
