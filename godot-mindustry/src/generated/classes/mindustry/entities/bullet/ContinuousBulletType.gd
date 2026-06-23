# Generated from Mindustry upstream.
# Source: mindustry/entities/bullet/ContinuousBulletType.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.bullet"
const JAVA_KIND := "class"
const JAVA_NAME := "ContinuousBulletType"
const JAVA_EXTENDS := "BulletType"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "length", "type": "float"}, {"modifiers": ["public"], "name": "shake", "type": "float"}, {"modifiers": ["public"], "name": "damageInterval", "type": "float"}, {"modifiers": ["public"], "name": "largeHit", "type": "boolean"}, {"modifiers": ["public"], "name": "continuous", "type": "boolean"}, {"modifiers": ["public"], "name": "timescaleDamage", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "continuousDamage", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "estimateDPS", "parameters": [], "return_type": "float"}, {"modifiers": ["protected"], "name": "calculateRange", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applyDamage", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "currentLength", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []
