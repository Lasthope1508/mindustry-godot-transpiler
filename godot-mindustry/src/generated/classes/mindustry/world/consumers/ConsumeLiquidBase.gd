# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquidBase.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquidBase"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "amount", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquidBase", "parameters": [{"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeLiquidBase", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["abstract", "public"], "name": "consumes", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
