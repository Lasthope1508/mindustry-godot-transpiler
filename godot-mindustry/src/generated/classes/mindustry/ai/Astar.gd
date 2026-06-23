# Generated from Mindustry upstream.
# Source: mindustry/ai/Astar.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "Astar"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "manhattan", "type": "DistanceHeuristic"}, {"modifiers": ["final", "private", "static"], "name": "out", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "queue", "type": "PQueue"}, {"modifiers": ["private", "static"], "name": "costs", "type": "float"}, {"modifiers": ["private", "static"], "name": "rotations", "type": "byte"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "pathfind", "parameters": [{"name": "from", "type": "Tile", "varargs": false}, {"name": "to", "type": "Tile", "varargs": false}, {"name": "th", "type": "TileHeuristic", "varargs": false}, {"name": "passable", "type": "Boolf", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public", "static"], "name": "pathfind", "parameters": [{"name": "startX", "type": "int", "varargs": false}, {"name": "startY", "type": "int", "varargs": false}, {"name": "endX", "type": "int", "varargs": false}, {"name": "endY", "type": "int", "varargs": false}, {"name": "th", "type": "TileHeuristic", "varargs": false}, {"name": "passable", "type": "Boolf", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public", "static"], "name": "pathfind", "parameters": [{"name": "startX", "type": "int", "varargs": false}, {"name": "startY", "type": "int", "varargs": false}, {"name": "endX", "type": "int", "varargs": false}, {"name": "endY", "type": "int", "varargs": false}, {"name": "th", "type": "TileHeuristic", "varargs": false}, {"name": "dh", "type": "DistanceHeuristic", "varargs": false}, {"name": "passable", "type": "Boolf", "varargs": false}], "return_type": "Seq"}]
const JAVA_ENUM_CONSTANTS := []
