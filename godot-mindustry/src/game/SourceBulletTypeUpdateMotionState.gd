extends RefCounted
class_name SourceBulletTypeUpdateMotionState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_geometry_callback_registry := preload("res://src/game/SourceGeometryCallbackRegistry.gd")
const source_math_callback_registry := preload("res://src/game/SourceMathCallbackRegistry.gd")

const SOURCE_BULLET_FOLLOW_AIM_SPEED_DEFAULT := source_bullet_defaults.FOLLOW_AIM_SPEED_DEFAULT
const SOURCE_BULLET_WEAVE_MAG_DEFAULT := source_bullet_defaults.WEAVE_MAG_DEFAULT
const SOURCE_BULLET_WEAVE_SCALE_DEFAULT := source_bullet_defaults.WEAVE_SCALE_DEFAULT
const SOURCE_BULLET_WEAVE_RANDOM_DEFAULT := source_bullet_defaults.WEAVE_RANDOM_DEFAULT
const SOURCE_BULLET_ROTATE_SPEED_DEFAULT := source_bullet_defaults.ROTATE_SPEED_DEFAULT
const SOURCE_BULLET_CIRCLE_SHOOTER_RADIUS_DEFAULT := source_bullet_defaults.CIRCLE_SHOOTER_RADIUS_DEFAULT
const SOURCE_BULLET_CIRCLE_SHOOTER_RADIUS_SMOOTH_DEFAULT := source_bullet_defaults.CIRCLE_SHOOTER_RADIUS_SMOOTH_DEFAULT
const SOURCE_BULLET_CIRCLE_SHOOTER_ROTATE_SPEED_DEFAULT := source_bullet_defaults.CIRCLE_SHOOTER_ROTATE_SPEED_DEFAULT
const SOURCE_BULLET_CIRCLE_SHOOTER_ROTATION_OFFSET_DEGREES := source_math_defaults.QUARTER_CIRCLE_DEGREES
const SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_KEY := source_geometry_callback_registry.ANGLES_ANGLE_KEY
const SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_FALLBACK := source_geometry_callback_registry.ANGLES_ANGLE_FALLBACK
const SOURCE_BULLET_TYPE_UPDATE_MOTION_MOVE_TOWARD_ANGLE_KEY := source_geometry_callback_registry.MOVE_TOWARD_ANGLE_KEY
const SOURCE_BULLET_TYPE_UPDATE_MOTION_MOVE_TOWARD_ANGLE_FALLBACK := source_geometry_callback_registry.MOVE_TOWARD_ANGLE_FALLBACK
const SOURCE_BULLET_TYPE_UPDATE_MOTION_TRNS_VEC_KEY := source_geometry_callback_registry.TRNS_VEC_KEY
const SOURCE_BULLET_TYPE_UPDATE_MOTION_TRNS_VEC_FALLBACK := source_geometry_callback_registry.TRNS_VEC_FALLBACK
const SOURCE_BULLET_TYPE_UPDATE_MOTION_VEC2_LIMIT_KEY := source_math_callback_registry.VEC2_LIMIT_KEY
const SOURCE_BULLET_TYPE_UPDATE_MOTION_VEC2_LIMIT_FALLBACK := source_math_callback_registry.VECTOR_STATE_LIMIT_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_bullet_type_update_method_names"):
		var names = game.call("_bullet_type_update_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_KEY, SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_FALLBACK)),
		SOURCE_BULLET_TYPE_UPDATE_MOTION_MOVE_TOWARD_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_MOTION_MOVE_TOWARD_ANGLE_KEY, SOURCE_BULLET_TYPE_UPDATE_MOTION_MOVE_TOWARD_ANGLE_FALLBACK)),
		SOURCE_BULLET_TYPE_UPDATE_MOTION_TRNS_VEC_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_MOTION_TRNS_VEC_KEY, SOURCE_BULLET_TYPE_UPDATE_MOTION_TRNS_VEC_FALLBACK)),
		SOURCE_BULLET_TYPE_UPDATE_MOTION_VEC2_LIMIT_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_MOTION_VEC2_LIMIT_KEY, SOURCE_BULLET_TYPE_UPDATE_MOTION_VEC2_LIMIT_FALLBACK)),
	}

static func game_update_homing_target_velocity_state(game: Object, homing_initial_state: Dictionary, target_state: Variant, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_homing_target_velocity_state(homing_initial_state, target_state, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_MOVE_TOWARD_ANGLE_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_TRNS_VEC_KEY, Callable()))

static func game_update_homing_follow_aim_state(game: Object, homing_target_velocity_state: Dictionary, bullet_type_state: Dictionary, shooter_state: Variant, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_homing_follow_aim_state(homing_target_velocity_state, bullet_type_state, shooter_state, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_MOVE_TOWARD_ANGLE_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_TRNS_VEC_KEY, Callable()))

