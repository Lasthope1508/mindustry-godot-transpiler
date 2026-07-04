# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/ContinuousTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "ContinuousTurret"
const JAVA_EXTENDS := "Turret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "shootType", "type": "BulletType"}, {"modifiers": ["public"], "name": "aimChangeSpeed", "type": "float"}, {"modifiers": ["public"], "name": "scaleDamageEfficiency", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ContinuousTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	var shoot_type: Variant = _args[0] if _args.size() > 0 else null
	var object_map_call: Dictionary = {"call": "ObjectMap.of(this, shootType)", "this": "ContinuousTurret", "shoot_type": shoot_type}
	var ammo_values_call: Dictionary = {"call": "StatValues.ammo(ObjectMap.of(this, shootType))", "object_map_call": object_map_call}
	var stats_add_call: Dictionary = {"call": "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));", "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {"source_owner": "PortGame.source_continuous_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "stats_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));", "remove_reload_expr": "stats.remove(Stat.reload);", "remove_inaccuracy_expr": "stats.remove(Stat.inaccuracy);", "shoot_type": shoot_type, "super_set_stats_called": true, "stats_add_called": true, "remove_reload_called": true, "remove_inaccuracy_called": true, "object_map_call": object_map_call, "ammo_values_call": ammo_values_call, "stats_add_call": stats_add_call}
