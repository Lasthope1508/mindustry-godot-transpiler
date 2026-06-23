# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/logic/CanvasBlock.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "CanvasBlock"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "padding", "type": "float"}, {"modifiers": ["public"], "name": "canvasSize", "type": "int"}, {"modifiers": ["public"], "name": "palette", "type": "int"}, {"modifiers": ["public"], "name": "bitsPerPixel", "type": "int"}, {"modifiers": ["public"], "name": "colorToIndex", "type": "IntIntMap"}, {"modifiers": ["public"], "name": "side1", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "side2", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "corner1", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "corner2", "type": "TextureRegion"}, {"modifiers": ["protected"], "name": "previewPixmap", "type": "Pixmap"}, {"modifiers": ["protected"], "name": "previewTexture", "type": "Texture"}, {"modifiers": ["protected"], "name": "tempBlend", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "CanvasBlock", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setPaletteFromString", "parameters": [{"name": "value", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "makePixmap", "parameters": [{"name": "data", "type": "byte", "varargs": false}, {"name": "target", "type": "Pixmap", "varargs": false}], "return_type": "Pixmap"}, {"modifiers": ["protected"], "name": "getByte", "parameters": [{"name": "data", "type": "byte", "varargs": false}, {"name": "bitOffset", "type": "int", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setPaletteFromString_0(_args: Array = []) -> Variant:
	return null

func java_method_init_1(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_2(_args: Array = []) -> Variant:
	return null

func java_method_makePixmap_3(_args: Array = []) -> Variant:
	return null

func java_method_getByte_4(_args: Array = []) -> Variant:
	return null
