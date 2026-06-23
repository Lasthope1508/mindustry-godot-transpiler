# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemExplode.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemExplode"
const JAVA_EXTENDS := "ConsumeItemFilter"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "damage", "type": "float"}, {"modifiers": ["public"], "name": "threshold", "type": "float"}, {"modifiers": ["public"], "name": "baseChance", "type": "float"}, {"modifiers": ["public"], "name": "explodeEffect", "type": "Effect"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemExplode", "parameters": [{"name": "threshold", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeItemExplode", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "trigger", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []
