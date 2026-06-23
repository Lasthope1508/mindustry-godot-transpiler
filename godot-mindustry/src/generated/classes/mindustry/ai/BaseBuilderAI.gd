# Generated from Mindustry upstream.
# Source: mindustry/ai/BaseBuilderAI.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "BaseBuilderAI"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "axis", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "rotator", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "attempts", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "coreUnitMultiplier", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "emptyChance", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "timerStep", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "timerSpawn", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "timerRefreshPath", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "placeIntervalMin", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "placeIntervalMax", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "pathStep", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "tmpTiles", "type": "Seq"}, {"modifiers": ["private", "static"], "name": "correct", "type": "int"}, {"modifiers": ["private", "static"], "name": "incorrect", "type": "int"}, {"modifiers": ["private"], "name": "foundPath", "type": "boolean"}, {"modifiers": ["final"], "name": "data", "type": "TeamData"}, {"modifiers": ["final"], "name": "timer", "type": "Interval"}, {"modifiers": [], "name": "path", "type": "IntSet"}, {"modifiers": [], "name": "calcPath", "type": "IntSet"}, {"modifiers": [], "name": "calcTile", "type": "Tile"}, {"modifiers": [], "name": "calculating", "type": "boolean"}, {"modifiers": [], "name": "startedCalculating", "type": "boolean"}, {"modifiers": [], "name": "calcCount", "type": "int"}, {"modifiers": [], "name": "totalCalcs", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BaseBuilderAI", "parameters": [{"name": "data", "type": "TeamData", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "randomPosition", "parameters": [], "return_type": "Position"}, {"modifiers": ["private"], "name": "tryPlace", "parameters": [{"name": "part", "type": "BasePart", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
