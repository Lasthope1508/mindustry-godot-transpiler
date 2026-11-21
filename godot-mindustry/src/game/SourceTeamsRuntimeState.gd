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
# updateTeamStats (Teams.java:181-251, N2383) reads and writes the
# fuller TeamData shape on the same per-team dicts:
# {"cores": [...], "buildings": [...], "units": [...],
#  "core_enemies": [...], "present_flag": bool, "unit_count": int,
#  "players": [player refs], "last_core": core ref or absent,
#  "unit_tree": {"inserted": [unit records]} or absent,
#  "type_counts": [int] or absent,
#  "units_by_type": [Array of unit records or null] or absent}.
# present_flag / lastCore / unitTree / typeCounts / unitsByType are
# TeamData fields (Teams.java:280, 290, 296, 299, 311); present and
# bosses are the Teams-level Seqs (Teams.java:30, 32).

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


static func source_team_data_get_buildings_state(building_types: Dictionary, block_key: Variant, default_buildings: Callable) -> Dictionary:
	# TeamData.getBuildings (Teams.java:318-320) on
	# `public static class TeamData{` (Teams.java:270):
	# `public Seq<Building> getBuildings(Block block){`
	# `return buildingTypes.get(block, () -> new Seq<>(false));`
	# `}`
	# buildingTypes is the ObjectMap<Block, Seq<Building>>
	# (Teams.java:304) as a Dictionary keyed by block key.
	# ObjectMap.get(key, default) does NOT store the
	# default, so a missing block returns a fresh empty
	# Array from the default supplier and leaves the map
	# untouched; a present block returns its stored Array
	# as-is (the same Seq reference Java returns). The
	# `() -> new Seq<>(false)` supplier arrives as the
	# default_buildings Callable (the N2386 Callable
	# precedent); Block is not ported, so the block
	# arrives as its key.
	if building_types.has(block_key):
		return {"buildings": building_types[block_key]}
	return {"buildings": default_buildings.call()}


static func source_team_data_get_count_state(building_types: Dictionary, block_key: Variant) -> Dictionary:
	# TeamData.getCount (Teams.java:322-325):
	# `public int getCount(Block block){`
	# `var res = buildingTypes.get(block);`
	# `return res == null ? 0 : res.size;`
	# `}`
	# Same map as getBuildings, read-only: a missing
	# block counts 0 (the `res == null` branch); a
	# present block counts its stored Array size.
	var res: Variant = building_types.get(block_key, null)
	if res == null:
		return {"count": 0}
	return {"count": (res as Array).size()}


static func source_team_data_get_units_state(units_by_type: Variant, type_id: int) -> Dictionary:
	# TeamData.getUnits (Teams.java:418-420):
	# `public Seq<Unit> getUnits(UnitType type){`
	# `return unitCache(type);`
	# `}`
	# getUnits is just an alias for unitCache (the comment
	# at Teams.java:417) -- the unitCache call is INSIDE
	# this group (an internal self-reference, not an
	# outside expr): units_by_type passes through to
	# unitCache, which may return null (the @Nullable
	# return, Teams.java:419).
	var cached: Dictionary = source_team_data_unit_cache_state(units_by_type, type_id)
	return {"units": cached.get("units", null)}


static func source_team_data_unit_cache_state(units_by_type: Variant, type_id: int) -> Dictionary:
	# TeamData.unitCache (Teams.java:422-426):
	# `public Seq<Unit> unitCache(UnitType type){`
	# `if(unitsByType == null || unitsByType.length <= type.id || unitsByType[type.id] == null) return null;`
	# `return unitsByType[type.id];`
	# `}`
	# unitsByType is the @Nullable Seq<Unit>[] (Teams.java:311)
	# as an Array of unit Arrays (or null); type.id arrives
	# as the type_id param (UnitType is not ported). All
	# three null guards run before the index: a null table,
	# an out-of-range type id, or a null slot all return
	# null (the @Nullable return, Teams.java:421).
	if units_by_type == null:
		return {"units": null}
	var by_type: Array = units_by_type as Array
	if type_id < 0 or type_id >= by_type.size():
		return {"units": null}
	var slot: Variant = by_type[type_id]
	if slot == null:
		return {"units": null}
	return {"units": slot}


