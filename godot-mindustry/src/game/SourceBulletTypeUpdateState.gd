extends RefCounted
class_name SourceBulletTypeUpdateState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

const SOURCE_BULLET_TRAIL_PARAM_DEFAULT := source_bullet_defaults.TRAIL_PARAM_DEFAULT
const SOURCE_BULLET_ROTATION_COMMENT := "/** @return the bullet's rotation. */"
const SOURCE_BULLET_ROTATION_METHOD := "public float rotation(){"
const SOURCE_BULLET_ROTATION_RETURN := "return vel.isZero(0.001f) ? rotation : vel.angle();"
const SOURCE_BULLET_INTERVAL_DELAY_DEFAULT := source_bullet_defaults.INTERVAL_DELAY_DEFAULT
const SOURCE_BULLET_INTERVAL_BULLETS_DEFAULT := source_bullet_defaults.INTERVAL_BULLETS_DEFAULT
const SOURCE_BULLET_INTERVAL_SPREAD_DEFAULT := source_bullet_defaults.INTERVAL_SPREAD_DEFAULT
const SOURCE_BULLET_INTERVAL_ANGLE_DEFAULT := source_bullet_defaults.INTERVAL_ANGLE_DEFAULT
const SOURCE_BULLET_INTERVAL_DEFAULT := source_bullet_defaults.BULLET_INTERVAL_DEFAULT
const SOURCE_BULLET_TRAIL_SIN_MAG_DEFAULT := source_bullet_defaults.TRAIL_SIN_MAG_DEFAULT
const SOURCE_BULLET_HOMING_POWER_DEFAULT := source_bullet_defaults.HOMING_POWER_DEFAULT
const SOURCE_BULLET_HOMING_POWER_EPSILON := source_bullet_defaults.HOMING_POWER_EPSILON
const SOURCE_BULLET_HOMING_DELAY_DEFAULT := source_bullet_defaults.HOMING_DELAY_DEFAULT
const SOURCE_BULLET_AIM_UNSET_DEFAULT := source_bullet_defaults.AIM_UNSET_DEFAULT
const SOURCE_BULLET_HOMING_RANGE_DEFAULT := source_bullet_defaults.HOMING_RANGE_DEFAULT
const SOURCE_BULLET_FOLLOW_AIM_SPEED_DEFAULT := source_bullet_defaults.FOLLOW_AIM_SPEED_DEFAULT
const SOURCE_BULLET_WEAVE_MAG_DEFAULT := source_bullet_defaults.WEAVE_MAG_DEFAULT
const SOURCE_BULLET_WEAVE_SCALE_DEFAULT := source_bullet_defaults.WEAVE_SCALE_DEFAULT
const SOURCE_BULLET_WEAVE_RANDOM_DEFAULT := source_bullet_defaults.WEAVE_RANDOM_DEFAULT
const SOURCE_BULLET_ROTATE_SPEED_DEFAULT := source_bullet_defaults.ROTATE_SPEED_DEFAULT
const SOURCE_BULLET_CIRCLE_SHOOTER_RADIUS_DEFAULT := source_bullet_defaults.CIRCLE_SHOOTER_RADIUS_DEFAULT
const SOURCE_BULLET_CIRCLE_SHOOTER_RADIUS_SMOOTH_DEFAULT := source_bullet_defaults.CIRCLE_SHOOTER_RADIUS_SMOOTH_DEFAULT
const SOURCE_BULLET_CIRCLE_SHOOTER_ROTATE_SPEED_DEFAULT := source_bullet_defaults.CIRCLE_SHOOTER_ROTATE_SPEED_DEFAULT
const SOURCE_BULLET_CIRCLE_SHOOTER_ROTATION_OFFSET_DEGREES := source_math_defaults.QUARTER_CIRCLE_DEGREES
const SOURCE_BULLET_TRAIL_MIN_VELOCITY_DEFAULT := source_bullet_defaults.TRAIL_MIN_VELOCITY_DEFAULT
const SOURCE_BULLET_TRAIL_CHANCE_DEFAULT := source_bullet_defaults.TRAIL_CHANCE_DEFAULT
const SOURCE_BULLET_TRAIL_SPREAD_DEFAULT := source_bullet_defaults.TRAIL_SPREAD_DEFAULT
const SOURCE_BULLET_TRAIL_INTERVAL_DEFAULT := source_bullet_defaults.TRAIL_INTERVAL_DEFAULT
const SOURCE_BULLET_TRAIL_COLOR_DEFAULT := source_bullet_defaults.TRAIL_COLOR_DEFAULT
const SOURCE_BULLET_TRAIL_EFFECT_DEFAULT := source_bullet_defaults.TRAIL_EFFECT_DEFAULT
const SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY := "angles_angle"
const SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_FALLBACK := "source_arc_angles_angle"
const SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_KEY := "move_toward_angle"
const SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_FALLBACK := "source_arc_angles_move_toward"
const SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_KEY := "trns_vec"
const SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_FALLBACK := "source_arc_angles_trns_vec"
const SOURCE_BULLET_TYPE_UPDATE_VEC2_LIMIT_KEY := "vec2_limit"
const SOURCE_BULLET_TYPE_UPDATE_VEC2_LIMIT_FALLBACK := "source_vec2_limit"
const SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY := "bullet_rotation_degrees"
const SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_FALLBACK := "source_bullet_rotation_degrees"

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
		SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_FALLBACK)),
		SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_KEY, SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_FALLBACK)),
		SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_KEY, SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_FALLBACK)),
		SOURCE_BULLET_TYPE_UPDATE_VEC2_LIMIT_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_VEC2_LIMIT_KEY, SOURCE_BULLET_TYPE_UPDATE_VEC2_LIMIT_FALLBACK)),
		SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY, SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_FALLBACK)),
	}

