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
const source_shoot_pattern_defaults := preload("res://src/game/SourceShootPatternDefaults.gd")
const SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT := source_shoot_pattern_defaults.SHOTS_DEFAULT
const SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT := source_shoot_pattern_defaults.FIRST_SHOT_DELAY_DEFAULT
const SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT := source_shoot_pattern_defaults.SHOT_DELAY_DEFAULT

func java_method_shoot_0(_args: Array = []) -> Variant:
	var total_shots: int = int(_args[0] if _args.size() > 0 else 0)
	var shots: int = int(_args[1] if _args.size() > 1 else SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT)
	var first_shot_delay: float = float(_args[2] if _args.size() > 2 else SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT)
	var shot_delay: float = float(_args[3] if _args.size() > 3 else SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT)
	var barrel_incrementer_present: bool = bool(_args[4] if _args.size() > 4 else false)
	var compat_result = java_method_shoot_1([shots, first_shot_delay, shot_delay])
	return {
		"source_owner": "port_game.source_shoot_pattern_default_events",
		"generated_owner": "shoot_pattern.java_method_shoot_0",
		"source": "core/src/mindustry/entities/pattern/ShootPattern.java",
		"method": "public void shoot(int totalShots, BulletHandler handler, @Nullable Runnable barrelIncrementer){",
		"compatibility_call": "shoot(totalShots, handler);",
		"compatibility_comment": "//the default implementation calls the \"soft deprecated\" variant for mod compatibility, so overrides from older mods can function properly",
		"totalShots": total_shots,
		"shots": shots,
		"firstShotDelay": first_shot_delay,
		"shotDelay": shot_delay,
		"barrelIncrementerPresent": barrel_incrementer_present,
		"barrelIncrementerCalls": 0,
		"barrelIncrementerIgnored": true,
		"compat_result": compat_result,
		"events": compat_result.get("events", []),
	}

func java_method_shoot_1(_args: Array = []) -> Variant:
	var shots: int = int(_args[0] if _args.size() > 0 else SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT)
	var first_shot_delay: float = float(_args[1] if _args.size() > 1 else SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT)
	var shot_delay: float = float(_args[2] if _args.size() > 2 else SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT)
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
		"source_owner": "port_game.source_shoot_pattern_default_events",
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
	return {
		"source_owner": "ShootPattern.flip",
		"generated_owner": "shoot_pattern.java_method_flip_2",
		"source": "core/src/mindustry/entities/pattern/ShootPattern.java",
		"method": "public void flip(){",
		"comment": "/** Subclasses should override this to flip its sides. */",
		"no_op": true,
		"mutated_fields": [],
	}

func java_method_copy_3(_args: Array = []) -> Variant:
	var shots: int = int(_args[0] if _args.size() > 0 else SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT)
	var first_shot_delay: float = float(_args[1] if _args.size() > 1 else SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT)
	var shot_delay: float = float(_args[2] if _args.size() > 2 else SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT)
	var copy_state := {
		"shots": shots,
		"firstShotDelay": first_shot_delay,
		"shotDelay": shot_delay,
	}
	return {
		"source_owner": "ShootPattern.copy",
		"generated_owner": "shoot_pattern.java_method_copy_3",
		"source": "core/src/mindustry/entities/pattern/ShootPattern.java",
		"method": "public ShootPattern copy(){",
		"try_source": "try{",
		"clone_return_source": "return (ShootPattern)clone();",
		"catch_source": "}catch(CloneNotSupportedException absurd){",
		"throw_source": "throw new RuntimeException(\"impending doom\", absurd);",
		"implements_cloneable": "public class ShootPattern implements Cloneable{",
		"copy": copy_state,
		"same_reference": false,
	}
