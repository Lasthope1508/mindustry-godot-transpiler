extends "res://src/game/SourceBlockRuntimePortBridge.gd"

const source_block_init_sound_state := preload("res://src/game/SourceBlockInitSoundState.gd")
const source_block_init_flags_state := preload("res://src/game/SourceBlockInitFlagsState.gd")
const source_block_init_health_state := preload("res://src/game/SourceBlockInitHealthState.gd")
const source_block_init_clip_state := preload("res://src/game/SourceBlockInitClipState.gd")
const source_block_init_placement_state := preload("res://src/game/SourceBlockInitPlacementState.gd")
const source_block_init_build_time_state := preload("res://src/game/SourceBlockInitBuildTimeState.gd")
const source_block_init_consumer_state := preload("res://src/game/SourceBlockInitConsumerState.gd")
const source_block_init_building_default_state_script := preload("res://src/game/SourceBlockInitBuildingDefaultState.gd")
const source_block_init_item_liquid_filters_state_script := preload("res://src/game/SourceBlockInitItemLiquidFiltersState.gd")
const source_block_init_set_bars_call_state_script := preload("res://src/game/SourceBlockInitSetBarsCallState.gd")
const source_block_init_stats_categories_state_script := preload("res://src/game/SourceBlockInitStatsCategoriesState.gd")
const source_block_init_logic_configurable_state_script := preload("res://src/game/SourceBlockInitLogicConfigurableState.gd")
const source_block_init_buffered_power_state_script := preload("res://src/game/SourceBlockInitBufferedPowerState.gd")
const source_block_init_sandbox_visibility_state_script := preload("res://src/game/SourceBlockInitSandboxVisibilityState.gd")

func source_block_init_building_default_state(build_type_before: Variant) -> Dictionary:
	return source_block_init_building_default_state_script.building_default_state(build_type_before)

func generated_block_init_building_default_bridge_state(build_type_before: Variant) -> Dictionary:
	return source_block_init_building_default_state_script.generated_block_init_building_default_bridge_state(build_type_before)