static func game_update_homing_target_velocity_state(game: Object, homing_initial_state: Dictionary, target_state: Variant, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_homing_target_velocity_state(homing_initial_state, target_state, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_KEY, Callable()))

static func game_update_homing_follow_aim_state(game: Object, homing_target_velocity_state: Dictionary, bullet_type_state: Dictionary, shooter_state: Variant, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_homing_follow_aim_state(homing_target_velocity_state, bullet_type_state, shooter_state, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_KEY, Callable()))

static func game_update_weaving_state(game: Object, bullet_state: Dictionary, bullet_type_state: Dictionary, random_seed_result: int, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_weaving_state(bullet_state, bullet_type_state, random_seed_result, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable()))

static func game_update_weaving_rotate_speed_state(game: Object, weaving_state: Dictionary, bullet_type_state: Dictionary, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_weaving_rotate_speed_state(weaving_state, bullet_type_state, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable()))

static func game_update_weaving_circle_shooter_state(game: Object, rotate_speed_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_weaving_circle_shooter_state(rotate_speed_state, bullet_type_state, owner_health_state, source_delta, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_VEC2_LIMIT_KEY, Callable()), callbacks.get(SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable()))

static func game_bullet_rotation_degrees(game: Object, bullet_state: Dictionary) -> float:
	var callbacks := default_callbacks_state(game)
	return bullet_rotation_degrees(bullet_state, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable()))

static func game_update_trail_effects_chance_state(game: Object, bullet_state: Dictionary, bullet_type_state: Dictionary, chance_delta_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_trail_effects_chance_state(bullet_state, bullet_type_state, chance_delta_result, random_offset_state, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY, Callable()))

static func game_update_trail_effects_interval_state(game: Object, chance_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_trail_effects_interval_state(chance_state, bullet_type_state, timer_get_result, random_offset_state, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY, Callable()))

static func source_vec2_rotate_radians(x_value: float, y_value: float, radians: float) -> Dictionary:
	return source_math_state.source_vec2_rotate_radians(x_value, y_value, radians)

static func bullet_rotation_degrees(bullet_state: Dictionary, angle_callable: Callable) -> float:
	var velocity_state: Dictionary = bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var velocity_len2 := velocity_x * velocity_x + velocity_y * velocity_y
	if velocity_len2 < source_bullet_defaults.ROTATION_ZERO_MARGIN:
		return float(bullet_state.get("rotation", 0.0))
	return float(angle_callable.call(0.0, 0.0, velocity_x, velocity_y))

static func update_dispatch_state(bullet_state: Dictionary) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var call_order := [
		"updateTrail(b)",
		"updateHoming(b)",
		"updateWeaving(b)",
		"updateTrailEffects(b)",
		"updateBulletInterval(b)",
	]
	return {
		"bullet": update_bullet_state,
		"callOrder": call_order,
		"updateMethodSource": "public void update(Bullet b){",
		"nextMethodReservedSource": "public void updateBulletInterval(Bullet b){",
	}

