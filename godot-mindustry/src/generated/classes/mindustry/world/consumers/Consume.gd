# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/Consume.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "Consume"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "optional", "type": "boolean"}, {"modifiers": ["public"], "name": "booster", "type": "boolean"}, {"modifiers": ["public"], "name": "update", "type": "boolean"}, {"modifiers": ["public"], "name": "multiplier", "type": "Floatf"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "optional", "parameters": [{"name": "optional", "type": "boolean", "varargs": false}, {"name": "boost", "type": "boolean", "varargs": false}], "return_type": "Consume"}, {"modifiers": ["public"], "name": "boost", "parameters": [], "return_type": "Consume"}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "update", "type": "boolean", "varargs": false}], "return_type": "Consume"}, {"modifiers": ["public"], "name": "ignore", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "trigger", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "efficiencyMultiplier", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
