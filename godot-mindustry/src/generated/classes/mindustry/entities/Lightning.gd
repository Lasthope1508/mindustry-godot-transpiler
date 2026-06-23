# Generated from Mindustry upstream.
# Source: mindustry/entities/Lightning.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities"
const JAVA_KIND := "class"
const JAVA_NAME := "Lightning"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "random", "type": "Rand"}, {"modifiers": ["final", "private", "static"], "name": "rect", "type": "Rect"}, {"modifiers": ["final", "private", "static"], "name": "entities", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "hit", "type": "IntSet"}, {"modifiers": ["final", "private", "static"], "name": "maxChain", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "hitRange", "type": "float"}, {"modifiers": ["private", "static"], "name": "bhit", "type": "boolean"}, {"modifiers": ["private", "static"], "name": "lastSeed", "type": "int"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "create", "parameters": [{"name": "bulletCreated", "type": "BulletType", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "targetAngle", "type": "float", "varargs": false}, {"name": "length", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "create", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "targetAngle", "type": "float", "varargs": false}, {"name": "length", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "create", "parameters": [{"name": "bullet", "type": "Bullet", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "targetAngle", "type": "float", "varargs": false}, {"name": "length", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "createLightningInternal", "parameters": [{"name": "hitter", "type": "Bullet", "varargs": false}, {"name": "hitCreate", "type": "BulletType", "varargs": false}, {"name": "seed", "type": "int", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "length", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_create_0(_args: Array = []) -> Variant:
	return null

func java_method_create_1(_args: Array = []) -> Variant:
	return null

func java_method_create_2(_args: Array = []) -> Variant:
	return null

func java_method_createLightningInternal_3(_args: Array = []) -> Variant:
	return null
