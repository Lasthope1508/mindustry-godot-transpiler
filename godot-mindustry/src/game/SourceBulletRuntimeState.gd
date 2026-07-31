extends RefCounted
class_name SourceBulletRuntimeState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

const SOURCE_BULLET_TEXTURE_SPRITE_FIELD := "public String sprite;"
const SOURCE_BULLET_TEXTURE_BACK_SPRITE_FIELD := "public @Nullable String backSprite;"
const SOURCE_BULLET_TEXTURE_DEFAULT_SPRITE_CTOR := "this(speed, damage, \"bullet\");"
const SOURCE_BULLET_TEXTURE_FRONT_REGION_LOAD := "frontRegion = Core.atlas.find(sprite);"
const SOURCE_BULLET_TEXTURE_DEFAULT := "bullet"
const SOURCE_BULLET_TEXTURE_ASSET_ROOT := "res://assets/core/assets-raw/sprites/effects"
const SOURCE_BULLET_RANGE_CHANGE_DEFAULT := source_bullet_defaults.RANGE_CHANGE_DEFAULT
const SOURCE_BULLET_RANGE_CHANGE_COMMENT := "/** When used in a turret with multiple ammo types, this can be set to a non-zero value to influence range. */"
const SOURCE_BULLET_RANGE_CHANGE_FIELD := "public float rangeChange = 0f;"
const SOURCE_BULLET_RANGE_CHANGE_KEY := "rangeChange"
const SOURCE_BULLET_EXTRA_RANGE_MARGIN_DEFAULT := source_bullet_defaults.EXTRA_RANGE_MARGIN_DEFAULT
const SOURCE_BULLET_EXTRA_RANGE_MARGIN_KEY := "extraRangeMargin"
const SOURCE_BULLET_INACCURACY_DEFAULT := source_bullet_defaults.INACCURACY_DEFAULT
const SOURCE_BULLET_INACCURACY_COMMENT := "/** Extra inaccuracy when firing. */"
const SOURCE_BULLET_INACCURACY_FIELD := "public float inaccuracy = 0f;"
const SOURCE_BULLET_INACCURACY_KEY := "inaccuracy"
const SOURCE_BULLET_LIFETIME_COMMENT := "/** Lifetime in ticks. */"
const SOURCE_BULLET_LIFETIME_FIELD := "public float lifetime = 40f;"
const SOURCE_BULLET_LIFETIME_KEY := "lifetime"
const SOURCE_BULLET_LIFETIME_TICKS_PER_SECOND := source_bullet_defaults.TICKS_PER_SECOND
const SOURCE_BULLET_WORLD_SPEED_COMMENT := "/** Speed in units/tick. */"
const SOURCE_BULLET_WORLD_SPEED_FIELD := "public float speed = 1f;"
const SOURCE_BULLET_WORLD_SPEED_KEY := "speed"
const SOURCE_BULLET_WORLD_SPEED_STAT_CASE := "case speed -> type.speed * 60f / tilesize;"
const SOURCE_BULLET_WORLD_SPEED_TICKS_PER_SECOND := source_bullet_defaults.TICKS_PER_SECOND
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
const SOURCE_BULLET_HIT_SIZE_FIELD := "public float hitSize = 4;"
const SOURCE_BULLET_HIT_SIZE_KEY := "hitSize"
const SOURCE_BULLET_HIT_METHOD := "public void hit(Bullet b){"
const SOURCE_BULLET_HIT_CALL := "hit(b, b.x, b.y, true);"
const SOURCE_BULLET_DAMAGE_FIELD := "public float damage = 1f;"
const SOURCE_BULLET_DAMAGE_KEY := "damage"
const SOURCE_BULLET_DAMAGE_DEFAULT := source_bullet_defaults.DAMAGE_DEFAULT
const SOURCE_BULLET_AMMO_MULTIPLIER_COMMENT := "/** How many bullets get created per ammo item/liquid. */"
const SOURCE_BULLET_AMMO_MULTIPLIER_FIELD := "public float ammoMultiplier = 2f;"
const SOURCE_BULLET_AMMO_MULTIPLIER_DEFAULT := source_bullet_defaults.AMMO_MULTIPLIER_DEFAULT
const SOURCE_BULLET_AMMO_MULTIPLIER_KEY := "ammoMultiplier"
const SOURCE_BULLET_RELOAD_MULTIPLIER_COMMENT := "/** Multiplied by turret reload speed to get final shoot speed. */"
const SOURCE_BULLET_RELOAD_MULTIPLIER_FIELD := "public float reloadMultiplier = 1f;"
const SOURCE_BULLET_RELOAD_MULTIPLIER_DEFAULT := source_bullet_defaults.RELOAD_MULTIPLIER_DEFAULT
const SOURCE_BULLET_RELOAD_MULTIPLIER_KEY := "reloadMultiplier"
const SOURCE_BULLET_SCALE_FIELD := "public float width = 5f, height = 7f;"
const SOURCE_BULLET_SCALE_WIDTH_DEFAULT := source_bullet_defaults.SCALE_WIDTH_DEFAULT
const SOURCE_BULLET_SCALE_WIDTH_KEY := "width"
const SOURCE_BULLET_SCALE_HEIGHT_DEFAULT := source_bullet_defaults.SCALE_HEIGHT_DEFAULT
const SOURCE_BULLET_SCALE_HEIGHT_KEY := "height"
const SOURCE_BULLET_DESPAWNED_METHOD := "public void despawned(Bullet b){"
const SOURCE_BULLET_DESPAWNED_HIT_GATE := "if(despawnHit){"

