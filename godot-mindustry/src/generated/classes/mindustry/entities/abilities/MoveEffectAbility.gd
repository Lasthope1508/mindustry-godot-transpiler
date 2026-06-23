# Generated from Mindustry upstream.
# Source: mindustry/entities/abilities/MoveEffectAbility.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.abilities"
const JAVA_KIND := "class"
const JAVA_NAME := "MoveEffectAbility"
const JAVA_EXTENDS := "Ability"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "minVelocity", "type": "float"}, {"modifiers": ["public"], "name": "interval", "type": "float"}, {"modifiers": ["public"], "name": "chance", "type": "float"}, {"modifiers": ["public"], "name": "amount", "type": "int"}, {"modifiers": ["public"], "name": "x", "type": "float"}, {"modifiers": ["public"], "name": "y", "type": "float"}, {"modifiers": ["public"], "name": "rotation", "type": "float"}, {"modifiers": ["public"], "name": "rangeX", "type": "float"}, {"modifiers": ["public"], "name": "rangeY", "type": "float"}, {"modifiers": ["public"], "name": "rangeLengthMin", "type": "float"}, {"modifiers": ["public"], "name": "rangeLengthMax", "type": "float"}, {"modifiers": ["public"], "name": "rotateEffect", "type": "boolean"}, {"modifiers": ["public"], "name": "effectParam", "type": "float"}, {"modifiers": ["public"], "name": "teamColor", "type": "boolean"}, {"modifiers": ["public"], "name": "parentizeEffects", "type": "boolean"}, {"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "effect", "type": "Effect"}, {"modifiers": ["protected"], "name": "counter", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MoveEffectAbility", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "effect", "type": "Effect", "varargs": false}, {"name": "interval", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "MoveEffectAbility", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_update_0(_args: Array = []) -> Variant:
	return null
