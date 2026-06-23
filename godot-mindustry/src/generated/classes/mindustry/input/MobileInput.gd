# Generated from Mindustry upstream.
# Source: mindustry/input/MobileInput.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.input"
const JAVA_KIND := "class"
const JAVA_NAME := "MobileInput"
const JAVA_EXTENDS := "InputHandler"
const JAVA_IMPLEMENTS := ["GestureListener"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "maxPanSpeed", "type": "float"}, {"modifiers": ["final", "public"], "name": "edgePan", "type": "float"}, {"modifiers": ["public"], "name": "vector", "type": "Vec2"}, {"modifiers": ["public"], "name": "movement", "type": "Vec2"}, {"modifiers": ["public"], "name": "targetPos", "type": "Vec2"}, {"modifiers": ["public"], "name": "lastZoom", "type": "float"}, {"modifiers": ["public"], "name": "lineStartX", "type": "int"}, {"modifiers": ["public"], "name": "lineStartY", "type": "int"}, {"modifiers": ["public"], "name": "lastLineX", "type": "int"}, {"modifiers": ["public"], "name": "lastLineY", "type": "int"}, {"modifiers": ["public"], "name": "lineScale", "type": "float"}, {"modifiers": ["public"], "name": "crosshairScale", "type": "float"}, {"modifiers": ["public"], "name": "lastTarget", "type": "Teamc"}, {"modifiers": ["public"], "name": "shiftDeltaX", "type": "float"}, {"modifiers": ["public"], "name": "shiftDeltaY", "type": "float"}, {"modifiers": ["public"], "name": "removals", "type": "Seq"}, {"modifiers": ["public"], "name": "selecting", "type": "boolean"}, {"modifiers": ["public"], "name": "lineMode", "type": "boolean"}, {"modifiers": ["public"], "name": "schematicMode", "type": "boolean"}, {"modifiers": ["public"], "name": "rebuildMode", "type": "boolean"}, {"modifiers": ["public"], "name": "queueCommandMode", "type": "boolean"}, {"modifiers": ["public"], "name": "mode", "type": "PlaceMode"}, {"modifiers": ["public"], "name": "lastBlock", "type": "Block"}, {"modifiers": ["public"], "name": "lastPlaced", "type": "BuildPlan"}, {"modifiers": ["public"], "name": "down", "type": "boolean"}, {"modifiers": ["public"], "name": "manualShooting", "type": "boolean"}, {"modifiers": ["public"], "name": "target", "type": "Teamc"}, {"modifiers": ["public"], "name": "payloadTarget", "type": "Position"}, {"modifiers": ["public"], "name": "unitTapped", "type": "Unit"}, {"modifiers": ["public"], "name": "buildingTapped", "type": "Building"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": [], "name": "checkTargets", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "hasPlan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "checkOverlapPlacement", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "getPlan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": [], "name": "removePlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "isLinePlacing", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "isAreaBreaking", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "buildPlacementUI", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showCancel", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hasSchematic", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "buildUI", "parameters": [{"name": "group", "type": "Group", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBottom", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawTop", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawOverSelect", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "drawPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isRebuildSelecting", "parameters": [], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "schemOriginX", "parameters": [], "return_type": "int"}, {"modifiers": ["protected"], "name": "schemOriginY", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "isPlacing", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isBreaking", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "useSchematic", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "checkHidden", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "touchDown", "parameters": [{"name": "screenX", "type": "int", "varargs": false}, {"name": "screenY", "type": "int", "varargs": false}, {"name": "pointer", "type": "int", "varargs": false}, {"name": "button", "type": "KeyCode", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "touchUp", "parameters": [{"name": "screenX", "type": "int", "varargs": false}, {"name": "screenY", "type": "int", "varargs": false}, {"name": "pointer", "type": "int", "varargs": false}, {"name": "button", "type": "KeyCode", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "longPress", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "tap", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "count", "type": "int", "varargs": false}, {"name": "button", "type": "KeyCode", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "updateState", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getSyncedPlans", "parameters": [{"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "autoPan", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "pan", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "deltaX", "type": "float", "varargs": false}, {"name": "deltaY", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "panStop", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "pointer", "type": "int", "varargs": false}, {"name": "button", "type": "KeyCode", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "zoom", "parameters": [{"name": "initialDistance", "type": "float", "varargs": false}, {"name": "distance", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "updateMovement", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_checkTargets_0(_args: Array = []) -> Variant:
	return null

func java_method_hasPlan_1(_args: Array = []) -> Variant:
	return null

func java_method_checkOverlapPlacement_2(_args: Array = []) -> Variant:
	return null

func java_method_getPlan_3(_args: Array = []) -> Variant:
	return null

func java_method_removePlan_4(_args: Array = []) -> Variant:
	return null

func java_method_isLinePlacing_5(_args: Array = []) -> Variant:
	return null

func java_method_isAreaBreaking_6(_args: Array = []) -> Variant:
	return null

func java_method_buildPlacementUI_7(_args: Array = []) -> Variant:
	return null

func java_method_showCancel_8(_args: Array = []) -> Variant:
	return null

func java_method_hasSchematic_9(_args: Array = []) -> Variant:
	return null

func java_method_buildUI_10(_args: Array = []) -> Variant:
	return null

func java_method_drawBottom_11(_args: Array = []) -> Variant:
	return null

func java_method_drawTop_12(_args: Array = []) -> Variant:
	return null

func java_method_drawOverSelect_13(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_14(_args: Array = []) -> Variant:
	return null

func java_method_isRebuildSelecting_15(_args: Array = []) -> Variant:
	return null

func java_method_schemOriginX_16(_args: Array = []) -> Variant:
	return null

func java_method_schemOriginY_17(_args: Array = []) -> Variant:
	return null

func java_method_isPlacing_18(_args: Array = []) -> Variant:
	return null

func java_method_isBreaking_19(_args: Array = []) -> Variant:
	return null

func java_method_useSchematic_20(_args: Array = []) -> Variant:
	return null

func java_method_touchDown_21(_args: Array = []) -> Variant:
	return null

func java_method_touchUp_22(_args: Array = []) -> Variant:
	return null

func java_method_longPress_23(_args: Array = []) -> Variant:
	return null

func java_method_tap_24(_args: Array = []) -> Variant:
	return null

func java_method_updateState_25(_args: Array = []) -> Variant:
	return null

func java_method_reset_26(_args: Array = []) -> Variant:
	return null

func java_method_getSyncedPlans_27(_args: Array = []) -> Variant:
	return null

func java_method_update_28(_args: Array = []) -> Variant:
	return null

func java_method_autoPan_29(_args: Array = []) -> Variant:
	return null

func java_method_pan_30(_args: Array = []) -> Variant:
	return null

func java_method_panStop_31(_args: Array = []) -> Variant:
	return null

func java_method_zoom_32(_args: Array = []) -> Variant:
	return null

func java_method_updateMovement_33(_args: Array = []) -> Variant:
	return null
