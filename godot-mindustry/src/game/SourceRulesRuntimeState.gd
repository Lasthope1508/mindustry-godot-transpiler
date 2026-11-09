extends RefCounted
class_name SourceRulesRuntimeState

const source_rules_defaults := preload("res://src/game/SourceRulesDefaults.gd")

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
