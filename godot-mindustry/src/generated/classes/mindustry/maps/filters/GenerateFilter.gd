# Generated from Mindustry upstream.
# Source: mindustry/maps/filters/GenerateFilter.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.maps.filters"
const JAVA_KIND := "class"
const JAVA_NAME := "GenerateFilter"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Cloneable", "Serializable"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "seed", "type": "int"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "tiles", "type": "Tiles", "varargs": false}, {"name": "in", "type": "GenerateInput", "varargs": false}], "return_type": ""}, {"modifiers": ["abstract", "public"], "name": "options", "parameters": [], "return_type": "FilterOption"}, {"modifiers": ["public"], "name": "apply", "parameters": [{"name": "in", "type": "GenerateInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "image", "type": "Image", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "simpleName", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "name", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "char"}, {"modifiers": ["public"], "name": "randomize", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isBuffered", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isPost", "parameters": [], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "noise", "parameters": [{"name": "seedOffset", "type": "int", "varargs": false}, {"name": "in", "type": "GenerateInput", "varargs": false}, {"name": "scl", "type": "float", "varargs": false}, {"name": "mag", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["protected"], "name": "noise", "parameters": [{"name": "in", "type": "GenerateInput", "varargs": false}, {"name": "scl", "type": "float", "varargs": false}, {"name": "mag", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["protected"], "name": "noise", "parameters": [{"name": "in", "type": "GenerateInput", "varargs": false}, {"name": "scl", "type": "float", "varargs": false}, {"name": "mag", "type": "float", "varargs": false}, {"name": "octaves", "type": "float", "varargs": false}, {"name": "persistence", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["protected"], "name": "noise", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "scl", "type": "float", "varargs": false}, {"name": "mag", "type": "float", "varargs": false}, {"name": "octaves", "type": "float", "varargs": false}, {"name": "persistence", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["protected"], "name": "rnoise", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "scl", "type": "float", "varargs": false}, {"name": "mag", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["protected"], "name": "rnoise", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "octaves", "type": "int", "varargs": false}, {"name": "scl", "type": "float", "varargs": false}, {"name": "falloff", "type": "float", "varargs": false}, {"name": "mag", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["protected"], "name": "chance", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "GenerateFilter"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	return null

func java_method_options_1(_args: Array = []) -> Variant:
	return null

func java_method_apply_2(_args: Array = []) -> Variant:
	return null

func java_method_draw_3(_args: Array = []) -> Variant:
	return null

func java_method_simpleName_4(_args: Array = []) -> Variant:
	return null

func java_method_name_5(_args: Array = []) -> Variant:
	return null

func java_method_icon_6(_args: Array = []) -> Variant:
	return null

func java_method_randomize_7(_args: Array = []) -> Variant:
	return null

func java_method_isBuffered_8(_args: Array = []) -> Variant:
	return null

func java_method_isPost_9(_args: Array = []) -> Variant:
	return null

func java_method_noise_10(_args: Array = []) -> Variant:
	return null

func java_method_noise_11(_args: Array = []) -> Variant:
	return null

func java_method_noise_12(_args: Array = []) -> Variant:
	return null

func java_method_noise_13(_args: Array = []) -> Variant:
	return null

func java_method_rnoise_14(_args: Array = []) -> Variant:
	return null

func java_method_rnoise_15(_args: Array = []) -> Variant:
	return null

func java_method_chance_16(_args: Array = []) -> Variant:
	return null

func java_method_copy_17(_args: Array = []) -> Variant:
	return null
