extends RefCounted
class_name SourceBulletRuntime

const SourceBulletDefaults := preload("res://src/game/SourceBulletDefaults.gd")

const SOURCE_BULLET_RANGE_CHANGE_COMMENT := "/** When used in a turret with multiple ammo types, this can be set to a non-zero value to influence range. */"
const SOURCE_BULLET_RANGE_CHANGE_FIELD := "public float rangeChange = 0f;"
const SOURCE_BULLET_RANGE_CHANGE_KEY := "rangeChange"
const SOURCE_BULLET_INACCURACY_COMMENT := "/** Extra inaccuracy when firing. */"
const SOURCE_BULLET_INACCURACY_FIELD := "public float inaccuracy = 0f;"
const SOURCE_BULLET_INACCURACY_KEY := "inaccuracy"
const SOURCE_BULLET_LIFETIME_COMMENT := "/** Lifetime in ticks. */"
const SOURCE_BULLET_LIFETIME_FIELD := "public float lifetime = 40f;"
const SOURCE_BULLET_LIFETIME_KEY := "lifetime"
const SOURCE_BULLET_WORLD_SPEED_COMMENT := "/** Speed in units/tick. */"
const SOURCE_BULLET_WORLD_SPEED_FIELD := "public float speed = 1f;"
const SOURCE_BULLET_WORLD_SPEED_STAT_CASE := "case speed -> type.speed * 60f / tilesize;"
const SOURCE_BULLET_WORLD_SPEED_KEY := "speed"
const SOURCE_BULLET_VELOCITY_SPEED_FIELD := "public float speed = 1f;"
const SOURCE_BULLET_VELOCITY_INIT_VEL_CALL := "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));"
const SOURCE_BULLET_VELOCITY_COMP_INIT_VEL_METHOD := "public void initVel(float angle, float amount){"
const SOURCE_BULLET_VELOCITY_COMP_TRNS := "vel.trns(angle, amount);"
const SOURCE_BULLET_VELOCITY_COMP_ROTATION := "rotation = angle;"
const SOURCE_BULLET_VELOCITY_VECTOR_FIELD := "Vec2 vel = new Vec2();"
const SOURCE_BULLET_VELOCITY_VECTOR_INIT_TRNS := "vel.trns(angle, amount);"
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_METHOD := "public Vec2 trns(float angle, float amount){"
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_RETURN := "return set(amount, 0).rotate(angle);"
const SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE := "existing Vec2 velocity"
const SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE := "vel.trns(angle, amount)"
const SOURCE_BULLET_ROTATION_ZERO_MARGIN := 0.001
const SOURCE_BULLET_HIT_SIZE_FIELD := "public float hitSize = 4;"
const SOURCE_BULLET_HIT_SIZE_KEY := "hitSize"
const SOURCE_BULLET_DAMAGE_FIELD := "public float damage = 1f;"
const SOURCE_BULLET_DAMAGE_KEY := "damage"
const SOURCE_BULLET_AMMO_MULTIPLIER_COMMENT := "/** How many bullets get created per ammo item/liquid. */"
const SOURCE_BULLET_AMMO_MULTIPLIER_FIELD := "public float ammoMultiplier = 2f;"
const SOURCE_BULLET_AMMO_MULTIPLIER_KEY := "ammoMultiplier"
const SOURCE_BULLET_RELOAD_MULTIPLIER_COMMENT := "/** Multiplied by turret reload speed to get final shoot speed. */"
const SOURCE_BULLET_RELOAD_MULTIPLIER_FIELD := "public float reloadMultiplier = 1f;"
const SOURCE_BULLET_RELOAD_MULTIPLIER_KEY := "reloadMultiplier"
const SOURCE_BULLET_SCALE_FIELD := "public float width = 5f, height = 7f;"
const SOURCE_BULLET_SCALE_WIDTH_KEY := "width"
const SOURCE_BULLET_SCALE_HEIGHT_KEY := "height"

static func range_change(data: Dictionary, defaults: SourceBulletDefaults) -> float:
	return float(data.get(SOURCE_BULLET_RANGE_CHANGE_KEY, defaults.range_change_default()))

static func inaccuracy(data: Dictionary, defaults: SourceBulletDefaults) -> float:
	return float(data.get(SOURCE_BULLET_INACCURACY_KEY, defaults.inaccuracy_default()))

static func lifetime_seconds(data: Dictionary, defaults: SourceBulletDefaults, tick_rate: float) -> float:
	if tick_rate == 0.0:
		return 0.0
	return float(data.get(SOURCE_BULLET_LIFETIME_KEY, defaults.lifetime_default())) / tick_rate

static func world_speed(data: Dictionary, defaults: SourceBulletDefaults, tick_rate: float) -> float:
	return float(data.get(SOURCE_BULLET_WORLD_SPEED_KEY, defaults.speed_default())) * tick_rate

static func velocity(data: Dictionary, defaults: SourceBulletDefaults, tick_rate: float, shoot_angle_degrees: float) -> Vector2:
	return Vector2.RIGHT.rotated(deg_to_rad(shoot_angle_degrees)) * world_speed(data, defaults, tick_rate)

static func velocity_vector_state(velocity_state: Dictionary) -> Dictionary:
	if velocity_state.has("x") or velocity_state.has("y"):
		return {
			"x": float(velocity_state.get("x", 0.0)),
			"y": float(velocity_state.get("y", 0.0)),
			"source": SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE,
		}
	var angle := float(velocity_state.get("angle", 0.0))
	var speed := float(velocity_state.get("speed", 0.0))
	var vec := Vector2.RIGHT.rotated(deg_to_rad(angle)) * speed
	return {
		"x": vec.x,
		"y": vec.y,
		"angle": angle,
		"speed": speed,
		"source": SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE,
	}

static func create_keep_velocity_state(trail_add_state: Dictionary, bullet_type_state: Dictionary, owner_state: Dictionary, defaults: SourceBulletDefaults) -> Dictionary:
	var raw_bullet_state = trail_add_state.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(trail_add_state.get("bulletTrailAddApplied", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(trail_add_state.get("bulletContinues", false)),
			"keepVelocityApplied": false,
			"scaleKeepVelocityApplied": false,
			"returnedBullet": null,
			"bullet": null,
			"keepVelocitySource": "if(keepVelocity && owner instanceof Velc v){",
			"vec2LenSource": "return (float)Math.sqrt(x * x + y * y)",
			"vec2AddSource": "x += v.x; y += v.y",
			"lifetimeScaleSource": "if(newLen > 0f) bullet.lifetime *= Math.min(1f, len / newLen)",
			"returnSource": "return bullet",
		}
	var keep_velocity := bool(bullet_type_state.get("keepVelocity", defaults.keep_velocity_default()))
	var scale_keep_velocity := bool(bullet_type_state.get("scaleKeepVelocity", defaults.scale_keep_velocity_default()))
	var owner_is_velc := bool(owner_state.get("isVelc", false))
	bullet_state = bullet_state.duplicate(true)
	var raw_velocity_state = bullet_state.get("velocity", {})
	var velocity_state: Dictionary = raw_velocity_state if raw_velocity_state is Dictionary else {}
	var bullet_vel_before := velocity_vector_state(velocity_state)
	var raw_owner_vel = owner_state.get("vel", {"x": 0.0, "y": 0.0})
	var owner_vel: Dictionary = raw_owner_vel if raw_owner_vel is Dictionary else {"x": 0.0, "y": 0.0}
	var len_before := sqrt(float(bullet_vel_before.get("x", 0.0)) * float(bullet_vel_before.get("x", 0.0)) + float(bullet_vel_before.get("y", 0.0)) * float(bullet_vel_before.get("y", 0.0)))
	if not (keep_velocity and owner_is_velc):
		return {
			"bulletContinues": true,
			"keepVelocityApplied": false,
			"scaleKeepVelocityApplied": false,
			"keepVelocity": keep_velocity,
			"ownerIsVelc": owner_is_velc,
			"lenBefore": len_before,
			"lenAfter": len_before,
			"bulletVelBefore": bullet_vel_before,
			"bulletVelAfter": bullet_vel_before.duplicate(),
			"returnedBullet": bullet_state,
			"bullet": bullet_state,
			"keepVelocitySource": "if(keepVelocity && owner instanceof Velc v){",
			"vec2LenSource": "return (float)Math.sqrt(x * x + y * y)",
			"vec2AddSource": "x += v.x; y += v.y",
			"lifetimeScaleSource": "if(newLen > 0f) bullet.lifetime *= Math.min(1f, len / newLen)",
			"returnSource": "return bullet",
		}
	var bullet_vel_after := {
		"x": float(bullet_vel_before.get("x", 0.0)) + float(owner_vel.get("x", 0.0)),
		"y": float(bullet_vel_before.get("y", 0.0)) + float(owner_vel.get("y", 0.0)),
	}
	var new_len := sqrt(float(bullet_vel_after["x"]) * float(bullet_vel_after["x"]) + float(bullet_vel_after["y"]) * float(bullet_vel_after["y"]))
	var scale_applied := false
	if scale_keep_velocity and new_len > 0.0:
		scale_applied = true
		bullet_state["lifetime"] = float(bullet_state.get("lifetime", 0.0)) * minf(1.0, len_before / new_len)
	bullet_state["velocity"] = bullet_vel_after
	return {
		"bulletContinues": true,
		"keepVelocityApplied": true,
		"scaleKeepVelocityApplied": scale_applied,
		"keepVelocity": keep_velocity,
		"scaleKeepVelocity": scale_keep_velocity,
		"ownerIsVelc": owner_is_velc,
		"ownerVel": owner_vel,
		"lenBefore": len_before,
		"lenAfter": new_len,
		"bulletVelBefore": bullet_vel_before,
		"bulletVelAfter": bullet_vel_after,
		"returnedBullet": bullet_state,
		"bullet": bullet_state,
		"keepVelocitySource": "if(keepVelocity && owner instanceof Velc v){",
		"vec2LenSource": "return (float)Math.sqrt(x * x + y * y)",
		"vec2AddSource": "x += v.x; y += v.y",
		"lifetimeScaleSource": "if(newLen > 0f) bullet.lifetime *= Math.min(1f, len / newLen)",
		"returnSource": "return bullet",
	}

static func init_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, defaults: SourceBulletDefaults) -> Dictionary:
	var init_bullet_state := bullet_state.duplicate(true)
	var init_owner_state := owner_health_state.duplicate(true)
	var kill_shooter := bool(bullet_type_state.get("killShooter", defaults.kill_shooter_default()))
	var owner_is_healthc := bool(init_owner_state.get("isHealthc", false))
	var owner_dead := bool(init_owner_state.get("dead", false))
	var kill_shooter_applied := false
	if kill_shooter and owner_is_healthc and not owner_dead:
		kill_shooter_applied = true
		init_owner_state["health"] = minf(float(init_owner_state.get("health", 0.0)), 0.0)
		init_owner_state["dead"] = true
		init_owner_state["killedCalled"] = true
		init_owner_state["removed"] = true
	var instant_disappear := bool(bullet_type_state.get("instantDisappear", defaults.instant_disappear_default()))
	if instant_disappear:
		init_bullet_state["time"] = float(bullet_type_state.get("lifetime", defaults.lifetime_default())) + 1.0
	return {
		"bullet": init_bullet_state,
		"owner": init_owner_state,
		"killShooter": kill_shooter,
		"ownerIsHealthc": owner_is_healthc,
		"ownerDeadBefore": owner_dead,
		"killShooterApplied": kill_shooter_applied,
		"instantDisappear": instant_disappear,
		"instantDisappearApplied": instant_disappear,
		"spawnBulletsDeferred": true,
		"killShooterSource": "if(killShooter && b.owner() instanceof Healthc h && !h.dead()){",
		"healthKillSource": "health = Math.min(health, 0); dead = true; killed(); remove()",
		"instantDisappearSource": "b.time = lifetime + 1f",
		"spawnBulletsReservedSource": "if(spawnBullets.size > 0){",
	}

