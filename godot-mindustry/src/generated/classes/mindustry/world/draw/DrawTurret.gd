# Generated from Mindustry upstream.
# Source: mindustry/world/draw/DrawTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.draw"
const JAVA_KIND := "class"
const JAVA_NAME := "DrawTurret"
const JAVA_EXTENDS := "DrawBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "rand", "type": "Rand"}, {"modifiers": ["public"], "name": "parts", "type": "Seq"}, {"modifiers": ["public"], "name": "ammoParts", "type": "ObjectMap"}, {"modifiers": ["public"], "name": "basePrefix", "type": "String"}, {"modifiers": ["public"], "name": "liquidDraw", "type": "Liquid"}, {"modifiers": ["public"], "name": "turretLayer", "type": "float"}, {"modifiers": ["public"], "name": "shadowLayer", "type": "float"}, {"modifiers": ["public"], "name": "heatLayer", "type": "float"}, {"modifiers": ["public"], "name": "base", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "liquid", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "top", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "heat", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "preview", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "outline", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "DrawTurret", "parameters": [{"name": "basePrefix", "type": "String", "varargs": false}]}, {"modifiers": ["public"], "name": "DrawTurret", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setAmmoParts", "parameters": [{"name": "objects", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "getRegionsToOutline", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawTurret", "parameters": [{"name": "block", "type": "Turret", "varargs": false}, {"name": "build", "type": "TurretBuild", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawHeat", "parameters": [{"name": "block", "type": "Turret", "varargs": false}, {"name": "build", "type": "TurretBuild", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setAmmoParts_0(_args: Array = []) -> Variant:
	return null

func java_method_getRegionsToOutline_1(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_2(_args: Array = []) -> Variant:
	return null

func java_method_draw_3(_args: Array = []) -> Variant:
	return null

func java_method_drawTurret_4(_args: Array = []) -> Variant:
	return null

func java_method_drawHeat_5(_args: Array = []) -> Variant:
	return null

func java_method_load_6(_args: Array = []) -> Variant:
	return null

func java_method_icons_7(_args: Array = []) -> Variant:
	return null
