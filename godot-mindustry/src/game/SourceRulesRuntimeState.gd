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


# Rules.hasEnv(int env) — Rules.java:263-265:
#     public boolean hasEnv(int env){
#         return (this.env & env) != 0;
#     }
# The env field defaults to Vars.defaultEnv (Rules.java:163;
# Vars.java:65: Env.terrestrial | Env.spores | Env.groundOil |
# Env.groundWater | Env.oxygen). With the Env bits (Env.java:
# terrestrial=1, space=1<<1, spores=1<<3, groundOil=1<<5,
# groundWater=1<<6, oxygen=1<<7) the default is
# 1|8|32|64|128 = 233 -- note space (2) is NOT in it.
# TRAP: this is an ANY-overlap check, not ALL-bits -- a
# combined flag is true when ANY one of its bits is set
# (flag 2|8=10 is true on the default env because spores=8
# is set, even though space=2 is not). A port that checks
# (env & flag) == flag is wrong.
# TRAP: flag 0 is always false -- 0 & anything is 0, so
# hasEnv(0) is false for every env. A port that returns the
# raw AND value instead of comparing != 0 breaks the bool
# shape here.
# The Java parameter is also named `env` and shadows the
# field; GD names the parameter env_flag and the field
# travels as the "env" key. A missing "env" key means the
# Java field default. No const exists for 233 in
# SourceRulesDefaults.gd, so the literal is used with the
# Vars.java:65 derivation above.
# rules_state shape: {"env": int}.
static func source_rules_has_env_state(rules_state: Dictionary, env_flag: int) -> Dictionary:
	var env: int = int(rules_state.get("env", 233))
	return {"has_env": (env & env_flag) != 0}


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


# Rules.unitMineSpeed(Team team) — Rules.java:292-294:
#     public float unitMineSpeed(Team team){
#         return unitMineSpeedMultiplier *
#             teams.get(team).unitMineSpeedMultiplier;
#     }
# The global multiplier defaults to 1f (Rules.java:91) and the
# per-team multiplier defaults to 1f (Rules.java:359, TeamRules).
# TRAP: there is NO floor here -- unlike N2459 unitHealth, which
# returns Math.max(product, 0.000001f), a product of 0 returns
# 0.0 and a negative product passes through negative. A port
# that copies the N2459 floor into this function is wrong.
# GDScript float is 64-bit vs Java float 32-bit: products are
# compared with a tolerance in the proof, never == on large
# float products.
# rules_state shape: {"unitMineSpeedMultiplier": float,
#   "teams": {team_id: {"unitMineSpeedMultiplier": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_rules_unit_mine_speed_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var global_multiplier: float = float(rules_state.get("unitMineSpeedMultiplier", source_rules_defaults.UNIT_MINE_SPEED_MULTIPLIER_DEFAULT))
	var team_multiplier: float = source_rules_defaults.UNIT_MINE_SPEED_MULTIPLIER_DEFAULT
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		team_multiplier = float(team_rules.get("unitMineSpeedMultiplier", source_rules_defaults.UNIT_MINE_SPEED_MULTIPLIER_DEFAULT))
	return {"unit_mine_speed": global_multiplier * team_multiplier}


# Rules.blockHealth(Team team) — Rules.java:296-298:
#     public float blockHealth(Team team){
#         return blockHealthMultiplier *
#             teams.get(team).blockHealthMultiplier;
#     }
# The global multiplier defaults to 1f (Rules.java:111) and the
# per-team multiplier defaults to 1f (Rules.java:365, TeamRules).
# TRAP: there is NO floor here -- unlike N2459 unitHealth, which
# returns Math.max(product, 0.000001f), a product of 0 returns
# 0.0 and a negative product passes through negative. A port
# that copies the N2459 floor into this function is wrong.
# GDScript float is 64-bit vs Java float 32-bit: products are
# compared with a tolerance in the proof, never == on large
# float products.
# rules_state shape: {"blockHealthMultiplier": float,
#   "teams": {team_id: {"blockHealthMultiplier": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_rules_block_health_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var global_multiplier: float = float(rules_state.get("blockHealthMultiplier", source_rules_defaults.BLOCK_HEALTH_MULTIPLIER_DEFAULT))
	var team_multiplier: float = source_rules_defaults.BLOCK_HEALTH_MULTIPLIER_DEFAULT
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		team_multiplier = float(team_rules.get("blockHealthMultiplier", source_rules_defaults.BLOCK_HEALTH_MULTIPLIER_DEFAULT))
	return {"block_health": global_multiplier * team_multiplier}


