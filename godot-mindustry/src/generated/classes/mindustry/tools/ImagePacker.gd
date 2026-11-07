# Generated from Mindustry upstream.
# Source: tools/src/mindustry/tools/ImagePacker.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.tools"
const JAVA_KIND := "class"
const JAVA_NAME := "ImagePacker"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["static"], "name": "cache", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "main", "parameters": [{"name": "args", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "fixSubdirectory", "parameters": [{"name": "dir", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "texname", "parameters": [{"name": "c", "type": "UnlockableContent", "varargs": false}], "return_type": "String"}, {"modifiers": ["static"], "name": "generate", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "get", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Pixmap"}, {"modifiers": ["static"], "name": "has", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["static"], "name": "get", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}], "return_type": "Pixmap"}, {"modifiers": ["static"], "name": "save", "parameters": [{"name": "pix", "type": "Pixmap", "varargs": false}, {"name": "path", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "drawCenter", "parameters": [{"name": "pix", "type": "Pixmap", "varargs": false}, {"name": "other", "type": "Pixmap", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "saveScaled", "parameters": [{"name": "pix", "type": "Pixmap", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "size", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "drawScaledFit", "parameters": [{"name": "base", "type": "Pixmap", "varargs": false}, {"name": "image", "type": "Pixmap", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "delete", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "replace", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "image", "type": "Pixmap", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "replace", "parameters": [{"name": "path", "type": "String", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "image", "type": "Pixmap", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "replace", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "image", "type": "Pixmap", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "err", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "args", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["static"], "name": "validate", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_main_0(_args: Array = []) -> Variant:
	return null

func java_method_fixSubdirectory_1(_args: Array = []) -> Variant:
	return null

func java_method_texname_2(_args: Array = []) -> Variant:
	return null

func java_method_generate_3(_args: Array = []) -> Variant:
	return null

func java_method_get_4(_args: Array = []) -> Variant:
	return null

func java_method_has_5(_args: Array = []) -> Variant:
	return null

func java_method_get_6(_args: Array = []) -> Variant:
	return null

func java_method_save_7(_args: Array = []) -> Variant:
	return null

func java_method_drawCenter_8(_args: Array = []) -> Variant:
	return null

func java_method_saveScaled_9(_args: Array = []) -> Variant:
	return null

func java_method_drawScaledFit_10(_args: Array = []) -> Variant:
	return null

func java_method_delete_11(_args: Array = []) -> Variant:
	return null

func java_method_replace_12(_args: Array = []) -> Variant:
	return null

func java_method_replace_13(_args: Array = []) -> Variant:
	return null

func java_method_replace_14(_args: Array = []) -> Variant:
	return null

func java_method_err_15(_args: Array = []) -> Variant:
	return null

func java_method_validate_16(_args: Array = []) -> Variant:
	return null
