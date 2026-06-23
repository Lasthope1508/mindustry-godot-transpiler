# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquid.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquid"
const JAVA_EXTENDS := "ConsumeLiquidBase"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "liquid", "type": "Liquid"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["protected"], "name": "ConsumeLiquid", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "consumes", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
