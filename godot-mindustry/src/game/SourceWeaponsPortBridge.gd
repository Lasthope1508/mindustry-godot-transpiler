extends "res://src/game/SourceUnitUpdatePortBridge.gd"

const source_weapons_state := preload("res://src/game/SourceWeaponsState.gd")

func source_weapons_setup_mounts_state(weapon_states: Array) -> Dictionary:
	return source_weapons_state.setup_mounts_state(weapon_states)

func source_weapons_set_rotation_state(mount_states: Array, source_rotation: float) -> Dictionary:
	return source_weapons_state.set_rotation_state(mount_states, source_rotation)

func source_weapons_control_state(mount_states: Array, rotate_value: bool, shoot_value: bool) -> Dictionary:
	return source_weapons_state.control_state(mount_states, rotate_value, shoot_value)

func source_weapons_control_rotate_shoot_state(mount_states: Array, rotate_shoot: bool) -> Dictionary:
	return source_weapons_state.control_rotate_shoot_state(mount_states, rotate_shoot)

func source_weapons_aim_state(mount_states: Array, unit_x: float, unit_y: float, target_x: float, target_y: float, aim_dst: float) -> Dictionary:
	return source_weapons_state.aim_state(mount_states, unit_x, unit_y, target_x, target_y, aim_dst)

func source_weapons_aim_position_state(mount_states: Array, unit_x: float, unit_y: float, position_x: float, position_y: float, aim_dst: float) -> Dictionary:
	return source_weapons_state.aim_position_state(mount_states, unit_x, unit_y, position_x, position_y, aim_dst)

func source_weapons_can_shoot_state(disarmed_value: bool) -> Dictionary:
	return source_weapons_state.can_shoot_state(disarmed_value)

func source_weapons_remove_continuous_bullet_cleanup_state(mount_states: Array, unit_id: int) -> Dictionary:
	return source_weapons_state.remove_continuous_bullet_cleanup_state(mount_states, unit_id)

func source_weapons_remove_sound_stop_state(mount_states: Array) -> Dictionary:
	return source_weapons_state.remove_sound_stop_state(mount_states)

func source_weapons_update_dispatch_state(mount_states: Array, unit_id: int) -> Dictionary:
	return source_weapons_state.update_dispatch_state(mount_states, unit_id)

func source_weapon_update_passive_timers_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float) -> Dictionary:
	return source_weapons_state.game_update_passive_timers_state(self, mount_state, weapon_state, unit_state, source_delta)

func source_weapon_update_mount_origin_state(unit_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapons_state.game_update_mount_origin_state(self, unit_state, weapon_state)

func source_weapon_update_auto_target_retarget_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, mount_x: float, mount_y: float, find_target_result_exists: bool) -> Dictionary:
	return source_weapons_state.update_auto_target_retarget_state(mount_state, weapon_state, bullet_state, source_delta, mount_x, mount_y, find_target_result_exists)

func source_weapon_update_auto_target_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, mount_x: float, mount_y: float, check_target_result: bool) -> Dictionary:
	return source_weapons_state.update_auto_target_invalidation_state(mount_state, weapon_state, bullet_state, mount_x, mount_y, check_target_result)

func source_weapon_update_auto_target_shoot_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, mount_x: float, mount_y: float, target_within_result: bool, predicted_aim: Dictionary) -> Dictionary:
	return source_weapons_state.update_auto_target_shoot_aim_state(mount_state, weapon_state, bullet_state, can_shoot, mount_x, mount_y, target_within_result, predicted_aim)

func source_weapon_update_rotate_toward_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, can_shoot: bool, source_delta: float) -> Dictionary:
	return source_weapons_state.game_update_rotate_toward_state(self, mount_state, weapon_state, unit_state, can_shoot, source_delta)