static func range_change(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_RANGE_CHANGE_KEY, SOURCE_BULLET_RANGE_CHANGE_DEFAULT))

static func texture_path(sprite_id: String) -> String:
	var resolved_sprite := sprite_id if sprite_id != "" else SOURCE_BULLET_TEXTURE_DEFAULT
	return "%s/%s.png" % [SOURCE_BULLET_TEXTURE_ASSET_ROOT, resolved_sprite]

static func extra_range_margin(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_EXTRA_RANGE_MARGIN_KEY, SOURCE_BULLET_EXTRA_RANGE_MARGIN_DEFAULT))

static func inaccuracy(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_INACCURACY_KEY, SOURCE_BULLET_INACCURACY_DEFAULT))

static func lifetime_seconds(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_LIFETIME_KEY, source_bullet_defaults.LIFETIME_DEFAULT)) / SOURCE_BULLET_LIFETIME_TICKS_PER_SECOND

static func world_speed_per_tick(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_WORLD_SPEED_KEY, source_bullet_defaults.WORLD_SPEED_DEFAULT))

static func world_speed(data: Dictionary) -> float:
	return world_speed_per_tick(data) * SOURCE_BULLET_WORLD_SPEED_TICKS_PER_SECOND

static func velocity(data: Dictionary, shoot_angle_degrees: float) -> Vector2:
	var velocity_state := source_math_state.source_angles_trns_vec(shoot_angle_degrees, world_speed(data), 0.0)
	return Vector2(float(velocity_state.get("x", 0.0)), float(velocity_state.get("y", 0.0)))

static func source_bullet_velocity_vector_state(velocity_state: Dictionary) -> Dictionary:
	return {
		"source": SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE if bool(velocity_state.get("existing", false)) else SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE,
		"velocity_state": velocity_state,
	}

static func hit_size(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_HIT_SIZE_KEY, source_bullet_defaults.HIT_SIZE_DEFAULT))

static func damage(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_DAMAGE_KEY, SOURCE_BULLET_DAMAGE_DEFAULT))

static func ammo_multiplier(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_AMMO_MULTIPLIER_KEY, SOURCE_BULLET_AMMO_MULTIPLIER_DEFAULT))

static func reload_multiplier(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_RELOAD_MULTIPLIER_KEY, SOURCE_BULLET_RELOAD_MULTIPLIER_DEFAULT))

static func dimensions(data: Dictionary) -> Dictionary:
	var width := float(data.get(SOURCE_BULLET_SCALE_WIDTH_KEY, SOURCE_BULLET_SCALE_WIDTH_DEFAULT))
	var height := float(data.get(SOURCE_BULLET_SCALE_HEIGHT_KEY, SOURCE_BULLET_SCALE_HEIGHT_DEFAULT))
	return {"width": width, "height": height}

static func scale(data: Dictionary, texture_size: Vector2) -> Vector2:
	var width := float(data.get(SOURCE_BULLET_SCALE_WIDTH_KEY, SOURCE_BULLET_SCALE_WIDTH_DEFAULT))
	var height := float(data.get(SOURCE_BULLET_SCALE_HEIGHT_KEY, SOURCE_BULLET_SCALE_HEIGHT_DEFAULT))
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Vector2.ONE
	return Vector2(width / texture_size.x, height / texture_size.y)

