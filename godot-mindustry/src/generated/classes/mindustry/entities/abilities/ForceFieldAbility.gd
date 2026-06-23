# Generated from Mindustry upstream.
# Source: mindustry/entities/abilities/ForceFieldAbility.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.abilities"
const JAVA_KIND := "class"
const JAVA_NAME := "ForceFieldAbility"
const JAVA_EXTENDS := "Ability"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "radius", "type": "float"}, {"modifiers": ["public"], "name": "regen", "type": "float"}, {"modifiers": ["public"], "name": "max", "type": "float"}, {"modifiers": ["public"], "name": "cooldown", "type": "float"}, {"modifiers": ["public"], "name": "sides", "type": "int"}, {"modifiers": ["public"], "name": "rotation", "type": "float"}, {"modifiers": ["public"], "name": "breakSound", "type": "Sound"}, {"modifiers": ["public"], "name": "hitSound", "type": "Sound"}, {"modifiers": ["public"], "name": "hitSoundVolume", "type": "float"}, {"modifiers": ["protected"], "name": "radiusScale", "type": "float"}, {"modifiers": ["protected"], "name": "alpha", "type": "float"}, {"modifiers": ["protected"], "name": "wasBroken", "type": "boolean"}, {"modifiers": ["private", "static"], "name": "realRad", "type": "float"}, {"modifiers": ["private", "static"], "name": "paramUnit", "type": "Unit"}, {"modifiers": ["private", "static"], "name": "paramField", "type": "ForceFieldAbility"}, {"modifiers": ["final", "private", "static"], "name": "shieldConsumer", "type": "Cons"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ForceFieldAbility", "parameters": [{"name": "radius", "type": "float", "varargs": false}, {"name": "regen", "type": "float", "varargs": false}, {"name": "max", "type": "float", "varargs": false}, {"name": "cooldown", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ForceFieldAbility", "parameters": [{"name": "radius", "type": "float", "varargs": false}, {"name": "regen", "type": "float", "varargs": false}, {"name": "max", "type": "float", "varargs": false}, {"name": "cooldown", "type": "float", "varargs": false}, {"name": "sides", "type": "int", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}]}, {"modifiers": [], "name": "ForceFieldAbility", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addStats", "parameters": [{"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "death", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "displayBars", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "bars", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "created", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkRadius", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_addStats_0(_args: Array = []) -> Variant:
	return null

func java_method_update_1(_args: Array = []) -> Variant:
	return null

func java_method_death_2(_args: Array = []) -> Variant:
	return null

func java_method_draw_3(_args: Array = []) -> Variant:
	return null

func java_method_displayBars_4(_args: Array = []) -> Variant:
	return null

func java_method_created_5(_args: Array = []) -> Variant:
	return null

func java_method_checkRadius_6(_args: Array = []) -> Variant:
	return null