static func update_bullet_interval_state(bullet_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, interval_random_offsets: Array) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var interval_bullet = bullet_type_state.get("intervalBullet", null)
	var gate_passed := interval_bullet != null and float(update_bullet_state.get("time", 0.0)) >= float(bullet_type_state.get("intervalDelay", SOURCE_BULLET_INTERVAL_DELAY_DEFAULT)) and timer_get_result
	var interval_calls: Array = []
	var interval_bullets := int(bullet_type_state.get("intervalBullets", SOURCE_BULLET_INTERVAL_BULLETS_DEFAULT))
	var interval_spread := float(bullet_type_state.get("intervalSpread", SOURCE_BULLET_INTERVAL_SPREAD_DEFAULT))
	var interval_angle := float(bullet_type_state.get("intervalAngle", SOURCE_BULLET_INTERVAL_ANGLE_DEFAULT))
	var base_angle := float(update_bullet_state.get("rotation", 0.0))
	if gate_passed:
		for i in interval_bullets:
			var random_offset := float(interval_random_offsets[i]) if i < interval_random_offsets.size() else 0.0
			var spread_offset := (float(i) - (float(interval_bullets) - 1.0) / 2.0) * interval_spread
			interval_calls.append({
				"bulletType": interval_bullet,
				"owner": update_bullet_state,
				"x": float(update_bullet_state.get("x", 0.0)),
				"y": float(update_bullet_state.get("y", 0.0)),
				"angle": base_angle + random_offset + interval_angle + spread_offset,
				"randomOffset": random_offset,
				"spreadOffset": spread_offset,
			})
	return {
		"bullet": update_bullet_state,
		"gatePassed": gate_passed,
		"timerGetResult": timer_get_result,
		"timerIndex": 2,
		"timerTime": float(bullet_type_state.get("bulletInterval", SOURCE_BULLET_INTERVAL_DEFAULT)),
		"baseAngle": base_angle,
		"intervalBulletCount": interval_calls.size(),
		"intervalBulletCalls": interval_calls,
		"intervalRandomOffsets": interval_random_offsets.duplicate(),
		"gateSource": "if(intervalBullet != null && b.time >= intervalDelay && b.timer.get(2, bulletInterval)){",
		"createSource": "intervalBullet.create(b, b.x, b.y, ang + Mathf.range(intervalRandomSpread) + intervalAngle + ((i - (intervalBullets - 1f)/2f) * intervalSpread))",
		"updateHomingBoundarySource": "public void updateHoming(Bullet b){",
	}

static func update_trail_state(bullet_state: Dictionary, bullet_type_state: Dictionary, headless_value: bool, trail_interp_value: float, absin_value: float, source_delta: float) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var trail_length := int(bullet_type_state.get("trailLength", source_bullet_defaults.TRAIL_LENGTH_DEFAULT))
	var gate_passed := not headless_value and trail_length > 0
	if not gate_passed:
		return {
			"bullet": update_bullet_state,
			"trailUpdated": false,
			"gatePassed": false,
			"gateSource": "if(!headless && trailLength > 0){",
			"updateSource": "b.trail.update(b.x, b.y, trailInterp.apply(b.fin()) * (1f + (trailSinMag > 0 ? Mathf.absin(Time.time, trailSinScl, trailSinMag) : 0f)))",
			"initBoundarySource": "public void init(){",
		}
	var raw_trail_state = update_bullet_state.get("trail", null)
	var trail_state: Dictionary = raw_trail_state if raw_trail_state is Dictionary else {}
	var trail_created := raw_trail_state == null or not (raw_trail_state is Dictionary)
	trail_state["length"] = trail_length
	var sin_scale := 1.0 + (absin_value if float(bullet_type_state.get("trailSinMag", SOURCE_BULLET_TRAIL_SIN_MAG_DEFAULT)) > 0.0 else 0.0)
	var width := trail_interp_value * sin_scale
	trail_state["lastX"] = float(update_bullet_state.get("x", 0.0))
	trail_state["lastY"] = float(update_bullet_state.get("y", 0.0))
	trail_state["lastW"] = width
	trail_state["counter"] = float(trail_state.get("counter", 0.0)) + source_delta
	update_bullet_state["trail"] = trail_state
	return {
		"bullet": update_bullet_state,
		"trail": trail_state,
		"trailCreated": trail_created,
		"trailUpdated": true,
		"gatePassed": true,
		"width": width,
		"sinScale": sin_scale,
		"trailInterpValue": trail_interp_value,
		"absinValue": absin_value,
		"gateSource": "if(!headless && trailLength > 0){",
		"updateSource": "b.trail.update(b.x, b.y, trailInterp.apply(b.fin()) * (1f + (trailSinMag > 0 ? Mathf.absin(Time.time, trailSinScl, trailSinMag) : 0f)))",
		"initBoundarySource": "public void init(){",
	}

