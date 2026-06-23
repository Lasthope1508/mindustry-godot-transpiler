# Generated from Mindustry upstream.
# Source: mindustry/game/Teams.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "class"
const JAVA_NAME := "Teams"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "map", "type": "TeamData"}, {"modifiers": ["public"], "name": "active", "type": "Seq"}, {"modifiers": ["public"], "name": "present", "type": "Seq"}, {"modifiers": ["public"], "name": "bosses", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Teams", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "closestEnemyCore", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": "CoreBuild"}, {"modifiers": ["public"], "name": "closestCore", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": "CoreBuild"}, {"modifiers": ["public"], "name": "anyEnemyCoresWithinBuildRadius", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "anyEnemyCoresWithin", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "eachEnemyCore", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "ret", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "TeamData"}, {"modifiers": ["public"], "name": "getOrNull", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "TeamData"}, {"modifiers": ["public"], "name": "playerCores", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "cores", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "isActive", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canInteract", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "other", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getActive", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "updateActive", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "registerCore", "parameters": [{"name": "core", "type": "CoreBuild", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "unregisterCore", "parameters": [{"name": "entity", "type": "CoreBuild", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "count", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateTeamStats", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "updateEnemies", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "destroyPayload", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_closestEnemyCore_0(_args: Array = []) -> Variant:
	return null

func java_method_closestCore_1(_args: Array = []) -> Variant:
	return null

func java_method_anyEnemyCoresWithinBuildRadius_2(_args: Array = []) -> Variant:
	return null

func java_method_anyEnemyCoresWithin_3(_args: Array = []) -> Variant:
	return null

func java_method_eachEnemyCore_4(_args: Array = []) -> Variant:
	return null

func java_method_get_5(_args: Array = []) -> Variant:
	return null

func java_method_getOrNull_6(_args: Array = []) -> Variant:
	return null

func java_method_playerCores_7(_args: Array = []) -> Variant:
	return null

func java_method_cores_8(_args: Array = []) -> Variant:
	return null

func java_method_isActive_9(_args: Array = []) -> Variant:
	return null

func java_method_canInteract_10(_args: Array = []) -> Variant:
	return null

func java_method_getActive_11(_args: Array = []) -> Variant:
	return null

func java_method_updateActive_12(_args: Array = []) -> Variant:
	return null

func java_method_registerCore_13(_args: Array = []) -> Variant:
	return null

func java_method_unregisterCore_14(_args: Array = []) -> Variant:
	return null

func java_method_count_15(_args: Array = []) -> Variant:
	return null

func java_method_updateTeamStats_16(_args: Array = []) -> Variant:
	return null

func java_method_updateEnemies_17(_args: Array = []) -> Variant:
	return null

func java_method_destroyPayload_18(_args: Array = []) -> Variant:
	return null
