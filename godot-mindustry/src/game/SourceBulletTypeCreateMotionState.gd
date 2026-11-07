extends RefCounted
class_name SourceBulletTypeCreateMotionState

static func aim_state(identity_state: Dictionary, create_call_state: Dictionary, target_state: Dictionary, world_tile_from_aim: Variant) -> Dictionary:
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var raw_bullet_state = identity_state.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(identity_state.get("bulletAllocated", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(identity_state.get("bulletContinues", false)),
			"bulletAimApplied": false,
			"bullet": null,
			"aimTileSource": "bullet.aimTile = target instanceof Building b ? b.tile : world.tileWorld(aimX, aimY)",
			"worldTileWorldSource": "return tile(Math.round(x / tilesize), Math.round(y / tilesize))",
			"initVelReservedSource": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f))",
		}
	var aim_x := float(bullet_create_call.get("aimX", -1.0))
	var aim_y := float(bullet_create_call.get("aimY", -1.0))
	var has_aim_tile := not (aim_x == -1.0 and aim_y == -1.0)
	var aim_tile: Variant = null
	if has_aim_tile:
		if str(target_state.get("kind", "")) == "Building":
			aim_tile = target_state.get("tile", null)
		else:
			aim_tile = world_tile_from_aim
	bullet_state = bullet_state.duplicate()
	bullet_state["aimTile"] = aim_tile
	bullet_state["aimX"] = aim_x
	bullet_state["aimY"] = aim_y
	return {
		"bulletContinues": true,
		"bulletAimApplied": true,
		"hasAimTile": has_aim_tile,
		"bullet": bullet_state,
		"aimTileSource": "bullet.aimTile = target instanceof Building b ? b.tile : world.tileWorld(aimX, aimY)",
		"aimXSource": "bullet.aimX = aimX",
		"aimYSource": "bullet.aimY = aimY",
		"worldTileWorldSource": "return tile(Math.round(x / tilesize), Math.round(y / tilesize))",
		"initVelReservedSource": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f))",
	}

static func velocity_position_state(aim_result: Dictionary, initial_gate: Dictionary, create_call_state: Dictionary, bullet_type_state: Dictionary, velocity_scale_random_factor: float) -> Dictionary:
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var raw_bullet_state = aim_result.get("bullet", {})
	var bullet_state: Dictionary = raw_bullet_state if raw_bullet_state is Dictionary else {}
	if not bool(aim_result.get("bulletAimApplied", false)) or bullet_state.is_empty():
		return {
			"bulletContinues": bool(aim_result.get("bulletContinues", false)),
			"bulletVelocityPositionApplied": false,
			"bullet": null,
			"initVelSource": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f))",
			"bulletCompInitVelSource": "vel.trns(angle, amount); rotation = angle",
			"setSource": "bullet.set(x, y)",
			"lastXSource": "bullet.lastX = x",
			"lastYSource": "bullet.lastY = y",
			"lifetimeReservedSource": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f)",
		}
	var angle := float(initial_gate.get("angle", bullet_create_call.get("angle", 0.0)))
	var x := float(bullet_create_call.get("x", 0.0))
	var y := float(bullet_create_call.get("y", 0.0))
	var speed := float(bullet_type_state.get("speed", 0.0))
	var velocity_scl := float(bullet_create_call.get("velocityScl", 1.0))
	var velocity_scale_rand_min := float(bullet_type_state.get("velocityScaleRandMin", 1.0))
	var velocity_scale_rand_max := float(bullet_type_state.get("velocityScaleRandMax", 1.0))
	var velocity_random_multiplier := velocity_scale_random_factor if velocity_scale_rand_min != 1.0 or velocity_scale_rand_max != 1.0 else 1.0
	var velocity_amount := speed * velocity_scl * velocity_random_multiplier
	bullet_state = bullet_state.duplicate()
	bullet_state["velocity"] = {"angle": angle, "speed": velocity_amount}
	bullet_state["rotation"] = angle
	bullet_state["x"] = x
	bullet_state["y"] = y
	bullet_state["lastX"] = x
	bullet_state["lastY"] = y
	return {
		"bulletContinues": true,
		"bulletVelocityPositionApplied": true,
		"velocityScaleRandMin": velocity_scale_rand_min,
		"velocityScaleRandMax": velocity_scale_rand_max,
		"velocityScaleRandomFactor": velocity_scale_random_factor,
		"velocityRandomMultiplier": velocity_random_multiplier,
		"velocityAmount": velocity_amount,
		"bullet": bullet_state,
		"initVelSource": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f))",
		"bulletCompInitVelSource": "vel.trns(angle, amount); rotation = angle",
		"setSource": "bullet.set(x, y)",
		"lastXSource": "bullet.lastX = x",
		"lastYSource": "bullet.lastY = y",
		"lifetimeReservedSource": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f)",
	}