static func target_step_state(position: Vector2, target_position: Vector2, seconds: float, bullet_velocity: Vector2, lifetime_remaining: float, bullet_hit_size: float, bullet_damage: float, target_health: float) -> Dictionary:
	var next_position := position + bullet_velocity * seconds
	var next_lifetime_remaining := lifetime_remaining - seconds
	var hit_target := target_position.distance_to(next_position) <= bullet_hit_size
	var target_health_after := target_health - bullet_damage if hit_target else target_health
	return {
		"next_position": next_position,
		"lifetime_remaining": next_lifetime_remaining,
		"expired": next_lifetime_remaining <= 0.0,
		"hit_target": hit_target,
		"hit_damage": bullet_damage if hit_target else 0.0,
		"target_health_before": target_health,
		"target_health_after": target_health_after,
		"target_destroyed": hit_target and target_health_after <= 0.0,
	}

static func spawn_state(data: Dictionary, shoot_angle_degrees: float, texture_size: Vector2) -> Dictionary:
	var bullet_damage := damage(data)
	var bullet_hit_size := hit_size(data)
	var bullet_speed := world_speed(data)
	return {
		"ammo_item": str(data.get("ammo_item", data.get("item", ""))),
		"damage": bullet_damage,
		"reload_multiplier": reload_multiplier(data),
		"velocity": velocity(data, shoot_angle_degrees),
		"speed": bullet_speed,
		"hit_size": bullet_hit_size,
		"hitSize": bullet_hit_size,
		"lifetime_remaining": lifetime_seconds(data),
		"sprite_id": str(data.get("sprite", SOURCE_BULLET_TEXTURE_DEFAULT)),
		"sprite_scale": scale(data, texture_size),
	}

static func spawn_turret_bullet(game, origin: Vector2, target, data: Dictionary, shoot_angle_degrees := 0.0) -> void:
	if data.is_empty():
		return
	var spawn_texture: Texture2D = game.call("source_bullet_texture", str(data.get("sprite", SOURCE_BULLET_TEXTURE_DEFAULT))) as Texture2D
	var texture_size: Vector2 = spawn_texture.get_size() if spawn_texture else Vector2.ZERO
	var bullet_spawn_state := spawn_state(data, shoot_angle_degrees, texture_size)
	var last_turret_fired_ammo_item := str(game.get("last_turret_fired_ammo_item"))
	var last_turret_fired_damage := float(game.get("last_turret_fired_damage"))
	last_turret_fired_ammo_item = str(bullet_spawn_state.get("ammo_item", ""))
	last_turret_fired_damage = float(bullet_spawn_state.get("damage", 0.0))
	game.set("last_turret_fired_ammo_item", last_turret_fired_ammo_item)
	game.set("last_turret_fired_damage", last_turret_fired_damage)
	game.set("last_turret_fired_reload_multiplier", float(bullet_spawn_state.get("reload_multiplier", 1.0)))
	var turret_shot_count := int(game.get("turret_shot_count"))
	turret_shot_count += 1
	game.set("turret_shot_count", turret_shot_count)
	var bullet_velocity := bullet_spawn_state.get("velocity", Vector2.ZERO) as Vector2
	var sprite := Sprite2D.new()
	sprite.texture = game.call("source_bullet_texture", str(bullet_spawn_state.get("sprite_id", SOURCE_BULLET_TEXTURE_DEFAULT)))
	sprite.position = origin
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = bullet_spawn_state.get("sprite_scale", Vector2.ONE) as Vector2
	game.get_node("World/BulletLayer").add_child(sprite)
	var bullets: Array = game.get("bullets")
	bullets.append({"sprite": sprite, "target": target, "velocity": bullet_velocity, "speed": float(bullet_spawn_state.get("speed", 0.0)), "damage": float(bullet_spawn_state.get("damage", 0.0)), "hitSize": float(bullet_spawn_state.get("hit_size", 0.0)), "lifetime_remaining": float(bullet_spawn_state.get("lifetime_remaining", 0.0))})

static func target_step_context(game, bullet: Dictionary, seconds: float) -> Dictionary:
	var sprite = bullet.get("sprite", null)
	var position_before := Vector2.ZERO
	if is_instance_valid(sprite):
		position_before = sprite.position
	var target = bullet.get("target", null)
	var target_position := Vector2.ZERO
	var target_health_before := 0.0
	if target is Dictionary:
		var target_sprite = target.get("sprite", null)
		if is_instance_valid(target_sprite):
			target_position = target_sprite.position
		target_health_before = float(target.get("health", 0.0))
	return {
		"game": game,
		"bullet": bullet,
		"seconds": seconds,
		"position_before": position_before,
		"target_position": target_position,
		"target_health_before": target_health_before,
		"bullet_velocity": bullet.get("velocity", Vector2.ZERO),
		"bullet_hit_size": float(bullet.get("hitSize", bullet.get("hit_size", source_bullet_defaults.HIT_SIZE_DEFAULT))),
		"bullet_damage": float(bullet.get("damage", 0.0)),
		"lifetime_remaining": float(bullet.get("lifetime_remaining", 0.0)),
	}