func source_block_init_destroy_sound_state(destroy_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.destroy_sound_state(destroy_sound_before, size_value)

func generated_block_init_destroy_sound_bridge_state(destroy_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.generated_block_init_destroy_sound_bridge_state(destroy_sound_before, size_value)

func source_block_init_place_sound_state(place_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.place_sound_state(place_sound_before, size_value)

func generated_block_init_place_sound_bridge_state(place_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.generated_block_init_place_sound_bridge_state(place_sound_before, size_value)

func source_block_init_break_sound_state(break_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.break_sound_state(break_sound_before, size_value)

func generated_block_init_break_sound_bridge_state(break_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.generated_block_init_break_sound_bridge_state(break_sound_before, size_value)

func source_block_init_custom_shadow_state(custom_shadow: bool, has_shadow_before: bool) -> Dictionary:
	return source_block_init_flags_state.custom_shadow_state(custom_shadow, has_shadow_before)

func generated_block_init_custom_shadow_bridge_state(custom_shadow: bool, has_shadow_before: bool) -> Dictionary:
	return source_block_init_flags_state.generated_custom_shadow_bridge_state(custom_shadow, has_shadow_before)

func source_block_init_under_bullets_state(under_bullets: bool, priority_before: Variant) -> Dictionary:
	return source_block_init_flags_state.under_bullets_state(under_bullets, priority_before)

func generated_block_init_under_bullets_bridge_state(under_bullets: bool, priority_before: Variant) -> Dictionary:
	return source_block_init_flags_state.generated_under_bullets_bridge_state(under_bullets, priority_before)

func source_block_init_fog_radius_flag_state(fog_radius: int, flags_before: Array) -> Dictionary:
	return source_block_init_flags_state.fog_radius_flag_state(fog_radius, flags_before)

func generated_block_init_fog_radius_flag_bridge_state(fog_radius: int, flags_before: Array) -> Dictionary:
	return source_block_init_flags_state.generated_fog_radius_flag_bridge_state(fog_radius, flags_before)

func source_block_init_sync_flag_state(sync_value: bool, flags_before: Array) -> Dictionary:
	return source_block_init_flags_state.sync_flag_state(sync_value, flags_before)

func generated_block_init_sync_flag_bridge_state(sync_value: bool, flags_before: Array) -> Dictionary:
	return source_block_init_flags_state.generated_sync_flag_bridge_state(sync_value, flags_before)

func source_block_init_health_scaled_state(health_before: int, size_value: int, scaled_health: float) -> Dictionary:
	return source_block_init_health_state.health_scaled_state(health_before, size_value, scaled_health)

func generated_block_init_health_scaled_bridge_state(health_before: int, size_value: int, scaled_health: float) -> Dictionary:
	return source_block_init_health_state.generated_health_scaled_bridge_state(health_before, size_value, scaled_health)

func source_block_init_health_requirements_scaling_state(health_before: int, size_value: int, scaled_health_before: float, requirement_health_scalings: Array) -> Dictionary:
	return source_block_init_health_state.health_requirements_scaling_state(health_before, size_value, scaled_health_before, requirement_health_scalings)

func generated_block_init_health_requirements_scaling_bridge_state(health_before: int, size_value: int, scaled_health_before: float, requirement_health_scalings: Array) -> Dictionary:
	return source_block_init_health_state.generated_health_requirements_scaling_bridge_state(health_before, size_value, scaled_health_before, requirement_health_scalings)

func source_block_init_clip_size_state(clip_size_before: float, size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_init_clip_state.clip_size_state(clip_size_before, size_value, source_tilesize)

func generated_block_init_clip_size_bridge_state(clip_size_before: float, size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_init_clip_state.generated_clip_size_bridge_state(clip_size_before, size_value, source_tilesize)

func source_block_init_light_clip_size_state(light_clip_size_before: float, clip_size: float) -> Dictionary:
	return source_block_init_clip_state.light_clip_size_state(light_clip_size_before, clip_size)

func generated_block_init_light_clip_size_bridge_state(light_clip_size_before: float, clip_size: float) -> Dictionary:
	return source_block_init_clip_state.generated_light_clip_size_bridge_state(light_clip_size_before, clip_size)

func source_block_init_liquid_light_state(has_liquids: bool, draw_liquid_light: bool, emit_light_before: bool, light_clip_size_before: float, size_value: int) -> Dictionary:
	return source_block_init_clip_state.liquid_light_state(has_liquids, draw_liquid_light, emit_light_before, light_clip_size_before, size_value)

func generated_block_init_liquid_light_bridge_state(has_liquids: bool, draw_liquid_light: bool, emit_light_before: bool, light_clip_size_before: float, size_value: int) -> Dictionary:
	return source_block_init_clip_state.generated_liquid_light_bridge_state(has_liquids, draw_liquid_light, emit_light_before, light_clip_size_before, size_value)

func source_block_init_liquid_capacity_default_state(liquid_capacity_before: float) -> Dictionary:
	return source_block_init_clip_state.liquid_capacity_default_state(liquid_capacity_before)

func generated_block_init_liquid_capacity_default_bridge_state(liquid_capacity_before: float) -> Dictionary:
	return source_block_init_clip_state.generated_liquid_capacity_default_bridge_state(liquid_capacity_before)

func source_block_init_emit_light_radius_state(emit_light: bool, light_clip_size_before: float, light_radius: float) -> Dictionary:
	return source_block_init_clip_state.emit_light_radius_state(emit_light, light_clip_size_before, light_radius)

func generated_block_init_emit_light_radius_bridge_state(emit_light: bool, light_clip_size_before: float, light_radius: float) -> Dictionary:
	return source_block_init_clip_state.generated_emit_light_radius_bridge_state(emit_light, light_clip_size_before, light_radius)

func source_block_init_accepts_items_state(block_group: Variant, category_value: Variant, accepts_items_before: bool) -> Dictionary:
	return source_block_init_placement_state.accepts_items_state(block_group, category_value, accepts_items_before)

func generated_block_init_accepts_items_bridge_state(block_group: Variant, category_value: Variant, accepts_items_before: bool) -> Dictionary:
	return source_block_init_placement_state.generated_accepts_items_bridge_state(block_group, category_value, accepts_items_before)

func source_block_init_offset_state(size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_init_placement_state.offset_state(size_value, source_tilesize)

func generated_block_init_offset_bridge_state(size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_init_placement_state.generated_offset_bridge_state(size_value, source_tilesize)

func source_block_init_build_time_requirements_state(build_time_before: float, requirement_stacks: Array) -> Dictionary:
	return source_block_init_build_time_state.requirements_state(build_time_before, requirement_stacks)

func generated_block_init_build_time_requirements_bridge_state(build_time_before: float, requirement_stacks: Array) -> Dictionary:
	return source_block_init_build_time_state.generated_requirements_bridge_state(build_time_before, requirement_stacks)

func source_block_init_build_time_default_state(build_time_before: float) -> Dictionary:
	return source_block_init_build_time_state.default_state(build_time_before)

func generated_block_init_build_time_default_bridge_state(build_time_before: float) -> Dictionary:
	return source_block_init_build_time_state.generated_default_bridge_state(build_time_before)

func source_block_init_build_time_multiplier_state(build_time_before: float, build_cost_multiplier: float) -> Dictionary:
	return source_block_init_build_time_state.multiplier_state(build_time_before, build_cost_multiplier)

func generated_block_init_build_time_multiplier_bridge_state(build_time_before: float, build_cost_multiplier: float) -> Dictionary:
	return source_block_init_build_time_state.generated_multiplier_bridge_state(build_time_before, build_cost_multiplier)

func source_block_init_consumer_arrays_state(consume_builder: Array) -> Dictionary:
	return source_block_init_consumer_state.arrays_state(consume_builder)

func generated_block_init_consumer_arrays_bridge_state(consume_builder: Array) -> Dictionary:
	return source_block_init_consumer_state.generated_consumer_arrays_bridge_state(consume_builder)

func source_block_init_item_liquid_filters_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return source_block_init_item_liquid_filters_state_script.item_liquid_filters_state(content_items_size, content_liquids_size)

func generated_block_init_item_liquid_filters_bridge_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return source_block_init_item_liquid_filters_state_script.generated_block_init_item_liquid_filters_bridge_state(content_items_size, content_liquids_size)

func source_block_init_consumer_apply_loop_state(consumers: Array) -> Dictionary:
	return source_block_init_consumer_state.apply_loop_state(consumers)

func generated_block_init_consumer_apply_loop_bridge_state(consumers: Array) -> Dictionary:
	return source_block_init_consumer_state.generated_consumer_apply_loop_bridge_state(consumers)

func source_block_init_set_bars_call_state() -> Dictionary:
	return source_block_init_set_bars_call_state_script.set_bars_call_state()

func generated_block_init_set_bars_call_bridge_state() -> Dictionary:
	return source_block_init_set_bars_call_state_script.generated_block_init_set_bars_call_bridge_state()

func source_block_init_stats_categories_state(stats_use_categories_before: bool) -> Dictionary:
	return source_block_init_stats_categories_state_script.stats_categories_state(stats_use_categories_before)

func generated_block_init_stats_categories_bridge_state(stats_use_categories_before: bool) -> Dictionary:
	return source_block_init_stats_categories_state_script.generated_block_init_stats_categories_bridge_state(stats_use_categories_before)

func source_block_init_logic_configurable_state(logic_configurable_before: bool, config_key_assignable_to_unlockable_content: bool) -> Dictionary:
	return source_block_init_logic_configurable_state_script.logic_configurable_state(logic_configurable_before, config_key_assignable_to_unlockable_content)

func generated_block_init_logic_configurable_bridge_state(logic_configurable_before: bool, config_key_assignable_to_unlockable_content: bool) -> Dictionary:
	return source_block_init_logic_configurable_state_script.generated_block_init_logic_configurable_bridge_state(logic_configurable_before, config_key_assignable_to_unlockable_content)

func source_block_init_buffered_power_state(outputs_power: bool, has_cons_power: bool, cons_power_buffered_before: bool) -> Dictionary:
	return source_block_init_buffered_power_state_script.buffered_power_state(outputs_power, has_cons_power, cons_power_buffered_before)

func generated_block_init_buffered_power_bridge_state(outputs_power: bool, has_cons_power: bool, cons_power_buffered_before: bool) -> Dictionary:
	return source_block_init_buffered_power_state_script.generated_block_init_buffered_power_bridge_state(outputs_power, has_cons_power, cons_power_buffered_before)

func source_block_init_sandbox_visibility_state(build_visibility: String, hide_details_before: bool) -> Dictionary:
	return source_block_init_sandbox_visibility_state_script.sandbox_visibility_state(build_visibility, hide_details_before)

func generated_block_init_sandbox_visibility_bridge_state(build_visibility: String, hide_details_before: bool) -> Dictionary:
	return source_block_init_sandbox_visibility_state_script.generated_block_init_sandbox_visibility_bridge_state(build_visibility, hide_details_before)
