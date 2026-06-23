# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/power/ThermalGenerator.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.power"
const JAVA_KIND := "class"
const JAVA_NAME := "ThermalGenerator"
const JAVA_EXTENDS := "PowerGenerator"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "generateEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "effectChance", "type": "float"}, {"modifiers": ["public"], "name": "minEfficiency", "type": "float"}, {"modifiers": ["public"], "name": "displayEfficiencyScale", "type": "float"}, {"modifiers": ["public"], "name": "displayEfficiency", "type": "boolean"}, {"modifiers": ["public"], "name": "outputLiquid", "type": "LiquidStack"}, {"modifiers": ["public"], "name": "attribute", "type": "Attribute"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ThermalGenerator", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getDisplayedPowerProduction", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
