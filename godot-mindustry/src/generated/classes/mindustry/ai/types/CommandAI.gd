# Generated from Mindustry upstream.
# Source: mindustry/ai/types/CommandAI.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai.types"
const JAVA_KIND := "class"
const JAVA_NAME := "CommandAI"
const JAVA_EXTENDS := "AIController"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "maxCommandQueueSize", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "avoidInterval", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "vecOut", "type": "Vec2"}, {"modifiers": ["final", "protected", "static"], "name": "vecMovePos", "type": "Vec2"}, {"modifiers": ["final", "protected", "static"], "name": "noFound", "type": "boolean"}, {"modifiers": ["final", "protected", "static"], "name": "tmpPayload", "type": "UnitPayload"}, {"modifiers": ["final", "protected", "static"], "name": "transferStateNone", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "transferStateLoad", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "transferStateUnload", "type": "int"}, {"modifiers": ["public"], "name": "commandQueue", "type": "Seq"}, {"modifiers": ["public"], "name": "targetPos", "type": "Vec2"}, {"modifiers": ["public"], "name": "attackTarget", "type": "Teamc"}, {"modifiers": ["public"], "name": "group", "type": "UnitGroup"}, {"modifiers": ["public"], "name": "groupIndex", "type": "int"}, {"modifiers": ["public"], "name": "unreachableBuildings", "type": "IntSeq"}, {"modifiers": ["public"], "name": "readAttackTarget", "type": "int"}, {"modifiers": ["protected"], "name": "stopAtTarget", "type": "boolean"}, {"modifiers": ["protected"], "name": "stopWhenInRange", "type": "boolean"}, {"modifiers": ["protected"], "name": "lastTargetPos", "type": "Vec2"}, {"modifiers": ["protected"], "name": "blockingUnit", "type": "boolean"}, {"modifiers": ["protected"], "name": "timeSpentBlocked", "type": "float"}, {"modifiers": ["protected"], "name": "payloadPickupCooldown", "type": "float"}, {"modifiers": ["protected"], "name": "transferState", "type": "int"}, {"modifiers": ["public"], "name": "command", "type": "UnitCommand"}, {"modifiers": ["public"], "name": "stances", "type": "Bits"}, {"modifiers": ["protected"], "name": "commandController", "type": "AIController"}, {"modifiers": ["protected"], "name": "lastCommand", "type": "UnitCommand"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "currentCommand", "parameters": [], "return_type": "UnitCommand"}, {"modifiers": ["public"], "name": "command", "parameters": [{"name": "command", "type": "UnitCommand", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hasStance", "parameters": [{"name": "stance", "type": "UnitStance", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setStance", "parameters": [{"name": "stance", "type": "UnitStance", "varargs": false}, {"name": "enabled", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setStance", "parameters": [{"name": "stance", "type": "UnitStance", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "disableStance", "parameters": [{"name": "stance", "type": "UnitStance", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "stanceChanged", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isLogicControllable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isAttacking", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "updateUnit", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "shouldBoost", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "clearCommands", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "tryPickupUnit", "parameters": [{"name": "pay", "type": "Payloadc", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "findMainTarget", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public"], "name": "defaultBehavior", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "finishPath", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "removed", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "commandQueue", "parameters": [{"name": "location", "type": "Position", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "afterRead", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "shouldFire", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hit", "parameters": [{"name": "bullet", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "keepState", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "findTarget", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public"], "name": "nearAttackTarget", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "retarget", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hasCommand", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setupLastPos", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "commandPosition", "parameters": [{"name": "pos", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "commandPosition", "parameters": [{"name": "pos", "type": "Vec2", "varargs": false}, {"name": "stopWhenInRange", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "commandTarget", "parameters": [{"name": "moveTo", "type": "Teamc", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "commandTarget", "parameters": [{"name": "moveTo", "type": "Teamc", "varargs": false}, {"name": "stopAtTarget", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_currentCommand_0(_args: Array = []) -> Variant:
	return null

func java_method_command_1(_args: Array = []) -> Variant:
	return null

func java_method_hasStance_2(_args: Array = []) -> Variant:
	return null

func java_method_setStance_3(_args: Array = []) -> Variant:
	return null

func java_method_setStance_4(_args: Array = []) -> Variant:
	return null

func java_method_disableStance_5(_args: Array = []) -> Variant:
	return null

func java_method_stanceChanged_6(_args: Array = []) -> Variant:
	return null

func java_method_init_7(_args: Array = []) -> Variant:
	return null

func java_method_isLogicControllable_8(_args: Array = []) -> Variant:
	return null

func java_method_isAttacking_9(_args: Array = []) -> Variant:
	return null

func java_method_updateUnit_10(_args: Array = []) -> Variant:
	return null

func java_method_shouldBoost_11(_args: Array = []) -> Variant:
	return null

func java_method_clearCommands_12(_args: Array = []) -> Variant:
	return null

func java_method_tryPickupUnit_13(_args: Array = []) -> Variant:
	return null

func java_method_findMainTarget_14(_args: Array = []) -> Variant:
	return null

func java_method_defaultBehavior_15(_args: Array = []) -> Variant:
	return null

func java_method_finishPath_16(_args: Array = []) -> Variant:
	return null

func java_method_removed_17(_args: Array = []) -> Variant:
	return null

func java_method_commandQueue_18(_args: Array = []) -> Variant:
	return null

func java_method_afterRead_19(_args: Array = []) -> Variant:
	return null

func java_method_shouldFire_20(_args: Array = []) -> Variant:
	return null

func java_method_hit_21(_args: Array = []) -> Variant:
	return null

func java_method_keepState_22(_args: Array = []) -> Variant:
	return null

func java_method_findTarget_23(_args: Array = []) -> Variant:
	return null

func java_method_nearAttackTarget_24(_args: Array = []) -> Variant:
	return null

func java_method_retarget_25(_args: Array = []) -> Variant:
	return null

func java_method_hasCommand_26(_args: Array = []) -> Variant:
	return null

func java_method_setupLastPos_27(_args: Array = []) -> Variant:
	return null

func java_method_commandPosition_28(_args: Array = []) -> Variant:
	return null

func java_method_commandPosition_29(_args: Array = []) -> Variant:
	return null

func java_method_commandTarget_30(_args: Array = []) -> Variant:
	return null

func java_method_commandTarget_31(_args: Array = []) -> Variant:
	return null
