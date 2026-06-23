# Generated from Mindustry upstream.
# Source: mindustry/entities/abilities/StatusFieldAbility.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.abilities"
const JAVA_KIND := "class"
const JAVA_NAME := "StatusFieldAbility"
const JAVA_EXTENDS := "Ability"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "effect", "type": "StatusEffect"}, {"modifiers": ["public"], "name": "duration", "type": "float"}, {"modifiers": ["public"], "name": "reload", "type": "float"}, {"modifiers": ["public"], "name": "range", "type": "float"}, {"modifiers": ["public"], "name": "onShoot", "type": "boolean"}, {"modifiers": ["public"], "name": "applyEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "activeEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "effectX", "type": "float"}, {"modifiers": ["public"], "name": "effectY", "type": "float"}, {"modifiers": ["public"], "name": "parentizeEffects", "type": "boolean"}, {"modifiers": ["public"], "name": "effectSizeParam", "type": "boolean"}, {"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["protected"], "name": "timer", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "StatusFieldAbility", "parameters": []}, {"modifiers": ["public"], "name": "StatusFieldAbility", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "reload", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addStats", "parameters": [{"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_addStats_0(_args: Array = []) -> Variant:
	return null

func java_method_update_1(_args: Array = []) -> Variant:
	return null
