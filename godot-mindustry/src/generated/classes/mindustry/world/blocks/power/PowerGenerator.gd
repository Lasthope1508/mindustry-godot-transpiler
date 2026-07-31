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

func java_method_getDisplayedPowerProduction_0(_args: Array = []) -> Variant:
	var power_production: float = float(_args[0] if _args.size() > 0 else 0.0)
	var displayed_power_production: float = power_production
	return {"source_owner": "port_game.source_power_generator_displayed_power_production_state", "source": "core/src/mindustry/world/blocks/power/PowerGenerator.java", "field": "public float powerProduction;", "method": "public float getDisplayedPowerProduction(){", "return_power_production": "return powerProduction;", "schematic_method": "public float powerProduction(){", "schematic_sum_source": "return tiles.sumf(s -> s.block instanceof PowerGenerator p ? p.getDisplayedPowerProduction() : 0f);", "power_production": power_production, "displayed_power_production": displayed_power_production}

func java_method_icons_1(_args: Array = []) -> Variant:
	return null

func java_method_load_2(_args: Array = []) -> Variant:
	return null

func java_method_setStats_3(_args: Array = []) -> Variant:
	return null

func java_method_setBars_4(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_5(_args: Array = []) -> Variant:
	return null

func java_method_outputsItems_6(_args: Array = []) -> Variant:
	return null
