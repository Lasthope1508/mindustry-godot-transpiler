# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/units/UnitFactory.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.units"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitFactory"
const JAVA_EXTENDS := "UnitBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "capacities", "type": "int"}, {"modifiers": ["public"], "name": "plans", "type": "Seq"}, {"modifiers": ["public"], "name": "createSound", "type": "Sound"}, {"modifiers": ["public"], "name": "createSoundVolume", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnitFactory", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterPatch", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "initCapacities", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkContentArrayCapacity", "parameters": [{"name": "items", "type": "int", "varargs": false}, {"name": "liquids", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getPlanConfigs", "parameters": [{"name": "options", "type": "Seq", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
