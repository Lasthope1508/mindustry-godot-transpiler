# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/environment/ColoredFloor.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.environment"
const JAVA_KIND := "class"
const JAVA_NAME := "ColoredFloor"
const JAVA_EXTENDS := "Floor"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "flagIgnoreDifferentColor", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "flagSmoothBlend", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "verts", "type": "float"}, {"modifiers": ["public"], "name": "defaultColor", "type": "Color"}, {"modifiers": ["protected"], "name": "defaultColorRgba", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ColoredFloor", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "buildEditorConfig", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "showColorEdit", "parameters": [{"name": "t", "type": "Table", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getConfig", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "drawBase", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "sample", "parameters": [{"name": "target", "type": "Block", "varargs": false}, {"name": "tx1", "type": "int", "varargs": false}, {"name": "ty1", "type": "int", "varargs": false}, {"name": "tx2", "type": "int", "varargs": false}, {"name": "ty2", "type": "int", "varargs": false}, {"name": "tx3", "type": "int", "varargs": false}, {"name": "ty3", "type": "int", "varargs": false}, {"name": "tx4", "type": "int", "varargs": false}, {"name": "ty4", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "drawOverlay", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "floorChanged", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeEnded", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "editorPicked", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkAutotileSame", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "minimapColor", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_buildEditorConfig_1(_args: Array = []) -> Variant:
	return null

func java_method_showColorEdit_2(_args: Array = []) -> Variant:
	return null

func java_method_getConfig_3(_args: Array = []) -> Variant:
	return null

func java_method_drawBase_4(_args: Array = []) -> Variant:
	return null

func java_method_sample_5(_args: Array = []) -> Variant:
	return null

func java_method_drawOverlay_6(_args: Array = []) -> Variant:
	return null

func java_method_floorChanged_7(_args: Array = []) -> Variant:
	return null

func java_method_placeEnded_8(_args: Array = []) -> Variant:
	return null

func java_method_editorPicked_9(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_10(_args: Array = []) -> Variant:
	return null

func java_method_checkAutotileSame_11(_args: Array = []) -> Variant:
	return null

func java_method_minimapColor_12(_args: Array = []) -> Variant:
	return null
