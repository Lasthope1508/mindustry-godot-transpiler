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


static func source_teams_update_enemies_state(teams_state: Dictionary, waves_enabled: bool, wave_team_id: int) -> Dictionary:
	# Teams.updateEnemies (Teams.java:252-268):
	# `private void updateEnemies(){`
	# `if(state.rules.waves && !active.contains(get(state.rules.waveTeam))){`
	# `active.add(get(state.rules.waveTeam));`
	# `}`
	# `for(TeamData data : active){`
	# `Seq<Team> enemies = new Seq<>();`
	# `for(TeamData other : active){`
	# `if(data.team != other.team){`
	# `enemies.add(other.team);`
	# `}`
	# `}`
	# `data.coreEnemies = enemies.toArray(Team.class);`
	# `}`
	# `}`
	# state.rules.waves / state.rules.waveTeam are Rules state (not
	# ported), so they arrive as explicit params (the N2330 param
	# precedent); teams are compared by team_id, not the Team enum.
	# core_enemies already lives in the teams_state dict (kept by
	# registerCore/unregisterCore, N2074/N2075); this slice REWRITES
	# that field. The call-site `updateEnemies();` already owned by
	# N2074/N2075 (registerCore/unregisterCore call it) is callee
	# evidence only, not this method's body. The function is pure:
	# it deep-copies the teams_state, sets the copy's rules from the
	# params, applies the shared _teams_update_enemies helper to the
	# copy, and returns the updated copy -- the caller's dict is
	# never mutated.
	var was_active: Array = teams_state.get("active", [])
	var wave_team_added: bool = waves_enabled and wave_team_id >= 0 and not was_active.has(wave_team_id)
	var updated: Dictionary = teams_state.duplicate(true)
	updated["rules"] = {"waves": waves_enabled, "wave_team": wave_team_id}
	_teams_update_enemies(updated)
	return {"teams_state": updated, "wave_team_added": wave_team_added}


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


static func source_teams_closest_enemy_core_state(teams_state: Dictionary, x: float, y: float, team_id: int, enemy_cores: Array) -> Dictionary:
	# Teams.closestEnemyCore (Teams.java:39-55):
	# `@Nullable`
	# `public CoreBuild closestEnemyCore(float x, float y, Team team){`
	# `CoreBuild closest = null;`
	# `float closestDst = Float.MAX_VALUE;`
	# `for(Team enemy : team.data().coreEnemies){`
	# `for(CoreBuild core : enemy.cores()){`
	# `float dst = Mathf.dst2(x, y, core.getX(), core.getY());`
	# `if(closestDst > dst){`
	# `closest = core;`
	# `closestDst = dst;`
	# `}`
	# `}`
	# `}`
	# `return closest;`
	# `}`
	# on `public class Teams{` (Teams.java:27). The scan
	# walks the calling team's coreEnemies -- read from
	# teams_state (kept there by updateEnemies,
	# Teams.java:252-268, NOT ported here) -- and each
	# enemy team's cores, keeping the core with the
	# smallest squared distance. Mathf.dst2 is the SQUARED
	# distance (arc Mathf.java:656-659), so closest_dst2
	# is squared too. A strict `>` keeps the FIRST core
	# on a tie, exactly as Java. No enemy core means null
	# (the @Nullable return) with closest_dst2 left at
	# Float.MAX_VALUE (3.4028235e38). The cores stored in
	# teams_state are opaque refs with no position, so the
	# enemy cores arrive as explicit records {"team_id":
	# int, "ref": Variant, "x": float, "y": float} (the
	# N2330 param precedent); only records whose team_id
	# is in the calling team's core_enemies are
	# considered. The read does not mutate teams_state
	# (it never calls _teams_data, which would create a
	# missing team entry).
	var teams: Dictionary = teams_state.get("teams", {})
	var data: Dictionary = teams.get(team_id, {})
	var core_enemies: Array = data.get("core_enemies", [])
	var closest: Variant = null
	var closest_dst2: float = 3.4028235e38
	for entry in enemy_cores:
		if not entry is Dictionary:
			continue
		if not core_enemies.has(int(entry.get("team_id", -1))):
			continue
		var dx: float = x - float(entry.get("x", 0.0))
		var dy: float = y - float(entry.get("y", 0.0))
		var dst2: float = dx * dx + dy * dy
		if closest_dst2 > dst2:
			closest = entry.get("ref", null)
			closest_dst2 = dst2
	return {"closest_core": closest, "closest_dst2": closest_dst2}


