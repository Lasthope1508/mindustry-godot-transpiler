# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/units/UnitCargoLoader.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.units"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitCargoLoader"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "unitType", "type": "UnitType"}, {"modifiers": ["public"], "name": "unitBuildTime", "type": "float"}, {"modifiers": ["public"], "name": "polyStroke", "type": "float"}, {"modifiers": ["public"], "name": "polyRadius", "type": "float"}, {"modifiers": ["public"], "name": "polySides", "type": "int"}, {"modifiers": ["public"], "name": "polyRotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "polyColor", "type": "Color"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnitCargoLoader", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitTetherBlockSpawned", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "id", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