static func source_teams_closest_core_state(x: float, y: float, cores: Array, find_closest: Callable) -> Dictionary:
	# Teams.closestCore (Teams.java:56-58):
	# `@Nullable`
	# `public CoreBuild closestCore(float x, float y, Team team){`
	# `return Geometry.findClosest(x, y, get(team).cores);`
	# `}`
	# get(team).cores is the TeamData cores Seq (Teams.java:288)
	# as an Array param -- get(team) is Teams.get(Team)
	# (Teams.java:97), already the exact_expr of N2380, so
	# the lookup is the caller's job and the cores arrive
	# here already resolved. Geometry.findClosest is an
	# engine API (arc Geometry), not ported: it arrives as
	# the find_closest Callable (x, y, cores) -> the
	# nearest core ref, or null (the @Nullable return).
	# Read-only: nothing is written back.
	return {"core": find_closest.call(x, y, cores)}


static func source_team_data_tree_state(unit_tree: Variant, world_quad_bounds: Callable) -> Dictionary:
	# TeamData.tree (Teams.java:437-440) on
	# `public static class TeamData{` (Teams.java:270):
	# `public QuadTree<Unit> tree(){`
	# `if(unitTree == null) unitTree = new QuadTree<>(Vars.world.getQuadBounds(new Rect()));`
	# `return unitTree;`
	# `}`
	# unitTree is the cached @Nullable QuadTree<Unit>
	# (Teams.java:296) as a Dictionary-or-null param (the
	# QuadTree itself is not ported -- the cache arrives
	# as its Dictionary shape, the same shape
	# _teams_reset_team_data keeps under "unit_tree").
	# Vars.world.getQuadBounds arrives as the
	# world_quad_bounds Callable (no args -> the bounds
	# Dictionary for the fresh tree), called only when
	# the cache is null -- the lazy init. The returned
	# unit_tree is the value the caller stores back into
	# TeamData (the function itself stays pure, like
	# getBuildings above).
	if unit_tree == null:
		return {"unit_tree": world_quad_bounds.call()}
	return {"unit_tree": unit_tree}


static func _teams_reset_team_data(data: Dictionary) -> Dictionary:
	# The per-team reset half of Teams.updateTeamStats
	# (Teams.java:185-211) for one TeamData dict, shared by
	# the Team.all loop and by units/players whose team had
	# no entry yet (Java `team.data()` creates it, so the
	# reset had already run on it in the first loop).
	# `data.unitCount = 0;` / `if(data.typeCounts != null){`
	# / `Arrays.fill(data.typeCounts, 0);` are already the
	# exact_exprs of N2141 -- the reset behavior is
	# implemented here, the exprs are cited as evidence
	# only, not re-registered. lastCore keeps its previous
	# value when the team has no cores (Java only assigns
	# inside `if(data.cores.size > 0){`); unitTree is only
	# cleared when present (Java `if(data.unitTree != null){`).
	data["present_flag"] = int((data.get("buildings", []) as Array).size()) > 0
	data["unit_count"] = 0
	data["units"] = []
	data["players"] = []
	if int((data.get("cores", []) as Array).size()) > 0:
		data["last_core"] = (data.get("cores", []) as Array)[0]
	if data.get("unit_tree", null) is Dictionary:
		(data["unit_tree"] as Dictionary)["inserted"] = []
	var type_counts: Array = (data.get("type_counts", []) as Array).duplicate()
	for i in type_counts.size():
		type_counts[i] = 0
	data["type_counts"] = type_counts
	if data.get("units_by_type", null) is Array:
		var units_by_type: Array = data["units_by_type"]
		for i in units_by_type.size():
			if units_by_type[i] is Array:
				units_by_type[i] = []
	return {"type_counts": type_counts, "unit_count": 0, "team_unit_counts": {}}


