# Generated from Mindustry upstream.
# Source: mindustry/ai/UnitStance.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitStance"
const JAVA_EXTENDS := "MappableContent"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public", "static"], "name": "stop", "type": "UnitStance"}, {"modifiers": ["public", "static"], "name": "holdFire", "type": "UnitStance"}, {"modifiers": ["public", "static"], "name": "pursueTarget", "type": "UnitStance"}, {"modifiers": ["public", "static"], "name": "patrol", "type": "UnitStance"}, {"modifiers": ["public", "static"], "name": "ram", "type": "UnitStance"}, {"modifiers": ["public", "static"], "name": "boost", "type": "UnitStance"}, {"modifiers": ["public", "static"], "name": "holdPosition", "type": "UnitStance"}, {"modifiers": ["public", "static"], "name": "mineAuto", "type": "UnitStance"}, {"modifiers": ["public"], "name": "icon", "type": "String"}, {"modifiers": ["public"], "name": "keybind", "type": "KeyBind"}, {"modifiers": ["public"], "name": "incompatibleCommands", "type": "Seq"}, {"modifiers": ["public"], "name": "incompatibleStances", "type": "Seq"}, {"modifiers": ["public"], "name": "toggle", "type": "boolean"}, {"modifiers": ["public"], "name": "incompatibleStanceBits", "type": "Bits"}, {"modifiers": ["public"], "name": "incompatibleCommandBits", "type": "Bits"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnitStance", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "icon", "type": "String", "varargs": false}, {"name": "keybind", "type": "KeyBind", "varargs": false}, {"name": "toggle", "type": "boolean", "varargs": false}]}, {"modifiers": ["public"], "name": "UnitStance", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "icon", "type": "String", "varargs": false}, {"name": "keybind", "type": "KeyBind", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isCompatible", "parameters": [{"name": "other", "type": "UnitCommand", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getIcon", "parameters": [], "return_type": "TextureRegionDrawable"}, {"modifiers": ["public"], "name": "getEmoji", "parameters": [], "return_type": "char"}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "loadAll", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_isCompatible_1(_args: Array = []) -> Variant:
	return null

func java_method_localized_2(_args: Array = []) -> Variant:
	return null

func java_method_getIcon_3(_args: Array = []) -> Variant:
	return null

func java_method_getEmoji_4(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_5(_args: Array = []) -> Variant:
	return null

func java_method_toString_6(_args: Array = []) -> Variant:
	return null

func java_method_loadAll_7(_args: Array = []) -> Variant:
	return null