static func source_teams_any_enemy_cores_within_build_radius_state(teams_state: Dictionary, team_id: int, x: float, y: float, protect_cores_by_team: Dictionary, build_radius_by_team: Dictionary, tilesize: float, enemy_cores: Array) -> Dictionary:
	# Teams.anyEnemyCoresWithinBuildRadius (Teams.java:60-72):
	# `public boolean anyEnemyCoresWithinBuildRadius(Team team, float x, float y){`
	# `for(TeamData data : active){`
	# `if(team != data.team && data.team.rules().protectCores){`
	# `for(CoreBuild tile : data.cores){`
	# `if(tile.within(x, y, state.rules.buildRadius(tile.team) + tilesize)){`
	# `return true;`
	# `}`
	# `}`
	# `}`
	# `}`
	# `return false;`
	# `}`
	# on `public class Teams{` (Teams.java:27). The scan
	# walks the active teams (read from teams_state, kept
	# there by registerCore/unregisterCore, N2074/N2075),
	# skipping the calling team and teams whose rules do
	# not protect cores -- `data.team.rules().protectCores`
	# is Rules state (not ported), so it arrives as the
	# explicit protect_cores_by_team lookup keyed by
	# team_id -- and each enemy team's cores. A core
	# within `state.rules.buildRadius(tile.team) +
	# tilesize` of the query point returns true;
	# buildRadius is Rules state (not ported), so it
	# arrives as the explicit build_radius_by_team
	# lookup keyed by team_id, plus the tilesize param.
	# `tile.within(x, y, radius)` is arc Position.within
	# (Position.java:44-46): `Mathf.dst2(getX(), getY(),
	# x, y) < dst*dst` -- a STRICT < on the squared
	# distance, so a core exactly on the radius boundary
	# is OUTSIDE. The cores stored in teams_state are
	# opaque refs with no position, so the enemy cores
	# arrive as explicit records {"team_id": int, "x":
	# float, "y": float} (the N2330/N2354 param
	# precedent); only records whose team_id is the
	# active team being scanned are considered. The
	# call-site `state.teams.anyEnemyCoresWithinBuildRadius(...)`
	# already owned by N2042 (Build.validPlaceIgnoreUnits)
	# is callee evidence in another class's slice, not
	# this method's body. The read does not mutate
	# teams_state or the enemy-core records.
	var active: Array = teams_state.get("active", [])
	for data_team_id in active:
		var enemy_team_id := int(data_team_id)
		if enemy_team_id == team_id:
			continue
		if not bool(protect_cores_by_team.get(enemy_team_id, false)):
			continue
		var radius: float = float(build_radius_by_team.get(enemy_team_id, 0.0)) + tilesize
		var radius2: float = radius * radius
		for entry in enemy_cores:
			if not entry is Dictionary:
				continue
			if int(entry.get("team_id", -1)) != enemy_team_id:
				continue
			var dx: float = x - float(entry.get("x", 0.0))
			var dy: float = y - float(entry.get("y", 0.0))
			if dx * dx + dy * dy < radius2:
				return {"within": true}
	return {"within": false}


