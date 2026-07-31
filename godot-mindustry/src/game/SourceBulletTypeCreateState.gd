extends RefCounted
class_name SourceBulletTypeCreateState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const SOURCE_BULLET_VELOCITY_VECTOR_FIELD := "Vec2 vel = new Vec2();"
const SOURCE_BULLET_VELOCITY_VECTOR_INIT_TRNS := "vel.trns(angle, amount);"
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_METHOD := "public Vec2 trns(float angle, float amount){"
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_RETURN := "return set(amount, 0).rotate(angle);"
const SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE := "existing Vec2 velocity"
const SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE := "vel.trns(angle, amount)"
const SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY := "trns_vec"
const SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_FALLBACK := "source_arc_angles_trns_vec"

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
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var random_angle := random_angle_offset
	var create_chance := float(bullet_type_state.get("createChance", 1.0))
	if not bool(create_call_state.get("bulletContinues", false)) or bullet_create_call.is_empty():
		return {
			"bulletContinues": false,
			"bulletCreateCalled": false,
			"bulletCreateReturnsNull": true,
			"createChance": create_chance,
			"createChanceRoll": create_chance_roll,
			"createChancePassed": false,
			"angleOffsetSource": "angle += angleOffset + Mathf.range(randomAngleOffset)",
			"mathfRangeSource": "return random(-range, range)",
			"createChanceSource": "if(!Mathf.chance(createChance)) return null",
			"mathfChanceSource": "return d >= 1f || rand.nextFloat() < d",
			"ignoreSpawnAngleSource": "if(ignoreSpawnAngle) angle = 0",
			"spawnUnitReservedSource": "if(spawnUnit != null)",
		}
	var angle_offset := float(bullet_type_state.get("angleOffset", 0.0))
	var angle := float(bullet_create_call.get("angle", 0.0)) + angle_offset + random_angle
	var chance_passed := create_chance >= 1.0 or create_chance_roll < create_chance
	if not chance_passed:
		return {
			"bulletContinues": true,
			"bulletCreateCalled": true,
			"bulletCreateReturnsNull": true,
			"createChance": create_chance,
			"createChanceRoll": create_chance_roll,
			"createChancePassed": false,
			"angle": angle,
			"angleOffset": angle_offset,
			"randomAngleOffset": random_angle,
			"ignoreSpawnAngleApplied": false,
			"angleOffsetSource": "angle += angleOffset + Mathf.range(randomAngleOffset)",
			"mathfRangeSource": "return random(-range, range)",
			"createChanceSource": "if(!Mathf.chance(createChance)) return null",
			"mathfChanceSource": "return d >= 1f || rand.nextFloat() < d",
			"ignoreSpawnAngleSource": "if(ignoreSpawnAngle) angle = 0",
			"spawnUnitReservedSource": "if(spawnUnit != null)",
		}
	var ignore_spawn_angle := false
	if bool(bullet_type_state.get("ignoreSpawnAngle", false)):
		ignore_spawn_angle = true
		angle = 0.0
	return {
		"bulletContinues": true,
		"bulletCreateCalled": true,
		"bulletCreateReturnsNull": false,
		"createChance": create_chance,
		"createChanceRoll": create_chance_roll,
		"createChancePassed": true,
		"angle": angle,
		"angleOffset": angle_offset,
		"randomAngleOffset": random_angle,
		"ignoreSpawnAngleApplied": ignore_spawn_angle,
		"angleOffsetSource": "angle += angleOffset + Mathf.range(randomAngleOffset)",
		"mathfRangeSource": "return random(-range, range)",
		"createChanceSource": "if(!Mathf.chance(createChance)) return null",
		"mathfChanceSource": "return d >= 1f || rand.nextFloat() < d",
		"ignoreSpawnAngleSource": "if(ignoreSpawnAngle) angle = 0",
		"spawnUnitReservedSource": "if(spawnUnit != null)",
	}

