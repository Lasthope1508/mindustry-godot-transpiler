# Generated from Mindustry upstream.
# Source: mindustry/input/DesktopInput.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.input"
const JAVA_KIND := "class"
const JAVA_NAME := "DesktopInput"
const JAVA_EXTENDS := "InputHandler"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "movement", "type": "Vec2"}, {"modifiers": ["public"], "name": "cursorType", "type": "Cursor"}, {"modifiers": ["public"], "name": "selectX", "type": "int"}, {"modifiers": ["public"], "name": "selectY", "type": "int"}, {"modifiers": ["public"], "name": "schemX", "type": "int"}, {"modifiers": ["public"], "name": "schemY", "type": "int"}, {"modifiers": ["public"], "name": "lastLineX", "type": "int"}, {"modifiers": ["public"], "name": "lastLineY", "type": "int"}, {"modifiers": ["public"], "name": "schematicX", "type": "int"}, {"modifiers": ["public"], "name": "schematicY", "type": "int"}, {"modifiers": ["public"], "name": "mode", "type": "PlaceMode"}, {"modifiers": ["public"], "name": "selectScale", "type": "float"}, {"modifiers": ["public"], "name": "splan", "type": "BuildPlan"}, {"modifiers": ["public"], "name": "deleting", "type": "boolean"}, {"modifiers": ["public"], "name": "shouldShoot", "type": "boolean"}, {"modifiers": ["public"], "name": "panning", "type": "boolean"}, {"modifiers": ["public"], "name": "movedPlan", "type": "boolean"}, {"modifiers": ["public"], "name": "panScale", "type": "float"}, {"modifiers": ["public"], "name": "panSpeed", "type": "float"}, {"modifiers": ["public"], "name": "panBoostSpeed", "type": "float"}, {"modifiers": ["public"], "name": "selectMillis", "type": "long"}, {"modifiers": ["public"], "name": "prevSelected", "type": "Tile"}, {"modifiers": ["public"], "name": "lastCtrlGroup", "type": "int"}, {"modifiers": ["public"], "name": "lastCtrlGroupSelectMillis", "type": "long"}, {"modifiers": ["public"], "name": "lastPayloadKeyTapMillis", "type": "long"}, {"modifiers": ["public"], "name": "lastPayloadKeyHoldMillis", "type": "long"}, {"modifiers": ["private"], "name": "buildPlanMouseOffsetX", "type": "float"}, {"modifiers": ["private"], "name": "buildPlanMouseOffsetY", "type": "float"}, {"modifiers": ["private"], "name": "changedCursor", "type": "boolean"}, {"modifiers": ["private"], "name": "pressedCommandRect", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": [], "name": "showHint", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "buildUI", "parameters": [{"name": "group", "type": "Group", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawTop", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawBottom", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "useSchematic", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "checkHidden", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isBreaking", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "buildPlacementUI", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "pollInputNoPlayer", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "pollInputPlayer", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "tap", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "count", "type": "int", "varargs": false}, {"name": "button", "type": "KeyCode", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "touchDown", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "pointer", "type": "int", "varargs": false}, {"name": "button", "type": "KeyCode", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "selectedBlock", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getMouseX", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getMouseY", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "updateState", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "panCamera", "parameters": [{"name": "position", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "updateMovement", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_showHint_0(_args: Array = []) -> Variant:
	return null

func java_method_reset_1(_args: Array = []) -> Variant:
	return null

func java_method_buildUI_2(_args: Array = []) -> Variant:
	return null

func java_method_drawTop_3(_args: Array = []) -> Variant:
	return null

func java_method_drawBottom_4(_args: Array = []) -> Variant:
	return null

func java_method_update_5(_args: Array = []) -> Variant:
	return null

func java_method_useSchematic_6(_args: Array = []) -> Variant:
	return null

func java_method_isBreaking_7(_args: Array = []) -> Variant:
	return null

func java_method_buildPlacementUI_8(_args: Array = []) -> Variant:
	return null

func java_method_pollInputNoPlayer_9(_args: Array = []) -> Variant:
	return null

func java_method_pollInputPlayer_10(_args: Array = []) -> Variant:
	return null

func java_method_tap_11(_args: Array = []) -> Variant:
	return null

func java_method_touchDown_12(_args: Array = []) -> Variant:
	return null

func java_method_selectedBlock_13(_args: Array = []) -> Variant:
	return null

func java_method_getMouseX_14(_args: Array = []) -> Variant:
	return null

func java_method_getMouseY_15(_args: Array = []) -> Variant:
	return null

func java_method_updateState_16(_args: Array = []) -> Variant:
	return null

func java_method_panCamera_17(_args: Array = []) -> Variant:
	return null

func java_method_updateMovement_18(_args: Array = []) -> Variant:
	return null