static func source_teams_update_team_stats_state(teams_state: Dictionary, units: Array, players: Array, wave_team_id: int, content_unit_size: int, present: Array, bosses: Array) -> Dictionary:
	# Teams.updateTeamStats (Teams.java:181-251):
	# `present.clear();`
	# `bosses.clear();`
	# `for(Team team : Team.all){`
	# `TeamData data = team.data();`
	# `data.presentFlag = data.buildings.size > 0;`
	# `data.unitCount = 0;`
	# `data.units.clear();`
	# `data.players.clear();`
	# `if(data.cores.size > 0){`
	# `data.lastCore = data.cores.first();`
	# `}`
	# `if(data.unitTree != null){`
	# `data.unitTree.clear();`
	# `}`
	# `if(data.typeCounts != null){`
	# `Arrays.fill(data.typeCounts, 0);`
	# `}`
	# `//clear old unit records`
	# `if(data.unitsByType != null){`
	# `for(int i = 0; i < data.unitsByType.length; i++){`
	# `if(data.unitsByType[i] != null){`
	# `data.unitsByType[i].clear();`
	# `}`
	# `}`
	# `}`
	# `}`
	# `//TODO this is slow and dumb`
	# `for(Unit unit : Groups.unit){`
	# `if(unit.type == null) continue;`
	# `TeamData data = unit.team.data();`
	# `data.tree().insert(unit);`
	# `data.units.add(unit);`
	# `data.presentFlag = true;`
	# `if(unit.team == state.rules.waveTeam && unit.isBoss()){`
	# `bosses.add(unit);`
	# `}`
	# `if(data.unitsByType == null || data.unitsByType.length <= unit.type.id){`
	# `data.unitsByType = new Seq[content.units().size];`
	# `}`
	# `if(data.unitsByType[unit.type.id] == null){`
	# `data.unitsByType[unit.type.id] = new Seq<>();`
	# `}`
	# `data.unitsByType[unit.type.id].add(unit);`
	# `count(unit);`
	# `}`
	# `for(var player : Groups.player){`
	# `player.team().data().players.add(player);`
	# `}`
	# `//update presence of each team.`
	# `for(Team team : Team.all){`
	# `TeamData data = team.data();`
	# `if(data.presentFlag || data.active()){`
	# `present.add(data);`
	# `}`
	# `}`
	# `}`
	# on `public void updateTeamStats(){` (Teams.java:181,
	# already the exact_expr of N2141, cited here as
	# evidence only). The header, `data.unitCount = 0;`,
	# `if(data.typeCounts != null){`,
	# `Arrays.fill(data.typeCounts, 0);`,
	# `for(Unit unit : Groups.unit){`,
	# `data.units.add(unit);`, and helper `count(Unit unit){`
	# are already the exact_exprs of N2141; the loop header
	# `for(Team team : Team.all){` is already the exact_expr
	# of N1356 (Block.load) -- none is re-registered. The
	# reset + recount behavior they describe IS implemented
	# here, through the N2141 callee
	# `_team_data_count_unit` (which wraps
	# `source_team_data_update_count_state`) for
	# `count(unit);`. `data.tree()` is NOT called as an
	# accessor: the team's unitTree arrives inside the
	# per-team dict and is modeled as its inserted-unit
	# list {"inserted": [...]} -- the QuadTree spatial
	# structure (Teams.java:296, 437-439) is not ported;
	# tree() creates the tree lazily when null, so the
	# insert creates the {"inserted": [...]} dict when the
	# team had none. `data.active()` is TeamData.active()
	# (Teams.java:446-448), already the exact_expr of
	# N2074/N2075 -- the file's `_teams_active` helper IS
	# that callee. Team.all is the teams_state["teams"]
	# keys (the frame's tracked teams, in key order); a
	# unit/player whose team had no entry creates it via
	# `_teams_data`, exactly as Java `team.data()` does.
	# Groups.unit / Groups.player are live entity groups
	# (not ported): units arrive as records {"team_id":
	# int, "type_id": int (-1 maps to unit.type == null),
	# "type_name": String, "is_boss": bool,
	# "payload_units": [...]} (the N2141 record shape plus
	# is_boss), players as {"team_id": int, "ref":
	# Variant}. state.rules.waveTeam and
	# content.units().size arrive as explicit params (the
	# N2330 param precedent). present/bosses are the
	# frame's in/out Seqs: cleared first, then rebuilt in
	# place, so the caller's Arrays are the ones mutated.
	# teams_state is an in/out param. The unitsByType
	# regrowth replaces the whole array with a fresh one
	# of length content_unit_size exactly as Java does
	# (`data.unitsByType = new Seq[content.units().size];`)
	# -- in practice it only fires on the first unit of a
	# team, since afterwards length == content size.
	present.clear()
	bosses.clear()
	var teams: Dictionary = teams_state.get("teams", {})
	var rules: Dictionary = teams_state.get("rules", {})
	var per_team := {}
	for team_id in teams.keys():
		var member_team_id := int(team_id)
		var data: Dictionary = teams[member_team_id]
		per_team[member_team_id] = _teams_reset_team_data(data)
	for unit in units:
		if not unit is Dictionary:
			continue
		if int(unit.get("type_id", -1)) < 0:
			continue
		var unit_team_id := int(unit.get("team_id", -1))
		var data: Dictionary = _teams_data(teams_state, unit_team_id)
		var work: Dictionary = per_team.get(unit_team_id, {})
		if work.is_empty():
			work = _teams_reset_team_data(data)
			per_team[unit_team_id] = work
		var unit_tree: Dictionary = data.get("unit_tree", {})
		if not unit_tree is Dictionary:
			unit_tree = {}
		var inserted: Array = unit_tree.get("inserted", [])
		inserted.append(unit)
		unit_tree["inserted"] = inserted
		data["unit_tree"] = unit_tree
		var team_units: Array = data.get("units", [])
		team_units.append(unit)
		data["units"] = team_units
		data["present_flag"] = true
		if unit_team_id == wave_team_id and bool(unit.get("is_boss", false)):
			bosses.append(unit)
		var type_id := int(unit.get("type_id", -1))
		var units_by_type: Variant = data.get("units_by_type", null)
		if not units_by_type is Array or (units_by_type as Array).size() <= type_id:
			var grown: Array = []
			grown.resize(content_unit_size)
			units_by_type = grown
			data["units_by_type"] = units_by_type
		if (units_by_type as Array)[type_id] == null:
			(units_by_type as Array)[type_id] = []
		((units_by_type as Array)[type_id] as Array).append(unit)
		var counted: Dictionary = _team_data_count_unit(unit, unit_team_id, work.get("type_counts", []), int(work.get("unit_count", 0)), content_unit_size, work.get("team_unit_counts", {}))
		work["type_counts"] = counted.get("type_counts", work.get("type_counts", []))
		work["unit_count"] = int(counted.get("unit_count", 0))
		work["team_unit_counts"] = counted.get("team_unit_counts", work.get("team_unit_counts", {}))
	for player in players:
		if not player is Dictionary:
			continue
		var player_team_id := int(player.get("team_id", -1))
		var data: Dictionary = _teams_data(teams_state, player_team_id)
		if not per_team.has(player_team_id):
			per_team[player_team_id] = _teams_reset_team_data(data)
		var team_players: Array = data.get("players", [])
		team_players.append(player.get("ref", player))
		data["players"] = team_players
	var unit_counts_by_team := {}
	for team_id in per_team.keys():
		var member_team_id := int(team_id)
		var data: Dictionary = (teams_state.get("teams", {}) as Dictionary).get(member_team_id, {})
		var work: Dictionary = per_team[member_team_id]
		data["type_counts"] = work.get("type_counts", data.get("type_counts", []))
		data["unit_count"] = int(work.get("unit_count", 0))
		unit_counts_by_team[member_team_id] = work.get("team_unit_counts", {})
	for team_id in (teams_state.get("teams", {}) as Dictionary).keys():
		var member_team_id := int(team_id)
		var data: Dictionary = (teams_state.get("teams", {}) as Dictionary).get(member_team_id, {})
		if bool(data.get("present_flag", false)) or _teams_active(data, member_team_id, rules):
			present.append(member_team_id)
	return {"teams_state": teams_state, "present": present, "bosses": bosses, "unit_counts_by_team": unit_counts_by_team}


