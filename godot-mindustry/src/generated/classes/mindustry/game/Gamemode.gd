# Generated from Mindustry upstream.
# Source: mindustry/game/Gamemode.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "enum"
const JAVA_NAME := "Gamemode"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private"], "name": "rules", "type": "Cons"}, {"modifiers": ["final", "private"], "name": "validator", "type": "Boolf"}, {"modifiers": ["final", "public"], "name": "hidden", "type": "boolean"}, {"modifiers": ["final", "public", "static"], "name": "all", "type": "Gamemode"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "Gamemode", "parameters": [{"name": "rules", "type": "Cons", "varargs": false}]}, {"modifiers": [], "name": "Gamemode", "parameters": [{"name": "hidden", "type": "boolean", "varargs": false}, {"name": "rules", "type": "Cons", "varargs": false}]}, {"modifiers": [], "name": "Gamemode", "parameters": [{"name": "rules", "type": "Cons", "varargs": false}, {"name": "validator", "type": "Boolf", "varargs": false}]}, {"modifiers": [], "name": "Gamemode", "parameters": [{"name": "hidden", "type": "boolean", "varargs": false}, {"name": "rules", "type": "Cons", "varargs": false}, {"name": "validator", "type": "Boolf", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "in", "type": "Rules", "varargs": false}], "return_type": "Rules"}, {"modifiers": ["public"], "name": "valid", "parameters": [{"name": "map", "type": "Map", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "description", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := ["survival", "sandbox", "attack", "pvp", "editor"]
