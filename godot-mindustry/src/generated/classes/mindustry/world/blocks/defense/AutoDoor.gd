# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/AutoDoor.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense"
const JAVA_KIND := "class"
const JAVA_NAME := "AutoDoor"
const JAVA_EXTENDS := "Wall"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "rect", "type": "Rect"}, {"modifiers": ["final", "protected", "static"], "name": "units", "type": "Seq"}, {"modifiers": ["final", "protected", "static"], "name": "groundCheck", "type": "Boolf"}, {"modifiers": ["final", "public"], "name": "timerToggle", "type": "int"}, {"modifiers": ["public"], "name": "checkInterval", "type": "float"}, {"modifiers": ["public"], "name": "openfx", "type": "Effect"}, {"modifiers": ["public"], "name": "closefx", "type": "Effect"}, {"modifiers": ["public"], "name": "doorSound", "type": "Sound"}, {"modifiers": ["public"], "name": "openRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "triggerMargin", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "AutoDoor", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "autoDoorToggle", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "open", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
