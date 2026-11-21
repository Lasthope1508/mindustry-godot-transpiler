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

	# --- Teams lookup group (N2380):
	# Teams.get()+getOrNull()+playerCores()+cores()+isActive()+
	# canInteract()+getActive() (Teams.java:97-133,
	# `public TeamData get(Team team){` /
	# `var data = map[team.id];` /
	# `if(data != null){` /
	# `return data;` /
	# `return map[team.id] = new TeamData(team);` /
	# `public @Nullable TeamData getOrNull(Team team){` /
	# `return map[team.id];` /
	# `public Seq<CoreBuild> playerCores(){` /
	# `return get(state.rules.defaultTeam).cores;` /
	# `public Seq<CoreBuild> cores(Team team){` /
	# `return get(team).cores;` /
	# `public boolean isActive(Team team){` /
	# `return get(team).active();` /
	# `public boolean canInteract(Team team, Team other){` /
	# `return team == other || other == Team.derelict;` /
	# `public Seq<TeamData> getActive(){` /
	# `active.removeAll(t -> !t.active());` /
	# `return active;`).
	# One grouped slice (main-thread decision 2026-11-21, the
	# N2374 five-accessor / N2330 three-method group
	# precedent): seven one-to-three-line lookup methods
	# sharing the one lookup core (`map[team.id]` +
	# `get(team)`). Team ids: derelict 0, sharded 1, crux 2,
	# neoplastic 6 (Team.java:41). The proof calls the seven
	# pure functions with synthetic teams_state dicts (no live
	# tick); each mutating call gets its own fresh dict, since
	# get() creates missing entries and getActive() prunes
	# the active list in place.

	# get() on a missing team creates the empty TeamData dict
	# and stores it; get() on an existing team returns that
	# entry without creating.
	var state_missing: Dictionary = {"teams": {1: {"cores": ["c1", "c2"], "buildings": [], "units": [], "core_enemies": []}}, "active": [1], "rules": {"wave_team": 2, "waves": true}}
	var got_missing: Dictionary = teams_state.source_teams_get_state(state_missing, 3)
	proof["get_creates_missing_team_data"] = bool(got_missing.get("created", false)) and (got_missing.get("team_data", {}) as Dictionary).get("cores", ["not-empty"]).is_empty() and (got_missing.get("teams_state", {}) as Dictionary).get("teams", {}).has(3)
	var got_existing: Dictionary = teams_state.source_teams_get_state(state_missing, 1)
	proof["get_returns_existing_team_data"] = not bool(got_existing.get("created", true)) and (got_existing.get("team_data", {}) as Dictionary).get("cores", []) == ["c1", "c2"]

	# getOrNull() returns the existing entry, null when
	# missing, and never creates the missing entry.
	var state_or_null: Dictionary = {"teams": {1: {"cores": ["c1", "c2"], "buildings": [], "units": [], "core_enemies": []}}, "active": [1], "rules": {"wave_team": 2, "waves": true}}
	var or_null_existing: Dictionary = teams_state.source_teams_get_or_null_state(state_or_null, 1)
	proof["get_or_null_returns_existing"] = (or_null_existing.get("team_data", {}) as Dictionary).get("cores", []) == ["c1", "c2"]
	var or_null_missing: Dictionary = teams_state.source_teams_get_or_null_state(state_or_null, 99)
	proof["get_or_null_null_when_missing"] = or_null_missing.get("team_data", "not-null") == null
	proof["get_or_null_does_not_create_entry"] = not (state_or_null.get("teams", {}) as Dictionary).has(99)

	# playerCores() is get(state.rules.defaultTeam).cores;
	# cores() is get(team).cores.
	var state_cores: Dictionary = {"teams": {1: {"cores": ["c1", "c2"], "buildings": [], "units": [], "core_enemies": []}}, "active": [1], "rules": {"wave_team": 2, "waves": true}}
	var player_cores: Dictionary = teams_state.source_teams_player_cores_state(state_cores, 1)
	proof["player_cores_default_team_cores"] = player_cores.get("cores", []) == ["c1", "c2"]
	var team_cores: Dictionary = teams_state.source_teams_cores_state(state_cores, 1)
	proof["cores_returns_team_cores"] = team_cores.get("cores", []) == ["c1", "c2"]

	# isActive() is get(team).active(): true with cores, false
	# when empty (and not the wave team), true for the wave
	# team even with no cores (the comment at Teams.java:121).
	var state_active: Dictionary = {"teams": {1: {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": []}, 2: {"cores": [], "buildings": [], "units": [], "core_enemies": []}}, "active": [1, 2], "rules": {"wave_team": 2, "waves": true}}
	var active_with_cores: Dictionary = teams_state.source_teams_is_active_state(state_active, 1)
	proof["is_active_true_with_cores"] = bool(active_with_cores.get("is_active", false))
	var active_empty: Dictionary = teams_state.source_teams_is_active_state(state_active, 3)
	proof["is_active_false_when_empty"] = not bool(active_empty.get("is_active", true))
	var active_wave: Dictionary = teams_state.source_teams_is_active_state(state_active, 2)
	proof["is_active_true_for_wave_team"] = bool(active_wave.get("is_active", false))

	# canInteract() is `team == other || other == derelict`:
	# true for the same team, true when the other team is
	# derelict (id 0), false for two different non-derelict
	# teams.
	var interact_same: Dictionary = teams_state.source_teams_can_interact_state(1, 1, 0)
	proof["can_interact_same_team"] = bool(interact_same.get("can_interact", false))
	var interact_derelict: Dictionary = teams_state.source_teams_can_interact_state(1, 0, 0)
	proof["can_interact_derelict_other"] = bool(interact_derelict.get("can_interact", false))
	var interact_other: Dictionary = teams_state.source_teams_can_interact_state(1, 2, 0)
	proof["can_interact_false_for_other_teams"] = not bool(interact_other.get("can_interact", true))

	# getActive() prunes inactive teams from active in place:
	# team 1 stays (has cores), team 3 goes (no entry at all,
	# so inactive), team 6 goes (neoplastic with no units).
	# The wave team stays even with no cores.
	var state_prune: Dictionary = {"teams": {1: {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": []}, 6: {"cores": [], "buildings": [], "units": [], "core_enemies": []}}, "active": [1, 3, 6], "rules": {"wave_team": 2, "waves": true}}
	var pruned: Dictionary = teams_state.source_teams_get_active_state(state_prune)
	proof["get_active_removes_inactive_teams"] = pruned.get("active", []) == [1] and (pruned.get("teams_state", {}) as Dictionary).get("active", []) == [1]
	var state_wave: Dictionary = {"teams": {2: {"cores": [], "buildings": [], "units": [], "core_enemies": []}}, "active": [2], "rules": {"wave_team": 2, "waves": true}}
	var wave_kept: Dictionary = teams_state.source_teams_get_active_state(state_wave)
	proof["get_active_keeps_wave_team"] = wave_kept.get("active", []) == [2]

	# get() returns only its three keys, in the pinned order
	# team_data, created, teams_state.
	proof["get_returns_only_three_keys"] = got_existing.keys().size() == 3 and got_existing.keys()[0] == "team_data" and got_existing.keys()[1] == "created" and got_existing.keys()[2] == "teams_state"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsLookupProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
