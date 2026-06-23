# Generated from Mindustry upstream.
# Source: mindustry/editor/MapView.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "MapView"
const JAVA_EXTENDS := "Element"
const JAVA_IMPLEMENTS := ["GestureListener"]
const JAVA_FIELDS := [{"modifiers": [], "name": "tool", "type": "EditorTool"}, {"modifiers": ["private"], "name": "offsetx", "type": "float"}, {"modifiers": ["private"], "name": "offsety", "type": "float"}, {"modifiers": ["private"], "name": "zoom", "type": "float"}, {"modifiers": ["private"], "name": "grid", "type": "boolean"}, {"modifiers": ["private"], "name": "image", "type": "GridImage"}, {"modifiers": ["private"], "name": "vec", "type": "Vec2"}, {"modifiers": ["private"], "name": "rect", "type": "Rect"}, {"modifiers": ["private"], "name": "brushPolygons", "type": "Vec2"}, {"modifiers": [], "name": "drawing", "type": "boolean"}, {"modifiers": [], "name": "lastx", "type": "int"}, {"modifiers": [], "name": "lasty", "type": "int"}, {"modifiers": [], "name": "startx", "type": "int"}, {"modifiers": [], "name": "starty", "type": "int"}, {"modifiers": [], "name": "mousex", "type": "float"}, {"modifiers": [], "name": "mousey", "type": "float"}, {"modifiers": [], "name": "lastTool", "type": "EditorTool"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MapView", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getTool", "parameters": [], "return_type": "EditorTool"}, {"modifiers": ["public"], "name": "setTool", "parameters": [{"name": "tool", "type": "EditorTool", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isGrid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setGrid", "parameters": [{"name": "grid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "center", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "act", "parameters": [{"name": "delta", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "clampZoom", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "project", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "Point2"}, {"modifiers": ["private"], "name": "unproject", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "Vec2"}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "active", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "pan", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "deltaX", "type": "float", "varargs": false}, {"name": "deltaY", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "zoom", "parameters": [{"name": "initialDistance", "type": "float", "varargs": false}, {"name": "distance", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "pinch", "parameters": [{"name": "initialPointer1", "type": "Vec2", "varargs": false}, {"name": "initialPointer2", "type": "Vec2", "varargs": false}, {"name": "pointer1", "type": "Vec2", "varargs": false}, {"name": "pointer2", "type": "Vec2", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "pinchStop", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getTool_0(_args: Array = []) -> Variant:
	return null

func java_method_setTool_1(_args: Array = []) -> Variant:
	return null

func java_method_isGrid_2(_args: Array = []) -> Variant:
	return null

func java_method_setGrid_3(_args: Array = []) -> Variant:
	return null

func java_method_center_4(_args: Array = []) -> Variant:
	return null

func java_method_act_5(_args: Array = []) -> Variant:
	return null

func java_method_clampZoom_6(_args: Array = []) -> Variant:
	return null

func java_method_project_7(_args: Array = []) -> Variant:
	return null

func java_method_unproject_8(_args: Array = []) -> Variant:
	return null

func java_method_draw_9(_args: Array = []) -> Variant:
	return null

func java_method_active_10(_args: Array = []) -> Variant:
	return null

func java_method_pan_11(_args: Array = []) -> Variant:
	return null

func java_method_zoom_12(_args: Array = []) -> Variant:
	return null

func java_method_pinch_13(_args: Array = []) -> Variant:
	return null

func java_method_pinchStop_14(_args: Array = []) -> Variant:
	return null
