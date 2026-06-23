# Generated from Mindustry upstream.
# Source: mindustry/ai/UnitCommand.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitCommand"
const JAVA_EXTENDS := "MappableContent"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public", "static"], "name": "moveCommand", "type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "repairCommand", "type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "rebuildCommand", "type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "assistCommand", "type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "mineCommand", "type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "enterPayloadCommand", "type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "loadUnitsCommand", "type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "loadBlocksCommand", "type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "unloadPayloadCommand", "type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "loopPayloadCommand", "type": "UnitCommand"}, {"modifiers": ["final", "public"], "name": "icon", "type": "String"}, {"modifiers": ["final", "public"], "name": "controller", "type": "Func"}, {"modifiers": ["public"], "name": "switchToMove", "type": "boolean"}, {"modifiers": ["public"], "name": "drawTarget", "type": "boolean"}, {"modifiers": ["public"], "name": "resetTarget", "type": "boolean"}, {"modifiers": ["public"], "name": "snapToBuilding", "type": "boolean"}, {"modifiers": ["public"], "name": "exactArrival", "type": "boolean"}, {"modifiers": ["public"], "name": "refreshOnSelect", "type": "boolean"}, {"modifiers": ["public"], "name": "keybind", "type": "KeyBind"}, {"modifiers": ["public"], "name": "extraStances", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnitCommand", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "icon", "type": "String", "varargs": false}, {"name": "controller", "type": "Func", "varargs": false}]}, {"modifiers": ["public"], "name": "UnitCommand", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "icon", "type": "String", "varargs": false}, {"name": "keybind", "type": "KeyBind", "varargs": false}, {"name": "controller", "type": "Func", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getIcon", "parameters": [], "return_type": "TextureRegionDrawable"}, {"modifiers": ["public"], "name": "getEmoji", "parameters": [], "return_type": "char"}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "loadAll", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_localized_0(_args: Array = []) -> Variant:
	return null

func java_method_getIcon_1(_args: Array = []) -> Variant:
	return null

func java_method_getEmoji_2(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_3(_args: Array = []) -> Variant:
	return null

func java_method_toString_4(_args: Array = []) -> Variant:
	return null

func java_method_loadAll_5(_args: Array = []) -> Variant:
	return null
