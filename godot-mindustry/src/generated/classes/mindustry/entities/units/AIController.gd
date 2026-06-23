# Generated from Mindustry upstream.
# Source: mindustry/entities/units/AIController.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.units"
const JAVA_KIND := "class"
const JAVA_NAME := "AIController"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["UnitController"]
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "vec", "type": "Vec2"}, {"modifiers": ["final", "protected", "static"], "name": "rotateBackTimer", "type": "float"}, {"modifiers": ["final", "protected", "static"], "name": "timerTarget", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "timerTarget2", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "timerTarget3", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "timerTarget4", "type": "int"}, {"modifiers": ["protected"], "name": "unit", "type": "Unit"}, {"modifiers": ["protected"], "name": "timer", "type": "Interval"}, {"modifiers": ["protected"], "name": "fallback", "type": "AIController"}, {"modifiers": ["protected"], "name": "noTargetTime", "type": "float"}, {"modifiers": ["protected"], "name": "target", "type": "Teamc"}, {"modifiers": ["protected"], "name": "bomberTarget", "type": "Teamc"}, {"modifiers": ["protected"], "name": "turningAway", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["protected"], "name": "resetTimers", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateUnit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "hasStance", "parameters": [{"name": "stance", "type": "UnitStance", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "stanceChanged", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "keepState", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "afterRead", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isLogicControllable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "stopShooting", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "fallback", "parameters": [], "return_type": "AIController"}, {"modifiers": ["public"], "name": "useFallback", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "updateVisuals", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateMovement", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateTargeting", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "faceTarget", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "faceMovement", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "invalid", "parameters": [{"name": "target", "type": "Teamc", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "pathfind", "parameters": [{"name": "pathTarget", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "pathfind", "parameters": [{"name": "pathTarget", "type": "int", "varargs": false}, {"name": "stopAtTargetTile", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "pathfind", "parameters": [{"name": "pathTarget", "type": "int", "varargs": false}, {"name": "stopAtTargetTile", "type": "boolean", "varargs": false}, {"name": "avoidance", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "alterPathfind", "parameters": [{"name": "vec", "type": "Vec2", "varargs": false}], "return_type": "Vec2"}, {"modifiers": ["public"], "name": "targetInvalidated", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateWeapons", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkTarget", "parameters": [{"name": "target", "type": "Teamc", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "shouldFire", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "shouldShoot", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "targetFlag", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "flag", "type": "BlockFlag", "varargs": false}, {"name": "enemy", "type": "boolean", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public"], "name": "targetFlagActive", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "flag", "type": "BlockFlag", "varargs": false}, {"name": "enemy", "type": "boolean", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public"], "name": "target", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public"], "name": "retarget", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "findMainTarget", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public"], "name": "findTarget", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public"], "name": "commandTarget", "parameters": [{"name": "moveTo", "type": "Teamc", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "commandPosition", "parameters": [{"name": "pos", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getClosestSpawner", "parameters": [], "return_type": "Tile"}, {"modifiers": ["public"], "name": "unloadPayloads", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "circleAttack", "parameters": [{"name": "circleLength", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "circle", "parameters": [{"name": "target", "type": "Position", "varargs": false}, {"name": "circleLength", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "circle", "parameters": [{"name": "target", "type": "Position", "varargs": false}, {"name": "circleLength", "type": "float", "varargs": false}, {"name": "speed", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "moveTo", "parameters": [{"name": "target", "type": "Position", "varargs": false}, {"name": "circleLength", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "moveTo", "parameters": [{"name": "target", "type": "Position", "varargs": false}, {"name": "circleLength", "type": "float", "varargs": false}, {"name": "smooth", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "moveTo", "parameters": [{"name": "target", "type": "Position", "varargs": false}, {"name": "circleLength", "type": "float", "varargs": false}, {"name": "smooth", "type": "float", "varargs": false}, {"name": "keepDistance", "type": "boolean", "varargs": false}, {"name": "offset", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "moveTo", "parameters": [{"name": "target", "type": "Position", "varargs": false}, {"name": "circleLength", "type": "float", "varargs": false}, {"name": "smooth", "type": "float", "varargs": false}, {"name": "keepDistance", "type": "boolean", "varargs": false}, {"name": "offset", "type": "Vec2", "varargs": false}, {"name": "arrive", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "prefSpeed", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "unit", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "unit", "parameters": [], "return_type": "Unit"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_resetTimers_0(_args: Array = []) -> Variant:
	return null

func java_method_updateUnit_1(_args: Array = []) -> Variant:
	return null

func java_method_hasStance_2(_args: Array = []) -> Variant:
	return null

func java_method_stanceChanged_3(_args: Array = []) -> Variant:
	return null

func java_method_keepState_4(_args: Array = []) -> Variant:
	return null

func java_method_afterRead_5(_args: Array = []) -> Variant:
	return null

func java_method_isLogicControllable_6(_args: Array = []) -> Variant:
	return null

func java_method_stopShooting_7(_args: Array = []) -> Variant:
	return null

func java_method_fallback_8(_args: Array = []) -> Variant:
	return null

func java_method_useFallback_9(_args: Array = []) -> Variant:
	return null

func java_method_updateVisuals_10(_args: Array = []) -> Variant:
	return null

func java_method_updateMovement_11(_args: Array = []) -> Variant:
	return null

func java_method_updateTargeting_12(_args: Array = []) -> Variant:
	return null

func java_method_faceTarget_13(_args: Array = []) -> Variant:
	return null

func java_method_faceMovement_14(_args: Array = []) -> Variant:
	return null

func java_method_invalid_15(_args: Array = []) -> Variant:
	return null

func java_method_pathfind_16(_args: Array = []) -> Variant:
	return null

func java_method_pathfind_17(_args: Array = []) -> Variant:
	return null

func java_method_pathfind_18(_args: Array = []) -> Variant:
	return null

func java_method_alterPathfind_19(_args: Array = []) -> Variant:
	return null

func java_method_targetInvalidated_20(_args: Array = []) -> Variant:
	return null

func java_method_updateWeapons_21(_args: Array = []) -> Variant:
	return null

func java_method_checkTarget_22(_args: Array = []) -> Variant:
	return null

func java_method_shouldFire_23(_args: Array = []) -> Variant:
	return null

func java_method_shouldShoot_24(_args: Array = []) -> Variant:
	return null

func java_method_targetFlag_25(_args: Array = []) -> Variant:
	return null

func java_method_targetFlagActive_26(_args: Array = []) -> Variant:
	return null

func java_method_target_27(_args: Array = []) -> Variant:
	return null

func java_method_retarget_28(_args: Array = []) -> Variant:
	return null

func java_method_findMainTarget_29(_args: Array = []) -> Variant:
	return null

func java_method_findTarget_30(_args: Array = []) -> Variant:
	return null

func java_method_commandTarget_31(_args: Array = []) -> Variant:
	return null

func java_method_commandPosition_32(_args: Array = []) -> Variant:
	return null

func java_method_init_33(_args: Array = []) -> Variant:
	return null

func java_method_getClosestSpawner_34(_args: Array = []) -> Variant:
	return null

func java_method_unloadPayloads_35(_args: Array = []) -> Variant:
	return null

func java_method_circleAttack_36(_args: Array = []) -> Variant:
	return null

func java_method_circle_37(_args: Array = []) -> Variant:
	return null

func java_method_circle_38(_args: Array = []) -> Variant:
	return null

func java_method_moveTo_39(_args: Array = []) -> Variant:
	return null

func java_method_moveTo_40(_args: Array = []) -> Variant:
	return null

func java_method_moveTo_41(_args: Array = []) -> Variant:
	return null

func java_method_moveTo_42(_args: Array = []) -> Variant:
	return null

func java_method_prefSpeed_43(_args: Array = []) -> Variant:
	return null

func java_method_unit_44(_args: Array = []) -> Variant:
	return null

func java_method_unit_45(_args: Array = []) -> Variant:
	return null