static func source_team_data_schedule_derelict_state(build_pos: int, has_unit_payload: bool, derelict_buffer: Array, destroy_payload: Callable, chance_roll: float, random_delay: float, time_run: Callable, kill_build: Callable, add_plan: Callable) -> Dictionary:
	# TeamData.scheduleDerelict (Teams.java:396-409) on
	# `public static class TeamData{` (Teams.java:270):
	# `private void scheduleDerelict(Building build){`
	# `derelictBuffer.add(build.pos());`
	# `if(build.getPayload() instanceof UnitPayload){`
	# `Call.destroyPayload(build);`
	# `}`
	# `if(Mathf.chance(0.2)){`
	# `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`
	# `}`
	# `build.addPlan(false, true);`
	# `}`
	# derelictBuffer is the static IntSeq (Teams.java:271)
	# as an in/out Array param -- the buffer is shared
	# across calls, so the caller passes the live Array
	# and this function appends the pos in place (the
	# frame returns the same Array). `build.pos()` arrives
	# as the build_pos param (Building is not ported);
	# `build.getPayload() instanceof UnitPayload` arrives
	# as the has_unit_payload bool. `Call.destroyPayload`
	# is a network call, not ported: it arrives as the
	# destroy_payload Callable (build_pos) and the call is
	# recorded in the frame -- no packet is ever sent.
	# `Mathf.chance(0.2)` arrives as the chance_roll float
	# (the sampled roll, 0.0-1.0): the delayed kill is
	# scheduled only when the roll is below 0.2, exactly
	# as Java's chance check. `Time.run` is not ported:
	# it arrives as the time_run Callable (delay, action)
	# recording the delay + the kill action; the
	# `Mathf.random(0f, 60f * 6f)` sample arrives as the
	# random_delay float, and `build::kill` arrives as
	# the kill_build Callable (build_pos) wrapped in the
	# recorded action -- the kill only runs when the
	# recorded action is executed, never here.
	# `build.addPlan(false, true)` arrives as the add_plan
	# Callable (build_pos, false, true) and is recorded.
	derelict_buffer.append(build_pos)
	var destroy_payload_calls: Array = []
	if has_unit_payload:
		destroy_payload.call(build_pos)
		destroy_payload_calls.append(build_pos)
	var scheduled_kill: Variant = null
	if chance_roll < 0.2:
		time_run.call(random_delay, func() -> void: kill_build.call(build_pos))
		scheduled_kill = {"delay": random_delay, "build_pos": build_pos}
	add_plan.call(build_pos, false, true)
	return {"derelict_buffer": derelict_buffer, "destroy_payload_calls": destroy_payload_calls, "scheduled_kill": scheduled_kill, "add_plan_calls": [build_pos]}


