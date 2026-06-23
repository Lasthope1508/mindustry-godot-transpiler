# Generated from Mindustry upstream.
# Source: mindustry/type/Weather.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "Weather"
const JAVA_EXTENDS := "UnlockableContent"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "rand", "type": "Rand"}, {"modifiers": ["final", "private", "static"], "name": "boundMax", "type": "float"}, {"modifiers": ["public"], "name": "duration", "type": "float"}, {"modifiers": ["public"], "name": "opacityMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "attrs", "type": "Attributes"}, {"modifiers": ["public"], "name": "sound", "type": "Sound"}, {"modifiers": ["public"], "name": "soundVol", "type": "float"}, {"modifiers": ["public"], "name": "soundVolMin", "type": "float"}, {"modifiers": ["public"], "name": "soundVolOscMag", "type": "float"}, {"modifiers": ["public"], "name": "soundVolOscScl", "type": "float"}, {"modifiers": ["public"], "name": "hidden", "type": "boolean"}, {"modifiers": ["public"], "name": "type", "type": "Prov"}, {"modifiers": ["public"], "name": "status", "type": "StatusEffect"}, {"modifiers": ["public"], "name": "statusDuration", "type": "float"}, {"modifiers": ["public"], "name": "statusAir", "type": "boolean"}, {"modifiers": ["public"], "name": "statusGround", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Weather", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "type", "type": "Prov", "varargs": false}]}, {"modifiers": ["public"], "name": "Weather", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "create", "parameters": [], "return_type": "WeatherState"}, {"modifiers": ["public"], "name": "create", "parameters": [{"name": "intensity", "type": "float", "varargs": false}], "return_type": "WeatherState"}, {"modifiers": ["public"], "name": "create", "parameters": [{"name": "intensity", "type": "float", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}], "return_type": "WeatherState"}, {"modifiers": ["public"], "name": "instance", "parameters": [], "return_type": "WeatherState"}, {"modifiers": ["public"], "name": "isActive", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "state", "type": "WeatherState", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateEffect", "parameters": [{"name": "state", "type": "WeatherState", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawOver", "parameters": [{"name": "state", "type": "WeatherState", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawUnder", "parameters": [{"name": "state", "type": "WeatherState", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "drawParticles", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "sizeMin", "type": "float", "varargs": false}, {"name": "sizeMax", "type": "float", "varargs": false}, {"name": "density", "type": "float", "varargs": false}, {"name": "intensity", "type": "float", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}, {"name": "windx", "type": "float", "varargs": false}, {"name": "windy", "type": "float", "varargs": false}, {"name": "minAlpha", "type": "float", "varargs": false}, {"name": "maxAlpha", "type": "float", "varargs": false}, {"name": "sinSclMin", "type": "float", "varargs": false}, {"name": "sinSclMax", "type": "float", "varargs": false}, {"name": "sinMagMin", "type": "float", "varargs": false}, {"name": "sinMagMax", "type": "float", "varargs": false}, {"name": "randomParticleRotation", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "drawRain", "parameters": [{"name": "sizeMin", "type": "float", "varargs": false}, {"name": "sizeMax", "type": "float", "varargs": false}, {"name": "xspeed", "type": "float", "varargs": false}, {"name": "yspeed", "type": "float", "varargs": false}, {"name": "density", "type": "float", "varargs": false}, {"name": "intensity", "type": "float", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "drawSplashes", "parameters": [{"name": "splashes", "type": "TextureRegion", "varargs": false}, {"name": "padding", "type": "float", "varargs": false}, {"name": "density", "type": "float", "varargs": false}, {"name": "intensity", "type": "float", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}, {"name": "timeScale", "type": "float", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "splasher", "type": "Liquid", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "drawNoiseLayers", "parameters": [{"name": "noise", "type": "Texture", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "noisescl", "type": "float", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}, {"name": "baseSpeed", "type": "float", "varargs": false}, {"name": "intensity", "type": "float", "varargs": false}, {"name": "vwindx", "type": "float", "varargs": false}, {"name": "vwindy", "type": "float", "varargs": false}, {"name": "layers", "type": "int", "varargs": false}, {"name": "layerSpeedM", "type": "float", "varargs": false}, {"name": "layerAlphaM", "type": "float", "varargs": false}, {"name": "layerSclM", "type": "float", "varargs": false}, {"name": "layerColorM", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "drawNoise", "parameters": [{"name": "noise", "type": "Texture", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "noisescl", "type": "float", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}, {"name": "baseSpeed", "type": "float", "varargs": false}, {"name": "intensity", "type": "float", "varargs": false}, {"name": "vwindx", "type": "float", "varargs": false}, {"name": "vwindy", "type": "float", "varargs": false}, {"name": "offset", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}, {"modifiers": ["public", "static"], "name": "createWeather", "parameters": [{"name": "weather", "type": "Weather", "varargs": false}, {"name": "intensity", "type": "float", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "windX", "type": "float", "varargs": false}, {"name": "windY", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_create_0(_args: Array = []) -> Variant:
	return null

func java_method_create_1(_args: Array = []) -> Variant:
	return null

func java_method_create_2(_args: Array = []) -> Variant:
	return null

func java_method_instance_3(_args: Array = []) -> Variant:
	return null

func java_method_isActive_4(_args: Array = []) -> Variant:
	return null

func java_method_remove_5(_args: Array = []) -> Variant:
	return null

func java_method_update_6(_args: Array = []) -> Variant:
	return null

func java_method_updateEffect_7(_args: Array = []) -> Variant:
	return null

func java_method_drawOver_8(_args: Array = []) -> Variant:
	return null

func java_method_drawUnder_9(_args: Array = []) -> Variant:
	return null

func java_method_drawParticles_10(_args: Array = []) -> Variant:
	return null

func java_method_drawRain_11(_args: Array = []) -> Variant:
	return null

func java_method_drawSplashes_12(_args: Array = []) -> Variant:
	return null

func java_method_drawNoiseLayers_13(_args: Array = []) -> Variant:
	return null

func java_method_drawNoise_14(_args: Array = []) -> Variant:
	return null

func java_method_isHidden_15(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_16(_args: Array = []) -> Variant:
	return null

func java_method_createWeather_17(_args: Array = []) -> Variant:
	return null
