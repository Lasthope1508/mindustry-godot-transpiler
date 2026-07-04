# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/PowerTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "PowerTurret"
const JAVA_EXTENDS := "Turret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "shootType", "type": "BulletType"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PowerTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [{"name": "margin", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	var shoot_type: Variant = _args[0] if _args.size() > 0 else null
	var object_map_call: Dictionary = {"call": "ObjectMap.of(this, shootType)", "owner": "this", "shoot_type": shoot_type}
	var ammo_values_call: Dictionary = {"call": "StatValues.ammo(ObjectMap.of(this, shootType))", "object_map_call": object_map_call}
	var stats_add_call: Dictionary = {"call": "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));", "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {"source_owner": "PortGame.source_power_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "stats_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));", "shoot_type": shoot_type, "super_set_stats_called": true, "stats_add_called": true, "object_map_call": object_map_call, "ammo_values_call": ammo_values_call, "stats_add_call": stats_add_call}

func java_method_limitRange_1(_args: Array = []) -> Variant:
	var shoot_type: Variant = _args[0] if _args.size() > 0 else null
	var margin: float = float(_args[1] if _args.size() > 1 else 0.0)
	var limit_range_call: Dictionary = {"call": "limitRange(shootType, margin);", "shoot_type": shoot_type, "margin": margin}
	return {"source_owner": "PortGame.source_power_turret_limit_range_state", "method": "public void limitRange(float margin){", "dispatch_expr": "limitRange(shootType, margin);", "shoot_type": shoot_type, "margin": margin, "limit_range_called": true, "limit_range_call": limit_range_call}