static func init_spawn_bullets_state(initial_state: Dictionary, bullet_type_state: Dictionary, spawn_bullet_random_offsets: Array) -> Dictionary:
	var raw_bullet_state = initial_state.get("bullet", {})
	var init_bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	var spawn_bullets: Array = bullet_type_state.get("spawnBullets", [])
	var spawn_calls: Array = []
	for index in spawn_bullets.size():
		var spawn_bullet = spawn_bullets[index]
		var random_offset := float(spawn_bullet_random_offsets[index]) if index < spawn_bullet_random_offsets.size() else 0.0
		var create_call := {
			"bulletType": spawn_bullet,
			"owner": init_bullet_state,
			"x": float(init_bullet_state.get("x", 0.0)),
			"y": float(init_bullet_state.get("y", 0.0)),
			"angle": float(init_bullet_state.get("rotation", 0.0)) + random_offset,
			"randomOffset": random_offset,
			"sourceCall": "bullet.create(b, b.x, b.y, b.rotation() + Mathf.range(spawnBulletRandomSpread))",
		}
		spawn_calls.append(create_call)
	return {
		"bullet": init_bullet_state,
		"spawnBulletCount": spawn_bullets.size(),
		"spawnBulletCalls": spawn_calls,
		"spawnBulletsApplied": spawn_bullets.size() > 0,
		"spawnBulletRandomSpread": float(bullet_type_state.get("spawnBulletRandomSpread", 0.0)),
		"spawnBulletRandomOffsets": spawn_bullet_random_offsets.duplicate(),
		"spawnBulletsSource": "if(spawnBullets.size > 0){",
		"spawnBulletCreateSource": "bullet.create(b, b.x, b.y, b.rotation() + Mathf.range(spawnBulletRandomSpread))",
		"mathfRangeSource": "return random(-range, range)",
		"updateBoundarySource": "public void update(Bullet b){",
	}

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
	var gate_passed := interval_bullet != null and float(update_bullet_state.get("time", 0.0)) >= float(bullet_type_state.get("intervalDelay", -1.0)) and timer_get_result
	var interval_calls: Array = []
	var interval_bullets := int(bullet_type_state.get("intervalBullets", 1))
	var interval_spread := float(bullet_type_state.get("intervalSpread", 0.0))
	var interval_angle := float(bullet_type_state.get("intervalAngle", 0.0))
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
		"timerTime": float(bullet_type_state.get("bulletInterval", 20.0)),
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
	var trail_length := int(bullet_type_state.get("trailLength", -1))
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
	var sin_scale := 1.0 + (absin_value if float(bullet_type_state.get("trailSinMag", 0.0)) > 0.0 else 0.0)
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

static func arc_angles_forward_distance(angle1: float, angle2: float) -> float:
	return abs(angle1 - angle2)

static func arc_angles_backward_distance(angle1: float, angle2: float) -> float:
	return 360.0 - abs(angle1 - angle2)

static func arc_mathf_mod_float(value: float, mod: float) -> float:
	return fmod(fmod(value, mod) + mod, mod)

static func arc_angles_angle_dist(angle_a: float, angle_b: float) -> float:
	angle_a = arc_mathf_mod_float(angle_a, 360.0)
	angle_b = arc_mathf_mod_float(angle_b, 360.0)
	var forward := angle_a - angle_b + 360.0 if (angle_a - angle_b) < 0.0 else angle_a - angle_b
	var backward := angle_b - angle_a + 360.0 if (angle_b - angle_a) < 0.0 else angle_b - angle_a
	return min(forward, backward)

static func arc_angles_move_toward(angle: float, to: float, speed: float) -> float:
	if abs(arc_angles_angle_dist(angle, to)) < speed:
		return to
	angle = arc_mathf_mod_float(angle, 360.0)
	to = arc_mathf_mod_float(to, 360.0)
	if (angle > to) == (arc_angles_backward_distance(angle, to) > arc_angles_forward_distance(angle, to)):
		angle -= speed
	else:
		angle += speed
	return angle

static func arc_angles_angle(from_x: float, from_y: float, to_x: float, to_y: float) -> float:
	return rad_to_deg(atan2(to_y - from_y, to_x - from_x))

static func arc_angles_trns_vec(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	var rad := deg_to_rad(angle_degrees)
	return {"x": x_value * cos(rad) - y_value * sin(rad), "y": x_value * sin(rad) + y_value * cos(rad)}

static func update_homing_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var homing_power := float(bullet_type_state.get("homingPower", 0.0))
	var homing_delay := float(bullet_type_state.get("homingDelay", -1.0))
	var gate_passed := homing_power > 0.0001 and float(update_bullet_state.get("time", 0.0)) >= homing_delay
	var aim_x := float(update_bullet_state.get("aimX", -1.0))
	var aim_y := float(update_bullet_state.get("aimY", -1.0))
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
		"homingRange": float(bullet_type_state.get("homingRange", 50.0)),
		"targetSelectionDeferred": true,
		"followAimDeferred": true,
		"gateSource": "if(homingPower > 0.0001f && b.time >= homingDelay){",
		"realAimXSource": "float realAimX = b.aimX < 0 ? b.x : b.aimX",
		"realAimYSource": "float realAimY = b.aimY < 0 ? b.y : b.aimY",
		"targetReservedSource": "Teamc target",
		"followAimReservedSource": "if(followAimSpeed > 0f && b.shooter instanceof Unit u)",
	}

static func update_homing_target_velocity_state(homing_initial_state: Dictionary, target_state: Variant, source_delta: float) -> Dictionary:
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
	var target_angle := arc_angles_angle(float(update_bullet_state.get("x", 0.0)), float(update_bullet_state.get("y", 0.0)), float(target_state.get("x", 0.0)), float(target_state.get("y", 0.0)))
	var max_turn := homing_power * source_delta * 50.0
	var next_angle := arc_angles_move_toward(current_rotation, target_angle, max_turn)
	var speed := float(velocity_state.get("speed", sqrt(velocity_x * velocity_x + velocity_y * velocity_y)))
	var next_velocity := arc_angles_trns_vec(next_angle, speed, 0.0)
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

static func update_homing_follow_aim_state(homing_target_velocity_state: Dictionary, bullet_type_state: Dictionary, shooter_state: Variant, source_delta: float) -> Dictionary:
	var update_bullet_state: Dictionary = homing_target_velocity_state.get("bullet", {}).duplicate(true)
	var follow_aim_speed := float(bullet_type_state.get("followAimSpeed", 0.0))
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
	var target_angle := arc_angles_angle(float(update_bullet_state.get("x", 0.0)), float(update_bullet_state.get("y", 0.0)), float(shooter_state.get("aimX", 0.0)), float(shooter_state.get("aimY", 0.0)))
	var current_velocity_angle := float(velocity_state.get("angle", update_bullet_state.get("rotation", 0.0)))
	var max_turn := follow_aim_speed * source_delta
	var next_angle := arc_angles_move_toward(current_velocity_angle, target_angle, max_turn)
	var speed := float(velocity_state.get("speed", sqrt(velocity_x * velocity_x + velocity_y * velocity_y)))
	var next_velocity := arc_angles_trns_vec(next_angle, speed, 0.0)
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

static func update_weaving_state(bullet_state: Dictionary, bullet_type_state: Dictionary, random_seed_result: int, source_delta: float) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var weave_mag := float(bullet_type_state.get("weaveMag", 0.0))
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
	var weave_scale := float(bullet_type_state.get("weaveScale", 1.0))
	var random_sign := -1.0 if bool(bullet_type_state.get("weaveRandom", true)) and random_seed_result == 1 else 1.0
	var rotation_radians := sin((float(update_bullet_state.get("time", 0.0)) + PI * weave_scale / 2.0) / weave_scale) * weave_mag * random_sign * source_delta * deg_to_rad(1.0)
	var next_x := velocity_x * cos(rotation_radians) - velocity_y * sin(rotation_radians)
	var next_y := velocity_x * sin(rotation_radians) + velocity_y * cos(rotation_radians)
	update_bullet_state["velocity"] = {"x": next_x, "y": next_y, "angle": arc_angles_angle(0.0, 0.0, next_x, next_y), "speed": sqrt(next_x * next_x + next_y * next_y)}
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

static func update_weaving_rotate_speed_state(weaving_state: Dictionary, bullet_type_state: Dictionary, source_delta: float) -> Dictionary:
	var update_bullet_state: Dictionary = weaving_state.get("bullet", {}).duplicate(true)
	var rotate_speed := float(bullet_type_state.get("rotateSpeed", 0.0))
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
	var next_x := velocity_x * cos(rotation_radians) - velocity_y * sin(rotation_radians)
	var next_y := velocity_x * sin(rotation_radians) + velocity_y * cos(rotation_radians)
	update_bullet_state["velocity"] = {"x": next_x, "y": next_y, "angle": arc_angles_angle(0.0, 0.0, next_x, next_y), "speed": sqrt(next_x * next_x + next_y * next_y)}
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

static func vec2_limit(vector_state: Dictionary, limit: float) -> Dictionary:
	var vector_x := float(vector_state.get("x", 0.0))
	var vector_y := float(vector_state.get("y", 0.0))
	var len2 := vector_x * vector_x + vector_y * vector_y
	var limit2 := limit * limit
	if len2 > limit2:
		var limit_scale := sqrt(limit2 / len2)
		return {"x": vector_x * limit_scale, "y": vector_y * limit_scale}
	return {"x": vector_x, "y": vector_y}

static func update_weaving_circle_shooter_state(rotate_speed_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, source_delta: float) -> Dictionary:
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
	var circle_radius := float(bullet_type_state.get("circleShooterRadius", 13.0))
	var circle_radius_smooth := float(bullet_type_state.get("circleShooterRadiusSmooth", 10.0))
	var circle_rotate_speed := float(bullet_type_state.get("circleShooterRotateSpeed", 0.3))
	var speed := float(bullet_type_state.get("speed", 1.0))
	var circle_rotation_degrees: float = 90.0 * (0.0 + (1.0 - 0.0) * (1.0 - clamp((tmp_len - circle_radius) / circle_radius_smooth, 0.0, 1.0)))
	var rotation_radians := circle_rotation_degrees * deg_to_rad(1.0)
	var tmp_rotated := {"x": tmp_x * cos(rotation_radians) - tmp_y * sin(rotation_radians), "y": tmp_x * sin(rotation_radians) + tmp_y * cos(rotation_radians)}
	var tmp_limit := speed * circle_rotate_speed * source_delta
	var limited_tmp := vec2_limit(tmp_rotated, tmp_limit)
	var limited_velocity := vec2_limit({"x": velocity_x + float(limited_tmp.get("x", 0.0)), "y": velocity_y + float(limited_tmp.get("y", 0.0))}, speed)
	update_bullet_state["velocity"] = {"x": float(limited_velocity.get("x", 0.0)), "y": float(limited_velocity.get("y", 0.0)), "angle": arc_angles_angle(0.0, 0.0, float(limited_velocity.get("x", 0.0)), float(limited_velocity.get("y", 0.0))), "speed": sqrt(float(limited_velocity.get("x", 0.0)) * float(limited_velocity.get("x", 0.0)) + float(limited_velocity.get("y", 0.0)) * float(limited_velocity.get("y", 0.0)))}
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

