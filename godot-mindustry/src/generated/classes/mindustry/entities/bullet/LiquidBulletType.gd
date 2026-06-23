# Generated from Mindustry upstream.
# Source: mindustry/entities/bullet/LiquidBulletType.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.bullet"
const JAVA_KIND := "class"
const JAVA_NAME := "LiquidBulletType"
const JAVA_EXTENDS := "BulletType"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "liquid", "type": "Liquid"}, {"modifiers": ["public"], "name": "puddleSize", "type": "float"}, {"modifiers": ["public"], "name": "orbSize", "type": "float"}, {"modifiers": ["public"], "name": "boilTime", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LiquidBulletType", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}]}, {"modifiers": ["public"], "name": "LiquidBulletType", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "despawned", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hit", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}, {"name": "hitx", "type": "float", "varargs": false}, {"name": "hity", "type": "float", "varargs": false}, {"name": "createFrags", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
