# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumePowerDynamic.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumePowerDynamic"
const JAVA_EXTENDS := "ConsumePower"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private"], "name": "usage", "type": "Floatf"}, {"modifiers": ["private"], "name": "displayedPowerUsage", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumePowerDynamic", "parameters": [{"name": "usage", "type": "Floatf", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumePowerDynamic", "parameters": [{"name": "displayed", "type": "float", "varargs": false}, {"name": "usage", "type": "Floatf", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "requestedPower", "parameters": [{"name": "entity", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
