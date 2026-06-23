# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemDynamic.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemDynamic"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "items", "type": "Func"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemDynamic", "parameters": [{"name": "items", "type": "Func", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "rebuild", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "trigger", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []
