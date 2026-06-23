# Generated from Mindustry upstream.
# Source: mindustry/world/draw/DrawPower.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.draw"
const JAVA_KIND := "class"
const JAVA_NAME := "DrawPower"
const JAVA_EXTENDS := "DrawBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "emptyRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "fullRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "suffix", "type": "String"}, {"modifiers": ["public"], "name": "drawPlan", "type": "boolean"}, {"modifiers": ["public"], "name": "mixcol", "type": "boolean"}, {"modifiers": ["public"], "name": "emptyLightColor", "type": "Color"}, {"modifiers": ["public"], "name": "fullLightColor", "type": "Color"}, {"modifiers": ["public"], "name": "layer", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "DrawPower", "parameters": []}, {"modifiers": ["public"], "name": "DrawPower", "parameters": [{"name": "suffix", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "draw", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "load", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
