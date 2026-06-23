# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/Door.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense"
const JAVA_KIND := "class"
const JAVA_NAME := "Door"
const JAVA_EXTENDS := "Wall"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "rect", "type": "Rect"}, {"modifiers": ["final", "protected", "static"], "name": "doorQueue", "type": "Queue"}, {"modifiers": ["final", "public"], "name": "timerToggle", "type": "int"}, {"modifiers": ["public"], "name": "openfx", "type": "Effect"}, {"modifiers": ["public"], "name": "closefx", "type": "Effect"}, {"modifiers": ["public"], "name": "doorSound", "type": "Sound"}, {"modifiers": ["public"], "name": "chainEffect", "type": "boolean"}, {"modifiers": ["public"], "name": "openRegion", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Door", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getPlanRegion_0(_args: Array = []) -> Variant:
	return null
