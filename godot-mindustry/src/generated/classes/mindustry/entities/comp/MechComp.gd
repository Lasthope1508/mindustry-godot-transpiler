# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/MechComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "MechComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Hitboxc", "Unitc", "Mechc", "ElevationMovec"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "hitSize", "type": "float"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "baseRotation", "type": "float"}, {"modifiers": ["transient"], "name": "walkTime", "type": "float"}, {"modifiers": ["transient"], "name": "walkExtension", "type": "float"}, {"modifiers": ["private", "transient"], "name": "walked", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drownFloor", "parameters": [], "return_type": "Floor"}, {"modifiers": ["public"], "name": "walkExtend", "parameters": [{"name": "scaled", "type": "boolean", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "rotateMove", "parameters": [{"name": "vec", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "moveAt", "parameters": [{"name": "vector", "type": "Vec2", "varargs": false}, {"name": "acceleration", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "approach", "parameters": [{"name": "vector", "type": "Vec2", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
