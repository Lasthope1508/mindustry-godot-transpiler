# Generated from Mindustry upstream.
# Source: mindustry/game/SpawnGroup.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "class"
const JAVA_NAME := "SpawnGroup"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["JsonSerializable", "Cloneable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "never", "type": "int"}, {"modifiers": ["public"], "name": "type", "type": "UnitType"}, {"modifiers": ["public"], "name": "end", "type": "int"}, {"modifiers": ["public"], "name": "begin", "type": "int"}, {"modifiers": ["public"], "name": "spacing", "type": "int"}, {"modifiers": ["public"], "name": "max", "type": "int"}, {"modifiers": ["public"], "name": "unitScaling", "type": "float"}, {"modifiers": ["public"], "name": "shields", "type": "float"}, {"modifiers": ["public"], "name": "shieldScaling", "type": "float"}, {"modifiers": ["public"], "name": "unitAmount", "type": "int"}, {"modifiers": ["public"], "name": "spawn", "type": "int"}, {"modifiers": ["public"], "name": "payloads", "type": "Seq"}, {"modifiers": ["public"], "name": "effect", "type": "StatusEffect"}, {"modifiers": ["public"], "name": "items", "type": "ItemStack"}, {"modifiers": ["public"], "name": "team", "type": "Team"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SpawnGroup", "parameters": [{"name": "type", "type": "UnitType", "varargs": false}]}, {"modifiers": ["public"], "name": "SpawnGroup", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "canSpawn", "parameters": [{"name": "position", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getSpawned", "parameters": [{"name": "wave", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "getShield", "parameters": [{"name": "wave", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "createUnit", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "wave", "type": "int", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "createUnit", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "wave", "type": "int", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "json", "type": "Json", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "json", "type": "Json", "varargs": false}, {"name": "data", "type": "JsonValue", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "SpawnGroup"}, {"modifiers": ["public"], "name": "equals", "parameters": [{"name": "o", "type": "Object", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hashCode", "parameters": [], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_canSpawn_0(_args: Array = []) -> Variant:
	return null

func java_method_getSpawned_1(_args: Array = []) -> Variant:
	return null

func java_method_getShield_2(_args: Array = []) -> Variant:
	return null

func java_method_createUnit_3(_args: Array = []) -> Variant:
	return null

func java_method_createUnit_4(_args: Array = []) -> Variant:
	return null

func java_method_write_5(_args: Array = []) -> Variant:
	return null

func java_method_read_6(_args: Array = []) -> Variant:
	return null

func java_method_toString_7(_args: Array = []) -> Variant:
	return null

func java_method_copy_8(_args: Array = []) -> Variant:
	return null

func java_method_equals_9(_args: Array = []) -> Variant:
	return null

func java_method_hashCode_10(_args: Array = []) -> Variant:
	return null
