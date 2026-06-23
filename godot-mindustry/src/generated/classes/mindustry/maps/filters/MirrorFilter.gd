# Generated from Mindustry upstream.
# Source: mindustry/maps/filters/MirrorFilter.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.maps.filters"
const JAVA_KIND := "class"
const JAVA_NAME := "MirrorFilter"
const JAVA_EXTENDS := "GenerateFilter"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "v1", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "v2", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "v3", "type": "Vec2"}, {"modifiers": ["public"], "name": "angle", "type": "int"}, {"modifiers": ["public"], "name": "rotate", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "options", "parameters": [], "return_type": "FilterOption"}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "char"}, {"modifiers": ["public"], "name": "apply", "parameters": [{"name": "in", "type": "GenerateInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "image", "type": "Image", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "mirror", "parameters": [{"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}, {"name": "p", "type": "Vec2", "varargs": false}, {"name": "x0", "type": "float", "varargs": false}, {"name": "y0", "type": "float", "varargs": false}, {"name": "x1", "type": "float", "varargs": false}, {"name": "y1", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "left", "parameters": [{"name": "a", "type": "Vec2", "varargs": false}, {"name": "b", "type": "Vec2", "varargs": false}, {"name": "c", "type": "Vec2", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "clipHalfLine", "parameters": [{"name": "v", "type": "Vec2", "varargs": false}, {"name": "xmin", "type": "float", "varargs": false}, {"name": "ymin", "type": "float", "varargs": false}, {"name": "xmax", "type": "float", "varargs": false}, {"name": "ymax", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_options_0(_args: Array = []) -> Variant:
	return null

func java_method_icon_1(_args: Array = []) -> Variant:
	return null

func java_method_apply_2(_args: Array = []) -> Variant:
	return null

func java_method_draw_3(_args: Array = []) -> Variant:
	return null

func java_method_mirror_4(_args: Array = []) -> Variant:
	return null

func java_method_left_5(_args: Array = []) -> Variant:
	return null

func java_method_clipHalfLine_6(_args: Array = []) -> Variant:
	return null
