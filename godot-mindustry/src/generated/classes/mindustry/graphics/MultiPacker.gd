# Generated from Mindustry upstream.
# Source: mindustry/graphics/MultiPacker.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "MultiPacker"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Disposable"]
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "packers", "type": "PixmapPacker"}, {"modifiers": ["private"], "name": "outlined", "type": "ObjectSet"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MultiPacker", "parameters": []}, {"modifiers": ["public"], "name": "MultiPacker", "parameters": [{"name": "initialize", "type": "boolean", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "get", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}], "return_type": "PixmapRegion"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "region", "type": "String", "varargs": false}], "return_type": "PixmapRegion"}, {"modifiers": ["public"], "name": "getPacked", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "PixmapRegion"}, {"modifiers": ["public"], "name": "printStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "registerOutlined", "parameters": [{"name": "named", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isOutlined", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "has", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "has", "parameters": [{"name": "type", "type": "PageType", "varargs": false}, {"name": "name", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "type", "type": "PageType", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "region", "type": "PixmapRegion", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "type", "type": "PageType", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "region", "type": "PixmapRegion", "varargs": false}, {"name": "splits", "type": "int", "varargs": false}, {"name": "pads", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "type", "type": "PageType", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "pix", "type": "Pixmap", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "flush", "parameters": [{"name": "filter", "type": "TextureFilter", "varargs": false}, {"name": "atlas", "type": "TextureAtlas", "varargs": false}], "return_type": "TextureAtlas"}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_get_0(_args: Array = []) -> Variant:
	return null

func java_method_get_1(_args: Array = []) -> Variant:
	return null

func java_method_getPacked_2(_args: Array = []) -> Variant:
	return null

func java_method_printStats_3(_args: Array = []) -> Variant:
	return null

func java_method_registerOutlined_4(_args: Array = []) -> Variant:
	return null

func java_method_isOutlined_5(_args: Array = []) -> Variant:
	return null

func java_method_has_6(_args: Array = []) -> Variant:
	return null

func java_method_has_7(_args: Array = []) -> Variant:
	return null

func java_method_add_8(_args: Array = []) -> Variant:
	return null

func java_method_add_9(_args: Array = []) -> Variant:
	return null

func java_method_add_10(_args: Array = []) -> Variant:
	return null

func java_method_flush_11(_args: Array = []) -> Variant:
	return null

func java_method_dispose_12(_args: Array = []) -> Variant:
	return null
