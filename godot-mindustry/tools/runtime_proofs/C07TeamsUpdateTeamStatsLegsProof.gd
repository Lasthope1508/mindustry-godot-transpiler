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

	# --- Teams.updateTeamStats leftover legs (N2430):
	# the 2 exprs N2383 did not register --
	# `TeamData data = team.data();` (Teams.java:186 +
	# :244, the per-team lookup, registered ONCE despite
	# the two positions) and
	# `data.tree().insert(unit);` (:217, the unit-tree
	# insert). The GD function already exists (N2383);
	# the proof calls it with synthetic teams_state
	# dicts (no live tick) and drives one key per leg.
	# `TeamData data = unit.team.data();` (:215, variable
	# `unit.team`) is NOT `TeamData data = team.data();`
	# (:186/:244, variable `team`) -- the two are
	# registered separately. The lookup reads each team's
	# own dict from teams_state["teams"] and creates a
	# missing entry via `_teams_data`, exactly as Java
	# `team.data()` creates it; the tree insert appends
	# the unit to its team's unit_tree {"inserted": [...]}
	# list, created lazily when the team had none
	# (Teams.java:437-439) and cleared first by the
	# reset. Team ids: derelict 0, sharded 1, crux 2,
	# neoplastic 6 (Team.java:41); wave team is 2. Team
	# 1 has stale units/players/tree to prove the reset
	# clears them; team 2 has a boss unit and a null-type
	# unit and no tree; team 3 has nothing (absent); team
	# 4 has buildings but no units (present_flag from
	# buildings alone); team 5 is NOT in teams_state at
	# all -- its unit must create it via the lookup; team
	# 6 has a unit but no buildings (present_flag from
	# units alone).

	var dagger_1: Dictionary = {"team_id": 1, "type_id": 0, "type_name": "dagger", "is_boss": false, "payload_units": []}
	var mace_1: Dictionary = {"team_id": 1, "type_id": 1, "type_name": "mace", "is_boss": false, "payload_units": []}
	var fortress_1: Dictionary = {"team_id": 1, "type_id": 2, "type_name": "fortress", "is_boss": false, "payload_units": []}
	var boss_2: Dictionary = {"team_id": 2, "type_id": 0, "type_name": "dagger", "is_boss": true, "payload_units": []}
	var null_type_2: Dictionary = {"team_id": 2, "type_id": -1, "type_name": "", "is_boss": false, "payload_units": []}
	var fortress_6: Dictionary = {"team_id": 6, "type_id": 2, "type_name": "fortress", "is_boss": false, "payload_units": []}
	var dagger_5: Dictionary = {"team_id": 5, "type_id": 0, "type_name": "dagger", "is_boss": false, "payload_units": []}
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
	var units: Array = [dagger_1, mace_1, fortress_1, boss_2, null_type_2, fortress_6, dagger_5]
	var players: Array = [{"team_id": 1, "ref": "p1"}, {"team_id": 2, "ref": "p2"}]
	var present: Array = ["stale-present"]
	var bosses: Array = ["stale-boss"]
	var result: Dictionary = teams_state.source_teams_update_team_stats_state(state, units, players, 2, 4, present, bosses)
	var teams: Dictionary = (result.get("teams_state", {}) as Dictionary).get("teams", {})
	var team_1: Dictionary = teams.get(1, {})
	var team_2: Dictionary = teams.get(2, {})
	var team_3: Dictionary = teams.get(3, {})
	var team_4: Dictionary = teams.get(4, {})
	var team_5: Dictionary = teams.get(5, {})
	var team_6: Dictionary = teams.get(6, {})

	# The reset loop's `TeamData data = team.data();`
	# (:186) returns each team's own dict: team 1 ends
	# with exactly its 3 live units and player p1, its
	# present_flag from its buildings.
	proof["team_data_lookup_resets_each_team"] = (team_1.get("units", []) as Array).size() == 3 and not (team_1.get("units", []) as Array).has("stale-unit") and team_1.get("players", []) == ["p1"] and bool(team_1.get("present_flag", false))
	# A unit of a team with no entry creates it via the
	# lookup: team 5 appears with its unit counted and
	# its present_flag set by the unit.
	proof["team_data_lookup_creates_missing_team"] = teams.has(5) and (team_5.get("units", []) as Array) == [dagger_5] and int(team_5.get("unit_count", -1)) == 1 and bool(team_5.get("present_flag", false))
	# The `data.tree().insert(unit);` (:217) appends
	# each unit to its own team's tree insert list.
	proof["tree_insert_appends_unit"] = ((team_1.get("unit_tree", {}) as Dictionary).get("inserted", []) as Array) == [dagger_1, mace_1, fortress_1] and ((team_6.get("unit_tree", {}) as Dictionary).get("inserted", []) as Array) == [fortress_6]
	# tree() creates the tree lazily when the team had
	# none: team 2 had no unit_tree, yet its boss unit
	# is inserted.
	proof["tree_insert_creates_tree_when_absent"] = ((team_2.get("unit_tree", {}) as Dictionary).get("inserted", []) as Array) == [boss_2]
	# The reset clears the old inserts first: team 1's
	# stale tree unit is gone after the rebuild.
	proof["tree_insert_clears_stale_first"] = not ((team_1.get("unit_tree", {}) as Dictionary).get("inserted", []) as Array).has("stale-tree-unit")
	# The presence loop's `TeamData data = team.data();`
	# (:244) reads each team's data to rebuild present:
	# team 4 (buildings, no units) and team 5 (unit, no
	# buildings) are present, team 3 (nothing) is not.
	# Team 5's key is appended last (it did not exist
	# before the rebuild), so present ends [1, 2, 4, 6, 5].
	proof["presence_loop_reads_team_data"] = result.get("present", []) == [1, 2, 4, 6, 5] and present == [1, 2, 4, 6, 5] and not (result.get("present", []) as Array).has(3) and bool(team_4.get("present_flag", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsUpdateTeamStatsLegsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
