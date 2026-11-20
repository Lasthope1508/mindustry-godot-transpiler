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

	# --- Any enemy core within build radius (N2359):
	# Teams.anyEnemyCoresWithinBuildRadius() scans the active teams,
	# skipping the calling team and teams whose rules do not protect
	# cores (`public boolean anyEnemyCoresWithinBuildRadius(Team team,
	# float x, float y){` / `for(TeamData data : active){` /
	# `if(team != data.team && data.team.rules().protectCores){` /
	# `for(CoreBuild tile : data.cores){` /
	# `if(tile.within(x, y, state.rules.buildRadius(tile.team) + tilesize)){` /
	# `return true;` / `return false;`, Teams.java:60-72).
	# `tile.within(x, y, radius)` is arc Position.within
	# (Position.java:44-46): `Mathf.dst2(getX(), getY(), x, y) <
	# dst*dst` -- a STRICT < on the squared distance, so a core
	# exactly on the radius boundary is OUTSIDE. protectCores and
	# buildRadius are Rules state (not ported), so they arrive as
	# explicit per-team lookups; the enemy cores arrive as explicit
	# {"team_id", "x", "y"} records because the cores stored in
	# teams_state are opaque refs with no position. The proof calls
	# the pure function with synthetic teams_state dicts (no live
	# tick, no Rules).

	# Team 1 (sharded) has enemy team 2 (crux) with two cores; the
	# nearer one is well inside team 2's build radius (100) +
	# tilesize (8) = 108 from the query point (0, 0): core "near"
	# at (3, 4) is dst2 25 < 108*108.
	var state: Dictionary = {"teams": {1: {"cores": [], "buildings": [], "units": [], "core_enemies": [2]}, 2: {"cores": ["far", "near"], "buildings": [], "units": [], "core_enemies": [1]}}, "active": [1, 2], "rules": {"wave_team": 2, "waves": true}}
	var protect: Dictionary = {1: true, 2: true}
	var build_radius: Dictionary = {2: 100.0}
	var cores: Array = [{"team_id": 2, "x": 30.0, "y": 40.0}, {"team_id": 2, "x": 3.0, "y": 4.0}]
	var found: Dictionary = teams_state.source_teams_any_enemy_cores_within_build_radius_state(state, 1, 0.0, 0.0, protect, build_radius, 8.0, cores)
	proof["enemy_core_in_radius"] = bool(found.get("within", false))

	# No enemy core near the query point: from (1000, 1000) both
	# enemy cores are far outside radius 108.
	var far_found: Dictionary = teams_state.source_teams_any_enemy_cores_within_build_radius_state(state, 1, 1000.0, 1000.0, protect, build_radius, 8.0, cores)
	proof["no_enemy_core_outside"] = not bool(far_found.get("within", true))

	# A core of the CALLING team is ignored even when it sits on the
	# query point: team 1's core at (1, 0) is dst2 1 from (0, 0) but
	# team 1 == the calling team, and the only enemy core is far away.
	var own_cores: Array = [{"team_id": 1, "x": 1.0, "y": 0.0}, {"team_id": 2, "x": 500.0, "y": 0.0}]
	var own_found: Dictionary = teams_state.source_teams_any_enemy_cores_within_build_radius_state(state, 1, 0.0, 0.0, protect, build_radius, 8.0, own_cores)
	proof["same_team_ignored"] = not bool(own_found.get("within", true))

	# A core of an UNPROTECTED enemy team is ignored: team 2 does not
	# protect its cores, so its core at (3, 4) must not count.
	var unprotected: Dictionary = {1: true, 2: false}
	var unprotected_found: Dictionary = teams_state.source_teams_any_enemy_cores_within_build_radius_state(state, 1, 0.0, 0.0, unprotected, build_radius, 8.0, cores)
	proof["unprotected_team_ignored"] = not bool(unprotected_found.get("within", true))

	# A core exactly ON the radius boundary is OUTSIDE: radius is
	# 100 + 8 = 108, and a core at (108, 0) from (0, 0) has dst2
	# 11664 == 108*108, which fails the strict < in Position.within.
	var boundary_cores: Array = [{"team_id": 2, "x": 108.0, "y": 0.0}]
	var boundary_found: Dictionary = teams_state.source_teams_any_enemy_cores_within_build_radius_state(state, 1, 0.0, 0.0, protect, build_radius, 8.0, boundary_cores)
	proof["boundary_is_outside"] = not bool(boundary_found.get("within", true))

	# An empty teams_state returns false without crashing.
	var empty_found: Dictionary = teams_state.source_teams_any_enemy_cores_within_build_radius_state({}, 1, 0.0, 0.0, {}, {}, 8.0, cores)
	proof["empty_teams_state"] = not bool(empty_found.get("within", true))

	# The call mutates neither the teams_state nor the enemy-core
	# records nor the lookup dicts.
	proof["input_unmutated"] = int(state["teams"][1]["core_enemies"].size()) == 1 and int(state["teams"][1]["core_enemies"][0]) == 2 and int(state["active"].size()) == 2 and bool(protect.get(2, false)) and is_equal_approx(float(build_radius.get(2, -1.0)), 100.0) and is_equal_approx(float(cores[0].get("x", -1.0)), 30.0) and is_equal_approx(float(cores[1].get("y", -1.0)), 4.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsAnyEnemyCoresWithinBuildRadiusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
