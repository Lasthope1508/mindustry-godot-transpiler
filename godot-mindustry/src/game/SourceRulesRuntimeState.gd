extends RefCounted
class_name SourceRulesRuntimeState

const source_rules_defaults := preload("res://src/game/SourceRulesDefaults.gd")

# Rules.mode() — Rules.java:249-261:
#     /** Returns the gamemode that best fits these rules. */
#     public Gamemode mode(){
#         if(pvp){
#             return Gamemode.pvp;
#         }else if(editor){
#             return Gamemode.editor;
#         }else if(attackMode){
#             return Gamemode.attack;
#         }else if(infiniteResources){
#             return Gamemode.sandbox;
#         }else{
#             return Gamemode.survival;
#         }
#     }
# The Gamemode enum is returned as its String name -- precedent
# N2454: GameState `state` travels through GD as `state_name`
# ("paused"/"playing"/"menu"). The priority order is the trap:
# pvp wins over every other flag set at the same time, so the
# branches must be checked in Java order and must not be
# reordered (checking infiniteResources first would return
# "sandbox" for an attack game). A missing flag means the Java
# field default (false): all four booleans default to false
# (pvp :41, editor :51, attackMode :49, infiniteResources :27),
# so an empty rules state is survival.
# rules_state shape: {"pvp": bool, "editor": bool,
#   "attackMode": bool, "infiniteResources": bool}.
static func source_rules_mode_state(rules_state: Dictionary) -> Dictionary:
	if bool(rules_state.get("pvp", false)):
		return {"mode": "pvp"}
	if bool(rules_state.get("editor", false)):
		return {"mode": "editor"}
	if bool(rules_state.get("attackMode", false)):
		return {"mode": "attack"}
	if bool(rules_state.get("infiniteResources", false)):
		return {"mode": "sandbox"}
	return {"mode": "survival"}


# Rules.buildRadius(Team team) — Rules.java:267-269:
#     public float buildRadius(Team team){
#         return !teams.get(team).protectCores ? 0f :
#             enemyCoreBuildRadius +
#             teams.get(team).extraCoreBuildRadius;
#     }
# The global enemyCoreBuildRadius defaults to 400f (Rules.java:123)
# and the per-team protectCores defaults to true (Rules.java:324,
# TeamRules) with extraCoreBuildRadius defaulting to 0f (:371).
# TRAP: protectCores=false blocks everything -- the ternary
# returns 0f without adding anything, however large the extra
# is. A port that adds first and checks protect later is wrong.
# TRAP: no clamp -- unlike N2459 unitHealth there is no Math.max
# here, so a negative extra passes through (400 + -50 = 350).
# rules_state shape: {"enemyCoreBuildRadius": float,
#   "teams": {team_id: {"protectCores": bool,
#   "extraCoreBuildRadius": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_rules_build_radius_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var enemy_core_build_radius: float = float(rules_state.get("enemyCoreBuildRadius", source_rules_defaults.ENEMY_CORE_BUILD_RADIUS_DEFAULT))
	var protect_cores: bool = true
	var extra_core_build_radius: float = 0.0
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		protect_cores = bool(team_rules.get("protectCores", true))
		extra_core_build_radius = float(team_rules.get("extraCoreBuildRadius", 0.0))
	if not protect_cores:
		return {"build_radius": 0.0}
	return {"build_radius": enemy_core_build_radius + extra_core_build_radius}


# Rules.unitBuildSpeed(Team team) — Rules.java:271-273:
#     return unitBuildSpeedMultiplier *
#         teams.get(team).unitBuildSpeedMultiplier;
# The global multiplier defaults to 1f (Rules.java:81) and the
# per-team multiplier defaults to 1f (Rules.java:353, TeamRules).
# TRAP: there is NO floor here -- unlike N2459 unitHealth, which
# returns Math.max(product, 0.000001f), a product of 0 returns
# 0.0 and a negative product passes through negative. A port
# that copies the N2459 floor into this function is wrong.
# GDScript float is 64-bit vs Java float 32-bit: products are
# compared with a tolerance in the proof, never == on large
# float products.
# rules_state shape: {"unitBuildSpeedMultiplier": float,
#   "teams": {team_id: {"unitBuildSpeedMultiplier": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_rules_unit_build_speed_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var global_multiplier: float = float(rules_state.get("unitBuildSpeedMultiplier", source_rules_defaults.UNIT_BUILD_SPEED_MULTIPLIER_DEFAULT))
	var team_multiplier: float = source_rules_defaults.UNIT_BUILD_SPEED_MULTIPLIER_DEFAULT
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		team_multiplier = float(team_rules.get("unitBuildSpeedMultiplier", source_rules_defaults.UNIT_BUILD_SPEED_MULTIPLIER_DEFAULT))
	return {"unit_build_speed": global_multiplier * team_multiplier}


# Rules.unitCost(Team team) — Rules.java:275-276:
#     return unitCostMultiplier * teams.get(team).unitCostMultiplier;
# The global multiplier defaults to 1f (Rules.java:83) and the
# per-team multiplier defaults to 1f (Rules.java:361, TeamRules).
# Unit factories pay this multiplier on every consumer (UnitFactory,
# Reconstructor and UnitAssembler all set each consumer's multiplier
# to b -> state.rules.unitCost(b.team)).
# rules_state shape: {"unitCostMultiplier": float,
#   "teams": {team_id: {"unitCostMultiplier": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_unit_cost_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var global_multiplier: float = float(rules_state.get("unitCostMultiplier", source_rules_defaults.UNIT_COST_MULTIPLIER_DEFAULT))
	var team_multiplier: float = source_rules_defaults.UNIT_COST_MULTIPLIER_DEFAULT
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		team_multiplier = float(team_rules.get("unitCostMultiplier", source_rules_defaults.UNIT_COST_MULTIPLIER_DEFAULT))
	return {"unit_cost": global_multiplier * team_multiplier}