static func spawn_unit_state(initial_gate: Dictionary, bullet_type_state: Dictionary, net_client: bool, owner_health_state: Dictionary, shooter_state: Dictionary) -> Dictionary:
	var spawn_unit: Dictionary = bullet_type_state.get("spawnUnit", {})
	var kill_shooter := bool(bullet_type_state.get("killShooter", false))
	var owner_is_health := bool(owner_health_state.get("isHealthc", false))
	var owner_dead := bool(owner_health_state.get("dead", false))
	var owner_killed := false
	if not bool(initial_gate.get("bulletContinues", false)) or bool(initial_gate.get("bulletCreateReturnsNull", false)):
		return {
			"bulletContinues": false,
			"spawnUnitBranchEntered": false,
			"bulletCreateReturnsNull": true,
			"spawnedUnit": null,
			"ownerKilled": false,
			"spawnUnitSource": "if(spawnUnit != null)",
			"bulletCreationReservedSource": "Bullet bullet = Bullet.create()",
		}
	if spawn_unit.is_empty():
		return {
			"bulletContinues": true,
			"spawnUnitBranchEntered": false,
			"bulletCreateReturnsNull": false,
			"spawnedUnit": null,
			"ownerKilled": false,
			"spawnUnitSource": "if(spawnUnit != null)",
			"bulletCreationReservedSource": "Bullet bullet = Bullet.create()",
		}
	owner_killed = kill_shooter and owner_is_health and not owner_dead
	if net_client:
		return {
			"bulletContinues": true,
			"spawnUnitBranchEntered": true,
			"spawnSkippedClient": true,
			"bulletCreateReturnsNull": true,
			"spawnedUnit": null,
			"ownerKilled": owner_killed,
			"spawnUnitSource": "if(spawnUnit != null)",
			"clientGuardSource": "if(!net.client())",
			"spawnedUnitCreateSource": "Unit spawned = spawnUnit.create(team)",
			"spawnedVelocitySource": "spawned.vel.trns(angle, spawnUnit.speed)",
			"shooterAssignSource": "if(spawned.controller() instanceof MissileAI ai)",
			"killShooterSource": "if(killShooter && owner instanceof Healthc h && !h.dead()) h.kill()",
			"returnNullSource": "return null",
			"bulletCreationReservedSource": "Bullet bullet = Bullet.create()",
		}
	var bullet_create_call: Dictionary = initial_gate.get("bulletCreateCall", {})
	var angle := float(initial_gate.get("angle", bullet_create_call.get("angle", 0.0)))
	var spawned_unit := {
		"type": str(spawn_unit.get("id", spawn_unit.get("name", ""))),
		"team": bullet_create_call.get("team", ""),
		"x": float(bullet_create_call.get("x", 0.0)),
		"y": float(bullet_create_call.get("y", 0.0)),
		"rotation": angle,
		"velocityApplied": false,
		"velocity": null,
		"missileAIShooter": null,
		"added": true,
		"notified": true,
	}
	if float(spawn_unit.get("missileAccelTime", 0.0)) <= 0.0:
		spawned_unit["velocityApplied"] = true
		spawned_unit["velocity"] = {"angle": angle, "speed": float(spawn_unit.get("speed", 0.0))}
	if bool(spawn_unit.get("controllerIsMissileAI", false)):
		if str(shooter_state.get("kind", "")) == "Unit":
			spawned_unit["missileAIShooter"] = shooter_state.get("id", null)
		if str(shooter_state.get("kind", "")) == "ControlBlock":
			spawned_unit["missileAIShooter"] = shooter_state.get("unit", null)
	return {
		"bulletContinues": true,
		"spawnUnitBranchEntered": true,
		"spawnSkippedClient": false,
		"bulletCreateReturnsNull": true,
		"spawnedUnit": spawned_unit,
		"ownerKilled": owner_killed,
		"spawnUnitSource": "if(spawnUnit != null)",
		"clientGuardSource": "if(!net.client())",
		"spawnedUnitCreateSource": "Unit spawned = spawnUnit.create(team)",
		"spawnedSetSource": "spawned.set(x, y)",
		"spawnedRotationSource": "spawned.rotation = angle",
		"spawnedVelocitySource": "spawned.vel.trns(angle, spawnUnit.speed)",
		"shooterAssignSource": "if(spawned.controller() instanceof MissileAI ai)",
		"controlShooterAssignSource": "ai.shooter = control.unit()",
		"spawnedAddSource": "spawned.add()",
		"notifySpawnSource": "Units.notifyUnitSpawn(spawned)",
		"killShooterSource": "if(killShooter && owner instanceof Healthc h && !h.dead()) h.kill()",
		"returnNullSource": "return null",
		"bulletCreationReservedSource": "Bullet bullet = Bullet.create()",
	}

static func bullet_identity_state(create_call_state: Dictionary, initial_gate: Dictionary, spawn_unit: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	var shooter = bullet_create_call.get("shooter", null)
	var bullet_owner = bullet_create_call.get("owner", null)
	if not bool(initial_gate.get("bulletContinues", false)) or bool(initial_gate.get("bulletCreateReturnsNull", false)):
		return {
			"bulletContinues": false,
			"bulletAllocated": false,
			"bulletCreateReturnsNull": true,
			"bullet": null,
			"bulletCreateSource": "Bullet bullet = Bullet.create()",
			"aimTileReservedSource": "if(!(aimX == -1f && aimY == -1f)){",
		}
	if bool(spawn_unit.get("spawnUnitBranchEntered", false)) and bool(spawn_unit.get("bulletCreateReturnsNull", false)):
		return {
			"bulletContinues": true,
			"bulletAllocated": false,
			"bulletCreateReturnsNull": true,
			"bullet": null,
			"bulletCreateSource": "Bullet bullet = Bullet.create()",
			"aimTileReservedSource": "if(!(aimX == -1f && aimY == -1f)){",
		}
	var bullet_identity := {
		"type": bullet_type_state.get("id", bullet_type_state.get("name", "")),
		"owner": bullet_owner,
		"shooter": bullet_owner if shooter == null else shooter,
		"team": bullet_create_call.get("team", ""),
		"time": 0.0,
		"originX": float(bullet_create_call.get("x", 0.0)),
		"originY": float(bullet_create_call.get("y", 0.0)),
	}
	return {
		"bulletContinues": true,
		"bulletAllocated": true,
		"bulletCreateReturnsNull": false,
		"bullet": bullet_identity,
		"bulletCreateSource": "Bullet bullet = Bullet.create()",
		"typeSource": "bullet.type = this",
		"ownerSource": "bullet.owner = owner",
		"shooterSource": "bullet.shooter = (shooter == null ? owner : shooter)",
		"teamSource": "bullet.team = team",
		"timeSource": "bullet.time = 0f",
		"originXSource": "bullet.originX = x",
		"originYSource": "bullet.originY = y",
		"aimTileReservedSource": "if(!(aimX == -1f && aimY == -1f)){",
	}

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
