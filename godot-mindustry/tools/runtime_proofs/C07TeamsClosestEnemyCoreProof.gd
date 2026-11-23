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

	# --- Closest enemy core (N2354): Teams.closestEnemyCore() scans the
	# calling team's coreEnemies and each enemy team's cores, keeping the
	# core with the smallest squared distance (`@Nullable` /
	# `public CoreBuild closestEnemyCore(float x, float y, Team team){` /
	# `CoreBuild closest = null;` /
	# `float closestDst = Float.MAX_VALUE;` /
	# `for(Team enemy : team.data().coreEnemies){` /
	# `for(CoreBuild core : enemy.cores()){` /
	# `float dst = Mathf.dst2(x, y, core.getX(), core.getY());` /
	# `if(closestDst > dst){` / `closest = core;` / `closestDst = dst;` /
	# `return closest;`, Teams.java:39-55). Mathf.dst2 is the SQUARED
	# distance (arc Mathf.java:656-659). A strict `>` keeps the FIRST core
	# on a tie. No enemy core means null with closest_dst2 at
	# Float.MAX_VALUE. coreEnemies is read from teams_state (kept there by
	# updateEnemies, Teams.java:252-268, NOT ported here); the enemy cores
	# arrive as explicit {"team_id", "ref", "x", "y"} records because the
	# cores stored in teams_state are opaque refs with no position. The
	# proof calls the pure function with synthetic teams_state dicts (no
	# live tick, no updateEnemies).

	# Team 1 (sharded) has enemy team 2 (crux) with two cores; the nearer
	# one wins. Query from (0, 0): core "far" at (30, 40) is dst2 2500,
	# core "near" at (3, 4) is dst2 25.
	var state: Dictionary = {"teams": {1: {"cores": [], "buildings": [], "units": [], "core_enemies": [2]}, 2: {"cores": ["far", "near"], "buildings": [], "units": [], "core_enemies": [1]}}, "active": [1, 2], "rules": {"wave_team": 2, "waves": true}}
	var cores: Array = [{"team_id": 2, "ref": "far", "x": 30.0, "y": 40.0}, {"team_id": 2, "ref": "near", "x": 3.0, "y": 4.0}]
	var found: Dictionary = teams_state.source_teams_closest_enemy_core_state(state, 0.0, 0.0, 1, cores)
	proof["closest_found"] = String(found.get("closest_core", "")) == "near"

	# A tie keeps the FIRST core: two enemy cores at the same squared
	# distance (3, 4) and (-3, -4) both give dst2 25.
	var tied: Array = [{"team_id": 2, "ref": "first", "x": 3.0, "y": 4.0}, {"team_id": 2, "ref": "second", "x": -3.0, "y": -4.0}]
	var tied_found: Dictionary = teams_state.source_teams_closest_enemy_core_state(state, 0.0, 0.0, 1, tied)
	proof["closest_tie_first"] = String(tied_found.get("closest_core", "")) == "first"

	# No enemy cores at all: null with closest_dst2 at Float.MAX_VALUE.
	var none_found: Dictionary = teams_state.source_teams_closest_enemy_core_state(state, 0.0, 0.0, 1, [])
	proof["no_enemy_cores_null"] = none_found.get("closest_core", "not-null") == null and is_equal_approx(float(none_found.get("closest_dst2", -1.0)), 3.4028235e38)

	# A nearer core of a NON-enemy team is ignored: team 6 is not in
	# team 1's core_enemies, so its core at (1, 0) must not win over the
	# enemy core at (3, 4).
	var mixed: Array = [{"team_id": 6, "ref": "outsider", "x": 1.0, "y": 0.0}, {"team_id": 2, "ref": "near", "x": 3.0, "y": 4.0}]
	var mixed_found: Dictionary = teams_state.source_teams_closest_enemy_core_state(state, 0.0, 0.0, 1, mixed)
	proof["non_enemy_ignored"] = String(mixed_found.get("closest_core", "")) == "near"

	# closest_dst2 is the SQUARED distance: (3, 4) from (0, 0) is 25.
	proof["dst2_squared"] = is_equal_approx(float(found.get("closest_dst2", -1.0)), 25.0)

	# An empty teams_state gives null without crashing.
	var empty_found: Dictionary = teams_state.source_teams_closest_enemy_core_state({}, 0.0, 0.0, 1, cores)
	proof["empty_teams_state"] = empty_found.get("closest_core", "not-null") == null

	# The call mutates neither the teams_state nor the enemy-core records.
	proof["input_unmutated"] = int(state["teams"][1]["core_enemies"].size()) == 1 and int(state["teams"][1]["core_enemies"][0]) == 2 and String(cores[0].get("ref", "")) == "far" and is_equal_approx(float(cores[0].get("x", -1.0)), 30.0) and String(cores[1].get("ref", "")) == "near"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsClosestEnemyCoreProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
