# Generated from Mindustry upstream.
# Source: mindustry/world/draw/DrawHeatOutput.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.draw"
const JAVA_KIND := "class"
const JAVA_NAME := "DrawHeatOutput"
const JAVA_EXTENDS := "DrawBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "heat", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "glow", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "top1", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "top2", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "heatColor", "type": "Color"}, {"modifiers": ["public"], "name": "heatPulse", "type": "float"}, {"modifiers": ["public"], "name": "heatPulseScl", "type": "float"}, {"modifiers": ["public"], "name": "glowMult", "type": "float"}, {"modifiers": ["public"], "name": "rotOffset", "type": "int"}, {"modifiers": ["public"], "name": "drawGlow", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "DrawHeatOutput", "parameters": []}, {"modifiers": ["public"], "name": "DrawHeatOutput", "parameters": [{"name": "rotOffset", "type": "int", "varargs": false}, {"name": "drawGlow", "type": "boolean", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "draw", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_draw_0(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_1(_args: Array = []) -> Variant:
	return null

func java_method_load_2(_args: Array = []) -> Variant:
	return null
