# Generated from Mindustry upstream.
# Source: mindustry/game/Universe.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "class"
const JAVA_NAME := "Universe"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "seconds", "type": "int"}, {"modifiers": ["private"], "name": "netSeconds", "type": "int"}, {"modifiers": ["private"], "name": "secondCounter", "type": "float"}, {"modifiers": ["private"], "name": "turn", "type": "int"}, {"modifiers": ["private"], "name": "turnCounter", "type": "float"}, {"modifiers": ["private"], "name": "lastLoadout", "type": "Schematic"}, {"modifiers": ["private"], "name": "lastLaunchResources", "type": "ItemSeq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Universe", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "updateGlobal", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "turn", "parameters": [], "return_type": "int"}, {"modifiers": ["private"], "name": "updatePlanet", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "clearLoadoutInfo", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getLaunchResources", "parameters": [], "return_type": "ItemSeq"}, {"modifiers": ["public"], "name": "updateLaunchResources", "parameters": [{"name": "stacks", "type": "ItemSeq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateLoadout", "parameters": [{"name": "block", "type": "CoreBlock", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateLoadout", "parameters": [{"name": "block", "type": "CoreBlock", "varargs": false}, {"name": "schem", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getLastLoadout", "parameters": [], "return_type": "Schematic"}, {"modifiers": ["public"], "name": "getLoadout", "parameters": [{"name": "core", "type": "CoreBlock", "varargs": false}], "return_type": "Schematic"}, {"modifiers": ["public"], "name": "runTurn", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateNetSeconds", "parameters": [{"name": "value", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "secondsMod", "parameters": [{"name": "mod", "type": "float", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "seconds", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "setSeconds", "parameters": [{"name": "seconds", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "secondsf", "parameters": [], "return_type": "float"}, {"modifiers": ["private"], "name": "save", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "load", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_updateGlobal_0(_args: Array = []) -> Variant:
	return null

func java_method_turn_1(_args: Array = []) -> Variant:
	return null

func java_method_updatePlanet_2(_args: Array = []) -> Variant:
	return null

func java_method_update_3(_args: Array = []) -> Variant:
	return null

func java_method_clearLoadoutInfo_4(_args: Array = []) -> Variant:
	return null

func java_method_getLaunchResources_5(_args: Array = []) -> Variant:
	return null

func java_method_updateLaunchResources_6(_args: Array = []) -> Variant:
	return null

func java_method_updateLoadout_7(_args: Array = []) -> Variant:
	return null

func java_method_updateLoadout_8(_args: Array = []) -> Variant:
	return null

func java_method_getLastLoadout_9(_args: Array = []) -> Variant:
	return null

func java_method_getLoadout_10(_args: Array = []) -> Variant:
	return null

func java_method_runTurn_11(_args: Array = []) -> Variant:
	return null

func java_method_updateNetSeconds_12(_args: Array = []) -> Variant:
	return null

func java_method_secondsMod_13(_args: Array = []) -> Variant:
	return null

func java_method_seconds_14(_args: Array = []) -> Variant:
	return null

func java_method_setSeconds_15(_args: Array = []) -> Variant:
	return null

func java_method_secondsf_16(_args: Array = []) -> Variant:
	return null

func java_method_save_17(_args: Array = []) -> Variant:
	return null

func java_method_load_18(_args: Array = []) -> Variant:
	return null
