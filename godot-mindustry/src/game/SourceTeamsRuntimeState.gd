extends RefCounted
class_name SourceTeamsRuntimeState

# Teams.registerCore / unregisterCore (Teams.java:144-165) operate on a
# teams_state dict:
# {
#   "teams": {team_id (int): {"cores": [core_refs], "buildings": [...], "units": [...], "core_enemies": [team_ids]}},
#   "active": [team_ids],
#   "rules": {"wave_team": int, "waves": bool}
# }
# Team ids: derelict 0, sharded 1, crux 2, neoplastic 6 (Team.java:41).
# A team is active when (team == waveTeam && waves) || cores > 0 ||
# buildings > 0 || (team == neoplastic && units > 0) (Teams.java:446-448).
# updateEnemies (Teams.java:252-268) keeps the wave team active and sets
# each active team's coreEnemies to the other active teams.

# Team.java:41: neoplastic = new Team(6, "neoplastic", ...).
const SOURCE_TEAMS_NEOPLASTIC_TEAM_ID := 6


static func _teams_data(teams_state: Dictionary, team_id: int) -> Dictionary:
	var teams: Dictionary = teams_state.get("teams", {})
	if not teams.has(team_id):
		teams[team_id] = {"cores": [], "buildings": [], "units": [], "core_enemies": []}
	teams_state["teams"] = teams
	return teams[team_id]


static func _teams_active(team_data: Dictionary, team_id: int, rules: Dictionary) -> bool:
	return (team_id == int(rules.get("wave_team", -1)) and bool(rules.get("waves", false))) or int(team_data.get("cores", []).size()) > 0 or int(team_data.get("buildings", []).size()) > 0 or (team_id == SOURCE_TEAMS_NEOPLASTIC_TEAM_ID and int(team_data.get("units", []).size()) > 0)


static func _teams_update_enemies(teams_state: Dictionary) -> Dictionary:
	var rules: Dictionary = teams_state.get("rules", {})
	var active: Array = teams_state.get("active", [])
	if bool(rules.get("waves", false)):
		var wave_team := int(rules.get("wave_team", -1))
		if wave_team >= 0 and not active.has(wave_team):
			active.append(wave_team)
	var enemies_by_team := {}
	for team_id in active:
		var others: Array = []
		for other_id in active:
			if other_id != team_id:
				others.append(other_id)
		enemies_by_team[team_id] = others
		var data: Dictionary = _teams_data(teams_state, int(team_id))
		data["core_enemies"] = others
	teams_state["active"] = active
	return enemies_by_team


static func _teams_current_enemies(teams_state: Dictionary) -> Dictionary:
	var enemies_by_team := {}
	for team_id in teams_state.get("active", []):
		var data: Dictionary = _teams_data(teams_state, int(team_id))
		enemies_by_team[team_id] = data.get("core_enemies", [])
	return enemies_by_team


static func source_teams_register_core_state(teams_state: Dictionary, team_id: int, core_ref: Variant) -> Dictionary:
	var data: Dictionary = _teams_data(teams_state, team_id)
	var cores: Array = data.get("cores", [])
	var registered := false
	if not cores.has(core_ref):
		cores.append(core_ref)
		registered = true
	data["cores"] = cores
	var rules: Dictionary = teams_state.get("rules", {})
	var active: Array = teams_state.get("active", [])
	var active_changed := false
	var enemies_by_team := {}
	if _teams_active(data, team_id, rules) and not active.has(team_id):
		active.append(team_id)
		teams_state["active"] = active
		enemies_by_team = _teams_update_enemies(teams_state)
		active_changed = true
	else:
		enemies_by_team = _teams_current_enemies(teams_state)
	return {"registered": registered, "active_changed": active_changed, "active": teams_state.get("active", []), "enemies_by_team": enemies_by_team, "teams_state": teams_state}


static func source_teams_unregister_core_state(teams_state: Dictionary, team_id: int, core_ref: Variant) -> Dictionary:
	var data: Dictionary = _teams_data(teams_state, team_id)
	var cores: Array = data.get("cores", [])
	var unregistered := false
	if cores.has(core_ref):
		cores.erase(core_ref)
		unregistered = true
	data["cores"] = cores
	var rules: Dictionary = teams_state.get("rules", {})
	var active: Array = teams_state.get("active", [])
	var active_changed := false
	var enemies_by_team := {}
	if not _teams_active(data, team_id, rules) and active.has(team_id):
		active.erase(team_id)
		teams_state["active"] = active
		enemies_by_team = _teams_update_enemies(teams_state)
		active_changed = true
	else:
		enemies_by_team = _teams_current_enemies(teams_state)
	return {"unregistered": unregistered, "active_changed": active_changed, "active": teams_state.get("active", []), "enemies_by_team": enemies_by_team, "teams_state": teams_state}
