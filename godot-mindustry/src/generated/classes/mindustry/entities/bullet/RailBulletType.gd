# Generated from Mindustry upstream.
# Source: mindustry/entities/bullet/RailBulletType.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.bullet"
const JAVA_KIND := "class"
const JAVA_NAME := "RailBulletType"
const JAVA_EXTENDS := "BulletType"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "pierceEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "pointEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "lineEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "endEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "length", "type": "float"}, {"modifiers": ["public"], "name": "pointEffectSpace", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "RailBulletType", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["protected"], "name": "calculateRange", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "handlePierce", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}, {"name": "initialHealth", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "testCollision", "parameters": [{"name": "bullet", "type": "Bullet", "varargs": false}, {"name": "tile", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hitTile", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "initialHealth", "type": "float", "varargs": false}, {"name": "direct", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
