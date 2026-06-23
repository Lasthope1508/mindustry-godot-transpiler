# Generated from Mindustry upstream.
# Source: mindustry/world/draw/DrawRegion.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.draw"
const JAVA_KIND := "class"
const JAVA_NAME := "DrawRegion"
const JAVA_EXTENDS := "DrawBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "region", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "suffix", "type": "String"}, {"modifiers": ["public"], "name": "name", "type": "String"}, {"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "spinSprite", "type": "boolean"}, {"modifiers": ["public"], "name": "drawPlan", "type": "boolean"}, {"modifiers": ["public"], "name": "buildingRotate", "type": "boolean"}, {"modifiers": ["public"], "name": "rotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "x", "type": "float"}, {"modifiers": ["public"], "name": "y", "type": "float"}, {"modifiers": ["public"], "name": "rotation", "type": "float"}, {"modifiers": ["public"], "name": "layer", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "DrawRegion", "parameters": [{"name": "suffix", "type": "String", "varargs": false}]}, {"modifiers": ["public"], "name": "DrawRegion", "parameters": [{"name": "suffix", "type": "String", "varargs": false}, {"name": "rotateSpeed", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "DrawRegion", "parameters": [{"name": "suffix", "type": "String", "varargs": false}, {"name": "rotateSpeed", "type": "float", "varargs": false}, {"name": "spinSprite", "type": "boolean", "varargs": false}]}, {"modifiers": ["public"], "name": "DrawRegion", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "draw", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "load", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
