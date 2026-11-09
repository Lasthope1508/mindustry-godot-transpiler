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