static func game_update_weaving_state(game: Object, bullet_state: Dictionary, bullet_type_state: Dictionary, random_seed_result: int, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_weaving_state(bullet_state, bullet_type_state, random_seed_result, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_KEY, Callable()))

static func game_update_weaving_rotate_speed_state(game: Object, weaving_state: Dictionary, bullet_type_state: Dictionary, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_weaving_rotate_speed_state(weaving_state, bullet_type_state, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_KEY, Callable()))

static func game_update_weaving_circle_shooter_state(game: Object, rotate_speed_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_weaving_circle_shooter_state(rotate_speed_state, bullet_type_state, owner_health_state, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_VEC2_LIMIT_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOTION_ANGLES_ANGLE_KEY, Callable()))

static func source_vec2_rotate_radians(x_value: float, y_value: float, radians: float) -> Dictionary:
	return source_math_state.source_vec2_rotate_radians(x_value, y_value, radians)

static func update_homing_target_velocity_state(homing_initial_state: Dictionary, target_state: Variant, source_delta: float, angle_callable: Callable, move_toward_callable: Callable, trns_vec_callable: Callable) -> Dictionary:
	var update_bullet_state: Dictionary = homing_initial_state.get("bullet", {}).duplicate(true)
	var gate_passed := bool(homing_initial_state.get("gatePassed", false)) and target_state is Dictionary
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"homingVelocityApplied": false,
			"targetGatePassed": false,
			"targetGateSource": "if(target != null){",
			"setAngleSource": "b.vel.setAngle(Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f))",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var current_rotation := float(update_bullet_state.get("rotation", float(velocity_state.get("angle", 0.0))))
	var homing_power := float(homing_initial_state.get("homingPower", 0.0))
	var target_angle := float(angle_callable.call(float(update_bullet_state.get("x", 0.0)), float(update_bullet_state.get("y", 0.0)), float(target_state.get("x", 0.0)), float(target_state.get("y", 0.0))))
	var max_turn := homing_power * source_delta * 50.0
	var next_angle := float(move_toward_callable.call(current_rotation, target_angle, max_turn))
	var speed := float(velocity_state.get("speed", sqrt(velocity_x * velocity_x + velocity_y * velocity_y)))
	var next_velocity := trns_vec_callable.call(next_angle, speed, 0.0) as Dictionary
	update_bullet_state["rotation"] = next_angle
	update_bullet_state["velocity"] = {"angle": next_angle, "speed": speed, "x": next_velocity["x"], "y": next_velocity["y"]}
	return {
		"bullet": update_bullet_state,
		"homingVelocityApplied": true,
		"targetGatePassed": true,
		"currentRotation": current_rotation,
		"targetAngle": target_angle,
		"maxTurn": max_turn,
		"nextAngle": next_angle,
		"speed": speed,
		"velocity": update_bullet_state["velocity"],
		"targetGateSource": "if(target != null){",
		"setAngleSource": "b.vel.setAngle(Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f))",
		"angleToSource": "return Angles.angle(getX(), getY(), other.getX(), other.getY())",
		"vec2SetAngleSource": "this.set(len(), 0f); this.rotateRad(radians)",
	}

static func update_homing_follow_aim_state(homing_target_velocity_state: Dictionary, bullet_type_state: Dictionary, shooter_state: Variant, source_delta: float, angle_callable: Callable, move_toward_callable: Callable, trns_vec_callable: Callable) -> Dictionary:
	var update_bullet_state: Dictionary = homing_target_velocity_state.get("bullet", {}).duplicate(true)
	var follow_aim_speed := float(bullet_type_state.get("followAimSpeed", SOURCE_BULLET_FOLLOW_AIM_SPEED_DEFAULT))
	var gate_passed := follow_aim_speed > 0.0 and shooter_state is Dictionary and bool(shooter_state.get("isUnit", false))
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"followAimApplied": false,
			"followAimGatePassed": false,
			"followAimGateSource": "if(followAimSpeed > 0f && b.shooter instanceof Unit u){",
			"followAimSetAngleSource": "b.vel.setAngle(Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta))",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var target_angle := float(angle_callable.call(float(update_bullet_state.get("x", 0.0)), float(update_bullet_state.get("y", 0.0)), float(shooter_state.get("aimX", 0.0)), float(shooter_state.get("aimY", 0.0))))
	var current_velocity_angle := float(velocity_state.get("angle", update_bullet_state.get("rotation", 0.0)))
	var max_turn := follow_aim_speed * source_delta
	var next_angle := float(move_toward_callable.call(current_velocity_angle, target_angle, max_turn))
	var speed := float(velocity_state.get("speed", sqrt(velocity_x * velocity_x + velocity_y * velocity_y)))
	var next_velocity := trns_vec_callable.call(next_angle, speed, 0.0) as Dictionary
	update_bullet_state["rotation"] = next_angle
	update_bullet_state["velocity"] = {"angle": next_angle, "speed": speed, "x": next_velocity["x"], "y": next_velocity["y"]}
	return {
		"bullet": update_bullet_state,
		"followAimApplied": true,
		"followAimGatePassed": true,
		"currentVelocityAngle": current_velocity_angle,
		"targetAngle": target_angle,
		"maxTurn": max_turn,
		"nextAngle": next_angle,
		"speed": speed,
		"velocity": update_bullet_state["velocity"],
		"followAimGateSource": "if(followAimSpeed > 0f && b.shooter instanceof Unit u){",
		"followAimAngleSource": "float angle = b.angleTo(u.aimX, u.aimY)",
		"followAimSetAngleSource": "b.vel.setAngle(Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta))",
	}

