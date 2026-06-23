# Generated from Mindustry upstream.
# Source: mindustry/type/weapons/PointDefenseBulletWeapon.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type.weapons"
const JAVA_KIND := "class"
const JAVA_NAME := "PointDefenseBulletWeapon"
const JAVA_EXTENDS := "Weapon"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "damageTargetWeight", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PointDefenseBulletWeapon", "parameters": [{"name": "name", "type": "String", "varargs": false}]}, {"modifiers": ["public"], "name": "PointDefenseBulletWeapon", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["protected"], "name": "findTarget", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["protected"], "name": "checkTarget", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "target", "type": "Teamc", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "handleBullet", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "mount", "type": "WeaponMount", "varargs": false}, {"name": "bullet", "type": "Bullet", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