func source_weapon_update_bullet_origin_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, mount_x: float, mount_y: float) -> Dictionary:
	return source_weapons_state.game_update_bullet_origin_state(self, mount_state, weapon_state, unit_state, mount_x, mount_y)

func source_weapon_update_always_shooting_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapons_state.update_always_shooting_state(mount_state, weapon_state)

func source_weapon_update_continuous_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_weapons_state.update_continuous_invalidation_state(mount_state, weapon_state, bullet_state)

func source_weapon_update_continuous_live_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, weapon_rotation: float) -> Dictionary:
	return source_weapons_state.game_update_continuous_live_state(self, mount_state, weapon_state, unit_state, bullet_state, source_delta, bullet_x, bullet_y, weapon_rotation)

func source_weapon_update_continuous_sound_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, runtime_state: Dictionary, bullet_x: float, bullet_y: float) -> Dictionary:
	return source_weapons_state.update_continuous_sound_state(mount_state, weapon_state, bullet_state, runtime_state, bullet_x, bullet_y)

func source_weapon_update_continuous_laser_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, shoot_angle: float) -> Dictionary:
	return source_weapons_state.game_update_continuous_laser_aim_state(self, mount_state, weapon_state, bullet_state, source_delta, bullet_x, bullet_y, shoot_angle)

func source_weapon_update_always_continuous_keepalive_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	return source_weapons_state.game_update_always_continuous_keepalive_state(self, mount_state, weapon_state, bullet_state, unit_state)

func source_weapon_update_continuous_idle_heat_sound_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float) -> Dictionary:
	return source_weapons_state.update_continuous_idle_heat_sound_state(mount_state, weapon_state, unit_state, source_delta, bullet_x, bullet_y)

func source_weapon_update_alternating_side_flip_state(mount_state: Dictionary, weapon_state: Dictionary, unit_mount_states: Array) -> Dictionary:
	return source_weapons_state.update_alternating_side_flip_state(mount_state, weapon_state, unit_mount_states)

func source_weapon_update_active_sound_loop_state(mount_state: Dictionary, weapon_state: Dictionary, runtime_state: Dictionary, can_shoot: bool, unit_id: int) -> Dictionary:
	return source_weapons_state.update_active_sound_loop_state(mount_state, weapon_state, runtime_state, can_shoot, unit_id)

func source_weapon_update_velocity_length_state(unit_state: Dictionary, source_delta: float) -> Dictionary:
	return source_weapons_state.update_velocity_length_state(unit_state, source_delta)

func source_weapon_update_shoot_gate_prefix_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, was_flipped: bool, vel_len: float) -> Dictionary:
	return source_weapons_state.update_shoot_gate_prefix_state(mount_state, weapon_state, bullet_state, can_shoot, was_flipped, vel_len)

func source_weapon_update_reload_gate_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapons_state.update_reload_gate_state(mount_state, weapon_state)

func source_weapon_update_cone_gate_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	return source_weapons_state.game_update_cone_gate_state(self, mount_state, weapon_state, unit_state)

func source_weapon_update_shoot_call_reload_state(mount_state: Dictionary, weapon_state: Dictionary, unit_id: int, bullet_x: float, bullet_y: float, shoot_angle: float, shoot_gate: bool) -> Dictionary:
	return source_weapons_state.update_shoot_call_reload_state(mount_state, weapon_state, unit_id, bullet_x, bullet_y, shoot_angle, shoot_gate)

func source_weapon_shoot_charge_start_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary, shoot_x: float, shoot_y: float, charge_rotation: float) -> Dictionary:
	return source_weapons_state.game_shoot_charge_start_state(self, mount_state, weapon_state, bullet_state, unit_state, shoot_x, shoot_y, charge_rotation)

func source_shoot_pattern_default_events(shoot_state: Dictionary) -> Array:
	return source_weapons_state.shoot_pattern_default_events(shoot_state)

func generated_shoot_pattern_default_events_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	return source_weapons_state.generated_shoot_pattern_default_events_bridge_state(shots, first_shot_delay, shot_delay)