static func source_teams_any_enemy_cores_within_state(teams_state: Dictionary, team_id: int, x: float, y: float, radius: float, protect_cores_by_team: Dictionary, enemy_cores: Array) -> Dictionary:
	# Teams.anyEnemyCoresWithin (Teams.java:73-85):
	# `public boolean anyEnemyCoresWithin(Team team, float x, float y, float radius){`
	# `for(TeamData data : active){`
	# `if(team != data.team && data.team.rules().protectCores){`
	# `for(CoreBuild tile : data.cores){`
	# `if(tile.within(x, y, radius)){`
	# `return true;`
	# `}`
	# `}`
	# `}`
	# `}`
	# `return false;`
	# `}`
	# on `public class Teams{` (Teams.java:27). The scan
	# walks the active teams (read from teams_state, kept
	# there by registerCore/unregisterCore, N2074/N2075),
	# skipping the calling team and teams whose rules do
	# not protect cores -- `data.team.rules().protectCores`
	# is Rules state (not ported), so it arrives as the
	# explicit protect_cores_by_team lookup keyed by
	# team_id -- and each enemy team's cores. A core
	# within `radius` of the query point returns true;
	# unlike N2359 (anyEnemyCoresWithinBuildRadius), the
	# radius comes STRAIGHT from the signature param --
	# no buildRadius lookup and no tilesize here. The
	# `protectCores` condition line is shared text with
	# N2359, but this is a different method: the
	# distinguishing line `if(tile.within(x, y, radius)){`
	# is 0-hit in both ledgers.
	# `tile.within(x, y, radius)` is arc Position.within
	# (Position.java:44-46): `Mathf.dst2(getX(), getY(),
	# x, y) < dst*dst` -- a STRICT < on the squared
	# distance, so a core exactly on the radius boundary
	# is OUTSIDE. The cores stored in teams_state are
	# opaque refs with no position, so the enemy cores
	# arrive as explicit records {"team_id": int, "x":
	# float, "y": float} (the N2330/N2354 param
	# precedent); only records whose team_id is the
	# active team being scanned are considered. The
	# read does not mutate teams_state or the enemy-core
	# records.
	var active: Array = teams_state.get("active", [])
	var radius2: float = radius * radius
	for data_team_id in active:
		var enemy_team_id := int(data_team_id)
		if enemy_team_id == team_id:
			continue
		if not bool(protect_cores_by_team.get(enemy_team_id, false)):
			continue
		for entry in enemy_cores:
			if not entry is Dictionary:
				continue
			if int(entry.get("team_id", -1)) != enemy_team_id:
				continue
			var dx: float = x - float(entry.get("x", 0.0))
			var dy: float = y - float(entry.get("y", 0.0))
			if dx * dx + dy * dy < radius2:
				return {"within": true}
	return {"within": false}


static func source_teams_each_enemy_core_state(teams_state: Dictionary, team_id: int, enemy_cores: Array) -> Dictionary:
	# Teams.eachEnemyCore (Teams.java:86-94):
	# `public void eachEnemyCore(Team team, Cons<Building> ret){`
	# `for(TeamData data : active){`
	# `if(team != data.team){`
	# `for(Building tile : data.cores){`
	# `ret.get(tile);`
	# `}`
	# `}`
	# `}`
	# `}`
	# on `public class Teams{` (Teams.java:24). Java hands each
	# enemy core to the Cons<Building> callback; GDScript has no
	# Java Cons, so the port returns the enemy cores as data
	# (main-thread decision 2026-11-21, recorded in
	# allocations.json N2365): each core is [team_id, x, y] and the
	# caller iterates them instead of a callback. The payload is
	# the "cores" Array; the Dictionary envelope is the
	# family-convention return shape -- the SSOT validator
	# (source_symbols.py upsert_source_api_contract) accepts only
	# return_type Dictionary or void, so a bare Array return
	# cannot be registered, and every other state function in
	# this file returns a Dictionary. The cores stored in
	# teams_state are opaque refs with no position, so the enemy
	# cores arrive as explicit records
	# {"team_id": int, "x": float, "y": float} (the N2330/N2354
	# param precedent); only records whose team_id is the active
	# team being scanned are collected, in active-team order then
	# enemy_cores order. Unlike N2361 (anyEnemyCoresWithin), there
	# is no protectCores condition and no radius -- every enemy
	# team's cores are collected. The call does not mutate
	# teams_state or the enemy-core records.
	var active: Array = teams_state.get("active", [])
	var found: Array = []
	for data_team_id in active:
		var enemy_team_id := int(data_team_id)
		if enemy_team_id == team_id:
			continue
		for entry in enemy_cores:
			if not entry is Dictionary:
				continue
			if int(entry.get("team_id", -1)) != enemy_team_id:
				continue
			found.append([enemy_team_id, float(entry.get("x", 0.0)), float(entry.get("y", 0.0))])
	return {"cores": found}


