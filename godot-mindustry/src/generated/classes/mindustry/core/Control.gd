# Generated from Mindustry upstream.
# Source: mindustry/core/Control.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.core"
const JAVA_KIND := "class"
const JAVA_NAME := "Control"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["ApplicationListener", "Loadable"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "saves", "type": "Saves"}, {"modifiers": ["public"], "name": "sound", "type": "SoundControl"}, {"modifiers": ["public"], "name": "input", "type": "InputHandler"}, {"modifiers": ["public"], "name": "indicators", "type": "AttackIndicators"}, {"modifiers": ["public"], "name": "lastDamagedCore", "type": "CoreBuild"}, {"modifiers": ["private"], "name": "timer", "type": "Interval"}, {"modifiers": ["private"], "name": "hiscore", "type": "boolean"}, {"modifiers": ["private"], "name": "wasPaused", "type": "boolean"}, {"modifiers": ["private"], "name": "backgroundPaused", "type": "boolean"}, {"modifiers": ["private"], "name": "toBePlaced", "type": "Seq"}, {"modifiers": ["private"], "name": "toBePlacedConfigs", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Control", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["private"], "name": "forcePlaceAll", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "configurePlaced", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "placeLandBuild", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "loadAsync", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "loadSync", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkAutoUnlocks", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "createPlayer", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setInput", "parameters": [{"name": "newInput", "type": "InputHandler", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "playMap", "parameters": [{"name": "map", "type": "Map", "varargs": false}, {"name": "rules", "type": "Rules", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "playMap", "parameters": [{"name": "map", "type": "Map", "varargs": false}, {"name": "rules", "type": "Rules", "varargs": false}, {"name": "playtest", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "playSector", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "playSector", "parameters": [{"name": "origin", "type": "Sector", "varargs": false}, {"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "playSector", "parameters": [{"name": "origin", "type": "Sector", "varargs": false}, {"name": "sector", "type": "Sector", "varargs": false}, {"name": "reloader", "type": "WorldReloader", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "playNewSector", "parameters": [{"name": "origin", "type": "Sector", "varargs": false}, {"name": "sector", "type": "Sector", "varargs": false}, {"name": "reloader", "type": "WorldReloader", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "playNewSector", "parameters": [{"name": "origin", "type": "Sector", "varargs": false}, {"name": "sector", "type": "Sector", "varargs": false}, {"name": "reloader", "type": "WorldReloader", "varargs": false}, {"name": "params", "type": "WorldParams", "varargs": false}, {"name": "beforePlay", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isHighScore", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "pause", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "resume", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_forcePlaceAll_0(_args: Array = []) -> Variant:
	return null

func java_method_configurePlaced_1(_args: Array = []) -> Variant:
	return null

func java_method_placeLandBuild_2(_args: Array = []) -> Variant:
	return null

func java_method_loadAsync_3(_args: Array = []) -> Variant:
	return null

func java_method_loadSync_4(_args: Array = []) -> Variant:
	return null

func java_method_checkAutoUnlocks_5(_args: Array = []) -> Variant:
	return null

func java_method_createPlayer_6(_args: Array = []) -> Variant:
	return null

func java_method_setInput_7(_args: Array = []) -> Variant:
	return null

func java_method_playMap_8(_args: Array = []) -> Variant:
	return null

func java_method_playMap_9(_args: Array = []) -> Variant:
	return null

func java_method_playSector_10(_args: Array = []) -> Variant:
	return null

func java_method_playSector_11(_args: Array = []) -> Variant:
	return null

func java_method_playSector_12(_args: Array = []) -> Variant:
	return null

func java_method_playNewSector_13(_args: Array = []) -> Variant:
	return null

func java_method_playNewSector_14(_args: Array = []) -> Variant:
	return null

func java_method_isHighScore_15(_args: Array = []) -> Variant:
	return null

func java_method_dispose_16(_args: Array = []) -> Variant:
	return null

func java_method_pause_17(_args: Array = []) -> Variant:
	return null

func java_method_resume_18(_args: Array = []) -> Variant:
	return null

func java_method_init_19(_args: Array = []) -> Variant:
	return null

func java_method_update_20(_args: Array = []) -> Variant:
	return null
