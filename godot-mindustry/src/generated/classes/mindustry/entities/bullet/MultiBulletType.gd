# Generated from Mindustry upstream.
# Source: mindustry/entities/bullet/MultiBulletType.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.bullet"
const JAVA_KIND := "class"
const JAVA_NAME := "MultiBulletType"
const JAVA_EXTENDS := "BulletType"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "bullets", "type": "BulletType"}, {"modifiers": ["public"], "name": "repeat", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MultiBulletType", "parameters": [{"name": "bullets", "type": "BulletType", "varargs": true}]}, {"modifiers": ["public"], "name": "MultiBulletType", "parameters": [{"name": "repeat", "type": "int", "varargs": false}, {"name": "bullets", "type": "BulletType", "varargs": true}]}, {"modifiers": ["public"], "name": "MultiBulletType", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "estimateDPS", "parameters": [], "return_type": "float"}, {"modifiers": ["protected"], "name": "calculateRange", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "create", "parameters": [{"name": "owner", "type": "Entityc", "varargs": false}, {"name": "shooter", "type": "Entityc", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "angle", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "velocityScl", "type": "float", "varargs": false}, {"name": "lifetimeScl", "type": "float", "varargs": false}, {"name": "data", "type": "Object", "varargs": false}, {"name": "mover", "type": "Mover", "varargs": false}, {"name": "aimX", "type": "float", "varargs": false}, {"name": "aimY", "type": "float", "varargs": false}, {"name": "target", "type": "Teamc", "varargs": false}], "return_type": "Bullet"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_estimateDPS_0(_args: Array = []) -> Variant:
	return null

func java_method_calculateRange_1(_args: Array = []) -> Variant:
	return null

func java_method_create_2(_args: Array = []) -> Variant:
	return null