# Rules.blockDamage(Team team) — Rules.java:299-301:
#     public float blockDamage(Team team){
#         return blockDamageMultiplier *
#             teams.get(team).blockDamageMultiplier;
#     }
# The global multiplier defaults to 1f (Rules.java:113) and the
# per-team multiplier defaults to 1f (Rules.java:367, TeamRules).
# TRAP: there is NO floor here -- unlike N2459 unitHealth, which
# returns Math.max(product, 0.000001f), a product of 0 returns
# 0.0 and a negative product passes through negative. A port
# that copies the N2459 floor into this function is wrong.
# GDScript float is 64-bit vs Java float 32-bit: products are
# compared with a tolerance in the proof, never == on large
# float products.
# rules_state shape: {"blockDamageMultiplier": float,
#   "teams": {team_id: {"blockDamageMultiplier": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_rules_block_damage_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var global_multiplier: float = float(rules_state.get("blockDamageMultiplier", source_rules_defaults.BLOCK_DAMAGE_MULTIPLIER_DEFAULT))
	var team_multiplier: float = source_rules_defaults.BLOCK_DAMAGE_MULTIPLIER_DEFAULT
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		team_multiplier = float(team_rules.get("blockDamageMultiplier", source_rules_defaults.BLOCK_DAMAGE_MULTIPLIER_DEFAULT))
	return {"block_damage": global_multiplier * team_multiplier}


# Rules.buildSpeed(Team team) — Rules.java:303-305:
#     public float buildSpeed(Team team){
#         return buildSpeedMultiplier *
#             teams.get(team).buildSpeedMultiplier;
#     }
# The global multiplier defaults to 1f (Rules.java:117) and the
# per-team multiplier defaults to 1f (Rules.java:369, TeamRules).
# TRAP: there is NO floor here -- unlike N2459 unitHealth, which
# returns Math.max(product, 0.000001f), a product of 0 returns
# 0.0 and a negative product passes through negative. A port
# that copies the N2459 floor into this function is wrong.
# TRAP: do NOT reuse UNIT_BUILD_SPEED_MULTIPLIER_DEFAULT, which
# belongs to N2464 unitBuildSpeed (a different method); this
# slice uses the new const BUILD_SPEED_MULTIPLIER_DEFAULT.
# GDScript float is 64-bit vs Java float 32-bit: products are
# compared with a tolerance in the proof, never == on large
# float products.
# rules_state shape: {"buildSpeedMultiplier": float,
#   "teams": {team_id: {"buildSpeedMultiplier": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_rules_build_speed_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var global_multiplier: float = float(rules_state.get("buildSpeedMultiplier", source_rules_defaults.BUILD_SPEED_MULTIPLIER_DEFAULT))
	var team_multiplier: float = source_rules_defaults.BUILD_SPEED_MULTIPLIER_DEFAULT
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		team_multiplier = float(team_rules.get("buildSpeedMultiplier", source_rules_defaults.BUILD_SPEED_MULTIPLIER_DEFAULT))
	return {"build_speed": global_multiplier * team_multiplier}


# Rules.isBanned(Block block) — Rules.java:307-309:
#     public boolean isBanned(Block block){
#         return blockWhitelist != bannedBlocks.contains(block);
#     }
# blockWhitelist defaults to false (Rules.java:145) and
# bannedBlocks defaults to an empty ObjectSet<Block> (:181).
# TRAP: the whitelist INVERTS the answer -- with the whitelist
# on, a block IN the set is allowed (false) and a block NOT in
# the set is banned (true); with an empty set and the whitelist
# on, EVERY block is banned. A port that reads isBanned as "is
# in the set" (== instead of !=) is wrong in both whitelist
# cases. The block travels as its String name -- precedent N2460
# GameStats.getPlaced (SourceGameStatsRuntimeState
# source_game_stats_get_placed_state(stats_state, block:
# String)), because Java keys the set by Block object and GD keys
# by name.
# rules_state shape: {"blockWhitelist": bool,
#   "bannedBlocks": Array[String]}.
static func source_rules_is_banned_state(rules_state: Dictionary, block: String) -> Dictionary:
	var block_whitelist: bool = bool(rules_state.get("blockWhitelist", false))
	var banned_blocks: Array = rules_state.get("bannedBlocks", [])
	return {"is_banned": block_whitelist != banned_blocks.has(block)}


# Rules.isBanned(UnitType unit) — Rules.java:311-313:
#     public boolean isBanned(UnitType unit){
#         return unitWhitelist != bannedUnits.contains(unit);
#     }
# unitWhitelist defaults to false (Rules.java:147) and
# bannedUnits defaults to an empty ObjectSet<UnitType> (:183).
# TRAP: the whitelist INVERTS the answer -- with the whitelist
# on, a unit IN the set is allowed (false) and a unit NOT in
# the set is banned (true); with an empty set and the whitelist
# on, EVERY unit is banned. A port that reads isBanned as "is
# in the set" (== instead of !=) is wrong in both whitelist
# cases. TRAP: do not copy N2465's field names -- this method
# reads unitWhitelist/bannedUnits, not blockWhitelist/
# bannedBlocks. The unit travels as its String name -- same
# precedent as N2465 (Block by name, N2460 GameStats.getPlaced),
# because Java keys the set by UnitType object and GD keys by
# name.
# rules_state shape: {"unitWhitelist": bool,
#   "bannedUnits": Array[String]}.
static func source_rules_is_banned_unit_state(rules_state: Dictionary, unit: String) -> Dictionary:
	var unit_whitelist: bool = bool(rules_state.get("unitWhitelist", false))
	var banned_units: Array = rules_state.get("bannedUnits", [])
	return {"is_banned": unit_whitelist != banned_units.has(unit)}


