extends "res://src/game/SourceConsumeLiquidPortBridge.gd"

const source_bullet_runtime_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_bullet_runtime_port_bridge_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_turret_init_state_script := preload("res://src/game/SourceTurretInitState.gd")

func source_turret_init_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float, tracking_range: float) -> Dictionary:
	return source_turret_init_state_script.turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range)

func generated_turret_init_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float, tracking_range: float) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range)

func generated_turret_init_source_tilesize_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_source_tilesize_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size)

func generated_turret_init_size_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_size_default_bridge_state(shoot_y, shoot_y_is_negative_infinity)

func generated_turret_init_disable_overlap_check_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_disable_overlap_check_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground)

func generated_turret_init_range_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_range_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check)

func generated_turret_init_tracking_range_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_tracking_range_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value)

func source_base_turret_init_state(coolant_present: bool, found_consume_coolant: bool, disable_overlap_check: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, source_tilesize: float, fog_radius_multiplier: float, fog_radius: int) -> Dictionary:
	return source_turret_init_state_script.base_turret_init_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius)

func generated_base_turret_init_bridge_state(coolant_present: bool, found_consume_coolant: bool, disable_overlap_check: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, source_tilesize: float, fog_radius_multiplier: float, fog_radius: int) -> Dictionary:
	return source_turret_init_state_script.generated_base_turret_init_bridge_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius)

func source_base_turret_reinitialize_consumers_state() -> Dictionary:
	return source_turret_init_state_script.base_turret_reinitialize_consumers_state()

func generated_base_turret_reinitialize_consumers_bridge_state() -> Dictionary:
	return source_turret_init_state_script.generated_base_turret_reinitialize_consumers_bridge_state()

func source_base_turret_check_init_coolant_state(coolant_present: bool, has_consumer: bool) -> Dictionary:
	return source_turret_init_state_script.base_turret_check_init_coolant_state(coolant_present, has_consumer)

func generated_base_turret_check_init_coolant_bridge_state(coolant_present: bool, has_consumer: bool) -> Dictionary:
	return source_turret_init_state_script.generated_base_turret_check_init_coolant_bridge_state(coolant_present, has_consumer)

func source_bullet_texture(sprite_id: String) -> Texture2D:
	var path := source_bullet_runtime_state.texture_path(sprite_id)
	return source_bullet_runtime_port_bridge_texture_runtime_state.load_png_texture(path)

func source_bullet_range_change(data: Dictionary) -> float:
	return source_bullet_runtime_state.range_change(data)

func source_bullet_extra_range_margin(data: Dictionary) -> float:
	return source_bullet_runtime_state.extra_range_margin(data)

func source_bullet_inaccuracy(data: Dictionary) -> float:
	return source_bullet_runtime_state.inaccuracy(data)

func source_bullet_lifetime_seconds(data: Dictionary) -> float:
	return source_bullet_runtime_state.lifetime_seconds(data)

func source_bullet_world_speed_per_tick(data: Dictionary) -> float:
	return source_bullet_runtime_state.world_speed_per_tick(data)

func source_bullet_world_speed(data: Dictionary) -> float:
	return source_bullet_runtime_state.world_speed(data)

func source_bullet_velocity(data: Dictionary, shoot_angle_degrees: float) -> Vector2:
	return source_bullet_runtime_state.velocity(data, shoot_angle_degrees)

func source_bullet_hit_size(data: Dictionary) -> float:
	return source_bullet_runtime_state.hit_size(data)

func source_bullet_damage(data: Dictionary) -> float:
	return source_bullet_runtime_state.damage(data)

func source_bullet_ammo_multiplier(data: Dictionary) -> float:
	return source_bullet_runtime_state.ammo_multiplier(data)

func source_bullet_reload_multiplier(data: Dictionary) -> float:
	return source_bullet_runtime_state.reload_multiplier(data)

func source_bullet_dimensions(data: Dictionary) -> Dictionary:
	return source_bullet_runtime_state.dimensions(data)

func source_bullet_scale(data: Dictionary, texture_size: Vector2) -> Vector2:
	return source_bullet_runtime_state.scale(data, texture_size)

func spawn_turret_bullet(origin: Vector2, target, data: Dictionary, shoot_angle_degrees := 0.0) -> void:
	source_bullet_runtime_state.spawn_turret_bullet(self, origin, target, data, shoot_angle_degrees)

func simulate_bullets(delta: float) -> void:
	source_bullet_runtime_state.simulate_bullets(self, delta)
