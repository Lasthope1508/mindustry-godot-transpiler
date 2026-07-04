# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/ReloadTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "ReloadTurret"
const JAVA_EXTENDS := "BaseTurret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "reload", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ReloadTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	var coolant_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var reload_value: float = float(_args[1] if _args.size() > 1 else 0.0)
	var coolant_amount: float = float(_args[2] if _args.size() > 2 else 0.0)
	var coolant_multiplier: float = float(_args[3] if _args.size() > 3 else 0.0)
	var booster_replace_called: bool = coolant_present
	var booster_replace_call: Dictionary = {}
	if booster_replace_called:
		booster_replace_call = {"call": "stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));", "stat": "Stat.booster", "reload": reload_value, "coolant_amount": coolant_amount, "coolant_multiplier": coolant_multiplier, "base": true, "consumes": "coolant::consumes"}
	return {"source_owner": "PortGame.source_reload_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "coolant_gate": "if(coolant != null){", "booster_replace_expr": "stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));", "coolant_present": coolant_present, "reload_value": reload_value, "coolant_amount": coolant_amount, "coolant_multiplier": coolant_multiplier, "super_set_stats_called": true, "booster_replace_called": booster_replace_called, "booster_replace_call": booster_replace_call}
