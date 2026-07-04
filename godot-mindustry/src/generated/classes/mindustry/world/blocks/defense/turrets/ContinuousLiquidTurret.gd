# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "ContinuousLiquidTurret"
const JAVA_EXTENDS := "ContinuousTurret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "ammoTypes", "type": "ObjectMap"}, {"modifiers": ["public"], "name": "liquidConsumed", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ContinuousLiquidTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "ammo", "parameters": [{"name": "objects", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_ammo_0(_args: Array = []) -> Variant:
	var objects: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	return {"source_owner": "PortGame.source_continuous_liquid_turret_ammo_state", "field": "public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();", "comment": "/** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */", "method": "public void ammo(Object... objects){", "assignment_expr": "ammoTypes = ObjectMap.of(objects);", "objects": objects, "ammo_types_after": objects}

func java_method_setStats_1(_args: Array = []) -> Variant:
	var ammo_types: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var liquid_consumed: float = float(_args[1] if _args.size() > 1 else 0.0)
	var stat_liquid_consumed_updates: Array = []
	for entry in ammo_types:
		var entry_dict: Dictionary = entry if entry is Dictionary else {}
		stat_liquid_consumed_updates.append({"call": "b.statLiquidConsumed = liquidConsumed", "liquid": entry_dict.get("liquid", null), "bullet": entry_dict.get("bullet", null), "stat_liquid_consumed": liquid_consumed})
	var ammo_values_call: Dictionary = {"call": "StatValues.ammo(ammoTypes)", "ammo_types": ammo_types}
	var stats_replace_call: Dictionary = {"call": "stats.replace(Stat.ammo, StatValues.ammo(ammoTypes));", "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {"source_owner": "PortGame.source_continuous_liquid_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "mirror_comment": "//mirror stats onto each bullet (purely visual)", "stat_liquid_consumed_expr": "ammoTypes.each((l, b) -> b.statLiquidConsumed = liquidConsumed);", "stats_replace_expr": "stats.replace(Stat.ammo, StatValues.ammo(ammoTypes));", "ammo_types": ammo_types, "liquid_consumed": liquid_consumed, "super_set_stats_called": true, "stat_liquid_consumed_updates": stat_liquid_consumed_updates, "stats_replace_called": true, "ammo_values_call": ammo_values_call, "stats_replace_call": stats_replace_call}

func java_method_init_2(_args: Array = []) -> Variant:
	return null