static func source_team_data_finish_schedule_derelict_state(derelict_buffer: Array, set_teams: Callable) -> Dictionary:
	# TeamData.finishScheduleDerelict (Teams.java:411-414):
	# `private void finishScheduleDerelict(){`
	# `derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));`
	# `derelictBuffer.clear();`
	# `}`
	# derelictBuffer is the same in/out Array param as in
	# scheduleDerelict above (the static IntSeq,
	# Teams.java:271). `chunked(1000, ...)` splits the
	# buffer into chunks of at most 1000 positions;
	# `Call.setTeams` is a network call, not ported: it
	# arrives as the set_teams Callable (values, "derelict")
	# and every chunk call is recorded in the frame -- no
	# packet is ever sent. The buffer is cleared after the
	# flush (the `derelictBuffer.clear();` line), so the
	# returned derelict_buffer is always the emptied Array.
	var set_teams_calls: Array = []
	var index := 0
	while index < derelict_buffer.size():
		var chunk: Array = derelict_buffer.slice(index, mini(index + 1000, derelict_buffer.size()))
		set_teams.call(chunk, "derelict")
		set_teams_calls.append({"values": chunk, "team": "derelict"})
		index += 1000
	derelict_buffer.clear()
	return {"derelict_buffer": derelict_buffer, "set_teams_calls": set_teams_calls}


