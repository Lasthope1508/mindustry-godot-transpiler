# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/TankComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "TankComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Hitboxc", "Unitc", "ElevationMovec"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "hitSize", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "speedMultiplier", "type": "float"}, {"modifiers": [], "name": "disarmed", "type": "boolean"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": ["private", "transient"], "name": "treadEffectTime", "type": "float"}, {"modifiers": ["private", "transient"], "name": "lastSlowdown", "type": "float"}, {"modifiers": ["transient"], "name": "treadTime", "type": "float"}, {"modifiers": ["transient"], "name": "walked", "type": "boolean"}, {"modifiers": ["transient"], "name": "lastDeepFloor", "type": "Floor"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "floorSpeedMultiplier", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "drownFloor", "parameters": [], "return_type": "Floor"}, {"modifiers": ["public"], "name": "moveAt", "parameters": [{"name": "vector", "type": "Vec2", "varargs": false}, {"name": "acceleration", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "approach", "parameters": [{"name": "vector", "type": "Vec2", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
