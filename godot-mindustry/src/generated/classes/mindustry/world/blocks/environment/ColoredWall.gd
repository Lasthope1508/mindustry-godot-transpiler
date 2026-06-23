# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/environment/ColoredWall.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.environment"
const JAVA_KIND := "class"
const JAVA_NAME := "ColoredWall"
const JAVA_EXTENDS := "StaticWall"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "flagIgnoreDifferentColor", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "flagApplyDarkness", "type": "int"}, {"modifiers": ["public"], "name": "defaultColor", "type": "Color"}, {"modifiers": ["protected"], "name": "defaultColorRgba", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ColoredWall", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getConfig", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "buildEditorConfig", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBase", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "blockChanged", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeEnded", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "editorPicked", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkAutotileSame", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isDarkened", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "minimapColor", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_getConfig_1(_args: Array = []) -> Variant:
	return null

func java_method_buildEditorConfig_2(_args: Array = []) -> Variant:
	return null

func java_method_drawBase_3(_args: Array = []) -> Variant:
	return null

func java_method_blockChanged_4(_args: Array = []) -> Variant:
	return null

func java_method_placeEnded_5(_args: Array = []) -> Variant:
	return null

func java_method_editorPicked_6(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_7(_args: Array = []) -> Variant:
	return null

func java_method_checkAutotileSame_8(_args: Array = []) -> Variant:
	return null

func java_method_isDarkened_9(_args: Array = []) -> Variant:
	return null

func java_method_minimapColor_10(_args: Array = []) -> Variant:
	return null
