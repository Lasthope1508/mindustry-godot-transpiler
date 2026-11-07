extends "res://src/game/SourceBuildingPowerPortBridge.gd"

const source_power_generator_state := preload("res://src/game/SourcePowerGeneratorState.gd")
const source_power_generator_generated_state := preload("res://src/game/SourcePowerGeneratorGeneratedState.gd")
const source_thermal_generator_state := preload("res://src/game/SourceThermalGeneratorState.gd")

func source_power_generator_get_power_production_state(enabled: bool, power_production: float, production_efficiency: float) -> Dictionary:
	return source_power_generator_state.get_power_production_state(enabled, power_production, production_efficiency)

func source_power_generator_displayed_power_production_state(power_production: float) -> Dictionary:
	return source_power_generator_state.displayed_power_production_state(power_production)

func source_power_generator_icons_state(drawer_icons: Array) -> Dictionary:
	return source_power_generator_state.icons_state(drawer_icons)

func source_power_generator_outputs_items_state() -> Dictionary:
	return source_power_generator_state.outputs_items_state()

func source_power_generator_set_stats_state(power_production: float, super_set_stats_state: Dictionary = {}) -> Dictionary:
	return source_power_generator_state.set_stats_state(power_production, super_set_stats_state)

func source_power_generator_set_bars_state(has_power: bool, outputs_power: bool, super_set_bars_state: Dictionary, power_production: float, time_scale: float, production_efficiency: float) -> Dictionary:
	return source_power_generator_state.set_bars_state(has_power, outputs_power, super_set_bars_state, power_production, time_scale, production_efficiency)

func source_power_generator_load_state(super_load_state: Dictionary = {}, drawer_load_state: Dictionary = {}) -> Dictionary:
	return source_power_generator_state.load_state(super_load_state, drawer_load_state)

func source_power_generator_draw_plan_region_state(plan: Variant, list: Variant, drawer_draw_plan_state: Dictionary = {}) -> Dictionary:
	return source_power_generator_state.draw_plan_region_state(plan, list, drawer_draw_plan_state)

func generated_power_generator_displayed_power_production_bridge_state(power_production: float) -> Dictionary:
	return source_power_generator_generated_state.generated_displayed_power_production_bridge_state(power_production)

func source_power_generator_build_serialization_state(production_efficiency: float, generate_time: float, revision: int, read_production_efficiency_value: float, read_generate_time_value: float) -> Dictionary:
	return source_power_generator_state.build_serialization_state(production_efficiency, generate_time, revision, read_production_efficiency_value, read_generate_time_value)

func source_solar_generator_update_tile_state(enabled: bool, solar_multiplier: float, light_env: float, lighting: bool, ambient_light_alpha: float) -> Dictionary:
	return source_power_generator_state.solar_update_tile_state(enabled, solar_multiplier, light_env, lighting, ambient_light_alpha)

func source_power_generator_warmup_state(enabled: bool, production_efficiency: float) -> Dictionary:
	return source_power_generator_state.warmup_state(enabled, production_efficiency)

func source_power_generator_should_explode_state(warmup_value: float, explosion_min_warmup: float) -> Dictionary:
	return source_power_generator_state.should_explode_state(warmup_value, explosion_min_warmup)

func source_power_generator_ambient_volume_state(production_efficiency: float) -> Dictionary:
	return source_power_generator_state.ambient_volume_state(production_efficiency)

func source_power_generator_create_explosion_gate_state(should_explode_value: bool) -> Dictionary:
	return source_power_generator_state.create_explosion_gate_state(should_explode_value)

func source_power_generator_create_explosion_damage_state(should_explode_value: bool, source_x: float, source_y: float, explosion_radius: int, explosion_damage: int, source_tilesize: int) -> Dictionary:
	return source_power_generator_state.create_explosion_damage_state(should_explode_value, source_x, source_y, explosion_radius, explosion_damage, source_tilesize)

func source_power_generator_create_explosion_effect_sound_state(should_explode_value: bool, source_x: float, source_y: float, explode_effect_value: String, explode_sound_value: String) -> Dictionary:
	return source_power_generator_state.create_explosion_effect_sound_state(should_explode_value, source_x, source_y, explode_effect_value, explode_sound_value)

func source_power_generator_create_explosion_puddle_loop_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int) -> Dictionary:
	return source_power_generator_state.create_explosion_puddle_loop_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles)

func source_power_generator_create_explosion_puddle_vector_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, explosion_puddle_range: float, random_angle_units: Array, random_range_units: Array) -> Dictionary:
	return source_power_generator_state.create_explosion_puddle_vector_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_range, random_angle_units, random_range_units)

