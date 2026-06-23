# Generated from Mindustry upstream.
# Source: mindustry/maps/planet/SerpuloPlanetGenerator.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.maps.planet"
const JAVA_KIND := "class"
const JAVA_NAME := "SerpuloPlanetGenerator"
const JAVA_EXTENDS := "PlanetGenerator"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public", "static"], "name": "indirectPaths", "type": "boolean"}, {"modifiers": ["public", "static"], "name": "genLakes", "type": "boolean"}, {"modifiers": [], "name": "basegen", "type": "BaseGenerator"}, {"modifiers": [], "name": "heightYOffset", "type": "float"}, {"modifiers": [], "name": "scl", "type": "float"}, {"modifiers": [], "name": "waterOffset", "type": "float"}, {"modifiers": [], "name": "heightScl", "type": "float"}, {"modifiers": [], "name": "arr", "type": "Block"}, {"modifiers": [], "name": "dec", "type": "ObjectMap"}, {"modifiers": [], "name": "tars", "type": "ObjectMap"}, {"modifiers": [], "name": "water", "type": "float"}, {"modifiers": [], "name": "basePos", "type": "Vec3"}, {"modifiers": ["static"], "name": "metalDstScl", "type": "double"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": [], "name": "rawHeight", "parameters": [{"name": "position", "type": "Vec3", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "onSectorCaptured", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onSectorLost", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "beforeSaveWrite", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isEmissive", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "allowNumberedLaunch", "parameters": [{"name": "s", "type": "Sector", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "allowLanding", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "findLaunchCandidate", "parameters": [{"name": "destination", "type": "Sector", "varargs": false}, {"name": "selected", "type": "Sector", "varargs": false}], "return_type": "Sector"}, {"modifiers": ["public"], "name": "getLockedText", "parameters": [{"name": "hovered", "type": "Sector", "varargs": false}, {"name": "out", "type": "StringBuilder", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getHeight", "parameters": [{"name": "position", "type": "Vec3", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getColor", "parameters": [{"name": "position", "type": "Vec3", "varargs": false}, {"name": "out", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getEmissiveColor", "parameters": [{"name": "position", "type": "Vec3", "varargs": false}, {"name": "out", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "genTile", "parameters": [{"name": "position", "type": "Vec3", "varargs": false}, {"name": "tile", "type": "TileGen", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "getBlock", "parameters": [{"name": "position", "type": "Vec3", "varargs": false}, {"name": "visualOnly", "type": "boolean", "varargs": false}], "return_type": "Block"}, {"modifiers": ["protected"], "name": "noise", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "octaves", "type": "double", "varargs": false}, {"name": "falloff", "type": "double", "varargs": false}, {"name": "scl", "type": "double", "varargs": false}, {"name": "mag", "type": "double", "varargs": false}], "return_type": "float"}, {"modifiers": ["protected"], "name": "generate", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "postGenerate", "parameters": [{"name": "tiles", "type": "Tiles", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_rawHeight_0(_args: Array = []) -> Variant:
	return null

func java_method_onSectorCaptured_1(_args: Array = []) -> Variant:
	return null

func java_method_onSectorLost_2(_args: Array = []) -> Variant:
	return null

func java_method_beforeSaveWrite_3(_args: Array = []) -> Variant:
	return null

func java_method_isEmissive_4(_args: Array = []) -> Variant:
	return null

func java_method_allowNumberedLaunch_5(_args: Array = []) -> Variant:
	return null

func java_method_allowLanding_6(_args: Array = []) -> Variant:
	return null

func java_method_findLaunchCandidate_7(_args: Array = []) -> Variant:
	return null

func java_method_getLockedText_8(_args: Array = []) -> Variant:
	return null

func java_method_getHeight_9(_args: Array = []) -> Variant:
	return null

func java_method_getColor_10(_args: Array = []) -> Variant:
	return null

func java_method_getEmissiveColor_11(_args: Array = []) -> Variant:
	return null

func java_method_genTile_12(_args: Array = []) -> Variant:
	return null

func java_method_getBlock_13(_args: Array = []) -> Variant:
	return null

func java_method_noise_14(_args: Array = []) -> Variant:
	return null

func java_method_generate_15(_args: Array = []) -> Variant:
	return null

func java_method_postGenerate_16(_args: Array = []) -> Variant:
	return null
