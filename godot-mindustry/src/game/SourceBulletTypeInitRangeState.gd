extends RefCounted
class_name SourceBulletTypeInitRangeState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime := preload("res://src/game/SourceBulletRuntime.gd")
const SOURCE_BULLET_DRAG_DEFAULT := 0.0
const SOURCE_BULLET_RANGE_ZERO_DRAG_EPSILON := 0.000001
const SOURCE_BULLET_CONTINUOUS_DAMAGE_DEFAULT := -1.0
const SOURCE_BULLET_RANGE_OVERRIDE_DEFAULT := -1.0
const SOURCE_BULLET_RANGE_OVERRIDE_MIN_RETURN := 0.0
const SOURCE_BULLET_PIERCE_CAP_DEFAULT := -1
const SOURCE_BULLET_SET_DEFAULTS_DEFAULT := true
const SOURCE_BULLET_LIGHTNING_DEFAULT := 0
const SOURCE_BULLET_SPLASH_DAMAGE_RADIUS_DEFAULT := 0.0
const SOURCE_BULLET_LIGHT_RADIUS_UNSET_DEFAULT := -1.0
const SOURCE_BULLET_LIGHT_RADIUS_MIN_DEFAULT := 18.0
const SOURCE_BULLET_LIGHT_RADIUS_HIT_SIZE_SCALE := 5.0
const SOURCE_BULLET_DRAW_SIZE_DEFAULT := 40.0
const SOURCE_BULLET_DRAW_SIZE_SPEED_SCALE := 2.0

static func init_type_defaults_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state := bullet_type_state.duplicate(true)
	var pierce_cap := int(update_type_state.get("pierceCap", SOURCE_BULLET_PIERCE_CAP_DEFAULT))
	var pierce_applied := pierce_cap >= 1
	if pierce_applied:
		update_type_state["pierce"] = true
	var set_defaults := bool(update_type_state.get("setDefaults", SOURCE_BULLET_SET_DEFAULTS_DEFAULT))
	var lightning := int(update_type_state.get("lightning", SOURCE_BULLET_LIGHTNING_DEFAULT))
	var status_before := str(update_type_state.get("status", "none"))
	var status_shocked_applied := set_defaults and lightning > 0 and status_before == "none"
	if status_shocked_applied:
		update_type_state["status"] = "shocked"
	var despawn_hit_applied := set_defaults and (update_type_state.get("fragBullet", null) != null or float(update_type_state.get("splashDamageRadius", SOURCE_BULLET_SPLASH_DAMAGE_RADIUS_DEFAULT)) > 0.0 or lightning > 0)
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
	var light_radius := float(update_type_state.get("lightRadius", SOURCE_BULLET_LIGHT_RADIUS_UNSET_DEFAULT))
	var gate_passed := light_radius <= SOURCE_BULLET_LIGHT_RADIUS_UNSET_DEFAULT
	if not gate_passed:
		return {
			"bulletType": update_type_state,
			"lightRadiusApplied": false,
			"lightRadiusGatePassed": false,
			"lightRadius": light_radius,
			"lightRadiusGateSource": "if(lightRadius <= -1){",
			"lightRadiusAssignSource": "lightRadius = Math.max(18, hitSize * 5f)",
		}
	var resolved_light_radius: float = max(SOURCE_BULLET_LIGHT_RADIUS_MIN_DEFAULT, float(update_type_state.get("hitSize", source_bullet_defaults.HIT_SIZE_DEFAULT)) * SOURCE_BULLET_LIGHT_RADIUS_HIT_SIZE_SCALE)
	update_type_state["lightRadius"] = resolved_light_radius
	return {
		"bulletType": update_type_state,
		"lightRadiusApplied": true,
		"lightRadiusGatePassed": true,
		"lightRadius": resolved_light_radius,
		"hitSize": float(update_type_state.get("hitSize", source_bullet_defaults.HIT_SIZE_DEFAULT)),
		"lightRadiusGateSource": "if(lightRadius <= -1){",
		"lightRadiusAssignSource": "lightRadius = Math.max(18, hitSize * 5f)",
	}