static func rotation_degrees(bullet_state: Dictionary) -> float:
	var velocity_state: Dictionary = bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var velocity_len2 := velocity_x * velocity_x + velocity_y * velocity_y
	if velocity_len2 < SOURCE_BULLET_ROTATION_ZERO_MARGIN:
		return float(bullet_state.get("rotation", 0.0))
	return arc_angles_angle(0.0, 0.0, velocity_x, velocity_y)

static func update_trail_effects_chance_state(bullet_state: Dictionary, bullet_type_state: Dictionary, chance_delta_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var update_bullet_state := bullet_state.duplicate(true)
	var velocity_state: Dictionary = update_bullet_state.get("velocity", {})
	var velocity_x := float(velocity_state.get("x", 0.0))
	var velocity_y := float(velocity_state.get("y", 0.0))
	var velocity_len2 := velocity_x * velocity_x + velocity_y * velocity_y
	var trail_min_velocity := float(bullet_type_state.get("trailMinVelocity", 0.0))
	var can_spawn := trail_min_velocity <= 0.0 or velocity_len2 >= trail_min_velocity * trail_min_velocity
	var trail_chance := float(bullet_type_state.get("trailChance", -0.0001))
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
	var trail_spread := float(bullet_type_state.get("trailSpread", 0.0))
	var tmp_offset: Dictionary = {"x": 0.0, "y": 0.0}
	if trail_spread > 0.0:
		tmp_offset = random_offset_state.duplicate(true)
	var effect_rotation: float = rotation_degrees(update_bullet_state) if bool(bullet_type_state.get("trailRotation", false)) else float(bullet_type_state.get("trailParam", 2.0))
	var effect_call := {"x": float(update_bullet_state.get("x", 0.0)) + float(tmp_offset.get("x", 0.0)), "y": float(update_bullet_state.get("y", 0.0)) + float(tmp_offset.get("y", 0.0)), "rotation": effect_rotation, "color": bullet_type_state.get("trailColor", "Pal.missileYellowBack"), "effect": bullet_type_state.get("trailEffect", "Fx.missileTrail")}
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

static func update_trail_effects_interval_state(chance_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = chance_state.get("bullet", {}).duplicate(true)
	var effect_calls: Array = chance_state.get("effectCalls", []).duplicate(true)
	var can_spawn := bool(chance_state.get("canSpawn", false))
	var trail_interval := float(bullet_type_state.get("trailInterval", 0.0))
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
	var trail_spread := float(bullet_type_state.get("trailSpread", 0.0))
	var tmp_offset: Dictionary = {"x": 0.0, "y": 0.0}
	if trail_spread > 0.0:
		tmp_offset = random_offset_state.duplicate(true)
	var effect_rotation: float = rotation_degrees(update_bullet_state) if bool(bullet_type_state.get("trailRotation", false)) else float(bullet_type_state.get("trailParam", 2.0))
	var effect_call := {"x": float(update_bullet_state.get("x", 0.0)) + float(tmp_offset.get("x", 0.0)), "y": float(update_bullet_state.get("y", 0.0)) + float(tmp_offset.get("y", 0.0)), "rotation": effect_rotation, "color": bullet_type_state.get("trailColor", "Pal.missileYellowBack"), "effect": bullet_type_state.get("trailEffect", "Fx.missileTrail")}
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

static func init_type_defaults_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state := bullet_type_state.duplicate(true)
	var pierce_cap := int(update_type_state.get("pierceCap", -1))
	var pierce_applied := pierce_cap >= 1
	if pierce_applied:
		update_type_state["pierce"] = true
	var set_defaults := bool(update_type_state.get("setDefaults", true))
	var lightning := int(update_type_state.get("lightning", 0))
	var status_before := str(update_type_state.get("status", "none"))
	var status_shocked_applied := set_defaults and lightning > 0 and status_before == "none"
	if status_shocked_applied:
		update_type_state["status"] = "shocked"
	var despawn_hit_applied := set_defaults and (update_type_state.get("fragBullet", null) != null or float(update_type_state.get("splashDamageRadius", 0.0)) > 0.0 or lightning > 0)
	if despawn_hit_applied:
		update_type_state["despawnHit"] = true
	return {
		"bulletType": update_type_state,
		"pierceApplied": pierce_applied,
		"setDefaults": set_defaults,
		"lightning": lightning,
		"statusBefore": status_before,
		"statusShockedApplied": status_shocked_applied,
		"despawnHitApplied": despawn_hit_applied,
		"pierceGateSource": "if(pierceCap >= 1){",
		"pierceAssignSource": "pierce = true",
		"setDefaultsGateSource": "if(setDefaults){",
		"lightningGateSource": "if(lightning > 0){",
		"statusGateSource": "if(status == StatusEffects.none){",
		"statusAssignSource": "status = StatusEffects.shocked",
		"despawnHitGateSource": "if(fragBullet != null || splashDamageRadius > 0 || lightning > 0){",
		"despawnHitAssignSource": "despawnHit = true",
	}

static func init_frag_velocity_state(type_defaults_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = type_defaults_state.get("bulletType", {}).duplicate(true)
	var frag_bullet_value = update_type_state.get("fragBullet", null)
	var gate_passed := frag_bullet_value != null
	if not gate_passed:
		return {
			"bulletType": update_type_state,
			"fragBulletVelocityApplied": false,
			"fragGatePassed": false,
			"fragGateSource": "if(fragBullet != null){",
			"fragKeepVelocitySource": "fragBullet.keepVelocity = false",
			"fragScaleKeepVelocitySource": "fragBullet.scaleKeepVelocity = false",
		}
	var frag_bullet_state := (frag_bullet_value as Dictionary).duplicate(true)
	frag_bullet_state["keepVelocity"] = false
	frag_bullet_state["scaleKeepVelocity"] = false
	update_type_state["fragBullet"] = frag_bullet_state
	return {
		"bulletType": update_type_state,
		"fragBulletVelocityApplied": true,
		"fragGatePassed": true,
		"fragBullet": frag_bullet_state,
		"fragGateSource": "if(fragBullet != null){",
		"fragKeepVelocitySource": "fragBullet.keepVelocity = false",
		"fragScaleKeepVelocitySource": "fragBullet.scaleKeepVelocity = false",
	}

static func init_lightning_type_state(frag_velocity_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = frag_velocity_state.get("bulletType", {}).duplicate(true)
	var gate_passed := update_type_state.get("lightningType", null) == null
	if not gate_passed:
		return {
			"bulletType": update_type_state,
			"lightningTypeApplied": false,
			"lightningTypeGatePassed": false,
			"lightningType": update_type_state.get("lightningType", null),
			"lightningTypeGateSource": "if(lightningType == null){",
			"lightningTypeChoiceSource": "!collidesAir ? Bullets.damageLightningGround : !collidesGround ? Bullets.damageLightningAir : Bullets.damageLightning",
		}
	var lightning_type := ""
	lightning_type = "Bullets.damageLightning"
	if not bool(update_type_state.get("collidesAir", true)):
		lightning_type = "Bullets.damageLightningGround"
	elif not bool(update_type_state.get("collidesGround", true)):
		lightning_type = "Bullets.damageLightningAir"
	update_type_state["lightningType"] = lightning_type
	return {
		"bulletType": update_type_state,
		"lightningTypeApplied": true,
		"lightningTypeGatePassed": true,
		"lightningType": lightning_type,
		"collidesAir": bool(update_type_state.get("collidesAir", true)),
		"collidesGround": bool(update_type_state.get("collidesGround", true)),
		"lightningTypeGateSource": "if(lightningType == null){",
		"lightningTypeChoiceSource": "!collidesAir ? Bullets.damageLightningGround : !collidesGround ? Bullets.damageLightningAir : Bullets.damageLightning",
	}

static func init_light_radius_state(lightning_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = lightning_type_state.get("bulletType", {}).duplicate(true)
	var light_radius := float(update_type_state.get("lightRadius", -1.0))
	var gate_passed := light_radius <= -1.0
	if not gate_passed:
		return {
			"bulletType": update_type_state,
			"lightRadiusApplied": false,
			"lightRadiusGatePassed": false,
			"lightRadius": light_radius,
			"lightRadiusGateSource": "if(lightRadius <= -1){",
			"lightRadiusAssignSource": "lightRadius = Math.max(18, hitSize * 5f)",
		}
	var resolved_light_radius: float = max(18.0, float(update_type_state.get("hitSize", 4.0)) * 5.0)
	update_type_state["lightRadius"] = resolved_light_radius
	return {
		"bulletType": update_type_state,
		"lightRadiusApplied": true,
		"lightRadiusGatePassed": true,
		"lightRadius": resolved_light_radius,
		"hitSize": float(update_type_state.get("hitSize", 4.0)),
		"lightRadiusGateSource": "if(lightRadius <= -1){",
		"lightRadiusAssignSource": "lightRadius = Math.max(18, hitSize * 5f)",
	}

static func init_draw_size_state(light_radius_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = light_radius_state.get("bulletType", {}).duplicate(true)
	var draw_size := float(update_type_state.get("drawSize", 40.0))
	var computed_draw_size := float(update_type_state.get("trailLength", -1)) * float(update_type_state.get("speed", 1.0)) * 2.0
	var resolved_draw_size: float = max(draw_size, computed_draw_size)
	update_type_state["drawSize"] = resolved_draw_size
	return {
		"bulletType": update_type_state,
		"drawSize": resolved_draw_size,
		"drawSizeBefore": draw_size,
		"computedDrawSize": computed_draw_size,
		"trailLength": int(update_type_state.get("trailLength", -1)),
		"speed": float(update_type_state.get("speed", 1.0)),
		"drawSizeAssignSource": "drawSize = Math.max(drawSize, trailLength * speed * 2f)",
	}

static func init_range_assignment_state(draw_size_state: Dictionary, calculate_range_result: float) -> Dictionary:
	var update_type_state: Dictionary = draw_size_state.get("bulletType", {}).duplicate(true)
	var range_before := float(update_type_state.get("range", 0.0))
	update_type_state["range"] = calculate_range_result
	return {
		"bulletType": update_type_state,
		"range": calculate_range_result,
		"rangeBefore": range_before,
		"rangeAssignSource": "range = calculateRange()",
		"calculateRangeDeferred": true,
	}

static func calculate_range_override_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var range_override := float(update_type_state.get("rangeOverride", -1.0))
	var gate_passed := range_override > 0.0
	var resolved_range: Variant = null
	if gate_passed:
		resolved_range = range_override
	return {
		"bulletType": update_type_state,
		"rangeOverride": range_override,
		"rangeOverrideGatePassed": gate_passed,
		"returnEarly": gate_passed,
		"range": resolved_range,
		"rangeOverrideReturnSource": "if(rangeOverride > 0) return rangeOverride",
	}

static func calculate_range_spawn_unit_state(override_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = override_state.get("bulletType", {}).duplicate(true)
	var prior_return := bool(override_state.get("returnEarly", false))
	var spawn_unit_value = update_type_state.get("spawnUnit", null)
	var gate_passed := (not prior_return) and spawn_unit_value != null
	var resolved_range: Variant = override_state.get("range", null)
	var spawn_unit_state: Dictionary = {}
	var returned_spawn_unit: Variant = null
	if gate_passed:
		spawn_unit_state = (spawn_unit_value as Dictionary).duplicate(true)
		resolved_range = float(spawn_unit_state.get("lifetime", 0.0)) * float(spawn_unit_state.get("speed", 0.0))
		returned_spawn_unit = spawn_unit_state
	return {
		"bulletType": update_type_state,
		"spawnUnitRangeGatePassed": gate_passed,
		"returnEarly": prior_return or gate_passed,
		"range": resolved_range,
		"spawnUnit": returned_spawn_unit,
		"spawnUnitReturnSource": "if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed",
	}

static func calculate_range_despawn_unit_state(spawn_unit_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = spawn_unit_state.get("bulletType", {}).duplicate(true)
	var prior_return := bool(spawn_unit_state.get("returnEarly", false))
	var despawn_unit_value = update_type_state.get("despawnUnit", null)
	var gate_passed := (not prior_return) and despawn_unit_value != null
	var resolved_range: Variant = spawn_unit_state.get("range", null)
	var despawn_unit_state: Dictionary = {}
	var returned_despawn_unit: Variant = null
	if gate_passed:
		despawn_unit_state = (despawn_unit_value as Dictionary).duplicate(true)
		resolved_range = float(despawn_unit_state.get("lifetime", 0.0)) * float(despawn_unit_state.get("speed", 0.0))
		returned_despawn_unit = despawn_unit_state
	return {
		"bulletType": update_type_state,
		"despawnUnitRangeGatePassed": gate_passed,
		"returnEarly": prior_return or gate_passed,
		"range": resolved_range,
		"despawnUnit": returned_despawn_unit,
		"despawnUnitReturnSource": "if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed",
	}

static func calculate_range_fallback_state(despawn_unit_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = despawn_unit_state.get("bulletType", {}).duplicate(true)
	var prior_return := bool(despawn_unit_state.get("returnEarly", false))
	var resolved_range: Variant = despawn_unit_state.get("range", null)
	var speed := float(update_type_state.get("speed", 1.0))
	var lifetime := float(update_type_state.get("lifetime", 40.0))
	var drag := float(update_type_state.get("drag", 0.0))
	var max_range := float(update_type_state.get("maxRange", -1.0))
	var zero_drag := absf(drag) <= 0.000001
	var fallback_range := 0.0
	var fallback_gate_passed := not prior_return
	if fallback_gate_passed:
		if zero_drag:
			fallback_range = speed * lifetime
		else:
			fallback_range = speed * (1.0 - pow(1.0 - drag, lifetime)) / drag
		resolved_range = max(fallback_range, max_range)
	return {
		"bulletType": update_type_state,
		"fallbackRangeGatePassed": fallback_gate_passed,
		"returnEarly": prior_return or fallback_gate_passed,
		"range": resolved_range,
		"fallbackRange": fallback_range,
		"zeroDrag": zero_drag,
		"drag": drag,
		"maxRange": max_range,
		"fallbackReturnSource": "return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange)",
	}

static func continuous_damage_default_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	return {
		"bulletType": update_type_state,
		"continuousDamage": -1.0,
		"continuousDamageReturnSource": "return -1f",
	}

static func heals_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var heal_percent := float(update_type_state.get("healPercent", 0.0))
	var heal_amount := float(update_type_state.get("healAmount", 0.0))
	var heals := heal_percent > 0.0 or heal_amount > 0.0
	return {
		"bulletType": update_type_state,
		"healPercent": heal_percent,
		"healAmount": heal_amount,
		"heals": heals,
		"healsReturnSource": "return healPercent > 0 || healAmount > 0",
	}

static func test_collision_state(bullet_type_state: Dictionary, bullet_state: Dictionary, tile_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_tile_state: Dictionary = tile_state.duplicate(true)
	var heals_result := heals_state(update_type_state)
	var heals := bool(heals_result.get("heals", false))
	var tile_team = update_tile_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var tile_healthf := float(update_tile_state.get("healthf", 0.0))
	var collides_tile: bool = not heals or tile_team != bullet_team or tile_healthf < 1.0
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"tile": update_tile_state,
		"heals": heals,
		"tileTeam": tile_team,
		"bulletTeam": bullet_team,
		"tileHealthf": tile_healthf,
		"collides": collides_tile,
		"testCollisionReturnSource": "return !heals() || tile.team != bullet.team || tile.healthf() < 1f",
	}

static func hit_tile_fire_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var make_fire := bool(update_type_state.get("makeFire", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var fire_gate_passed: bool = make_fire and build_team != bullet_team
	var build_tile = update_build_state.get("tile", null)
	var fires_create_call: Variant = null
	if fire_gate_passed:
		fires_create_call = {"call": "Fires.create(build.tile)", "tile": build_tile}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"makeFire": make_fire,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"fireGatePassed": fire_gate_passed,
		"fireCreated": fire_gate_passed,
		"firesCreateCall": fires_create_call,
		"hitTileFireGateSource": "if(makeFire && build.team != b.team)",
		"firesCreateSource": "Fires.create(build.tile)",
		"healBranchBoundarySource": "if(heals() && build.team == b.team && !(build.block instanceof ConstructBlock))",
	}

static func hit_tile_heal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var heals_result := heals_state(update_type_state)
	var heals := bool(heals_result.get("heals", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var block_is_construct := bool(update_build_state.get("blockIsConstructBlock", false))
	var heal_gate_passed: bool = heals and build_team == bullet_team and not block_is_construct
	var build_max_health := float(update_build_state.get("maxHealth", 0.0))
	var heal_percent := float(update_type_state.get("healPercent", 0.0))
	var heal_amount := float(update_type_state.get("healAmount", 0.0))
	var heal_applied_amount := heal_percent / 100.0 * build_max_health + heal_amount
	var heal_color := str(update_type_state.get("healColor", "Pal.heal"))
	var heal_sound_volume := float(update_type_state.get("healSoundVolume", 1.0))
	var build_x := float(update_build_state.get("x", 0.0))
	var build_y := float(update_build_state.get("y", 0.0))
	var build_block = update_build_state.get("block", null)
	var heal_effect_call: Variant = null
	var build_heal_call: Variant = null
	var heal_sound_call: Variant = null
	if heal_gate_passed:
		heal_effect_call = {"call": "healEffect.at(build.x, build.y, 0f, healColor, build.block)", "x": build_x, "y": build_y, "rotation": 0.0, "color": heal_color, "block": build_block}
		build_heal_call = {"call": "build.heal(healPercent / 100f * build.maxHealth + healAmount)", "amount": heal_applied_amount}
		heal_sound_call = {"call": "healSound.at(build, 1f + Mathf.range(0.1f), healSoundVolume)", "pitchBase": 1.0, "pitchRange": 0.1, "volume": heal_sound_volume}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"heals": heals,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"blockIsConstructBlock": block_is_construct,
		"healGatePassed": heal_gate_passed,
		"healAppliedAmount": heal_applied_amount,
		"healed": heal_gate_passed,
		"hitCalled": heal_gate_passed,
		"healEffectCall": heal_effect_call,
		"buildHealCall": build_heal_call,
		"healSoundCall": heal_sound_call,
		"enemyDirectBranchDeferred": true,
		"pierceDeferred": true,
		"hitTileHealGateSource": "if(heals() && build.team == b.team && !(build.block instanceof ConstructBlock))",
		"healEffectSource": "healEffect.at(build.x, build.y, 0f, healColor, build.block)",
		"healAmountSource": "healPercent / 100f * build.maxHealth + healAmount",
		"healSoundSource": "healSound.at(build, 1f + Mathf.range(0.1f), healSoundVolume)",
		"hitCallSource": "hit(b)",
		"deferredBranchSource": "}else if(build.team != b.team && direct){",
		"pierceSource": "handlePierce(b, initialHealth, x, y)",
	}

static func hit_tile_enemy_direct_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var update_hit_tile_state: Dictionary = hit_tile_state.duplicate(true)
	var direct := bool(update_hit_tile_state.get("direct", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var enemy_direct_gate_passed: bool = build_team != bullet_team and direct
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"hitTile": update_hit_tile_state,
		"direct": direct,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"enemyDirectGatePassed": enemy_direct_gate_passed,
		"hitCalled": enemy_direct_gate_passed,
		"lifestealDeferred": true,
		"pierceDeferred": true,
		"hitTileEnemyDirectGateSource": "}else if(build.team != b.team && direct)",
		"enemyHitCallSource": "hit(b)",
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
		"pierceSource": "handlePierce(b, initialHealth, x, y)",
	}

static func hit_tile_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var update_hit_tile_state: Dictionary = hit_tile_state.duplicate(true)
	var update_owner_health_state: Dictionary = owner_health_state.duplicate(true)
	var direct := bool(update_hit_tile_state.get("direct", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var enemy_direct_gate_passed: bool = build_team != bullet_team and direct
	var lifesteal := float(update_type_state.get("lifesteal", 0.0))
	var lifesteal_damage := float(update_type_state.get("damage", 0.0))
	var build_health := float(update_build_state.get("health", 0.0))
	var owner_is_healthc := bool(update_owner_health_state.get("isHealthc", false))
	var lifesteal_gate_passed: bool = lifesteal > 0.0 and owner_is_healthc
	var lifesteal_result := maxf(minf(build_health, lifesteal_damage), 0.0)
	var owner_heal_called := enemy_direct_gate_passed and lifesteal_gate_passed
	var owner_heal_amount := lifesteal_result * lifesteal if owner_heal_called else 0.0
	var owner_heal_call = null
	if owner_heal_called:
		owner_heal_call = {
			"call": "o.heal(result * lifesteal)",
			"amount": owner_heal_amount,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"hitTile": update_hit_tile_state,
		"ownerHealth": update_owner_health_state,
		"direct": direct,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"enemyDirectGatePassed": enemy_direct_gate_passed,
		"lifesteal": lifesteal,
		"damage": lifesteal_damage,
		"buildHealth": build_health,
		"ownerIsHealthc": owner_is_healthc,
		"lifestealGatePassed": lifesteal_gate_passed,
		"lifestealResult": lifesteal_result if owner_heal_called else 0.0,
		"ownerHealCalled": owner_heal_called,
		"ownerHealAmount": owner_heal_amount,
		"ownerHealCall": owner_heal_call,
		"pierceDeferred": true,
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
		"lifestealResultSource": "float result = Math.max(Math.min(build.health, damage), 0)",
		"ownerHealSource": "o.heal(result * lifesteal)",
		"pierceSource": "handlePierce(b, initialHealth, x, y)",
	}

static func handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, pierce_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_pierce_state: Dictionary = pierce_state.duplicate(true)
	var pierce_damage_factor := float(update_type_state.get("pierceDamageFactor", 0.0))
	var remove_after_pierce := bool(update_type_state.get("removeAfterPierce", false))
	var initial_health := float(update_pierce_state.get("initialHealth", 0.0))
	var x := float(update_pierce_state.get("x", 0.0))
	var y := float(update_pierce_state.get("y", 0.0))
	var bullet_damage := float(update_bullet_state.get("damage", 0.0))
	var zero_pierce_damage_factor := absf(pierce_damage_factor) <= 0.000001
	var sub := 0.0 if zero_pierce_damage_factor else maxf(initial_health * pierce_damage_factor, 0.0)
	var damage_subtract := bullet_damage if is_nan(sub) else minf(bullet_damage, sub)
	var next_damage := bullet_damage - damage_subtract
	var remove_gate_passed := remove_after_pierce and next_damage <= 0.0
	update_bullet_state["damage"] = next_damage
	if remove_gate_passed:
		update_bullet_state["hit"] = true
		update_bullet_state["removed"] = true
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"pierce": update_pierce_state,
		"pierceDamageFactor": pierce_damage_factor,
		"removeAfterPierce": remove_after_pierce,
		"initialHealth": initial_health,
		"x": x,
		"y": y,
		"zeroPierceDamageFactor": zero_pierce_damage_factor,
		"sub": sub,
		"damageBefore": bullet_damage,
		"damageSubtract": damage_subtract,
		"damage": next_damage,
		"removeGatePassed": remove_gate_passed,
		"hit": bool(update_bullet_state.get("hit", false)),
		"removeCalled": bool(update_bullet_state.get("removed", false)),
		"subSource": "float sub = Mathf.zero(pierceDamageFactor) ? 0f : Math.max(initialHealth * pierceDamageFactor, 0)",
		"damageSubtractSource": "b.damage -= Float.isNaN(sub) ? b.damage : Math.min(b.damage, sub)",
		"removeAfterPierceSource": "if(removeAfterPierce && b.damage <= 0)",
		"hitAssignmentSource": "b.hit = true",
		"removeCallSource": "b.remove()",
	}

static func damage_multiplier_state(bullet_state: Dictionary, bullet_owner_state: Dictionary, rules_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_owner_state: Dictionary = bullet_owner_state.duplicate(true)
	var update_rules_state: Dictionary = rules_state.duplicate(true)
	var owner_is_unit := bool(update_owner_state.get("isUnit", false))
	var owner_unit_damage_multiplier := float(update_owner_state.get("unitDamageMultiplier", 1.0))
	var owner_is_building := bool(update_owner_state.get("isBuilding", false))
	var rules_unit_damage := float(update_rules_state.get("unitDamage", 1.0))
	var rules_block_damage := float(update_rules_state.get("blockDamage", 1.0))
	var damage_multiplier := 1.0
	var branch := "fallback"
	if owner_is_unit:
		damage_multiplier = owner_unit_damage_multiplier * rules_unit_damage
		branch = "unit"
	elif owner_is_building:
		damage_multiplier = rules_block_damage
		branch = "building"
	return {
		"bullet": update_bullet_state,
		"owner": update_owner_state,
		"rules": update_rules_state,
		"team": update_bullet_state.get("team", null),
		"ownerIsUnit": owner_is_unit,
		"ownerUnitDamageMultiplier": owner_unit_damage_multiplier,
		"ownerIsBuilding": owner_is_building,
		"rulesUnitDamage": rules_unit_damage,
		"rulesBlockDamage": rules_block_damage,
		"damageMultiplier": damage_multiplier,
		"branch": branch,
		"unitBranchSource": "if(b.owner instanceof Unit u) return u.damageMultiplier() * state.rules.unitDamage(b.team)",
		"buildingBranchSource": "if(b.owner instanceof Building) return state.rules.blockDamage(b.team)",
		"fallbackSource": "return 1f",
	}

static func hit_entity_damage_cap_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_hit_entity_state: Dictionary = hit_entity_state.duplicate(true)
	var entity_is_unit := bool(update_entity_state.get("isUnit", false))
	var entity_unit_dead := bool(update_entity_state.get("unitDead", false))
	var was_dead: bool = entity_is_unit and entity_unit_dead
	var entity_is_healthc := bool(update_entity_state.get("isHealthc", false))
	var healthc_gate_passed := entity_is_healthc
	var damage_amount := float(update_bullet_state.get("damage", 0.0))
	var entity_is_shieldc := bool(update_entity_state.get("isShieldc", false))
	var entity_shield := float(update_entity_state.get("shield", 0.0))
	var shield := 0.0
	var max_damage_fraction := float(update_type_state.get("maxDamageFraction", 0.0))
	var entity_max_health := float(update_entity_state.get("maxHealth", 0.0))
	var health := float(update_hit_entity_state.get("health", 0.0))
	var cap := 0.0
	var max_damage_fraction_gate_passed := healthc_gate_passed and max_damage_fraction > 0.0
	if healthc_gate_passed:
		shield = maxf(entity_shield, 0.0) if entity_is_shieldc else 0.0
		cap = entity_max_health * max_damage_fraction + shield
		if max_damage_fraction_gate_passed:
			damage_amount = minf(damage_amount, cap)
			health = minf(health, cap)
		else:
			health += shield
	update_hit_entity_state["health"] = health
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"hitEntity": update_hit_entity_state,
		"wasDead": was_dead,
		"healthcGatePassed": healthc_gate_passed,
		"damage": damage_amount,
		"shield": shield,
		"maxDamageFraction": max_damage_fraction,
		"maxDamageFractionGatePassed": max_damage_fraction_gate_passed,
		"cap": cap,
		"effectiveHealth": health,
		"lifestealDeferred": true,
		"armorDamageDeferred": true,
		"unitImpulseDeferred": true,
		"pierceDeferred": true,
		"wasDeadSource": "boolean wasDead = entity instanceof Unit u && u.dead",
		"healthcGateSource": "if(entity instanceof Healthc h)",
		"damageSource": "float damage = b.damage",
		"shieldSource": "float shield = entity instanceof Shieldc s ? Math.max(s.shield(), 0f) : 0f",
		"maxDamageFractionGateSource": "if(maxDamageFraction > 0)",
		"capSource": "float cap = h.maxHealth() * maxDamageFraction + shield",
		"damageCapSource": "damage = Math.min(damage, cap)",
		"healthCapCommentSource": "//cap health to effective health for handlePierce to handle it properly",
		"healthCapSource": "health = Math.min(health, cap)",
		"healthShieldSource": "health += shield",
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
	}

static func hit_entity_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_hit_entity_state: Dictionary = hit_entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_owner_health_state: Dictionary = owner_health_state.duplicate(true)
	var healthc_gate_passed := bool(update_damage_cap_state.get("healthcGatePassed", false))
	var lifesteal := float(update_type_state.get("lifesteal", 0.0))
	var owner_is_healthc := bool(update_owner_health_state.get("isHealthc", false))
	var lifesteal_gate_passed := healthc_gate_passed and lifesteal > 0.0 and owner_is_healthc
	var entity_health := float(update_entity_state.get("health", 0.0))
	var damage_amount := float(update_damage_cap_state.get("damage", update_bullet_state.get("damage", 0.0)))
	var lifesteal_result := 0.0
	if lifesteal_gate_passed:
		lifesteal_result = maxf(minf(entity_health, damage_amount), 0.0)
	var owner_heal_amount := lifesteal_result * lifesteal if lifesteal_gate_passed else 0.0
	var owner_heal_call: Variant = null
	if lifesteal_gate_passed:
		owner_heal_call = {
			"call": "o.heal(result * lifesteal)",
			"amount": owner_heal_amount,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"hitEntity": update_hit_entity_state,
		"damageCap": update_damage_cap_state,
		"ownerHealth": update_owner_health_state,
		"healthcGatePassed": healthc_gate_passed,
		"lifesteal": lifesteal,
		"ownerIsHealthc": owner_is_healthc,
		"lifestealGatePassed": lifesteal_gate_passed,
		"entityHealth": entity_health,
		"damage": damage_amount,
		"lifestealResult": lifesteal_result,
		"ownerHealCalled": lifesteal_gate_passed,
		"ownerHealAmount": owner_heal_amount,
		"ownerHealCall": owner_heal_call,
		"armorDamageDeferred": true,
		"unitImpulseDeferred": true,
		"pierceDeferred": true,
		"healthcGateSource": "if(entity instanceof Healthc h)",
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
		"lifestealResultSource": "float result = Math.max(Math.min(h.health(), damage), 0)",
		"ownerHealSource": "o.heal(result * lifesteal)",
		"pierceArmorBoundarySource": "if(pierceArmor)",
	}

static func hit_entity_armor_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, lifesteal_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_hit_entity_state: Dictionary = hit_entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_lifesteal_state: Dictionary = lifesteal_state.duplicate(true)
	var healthc_gate_passed := bool(update_damage_cap_state.get("healthcGatePassed", false))
	var damage_amount := float(update_damage_cap_state.get("damage", update_bullet_state.get("damage", 0.0)))
	var pierce_armor := bool(update_type_state.get("pierceArmor", false))
	var armor_multiplier := float(update_type_state.get("armorMultiplier", 1.0))
	var pierce_armor_gate_passed := healthc_gate_passed and pierce_armor
	var armor_multiplier_gate_passed := healthc_gate_passed and not pierce_armor and armor_multiplier != 1.0
	var damage_gate_passed := healthc_gate_passed and not pierce_armor and armor_multiplier == 1.0
	var health_damage_call: Variant = null
	if pierce_armor_gate_passed:
		health_damage_call = {
			"call": "h.damagePierce(damage)",
			"damage": damage_amount,
		}
	elif armor_multiplier_gate_passed:
		health_damage_call = {
			"call": "h.damageArmorMult(damage, armorMultiplier)",
			"damage": damage_amount,
			"armorMultiplier": armor_multiplier,
		}
	elif damage_gate_passed:
		health_damage_call = {
			"call": "h.damage(damage)",
			"damage": damage_amount,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"hitEntity": update_hit_entity_state,
		"damageCap": update_damage_cap_state,
		"lifesteal": update_lifesteal_state,
		"healthcGatePassed": healthc_gate_passed,
		"damage": damage_amount,
		"pierceArmor": pierce_armor,
		"armorMultiplier": armor_multiplier,
		"pierceArmorGatePassed": pierce_armor_gate_passed,
		"armorMultiplierGatePassed": armor_multiplier_gate_passed,
		"damageGatePassed": damage_gate_passed,
		"damagePierceCalled": pierce_armor_gate_passed,
		"damageArmorMultCalled": armor_multiplier_gate_passed,
		"damageCalled": damage_gate_passed,
		"healthDamageCall": health_damage_call,
		"unitImpulseDeferred": true,
		"pierceDeferred": true,
		"healthcGateSource": "if(entity instanceof Healthc h)",
		"damageLocalSource": "float damage = b.damage",
		"pierceArmorSource": "if(pierceArmor)",
		"damagePierceSource": "h.damagePierce(damage)",
		"armorMultiplierSource": "}else if(armorMultiplier != 1)",
		"damageArmorMultSource": "h.damageArmorMult(damage, armorMultiplier)",
		"damageSource": "}else{ h.damage(damage); }",
		"unitBoundarySource": "if(entity instanceof Unit unit)",
	}

static func hit_entity_unit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, armor_damage_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_armor_damage_state: Dictionary = armor_damage_state.duplicate(true)
	var unit_gate_passed := bool(update_entity_state.get("isUnit", false))
	var knockback := float(update_type_state.get("knockback", 0.0))
	var impact := bool(update_type_state.get("impact", false))
	var status = update_type_state.get("status", null)
	var status_duration := float(update_type_state.get("statusDuration", 480.0))
	var entity_x := float(update_entity_state.get("x", 0.0))
	var entity_y := float(update_entity_state.get("y", 0.0))
	var bullet_x := float(update_bullet_state.get("x", 0.0))
	var bullet_y := float(update_bullet_state.get("y", 0.0))
	var bullet_rotation := float(update_bullet_state.get("rotation", 0.0))
	var impulse_vector := Vector2.ZERO
	if unit_gate_passed:
		var base_vector := Vector2(entity_x - bullet_x, entity_y - bullet_y)
		if base_vector != Vector2.ZERO:
			impulse_vector = base_vector.normalized() * (knockback * 80.0)
	if unit_gate_passed and impact:
		var impulse_length := impulse_vector.length()
		var impact_angle := bullet_rotation + (180.0 if knockback < 0.0 else 0.0)
		impulse_vector = Vector2.RIGHT.rotated(deg_to_rad(impact_angle)) * impulse_length
	var impulse_call: Variant = null
	var status_apply_call: Variant = null
	var bullet_damage_event_call: Variant = null
	if unit_gate_passed:
		impulse_call = {
			"call": "unit.impulse(Tmp.v3)",
			"vector": {"x": impulse_vector.x, "y": impulse_vector.y},
		}
		status_apply_call = {
			"call": "unit.apply(status, statusDuration)",
			"status": status,
			"duration": status_duration,
		}
		bullet_damage_event_call = {
			"call": "Events.fire(bulletDamageEvent.set(unit, b))",
			"unit": update_entity_state,
			"bullet": update_bullet_state,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"armorDamage": update_armor_damage_state,
		"unitGatePassed": unit_gate_passed,
		"knockback": knockback,
		"impact": impact,
		"status": status,
		"statusDuration": status_duration,
		"entityX": entity_x,
		"entityY": entity_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"bulletRotation": bullet_rotation,
		"impulseVector": {"x": impulse_vector.x, "y": impulse_vector.y},
		"impulseCalled": unit_gate_passed,
		"impulseCall": impulse_call,
		"statusApplyCalled": unit_gate_passed,
		"statusApplyCall": status_apply_call,
		"bulletDamageEventFired": unit_gate_passed,
		"bulletDamageEventCall": bullet_damage_event_call,
		"destroyEventDeferred": true,
		"pierceDeferred": true,
		"unitGateSource": "if(entity instanceof Unit unit)",
		"impulseVectorSource": "Tmp.v3.set(unit).sub(b).nor().scl(knockback * 80f)",
		"impactAngleSource": "if(impact) Tmp.v3.setAngle(b.rotation() + (knockback < 0 ? 180f : 0f))",
		"unitImpulseSource": "unit.impulse(Tmp.v3)",
		"unitApplySource": "unit.apply(status, statusDuration)",
		"bulletDamageEventSource": "Events.fire(bulletDamageEvent.set(unit, b))",
		"destroyEventBoundarySource": "if(!wasDead && entity instanceof Unit unit && unit.dead)",
	}

static func hit_entity_unit_destroy_event_state(bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_effects_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_unit_effects_state: Dictionary = unit_effects_state.duplicate(true)
	var was_dead := bool(update_damage_cap_state.get("wasDead", false))
	var unit_gate_passed := bool(update_entity_state.get("isUnit", false))
	var unit_dead := bool(update_entity_state.get("unitDead", false))
	var destroy_event_gate_passed := (not was_dead) and unit_gate_passed and unit_dead
	var unit_destroy_event_call: Variant = null
	if destroy_event_gate_passed:
		unit_destroy_event_call = {
			"call": "Events.fire(new UnitBulletDestroyEvent(unit, b))",
			"unit": update_entity_state,
			"bullet": update_bullet_state,
		}
	return {
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"damageCap": update_damage_cap_state,
		"unitEffects": update_unit_effects_state,
		"wasDead": was_dead,
		"unitGatePassed": unit_gate_passed,
		"unitDead": unit_dead,
		"destroyEventGatePassed": destroy_event_gate_passed,
		"unitDestroyEventFired": destroy_event_gate_passed,
		"unitDestroyEventCall": unit_destroy_event_call,
		"pierceDeferred": true,
		"wasDeadSource": "boolean wasDead = entity instanceof Unit u && u.dead",
		"destroyEventGateSource": "if(!wasDead && entity instanceof Unit unit && unit.dead)",
		"unitDestroyEventSource": "Events.fire(new UnitBulletDestroyEvent(unit, b))",
		"handlePierceBoundarySource": "handlePierce(b, health, entity.x(), entity.y())",
	}

static func hit_entity_handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_destroy_event_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_unit_destroy_event_state: Dictionary = unit_destroy_event_state.duplicate(true)
	var effective_health := float(update_damage_cap_state.get("effectiveHealth", 0.0))
	var entity_x := float(update_entity_state.get("x", 0.0))
	var entity_y := float(update_entity_state.get("y", 0.0))
	var pierce_state := {"initialHealth": effective_health, "x": entity_x, "y": entity_y}
	var handle_pierce_result := handle_pierce_state(update_type_state, update_bullet_state, pierce_state)
	var handle_pierce_call := {
		"call": "handlePierce(b, health, entity.x(), entity.y())",
		"initialHealth": effective_health,
		"x": entity_x,
		"y": entity_y,
	}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"damageCap": update_damage_cap_state,
		"unitDestroyEvent": update_unit_destroy_event_state,
		"pierce": pierce_state,
		"handlePierce": handle_pierce_result,
		"bulletAfterPierce": handle_pierce_result.get("bullet", update_bullet_state),
		"effectiveHealth": effective_health,
		"entityX": entity_x,
		"entityY": entity_y,
		"handlePierceCalled": true,
		"handlePierceCall": handle_pierce_call,
		"damage": float(handle_pierce_result.get("damage", update_bullet_state.get("damage", 0.0))),
		"removeCalled": bool(handle_pierce_result.get("removeCalled", false)),
		"handlePierceCallSource": "handlePierce(b, health, entity.x(), entity.y())",
		"handlePierceMethodSource": "public void handlePierce(Bullet b, float initialHealth, float x, float y)",
	}

static func hit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var hit_x := float(update_hit_xy_state.get("x", 0.0))
	var hit_y := float(update_hit_xy_state.get("y", 0.0))
	var hit_effect: Variant = update_type_state.get("hitEffect", "Fx.hitBulletSmall")
	var hit_sound: Variant = update_type_state.get("hitSound", "Sounds.none")
	var hit_sound_pitch := float(update_type_state.get("hitSoundPitch", 1.0))
	var hit_sound_pitch_range := float(update_type_state.get("hitSoundPitchRange", 0.1))
	var hit_sound_volume := float(update_type_state.get("hitSoundVolume", 1.0))
	var hit_shake := float(update_type_state.get("hitShake", 0.0))
	var hit_color: Variant = update_type_state.get("hitColor", "Color.white")
	var bullet_rotation := float(update_bullet_state.get("rotation", 0.0))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"x": hit_x,
		"y": hit_y,
		"hitEffectCall": {
			"call": "hitEffect.at(x, y, b.rotation(), hitColor)",
			"effect": hit_effect,
			"x": hit_x,
			"y": hit_y,
			"rotation": bullet_rotation,
			"color": hit_color,
		},
		"hitSoundCall": {
			"call": "hitSound.at(x, y, hitSoundPitch + Mathf.range(hitSoundPitchRange), hitSoundVolume)",
			"sound": hit_sound,
			"x": hit_x,
			"y": hit_y,
			"pitchBase": hit_sound_pitch,
			"pitchRange": hit_sound_pitch_range,
			"volume": hit_sound_volume,
		},
		"shakeCall": {
			"call": "Effect.shake(hitShake, hitShake, b)",
			"amountX": hit_shake,
			"amountY": hit_shake,
			"bullet": update_bullet_state,
		},
		"hitEffectCallSource": "hitEffect.at(x, y, b.rotation(), hitColor)",
		"hitSoundCallSource": "hitSound.at(x, y, hitSoundPitch + Mathf.range(hitSoundPitchRange), hitSoundVolume)",
		"shakeCallSource": "Effect.shake(hitShake, hitShake, b)",
		"fragBranchBoundarySource": "if(createFrags && fragOnHit)",
	}

static func hit_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_frag_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_frag_state: Dictionary = hit_frag_state.duplicate(true)
	var hit_x := float(update_hit_xy_state.get("x", 0.0))
	var hit_y := float(update_hit_xy_state.get("y", 0.0))
	var create_frags := bool(update_hit_frag_state.get("createFrags", false))
	var frag_on_hit := bool(update_type_state.get("fragOnHit", true))
	var delay_frags := bool(update_type_state.get("delayFrags", false))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_bullet_exists := frag_bullet != null
	var frag_bullet_delay_frags := false
	if frag_bullet is Dictionary:
		var frag_bullet_state: Dictionary = frag_bullet
		frag_bullet_delay_frags = bool(frag_bullet_state.get("delayFrags", false))
	var frag_gate_passed := create_frags and frag_on_hit
	var delay_frag_gate_passed := frag_gate_passed and delay_frags and frag_bullet_exists and frag_bullet_delay_frags
	var time_run_call := {}
	var create_frags_call := {}
	if delay_frag_gate_passed:
		time_run_call = {
			"call": "Time.run(0f, () -> createFrags(b, x, y))",
			"delay": 0.0,
			"x": hit_x,
			"y": hit_y,
			"scheduled": true,
		}
	elif frag_gate_passed:
		create_frags_call = {
			"call": "createFrags(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitFrag": update_hit_frag_state,
		"x": hit_x,
		"y": hit_y,
		"createFrags": create_frags,
		"fragOnHit": frag_on_hit,
		"delayFrags": delay_frags,
		"fragBullet": frag_bullet,
		"fragBulletExists": frag_bullet_exists,
		"fragBulletDelayFrags": frag_bullet_delay_frags,
		"fragGatePassed": frag_gate_passed,
		"delayFragGatePassed": delay_frag_gate_passed,
		"timeRunCall": time_run_call,
		"createFragsCall": create_frags_call,
		"fragGateSource": "if(createFrags && fragOnHit)",
		"delayGateSource": "if(delayFrags && fragBullet != null && fragBullet.delayFrags)",
		"timeRunCallSource": "Time.run(0f, () -> createFrags(b, x, y))",
		"createFragsCallSource": "createFrags(b, x, y)",
		"postFragBoundarySource": "createPuddles(b, x, y)",
	}

static func hit_post_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, incoming_hit_frag_dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_frag_dispatch_state: Dictionary = incoming_hit_frag_dispatch_state.duplicate(true)
	var hit_x := float(update_hit_frag_dispatch_state.get("x", update_hit_xy_state.get("x", 0.0)))
	var hit_y := float(update_hit_frag_dispatch_state.get("y", update_hit_xy_state.get("y", 0.0)))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitFragDispatch": update_hit_frag_dispatch_state,
		"x": hit_x,
		"y": hit_y,
		"createPuddlesCall": {
			"call": "createPuddles(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		},
		"createIncendCall": {
			"call": "createIncend(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		},
		"createUnitsCall": {
			"call": "createUnits(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		},
		"createPuddlesCallSource": "createPuddles(b, x, y)",
		"createIncendCallSource": "createIncend(b, x, y)",
		"createUnitsCallSource": "createUnits(b, x, y)",
		"suppressionBoundarySource": "if(suppressionRange > 0)",
	}

static func hit_suppression_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, incoming_hit_post_frag_dispatch_state: Dictionary, source_tick_rate: float) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_post_frag_dispatch_state: Dictionary = incoming_hit_post_frag_dispatch_state.duplicate(true)
	var hit_x := float(update_hit_post_frag_dispatch_state.get("x", update_hit_xy_state.get("x", 0.0)))
	var hit_y := float(update_hit_post_frag_dispatch_state.get("y", update_hit_xy_state.get("y", 0.0)))
	var bullet_x := float(update_bullet_state.get("x", 0.0))
	var bullet_y := float(update_bullet_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var suppression_range := float(update_type_state.get("suppressionRange", -1.0))
	var suppression_duration := float(update_type_state.get("suppressionDuration", source_tick_rate * 8.0))
	var suppression_effect_chance := float(update_type_state.get("suppressionEffectChance", 50.0))
	var suppress_color: Variant = update_type_state.get("suppressColor", "Pal.sapBullet")
	var suppression_gate_passed := suppression_range > 0.0
	var suppression_vector := {"x": bullet_x, "y": bullet_y}
	var apply_suppression_call := {}
	if suppression_gate_passed:
		apply_suppression_call = {
			"call": "Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor)",
			"team": bullet_team,
			"x": bullet_x,
			"y": bullet_y,
			"range": suppression_range,
			"reload": suppression_duration,
			"maxDelay": 0.0,
			"applyParticleChance": suppression_effect_chance,
			"source": suppression_vector,
			"effectColor": suppress_color,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitPostFragDispatch": update_hit_post_frag_dispatch_state,
		"x": hit_x,
		"y": hit_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"bulletTeam": bullet_team,
		"suppressionRange": suppression_range,
		"suppressionDuration": suppression_duration,
		"suppressionEffectChance": suppression_effect_chance,
		"suppressColor": suppress_color,
		"suppressionGatePassed": suppression_gate_passed,
		"suppressionVector": suppression_vector,
		"applySuppressionCall": apply_suppression_call,
		"suppressionGateSource": "if(suppressionRange > 0)",
		"pooledVec2CommentSource": "//bullets are pooled, require separate Vec2 instance",
		"applySuppressionCallSource": "Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor)",
		"splashDamageBoundarySource": "createSplashDamage(b, x, y)",
	}

static func hit_splash_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, incoming_hit_suppression_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_suppression_state: Dictionary = incoming_hit_suppression_state.duplicate(true)
	var hit_x := float(update_hit_suppression_state.get("x", update_hit_xy_state.get("x", 0.0)))
	var hit_y := float(update_hit_suppression_state.get("y", update_hit_xy_state.get("y", 0.0)))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitSuppression": update_hit_suppression_state,
		"x": hit_x,
		"y": hit_y,
		"createSplashDamageCall": {
			"call": "createSplashDamage(b, x, y)",
			"x": hit_x,
			"y": hit_y,
			"called": true,
		},
		"createSplashDamageCallSource": "createSplashDamage(b, x, y)",
		"createSplashDamageMethodBoundarySource": "public void createSplashDamage(Bullet b, float x, float y)",
		"lightningBoundarySource": "for(int i = 0; i < lightning; i++)",
	}

static func create_splash_damage_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_hit_splash_damage_dispatch_state: Dictionary, incoming_damage_multiplier_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_splash_damage_dispatch_state: Dictionary = incoming_hit_splash_damage_dispatch_state.duplicate(true)
	var update_damage_multiplier_state: Dictionary = incoming_damage_multiplier_state.duplicate(true)
	var hit_x := float(update_hit_splash_damage_dispatch_state.get("x", 0.0))
	var hit_y := float(update_hit_splash_damage_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var bullet_absorbed := bool(update_bullet_state.get("absorbed", false))
	var splash_damage_radius := float(update_type_state.get("splashDamageRadius", -1.0))
	var splash_damage := float(update_type_state.get("splashDamage", 0.0))
	var damage_multiplier := float(update_damage_multiplier_state.get("damageMultiplier", 1.0))
	var splash_damage_pierce := bool(update_type_state.get("splashDamagePierce", false))
	var collides_air := bool(update_type_state.get("collidesAir", true))
	var collides_ground := bool(update_type_state.get("collidesGround", true))
	var scaled_splash_damage := bool(update_type_state.get("scaledSplashDamage", false))
	var armor_multiplier := float(update_type_state.get("armorMultiplier", 1.0))
	var splash_damage_gate_passed := splash_damage_radius > 0.0 and not bullet_absorbed
	var damage_amount := splash_damage * damage_multiplier
	var damage_call := {}
	if splash_damage_gate_passed:
		damage_call = {
			"call": "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier)",
			"team": bullet_team,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"damage": damage_amount,
			"complete": splash_damage_pierce,
			"air": collides_air,
			"ground": collides_ground,
			"scaled": scaled_splash_damage,
			"source": update_bullet_state,
			"armorMult": armor_multiplier,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitSplashDamageDispatch": update_hit_splash_damage_dispatch_state,
		"damageMultiplierState": update_damage_multiplier_state,
		"x": hit_x,
		"y": hit_y,
		"bulletTeam": bullet_team,
		"bulletAbsorbed": bullet_absorbed,
		"splashDamageRadius": splash_damage_radius,
		"splashDamage": splash_damage,
		"damageMultiplier": damage_multiplier,
		"damageAmount": damage_amount,
		"splashDamagePierce": splash_damage_pierce,
		"collidesAir": collides_air,
		"collidesGround": collides_ground,
		"scaledSplashDamage": scaled_splash_damage,
		"armorMultiplier": armor_multiplier,
		"splashDamageGatePassed": splash_damage_gate_passed,
		"damageCall": damage_call,
		"splashDamageGateSource": "if(splashDamageRadius > 0 && !b.absorbed)",
		"damageCallSource": "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier)",
		"statusBoundarySource": "if(status != StatusEffects.none)",
	}

static func create_splash_damage_status_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_splash_damage_damage_dispatch_state: Dictionary, source_tick_rate: float) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_damage_dispatch_state: Dictionary = incoming_create_splash_damage_damage_dispatch_state.duplicate(true)
	var hit_x := float(update_damage_dispatch_state.get("x", 0.0))
	var hit_y := float(update_damage_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var splash_damage_radius := float(update_damage_dispatch_state.get("splashDamageRadius", update_type_state.get("splashDamageRadius", -1.0)))
	var status := str(update_type_state.get("status", "none"))
	var status_duration := float(update_type_state.get("statusDuration", source_tick_rate * 8.0))
	var collides_air := bool(update_damage_dispatch_state.get("collidesAir", update_type_state.get("collidesAir", true)))
	var collides_ground := bool(update_damage_dispatch_state.get("collidesGround", update_type_state.get("collidesGround", true)))
	var splash_damage_gate_passed := bool(update_damage_dispatch_state.get("splashDamageGatePassed", false))
	var status_gate_passed := splash_damage_gate_passed and status != "none"
	var status_call := {}
	if status_gate_passed:
		status_call = {
			"call": "Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround)",
			"team": bullet_team,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"effect": status,
			"duration": status_duration,
			"air": collides_air,
			"ground": collides_ground,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createSplashDamageDamageDispatch": update_damage_dispatch_state,
		"x": hit_x,
		"y": hit_y,
		"bulletTeam": bullet_team,
		"splashDamageRadius": splash_damage_radius,
		"status": status,
		"statusDuration": status_duration,
		"collidesAir": collides_air,
		"collidesGround": collides_ground,
		"splashDamageGatePassed": splash_damage_gate_passed,
		"statusGatePassed": status_gate_passed,
		"statusCall": status_call,
		"statusGateSource": "if(status != StatusEffects.none)",
		"statusCallSource": "Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround)",
		"healsBoundarySource": "if(heals())",
	}

static func create_splash_damage_heal_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_splash_damage_status_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_status_dispatch_state: Dictionary = incoming_create_splash_damage_status_dispatch_state.duplicate(true)
	var update_nearby_blocks_state: Dictionary = nearby_blocks_state.duplicate(true)
	var hit_x := float(update_status_dispatch_state.get("x", 0.0))
	var hit_y := float(update_status_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var splash_damage_radius := float(update_status_dispatch_state.get("splashDamageRadius", update_type_state.get("splashDamageRadius", -1.0)))
	var splash_damage_gate_passed := bool(update_status_dispatch_state.get("splashDamageGatePassed", false))
	var heal_percent := float(update_type_state.get("healPercent", 0.0))
	var heal_amount := float(update_type_state.get("healAmount", 0.0))
	var heal_color: Variant = update_type_state.get("healColor", "Pal.heal")
	var heal_effect: Variant = update_type_state.get("healEffect", "Fx.healBlockFull")
	var heals := heal_percent > 0.0 or heal_amount > 0.0
	var heal_gate_passed := splash_damage_gate_passed and heals
	var nearby_blocks: Array = update_nearby_blocks_state.get("blocks", [])
	var each_block_call := {}
	var heal_applications: Array = []
	if heal_gate_passed:
		each_block_call = {
			"call": "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})",
			"team": bullet_team,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"predicate": "Building::damaged",
			"called": true,
		}
		for raw_block in nearby_blocks:
			if not raw_block is Dictionary:
				continue
			var other: Dictionary = raw_block.duplicate(true)
			if not bool(other.get("damaged", false)):
				continue
			var other_x := float(other.get("x", 0.0))
			var other_y := float(other.get("y", 0.0))
			var other_block: Variant = other.get("block", null)
			var other_max_health := float(other.get("maxHealth", 0.0))
			var heal_applied_amount := heal_percent / 100.0 * other_max_health + heal_amount
			heal_applications.append({
				"other": other,
				"healAppliedAmount": heal_applied_amount,
				"healEffectCall": {
					"call": "healEffect.at(other.x, other.y, 0f, healColor, other.block)",
					"effect": heal_effect,
					"x": other_x,
					"y": other_y,
					"rotation": 0.0,
					"color": heal_color,
					"block": other_block,
				},
				"otherHealCall": {
					"call": "other.heal(healPercent / 100f * other.maxHealth() + healAmount)",
					"amount": heal_applied_amount,
				},
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createSplashDamageStatusDispatch": update_status_dispatch_state,
		"nearbyBlocks": update_nearby_blocks_state,
		"x": hit_x,
		"y": hit_y,
		"bulletTeam": bullet_team,
		"splashDamageRadius": splash_damage_radius,
		"splashDamageGatePassed": splash_damage_gate_passed,
		"healPercent": heal_percent,
		"healAmount": heal_amount,
		"healColor": heal_color,
		"healEffect": heal_effect,
		"heals": heals,
		"healGatePassed": heal_gate_passed,
		"eachBlockCall": each_block_call,
		"healApplications": heal_applications,
		"healsGateSource": "if(heals())",
		"eachBlockCallSource": "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})",
		"healEffectCallSource": "healEffect.at(other.x, other.y, 0f, healColor, other.block)",
		"otherHealCallSource": "other.heal(healPercent / 100f * other.maxHealth() + healAmount)",
		"makeFireBoundarySource": "if(makeFire)",
	}

static func create_splash_damage_make_fire_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_splash_damage_heal_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_heal_dispatch_state: Dictionary = incoming_create_splash_damage_heal_dispatch_state.duplicate(true)
	var update_nearby_blocks_state: Dictionary = nearby_blocks_state.duplicate(true)
	var hit_x := float(update_heal_dispatch_state.get("x", 0.0))
	var hit_y := float(update_heal_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var splash_damage_radius := float(update_heal_dispatch_state.get("splashDamageRadius", update_type_state.get("splashDamageRadius", -1.0)))
	var splash_damage_gate_passed := bool(update_heal_dispatch_state.get("splashDamageGatePassed", false))
	var make_fire := bool(update_type_state.get("makeFire", false))
	var make_fire_gate_passed := splash_damage_gate_passed and make_fire
	var nearby_blocks: Array = update_nearby_blocks_state.get("blocks", [])
	var each_block_call := {}
	var fire_applications: Array = []
	if make_fire_gate_passed:
		each_block_call = {
			"call": "indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile))",
			"team": null,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"predicate": "other.team != b.team",
			"called": true,
		}
		for raw_block in nearby_blocks:
			if not raw_block is Dictionary:
				continue
			var other: Dictionary = raw_block.duplicate(true)
			if other.get("team", null) == bullet_team:
				continue
			var other_tile: Variant = other.get("tile", null)
			fire_applications.append({
				"other": other,
				"firesCreateCall": {
					"call": "Fires.create(other.tile)",
					"tile": other_tile,
				},
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createSplashDamageHealDispatch": update_heal_dispatch_state,
		"nearbyBlocks": update_nearby_blocks_state,
		"x": hit_x,
		"y": hit_y,
		"bulletTeam": bullet_team,
		"splashDamageRadius": splash_damage_radius,
		"splashDamageGatePassed": splash_damage_gate_passed,
		"makeFire": make_fire,
		"makeFireGatePassed": make_fire_gate_passed,
		"eachBlockCall": each_block_call,
		"fireApplications": fire_applications,
		"makeFireGateSource": "if(makeFire)",
		"eachBlockCallSource": "indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile))",
		"firesCreateCallSource": "Fires.create(other.tile)",
		"createFragsBoundarySource": "public void createFrags(Bullet b, float x, float y){",
	}

static func create_frags_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_frags_state: Dictionary = create_frags_state.duplicate(true)
	var frag_x := float(update_create_frags_state.get("x", 0.0))
	var frag_y := float(update_create_frags_state.get("y", 0.0))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_bullet_exists := frag_bullet != null
	var frag_on_absorb := bool(update_type_state.get("fragOnAbsorb", true))
	var bullet_absorbed := bool(update_bullet_state.get("absorbed", false))
	var pierce_frag_cap := int(update_type_state.get("pierceFragCap", -1))
	var bullet_frags := int(update_bullet_state.get("frags", 0))
	var frag_bullets := int(update_type_state.get("fragBullets", 9))
	var frag_gate_passed := frag_bullet_exists and (frag_on_absorb or not bullet_absorbed) and (pierce_frag_cap < 0 or bullet_frags < pierce_frag_cap)
	var loop_iterations := frag_bullets if frag_gate_passed else 0
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createFrags": update_create_frags_state,
		"x": frag_x,
		"y": frag_y,
		"fragBullet": frag_bullet,
		"fragBulletExists": frag_bullet_exists,
		"fragOnAbsorb": frag_on_absorb,
		"bulletAbsorbed": bullet_absorbed,
		"pierceFragCap": pierce_frag_cap,
		"bulletFrags": bullet_frags,
		"fragBullets": frag_bullets,
		"fragGatePassed": frag_gate_passed,
		"loopIterations": loop_iterations,
		"fragGateSource": "if(fragBullet != null && (fragOnAbsorb || !b.absorbed) && (pierceFragCap < 0 || b.frags < pierceFragCap))",
		"loopBoundarySource": "for(int i = 0; i < fragBullets; i++){",
		"randomLenBoundarySource": "float len = Mathf.random(fragOffsetMin, fragOffsetMax);",
	}

static func create_frags_random_geometry_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_frags_initial_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_initial_state: Dictionary = incoming_create_frags_initial_state.duplicate(true)
	var update_random_state: Dictionary = frag_random_state.duplicate(true)
	var len_samples: Array = update_random_state.get("lenSamples", [])
	var range_samples: Array = update_random_state.get("rangeSamples", [])
	var fragment_plans: Array = []
	var frag_gate_passed := bool(update_initial_state.get("fragGatePassed", false))
	var loop_iterations := int(update_initial_state.get("loopIterations", 0))
	var frag_bullets := int(update_type_state.get("fragBullets", update_initial_state.get("fragBullets", 9)))
	var frag_offset_min := float(update_type_state.get("fragOffsetMin", 1.0))
	var frag_offset_max := float(update_type_state.get("fragOffsetMax", 7.0))
	var frag_random_spread := float(update_type_state.get("fragRandomSpread", 360.0))
	var frag_angle := float(update_type_state.get("fragAngle", 0.0))
	var frag_spread := float(update_type_state.get("fragSpread", 0.0))
	var rotation_value := float(update_bullet_state.get("rotation", 0.0))
	var x_value := float(update_initial_state.get("x", 0.0))
	var y_value := float(update_initial_state.get("y", 0.0))
	if frag_gate_passed:
		for i in loop_iterations:
			var len_sample: Variant = len_samples[i] if i < len_samples.size() else null
			var range_sample: Variant = range_samples[i] if i < range_samples.size() else null
			var angle_value: Variant = null
			if range_sample != null:
				angle_value = rotation_value + float(range_sample) + frag_angle + frag_spread * float(i) - (float(frag_bullets) - 1.0) * frag_spread / 2.0
			fragment_plans.append({
				"index": i,
				"x": x_value,
				"y": y_value,
				"len": len_sample,
				"lenSampleProvided": len_sample != null,
				"lenRandomCall": {"call": "Mathf.random(fragOffsetMin, fragOffsetMax)", "min": frag_offset_min, "max": frag_offset_max, "value": len_sample},
				"rangeSample": range_sample,
				"rangeSampleProvided": range_sample != null,
				"angleRandomCall": {"call": "Mathf.range(fragRandomSpread / 2)", "range": frag_random_spread / 2.0, "value": range_sample},
				"angle": angle_value,
				"rotation": rotation_value,
				"fragAngle": frag_angle,
				"spreadOffset": frag_spread * float(i) - (float(frag_bullets) - 1.0) * frag_spread / 2.0,
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createFragsInitial": update_initial_state,
		"fragRandom": update_random_state,
		"fragGatePassed": frag_gate_passed,
		"loopIterations": loop_iterations,
		"fragOffsetMin": frag_offset_min,
		"fragOffsetMax": frag_offset_max,
		"fragRandomSpread": frag_random_spread,
		"fragAngle": frag_angle,
		"fragSpread": frag_spread,
		"rotation": rotation_value,
		"fragmentPlans": fragment_plans,
		"randomLenSource": "float len = Mathf.random(fragOffsetMin, fragOffsetMax);",
		"angleFormulaSource": "float a = b.rotation() + Mathf.range(fragRandomSpread / 2) + fragAngle + fragSpread * i - (fragBullets - 1) * fragSpread / 2f;",
		"createCallBoundarySource": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax));",
	}

static func create_frags_create_call_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_frags_random_geometry_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_geometry_state: Dictionary = incoming_create_frags_random_geometry_state.duplicate(true)
	var update_random_state: Dictionary = frag_random_state.duplicate(true)
	var velocity_samples: Array = update_random_state.get("velocitySamples", [])
	var life_samples: Array = update_random_state.get("lifeSamples", [])
	var fragment_plans: Array = update_geometry_state.get("fragmentPlans", [])
	var fragment_create_calls: Array = []
	var frag_gate_passed := bool(update_geometry_state.get("fragGatePassed", false))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_velocity_min := float(update_type_state.get("fragVelocityMin", 0.2))
	var frag_velocity_max := float(update_type_state.get("fragVelocityMax", 1.0))
	var frag_life_min := float(update_type_state.get("fragLifeMin", 1.0))
	var frag_life_max := float(update_type_state.get("fragLifeMax", 1.0))
	if frag_gate_passed:
		for fragment_plan in fragment_plans:
			var plan: Dictionary = fragment_plan
			var index := int(plan.get("index", fragment_create_calls.size()))
			var len_sample: Variant = plan.get("len", null)
			var angle_value: Variant = plan.get("angle", null)
			var base_x := float(plan.get("x", 0.0))
			var base_y := float(plan.get("y", 0.0))
			var velocity_sample: Variant = velocity_samples[index] if index < velocity_samples.size() else null
			var life_sample: Variant = life_samples[index] if index < life_samples.size() else null
			var frag_x: Variant = null
			var frag_y: Variant = null
			var trns_x: Variant = null
			var trns_y: Variant = null
			if len_sample != null and angle_value != null:
				var len_value := float(len_sample)
				var offset := arc_angles_trns_vec(angle_value, len_value, 0.0)
				trns_x = offset.get("x", null)
				trns_y = offset.get("y", null)
				frag_x = base_x + float(trns_x)
				frag_y = base_y + float(trns_y)
			fragment_create_calls.append({
				"index": index,
				"fragBullet": frag_bullet,
				"ownerBullet": update_bullet_state,
				"baseX": base_x,
				"baseY": base_y,
				"len": len_sample,
				"angle": angle_value,
				"trnsx": trns_x,
				"trnsy": trns_y,
				"x": frag_x,
				"y": frag_y,
				"velocity": velocity_sample,
				"velocitySampleProvided": velocity_sample != null,
				"velocityRandomCall": {"call": "Mathf.random(fragVelocityMin, fragVelocityMax)", "min": frag_velocity_min, "max": frag_velocity_max, "value": velocity_sample},
				"life": life_sample,
				"lifeSampleProvided": life_sample != null,
				"lifeRandomCall": {"call": "Mathf.random(fragLifeMin, fragLifeMax)", "min": frag_life_min, "max": frag_life_max, "value": life_sample},
				"call": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax))",
			})
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createFragsRandomGeometry": update_geometry_state,
		"fragRandom": update_random_state,
		"fragGatePassed": frag_gate_passed,
		"fragBullet": frag_bullet,
		"fragVelocityMin": frag_velocity_min,
		"fragVelocityMax": frag_velocity_max,
		"fragLifeMin": frag_life_min,
		"fragLifeMax": frag_life_max,
		"fragmentCreateCalls": fragment_create_calls,
		"trnsxSource": "Angles.trnsx(a, len)",
		"trnsySource": "Angles.trnsy(a, len)",
		"velocityRandomSource": "Mathf.random(fragVelocityMin, fragVelocityMax)",
		"lifeRandomSource": "Mathf.random(fragLifeMin, fragLifeMax)",
		"createCallSource": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax));",
		"fragsIncrementBoundarySource": "b.frags++;",
	}

static func create_frags_increment_state(bullet_state: Dictionary, incoming_create_frags_create_call_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_call_state: Dictionary = incoming_create_frags_create_call_state.duplicate(true)
	var frag_gate_passed := bool(update_create_call_state.get("fragGatePassed", false))
	var bullet_frags_before := int(update_bullet_state.get("frags", 0))
	var bullet_frags_after := bullet_frags_before
	var frags_incremented := frag_gate_passed
	if frags_incremented:
		bullet_frags_after = bullet_frags_before + 1
	update_bullet_state["frags"] = bullet_frags_after
	return {
		"bullet": update_bullet_state,
		"createFragsCreateCall": update_create_call_state,
		"fragGatePassed": frag_gate_passed,
		"bulletFragsBefore": bullet_frags_before,
		"bulletFragsAfter": bullet_frags_after,
		"fragsIncremented": frags_incremented,
		"fragsIncrementSource": "b.frags++;",
	}

static func hit_size(data: Dictionary, defaults: SourceBulletDefaults) -> float:
	return float(data.get(SOURCE_BULLET_HIT_SIZE_KEY, defaults.hit_size_default()))

static func damage(data: Dictionary, defaults: SourceBulletDefaults) -> float:
	return float(data.get(SOURCE_BULLET_DAMAGE_KEY, defaults.damage_default()))

static func ammo_multiplier(data: Dictionary, defaults: SourceBulletDefaults) -> float:
	return float(data.get(SOURCE_BULLET_AMMO_MULTIPLIER_KEY, defaults.ammo_multiplier_default()))

static func reload_multiplier(data: Dictionary, defaults: SourceBulletDefaults) -> float:
	return float(data.get(SOURCE_BULLET_RELOAD_MULTIPLIER_KEY, defaults.reload_multiplier_default()))

static func scale(data: Dictionary, defaults: SourceBulletDefaults, texture_size: Vector2) -> Vector2:
	var width := float(data.get(SOURCE_BULLET_SCALE_WIDTH_KEY, defaults.width_default()))
	var height := float(data.get(SOURCE_BULLET_SCALE_HEIGHT_KEY, defaults.height_default()))
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Vector2.ONE
	return Vector2(width / texture_size.x, height / texture_size.y)
