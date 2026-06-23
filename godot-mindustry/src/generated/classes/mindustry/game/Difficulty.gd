# Generated from Mindustry upstream.
# Source: mindustry/game/Difficulty.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "enum"
const JAVA_NAME := "Difficulty"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "all", "type": "Difficulty"}, {"modifiers": ["public"], "name": "enemyHealthMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "enemySpawnMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "waveTimeMultiplier", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "Difficulty", "parameters": [{"name": "enemyHealthMultiplier", "type": "float", "varargs": false}, {"name": "enemySpawnMultiplier", "type": "float", "varargs": false}, {"name": "waveTimeMultiplier", "type": "float", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "info", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}, {"modifiers": ["static"], "name": "percentStat", "parameters": [{"name": "val", "type": "float", "varargs": false}], "return_type": "String"}, {"modifiers": ["static"], "name": "percentStatNeg", "parameters": [{"name": "val", "type": "float", "varargs": false}], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := ["casual", "easy", "normal", "hard", "eradication"]