static func target_step_from_context(context: Dictionary) -> Dictionary:
	var bullet: Dictionary = context.get("bullet", {})
	var seconds := float(context.get("seconds", 0.0))
	var velocity_value = context.get("bullet_velocity", bullet.get("velocity", Vector2.ZERO))
	if not (velocity_value is Vector2):
		velocity_value = Vector2.ZERO
	var position_before: Vector2 = context.get("position_before", Vector2.ZERO)
	var target_position: Vector2 = context.get("target_position", Vector2.ZERO)
	var target_health_before := float(context.get("target_health_before", 0.0))
	return target_step_state(position_before, target_position, seconds, velocity_value, float(context.get("lifetime_remaining", 0.0)), float(context.get("bullet_hit_size", source_bullet_defaults.HIT_SIZE_DEFAULT)), float(context.get("bullet_damage", 0.0)), target_health_before)

static func runtime_step_context(game, bullet: Dictionary, seconds: float) -> Dictionary:
	return target_step_context(game, bullet, seconds)

static func runtime_step_from_context(context: Dictionary) -> Dictionary:
	return target_step_from_context(context)

static func runtime_hit_application_state(runtime_context: Dictionary, runtime_step: Dictionary, current_hit_count: int) -> Dictionary:
	var hit_target := bool(runtime_step.get("hit_target", false))
	var target_health_before := float(runtime_context.get("target_health_before", runtime_step.get("target_health_before", 0.0)))
	var target_health_after := float(runtime_step.get("target_health_after", target_health_before))
	return {
		"hit_count": current_hit_count + 1 if hit_target else current_hit_count,
		"hit_damage": float(runtime_step.get("hit_damage", 0.0)),
		"target_health_before": target_health_before,
		"target_health_after": target_health_after,
		"target_destroyed": bool(runtime_step.get("target_destroyed", false)),
	}

static func simulate_bullets(game, delta: float) -> void:
	var bullets: Array = game.get("bullets")
	var pending_removals: Array = []
	var bullet_hit_count := int(game.get("bullet_hit_count"))
	for bullet in bullets:
		var sprite = bullet.get("sprite", null)
		if not is_instance_valid(sprite):
			pending_removals.append(bullet)
			continue
		var bullet_step_context := runtime_step_context(game, bullet, delta)
		var bullet_step := runtime_step_from_context(bullet_step_context)
		var hit_application := runtime_hit_application_state(bullet_step_context, bullet_step, bullet_hit_count)
		sprite.position = bullet_step.get("next_position", sprite.position) as Vector2
		var lifetime_remaining: float = float(bullet_step.get("lifetime_remaining", 0.0))
		bullet["lifetime_remaining"] = lifetime_remaining
		var target = bullet.get("target", null)
		var remove_bullet := false
		if bool(bullet_step.get("expired", false)):
			remove_bullet = true
		if target is Dictionary:
			var target_sprite = target.get("sprite", null)
			if is_instance_valid(target_sprite):
				if bool(bullet_step.get("hit_target", false)):
					var target_health_before: float = float(bullet_step_context.get("target_health_before", 0.0))
					target["health"] = float(hit_application.get("target_health_after", target_health_before))
					game.set("last_bullet_target_health_before", float(hit_application.get("target_health_before", target_health_before)))
					game.set("last_bullet_target_health_after", float(hit_application.get("target_health_after", target_health_before)))
					game.set("last_bullet_hit_damage", float(hit_application.get("hit_damage", 0.0)))
					game.set("last_bullet_target_destroyed", bool(hit_application.get("target_destroyed", false)))
					bullet_hit_count = int(hit_application.get("hit_count", bullet_hit_count))
					game.set("bullet_hit_count", int(hit_application.get("hit_count", bullet_hit_count)))
					remove_bullet = true
		if remove_bullet:
			pending_removals.append(bullet)
	game.set("bullet_hit_count", bullet_hit_count)
	for bullet in pending_removals:
		var sprite = bullet.get("sprite", null)
		if is_instance_valid(sprite):
			sprite.queue_free()
		bullets.erase(bullet)