static func update_weaving_state(bullet_state: Dictionary, bullet_type_state: Dictionary, random_seed_result: int, source_delta: float, angle_callable: Callable) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var weave_mag := float(bullet_type_state.get("weaveMag", SOURCE_BULLET_WEAVE_MAG_DEFAULT))
	var gate_passed := weave_mag != 0.0
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"weaveApplied": false,
			"weaveGatePassed": false,
			"weaveGateSource": "if(weaveMag != 0){",
			"rotateRadExactSource": "b.vel.rotateRadExact((float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad)",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var weave_scale := float(bullet_type_state.get("weaveScale", SOURCE_BULLET_WEAVE_SCALE_DEFAULT))
	var random_sign := -1.0 if bool(bullet_type_state.get("weaveRandom", SOURCE_BULLET_WEAVE_RANDOM_DEFAULT)) and random_seed_result == 1 else 1.0
	var rotation_radians := sin((float(update_bullet_state.get("time", 0.0)) + PI * weave_scale / 2.0) / weave_scale) * weave_mag * random_sign * source_delta * deg_to_rad(1.0)
	var rotated_velocity := source_vec2_rotate_radians(velocity_x, velocity_y, rotation_radians)
	var next_x := float(rotated_velocity.get("x", 0.0))
	var next_y := float(rotated_velocity.get("y", 0.0))
	update_bullet_state["velocity"] = {"x": next_x, "y": next_y, "angle": float(angle_callable.call(0.0, 0.0, next_x, next_y)), "speed": sqrt(next_x * next_x + next_y * next_y)}
	return {
		"bullet": update_bullet_state,
		"weaveApplied": true,
		"weaveGatePassed": true,
		"rotationRadians": rotation_radians,
		"randomSign": random_sign,
		"randomSeedResult": random_seed_result,
		"velocity": update_bullet_state["velocity"],
		"weaveGateSource": "if(weaveMag != 0){",
		"rotateRadExactSource": "b.vel.rotateRadExact((float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad)",
		"vec2RotateRadExactSource": "float newX = this.x * cos - this.y * sin; float newY = this.x * sin + this.y * cos",
	}

static func update_weaving_rotate_speed_state(weaving_state: Dictionary, bullet_type_state: Dictionary, source_delta: float, angle_callable: Callable) -> Dictionary:
	var update_bullet_state: Dictionary = weaving_state.get("bullet", {}).duplicate(true)
	var rotate_speed := float(bullet_type_state.get("rotateSpeed", SOURCE_BULLET_ROTATE_SPEED_DEFAULT))
	var gate_passed := rotate_speed != 0.0
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"rotateSpeedApplied": false,
			"rotateSpeedGatePassed": false,
			"rotateSpeedGateSource": "if(rotateSpeed != 0){",
			"rotateSpeedSource": "b.vel.rotate(rotateSpeed * Time.delta)",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var rotation_radians := rotate_speed * source_delta * deg_to_rad(1.0)
	var rotated_velocity := source_vec2_rotate_radians(velocity_x, velocity_y, rotation_radians)
	var next_x := float(rotated_velocity.get("x", 0.0))
	var next_y := float(rotated_velocity.get("y", 0.0))
	update_bullet_state["velocity"] = {"x": next_x, "y": next_y, "angle": float(angle_callable.call(0.0, 0.0, next_x, next_y)), "speed": sqrt(next_x * next_x + next_y * next_y)}
	return {
		"bullet": update_bullet_state,
		"rotateSpeedApplied": true,
		"rotateSpeedGatePassed": true,
		"rotationRadians": rotation_radians,
		"velocity": update_bullet_state["velocity"],
		"rotateSpeedGateSource": "if(rotateSpeed != 0){",
		"rotateSpeedSource": "b.vel.rotate(rotateSpeed * Time.delta)",
		"vec2RotateSource": "return rotateRad(degrees * Mathf.degreesToRadians)",
	}

