# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/ItemTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "ItemTurret"
const JAVA_EXTENDS := "Turret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "ammoTypes", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ItemTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "ammo", "parameters": [{"name": "objects", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [{"name": "margin", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_ammo_0(_args: Array = []) -> Variant:
	return null

func java_method_limitRange_1(_args: Array = []) -> Variant:
	var margin: float = 9.0
	var limit_range_call: Dictionary = {"call": "limitRange(9f);", "margin": margin}
	return {"source_owner": "PortGame.source_item_turret_limit_range_default_state", "method": "public void limitRange(){", "comment": "/** Limits bullet range to this turret's range value. */", "dispatch_expr": "limitRange(9f);", "margin": margin, "limit_range_called": true, "limit_range_call": limit_range_call}

func java_method_limitRange_2(_args: Array = []) -> Variant:
	var margin: float = float(_args[0] if _args.size() > 0 else 0.0)
	var ammo_entries: Array = _args[1] if _args.size() > 1 else []
	var limit_range_calls: Array = []
	for entry in ammo_entries:
		var entry_value: Variant = entry.get("value", null) if entry is Dictionary else entry
		limit_range_calls.append({"call": "limitRange(entry.value, margin);", "entry_value": entry_value, "margin": margin})
	return {"source_owner": "PortGame.source_item_turret_limit_range_entries_state", "method": "public void limitRange(float margin){", "comment": "/** Limits bullet range to this turret's range value. */", "loop_expr": "for(var entry : ammoTypes.entries()){", "dispatch_expr": "limitRange(entry.value, margin);", "margin": margin, "ammo_entries": ammo_entries, "limit_range_calls": limit_range_calls, "limit_range_call_count": limit_range_calls.size()}

func java_method_setStats_3(_args: Array = []) -> Variant:
	var ammo_types: Variant = _args[0] if _args.size() > 0 else null
	var name_value: String = str(_args[1] if _args.size() > 1 else "")
	var max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)
	var ammo_per_shot: float = float(_args[3] if _args.size() > 3 else 1.0)
	var ammo_capacity_divisor: float = maxf(ammo_per_shot, 1.0)
	var ammo_capacity: float = max_ammo / ammo_capacity_divisor
	var stats_item_capacity_remove_call: Dictionary = {"call": "stats.remove(Stat.itemCapacity);", "stat": "Stat.itemCapacity"}
	var ammo_values_call: Dictionary = {"call": "StatValues.ammo(ammoTypes, name)", "ammo_types": ammo_types, "name": name_value}
	var stats_ammo_add_call: Dictionary = {"call": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));", "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	var stats_ammo_capacity_add_call: Dictionary = {"call": "stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);", "stat": "Stat.ammoCapacity", "value": ammo_capacity, "unit": "StatUnit.shots"}
	return {"source_owner": "PortGame.source_item_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "stats_remove_expr": "stats.remove(Stat.itemCapacity);", "stats_ammo_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));", "stats_ammo_capacity_add_expr": "stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);", "ammo_types": ammo_types, "name_value": name_value, "max_ammo": max_ammo, "ammo_per_shot": ammo_per_shot, "ammo_capacity_divisor": ammo_capacity_divisor, "ammo_capacity": ammo_capacity, "super_set_stats_called": true, "stats_item_capacity_removed": true, "stats_ammo_added": true, "stats_ammo_capacity_added": true, "stats_item_capacity_remove_call": stats_item_capacity_remove_call, "ammo_values_call": ammo_values_call, "stats_ammo_add_call": stats_ammo_add_call, "stats_ammo_capacity_add_call": stats_ammo_capacity_add_call}

func java_method_setBars_4(_args: Array = []) -> Variant:
	return null

func java_method_init_5(_args: Array = []) -> Variant:
	return null
