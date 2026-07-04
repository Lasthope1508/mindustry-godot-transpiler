# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/LiquidTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "LiquidTurret"
const JAVA_EXTENDS := "Turret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "ammoTypes", "type": "ObjectMap"}, {"modifiers": ["public"], "name": "extinguish", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LiquidTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "ammo", "parameters": [{"name": "objects", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_ammo_0(_args: Array = []) -> Variant:
	var objects: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	return {"source_owner": "PortGame.source_liquid_turret_ammo_state", "field": "public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();", "comment": "/** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */", "method": "public void ammo(Object... objects){", "assignment_expr": "ammoTypes = ObjectMap.of(objects);", "objects": objects, "ammo_types_after": objects}

func java_method_setStats_1(_args: Array = []) -> Variant:
	var ammo_types: Variant = _args[0] if _args.size() > 0 else null
	var name_value: String = str(_args[1] if _args.size() > 1 else "")
	var ammo_values_call: Dictionary = {"call": "StatValues.ammo(ammoTypes, name)", "ammo_types": ammo_types, "name": name_value}
	var stats_add_call: Dictionary = {"call": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));", "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {"source_owner": "PortGame.source_liquid_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "stats_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));", "ammo_types": ammo_types, "name_value": name_value, "super_set_stats_called": true, "stats_added": true, "ammo_values_call": ammo_values_call, "stats_add_call": stats_add_call}

func java_method_init_2(_args: Array = []) -> Variant:
	return null
