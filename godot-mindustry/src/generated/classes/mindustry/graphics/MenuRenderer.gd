# Generated from Mindustry upstream.
# Source: mindustry/graphics/MenuRenderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "MenuRenderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Disposable"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "darkness", "type": "float"}, {"modifiers": ["final", "private"], "name": "width", "type": "int"}, {"modifiers": ["final", "private"], "name": "height", "type": "int"}, {"modifiers": ["private"], "name": "cacheFloor", "type": "int"}, {"modifiers": ["private"], "name": "cacheWall", "type": "int"}, {"modifiers": ["private"], "name": "camera", "type": "Camera"}, {"modifiers": ["private"], "name": "mat", "type": "Mat"}, {"modifiers": ["private"], "name": "shadows", "type": "FrameBuffer"}, {"modifiers": ["private"], "name": "batch", "type": "CacheBatch"}, {"modifiers": ["private"], "name": "time", "type": "float"}, {"modifiers": ["private"], "name": "flyerRot", "type": "float"}, {"modifiers": ["private"], "name": "flyers", "type": "int"}, {"modifiers": ["private"], "name": "flyerType", "type": "UnitType"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MenuRenderer", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["private"], "name": "generate", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "cache", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "render", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "drawFlyers", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "flyers", "parameters": [{"name": "cons", "type": "Floatc2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_generate_0(_args: Array = []) -> Variant:
	return null

func java_method_cache_1(_args: Array = []) -> Variant:
	return null

func java_method_render_2(_args: Array = []) -> Variant:
	return null

func java_method_drawFlyers_3(_args: Array = []) -> Variant:
	return null

func java_method_flyers_4(_args: Array = []) -> Variant:
	return null

func java_method_dispose_5(_args: Array = []) -> Variant:
	return null
