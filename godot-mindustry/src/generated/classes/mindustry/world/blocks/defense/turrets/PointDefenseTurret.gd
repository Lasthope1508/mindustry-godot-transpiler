# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/PointDefenseTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "PointDefenseTurret"
const JAVA_EXTENDS := "ReloadTurret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "timerTarget", "type": "int"}, {"modifiers": ["public"], "name": "retargetTime", "type": "float"}, {"modifiers": ["public"], "name": "baseRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "beamEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "hitEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "shootEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "shootSound", "type": "Sound"}, {"modifiers": ["public"], "name": "shootCone", "type": "float"}, {"modifiers": ["public"], "name": "bulletDamage", "type": "float"}, {"modifiers": ["public"], "name": "shootLength", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PointDefenseTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_TICK_RATE := source_time_defaults.TICK_RATE
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const SOURCE_TURRET_RELOAD_DEFAULT := source_turret_defaults.RELOAD_DEFAULT
const source_point_defense_turret_defaults := preload("res://src/game/SourcePointDefenseTurretDefaults.gd")
const SOURCE_POINT_DEFENSE_BULLET_DAMAGE_DEFAULT := source_point_defense_turret_defaults.BULLET_DAMAGE_DEFAULT

func java_method_icons_0(_args: Array = []) -> Variant:
	return null

func java_method_setStats_1(_args: Array = []) -> Variant:
	var bullet_damage: float = float(_args[0] if _args.size() > 0 else SOURCE_POINT_DEFENSE_BULLET_DAMAGE_DEFAULT)
	var reload_value: float = float(_args[1] if _args.size() > 1 else SOURCE_TURRET_RELOAD_DEFAULT)
	var reload_stat_rate: float = SOURCE_TICK_RATE / reload_value
	var reload_stat_call: Dictionary = {"call": "stats.add(Stat.reload, 60f / reload, StatUnit.perSecond);", "stat": "Stat.reload", "value": reload_stat_rate, "unit": "StatUnit.perSecond", "denominator": reload_value}
	var damage_stat_call: Dictionary = {"call": "stats.add(Stat.damage, bulletDamage, StatUnit.none);", "stat": "Stat.damage", "value": bullet_damage, "unit": "StatUnit.none"}
	return {"source_owner": "port_game.source_point_defense_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "reload_stat_expr": "stats.add(Stat.reload, 60f / reload, StatUnit.perSecond);", "damage_stat_expr": "stats.add(Stat.damage, bulletDamage, StatUnit.none);", "bullet_damage": bullet_damage, "reload_value": reload_value, "reload_stat_rate": reload_stat_rate, "super_set_stats_called": true, "reload_stat_call": reload_stat_call, "damage_stat_call": damage_stat_call}
