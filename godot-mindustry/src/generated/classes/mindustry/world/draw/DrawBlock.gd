# Generated from Mindustry upstream.
# Source: mindustry/world/draw/DrawBlock.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.draw"
const JAVA_KIND := "class"
const JAVA_NAME := "DrawBlock"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "rand", "type": "Rand"}, {"modifiers": ["public"], "name": "iconOverride", "type": "String"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getRegionsToOutline", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawLight", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["final", "public"], "name": "finalIcons", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "expectCrafter", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "GenericCrafter"}]
const JAVA_ENUM_CONSTANTS := []
