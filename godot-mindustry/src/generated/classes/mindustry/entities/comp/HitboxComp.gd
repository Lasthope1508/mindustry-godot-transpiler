# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/HitboxComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "HitboxComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Sized", "QuadTreeObject"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": ["transient"], "name": "lastX", "type": "float"}, {"modifiers": ["transient"], "name": "lastY", "type": "float"}, {"modifiers": ["transient"], "name": "deltaX", "type": "float"}, {"modifiers": ["transient"], "name": "deltaY", "type": "float"}, {"modifiers": ["transient"], "name": "hitSize", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterRead", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "hitSize", "parameters": [], "return_type": "float"}, {"modifiers": [], "name": "getCollisions", "parameters": [{"name": "consumer", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "updateLastPosition", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "collision", "parameters": [{"name": "other", "type": "Hitboxc", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "deltaLen", "parameters": [], "return_type": "float"}, {"modifiers": [], "name": "deltaAngle", "parameters": [], "return_type": "float"}, {"modifiers": [], "name": "collides", "parameters": [{"name": "other", "type": "Hitboxc", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hitbox", "parameters": [{"name": "rect", "type": "Rect", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hitboxTile", "parameters": [{"name": "rect", "type": "Rect", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
