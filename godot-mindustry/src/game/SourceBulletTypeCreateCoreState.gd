extends RefCounted
class_name SourceBulletTypeCreateCoreState

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
