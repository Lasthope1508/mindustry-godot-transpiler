# Generated from Mindustry upstream.
# Source: mindustry/entities/abilities/EnergyFieldAbility.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.abilities"
const JAVA_KIND := "class"
const JAVA_NAME := "EnergyFieldAbility"
const JAVA_EXTENDS := "Ability"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "all", "type": "Seq"}, {"modifiers": ["public"], "name": "damage", "type": "float"}, {"modifiers": ["public"], "name": "reload", "type": "float"}, {"modifiers": ["public"], "name": "range", "type": "float"}, {"modifiers": ["public"], "name": "healEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "hitEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "damageEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "status", "type": "StatusEffect"}, {"modifiers": ["public"], "name": "shootSound", "type": "Sound"}, {"modifiers": ["public"], "name": "statusDuration", "type": "float"}, {"modifiers": ["public"], "name": "x", "type": "float"}, {"modifiers": ["public"], "name": "y", "type": "float"}, {"modifiers": ["public"], "name": "targetGround", "type": "boolean"}, {"modifiers": ["public"], "name": "targetAir", "type": "boolean"}, {"modifiers": ["public"], "name": "hitBuildings", "type": "boolean"}, {"modifiers": ["public"], "name": "hitUnits", "type": "boolean"}, {"modifiers": ["public"], "name": "maxTargets", "type": "int"}, {"modifiers": ["public"], "name": "healPercent", "type": "float"}, {"modifiers": ["public"], "name": "sameTypeHealMult", "type": "float"}, {"modifiers": ["public"], "name": "displayHeal", "type": "boolean"}, {"modifiers": ["public"], "name": "layer", "type": "float"}, {"modifiers": ["public"], "name": "blinkScl", "type": "float"}, {"modifiers": ["public"], "name": "blinkSize", "type": "float"}, {"modifiers": ["public"], "name": "effectRadius", "type": "float"}, {"modifiers": ["public"], "name": "sectorRad", "type": "float"}, {"modifiers": ["public"], "name": "rotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "sectors", "type": "int"}, {"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "useAmmo", "type": "boolean"}, {"modifiers": ["protected"], "name": "timer", "type": "float"}, {"modifiers": ["protected"], "name": "curStroke", "type": "float"}, {"modifiers": ["protected"], "name": "anyNearby", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "EnergyFieldAbility", "parameters": []}, {"modifiers": ["public"], "name": "EnergyFieldAbility", "parameters": [{"name": "damage", "type": "float", "varargs": false}, {"name": "reload", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addStats", "parameters": [{"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_addStats_0(_args: Array = []) -> Variant:
	return null

func java_method_draw_1(_args: Array = []) -> Variant:
	return null

func java_method_update_2(_args: Array = []) -> Variant:
	return null
