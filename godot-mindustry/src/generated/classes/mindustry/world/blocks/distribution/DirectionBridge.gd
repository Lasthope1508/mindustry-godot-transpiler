# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/distribution/DirectionBridge.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.distribution"
const JAVA_KIND := "class"
const JAVA_NAME := "DirectionBridge"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "otherDst", "type": "int"}, {"modifiers": ["public"], "name": "bridgeRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "bridgeBotRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "bridgeLiquidRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "arrowRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "dirRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "range", "type": "int"}, {"modifiers": ["private", "static"], "name": "currentPlan", "type": "BuildPlan"}, {"modifiers": ["private", "static"], "name": "otherPlan", "type": "BuildPlan"}, {"modifiers": ["private"], "name": "planFinder", "type": "Boolf"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "DirectionBridge", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfigTop", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "changePlacementPath", "parameters": [{"name": "points", "type": "Seq", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}, {"name": "line", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBridge", "parameters": [{"name": "rotation", "type": "int", "varargs": false}, {"name": "x1", "type": "float", "varargs": false}, {"name": "y1", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "liquidColor", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "positionsValid", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_1(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanConfigTop_2(_args: Array = []) -> Variant:
	return null

func java_method_icons_3(_args: Array = []) -> Variant:
	return null

func java_method_changePlacementPath_4(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_5(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_6(_args: Array = []) -> Variant:
	return null

func java_method_drawBridge_7(_args: Array = []) -> Variant:
	return null

func java_method_positionsValid_8(_args: Array = []) -> Variant:
	return null
