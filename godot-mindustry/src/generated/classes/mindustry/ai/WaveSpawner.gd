# Generated from Mindustry upstream.
# Source: mindustry/ai/WaveSpawner.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "WaveSpawner"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "margin", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "coreMargin", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "maxSteps", "type": "float"}, {"modifiers": ["private"], "name": "tmpCount", "type": "int"}, {"modifiers": ["private"], "name": "spawns", "type": "Seq"}, {"modifiers": ["private"], "name": "spawning", "type": "boolean"}, {"modifiers": ["private"], "name": "any", "type": "boolean"}, {"modifiers": ["private"], "name": "firstSpawn", "type": "Tile"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "WaveSpawner", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getFirstSpawn", "parameters": [], "return_type": "Tile"}, {"modifiers": ["public"], "name": "countSpawns", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "getSpawns", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "playerNear", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "spawnEnemies", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "spawnUnit", "parameters": [{"name": "group", "type": "SpawnGroup", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "doShockwave", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "eachGroundSpawn", "parameters": [{"name": "cons", "type": "Intc2", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "eachGroundSpawn", "parameters": [{"name": "filterPos", "type": "int", "varargs": false}, {"name": "cons", "type": "SpawnConsumer", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "eachFlyerSpawn", "parameters": [{"name": "filterPos", "type": "int", "varargs": false}, {"name": "cons", "type": "Floatc2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "countGroundSpawns", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "countFlyerSpawns", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "isSpawning", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "spawnEffect", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "spawnEffect", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "u", "type": "UnitType", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getFirstSpawn_0(_args: Array = []) -> Variant:
	return null

func java_method_countSpawns_1(_args: Array = []) -> Variant:
	return null

func java_method_getSpawns_2(_args: Array = []) -> Variant:
	return null

func java_method_playerNear_3(_args: Array = []) -> Variant:
	return null

func java_method_spawnEnemies_4(_args: Array = []) -> Variant:
	return null

func java_method_spawnUnit_5(_args: Array = []) -> Variant:
	return null

func java_method_doShockwave_6(_args: Array = []) -> Variant:
	return null

func java_method_eachGroundSpawn_7(_args: Array = []) -> Variant:
	return null

func java_method_eachGroundSpawn_8(_args: Array = []) -> Variant:
	return null

func java_method_eachFlyerSpawn_9(_args: Array = []) -> Variant:
	return null

func java_method_countGroundSpawns_10(_args: Array = []) -> Variant:
	return null

func java_method_countFlyerSpawns_11(_args: Array = []) -> Variant:
	return null

func java_method_isSpawning_12(_args: Array = []) -> Variant:
	return null

func java_method_reset_13(_args: Array = []) -> Variant:
	return null

func java_method_spawnEffect_14(_args: Array = []) -> Variant:
	return null

func java_method_spawnEffect_15(_args: Array = []) -> Variant:
	return null