# Rules.unitActivationDelay(Team team) — Rules.java:315-317:
#     public float unitActivationDelay(Team team){
#         return unitFactoryActivationDelay +
#             teams.get(team).unitFactoryActivationDelay;
#     }
# The global delay defaults to 0f (Rules.java:93) and the
# per-team delay defaults to 0f (Rules.java:351, TeamRule).
# TRAP: this ADDS -- unlike the sibling Rules multipliers
# (N2096 unitCost, N2462 unitDamage, N2464 unitBuildSpeed)
# which multiply, 2 + 3 is 5.0, not 6.0. A port that copies
# the multiply pattern into this function is wrong.
# TRAP: there is NO clamp here -- unlike N2459 unitHealth,
# which returns Math.max(product, 0.000001f), a negative
# team delay passes through (5 + -2 = 3.0). The const
# UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT already exists in
# SourceRulesDefaults.gd (:34), so no new const is needed.
# GDScript float is 64-bit vs Java float 32-bit: sums are
# compared with a tolerance in the proof, never == on large
# float sums.
# rules_state shape: {"unitFactoryActivationDelay": float,
#   "teams": {team_id: {"unitFactoryActivationDelay": float}}}.
# Team keys may be ints (built in GDScript) or strings (from JSON).
static func source_rules_unit_activation_delay_state(rules_state: Dictionary, team_id: int) -> Dictionary:
	var global_delay: float = float(rules_state.get("unitFactoryActivationDelay", source_rules_defaults.UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT))
	var team_delay: float = source_rules_defaults.UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT
	var teams: Dictionary = rules_state.get("teams", {})
	var team_rules: Dictionary = {}
	if teams.has(team_id):
		team_rules = teams[team_id]
	elif teams.has(str(team_id)):
		team_rules = teams[str(team_id)]
	if not team_rules.is_empty():
		team_delay = float(team_rules.get("unitFactoryActivationDelay", source_rules_defaults.UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT))
	return {"unit_activation_delay": global_delay + team_delay}


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


# TeamComp.closestCore() — TeamComp.java:31-34:
#     @Nullable
#     public CoreBuild closestCore(){
#         return state.teams.closestCore(x, y, team);
#     }
# A pure delegate: the callee Teams.closestCore
# (Teams.java:56-58, `return Geometry.findClosest(x, y,
# get(team).cores);`) is already ported (N2392,
# SourceTeamsRuntimeState.source_teams_closest_core_state),
# so its result arrives as the precomputed closest_core
# input (the precomputed-input precedent: N2477
# buildRotation takes the precomputed unit.rotation(),
# N2488 coloredName takes the precomputed localized()).
# The delegate never re-runs the Geometry.findClosest
# search and never touches the team's cores Array -- the
# cores and the find_closest Callable live in N2392. The
# @Nullable return passes through whole: null when no
# core is near, exactly as the callee returns it -- no
# default core, no empty-dict fallback, no guard. The
# `x` / `y` / `team` of the call are the entity's own
# fields (`@Import float x, y;` TeamComp.java:13, `Team
# team = Team.derelict;` :15), so they arrive as
# evidence inputs (team by id, the N2099 cheating
# precedent). Java order: cheating() (:17-19) comes
# before closestCore() (:31-34), so this function sits
# right after source_team_cheating_state (inFogTo :21-23
# and core() :27-29 are unported).
static func source_team_comp_closest_core_state(x: float, y: float, team_id: int, closest_core: Variant) -> Dictionary:
	return {"closest_core": closest_core}


# TeamComp.closestEnemyCore() — TeamComp.java:36-39:
#     @Nullable
#     public CoreBuild closestEnemyCore(){
#         return state.teams.closestEnemyCore(x, y, team);
#     }
# A pure delegate: the callee Teams.closestEnemyCore
# (Teams.java:39-55, scanning team.data().coreEnemies
# for the smallest Mathf.dst2) is already ported
# (N2354,
# SourceTeamsRuntimeState.source_teams_closest_enemy_core_state),
# so its result arrives as the precomputed closest_core
# input (the precomputed-input precedent: N2477
# buildRotation takes the precomputed unit.rotation(),
# N2488 coloredName takes the precomputed localized(),
# N2489 closestCore takes the precomputed callee
# result). The delegate never re-runs the enemy-core
# scan and never touches the team's coreEnemies -- the
# scan and the dst2 comparison live in N2354. The
# @Nullable return passes through whole: null when no
# enemy core is near, exactly as the callee returns it
# -- no default core, no empty-dict fallback, no guard.
# The `x` / `y` / `team` of the call are the entity's
# own fields (`@Import float x, y;` TeamComp.java:13,
# `Team team = Team.derelict;` :15), so they arrive as
# evidence inputs (team by id, the N2099 cheating
# precedent). Java order: closestCore() (:31-34) comes
# before closestEnemyCore() (:36-39), so this function
# sits right after source_team_comp_closest_core_state.
static func source_team_comp_closest_enemy_core_state(x: float, y: float, team_id: int, closest_core: Variant) -> Dictionary:
	return {"closest_core": closest_core}
