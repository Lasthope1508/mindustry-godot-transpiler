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

	# --- Update enemies (N2357): Teams.updateEnemies() adds the wave
	# team to active when waves are enabled and it is not active yet
	# (`private void updateEnemies(){` /
	# `if(state.rules.waves && !active.contains(get(state.rules.waveTeam))){` /
	# `active.add(get(state.rules.waveTeam));`), then rewrites every
	# active team's coreEnemies to the other active teams
	# (`for(TeamData data : active){` /
	# `Seq<Team> enemies = new Seq<>();` /
	# `for(TeamData other : active){` /
	# `if(data.team != other.team){` / `enemies.add(other.team);` /
	# `data.coreEnemies = enemies.toArray(Team.class);`,
	# Teams.java:252-268). state.rules.waves / state.rules.waveTeam
	# are Rules state (not ported), so they arrive as explicit params
	# (waves_enabled, wave_team_id); teams are compared by team_id.
	# The function is pure: it deep-copies the teams_state, sets the
	# copy's rules from the params, applies the shared
	# _teams_update_enemies helper to the copy, and returns the
	# updated copy plus wave_team_added -- the caller's dict is never
	# mutated. The proof calls the pure function with synthetic
	# teams_state dicts (no live tick).

	# Team 1 (sharded) is active with a STALE core_enemies [6]; team 2
	# (crux, the wave team) is not active yet. Waves on, wave team 2:
	# the wave team is added and both teams' core_enemies are rewritten
	# to each other.
	var state: Dictionary = {"teams": {1: {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": [6]}, 2: {"cores": ["c2"], "buildings": [], "units": [], "core_enemies": []}}, "active": [1], "rules": {"wave_team": 2, "waves": true}}
	var added: Dictionary = teams_state.source_teams_update_enemies_state(state, true, 2)
	proof["wave_team_added"] = bool(added.get("wave_team_added", false))
	var added_state: Dictionary = added.get("teams_state", {})
	proof["core_enemies_updated"] = int(added_state.get("active", []).size()) == 2 and int(added_state.get("active", [])[1]) == 2 and Array(added_state["teams"][1].get("core_enemies", [])).size() == 1 and int(added_state["teams"][1]["core_enemies"][0]) == 2 and Array(added_state["teams"][2].get("core_enemies", [])).size() == 1 and int(added_state["teams"][2]["core_enemies"][0]) == 1
	proof["enemies_exclude_self"] = not Array(added_state["teams"][1].get("core_enemies", [])).has(1) and not Array(added_state["teams"][2].get("core_enemies", [])).has(2)

	# The wave team is already active: no add, core_enemies still
	# recomputed.
	var already: Dictionary = {"teams": {1: {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": []}, 2: {"cores": ["c2"], "buildings": [], "units": [], "core_enemies": []}}, "active": [1, 2], "rules": {"wave_team": 2, "waves": true}}
	var already_result: Dictionary = teams_state.source_teams_update_enemies_state(already, true, 2)
	proof["wave_team_already_active"] = not bool(already_result.get("wave_team_added", true)) and int(Dictionary(already_result.get("teams_state", {})).get("active", []).size()) == 2

	# Waves off: the wave team is NOT added, and the single active
	# team ends up with no enemies (only itself is active).
	var no_waves: Dictionary = {"teams": {1: {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": [2]}, 2: {"cores": ["c2"], "buildings": [], "units": [], "core_enemies": []}}, "active": [1], "rules": {"wave_team": 2, "waves": false}}
	var no_waves_result: Dictionary = teams_state.source_teams_update_enemies_state(no_waves, false, 2)
	var no_waves_state: Dictionary = no_waves_result.get("teams_state", {})
	proof["waves_disabled_no_add"] = not bool(no_waves_result.get("wave_team_added", true)) and int(no_waves_state.get("active", []).size()) == 1 and Array(no_waves_state["teams"][1].get("core_enemies", [])).is_empty()

	# An empty active list is a no-op without crashing.
	var empty_result: Dictionary = teams_state.source_teams_update_enemies_state({"teams": {}, "active": [], "rules": {"wave_team": -1, "waves": false}}, false, -1)
	proof["empty_active"] = not bool(empty_result.get("wave_team_added", true)) and Array(Dictionary(empty_result.get("teams_state", {})).get("active", [])).is_empty()

	# The call mutates neither the caller's active list nor its
	# teams' core_enemies (the stale [6] is still there).
	proof["input_unmutated"] = int(state.get("active", []).size()) == 1 and int(state.get("active", [])[0]) == 1 and Array(state["teams"][1].get("core_enemies", [])).size() == 1 and int(state["teams"][1]["core_enemies"][0]) == 6

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsUpdateEnemiesProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
