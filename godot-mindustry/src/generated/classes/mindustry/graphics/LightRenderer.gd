# Generated from Mindustry upstream.
# Source: mindustry/graphics/LightRenderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "LightRenderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "scaling", "type": "int"}, {"modifiers": ["private"], "name": "vertices", "type": "float"}, {"modifiers": ["private"], "name": "buffer", "type": "FrameBuffer"}, {"modifiers": ["private"], "name": "lights", "type": "Seq"}, {"modifiers": ["private"], "name": "circles", "type": "Seq"}, {"modifiers": ["private"], "name": "circleIndex", "type": "int"}, {"modifiers": ["private"], "name": "circleRegion", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "add", "parameters": [{"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "line", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}, {"name": "tint", "type": "Color", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "enabled", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
