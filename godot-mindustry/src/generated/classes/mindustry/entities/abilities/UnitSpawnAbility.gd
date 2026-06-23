# Generated from Mindustry upstream.
# Source: mindustry/entities/abilities/UnitSpawnAbility.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.abilities"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitSpawnAbility"
const JAVA_EXTENDS := "Ability"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "unit", "type": "UnitType"}, {"modifiers": ["public"], "name": "spawnTime", "type": "float"}, {"modifiers": ["public"], "name": "spawnX", "type": "float"}, {"modifiers": ["public"], "name": "spawnY", "type": "float"}, {"modifiers": ["public"], "name": "spawnEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "parentizeEffects", "type": "boolean"}, {"modifiers": ["protected"], "name": "timer", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnitSpawnAbility", "parameters": [{"name": "unit", "type": "UnitType", "varargs": false}, {"name": "spawnTime", "type": "float", "varargs": false}, {"name": "spawnX", "type": "float", "varargs": false}, {"name": "spawnY", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "UnitSpawnAbility", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addStats", "parameters": [{"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []
