# Generated from Mindustry upstream.
# Source: mindustry/entities/bullet/PointLaserBulletType.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.bullet"
const JAVA_KIND := "class"
const JAVA_NAME := "PointLaserBulletType"
const JAVA_EXTENDS := "BulletType"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "sprite", "type": "String"}, {"modifiers": ["public"], "name": "laser", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserEnd", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "beamEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "beamEffectInterval", "type": "float"}, {"modifiers": ["public"], "name": "beamEffectSize", "type": "float"}, {"modifiers": ["public"], "name": "oscScl", "type": "float"}, {"modifiers": ["public"], "name": "oscMag", "type": "float"}, {"modifiers": ["public"], "name": "damageInterval", "type": "float"}, {"modifiers": ["public"], "name": "shake", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PointLaserBulletType", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "continuousDamage", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "estimateDPS", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateTrailEffects", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateTrail", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateBulletInterval", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
