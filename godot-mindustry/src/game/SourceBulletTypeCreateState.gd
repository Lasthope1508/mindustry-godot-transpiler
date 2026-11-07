extends RefCounted
class_name SourceBulletTypeCreateState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_bullet_type_create_core_state := preload("res://src/game/SourceBulletTypeCreateCoreState.gd")
const source_bullet_type_create_motion_state := preload("res://src/game/SourceBulletTypeCreateMotionState.gd")
const source_geometry_callback_registry := preload("res://src/game/SourceGeometryCallbackRegistry.gd")
const SOURCE_BULLET_VELOCITY_VECTOR_FIELD := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_FIELD
const SOURCE_BULLET_VELOCITY_VECTOR_INIT_TRNS := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_INIT_TRNS
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_METHOD := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_METHOD
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_RETURN := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_RETURN
const SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE
const SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE
const SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY := source_geometry_callback_registry.TRNS_VEC_KEY
const SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_FALLBACK := source_geometry_callback_registry.TRNS_VEC_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_bullet_type_create_method_names"):
		var names = game.call("_bullet_type_create_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY, SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_FALLBACK)),
	}

static func game_velocity_vector_state(game: Object, velocity_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return velocity_vector_state(velocity_state, callbacks.get(SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY, Callable()))

static func game_keep_velocity_state(game: Object, trail_add_payload_state: Dictionary, bullet_type_state: Dictionary, owner_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return keep_velocity_state(trail_add_payload_state, bullet_type_state, owner_state, callbacks.get(SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY, Callable()))

static func initial_gate_state(create_call_state: Dictionary, bullet_type_state: Dictionary, random_angle_offset: float, create_chance_roll: float) -> Dictionary:
	return source_bullet_type_create_core_state.initial_gate_state(create_call_state, bullet_type_state, random_angle_offset, create_chance_roll)

static func spawn_unit_state(initial_gate: Dictionary, bullet_type_state: Dictionary, net_client: bool, owner_health_state: Dictionary, shooter_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_core_state.spawn_unit_state(initial_gate, bullet_type_state, net_client, owner_health_state, shooter_state)

static func bullet_identity_state(create_call_state: Dictionary, initial_gate: Dictionary, spawn_unit: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_core_state.bullet_identity_state(create_call_state, initial_gate, spawn_unit, bullet_type_state)

static func aim_state(identity_state: Dictionary, create_call_state: Dictionary, target_state: Dictionary, world_tile_from_aim: Variant) -> Dictionary:
	return source_bullet_type_create_motion_state.aim_state(identity_state, create_call_state, target_state, world_tile_from_aim)

static func velocity_position_state(aim_result: Dictionary, initial_gate: Dictionary, create_call_state: Dictionary, bullet_type_state: Dictionary, velocity_scale_random_factor: float) -> Dictionary:
	return source_bullet_type_create_motion_state.velocity_position_state(aim_result, initial_gate, create_call_state, bullet_type_state, velocity_scale_random_factor)

static func lifetime_payload_damage_state(velocity_position: Dictionary, create_call_state: Dictionary, bullet_type_state: Dictionary, life_scale_random_factor: float, damage_multiplier_factor: float) -> Dictionary:
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var raw_bullet_state = velocity_position.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(velocity_position.get("bulletVelocityPositionApplied", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(velocity_position.get("bulletContinues", false)),
			"bulletLifetimePayloadDamageApplied": false,
			"bullet": null,
			"lifetimeSource": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f)",
			"dataSource": "bullet.data = data",
			"hitSizeSource": "bullet.hitSize = hitSize",
			"moverSource": "bullet.mover = mover",
			"damageSource": "bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier()",
			"damageMultiplierSource": "return type.damageMultiplier(self())",
			"buildingDamageMultiplierSource": "bullet.buildingDamageMultiplier = buildingDamageMultiplier",
			"trailClearReservedSource": "if(bullet.trail != null){",
			"addReservedSource": "bullet.add()",
		}
	var lifetime := float(bullet_type_state.get("lifetime", 40.0))
	var lifetime_scl := float(bullet_create_call.get("lifetimeScl", 1.0))
	var life_scale_rand_min := float(bullet_type_state.get("lifeScaleRandMin", 1.0))
	var life_scale_rand_max := float(bullet_type_state.get("lifeScaleRandMax", 1.0))
	var life_random_multiplier := life_scale_random_factor if life_scale_rand_min != 1.0 or life_scale_rand_max != 1.0 else 1.0
	var lifetime_amount := lifetime * lifetime_scl * life_random_multiplier
	var create_damage := float(bullet_create_call.get("damage", -1.0))
	var type_damage := float(bullet_type_state.get("damage", 1.0))
	var base_damage := type_damage if create_damage < 0.0 else create_damage
	var hit_size := float(bullet_type_state.get("hitSize", 4.0))
	var building_damage_multiplier := float(bullet_type_state.get("buildingDamageMultiplier", source_bullet_defaults.BUILDING_DAMAGE_MULTIPLIER_DEFAULT))
	bullet_state = bullet_state.duplicate()
	bullet_state["lifetime"] = lifetime_amount
	bullet_state["data"] = bullet_create_call.get("data", null)
	bullet_state["hitSize"] = hit_size
	bullet_state["mover"] = bullet_create_call.get("mover", null)
	bullet_state["damage"] = base_damage * damage_multiplier_factor
	bullet_state["buildingDamageMultiplier"] = building_damage_multiplier
	return {
		"bulletContinues": true,
		"bulletLifetimePayloadDamageApplied": true,
		"lifeScaleRandMin": life_scale_rand_min,
		"lifeScaleRandMax": life_scale_rand_max,
		"lifeScaleRandomFactor": life_scale_random_factor,
		"lifeRandomMultiplier": life_random_multiplier,
		"lifetimeAmount": lifetime_amount,
		"baseDamage": base_damage,
		"damageMultiplierFactor": damage_multiplier_factor,
		"damageAmount": base_damage * damage_multiplier_factor,
		"bullet": bullet_state,
		"lifetimeSource": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f)",
		"dataSource": "bullet.data = data",
		"hitSizeSource": "bullet.hitSize = hitSize",
		"moverSource": "bullet.mover = mover",
		"damageSource": "bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier()",
		"damageMultiplierSource": "return type.damageMultiplier(self())",
		"buildingDamageMultiplierSource": "bullet.buildingDamageMultiplier = buildingDamageMultiplier",
		"trailClearReservedSource": "if(bullet.trail != null){",
		"addReservedSource": "bullet.add()",
	}

static func trail_add_state(lifetime_payload_damage: Dictionary) -> Dictionary:
	var raw_bullet_state = lifetime_payload_damage.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(lifetime_payload_damage.get("bulletLifetimePayloadDamageApplied", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(lifetime_payload_damage.get("bulletContinues", false)),
			"bulletTrailAddApplied": false,
			"trailCleared": false,
			"bulletAdded": false,
			"typeInitCalled": false,
			"typeInitCall": null,
			"bullet": null,
			"trailNullGuardSource": "if(bullet.trail != null){",
			"trailClearSource": "bullet.trail.clear()",
			"trailClearImplSource": "points.clear()",
			"bulletAddSource": "bullet.add()",
			"bulletCompAddSource": "type.init(self())",
			"keepVelocityReservedSource": "if(keepVelocity && owner instanceof Velc v){",
		}
	bullet_state = bullet_state.duplicate(true)
	var raw_trail_state = bullet_state.get("trail", null)
	var trail_state: Dictionary = raw_trail_state if raw_trail_state is Dictionary else {}
	var trail_cleared := false
	if raw_trail_state != null:
		trail_cleared = true
		if raw_trail_state is Dictionary:
			trail_state = trail_state.duplicate(true)
			trail_state["points"] = []
			bullet_state["trail"] = trail_state
	var type_init_call := {"call": "type.init(self())", "bullet": bullet_state}
	return {
		"bulletContinues": true,
		"bulletTrailAddApplied": true,
		"trailCleared": trail_cleared,
		"bulletAdded": true,
		"typeInitCalled": true,
		"typeInitCall": type_init_call,
		"bullet": bullet_state,
		"trailNullGuardSource": "if(bullet.trail != null){",
		"trailClearSource": "bullet.trail.clear()",
		"trailClearImplSource": "points.clear()",
		"bulletAddSource": "bullet.add()",
		"bulletCompAddSource": "type.init(self())",
		"keepVelocityReservedSource": "if(keepVelocity && owner instanceof Velc v){",
	}

static func velocity_vector_state(velocity_state: Dictionary, trns_vec: Callable) -> Dictionary:
	if velocity_state.has("x") or velocity_state.has("y"):
		return {
			"x": float(velocity_state.get("x", 0.0)),
			"y": float(velocity_state.get("y", 0.0)),
			"source": SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE,
		}
	var angle := float(velocity_state.get("angle", 0.0))
	var speed := float(velocity_state.get("speed", 0.0))
	var vec: Dictionary = trns_vec.call(angle, speed, 0.0)
	return {
		"x": float(vec.get("x", 0.0)),
		"y": float(vec.get("y", 0.0)),
		"angle": angle,
		"speed": speed,
		"source": SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE,
	}

static func keep_velocity_state(trail_add: Dictionary, bullet_type_state: Dictionary, owner_state: Dictionary, trns_vec: Callable) -> Dictionary:
	var raw_bullet_state = trail_add.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(trail_add.get("bulletTrailAddApplied", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(trail_add.get("bulletContinues", false)),
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
	var keep_velocity := bool(bullet_type_state.get("keepVelocity", true))
	var scale_keep_velocity := bool(bullet_type_state.get("scaleKeepVelocity", false))
	var owner_is_velc := bool(owner_state.get("isVelc", false))
	bullet_state = bullet_state.duplicate(true)
	var raw_velocity_state = bullet_state.get("velocity", {})
	var velocity_state: Dictionary = raw_velocity_state if raw_velocity_state is Dictionary else {}
	var bullet_vel_before := velocity_vector_state(velocity_state, trns_vec)
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