static func source_team_data_destroy_to_derelict_state(building_tree_objects: Variant, plans: Array, units: Array, team_id: int, derelict_buffer: Array, unit_delays: Array, chance_rolls: Array, kill_delays: Array, destroy_payload: Callable, time_run: Callable, kill_build: Callable, kill_unit: Callable, add_plan: Callable, set_teams: Callable) -> Dictionary:
	# TeamData.destroyToDerelict (Teams.java:328-360):
	# `public void destroyToDerelict(){`
	# `var builds = new Seq<Building>();`
	# `if(buildingTree != null){`
	# `buildingTree.getObjects(builds);`
	# `}`
	# `plans.clear();`
	# `for(var b : builds){`
	# `if(b.block.privileged) continue;`
	# `if(b instanceof CoreBuild){`
	# `b.kill();`
	# `}else{`
	# `scheduleDerelict(b);`
	# `}`
	# `}`
	# `finishScheduleDerelict();`
	# `units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {`
	# `if(u.team == team){`
	# `u.kill();`
	# `}`
	# `}));`
	# `}`
	# buildingTree is the @Nullable QuadTree<Building>
	# (Teams.java:294), not ported: its objects arrive as
	# the building_tree_objects param (null when the tree
	# is null, else the Array of build records). Each build
	# record is a Dictionary {"pos": int, "privileged":
	# bool, "is_core": bool, "has_unit_payload": bool} --
	# `b.block.privileged` and `b instanceof CoreBuild`
	# arrive as the precomputed "privileged" / "is_core"
	# flags (Block is not ported). `plans.clear();` is
	# already the exact_expr of N1143 -- the clear IS
	# implemented here (the passed plans Array is cleared
	# in place, the same in/out pattern as present/bosses
	# in updateTeamStats) but the expr is cited as
	# evidence only, not re-registered. `b.kill();` /
	# `u.kill();` are generic -- not registered; the kills
	# arrive as the kill_build (build_pos) / kill_unit
	# (unit record) Callable params. Cores are killed at
	# once via kill_build; every other non-privileged
	# build goes through the scheduleDerelict callee above
	# (an internal self-reference, not an outside expr),
	# with the per-scheduled-build `Mathf.chance(0.2)` /
	# `Mathf.random(0f, 60f * 6f)` samples arriving as the
	# chance_rolls / kill_delays Arrays in schedule order
	# (a missing entry defaults to 0.0, i.e. the kill is
	# scheduled). `finishScheduleDerelict();` is the
	# finish callee above. `units.each(...)` iterates the
	# units Array (records {"team_id": int, ...}); the
	# `Mathf.random(0f, 60f * 5f)` sample per unit arrives
	# as the unit_delays Array in unit order (a missing
	# entry defaults to 0.0). `Time.run` arrives as the
	# time_run Callable (delay, action); the delayed action
	# keeps the `if(u.team == team){` check -- the team
	# comparison runs when the recorded action is
	# executed, against the team_id param, and only then
	# calls kill_unit -- so a unit that switched teams by
	# the time the action runs is spared, exactly as the
	# Java comment says.
	var builds: Array = []
	if building_tree_objects != null:
		builds = building_tree_objects as Array
	plans.clear()
	var killed_cores: Array = []
	var destroy_payload_calls: Array = []
	var scheduled_kills: Array = []
	var add_plan_calls: Array = []
	var schedule_index := 0
	for b in builds:
		if not b is Dictionary:
			continue
		if bool(b.get("privileged", false)):
			continue
		var build_pos := int(b.get("pos", 0))
		if bool(b.get("is_core", false)):
			kill_build.call(build_pos)
			killed_cores.append(build_pos)
		else:
			var chance_roll := 0.0
			if schedule_index < chance_rolls.size():
				chance_roll = float(chance_rolls[schedule_index])
			var kill_delay := 0.0
			if schedule_index < kill_delays.size():
				kill_delay = float(kill_delays[schedule_index])
			schedule_index += 1
			var scheduled: Dictionary = source_team_data_schedule_derelict_state(build_pos, bool(b.get("has_unit_payload", false)), derelict_buffer, destroy_payload, chance_roll, kill_delay, time_run, kill_build, add_plan)
			destroy_payload_calls.append_array(scheduled.get("destroy_payload_calls", []))
			var scheduled_kill: Variant = scheduled.get("scheduled_kill", null)
			if scheduled_kill != null:
				scheduled_kills.append(scheduled_kill)
			add_plan_calls.append_array(scheduled.get("add_plan_calls", []))
	var finished: Dictionary = source_team_data_finish_schedule_derelict_state(derelict_buffer, set_teams)
	var scheduled_unit_kills: Array = []
	for i in units.size():
		var unit: Variant = units[i]
		if not unit is Dictionary:
			continue
		var unit_dict: Dictionary = unit
		var delay := 0.0
		if i < unit_delays.size():
			delay = float(unit_delays[i])
		time_run.call(delay, func() -> void:
			if int(unit_dict.get("team_id", -1)) == team_id:
				kill_unit.call(unit_dict)
		)
		scheduled_unit_kills.append({"delay": delay, "unit": unit_dict})
	return {"builds": builds, "plans": plans, "derelict_buffer": derelict_buffer, "killed_cores": killed_cores, "destroy_payload_calls": destroy_payload_calls, "scheduled_kills": scheduled_kills, "add_plan_calls": add_plan_calls, "set_teams_calls": finished.get("set_teams_calls", []), "scheduled_unit_kills": scheduled_unit_kills}