func source_power_generator_create_explosion_puddle_tile_world_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, source_x: float, source_y: float, source_tilesize: int, tmp_v1_vectors: Array) -> Dictionary:
	return source_power_generator_state.create_explosion_puddle_tile_world_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, source_x, source_y, source_tilesize, tmp_v1_vectors)

func source_power_generator_create_explosion_puddle_deposit_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, explosion_puddle_amount: float, tile_world_calls: Array) -> Dictionary:
	return source_power_generator_state.create_explosion_puddle_deposit_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_amount, tile_world_calls)

func source_power_generator_create_explosion_shake_state(should_explode_value: bool, source_x: float, source_y: float, explosion_shake: float, explosion_shake_duration: float) -> Dictionary:
	return source_power_generator_state.create_explosion_shake_state(should_explode_value, source_x, source_y, explosion_shake, explosion_shake_duration)

func source_power_generator_on_destroyed_reactor_explosion_state(reactor_explosions: bool = source_power_generator_state.SOURCE_RULES_REACTOR_EXPLOSIONS_DEFAULT, create_explosion_state: Dictionary = {}) -> Dictionary:
	return source_power_generator_state.on_destroyed_reactor_explosion_state(reactor_explosions, create_explosion_state)

func source_thermal_generator_update_tile_state(sum: float, attribute_env: float) -> Dictionary:
	return source_thermal_generator_state.update_tile_state(sum, attribute_env)

func source_thermal_generator_update_tile_effect_state(source_x: float, source_y: float, production_efficiency: float, effect_chance: float, chance_delta_result: bool, range_x: float, range_y: float, generate_effect_name: String) -> Dictionary:
	return source_thermal_generator_state.update_tile_effect_state(source_x, source_y, production_efficiency, effect_chance, chance_delta_result, range_x, range_y, generate_effect_name)

func source_thermal_generator_update_tile_output_liquid_state(output_liquid_present: bool, output_liquid_liquid: String, output_liquid_amount: float, production_efficiency: float, delta_value: float, liquid_capacity: float, current_liquid_amount: float) -> Dictionary:
	return source_thermal_generator_state.update_tile_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, production_efficiency, delta_value, liquid_capacity, current_liquid_amount)

func source_thermal_generator_displayed_power_production_state(power_production: float, display_efficiency_scale: float) -> Dictionary:
	return source_thermal_generator_state.displayed_power_production_state(power_production, display_efficiency_scale)

func source_thermal_generator_init_state(output_liquid_present: bool, light_clip_size: float, size: float) -> Dictionary:
	return source_thermal_generator_state.init_state(output_liquid_present, light_clip_size, size)

func source_thermal_generator_total_progress_state(enabled: bool, sum: float, super_total_progress: float) -> Dictionary:
	return source_thermal_generator_state.total_progress_state(enabled, sum, super_total_progress)

func source_thermal_generator_after_picked_up_state(sum: float, super_after_picked_up_state: Dictionary) -> Dictionary:
	return source_thermal_generator_state.after_picked_up_state(sum, super_after_picked_up_state)

func source_thermal_generator_on_proximity_added_state(sum_attribute: float, super_on_proximity_added_state: Dictionary) -> Dictionary:
	return source_thermal_generator_state.on_proximity_added_state(sum_attribute, super_on_proximity_added_state)

func source_thermal_generator_can_place_on_state(linked_attribute_sum: float, min_efficiency: float) -> Dictionary:
	return source_thermal_generator_state.can_place_on_state(linked_attribute_sum, min_efficiency)

func source_thermal_generator_draw_light_state(source_x: float, source_y: float, source_time: float, production_efficiency: float, size: float) -> Dictionary:
	return source_thermal_generator_state.draw_light_state(source_x, source_y, source_time, production_efficiency, size)

func source_thermal_generator_set_stats_state(power_production: float, display_efficiency_scale: float, display_efficiency: bool, size: float, floating: bool, super_set_stats_state: Dictionary) -> Dictionary:
	return source_thermal_generator_state.set_stats_state(power_production, display_efficiency_scale, display_efficiency, size, floating, super_set_stats_state)

func source_thermal_generator_set_stats_output_liquid_state(output_liquid_present: bool, output_liquid_liquid: String, output_liquid_amount: float, size: float) -> Dictionary:
	return source_thermal_generator_state.set_stats_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, size)

func source_thermal_generator_draw_place_state(x: int, y: int, rotation_value: int, valid: bool, display_efficiency: bool, sum_attribute: float, display_efficiency_scale: float) -> Dictionary:
	return source_thermal_generator_state.draw_place_state(x, y, rotation_value, valid, display_efficiency, sum_attribute, display_efficiency_scale)
