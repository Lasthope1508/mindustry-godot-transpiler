# Generated from Mindustry upstream.
# Source: mindustry/world/draw/DrawMulti.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.draw"
const JAVA_KIND := "class"
const JAVA_NAME := "DrawMulti"
const JAVA_EXTENDS := "DrawBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "drawers", "type": "DrawBlock"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "DrawMulti", "parameters": []}, {"modifiers": ["public"], "name": "DrawMulti", "parameters": [{"name": "drawers", "type": "DrawBlock", "varargs": true}]}, {"modifiers": ["public"], "name": "DrawMulti", "parameters": [{"name": "drawers", "type": "Seq", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getRegionsToOutline", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawLight", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []
