extends RefCounted
class_name SourceBulletTypeInitState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")

const SOURCE_BULLET_INSTANT_DISAPPEAR_LIFETIME_MARGIN := source_bullet_defaults.INSTANT_DISAPPEAR_LIFETIME_MARGIN
const SOURCE_BULLET_SPAWN_BULLET_RANDOM_SPREAD_DEFAULT := source_bullet_defaults.SPAWN_BULLET_RANDOM_SPREAD_DEFAULT

static func init_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	var init_bullet_state := bullet_state.duplicate(true)
	var init_owner_state := owner_health_state.duplicate(true)
	var kill_shooter := bool(bullet_type_state.get("killShooter", false))
	var owner_is_healthc := bool(init_owner_state.get("isHealthc", false))
	var owner_dead := bool(init_owner_state.get("dead", false))
	var kill_shooter_applied := false
	if kill_shooter and owner_is_healthc and not owner_dead:
		kill_shooter_applied = true
		init_owner_state["health"] = minf(float(init_owner_state.get("health", 0.0)), 0.0)
		init_owner_state["dead"] = true
		init_owner_state["killedCalled"] = true
		init_owner_state["removed"] = true
	var instant_disappear := bool(bullet_type_state.get("instantDisappear", false))
	if instant_disappear:
		init_bullet_state["time"] = float(bullet_type_state.get("lifetime", source_bullet_defaults.LIFETIME_DEFAULT)) + SOURCE_BULLET_INSTANT_DISAPPEAR_LIFETIME_MARGIN
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
		"spawnBulletRandomSpread": float(bullet_type_state.get("spawnBulletRandomSpread", SOURCE_BULLET_SPAWN_BULLET_RANDOM_SPREAD_DEFAULT)),
		"spawnBulletRandomOffsets": spawn_bullet_random_offsets.duplicate(),
		"spawnBulletsSource": "if(spawnBullets.size > 0){",
		"spawnBulletCreateSource": "bullet.create(b, b.x, b.y, b.rotation() + Mathf.range(spawnBulletRandomSpread))",
		"mathfRangeSource": "return random(-range, range)",
		"updateBoundarySource": "public void update(Bullet b){",
	}
