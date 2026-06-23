# Generated from Mindustry upstream.
# Source: mindustry/entities/pattern/ShootMulti.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.pattern"
const JAVA_KIND := "class"
const JAVA_NAME := "ShootMulti"
const JAVA_EXTENDS := "ShootPattern"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "source", "type": "ShootPattern"}, {"modifiers": ["public"], "name": "dest", "type": "ShootPattern"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ShootMulti", "parameters": [{"name": "source", "type": "ShootPattern", "varargs": false}, {"name": "dest", "type": "ShootPattern", "varargs": true}]}, {"modifiers": ["public"], "name": "ShootMulti", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "flip", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "shoot", "parameters": [{"name": "totalShots", "type": "int", "varargs": false}, {"name": "handler", "type": "BulletHandler", "varargs": false}, {"name": "barrelIncrementer", "type": "Runnable", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