static func init_draw_size_state(light_radius_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = light_radius_state.get("bulletType", {}).duplicate(true)
	var draw_size := float(update_type_state.get("drawSize", SOURCE_BULLET_DRAW_SIZE_DEFAULT))
	var computed_draw_size := float(update_type_state.get("trailLength", source_bullet_defaults.TRAIL_LENGTH_DEFAULT)) * float(update_type_state.get("speed", source_bullet_defaults.WORLD_SPEED_DEFAULT)) * SOURCE_BULLET_DRAW_SIZE_SPEED_SCALE
	var resolved_draw_size: float = max(draw_size, computed_draw_size)
	update_type_state["drawSize"] = resolved_draw_size
	return {
		"bulletType": update_type_state,
		"drawSize": resolved_draw_size,
		"drawSizeBefore": draw_size,
		"computedDrawSize": computed_draw_size,
		"trailLength": int(update_type_state.get("trailLength", source_bullet_defaults.TRAIL_LENGTH_DEFAULT)),
		"speed": float(update_type_state.get("speed", source_bullet_defaults.WORLD_SPEED_DEFAULT)),
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
	var range_override := float(update_type_state.get("rangeOverride", SOURCE_BULLET_RANGE_OVERRIDE_DEFAULT))
	var gate_passed := range_override > SOURCE_BULLET_RANGE_OVERRIDE_MIN_RETURN
	var resolved_range: Variant = null
	if gate_passed:
		resolved_range = range_override
	var runtime_state := source_bullet_runtime.calculate_range_override_state(bullet_type_state)
	if gate_passed:
		runtime_state["range"] = resolved_range
	var source_trace := {"rangeOverrideReturnSource": "if(rangeOverride > 0) return rangeOverride"}
	runtime_state["rangeOverrideReturnSource"] = source_trace.get("rangeOverrideReturnSource", "")
	return runtime_state

static func calculate_range_spawn_unit_state(override_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = override_state.get("bulletType", {}).duplicate(true)
	var prior_return := bool(override_state.get("returnEarly", false))
	var spawn_unit_value = update_type_state.get("spawnUnit", null)
	var gate_passed := (not prior_return) and spawn_unit_value != null
	var spawn_unit_state: Dictionary = {}
	if gate_passed:
		spawn_unit_state = (spawn_unit_value as Dictionary).duplicate(true)
	var resolved_range: Variant = override_state.get("range", null)
	if gate_passed:
		resolved_range = float(spawn_unit_state.get("lifetime", 0.0)) * float(spawn_unit_state.get("speed", 0.0))
	var returned_spawn_unit: Variant = null
	if gate_passed:
		returned_spawn_unit = spawn_unit_state
	var runtime_state := source_bullet_runtime.calculate_range_spawn_unit_state(override_state)
	if gate_passed:
		runtime_state["range"] = resolved_range
		runtime_state["spawnUnit"] = returned_spawn_unit
	var source_trace := {"spawnUnitReturnSource": "if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed"}
	runtime_state["spawnUnitReturnSource"] = source_trace.get("spawnUnitReturnSource", "")
	return runtime_state

static func calculate_range_despawn_unit_state(spawn_unit_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = spawn_unit_state.get("bulletType", {}).duplicate(true)
	var prior_return := bool(spawn_unit_state.get("returnEarly", false))
	var despawn_unit_value = update_type_state.get("despawnUnit", null)
	var gate_passed := (not prior_return) and despawn_unit_value != null
	var despawn_unit_state: Dictionary = {}
	if gate_passed:
		despawn_unit_state = (despawn_unit_value as Dictionary).duplicate(true)
	var resolved_range := 0.0
	if gate_passed:
		resolved_range = float(despawn_unit_state.get("lifetime", 0.0)) * float(despawn_unit_state.get("speed", 0.0))
	var returned_despawn_unit: Variant = null
	if gate_passed:
		returned_despawn_unit = despawn_unit_state
	var runtime_state := source_bullet_runtime.calculate_range_despawn_unit_state(spawn_unit_state)
	if gate_passed:
		runtime_state["range"] = resolved_range
		runtime_state["despawnUnit"] = returned_despawn_unit
	var source_trace := {"despawnUnitReturnSource": "if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed"}
	runtime_state["despawnUnitReturnSource"] = source_trace.get("despawnUnitReturnSource", "")
	return runtime_state

static func calculate_range_fallback_state(despawn_unit_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = despawn_unit_state.get("bulletType", {}).duplicate(true)
	var prior_return := bool(despawn_unit_state.get("returnEarly", false))
	var resolved_range: Variant = despawn_unit_state.get("range", null)
	var speed := float(update_type_state.get("speed", source_bullet_defaults.WORLD_SPEED_DEFAULT))
	var lifetime := float(update_type_state.get("lifetime", source_bullet_defaults.LIFETIME_DEFAULT))
	var drag := float(update_type_state.get("drag", SOURCE_BULLET_DRAG_DEFAULT))
	var max_range := float(update_type_state.get("maxRange", -1.0))
	var zero_drag := absf(drag) <= SOURCE_BULLET_RANGE_ZERO_DRAG_EPSILON
	var fallback_range := 0.0
	var fallback_gate_passed := not prior_return
	if fallback_gate_passed:
		if zero_drag:
			fallback_range = speed * lifetime
		else:
			fallback_range = speed * (1.0 - pow(1.0 - drag, lifetime)) / drag
		resolved_range = max(fallback_range, max_range)
	var runtime_state := source_bullet_runtime.calculate_range_fallback_state(despawn_unit_state)
	if fallback_gate_passed:
		runtime_state["range"] = resolved_range
		runtime_state["fallbackRange"] = fallback_range
		runtime_state["zeroDrag"] = zero_drag
		runtime_state["drag"] = drag
		runtime_state["maxRange"] = max_range
	var source_trace := {"fallbackReturnSource": "return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange)"}
	runtime_state["fallbackReturnSource"] = source_trace.get("fallbackReturnSource", "")
	return runtime_state

static func continuous_damage_default_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var runtime_state := source_bullet_runtime.continuous_damage_default_state(bullet_type_state)
	runtime_state["bulletType"] = update_type_state
	var source_trace := {
		"continuousDamage": SOURCE_BULLET_CONTINUOUS_DAMAGE_DEFAULT,
		"continuousDamageReturnSource": "return -1f",
	}
	runtime_state["continuousDamage"] = source_trace.get("continuousDamage", SOURCE_BULLET_CONTINUOUS_DAMAGE_DEFAULT)
	runtime_state["continuousDamageReturnSource"] = source_trace.get("continuousDamageReturnSource", "")
	return runtime_state