# Rules.unitDamage(Team team) — Rules.java:279-281:
#     return unitDamageMultiplier * teams.get(team).unitDamageMultiplier;
# The global multiplier defaults to 1f (Rules.java:85) and the
# per-team multiplier defaults to 1f (Rules.java:355, TeamRules).
# TRAP: there is NO floor here -- unlike N2459 unitHealth, which
# returns Math.max(product, 0.000001f), a product of 0 returns
# 0.0 and a negative product passes through negative. A port
# that copies the N2459 floor into this function is wrong.
# GDScript float is 64-bit vs Java float 32-bit: products are
# compared with a tolerance in the proof, never == on large
# float products.
# rules_state shape: {"unitDamageMultiplier": float,
#   "teams": {team_id: {"unitDamageMultiplier": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_rules_unit_damage_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var global_multiplier: float = float(rules_state.get("unitDamageMultiplier", source_rules_defaults.UNIT_DAMAGE_MULTIPLIER_DEFAULT))
	var team_multiplier: float = source_rules_defaults.UNIT_DAMAGE_MULTIPLIER_DEFAULT
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		team_multiplier = float(team_rules.get("unitDamageMultiplier", source_rules_defaults.UNIT_DAMAGE_MULTIPLIER_DEFAULT))
	return {"unit_damage": global_multiplier * team_multiplier}


# Rules.unitHealth(Team team) — Rules.java:283-286:
#     public float unitHealth(Team team){
#         //a 0 here would be a very bad idea.
#         return Math.max(unitHealthMultiplier * teams.get(team).unitHealthMultiplier, 0.000001f);
#     }
# The global multiplier defaults to 1f (Rules.java:87) and the
# per-team multiplier defaults to 1f (Rules.java:363, TeamRules).
# TRAP: the floor is 0.000001, not 0 -- a product of 0 (or
# negative) still returns 0.000001, exactly as the Java comment
# :284 says ("a 0 here would be a very bad idea"). A port that
# clamps to 0 is wrong. GDScript float is 64-bit vs Java float
# 32-bit: the floor literal is the same 0.000001, and products
# are compared with a tolerance in the proof, never == on large
# float products.
# rules_state shape: {"unitHealthMultiplier": float,
#   "teams": {team_id: {"unitHealthMultiplier": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_rules_unit_health_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var global_multiplier: float = float(rules_state.get("unitHealthMultiplier", source_rules_defaults.UNIT_HEALTH_MULTIPLIER_DEFAULT))
	var team_multiplier: float = source_rules_defaults.UNIT_HEALTH_MULTIPLIER_DEFAULT
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		team_multiplier = float(team_rules.get("unitHealthMultiplier", source_rules_defaults.UNIT_HEALTH_MULTIPLIER_DEFAULT))
	return {"unit_health": maxf(global_multiplier * team_multiplier, 0.000001)}


# GameState.rules — GameState.java:35:
#     /** The current game rules. */
#     public Rules rules = new Rules();
# Vars.state (Vars.java:271) is the global GameState holding it. The
# rules object is live and mutable: it is created once per game with
# the Rules defaults (unitCostMultiplier 1f, Rules.java:83; teams a
# fresh TeamRules, Rules.java:29) and every reader — the drill tick,
# the unit factories' multiplier callbacks — reads the same object.
# rules_state shape: {"unitCostMultiplier": float,
#   "teams": {team_id: {"unitCostMultiplier": float}}}.
# A missing or empty rules state means the game has no rules yet, so
# this returns the Java `new Rules()` defaults; an existing rules
# state is returned as-is, the same Dictionary object, so mutations
# through it stay live on the game.
static func source_game_rules_state(rules_state: Variant) -> Dictionary:
	if rules_state is Dictionary and not (rules_state as Dictionary).is_empty():
		return {"rules": rules_state}
	return {"rules": {"unitCostMultiplier": source_rules_defaults.UNIT_COST_MULTIPLIER_DEFAULT, "teams": {}}}


# TeamComp.cheating() — TeamComp.java:17-19:
#     public boolean cheating(){
#         return team.rules().cheat;
#     }
# Team.rules() (Team.java:88-90) returns state.rules.teams.get(this);
# TeamRules.get (Rules.java:391-394) creates a fresh TeamRule when the
# team has none, and TeamRule.cheat (Rules.java:328, "If true, blocks
# don't require power or resources.") defaults to false. While a team
# cheats, its buildings' consumers are skipped and everything counts
# as valid (BuildingComp.java:1944-1945, "//everything is valid when
# cheating", `if(!block.hasConsumers || cheating()){`).
# rules_state shape: {"teams": {team_id: {"cheat": bool}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
# A missing team or a missing/empty rules state means the Java fresh
# TeamRule, so cheating is false.
static func source_team_cheating_state(rules_state: Variant, team_id: int) -> Dictionary:
	var cheat: bool = source_rules_defaults.TEAM_CHEAT_DEFAULT
	if rules_state is Dictionary:
		var teams: Dictionary = (rules_state as Dictionary).get("teams", {})
		var team_rules: Dictionary = {}
		if teams.has(team_id):
			team_rules = teams[team_id]
		elif teams.has(str(team_id)):
			team_rules = teams[str(team_id)]
		if not team_rules.is_empty():
			cheat = bool(team_rules.get("cheat", source_rules_defaults.TEAM_CHEAT_DEFAULT))
	return {"cheating": cheat}
