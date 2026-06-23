# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/SegmentComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "SegmentComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Rotc", "Hitboxc", "Unitc", "Segmentc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "vel", "type": "Vec2"}, {"modifiers": ["transient"], "name": "parentSegment", "type": "Segmentc"}, {"modifiers": ["transient"], "name": "childSegment", "type": "Segmentc"}, {"modifiers": ["transient"], "name": "headSegment", "type": "Segmentc"}, {"modifiers": ["transient"], "name": "segmentIndex", "type": "int"}, {"modifiers": [], "name": "parentId", "type": "int"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "isHead", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "addChild", "parameters": [{"name": "other", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "ignoreSolids", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "playerControllable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "shouldUpdateController", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "moving", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "collisionLayer", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "isCommandable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "afterSync", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterReadAll", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "beforeWrite", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkParent", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateSegment", "parameters": [{"name": "head", "type": "Segmentc", "varargs": false}, {"name": "parent", "type": "Segmentc", "varargs": false}, {"name": "index", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
