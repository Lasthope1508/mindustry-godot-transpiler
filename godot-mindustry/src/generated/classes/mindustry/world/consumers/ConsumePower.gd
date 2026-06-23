# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumePower.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumePower"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "usage", "type": "float"}, {"modifiers": ["public"], "name": "capacity", "type": "float"}, {"modifiers": ["public"], "name": "buffered", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumePower", "parameters": [{"name": "usage", "type": "float", "varargs": false}, {"name": "capacity", "type": "float", "varargs": false}, {"name": "buffered", "type": "boolean", "varargs": false}]}, {"modifiers": ["protected"], "name": "ConsumePower", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "ignore", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "requestedPower", "parameters": [{"name": "entity", "type": "Building", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []
