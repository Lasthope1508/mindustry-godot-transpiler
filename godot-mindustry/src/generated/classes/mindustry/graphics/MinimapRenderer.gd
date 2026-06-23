# Generated from Mindustry upstream.
# Source: mindustry/graphics/MinimapRenderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "MinimapRenderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "baseSize", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "updateInterval", "type": "float"}, {"modifiers": ["final", "private"], "name": "units", "type": "Seq"}, {"modifiers": ["private"], "name": "pixmap", "type": "Pixmap"}, {"modifiers": ["private"], "name": "texture", "type": "Texture"}, {"modifiers": ["private"], "name": "region", "type": "TextureRegion"}, {"modifiers": ["private"], "name": "rect", "type": "Rect"}, {"modifiers": ["private"], "name": "zoom", "type": "float"}, {"modifiers": ["private"], "name": "updates", "type": "IntSet"}, {"modifiers": ["private"], "name": "updateCounter", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MinimapRenderer", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getPixmap", "parameters": [], "return_type": "Pixmap"}, {"modifiers": ["public"], "name": "getTexture", "parameters": [], "return_type": "Texture"}, {"modifiers": ["public"], "name": "zoomBy", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setZoom", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getZoom", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawEntities", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "w", "type": "float", "varargs": false}, {"name": "h", "type": "float", "varargs": false}, {"name": "fullView", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSpawns", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getRegion", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "updateAll", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updatePixel", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateUnitArray", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "realBlock", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Block"}, {"modifiers": ["private"], "name": "colorFor", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "drawLabel", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "text", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "scaleFactor", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawLabel", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "text", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "scaleFactor", "type": "float", "varargs": false}, {"name": "bg", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_update_0(_args: Array = []) -> Variant:
	return null

func java_method_getPixmap_1(_args: Array = []) -> Variant:
	return null

func java_method_getTexture_2(_args: Array = []) -> Variant:
	return null

func java_method_zoomBy_3(_args: Array = []) -> Variant:
	return null

func java_method_setZoom_4(_args: Array = []) -> Variant:
	return null

func java_method_getZoom_5(_args: Array = []) -> Variant:
	return null

func java_method_reset_6(_args: Array = []) -> Variant:
	return null

func java_method_drawEntities_7(_args: Array = []) -> Variant:
	return null

func java_method_drawSpawns_8(_args: Array = []) -> Variant:
	return null

func java_method_getRegion_9(_args: Array = []) -> Variant:
	return null

func java_method_updateAll_10(_args: Array = []) -> Variant:
	return null

func java_method_update_11(_args: Array = []) -> Variant:
	return null

func java_method_updatePixel_12(_args: Array = []) -> Variant:
	return null

func java_method_updateUnitArray_13(_args: Array = []) -> Variant:
	return null

func java_method_realBlock_14(_args: Array = []) -> Variant:
	return null

func java_method_colorFor_15(_args: Array = []) -> Variant:
	return null

func java_method_drawLabel_16(_args: Array = []) -> Variant:
	return null

func java_method_drawLabel_17(_args: Array = []) -> Variant:
	return null
