# Generated from Mindustry upstream.
# Source: mindustry/entities/bullet/SapBulletType.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.bullet"
const JAVA_KIND := "class"
const JAVA_NAME := "SapBulletType"
const JAVA_EXTENDS := "BulletType"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "length", "type": "float"}, {"modifiers": ["public"], "name": "lengthRand", "type": "float"}, {"modifiers": ["public"], "name": "sapStrength", "type": "float"}, {"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "width", "type": "float"}, {"modifiers": ["public"], "name": "sprite", "type": "String"}, {"modifiers": ["public"], "name": "laserRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserEndRegion", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SapBulletType", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawLight", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "calculateRange", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "init", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
