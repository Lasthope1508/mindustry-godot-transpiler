# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/BaseTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "BaseTurret"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "range", "type": "float"}, {"modifiers": ["public"], "name": "placeOverlapMargin", "type": "float"}, {"modifiers": ["public"], "name": "rotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "fogRadiusMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "disableOverlapCheck", "type": "boolean"}, {"modifiers": ["public"], "name": "activationTime", "type": "float"}, {"modifiers": ["public"], "name": "coolEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "coolantMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "coolant", "type": "ConsumeLiquidBase"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BaseTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reinitializeConsumers", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "checkInitCoolant", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
