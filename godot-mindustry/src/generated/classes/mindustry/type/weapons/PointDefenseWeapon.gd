# Generated from Mindustry upstream.
# Source: mindustry/type/weapons/PointDefenseWeapon.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type.weapons"
const JAVA_KIND := "class"
const JAVA_NAME := "PointDefenseWeapon"
const JAVA_EXTENDS := "Weapon"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "beamEffect", "type": "Effect"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PointDefenseWeapon", "parameters": [{"name": "name", "type": "String", "varargs": false}]}, {"modifiers": ["public"], "name": "PointDefenseWeapon", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addStats", "parameters": [{"name": "u", "type": "UnitType", "varargs": false}, {"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "findTarget", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["protected"], "name": "checkTarget", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "target", "type": "Teamc", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "shoot", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "mount", "type": "WeaponMount", "varargs": false}, {"name": "shootX", "type": "float", "varargs": false}, {"name": "shootY", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_addStats_0(_args: Array = []) -> Variant:
	return null

func java_method_findTarget_1(_args: Array = []) -> Variant:
	return null

func java_method_checkTarget_2(_args: Array = []) -> Variant:
	return null

func java_method_shoot_3(_args: Array = []) -> Variant:
	return null