static func source_team_data_time_destroy_state(x: float, y: float, range: float, building_tree_objects: Variant, derelict_buffer: Array, chance_rolls: Array, kill_delays: Array, sector: Variant, circle_tiles: Array, tilesize: float, destroy_payload: Callable, time_run: Callable, kill_build: Callable, add_plan: Callable, set_teams: Callable, set_floor: Callable) -> Dictionary:
	# TeamData.timeDestroy (Teams.java:362-394):
	# `public void timeDestroy(float x, float y, float range){`
	# `var builds = new Seq<Building>();`
	# `if(buildingTree != null){`
	# `buildingTree.intersect(x - range, y - range, range * 2f, range * 2f, builds);`
	# `}`
	# `for(var build : builds){`
	# `if(!build.block.privileged && build.within(x, y, range) && !cores.contains(c -> c.within(build, range))){`
	# `scheduleDerelict(build);`
	# `}`
	# `}`
	# `finishScheduleDerelict();`
	# `var sector = state.getSector();`
	# `if(sector != null){`
	# `boolean any = false;`
	# `for(var entry : sector.planet.sectorCaptureReplacements){`
	# `if(indexer.isBlockPresent(entry.key)){`
	# `any = true;`
	# `}`
	# `}`
	# `if(any){`
	# `Geometry.circle(World.toTile(x), World.toTile(y), world.width(), world.height(), Mathf.round(range / tilesize), (tx, ty) -> {`
	# `Tile t = world.rawTile(tx, ty);`
	# `Block result = sector.planet.sectorCaptureReplacements.get(t.floor());`
	# `if(result != null && !cores.contains(c -> c.within(t, range))){`
	# `t.setFloor(result.asFloor());`
	# `}`
	# `});`
	# `}`
	# `}`
	# `}`
	# buildingTree is the same @Nullable QuadTree as in
	# destroyToDerelict above: the intersected objects
	# arrive as the building_tree_objects param (null when
	# the tree is null -- the `x - range, y - range,
	# range * 2f, range * 2f` rect is the QuadTree's job,
	# precomputed by the caller). Each build record is a
	# Dictionary {"pos": int, "privileged": bool,
	# "within_range": bool, "near_core": bool,
	# "has_unit_payload": bool} -- `build.within(x, y,
	# range)` and `cores.contains(c -> c.within(build,
	# range))` arrive as the precomputed "within_range" /
	# "near_core" flags (positions are live world data, not
	# ported). Qualifying builds go through the
	# scheduleDerelict callee (chance_rolls / kill_delays
	# in schedule order, missing entries default to 0.0),
	# then the finish callee flushes the buffer.
	# `state.getSector()` arrives as the sector param (null
	# when there is no sector, else a Dictionary
	# {"replacements": Dictionary floor_key -> result,
	# "present_keys": Array}); `sector.planet.
	# sectorCaptureReplacements` is the "replacements"
	# Dictionary, and `indexer.isBlockPresent(entry.key)`
	# arrives as the precomputed "present_keys" Array --
	# `any` is true when any replacement key is present.
	# `Geometry.circle(...)` is an engine API, not ported:
	# the iterated tiles arrive as the circle_tiles param
	# (records {"tx": int, "ty": int, "floor": Variant,
	# "near_core": bool} -- `world.rawTile(tx, ty)` is the
	# tile record itself, `cores.contains(c -> c.within(t,
	# range))` is its precomputed "near_core" flag), and
	# the `Mathf.round(range / tilesize)` radius arrives
	# via the tilesize param (computed here, only when a
	# replacement is present). `t.setFloor(result.asFloor())`
	# arrives as the set_floor Callable (tile, result);
	# every floor change is recorded in the frame.
	var builds: Array = []
	if building_tree_objects != null:
		builds = building_tree_objects as Array
	var destroy_payload_calls: Array = []
	var scheduled_kills: Array = []
	var add_plan_calls: Array = []
	var schedule_index := 0
	for build in builds:
		if not build is Dictionary:
			continue
		if bool(build.get("privileged", false)):
			continue
		if not bool(build.get("within_range", false)):
			continue
		if bool(build.get("near_core", false)):
			continue
		var chance_roll := 0.0
		if schedule_index < chance_rolls.size():
			chance_roll = float(chance_rolls[schedule_index])
		var kill_delay := 0.0
		if schedule_index < kill_delays.size():
			kill_delay = float(kill_delays[schedule_index])
		schedule_index += 1
		var scheduled: Dictionary = source_team_data_schedule_derelict_state(int(build.get("pos", 0)), bool(build.get("has_unit_payload", false)), derelict_buffer, destroy_payload, chance_roll, kill_delay, time_run, kill_build, add_plan)
		destroy_payload_calls.append_array(scheduled.get("destroy_payload_calls", []))
		var scheduled_kill: Variant = scheduled.get("scheduled_kill", null)
		if scheduled_kill != null:
			scheduled_kills.append(scheduled_kill)
		add_plan_calls.append_array(scheduled.get("add_plan_calls", []))
	var finished: Dictionary = source_team_data_finish_schedule_derelict_state(derelict_buffer, set_teams)
	var has_sector := sector != null
	var any_replacement := false
	var circle_radius_tiles := 0
	var floor_changes: Array = []
	if has_sector:
		var replacements: Dictionary = (sector as Dictionary).get("replacements", {})
		var present_keys: Array = (sector as Dictionary).get("present_keys", [])
		for key in replacements.keys():
			if present_keys.has(key):
				any_replacement = true
				break
		if any_replacement:
			circle_radius_tiles = int(round(range / tilesize))
			for tile in circle_tiles:
				if not tile is Dictionary:
					continue
				var result: Variant = replacements.get(tile.get("floor", null), null)
				if result != null and not bool(tile.get("near_core", false)):
					set_floor.call(tile, result)
					floor_changes.append({"tx": int(tile.get("tx", 0)), "ty": int(tile.get("ty", 0)), "floor": result})
	return {"builds": builds, "derelict_buffer": derelict_buffer, "destroy_payload_calls": destroy_payload_calls, "scheduled_kills": scheduled_kills, "add_plan_calls": add_plan_calls, "set_teams_calls": finished.get("set_teams_calls", []), "has_sector": has_sector, "any_replacement_present": any_replacement, "circle_radius_tiles": circle_radius_tiles, "floor_changes": floor_changes}