static func update_homing_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var homing_power := float(bullet_type_state.get("homingPower", SOURCE_BULLET_HOMING_POWER_DEFAULT))
	var homing_delay := float(bullet_type_state.get("homingDelay", SOURCE_BULLET_HOMING_DELAY_DEFAULT))
	var gate_passed := homing_power > SOURCE_BULLET_HOMING_POWER_EPSILON and float(update_bullet_state.get("time", 0.0)) >= homing_delay
	var aim_x := float(update_bullet_state.get("aimX", SOURCE_BULLET_AIM_UNSET_DEFAULT))
	var aim_y := float(update_bullet_state.get("aimY", SOURCE_BULLET_AIM_UNSET_DEFAULT))
	var real_aim_x := float(update_bullet_state.get("x", 0.0)) if aim_x < 0.0 else aim_x
	var real_aim_y := float(update_bullet_state.get("y", 0.0)) if aim_y < 0.0 else aim_y
	var reported_real_aim_x: Variant = null
	var reported_real_aim_y: Variant = null
	if gate_passed:
		reported_real_aim_x = real_aim_x
		reported_real_aim_y = real_aim_y
	return {
		"bullet": update_bullet_state,
		"gatePassed": gate_passed,
		"realAimComputed": gate_passed,
		"realAimX": reported_real_aim_x,
		"realAimY": reported_real_aim_y,
		"aimX": aim_x,
		"aimY": aim_y,
		"homingPower": homing_power,
		"homingDelay": homing_delay,
		"homingRange": float(bullet_type_state.get("homingRange", SOURCE_BULLET_HOMING_RANGE_DEFAULT)),
		"targetSelectionDeferred": true,
		"followAimDeferred": true,
		"gateSource": "if(homingPower > 0.0001f && b.time >= homingDelay){",
		"realAimXSource": "float realAimX = b.aimX < 0 ? b.x : b.aimX",
		"realAimYSource": "float realAimY = b.aimY < 0 ? b.y : b.aimY",
		"targetReservedSource": "Teamc target",
		"followAimReservedSource": "if(followAimSpeed > 0f && b.shooter instanceof Unit u)",
	}

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

static func update_trail_effects_chance_state(bullet_state: Dictionary, bullet_type_state: Dictionary, chance_delta_result: bool, random_offset_state: Dictionary, rotation_degrees_callable: Callable) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var velocity_len2 := velocity_x * velocity_x + velocity_y * velocity_y
	var trail_min_velocity := float(bullet_type_state.get("trailMinVelocity", SOURCE_BULLET_TRAIL_MIN_VELOCITY_DEFAULT))
	var can_spawn := trail_min_velocity <= 0.0 or velocity_len2 >= trail_min_velocity * trail_min_velocity
	var trail_chance := float(bullet_type_state.get("trailChance", SOURCE_BULLET_TRAIL_CHANCE_DEFAULT))
	var gate_passed := trail_chance > 0.0 and can_spawn
	if not gate_passed or not chance_delta_result:
		return {
			"bullet": update_bullet_state,
			"trailChanceEffectApplied": false,
			"canSpawn": can_spawn,
			"chanceGatePassed": gate_passed,
			"chanceDeltaResult": chance_delta_result,
			"effectCalls": [],
			"canSpawnSource": "boolean canSpawn = trailMinVelocity <= 0f || b.vel.len2() >= trailMinVelocity * trailMinVelocity",
			"chanceGateSource": "if(trailChance > 0 && canSpawn){",
			"chanceDeltaSource": "if(Mathf.chanceDelta(trailChance)){",
			"effectAtSource": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)",
		}
	var trail_spread := float(bullet_type_state.get("trailSpread", SOURCE_BULLET_TRAIL_SPREAD_DEFAULT))
	var tmp_offset: Dictionary = {"x": 0.0, "y": 0.0}
	if trail_spread > 0.0:
		tmp_offset = random_offset_state.duplicate(true)
	var effect_rotation: float = float(rotation_degrees_callable.call(update_bullet_state)) if bool(bullet_type_state.get("trailRotation", false)) else float(bullet_type_state.get("trailParam", SOURCE_BULLET_TRAIL_PARAM_DEFAULT))
	var effect_call := {"x": float(update_bullet_state.get("x", 0.0)) + float(tmp_offset.get("x", 0.0)), "y": float(update_bullet_state.get("y", 0.0)) + float(tmp_offset.get("y", 0.0)), "rotation": effect_rotation, "color": bullet_type_state.get("trailColor", SOURCE_BULLET_TRAIL_COLOR_DEFAULT), "effect": bullet_type_state.get("trailEffect", SOURCE_BULLET_TRAIL_EFFECT_DEFAULT)}
	return {
		"bullet": update_bullet_state,
		"trailChanceEffectApplied": true,
		"canSpawn": can_spawn,
		"chanceGatePassed": gate_passed,
		"chanceDeltaResult": chance_delta_result,
		"trailSpread": trail_spread,
		"tmpOffset": tmp_offset,
		"effectCalls": [effect_call],
		"canSpawnSource": "boolean canSpawn = trailMinVelocity <= 0f || b.vel.len2() >= trailMinVelocity * trailMinVelocity",
		"chanceGateSource": "if(trailChance > 0 && canSpawn){",
		"chanceDeltaSource": "if(Mathf.chanceDelta(trailChance)){",
		"spreadRandomSource": "Tmp.v1.rnd(Mathf.random(trailSpread))",
		"spreadZeroSource": "Tmp.v1.setZero()",
		"effectAtSource": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)",
	}

