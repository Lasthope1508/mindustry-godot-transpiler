# Generated from Mindustry upstream.
# Source: mindustry/ai/Pathfinder.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "Pathfinder"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Runnable"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "maxUpdate", "type": "long"}, {"modifiers": ["final", "private", "static"], "name": "neverRefresh", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "updateFPS", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "updateInterval", "type": "int"}, {"modifiers": ["static"], "name": "wwidth", "type": "int"}, {"modifiers": ["static"], "name": "wheight", "type": "int"}, {"modifiers": ["final", "static"], "name": "impassable", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "fieldCore", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "maxFields", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "fieldTypes", "type": "Seq"}, {"modifiers": ["final", "public", "static"], "name": "costGround", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costLegs", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costNaval", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costNeoplasm", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costNone", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costHover", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "maxCosts", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costTypes", "type": "Seq"}, {"modifiers": [], "name": "tiles", "type": "int"}, {"modifiers": [], "name": "cache", "type": "Flowfield"}, {"modifiers": [], "name": "threadList", "type": "Seq"}, {"modifiers": [], "name": "mainList", "type": "Seq"}, {"modifiers": [], "name": "queue", "type": "TaskQueue"}, {"modifiers": [], "name": "thread", "type": "Thread"}, {"modifiers": [], "name": "tmpArray", "type": "IntSeq"}, {"modifiers": [], "name": "needsRefresh", "type": "boolean"}, {"modifiers": ["private"], "name": "lastRefreshTime", "type": "long"}, {"modifiers": ["final", "private", "static"], "name": "refreshIntervalMs", "type": "long"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Pathfinder", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["private"], "name": "clearCache", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "packTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["private"], "name": "start", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "stop", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "run", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getField", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "costType", "type": "int", "varargs": false}, {"name": "fieldType", "type": "int", "varargs": false}], "return_type": "Flowfield"}, {"modifiers": ["public"], "name": "getTargetTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "path", "type": "Flowfield", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "getTargetTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "path", "type": "Flowfield", "varargs": false}, {"name": "diagonals", "type": "boolean", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "getTargetTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "path", "type": "Flowfield", "varargs": false}, {"name": "diagonals", "type": "boolean", "varargs": false}, {"name": "avoidanceId", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["private"], "name": "updateTargets", "parameters": [{"name": "path", "type": "Flowfield", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "preloadPath", "parameters": [{"name": "path", "type": "Flowfield", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "registerPath", "parameters": [{"name": "path", "type": "Flowfield", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "updateFrontier", "parameters": [{"name": "path", "type": "Flowfield", "varargs": false}, {"name": "nsToRun", "type": "long", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_clearCache_0(_args: Array = []) -> Variant:
	return null

func java_method_packTile_1(_args: Array = []) -> Variant:
	return null

func java_method_get_2(_args: Array = []) -> Variant:
	return null

func java_method_start_3(_args: Array = []) -> Variant:
	return null

func java_method_stop_4(_args: Array = []) -> Variant:
	return null

func java_method_updateTile_5(_args: Array = []) -> Variant:
	return null

func java_method_run_6(_args: Array = []) -> Variant:
	return null

func java_method_getField_7(_args: Array = []) -> Variant:
	return null

func java_method_getTargetTile_8(_args: Array = []) -> Variant:
	return null

func java_method_getTargetTile_9(_args: Array = []) -> Variant:
	return null

func java_method_getTargetTile_10(_args: Array = []) -> Variant:
	return null

func java_method_updateTargets_11(_args: Array = []) -> Variant:
	return null

func java_method_preloadPath_12(_args: Array = []) -> Variant:
	return null

func java_method_registerPath_13(_args: Array = []) -> Variant:
	return null

func java_method_updateFrontier_14(_args: Array = []) -> Variant:
	return null
