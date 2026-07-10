# Generated from Mindustry upstream.
# Source: mindustry/entities/pattern/ShootPattern.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.pattern"
const JAVA_KIND := "class"
const JAVA_NAME := "ShootPattern"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Cloneable"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "shots", "type": "int"}, {"modifiers": ["public"], "name": "firstShotDelay", "type": "float"}, {"modifiers": ["public"], "name": "shotDelay", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "shoot", "parameters": [{"name": "totalShots", "type": "int", "varargs": false}, {"name": "handler", "type": "BulletHandler", "varargs": false}, {"name": "barrelIncrementer", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "shoot", "parameters": [{"name": "totalShots", "type": "int", "varargs": false}, {"name": "handler", "type": "BulletHandler", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "flip", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "ShootPattern"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_shoot_0(_args: Array = []) -> Variant:
	return null

func java_method_shoot_1(_args: Array = []) -> Variant:
	var shots: int = int(_args[0] if _args.size() > 0 else 1)
	var first_shot_delay: float = float(_args[1] if _args.size() > 1 else 0.0)
	var shot_delay: float = float(_args[2] if _args.size() > 2 else 0.0)
	var events: Array = []
	for i in shots:
		events.append({
			"xOffset": 0.0,
			"yOffset": 0.0,
			"angleOffset": 0.0,
			"delay": first_shot_delay + shot_delay * float(i),
			"mover": null,
		})
	return {
		"source_owner": "PortGame.source_shoot_pattern_default_events",
		"source": "core/src/mindustry/entities/pattern/ShootPattern.java",
		"method": "public void shoot(int totalShots, BulletHandler handler){",
		"loop": "for(int i = 0; i < shots; i++){",
		"handler_call": "handler.shoot(0, 0, 0, firstShotDelay + shotDelay * i);",
		"mover_null": "shoot(x, y, rotation, delay, null);",
		"shots": shots,
		"firstShotDelay": first_shot_delay,
		"shotDelay": shot_delay,
		"events": events,
	}

func java_method_flip_2(_args: Array = []) -> Variant:
	return null

func java_method_copy_3(_args: Array = []) -> Variant:
	return null
