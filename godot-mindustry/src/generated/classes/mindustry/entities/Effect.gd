# Generated from Mindustry upstream.
# Source: mindustry/entities/Effect.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities"
const JAVA_KIND := "class"
const JAVA_NAME := "Effect"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "shakeFalloff", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "container", "type": "EffectContainer"}, {"modifiers": ["final", "public", "static"], "name": "all", "type": "Seq"}, {"modifiers": ["private"], "name": "initialized", "type": "boolean"}, {"modifiers": ["final", "public"], "name": "id", "type": "int"}, {"modifiers": ["public"], "name": "renderer", "type": "Cons"}, {"modifiers": ["public"], "name": "lifetime", "type": "float"}, {"modifiers": ["public"], "name": "clip", "type": "float"}, {"modifiers": ["public"], "name": "startDelay", "type": "float"}, {"modifiers": ["public"], "name": "baseRotation", "type": "float"}, {"modifiers": ["public"], "name": "followParent", "type": "boolean"}, {"modifiers": ["public"], "name": "rotWithParent", "type": "boolean"}, {"modifiers": ["public"], "name": "layer", "type": "float"}, {"modifiers": ["public"], "name": "layerDuration", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Effect", "parameters": [{"name": "life", "type": "float", "varargs": false}, {"name": "clipsize", "type": "float", "varargs": false}, {"name": "renderer", "type": "Cons", "varargs": false}]}, {"modifiers": ["public"], "name": "Effect", "parameters": [{"name": "life", "type": "float", "varargs": false}, {"name": "renderer", "type": "Cons", "varargs": false}]}, {"modifiers": ["public"], "name": "Effect", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "startDelay", "parameters": [{"name": "d", "type": "float", "varargs": false}], "return_type": "Effect"}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "followParent", "parameters": [{"name": "follow", "type": "boolean", "varargs": false}], "return_type": "Effect"}, {"modifiers": ["public"], "name": "rotWithParent", "parameters": [{"name": "follow", "type": "boolean", "varargs": false}], "return_type": "Effect"}, {"modifiers": ["public"], "name": "layer", "parameters": [{"name": "l", "type": "float", "varargs": false}], "return_type": "Effect"}, {"modifiers": ["public"], "name": "baseRotation", "parameters": [{"name": "d", "type": "float", "varargs": false}], "return_type": "Effect"}, {"modifiers": ["public"], "name": "layer", "parameters": [{"name": "l", "type": "float", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}], "return_type": "Effect"}, {"modifiers": ["public"], "name": "wrap", "parameters": [{"name": "color", "type": "Color", "varargs": false}], "return_type": "WrapEffect"}, {"modifiers": ["public"], "name": "wrap", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": "WrapEffect"}, {"modifiers": ["public"], "name": "at", "parameters": [{"name": "pos", "type": "Position", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "at", "parameters": [{"name": "pos", "type": "Position", "varargs": false}, {"name": "parentize", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "at", "parameters": [{"name": "pos", "type": "Position", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "at", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "at", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "at", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "at", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "at", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "data", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "at", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "data", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "shouldCreate", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "create", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "data", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "add", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "data", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "render", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "life", "type": "float", "varargs": false}, {"name": "lifetime", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "data", "type": "Object", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "render", "parameters": [{"name": "e", "type": "EffectContainer", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "get", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "Effect"}, {"modifiers": ["private", "static"], "name": "shake", "parameters": [{"name": "intensity", "type": "float", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "shake", "parameters": [{"name": "intensity", "type": "float", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "shake", "parameters": [{"name": "intensity", "type": "float", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "loc", "type": "Position", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "floorDust", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "size", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "floorDustAngle", "parameters": [{"name": "effect", "type": "Effect", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "angle", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "decal", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "decal", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "lifetime", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "scorch", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "size", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "rubble", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "blockSize", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "shockwaveDust", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "shockwaveDust", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}, {"name": "density", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_startDelay_0(_args: Array = []) -> Variant:
	return null

func java_method_init_1(_args: Array = []) -> Variant:
	return null

func java_method_followParent_2(_args: Array = []) -> Variant:
	return null

func java_method_rotWithParent_3(_args: Array = []) -> Variant:
	return null

func java_method_layer_4(_args: Array = []) -> Variant:
	return null

func java_method_baseRotation_5(_args: Array = []) -> Variant:
	return null

func java_method_layer_6(_args: Array = []) -> Variant:
	return null

func java_method_wrap_7(_args: Array = []) -> Variant:
	return null

func java_method_wrap_8(_args: Array = []) -> Variant:
	return null

func java_method_at_9(_args: Array = []) -> Variant:
	return null

func java_method_at_10(_args: Array = []) -> Variant:
	return null

func java_method_at_11(_args: Array = []) -> Variant:
	return null

func java_method_at_12(_args: Array = []) -> Variant:
	return null

func java_method_at_13(_args: Array = []) -> Variant:
	return null

func java_method_at_14(_args: Array = []) -> Variant:
	return null

func java_method_at_15(_args: Array = []) -> Variant:
	return null

func java_method_at_16(_args: Array = []) -> Variant:
	return null

func java_method_at_17(_args: Array = []) -> Variant:
	return null

func java_method_shouldCreate_18(_args: Array = []) -> Variant:
	return null

func java_method_create_19(_args: Array = []) -> Variant:
	return null

func java_method_add_20(_args: Array = []) -> Variant:
	return null

func java_method_render_21(_args: Array = []) -> Variant:
	return null

func java_method_render_22(_args: Array = []) -> Variant:
	return null

func java_method_get_23(_args: Array = []) -> Variant:
	return null

func java_method_shake_24(_args: Array = []) -> Variant:
	return null

func java_method_shake_25(_args: Array = []) -> Variant:
	return null

func java_method_shake_26(_args: Array = []) -> Variant:
	return null

func java_method_floorDust_27(_args: Array = []) -> Variant:
	return null

func java_method_floorDustAngle_28(_args: Array = []) -> Variant:
	return null

func java_method_decal_29(_args: Array = []) -> Variant:
	return null

func java_method_decal_30(_args: Array = []) -> Variant:
	return null

func java_method_scorch_31(_args: Array = []) -> Variant:
	return null

func java_method_rubble_32(_args: Array = []) -> Variant:
	return null

func java_method_shockwaveDust_33(_args: Array = []) -> Variant:
	return null

func java_method_shockwaveDust_34(_args: Array = []) -> Variant:
	return null
