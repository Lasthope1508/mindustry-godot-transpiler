# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/logic/LogicDisplay.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "LogicDisplay"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "commandClear", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandColor", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandColorPack", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandStroke", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandLine", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandRect", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandLineRect", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandPoly", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandLinePoly", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandTriangle", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandImage", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandPrint", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandTranslate", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandScale", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandRotate", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "commandResetTransform", "type": "byte"}, {"modifiers": ["final", "public", "static"], "name": "displays", "type": "Seq"}, {"modifiers": ["final", "public", "static"], "name": "displayDrawType", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "scaleStep", "type": "float"}, {"modifiers": ["public"], "name": "maxSides", "type": "int"}, {"modifiers": ["public"], "name": "displaySize", "type": "int"}, {"modifiers": ["public"], "name": "scaleFactor", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LogicDisplay", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["static"], "name": "unpackSign", "parameters": [{"name": "value", "type": "int", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []
