# Generated from Mindustry upstream.
# Source: mindustry/entities/abilities/ShieldRegenFieldAbility.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.abilities"
const JAVA_KIND := "class"
const JAVA_NAME := "ShieldRegenFieldAbility"
const JAVA_EXTENDS := "Ability"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "amount", "type": "float"}, {"modifiers": ["public"], "name": "max", "type": "float"}, {"modifiers": ["public"], "name": "reload", "type": "float"}, {"modifiers": ["public"], "name": "range", "type": "float"}, {"modifiers": ["public"], "name": "applyEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "activeEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "sound", "type": "Sound"}, {"modifiers": ["public"], "name": "soundVolume", "type": "float"}, {"modifiers": ["public"], "name": "parentizeEffects", "type": "boolean"}, {"modifiers": ["protected"], "name": "timer", "type": "float"}, {"modifiers": ["protected"], "name": "applied", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "ShieldRegenFieldAbility", "parameters": []}, {"modifiers": ["public"], "name": "ShieldRegenFieldAbility", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "max", "type": "float", "varargs": false}, {"name": "reload", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addStats", "parameters": [{"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
