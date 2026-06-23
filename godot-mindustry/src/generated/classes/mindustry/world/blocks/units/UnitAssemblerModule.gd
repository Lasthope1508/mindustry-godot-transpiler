# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/units/UnitAssemblerModule.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.units"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitAssemblerModule"
const JAVA_EXTENDS := "PayloadBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "sideRegion1", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "sideRegion2", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "tier", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnitAssemblerModule", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "getLink", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "UnitAssemblerBuild"}]
const JAVA_ENUM_CONSTANTS := []
