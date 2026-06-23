# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/environment/CharacterOverlay.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.environment"
const JAVA_KIND := "class"
const JAVA_NAME := "CharacterOverlay"
const JAVA_EXTENDS := "OverlayFloor"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "chars", "type": "String"}, {"modifiers": ["public"], "name": "letterRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "color", "type": "Color"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "CharacterOverlay", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "drawBase", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getConfig", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onPicked", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "buildEditorConfig", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeEnded", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "editorPicked", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "charToData", "parameters": [{"name": "c", "type": "char", "varargs": false}], "return_type": "byte"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_drawBase_0(_args: Array = []) -> Variant:
	return null

func java_method_getConfig_1(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_2(_args: Array = []) -> Variant:
	return null

func java_method_onPicked_3(_args: Array = []) -> Variant:
	return null

func java_method_buildEditorConfig_4(_args: Array = []) -> Variant:
	return null

func java_method_placeEnded_5(_args: Array = []) -> Variant:
	return null

func java_method_editorPicked_6(_args: Array = []) -> Variant:
	return null

func java_method_charToData_7(_args: Array = []) -> Variant:
	return null