static func update_trail_effects_interval_state(chance_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, random_offset_state: Dictionary, rotation_degrees_callable: Callable) -> Dictionary:
	var update_bullet_state: Dictionary = chance_state.get("bullet", {}).duplicate(true)
	var effect_calls: Array = chance_state.get("effectCalls", []).duplicate(true)
	var can_spawn := bool(chance_state.get("canSpawn", false))
	var trail_interval := float(bullet_type_state.get("trailInterval", SOURCE_BULLET_TRAIL_INTERVAL_DEFAULT))
	var gate_passed := trail_interval > 0.0 and can_spawn
	if not gate_passed or not timer_get_result:
		return {
			"bullet": update_bullet_state,
			"trailIntervalEffectApplied": false,
			"canSpawn": can_spawn,
			"intervalGatePassed": gate_passed,
			"timerGetResult": timer_get_result,
			"effectCalls": effect_calls,
			"intervalGateSource": "if(trailInterval > 0f && canSpawn){",
			"timerSource": "if(b.timer(0, trailInterval)){",
			"effectAtSource": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)",
		}
	var trail_spread := float(bullet_type_state.get("trailSpread", SOURCE_BULLET_TRAIL_SPREAD_DEFAULT))
	var tmp_offset: Dictionary = {"x": 0.0, "y": 0.0}
	if trail_spread > 0.0:
		tmp_offset = random_offset_state.duplicate(true)
	var effect_rotation: float = float(rotation_degrees_callable.call(update_bullet_state)) if bool(bullet_type_state.get("trailRotation", false)) else float(bullet_type_state.get("trailParam", SOURCE_BULLET_TRAIL_PARAM_DEFAULT))
	var effect_call := {"x": float(update_bullet_state.get("x", 0.0)) + float(tmp_offset.get("x", 0.0)), "y": float(update_bullet_state.get("y", 0.0)) + float(tmp_offset.get("y", 0.0)), "rotation": effect_rotation, "color": bullet_type_state.get("trailColor", SOURCE_BULLET_TRAIL_COLOR_DEFAULT), "effect": bullet_type_state.get("trailEffect", SOURCE_BULLET_TRAIL_EFFECT_DEFAULT)}
	effect_calls.append(effect_call)
	return {
		"bullet": update_bullet_state,
		"trailIntervalEffectApplied": true,
		"canSpawn": can_spawn,
		"intervalGatePassed": gate_passed,
		"timerGetResult": timer_get_result,
		"trailSpread": trail_spread,
		"tmpOffset": tmp_offset,
		"effectCalls": effect_calls,
		"intervalGateSource": "if(trailInterval > 0f && canSpawn){",
		"timerSource": "if(b.timer(0, trailInterval)){",
		"spreadRandomSource": "Tmp.v1.rnd(Mathf.random(trailSpread))",
		"spreadZeroSource": "Tmp.v1.setZero()",
		"effectAtSource": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)",
	}
