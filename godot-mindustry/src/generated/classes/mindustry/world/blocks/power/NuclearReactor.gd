# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/power/NuclearReactor.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.power"
const JAVA_KIND := "class"
const JAVA_NAME := "NuclearReactor"
const JAVA_EXTENDS := "PowerGenerator"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "timerFuel", "type": "int"}, {"modifiers": ["public"], "name": "lightColor", "type": "Color"}, {"modifiers": ["public"], "name": "coolColor", "type": "Color"}, {"modifiers": ["public"], "name": "hotColor", "type": "Color"}, {"modifiers": ["public"], "name": "itemDuration", "type": "float"}, {"modifiers": ["public"], "name": "heating", "type": "float"}, {"modifiers": ["public"], "name": "heatOutput", "type": "float"}, {"modifiers": ["public"], "name": "heatWarmupRate", "type": "float"}, {"modifiers": ["public"], "name": "ambientCooldownTime", "type": "float"}, {"modifiers": ["public"], "name": "smokeThreshold", "type": "float"}, {"modifiers": ["public"], "name": "flashThreshold", "type": "float"}, {"modifiers": ["public"], "name": "coolantPower", "type": "float"}, {"modifiers": ["public"], "name": "fuelItem", "type": "Item"}, {"modifiers": ["public"], "name": "topRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "lightsRegion", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "NuclearReactor", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	return null

func java_method_setBars_1(_args: Array = []) -> Variant:
	return null