func generated_shoot_pattern_default_events_default_bridge_state() -> Dictionary:
	return source_weapons_state.generated_shoot_pattern_default_events_default_bridge_state()

func generated_shoot_pattern_compat_dispatch_bridge_state(total_shots: int, shots: int, first_shot_delay: float, shot_delay: float, barrel_incrementer_present: bool) -> Dictionary:
	return source_weapons_state.generated_shoot_pattern_compat_dispatch_bridge_state(total_shots, shots, first_shot_delay, shot_delay, barrel_incrementer_present)

func generated_shoot_pattern_flip_bridge_state() -> Dictionary:
	return source_weapons_state.generated_shoot_pattern_flip_bridge_state()

func generated_shoot_pattern_copy_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	return source_weapons_state.generated_shoot_pattern_copy_bridge_state(shots, first_shot_delay, shot_delay)

func source_weapon_shoot_default_pattern_dispatch_state(mount_state: Dictionary, shoot_state: Dictionary) -> Dictionary:
	return source_weapons_state.shoot_default_pattern_dispatch_state(mount_state, shoot_state)

func source_weapon_bullet_initial_guard_state(unit_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return source_weapons_state.bullet_initial_guard_state(unit_state, mount_state)

func source_weapon_bullet_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float) -> Dictionary:
	return source_weapons_state.game_bullet_geometry_state(self, unit_state, mount_state, weapon_state, x_offset, y_offset, x_spread, y_spread)

func source_weapon_bullet_angle_life_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float) -> Dictionary:
	return source_weapons_state.game_bullet_angle_life_state(self, unit_state, mount_state, weapon_state, bullet_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread)

func source_weapon_bullet_shooter_state(unit_state: Dictionary, controller_state: Dictionary) -> Dictionary:
	return source_weapons_state.bullet_shooter_state(unit_state, controller_state)

func source_weapon_bullet_create_call_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, controller_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, velocity_random: float, mover: Variant) -> Dictionary:
	return source_weapons_state.game_bullet_create_call_state(self, unit_state, mount_state, weapon_state, bullet_state, controller_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, velocity_random, mover)

func source_weapon_bullet_handle_call_state(unit_state: Dictionary, mount_state: Dictionary, create_call_state: Dictionary, created_bullet: Variant) -> Dictionary:
	return source_weapons_state.bullet_handle_call_state(unit_state, mount_state, create_call_state, created_bullet)

func source_weapon_handle_bullet_continuous_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapons_state.game_handle_bullet_continuous_geometry_state(self, unit_state, mount_state, weapon_state)

func source_weapon_handle_bullet_aim_update_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_weapons_state.game_handle_bullet_aim_update_state(self, unit_state, mount_state, weapon_state, bullet_state)

func source_weapon_bullet_sound_state(create_call_state: Dictionary, weapon_state: Dictionary, sound_pitch: float) -> Dictionary:
	return source_weapons_state.bullet_sound_state(create_call_state, weapon_state, sound_pitch)

func source_weapon_bullet_effects_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	return source_weapons_state.bullet_effects_state(create_call_state, mount_state, weapon_state, bullet_state, unit_state)

func source_weapon_bullet_recoil_velocity_state(create_call_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_weapons_state.game_bullet_recoil_velocity_state(self, create_call_state, unit_state, bullet_state)

func source_weapon_bullet_shake_state(create_call_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapons_state.bullet_shake_state(create_call_state, weapon_state)

func source_weapon_bullet_mount_recoil_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return source_weapons_state.bullet_mount_recoil_state(create_call_state, mount_state)

func source_weapon_bullet_recoil_slots_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapons_state.bullet_recoil_slots_state(create_call_state, mount_state, weapon_state)

func source_weapon_bullet_heat_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return source_weapons_state.bullet_heat_state(create_call_state, mount_state)
