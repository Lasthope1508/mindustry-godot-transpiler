# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/PayloadComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "PayloadComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Rotc", "Hitboxc", "Unitc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "payloads", "type": "Seq"}, {"modifiers": ["private", "transient"], "name": "payloadPower", "type": "PowerGraph"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "destroy", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "payloadUsed", "parameters": [], "return_type": "float"}, {"modifiers": [], "name": "canPickup", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "canPickup", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "canPickupPayload", "parameters": [{"name": "pay", "type": "Payload", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "hasPayload", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "addPayload", "parameters": [{"name": "load", "type": "Payload", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "pickup", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "pickup", "parameters": [{"name": "tile", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "dropLastPayload", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "tryDropPayload", "parameters": [{"name": "payload", "type": "Payload", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "canDropPayload", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "dropUnit", "parameters": [{"name": "payload", "type": "UnitPayload", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "dropBlock", "parameters": [{"name": "payload", "type": "BuildPayload", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "contentInfo", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "itemSize", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_update_0(_args: Array = []) -> Variant:
	return null

func java_method_remove_1(_args: Array = []) -> Variant:
	return null

func java_method_destroy_2(_args: Array = []) -> Variant:
	return null

func java_method_payloadUsed_3(_args: Array = []) -> Variant:
	return null

func java_method_canPickup_4(_args: Array = []) -> Variant:
	return null

func java_method_canPickup_5(_args: Array = []) -> Variant:
	return null

func java_method_canPickupPayload_6(_args: Array = []) -> Variant:
	return null

func java_method_hasPayload_7(_args: Array = []) -> Variant:
	return null

func java_method_addPayload_8(_args: Array = []) -> Variant:
	return null

func java_method_pickup_9(_args: Array = []) -> Variant:
	return null

func java_method_pickup_10(_args: Array = []) -> Variant:
	return null

func java_method_dropLastPayload_11(_args: Array = []) -> Variant:
	return null

func java_method_tryDropPayload_12(_args: Array = []) -> Variant:
	return null

func java_method_canDropPayload_13(_args: Array = []) -> Variant:
	return null

func java_method_dropUnit_14(_args: Array = []) -> Variant:
	return null

func java_method_dropBlock_15(_args: Array = []) -> Variant:
	return null

func java_method_contentInfo_16(_args: Array = []) -> Variant:
	return null
