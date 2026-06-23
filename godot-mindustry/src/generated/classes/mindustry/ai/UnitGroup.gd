# Generated from Mindustry upstream.
# Source: mindustry/ai/UnitGroup.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitGroup"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "units", "type": "Seq"}, {"modifiers": ["public"], "name": "collisionLayer", "type": "int"}, {"modifiers": ["public", "volatile"], "name": "positions", "type": "float"}, {"modifiers": ["public", "volatile"], "name": "originalPositions", "type": "float"}, {"modifiers": ["public", "volatile"], "name": "valid", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "calculateFormation", "parameters": [{"name": "dest", "type": "Vec2", "varargs": false}, {"name": "collisionLayer", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateRaycast", "parameters": [{"name": "index", "type": "int", "varargs": false}, {"name": "dest", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "updateRaycast", "parameters": [{"name": "index", "type": "int", "varargs": false}, {"name": "dest", "type": "Vec2", "varargs": false}, {"name": "v1", "type": "Vec2", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_calculateFormation_0(_args: Array = []) -> Variant:
	return null

func java_method_updateRaycast_1(_args: Array = []) -> Variant:
	return null

func java_method_updateRaycast_2(_args: Array = []) -> Variant:
	return null
