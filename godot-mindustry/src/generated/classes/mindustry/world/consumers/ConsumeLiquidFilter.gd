# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquidFilter.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquidFilter"
const JAVA_EXTENDS := "ConsumeLiquidBase"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "filter", "type": "Boolf"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquidFilter", "parameters": [{"name": "liquid", "type": "Boolf", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeLiquidFilter", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "efficiencyMultiplier", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getConsumed", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "Liquid"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "consumes", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "liquidEfficiencyMultiplier", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []
