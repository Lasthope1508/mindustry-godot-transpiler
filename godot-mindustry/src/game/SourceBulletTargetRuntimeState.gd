extends RefCounted
class_name SourceBulletTargetRuntimeState

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
		"bullet_hit_size": bullet.get("hitSize", bullet.get("hit_size", null)),
		"bullet_damage": float(bullet.get("damage", 0.0)),
		"lifetime_remaining": float(bullet.get("lifetime_remaining", 0.0)),
	}

static func target_step_from_context(context: Dictionary, default_hit_size: float) -> Dictionary:
	var bullet: Dictionary = context.get("bullet", {})
	var seconds := float(context.get("seconds", 0.0))
	var velocity_value = context.get("bullet_velocity", bullet.get("velocity", Vector2.ZERO))
	if not (velocity_value is Vector2):
		velocity_value = Vector2.ZERO
	var position_before: Vector2 = context.get("position_before", Vector2.ZERO)
	var target_position: Vector2 = context.get("target_position", Vector2.ZERO)
	var target_health_before := float(context.get("target_health_before", 0.0))
	return target_step_state(position_before, target_position, seconds, velocity_value, float(context.get("lifetime_remaining", 0.0)), float(context.get("bullet_hit_size", default_hit_size)), float(context.get("bullet_damage", 0.0)), target_health_before)

static func runtime_step_context(game, bullet: Dictionary, seconds: float) -> Dictionary:
	return target_step_context(game, bullet, seconds)

static func runtime_step_from_context(context: Dictionary, default_hit_size: float) -> Dictionary:
	return target_step_from_context(context, default_hit_size)

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

static func simulate_bullets(game, delta: float, default_hit_size: float) -> void:
	var bullets: Array = game.get("bullets")
	var pending_removals: Array = []
	var bullet_hit_count := int(game.get("bullet_hit_count"))
	for bullet in bullets:
		var sprite = bullet.get("sprite", null)
		if not is_instance_valid(sprite):
			pending_removals.append(bullet)
			continue
		var bullet_step_context := runtime_step_context(game, bullet, delta)
		var bullet_step := runtime_step_from_context(bullet_step_context, default_hit_size)
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
