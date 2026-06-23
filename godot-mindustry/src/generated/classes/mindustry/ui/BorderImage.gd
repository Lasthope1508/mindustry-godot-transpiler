# Generated from Mindustry upstream.
# Source: mindustry/ui/BorderImage.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui"
const JAVA_KIND := "class"
const JAVA_NAME := "BorderImage"
const JAVA_EXTENDS := "Image"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "thickness", "type": "float"}, {"modifiers": ["public"], "name": "pad", "type": "float"}, {"modifiers": ["public"], "name": "borderColor", "type": "Color"}, {"modifiers": ["public"], "name": "forceNearest", "type": "boolean"}, {"modifiers": ["public"], "name": "drawAlpha", "type": "boolean"}, {"modifiers": ["public"], "name": "alphaColor", "type": "Color"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BorderImage", "parameters": []}, {"modifiers": ["public"], "name": "BorderImage", "parameters": [{"name": "texture", "type": "Texture", "varargs": false}]}, {"modifiers": ["public"], "name": "BorderImage", "parameters": [{"name": "texture", "type": "Texture", "varargs": false}, {"name": "thick", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "BorderImage", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "thick", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "BorderImage", "parameters": [{"name": "region", "type": "Drawable", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "border", "parameters": [{"name": "color", "type": "Color", "varargs": false}], "return_type": "BorderImage"}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
