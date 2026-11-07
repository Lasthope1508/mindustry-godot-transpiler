extends "res://src/game/SourceTractorBeamTurretPortBridge.gd"

const source_tractor_beam_turret_build_update_tile_flow_state := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileFlowState.gd")

func source_tractor_beam_turret_build_update_tile_activation_state(activation_timer: float, time_delta: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.activation_state(activation_timer, time_delta)

func generated_tractor_beam_turret_build_update_tile_activation_bridge_state(activation_timer: float, time_delta: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_activation_bridge_state(activation_timer, time_delta)

func source_tractor_beam_turret_build_update_tile_eff_state(activation_returned_early: bool, efficiency: float, coolant_multiplier: float, delta_value: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.eff_state(activation_returned_early, efficiency, coolant_multiplier, delta_value)

func generated_tractor_beam_turret_build_update_tile_eff_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_eff_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value)

func source_tractor_beam_turret_build_update_tile_retarget_state(activation_returned_early: bool, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.retarget_state(activation_returned_early, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground)

func generated_tractor_beam_turret_build_update_tile_retarget_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_retarget_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground)

func source_tractor_beam_turret_build_update_tile_coolant_guard_state(activation_returned_early: bool, target_after: Variant, coolant_present: bool, coolant_amount: float, current_liquid: Variant) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_guard_state(activation_returned_early, target_after, coolant_present, coolant_amount, current_liquid)

func generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid)

func source_tractor_beam_turret_build_update_tile_coolant_used_state(coolant_guard: bool, liquid_amount: float, max_used: float, time_delta: float, coolant_multiplier: float, liquid_heat_capacity: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_used_state(coolant_guard, liquid_amount, max_used, time_delta, coolant_multiplier, liquid_heat_capacity)

func generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_used_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)

func source_tractor_beam_turret_build_update_tile_coolant_remove_state(coolant_guard: bool, liquid: Variant, used: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_remove_state(coolant_guard, liquid, used)

func generated_tractor_beam_turret_build_update_tile_coolant_remove_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_remove_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)

func source_tractor_beam_turret_build_update_tile_coolant_effect_state(coolant_guard: bool, used: float, chance_result: bool, x: float, y: float, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_effect_state(coolant_guard, used, chance_result, x, y, size, source_tilesize, range_x, range_y)

func generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_effect_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)

func source_tractor_beam_turret_build_update_tile_coolant_multiplier_state(coolant_guard: bool, used: float, liquid_heat_capacity: float, coolant_multiplier: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_multiplier_state(coolant_guard, used, liquid_heat_capacity, coolant_multiplier)

func generated_tractor_beam_turret_build_update_tile_coolant_multiplier_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_multiplier_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)

func source_tractor_beam_turret_build_update_tile_any_reset_state(activation_returned_early: bool, any_before: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.any_reset_state(activation_returned_early, any_before)

func generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_any_reset_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before)