static func source_team_data_liveness_state(cores: Array, team_rules: Dictionary) -> Dictionary:
	# TeamData.hasCore()+isAlive()+noCores()+core()+hasAI()
	# (Teams.java:450-472), one grouped slice (main-thread
	# decision 2026-11-21, N2326/N2297 group precedent):
	# `public boolean hasCore(){`
	# `return cores.size > 0;`
	# `}`
	# `public boolean isAlive(){`
	# `return hasCore();`
	# `}`
	# `public boolean noCores(){`
	# `return cores.isEmpty();`
	# `}`
	# `@Nullable`
	# `public CoreBuild core(){`
	# `return cores.isEmpty() ? null : cores.first();`
	# `}`
	# `public boolean hasAI(){`
	# `return team.rules().rtsAi || team.rules().buildAi;`
	# `}`
	# isAlive() delegates to hasCore() -- that delegate is
	# inside this same group, not an outside dedup. active()
	# (Teams.java:446-448) is NOT ported here: its only line
	# is already the exact_expr of N2074+N2075. The cores
	# arrive as an explicit Array of opaque core refs (the
	# N2330 param precedent); team.rules() arrives as the
	# explicit team_rules dict {rts_ai, build_ai} because
	# Rules is not ported. The read does not mutate cores
	# or team_rules.
	var has_core: bool = cores.size() > 0
	var has_ai: bool = bool(team_rules.get("rts_ai", false)) or bool(team_rules.get("build_ai", false))
	var first_core: Variant = null if cores.is_empty() else cores[0]
	return {"has_core": has_core, "is_alive": has_core, "no_cores": cores.is_empty(), "core": first_core, "has_ai": has_ai}


static func source_teams_get_state(teams_state: Dictionary, team_id: int) -> Dictionary:
	# Teams.get (Teams.java:97-104):
	# `public TeamData get(Team team){`
	# `var data = map[team.id];`
	# `if(data != null){`
	# `return data;`
	# `}else{`
	# `return map[team.id] = new TeamData(team);`
	# `}`
	# `}`
	# on `public class Teams{` (Teams.java:27). `map` is the
	# teams_state["teams"] dict (team_id -> TeamData dict);
	# the existing entry is returned when present, otherwise
	# a new empty TeamData dict is created and stored -- the
	# empty shape is the _teams_data shape ({"cores": [],
	# "buildings": [], "units": [], "core_enemies": []}),
	# since new TeamData(team) in Java starts with empty
	# cores/buildings/units. The `created` flag records
	# which branch ran: false on the `if(data != null){`
	# branch, true on the else branch. The write makes
	# teams_state an in/out param.
	var teams: Dictionary = teams_state.get("teams", {})
	var created: bool = not teams.has(team_id)
	var data: Dictionary = _teams_data(teams_state, team_id)
	return {"team_data": data, "created": created, "teams_state": teams_state}


static func source_teams_get_or_null_state(teams_state: Dictionary, team_id: int) -> Dictionary:
	# Teams.getOrNull (Teams.java:106-108):
	# `public @Nullable TeamData getOrNull(Team team){`
	# `return map[team.id];`
	# `}`
	# Unlike get(), this only READS the map: a missing team
	# returns null (the @Nullable return) and the entry is
	# NOT created -- it never calls _teams_data, which would
	# create a missing team entry. teams_state is read-only
	# here.
	var teams: Dictionary = teams_state.get("teams", {})
	var data: Variant = teams.get(team_id, null)
	return {"team_data": data}


