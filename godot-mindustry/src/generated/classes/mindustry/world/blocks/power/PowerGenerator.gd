# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/power/PowerGenerator.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.power"
const JAVA_KIND := "class"
const JAVA_NAME := "PowerGenerator"
const JAVA_EXTENDS := "PowerDistributor"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "powerProduction", "type": "float"}, {"modifiers": ["public"], "name": "generationType", "type": "Stat"}, {"modifiers": ["public"], "name": "drawer", "type": "DrawBlock"}, {"modifiers": ["public"], "name": "explosionRadius", "type": "int"}, {"modifiers": ["public"], "name": "explosionDamage", "type": "int"}, {"modifiers": ["public"], "name": "explodeEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "explodeSound", "type": "Sound"}, {"modifiers": ["public"], "name": "explosionPuddles", "type": "int"}, {"modifiers": ["public"], "name": "explosionPuddleRange", "type": "float"}, {"modifiers": ["public"], "name": "explosionPuddleAmount", "type": "float"}, {"modifiers": ["public"], "name": "explosionPuddleLiquid", "type": "Liquid"}, {"modifiers": ["public"], "name": "explosionMinWarmup", "type": "float"}, {"modifiers": ["public"], "name": "explosionShake", "type": "float"}, {"modifiers": ["public"], "name": "explosionShakeDuration", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PowerGenerator", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getDisplayedPowerProduction", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
const source_power_generator_state := preload("res://src/game/SourcePowerGeneratorState.gd")

func java_method_getDisplayedPowerProduction_0(_args: Array = []) -> Variant:
	var power_production: float = float(_args[0] if _args.size() > 0 else 0.0)
	return source_power_generator_state.displayed_power_production_state(power_production)

func java_method_icons_1(_args: Array = []) -> Variant:
	var drawer_icons: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	return source_power_generator_state.icons_state(drawer_icons)

func java_method_load_2(_args: Array = []) -> Variant:
	var super_load_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var drawer_load_state: Dictionary = _args[1] if _args.size() > 1 and _args[1] is Dictionary else {}
	return source_power_generator_state.load_state(super_load_state, drawer_load_state)

func java_method_setStats_3(_args: Array = []) -> Variant:
	var power_production: float = float(_args[0] if _args.size() > 0 else 0.0)
	var super_set_stats_state: Dictionary = _args[1] if _args.size() > 1 and _args[1] is Dictionary else {}
	return source_power_generator_state.set_stats_state(power_production, super_set_stats_state)

func java_method_setBars_4(_args: Array = []) -> Variant:
	var has_power: bool = bool(_args[0] if _args.size() > 0 else false)
	var outputs_power: bool = bool(_args[1] if _args.size() > 1 else false)
	var super_set_bars_state: Dictionary = _args[2] if _args.size() > 2 and _args[2] is Dictionary else {}
	var power_production: float = float(_args[3] if _args.size() > 3 else 0.0)
	var time_scale: float = float(_args[4] if _args.size() > 4 else 0.0)
	var production_efficiency: float = float(_args[5] if _args.size() > 5 else 0.0)
	return source_power_generator_state.set_bars_state(has_power, outputs_power, super_set_bars_state, power_production, time_scale, production_efficiency)

func java_method_drawPlanRegion_5(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var list: Variant = _args[1] if _args.size() > 1 else null
	var drawer_draw_plan_state: Dictionary = _args[2] if _args.size() > 2 and _args[2] is Dictionary else {}
	return source_power_generator_state.draw_plan_region_state(plan, list, drawer_draw_plan_state)

func java_method_outputsItems_6(_args: Array = []) -> Variant:
	return source_power_generator_state.outputs_items_state()
