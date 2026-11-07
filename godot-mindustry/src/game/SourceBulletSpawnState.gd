extends RefCounted
class_name SourceBulletSpawnState

static func spawn_state_from_values(ammo_item: String, bullet_damage: float, bullet_reload_multiplier: float, bullet_velocity: Vector2, bullet_speed: float, bullet_hit_size: float, bullet_lifetime_remaining: float, sprite_id: String, bullet_sprite_scale: Vector2) -> Dictionary:
	return {
		"ammo_item": ammo_item,
		"damage": bullet_damage,
		"reload_multiplier": bullet_reload_multiplier,
		"velocity": bullet_velocity,
		"speed": bullet_speed,
		"hit_size": bullet_hit_size,
		"hitSize": bullet_hit_size,
		"lifetime_remaining": bullet_lifetime_remaining,
		"sprite_id": sprite_id,
		"sprite_scale": bullet_sprite_scale,
	}

static func spawn_turret_bullet_from_state(game, origin: Vector2, target, bullet_spawn_state: Dictionary, bullet_texture: Texture2D) -> void:
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
	sprite.texture = bullet_texture
	sprite.position = origin
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = bullet_spawn_state.get("sprite_scale", Vector2.ONE) as Vector2
	game.get_node("World/BulletLayer").add_child(sprite)
	var bullets: Array = game.get("bullets")
	bullets.append({"sprite": sprite, "target": target, "velocity": bullet_velocity, "speed": float(bullet_spawn_state.get("speed", 0.0)), "damage": float(bullet_spawn_state.get("damage", 0.0)), "hitSize": float(bullet_spawn_state.get("hit_size", 0.0)), "lifetime_remaining": float(bullet_spawn_state.get("lifetime_remaining", 0.0))})