static func source_teams_player_cores_state(teams_state: Dictionary, default_team_id: int) -> Dictionary:
	# Teams.playerCores (Teams.java:110-112):
	# `public Seq<CoreBuild> playerCores(){`
	# `return get(state.rules.defaultTeam).cores;`
	# `}`
	# The get() call is INSIDE this group (an internal
	# self-reference, not an outside expr): it may create
	# the default team's entry, so teams_state is in/out.
	# state.rules.defaultTeam is Rules state (not ported),
	# so it arrives as the explicit default_team_id param
	# (the N2330 param precedent).
	var got: Dictionary = source_teams_get_state(teams_state, default_team_id)
	var data: Dictionary = got.get("team_data", {})
	return {"cores": data.get("cores", []), "teams_state": got.get("teams_state", teams_state)}


static func source_teams_cores_state(teams_state: Dictionary, team_id: int) -> Dictionary:
	# Teams.cores (Teams.java:115-117):
	# `public Seq<CoreBuild> cores(Team team){`
	# `return get(team).cores;`
	# `}`
	# The get() call is INSIDE this group (an internal
	# self-reference, not an outside expr): it may create
	# the team's entry, so teams_state is in/out. Do not
	# modify: the /** Do not modify! */ note on cores()
	# (Teams.java:114).
	var got: Dictionary = source_teams_get_state(teams_state, team_id)
	var data: Dictionary = got.get("team_data", {})
	return {"cores": data.get("cores", []), "teams_state": got.get("teams_state", teams_state)}


static func source_teams_is_active_state(teams_state: Dictionary, team_id: int) -> Dictionary:
	# Teams.isActive (Teams.java:120-123):
	# `public boolean isActive(Team team){`
	# `//the enemy wave team is always active`
	# `return get(team).active();`
	# `}`
	# The get() call is INSIDE this group (an internal
	# self-reference, not an outside expr): it may create
	# the team's entry, so teams_state is in/out. active()
	# is TeamData.active() (Teams.java:446-448), already the
	# exact_expr of N2074/N2075 -- the file's _teams_active
	# helper IS that callee, called here as evidence only,
	# not re-ported. The wave team is always active via the
	# wave condition inside active().
	var got: Dictionary = source_teams_get_state(teams_state, team_id)
	var data: Dictionary = got.get("team_data", {})
	var rules: Dictionary = teams_state.get("rules", {})
	return {"is_active": _teams_active(data, team_id, rules), "teams_state": got.get("teams_state", teams_state)}


static func source_teams_can_interact_state(team_id: int, other_team_id: int, derelict_team_id: int) -> Dictionary:
	# Teams.canInteract (Teams.java:125-127):
	# `public boolean canInteract(Team team, Team other){`
	# `return team == other || other == Team.derelict;`
	# `}`
	# A pure id predicate -- no teams_state needed.
	# Team.derelict is a Team const (not ported), so it
	# arrives as the explicit derelict_team_id param
	# (derelict id 0, Team.java:41, per the file header
	# comment).
	return {"can_interact": team_id == other_team_id or other_team_id == derelict_team_id}


static func source_teams_get_active_state(teams_state: Dictionary) -> Dictionary:
	# Teams.getActive (Teams.java:130-133):
	# `public Seq<TeamData> getActive(){`
	# `active.removeAll(t -> !t.active());`
	# `return active;`
	# `}`
	# Java removeAll mutates the active Seq in place,
	# keeping only entries whose TeamData.active() is true,
	# in original order -- so teams_state["active"] is
	# rewritten here and teams_state is an in/out param.
	# active() is TeamData.active() (Teams.java:446-448),
	# already the exact_expr of N2074/N2075 -- the file's
	# _teams_active helper IS that callee, called here as
	# evidence only, not re-ported. Do not modify: the
	# /** Do not modify. */ note on getActive()
	# (Teams.java:129).
	var rules: Dictionary = teams_state.get("rules", {})
	var teams: Dictionary = teams_state.get("teams", {})
	var kept: Array = []
	for member_id in teams_state.get("active", []):
		var member_team_id := int(member_id)
		var data: Dictionary = teams.get(member_team_id, {})
		if _teams_active(data, member_team_id, rules):
			kept.append(member_team_id)
	teams_state["active"] = kept
	return {"active": kept, "teams_state": teams_state}
