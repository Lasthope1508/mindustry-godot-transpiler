extends RefCounted
class_name SourceBulletTypeUpdateState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_geometry_callback_registry := preload("res://src/game/SourceGeometryCallbackRegistry.gd")
const source_bullet_source_text_state := preload("res://src/game/SourceBulletSourceTextState.gd")

const SOURCE_BULLET_TRAIL_PARAM_DEFAULT := source_bullet_defaults.TRAIL_PARAM_DEFAULT
const SOURCE_BULLET_ROTATION_COMMENT := source_bullet_source_text_state.SOURCE_BULLET_ROTATION_COMMENT
const SOURCE_BULLET_ROTATION_METHOD := source_bullet_source_text_state.SOURCE_BULLET_ROTATION_METHOD
const SOURCE_BULLET_ROTATION_RETURN := source_bullet_source_text_state.SOURCE_BULLET_ROTATION_RETURN
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
const SOURCE_BULLET_TRAIL_MIN_VELOCITY_DEFAULT := source_bullet_defaults.TRAIL_MIN_VELOCITY_DEFAULT
const SOURCE_BULLET_TRAIL_CHANCE_DEFAULT := source_bullet_defaults.TRAIL_CHANCE_DEFAULT
const SOURCE_BULLET_TRAIL_SPREAD_DEFAULT := source_bullet_defaults.TRAIL_SPREAD_DEFAULT
const SOURCE_BULLET_TRAIL_INTERVAL_DEFAULT := source_bullet_defaults.TRAIL_INTERVAL_DEFAULT
const SOURCE_BULLET_TRAIL_COLOR_DEFAULT := source_bullet_defaults.TRAIL_COLOR_DEFAULT
const SOURCE_BULLET_TRAIL_EFFECT_DEFAULT := source_bullet_defaults.TRAIL_EFFECT_DEFAULT
const SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY := source_geometry_callback_registry.ANGLES_ANGLE_KEY
const SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_FALLBACK := source_geometry_callback_registry.ANGLES_ANGLE_FALLBACK
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
		SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY, SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_FALLBACK)),
	}

static func game_bullet_rotation_degrees(game: Object, bullet_state: Dictionary) -> float:
	var callbacks := default_callbacks_state(game)
	return bullet_rotation_degrees(bullet_state, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable()))

static func game_update_trail_effects_chance_state(game: Object, bullet_state: Dictionary, bullet_type_state: Dictionary, chance_delta_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_trail_effects_chance_state(bullet_state, bullet_type_state, chance_delta_result, random_offset_state, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY, Callable()))

static func game_update_trail_effects_interval_state(game: Object, chance_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_trail_effects_interval_state(chance_state, bullet_type_state, timer_get_result, random_offset_state, callbacks.get(SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY, Callable()))

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
