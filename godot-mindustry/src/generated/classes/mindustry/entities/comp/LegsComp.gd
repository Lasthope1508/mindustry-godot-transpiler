# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/LegsComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "LegsComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Rotc", "Hitboxc", "Unitc"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "straightVec", "type": "Vec2"}, {"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "speedMultiplier", "type": "float"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": [], "name": "disarmed", "type": "boolean"}, {"modifiers": ["transient"], "name": "legs", "type": "Leg"}, {"modifiers": ["transient"], "name": "totalLength", "type": "float"}, {"modifiers": ["transient"], "name": "moveSpace", "type": "float"}, {"modifiers": ["transient"], "name": "baseRotation", "type": "float"}, {"modifiers": ["transient"], "name": "lastDeepFloor", "type": "Floor"}, {"modifiers": ["transient"], "name": "curMoveOffset", "type": "Vec2"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "solidity", "parameters": [], "return_type": "SolidPred"}, {"modifiers": ["public"], "name": "drownFloor", "parameters": [], "return_type": "Floor"}, {"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "unloaded", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "destroy", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "resetLegs", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "resetLegs", "parameters": [{"name": "legLength", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "legOffset", "parameters": [{"name": "out", "type": "Vec2", "varargs": false}, {"name": "index", "type": "int", "varargs": false}], "return_type": "Vec2"}, {"modifiers": [], "name": "legAngle", "parameters": [{"name": "index", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": [], "name": "defaultLegAngle", "parameters": [{"name": "index", "type": "int", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_solidity_0(_args: Array = []) -> Variant:
	return null

func java_method_drownFloor_1(_args: Array = []) -> Variant:
	return null

func java_method_add_2(_args: Array = []) -> Variant:
	return null

func java_method_unloaded_3(_args: Array = []) -> Variant:
	return null

func java_method_destroy_4(_args: Array = []) -> Variant:
	return null

func java_method_resetLegs_5(_args: Array = []) -> Variant:
	return null

func java_method_resetLegs_6(_args: Array = []) -> Variant:
	return null

func java_method_update_7(_args: Array = []) -> Variant:
	return null

func java_method_legOffset_8(_args: Array = []) -> Variant:
	return null

func java_method_legAngle_9(_args: Array = []) -> Variant:
	return null

func java_method_defaultLegAngle_10(_args: Array = []) -> Variant:
	return null
