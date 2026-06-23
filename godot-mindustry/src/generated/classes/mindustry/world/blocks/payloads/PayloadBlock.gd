# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/payloads/PayloadBlock.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.payloads"
const JAVA_KIND := "class"
const JAVA_NAME := "PayloadBlock"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "payloadSpeed", "type": "float"}, {"modifiers": ["public"], "name": "payloadRotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "regionSuffix", "type": "String"}, {"modifiers": ["public"], "name": "topRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "outRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "inRegion", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PayloadBlock", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "findFactoryRegion", "parameters": [{"name": "suf", "type": "String", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public", "static"], "name": "blends", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "direction", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "pushOutput", "parameters": [{"name": "payload", "type": "Payload", "varargs": false}, {"name": "progress", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_load_0(_args: Array = []) -> Variant:
	return null

func java_method_findFactoryRegion_1(_args: Array = []) -> Variant:
	return null

func java_method_blends_2(_args: Array = []) -> Variant:
	return null

func java_method_pushOutput_3(_args: Array = []) -> Variant:
	return null
