# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/distribution/ItemBridge.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.distribution"
const JAVA_KIND := "class"
const JAVA_NAME := "ItemBridge"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "timerCheckMoved", "type": "int"}, {"modifiers": ["public"], "name": "range", "type": "int"}, {"modifiers": ["public"], "name": "transportTime", "type": "float"}, {"modifiers": ["public"], "name": "endRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "bridgeRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "arrowRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "fadeIn", "type": "boolean"}, {"modifiers": ["public"], "name": "moveArrows", "type": "boolean"}, {"modifiers": ["public"], "name": "pulse", "type": "boolean"}, {"modifiers": ["public"], "name": "arrowSpacing", "type": "float"}, {"modifiers": ["public"], "name": "arrowOffset", "type": "float"}, {"modifiers": ["public"], "name": "arrowPeriod", "type": "float"}, {"modifiers": ["public"], "name": "arrowTimeScl", "type": "float"}, {"modifiers": ["public"], "name": "bridgeWidth", "type": "float"}, {"modifiers": ["public"], "name": "lastBuild", "type": "ItemBridgeBuild"}, {"modifiers": ["private", "static"], "name": "currentFindX", "type": "int"}, {"modifiers": ["private", "static"], "name": "currentFindY", "type": "int"}, {"modifiers": ["private", "static"], "name": "currentPlan", "type": "BuildPlan"}, {"modifiers": ["final", "private", "static"], "name": "planFinder", "type": "Boolf"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ItemBridge", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfigTop", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBridge", "parameters": [{"name": "req", "type": "BuildPlan", "varargs": false}, {"name": "ox", "type": "float", "varargs": false}, {"name": "oy", "type": "float", "varargs": false}, {"name": "flip", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "linkValid", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "linkValid", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}, {"name": "checkDouble", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "positionsValid", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "findLink", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "handlePlacementLine", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "changePlacementPath", "parameters": [{"name": "points", "type": "Seq", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanConfigTop_1(_args: Array = []) -> Variant:
	return null

func java_method_drawBridge_2(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_3(_args: Array = []) -> Variant:
	return null

func java_method_linkValid_4(_args: Array = []) -> Variant:
	return null

func java_method_linkValid_5(_args: Array = []) -> Variant:
	return null

func java_method_positionsValid_6(_args: Array = []) -> Variant:
	return null

func java_method_findLink_7(_args: Array = []) -> Variant:
	return null

func java_method_init_8(_args: Array = []) -> Variant:
	return null

func java_method_handlePlacementLine_9(_args: Array = []) -> Variant:
	return null

func java_method_changePlacementPath_10(_args: Array = []) -> Variant:
	return null
