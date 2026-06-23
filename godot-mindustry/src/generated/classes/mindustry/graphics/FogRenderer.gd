# Generated from Mindustry upstream.
# Source: mindustry/graphics/FogRenderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "FogRenderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "staticFog", "type": "FrameBuffer"}, {"modifiers": ["private"], "name": "dynamicFog", "type": "FrameBuffer"}, {"modifiers": ["private"], "name": "events", "type": "LongSeq"}, {"modifiers": ["private"], "name": "rect", "type": "Rect"}, {"modifiers": ["private"], "name": "lastTeam", "type": "Team"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "FogRenderer", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "handleEvent", "parameters": [{"name": "event", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getStaticTexture", "parameters": [], "return_type": "Texture"}, {"modifiers": ["public"], "name": "getDynamicTexture", "parameters": [], "return_type": "Texture"}, {"modifiers": ["public"], "name": "drawFog", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "poly", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "renderEvent", "parameters": [{"name": "e", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "copyFromCpu", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
