# Generated from Mindustry upstream.
# Source: mindustry/graphics/LoadRenderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "LoadRenderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Disposable"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "color", "type": "Color"}, {"modifiers": ["final", "private", "static"], "name": "colorRed", "type": "Color"}, {"modifiers": ["final", "private", "static"], "name": "red", "type": "String"}, {"modifiers": ["final", "private", "static"], "name": "orange", "type": "String"}, {"modifiers": ["final", "private", "static"], "name": "floats", "type": "FloatSeq"}, {"modifiers": ["final", "private", "static"], "name": "preview", "type": "boolean"}, {"modifiers": ["private"], "name": "testprogress", "type": "float"}, {"modifiers": ["private"], "name": "assetText", "type": "StringBuilder"}, {"modifiers": ["private"], "name": "bars", "type": "Bar"}, {"modifiers": ["private"], "name": "mesh", "type": "Mesh"}, {"modifiers": ["private"], "name": "cam", "type": "Camera3D"}, {"modifiers": ["private"], "name": "lastLength", "type": "int"}, {"modifiers": ["private"], "name": "fx", "type": "FxProcessor"}, {"modifiers": ["private"], "name": "renderTimes", "type": "WindowedMean"}, {"modifiers": ["private"], "name": "bloom", "type": "BloomFilter"}, {"modifiers": ["private"], "name": "renderStencil", "type": "boolean"}, {"modifiers": ["private"], "name": "lastFrameTime", "type": "long"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_dispose_0(_args: Array = []) -> Variant:
	return null

func java_method_draw_1(_args: Array = []) -> Variant:
	return null