static func update_weaving_circle_shooter_state(rotate_speed_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, source_delta: float, limit_callable: Callable, angle_callable: Callable) -> Dictionary:
	var update_bullet_state: Dictionary = rotate_speed_state.get("bullet", {}).duplicate(true)
	var gate_passed := bool(bullet_type_state.get("circleShooter", false)) and bool(owner_health_state.get("isHealthc", false)) and bool(owner_health_state.get("isValid", false))
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"circleShooterApplied": false,
			"circleShooterGatePassed": false,
			"circleShooterGateSource": "if(circleShooter && b.owner instanceof Healthc h && h.isValid()){",
			"circleShooterVelocitySource": "b.vel.add(Tmp.v1.limit(speed * circleShooterRotateSpeed * Time.delta)).limit(speed)",
		}
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var tmp_x := float(owner_health_state.get("x", 0.0)) - float(update_bullet_state.get("x", 0.0))
	var tmp_y := float(owner_health_state.get("y", 0.0)) - float(update_bullet_state.get("y", 0.0))
	var tmp_len := sqrt(tmp_x * tmp_x + tmp_y * tmp_y)
	var circle_radius := float(bullet_type_state.get("circleShooterRadius", SOURCE_BULLET_CIRCLE_SHOOTER_RADIUS_DEFAULT))
	var circle_radius_smooth := float(bullet_type_state.get("circleShooterRadiusSmooth", SOURCE_BULLET_CIRCLE_SHOOTER_RADIUS_SMOOTH_DEFAULT))
	var circle_rotate_speed := float(bullet_type_state.get("circleShooterRotateSpeed", SOURCE_BULLET_CIRCLE_SHOOTER_ROTATE_SPEED_DEFAULT))
	var speed := float(bullet_type_state.get("speed", source_bullet_defaults.WORLD_SPEED_DEFAULT))
	var circle_rotation_degrees: float = SOURCE_BULLET_CIRCLE_SHOOTER_ROTATION_OFFSET_DEGREES * (0.0 + (1.0 - 0.0) * (1.0 - clamp((tmp_len - circle_radius) / circle_radius_smooth, 0.0, 1.0)))
	var rotation_radians := circle_rotation_degrees * deg_to_rad(1.0)
	var tmp_rotated := source_vec2_rotate_radians(tmp_x, tmp_y, rotation_radians)
	var tmp_limit := speed * circle_rotate_speed * source_delta
	var limited_tmp := limit_callable.call(tmp_rotated, tmp_limit) as Dictionary
	var limited_velocity := limit_callable.call({"x": velocity_x + float(limited_tmp.get("x", 0.0)), "y": velocity_y + float(limited_tmp.get("y", 0.0))}, speed) as Dictionary
	update_bullet_state["velocity"] = {"x": float(limited_velocity.get("x", 0.0)), "y": float(limited_velocity.get("y", 0.0)), "angle": float(angle_callable.call(0.0, 0.0, float(limited_velocity.get("x", 0.0)), float(limited_velocity.get("y", 0.0)))), "speed": sqrt(float(limited_velocity.get("x", 0.0)) * float(limited_velocity.get("x", 0.0)) + float(limited_velocity.get("y", 0.0)) * float(limited_velocity.get("y", 0.0)))}
	return {
		"bullet": update_bullet_state,
		"circleShooterApplied": true,
		"circleShooterGatePassed": true,
		"tmpBeforeRotate": {"x": tmp_x, "y": tmp_y, "len": tmp_len},
		"rotationDegrees": circle_rotation_degrees,
		"rotationRadians": rotation_radians,
		"tmpLimit": tmp_limit,
		"limitedTmp": limited_tmp,
		"velocity": update_bullet_state["velocity"],
		"circleShooterGateSource": "if(circleShooter && b.owner instanceof Healthc h && h.isValid()){",
		"circleShooterTmpSource": "Tmp.v1.set(h).sub(b)",
		"circleShooterRotateSource": "Tmp.v1.rotate(90f * Mathf.lerp(0f, 1f, 1f - Mathf.clamp((Tmp.v1.len() - circleShooterRadius) / circleShooterRadiusSmooth)))",
		"circleShooterVelocitySource": "b.vel.add(Tmp.v1.limit(speed * circleShooterRotateSpeed * Time.delta)).limit(speed)",
	}
