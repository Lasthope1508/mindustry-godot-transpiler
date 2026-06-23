# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/ConstructBlock.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks"
const JAVA_KIND := "class"
const JAVA_NAME := "ConstructBlock"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "consBlocks", "type": "ConstructBlock"}, {"modifiers": ["private", "static"], "name": "lastTime", "type": "long"}, {"modifiers": ["private", "static"], "name": "pitchSeq", "type": "int"}, {"modifiers": ["private", "static"], "name": "lastPlayed", "type": "long"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConstructBlock", "parameters": [{"name": "size", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "get", "parameters": [{"name": "size", "type": "int", "varargs": false}], "return_type": "ConstructBlock"}, {"modifiers": ["public", "static"], "name": "deconstructFinish", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "constructFinish", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "byte", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "shouldPlay", "parameters": [], "return_type": "boolean"}, {"modifiers": ["static"], "name": "calcPitch", "parameters": [{"name": "up", "type": "boolean", "varargs": false}], "return_type": "float"}, {"modifiers": ["public", "static"], "name": "playRepairSound", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "constructed", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "byte", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
