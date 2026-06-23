# Generated from Mindustry upstream.
# Source: mindustry/editor/MapEditor.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "MapEditor"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "brushSizes", "type": "float"}, {"modifiers": ["public"], "name": "tags", "type": "StringMap"}, {"modifiers": ["public"], "name": "renderer", "type": "EditorRenderer"}, {"modifiers": ["final", "private"], "name": "context", "type": "Context"}, {"modifiers": ["private"], "name": "stack", "type": "OperationStack"}, {"modifiers": ["private"], "name": "currentOp", "type": "DrawOperation"}, {"modifiers": ["private"], "name": "loading", "type": "boolean"}, {"modifiers": ["public"], "name": "brushSize", "type": "float"}, {"modifiers": ["public"], "name": "rotation", "type": "int"}, {"modifiers": ["public"], "name": "drawBlock", "type": "Block"}, {"modifiers": ["public"], "name": "drawTeam", "type": "Team"}, {"modifiers": ["public"], "name": "showTerrain", "type": "boolean"}, {"modifiers": ["public"], "name": "showFloor", "type": "boolean"}, {"modifiers": ["public"], "name": "showBuildings", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "isLoading", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "beginEdit", "parameters": [{"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "beginEdit", "parameters": [{"name": "map", "type": "Map", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "beginEdit", "parameters": [{"name": "pixmap", "type": "Pixmap", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateRenderer", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [{"name": "r", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "createTiles", "parameters": [{"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "createMap", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "Map"}, {"modifiers": ["private"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "tiles", "parameters": [], "return_type": "Tiles"}, {"modifiers": ["public"], "name": "tile", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "width", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "height", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "drawBlocksReplace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBlocks", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBlocks", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "tester", "type": "Boolf", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBlocks", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "square", "type": "boolean", "varargs": false}, {"name": "forceOverlay", "type": "boolean", "varargs": false}, {"name": "tester", "type": "Boolf", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "hasOverlap", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "addCliffs", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawCircle", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "drawer", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSquare", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "drawer", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "resize", "parameters": [{"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}, {"name": "shiftX", "type": "int", "varargs": false}, {"name": "shiftY", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "clearOp", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "undo", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "redo", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "canUndo", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canRedo", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "flushOp", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "addTileOp", "parameters": [{"name": "data", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "ops", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "removeLastOps", "parameters": [{"name": "amount", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_isLoading_0(_args: Array = []) -> Variant:
	return null

func java_method_beginEdit_1(_args: Array = []) -> Variant:
	return null

func java_method_beginEdit_2(_args: Array = []) -> Variant:
	return null

func java_method_beginEdit_3(_args: Array = []) -> Variant:
	return null

func java_method_updateRenderer_4(_args: Array = []) -> Variant:
	return null

func java_method_load_5(_args: Array = []) -> Variant:
	return null

func java_method_createTiles_6(_args: Array = []) -> Variant:
	return null

func java_method_createMap_7(_args: Array = []) -> Variant:
	return null

func java_method_reset_8(_args: Array = []) -> Variant:
	return null

func java_method_tiles_9(_args: Array = []) -> Variant:
	return null

func java_method_tile_10(_args: Array = []) -> Variant:
	return null

func java_method_width_11(_args: Array = []) -> Variant:
	return null

func java_method_height_12(_args: Array = []) -> Variant:
	return null

func java_method_drawBlocksReplace_13(_args: Array = []) -> Variant:
	return null

func java_method_drawBlocks_14(_args: Array = []) -> Variant:
	return null

func java_method_drawBlocks_15(_args: Array = []) -> Variant:
	return null

func java_method_drawBlocks_16(_args: Array = []) -> Variant:
	return null

func java_method_hasOverlap_17(_args: Array = []) -> Variant:
	return null

func java_method_addCliffs_18(_args: Array = []) -> Variant:
	return null

func java_method_drawCircle_19(_args: Array = []) -> Variant:
	return null

func java_method_drawSquare_20(_args: Array = []) -> Variant:
	return null

func java_method_resize_21(_args: Array = []) -> Variant:
	return null

func java_method_clearOp_22(_args: Array = []) -> Variant:
	return null

func java_method_undo_23(_args: Array = []) -> Variant:
	return null

func java_method_redo_24(_args: Array = []) -> Variant:
	return null

func java_method_canUndo_25(_args: Array = []) -> Variant:
	return null

func java_method_canRedo_26(_args: Array = []) -> Variant:
	return null

func java_method_flushOp_27(_args: Array = []) -> Variant:
	return null

func java_method_addTileOp_28(_args: Array = []) -> Variant:
	return null

func java_method_ops_29(_args: Array = []) -> Variant:
	return null

func java_method_removeLastOps_30(_args: Array = []) -> Variant:
	return null
