# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/WeaponsComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "WeaponsComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Teamc", "Posc", "Rotc", "Velc", "Statusc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "disarmed", "type": "boolean"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "mounts", "type": "WeaponMount"}, {"modifiers": ["transient"], "name": "isRotate", "type": "boolean"}, {"modifiers": [], "name": "aimX", "type": "float"}, {"modifiers": [], "name": "aimY", "type": "float"}, {"modifiers": [], "name": "isShooting", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": [], "name": "setWeaponRotation", "parameters": [{"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "setupWeapons", "parameters": [{"name": "def", "type": "UnitType", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "controlWeapons", "parameters": [{"name": "rotateShoot", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "controlWeapons", "parameters": [{"name": "rotate", "type": "boolean", "varargs": false}, {"name": "shoot", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "aim", "parameters": [{"name": "pos", "type": "Position", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "aim", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "canShoot", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setWeaponRotation_0(_args: Array = []) -> Variant:
	return null

func java_method_setupWeapons_1(_args: Array = []) -> Variant:
	return null

func java_method_controlWeapons_2(_args: Array = []) -> Variant:
	return null

func java_method_controlWeapons_3(_args: Array = []) -> Variant:
	return null

func java_method_aim_4(_args: Array = []) -> Variant:
	return null

func java_method_aim_5(_args: Array = []) -> Variant:
	return null

func java_method_canShoot_6(_args: Array = []) -> Variant:
	return null

func java_method_remove_7(_args: Array = []) -> Variant:
	return null

func java_method_update_8(_args: Array = []) -> Variant:
	return null
