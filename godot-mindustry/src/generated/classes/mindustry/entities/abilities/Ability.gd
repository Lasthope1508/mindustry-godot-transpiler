# Generated from Mindustry upstream.
# Source: mindustry/entities/abilities/Ability.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.abilities"
const JAVA_KIND := "class"
const JAVA_NAME := "Ability"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Cloneable"]
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "descriptionWidth", "type": "float"}, {"modifiers": ["public"], "name": "display", "type": "boolean"}, {"modifiers": ["public"], "name": "data", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "death", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "created", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [{"name": "type", "type": "UnitType", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "displayBars", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "bars", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addStats", "parameters": [{"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "abilityStat", "parameters": [{"name": "stat", "type": "String", "varargs": false}, {"name": "values", "type": "Object", "varargs": true}], "return_type": "String"}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "Ability"}, {"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getBundle", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []
