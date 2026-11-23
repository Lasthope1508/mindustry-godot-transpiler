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

	# --- Teams.updateTeamStats (N2383):
	# Teams.updateTeamStats() (Teams.java:181-251,
	# `present.clear();` / `bosses.clear();` /
	# `data.presentFlag = data.buildings.size > 0;` /
	# `data.units.clear();` / `data.players.clear();` /
	# `if(data.cores.size > 0){` /
	# `data.lastCore = data.cores.first();` /
	# `if(data.unitTree != null){` /
	# `data.unitTree.clear();` /
	# `if(data.unitsByType != null){` /
	# `for(int i = 0; i < data.unitsByType.length; i++){` /
	# `if(data.unitsByType[i] != null){` /
	# `data.unitsByType[i].clear();` /
	# `if(unit.type == null) continue;` /
	# `TeamData data = unit.team.data();` /
	# `data.presentFlag = true;` /
	# `if(unit.team == state.rules.waveTeam && unit.isBoss()){` /
	# `bosses.add(unit);` /
	# `if(data.unitsByType == null || data.unitsByType.length <= unit.type.id){` /
	# `data.unitsByType = new Seq[content.units().size];` /
	# `if(data.unitsByType[unit.type.id] == null){` /
	# `data.unitsByType[unit.type.id] = new Seq<>();` /
	# `data.unitsByType[unit.type.id].add(unit);` /
	# `count(unit);` /
	# `for(var player : Groups.player){` /
	# `player.team().data().players.add(player);` /
	# `if(data.presentFlag || data.active()){` /
	# `present.add(data);`).
	# The proof calls the pure function with synthetic
	# teams_state dicts (no live tick). Team ids:
	# derelict 0, sharded 1, crux 2, neoplastic 6
	# (Team.java:41); wave team is 2. Team 1 has stale
	# units/players/counts/tree/unitsByType to prove the
	# reset clears them; team 2 has a boss unit and a
	# null-type unit; team 3 has nothing (absent); team 4
	# has buildings but no units (present_flag from
	# buildings alone); team 6 has a unit but no buildings
	# (present_flag from units alone). Team 1 also has a
	# non-wave boss, which must NOT land in bosses. Team
	# 1's units_by_type starts at the content size (4, as
	# it is after the first rebuild) so the reset-clear is
	# what the proof checks -- a shorter array would make
	# the Java regrowth replace it wholesale on the first
	# higher type id (Teams.java:225-226).

	var dagger_1: Dictionary = {"team_id": 1, "type_id": 0, "type_name": "dagger", "is_boss": false, "payload_units": []}
	var payload_dagger: Dictionary = {"team_id": 1, "type_id": 0, "type_name": "dagger", "is_boss": false, "payload_units": []}
	var mace_1: Dictionary = {"team_id": 1, "type_id": 1, "type_name": "mace", "is_boss": false, "payload_units": [payload_dagger]}
	var fortress_1: Dictionary = {"team_id": 1, "type_id": 2, "type_name": "fortress", "is_boss": true, "payload_units": []}
	var boss_2: Dictionary = {"team_id": 2, "type_id": 0, "type_name": "dagger", "is_boss": true, "payload_units": []}
	var null_type_2: Dictionary = {"team_id": 2, "type_id": -1, "type_name": "", "is_boss": false, "payload_units": []}
	var fortress_6: Dictionary = {"team_id": 6, "type_id": 2, "type_name": "fortress", "is_boss": false, "payload_units": []}
	var state: Dictionary = {
		"teams": {
			1: {"cores": ["c1"], "buildings": ["b1"], "units": ["stale-unit"], "players": ["stale-player"], "last_core": "old-core", "unit_tree": {"inserted": ["stale-tree-unit"]}, "type_counts": [5, 5], "units_by_type": [["stale-u"], null, null, null], "core_enemies": []},
			2: {"cores": [], "buildings": [], "units": [], "players": [], "core_enemies": []},
			3: {"cores": [], "buildings": [], "units": [], "players": [], "core_enemies": []},
			4: {"cores": [], "buildings": ["b4"], "units": [], "players": [], "core_enemies": []},
			6: {"cores": [], "buildings": [], "units": ["stale-u6"], "players": [], "core_enemies": []},
		},
		"active": [1],
		"rules": {"wave_team": 2, "waves": true},
	}
	var units: Array = [dagger_1, mace_1, fortress_1, boss_2, null_type_2, fortress_6]
	var players: Array = [{"team_id": 1, "ref": "p1"}, {"team_id": 2, "ref": "p2"}]
	var present: Array = ["stale-present"]
	var bosses: Array = ["stale-boss"]
	var result: Dictionary = teams_state.source_teams_update_team_stats_state(state, units, players, 2, 4, present, bosses)
	var teams: Dictionary = (result.get("teams_state", {}) as Dictionary).get("teams", {})
	var team_1: Dictionary = teams.get(1, {})
	var team_2: Dictionary = teams.get(2, {})
	var team_3: Dictionary = teams.get(3, {})
	var team_4: Dictionary = teams.get(4, {})
	var team_6: Dictionary = teams.get(6, {})

	# The reset clears stale units/players: team 1 ends
	# with exactly its 3 live units and player p1.
	proof["reset_clears_stale_units_and_players"] = (team_1.get("units", []) as Array).size() == 3 and not (team_1.get("units", []) as Array).has("stale-unit") and team_1.get("players", []) == ["p1"]
	# presentFlag comes from buildings at reset: team 4
	# has buildings but no units, yet its flag is true.
	proof["reset_present_flag_from_buildings"] = bool(team_4.get("present_flag", false)) and int(team_4.get("unit_count", -1)) == 0
	# lastCore is the first core, not the stale value.
	proof["reset_last_core_first_core"] = team_1.get("last_core", "") == "c1"
	# The unit tree is cleared then rebuilt from live
	# inserts (3 for team 1); team 2 had no tree, so
	# tree() creates it lazily on the first insert.
	proof["reset_clears_unit_tree_then_inserts"] = ((team_1.get("unit_tree", {}) as Dictionary).get("inserted", []) as Array).size() == 3 and not ((team_1.get("unit_tree", {}) as Dictionary).get("inserted", []) as Array).has("stale-tree-unit") and ((team_2.get("unit_tree", {}) as Dictionary).get("inserted", []) as Array).size() == 1
	# typeCounts are zero-filled then recounted (the
	# stale [5, 5] is gone): dagger x2 (one top-level,
	# one payload), mace x1, fortress x1, grown to the
	# content unit size 4.
	proof["reset_zeroes_type_counts"] = team_1.get("type_counts", []) == [2, 1, 1, 0]
	# unitsByType entries are cleared: the stale entry
	# is gone, each type holds exactly its live units.
	proof["reset_clears_units_by_type_entries"] = (team_1.get("units_by_type", []) as Array)[0] == [dagger_1] and (team_1.get("units_by_type", []) as Array)[1] == [mace_1] and (team_1.get("units_by_type", []) as Array)[2] == [fortress_1] and (team_1.get("units_by_type", []) as Array)[3] == null
	# unitsByType grows to content.units().size on the
	# first unit of a team that had none.
	proof["units_by_type_grows_to_content_size"] = (team_2.get("units_by_type", []) as Array).size() == 4
	# A unit with type_id -1 (unit.type == null) is
	# skipped: team 2 counts exactly its one boss.
	proof["null_type_unit_skipped"] = int(team_2.get("unit_count", -1)) == 1 and (team_2.get("units", []) as Array).size() == 1
	# count(unit) recurses into payload units: team 1
	# counts 4 (3 top-level + 1 payload dagger), and the
	# name-keyed counts see dagger twice.
	proof["count_recurses_payload_units"] = int(team_1.get("unit_count", -1)) == 4 and int((result.get("unit_counts_by_team", {}) as Dictionary).get(1, {}).get("dagger", 0)) == 2
	# Only the wave-team boss lands in bosses.
	proof["wave_team_boss_in_bosses"] = (result.get("bosses", []) as Array).size() == 1 and ((result.get("bosses", []) as Array)[0] as Dictionary).get("team_id", -1) == 2 and bool(((result.get("bosses", []) as Array)[0] as Dictionary).get("is_boss", false))
	# The team-1 boss is not a wave-team boss.
	proof["non_wave_boss_not_in_bosses"] = not ((result.get("bosses", []) as Array)[0] as Dictionary).get("team_id", -1) == 1
	# Players group by team.
	proof["players_grouped_by_team"] = team_1.get("players", []) == ["p1"] and team_2.get("players", []) == ["p2"]
	# present is rebuilt from presentFlag || active() in
	# teams_state key order -- and the passed-in present
	# Array is the one mutated in place (the stale entry
	# is gone). Team 4 is present via active() (it has
	# buildings); team 6 via its unit.
	proof["present_includes_present_teams"] = result.get("present", []) == [1, 2, 4, 6] and present == [1, 2, 4, 6]
	# Team 3 has no buildings, no cores, no units, and
	# is not the wave team: absent.
	proof["present_excludes_absent_team"] = not (result.get("present", []) as Array).has(3) and not bool(team_3.get("present_flag", true))
	# presentFlag is set by seeing a unit even with no
	# buildings (team 6).
	proof["present_flag_set_by_units"] = bool(team_6.get("present_flag", false)) and int(team_6.get("unit_count", -1)) == 1 and team_6.get("type_counts", []) == [0, 0, 1, 0]
	# The function returns only its four keys, in the
	# pinned order teams_state, present, bosses,
	# unit_counts_by_team.
	proof["returns_only_four_keys"] = result.keys().size() == 4 and result.keys()[0] == "teams_state" and result.keys()[1] == "present" and result.keys()[2] == "bosses" and result.keys()[3] == "unit_counts_by_team"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsUpdateTeamStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