static func source_teams_update_active_state(teams_state: Dictionary, team_id: int) -> Dictionary:
	# Teams.updateActive (Teams.java:135-141):
	# `public void updateActive(Team team){`
	# `TeamData data = get(team);`
	# `//register in active list if needed`
	# `if(data.active() && !active.contains(data)){`
	# `active.add(data);`
	# `updateEnemies();`
	# `}`
	# `}`
	# The get() call is INSIDE this group (an internal
	# self-reference, not an outside expr): it may create
	# the team's entry, so teams_state is in/out.
	# data.active() is TeamData.active() (Teams.java:446-448),
	# already the exact_expr of N2074/N2075 -- the file's
	# _teams_active helper IS that callee, called here as
	# evidence only, not re-ported. `active.contains(data)`
	# is the active list (team ids) has-check; `active.add(data)`
	# appends the team id; `updateEnemies()` is the file's
	# _teams_update_enemies helper, called as evidence only,
	# not re-ported. The `active_changed` flag records
	# whether the guard branch ran; enemies_by_team is the
	# current map when the branch did not run.
	var got: Dictionary = source_teams_get_state(teams_state, team_id)
	var data: Dictionary = got.get("team_data", {})
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
	return {"active_changed": active_changed, "active": teams_state.get("active", []), "enemies_by_team": enemies_by_team, "teams_state": teams_state}


static func source_teams_default_constructor_state(teams_state: Dictionary, crux_team_id: int) -> Dictionary:
	# Teams() (Teams.java:34-36):
	# `public Teams(){`
	# `active.add(get(Team.crux));`
	# `}`
	# The default constructor seeds the active list with
	# the crux team. Team.crux is a Team const (not ported),
	# so it arrives as the explicit crux_team_id param
	# (crux id 2, Team.java:41, per the file header
	# comment). The get() call is INSIDE this group (an
	# internal self-reference, not an outside expr): it may
	# create the crux entry, so teams_state is in/out.
	# Java Seq.add appends unconditionally -- the crux id
	# is appended even if already present, exactly as the
	# Java ctor does on a fresh Teams (empty active).
	var got: Dictionary = source_teams_get_state(teams_state, crux_team_id)
	var data: Dictionary = got.get("team_data", {})
	var active: Array = teams_state.get("active", [])
	active.append(crux_team_id)
	teams_state["active"] = active
	return {"team_data": data, "active": teams_state.get("active", []), "teams_state": teams_state}


static func source_teams_destroy_payload_state(build: Variant, has_unit_payload: bool, take_payload: Callable, dump_payload: Callable, kill_unit: Callable) -> Dictionary:
	# Teams.destroyPayload (Teams.java:483-488):
	# `@Remote(called = Loc.server, unreliable = true)`
	# `public static void destroyPayload(Building build){`
	# `if(build != null && build.getPayload() instanceof UnitPayload && build.takePayload() instanceof UnitPayload unit){`
	# `unit.dump();`
	# `unit.unit.killed();`
	# `}`
	# `}`
	# @Remote is transport metadata (Call.destroyPayload),
	# NOT behavior: the annotation is recorded in the
	# register note only, never as a distinguishing expr
	# (main-thread decision 2026-11-22, batch 25 slot 3).
	# Building is not ported: it arrives as the build
	# Variant (null when absent). `build.getPayload()
	# instanceof UnitPayload` arrives as the
	# has_unit_payload bool. takePayload() returns the
	# same payload getPayload() saw, so its `instanceof
	# UnitPayload unit` is the payload-is-Dictionary
	# check below -- the taken payload must be a record
	# with a "unit" key. `unit.dump()` arrives as the
	# dump_payload Callable (payload); `unit.unit.killed()`
	# arrives as the kill_unit Callable (unit). No packet
	# is ever sent; the frame records which payload was
	# destroyed, which payloads were dumped and which
	# units were killed.
	var destroyed_payload: Variant = null
	var dumped_payloads: Array = []
	var killed_units: Array = []
	if build != null and has_unit_payload:
		var payload: Variant = take_payload.call(build)
		if payload is Dictionary and (payload as Dictionary).has("unit"):
			destroyed_payload = payload
			dump_payload.call(payload)
			dumped_payloads.append(payload)
			var unit: Variant = (payload as Dictionary).get("unit", null)
			kill_unit.call(unit)
			killed_units.append(unit)
	return {"destroyed_payload": destroyed_payload, "dumped_payloads": dumped_payloads, "killed_units": killed_units}
