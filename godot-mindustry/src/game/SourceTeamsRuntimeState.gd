extends RefCounted
class_name SourceTeamsRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerGameplayRegistry.gd")

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


static func source_team_data_update_count_state(type_counts: Array, type_id: int, amount: int, unit_count: int, content_unit_size: int) -> Dictionary:
	# TeamData.updateCount (Teams.java:429-436):
	# `public void updateCount(UnitType type, int amount){`
	# `if(type == null) return;`
	# `unitCount = Math.max(amount + unitCount, 0);`
	# `if(typeCounts == null || typeCounts.length <= type.id){`
	# `typeCounts = typeCounts == null ? new int[Vars.content.units().size] : Arrays.copyOf(typeCounts, Vars.content.units().size);`
	# `typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);`
	# `}`
	# type_id < 0 maps to type == null (the catalog exposes
	# name-string ids only, so the caller passes the integer type
	# id); the counts are returned unchanged. The updated per-type
	# count is read back through countType (Teams.java:442-444):
	# `public int countType(UnitType type){`
	# `return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];`
	# `}`
	var counts: Array = type_counts.duplicate()
	if type_id < 0:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TEAM_DATA_UPDATE_COUNT_STATE, "type_counts": counts, "unit_count": unit_count, "count_type": 0}
	if counts.size() <= type_id:
		# Arrays.copyOf semantics: grow to the content unit
		# count, padding with 0.
		while counts.size() < content_unit_size:
			counts.append(0)
	var new_unit_count: int = maxi(amount + unit_count, 0)
	counts[type_id] = maxi(amount + int(counts[type_id]), 0)
	var count_type: int = 0 if counts.size() <= type_id else int(counts[type_id])
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TEAM_DATA_UPDATE_COUNT_STATE, "type_counts": counts, "unit_count": new_unit_count, "count_type": count_type}


static func _team_data_count_unit(unit: Variant, team_id: int, type_counts: Array, unit_count: int, content_unit_size: int, team_unit_counts: Dictionary) -> Dictionary:
	# Teams.count (Teams.java:168-179) for one unit record:
	# `private void count(Unit unit){`
	# `unit.team.data().updateCount(unit.type, 1);`
	# `if(unit instanceof Payloadc payloadc){`
	# `var payloads = payloadc.payloads();`
	# `for(int i = 0; i < payloads.size; i++){`
	# `if(payloads.get(i) instanceof UnitPayload payload){`
	# `count(payload.unit);`
	# `}`
	# `}`
	# `}`
	# `}`
	# Unit records are {"team_id": int, "type_id": int,
	# "type_name": String, "payload_units": [...]}; a record of
	# another team, or with type_id < 0 (unit.type == null),
	# counts into another team's data or nothing at all, so it
	# is skipped here — exactly as the Groups.unit loop skips a
	# null type (Teams.java:214 `if(unit.type == null) continue;`).
	if not unit is Dictionary or int(unit.get("team_id", -1)) != team_id or int(unit.get("type_id", -1)) < 0:
		return {"type_counts": type_counts, "unit_count": unit_count, "team_unit_counts": team_unit_counts}
	var counted: Dictionary = source_team_data_update_count_state(type_counts, int(unit.get("type_id", -1)), 1, unit_count, content_unit_size)
	type_counts = counted.get("type_counts", type_counts)
	unit_count = int(counted.get("unit_count", unit_count))
	var type_name: String = str(unit.get("type_name", ""))
	team_unit_counts[type_name] = int(team_unit_counts.get(type_name, 0)) + 1
	var payload_units: Variant = unit.get("payload_units", [])
	if payload_units is Array:
		for payload_unit in payload_units:
			var recursed: Dictionary = _team_data_count_unit(payload_unit, team_id, type_counts, unit_count, content_unit_size, team_unit_counts)
			type_counts = recursed.get("type_counts", type_counts)
			unit_count = int(recursed.get("unit_count", unit_count))
			team_unit_counts = recursed.get("team_unit_counts", team_unit_counts)
	return {"type_counts": type_counts, "unit_count": unit_count, "team_unit_counts": team_unit_counts}


static func source_team_data_update_team_stats_state(units: Array, team_id: int, content_unit_size: int) -> Dictionary:
	# Teams.updateTeamStats (Teams.java:182-245) for ONE team —
	# the frame's view is a single team's TeamData, so the
	# multi-team presence/boss/player/tree rebuild stays
	# deferred; the reset + recount of this team's counts is
	# what the frame needs:
	# `data.unitCount = 0;`
	# `if(data.typeCounts != null){`
	# `Arrays.fill(data.typeCounts, 0);`
	# `}`
	# `for(Unit unit : Groups.unit){`
	# `if(unit.type == null) continue;`
	# `...`
	# `count(unit);`
	# `}`
	# Starting from empty counts is the reset (unitCount 0,
	# typeCounts all 0); every live unit of the team is then
	# recounted through the updateCount primitive, payload units
	# included, exactly as count(unit) recurses.
	var type_counts: Array = []
	var unit_count := 0
	var team_unit_counts := {}
	for unit in units:
		var counted: Dictionary = _team_data_count_unit(unit, team_id, type_counts, unit_count, content_unit_size, team_unit_counts)
		type_counts = counted.get("type_counts", type_counts)
		unit_count = int(counted.get("unit_count", unit_count))
		team_unit_counts = counted.get("team_unit_counts", team_unit_counts)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TEAM_DATA_UPDATE_TEAM_STATS_STATE, "unit_count": unit_count, "team_unit_counts": team_unit_counts}
