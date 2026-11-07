extends "res://src/game/SourceConveyorRuntimePortBridge.gd"

const source_block_query_state := preload("res://src/game/SourceBlockQueryState.gd")
const source_block_query_basic_state_script := preload("res://src/game/SourceBlockQueryBasicState.gd")
const source_block_runtime_geometry_state := preload("res://src/game/SourceBlockRuntimeGeometryState.gd")
const source_block_lifecycle_hook_state := preload("res://src/game/SourceBlockLifecycleHookState.gd")
const source_block_query_consumer_state_script := preload("res://src/game/SourceBlockQueryConsumerState.gd")
const source_block_query_placement_state_script := preload("res://src/game/SourceBlockQueryPlacementState.gd")
const source_block_query_darkness_state_script := preload("res://src/game/SourceBlockQueryDarknessState.gd")
const source_block_query_filter_state_script := preload("res://src/game/SourceBlockQueryFilterState.gd")
const source_block_display_query_state_script := preload("res://src/game/SourceBlockDisplayQueryState.gd")

func source_block_outputs_items_state(has_items: bool) -> Dictionary:
	return source_block_query_state.outputs_items_state(has_items)

func generated_block_outputs_items_bridge_state(has_items: bool) -> Dictionary:
	return source_block_query_state.generated_block_outputs_items_bridge_state(has_items)

func source_block_can_place_on_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return source_block_query_placement_state_script.can_place_on_state(tile, team, rotation_value)

func generated_block_can_place_on_bridge_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return source_block_query_placement_state_script.generated_block_can_place_on_bridge_state(tile, team, rotation_value)

func source_block_can_break_state(tile: Variant) -> Dictionary:
	return source_block_query_placement_state_script.can_break_state(tile)

func generated_block_can_break_bridge_state(tile: Variant) -> Dictionary:
	return source_block_query_placement_state_script.generated_block_can_break_bridge_state(tile)

func source_block_rotated_output_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return source_block_query_placement_state_script.rotated_output_state(rotate_value, x_value, y_value)

func generated_block_rotated_output_bridge_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return source_block_query_placement_state_script.generated_block_rotated_output_bridge_state(rotate_value, x_value, y_value)

func source_block_rotated_output_tile_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	return source_block_query_placement_state_script.rotated_output_tile_state(rotate_value, from_x, from_y, destination)

func generated_block_rotated_output_tile_bridge_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	return source_block_query_placement_state_script.generated_block_rotated_output_tile_bridge_state(rotate_value, from_x, from_y, destination)

func source_block_synthetic_state(update_value: bool, destructible_value: bool) -> Dictionary:
	return source_block_query_darkness_state_script.synthetic_state(update_value, destructible_value)

func generated_block_synthetic_bridge_state(update_value: bool, destructible_value: bool) -> Dictionary:
	return source_block_query_darkness_state_script.generated_block_synthetic_bridge_state(update_value, destructible_value)

func source_block_check_force_dark_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return source_block_query_darkness_state_script.check_force_dark_state(force_dark_value, tile)

func generated_block_check_force_dark_bridge_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return source_block_query_darkness_state_script.generated_block_check_force_dark_bridge_state(force_dark_value, tile)

func source_block_is_darkened_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	return source_block_query_darkness_state_script.is_darkened_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)

func generated_block_is_darkened_bridge_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	return source_block_query_darkness_state_script.generated_block_is_darkened_bridge_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)

func source_block_consumes_item_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	return source_block_query_filter_state_script.consumes_item_state(item_filter, item_id, item)

func generated_block_consumes_item_bridge_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	return source_block_query_filter_state_script.generated_block_consumes_item_bridge_state(item_filter, item_id, item)

func source_block_consumes_liquid_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	return source_block_query_filter_state_script.consumes_liquid_state(liquid_filter, liquid_id, liq)

func generated_block_consumes_liquid_bridge_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	return source_block_query_filter_state_script.generated_block_consumes_liquid_bridge_state(liquid_filter, liquid_id, liq)

func source_block_has_building_state(destructible_value: bool, update_value: bool) -> Dictionary:
	return source_block_query_basic_state_script.has_building_state(destructible_value, update_value)

func generated_block_has_building_bridge_state(destructible_value: bool, update_value: bool) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_has_building_bridge_state(destructible_value, update_value)

func source_block_new_building_state(build_type_value: Variant) -> Dictionary:
	return source_block_runtime_geometry_state.new_building_state(build_type_value)

func generated_block_new_building_bridge_state(build_type_value: Variant) -> Dictionary:
	return source_block_runtime_geometry_state.generated_block_new_building_bridge_state(build_type_value)

func source_block_update_clip_radius_state(clip_size_before: float, size_value: int, tilesize_value: float, radius_in_world_units: float) -> Dictionary:
	return source_block_runtime_geometry_state.update_clip_radius_state(clip_size_before, size_value, tilesize_value, radius_in_world_units)

func generated_block_update_clip_radius_bridge_state(clip_size_before: float, size_value: int, tilesize_value: float, radius_in_world_units: float) -> Dictionary:
	return source_block_runtime_geometry_state.generated_block_update_clip_radius_bridge_state(clip_size_before, size_value, tilesize_value, radius_in_world_units)

func source_block_bounds_state(x_value: int, y_value: int, size_value: int, tilesize_value: float, offset_value: float, rect_value: Variant = null) -> Dictionary:
	return source_block_runtime_geometry_state.bounds_state(x_value, y_value, size_value, tilesize_value, offset_value, rect_value)

func generated_block_bounds_bridge_state(x_value: int, y_value: int, size_value: int, tilesize_value: float, offset_value: float, rect_value: Variant = null) -> Dictionary:
	return source_block_runtime_geometry_state.generated_block_bounds_bridge_state(x_value, y_value, size_value, tilesize_value, offset_value, rect_value)

func source_block_build_editor_config_state(table: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.build_editor_config_state(table)

func generated_block_build_editor_config_bridge_state(table: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.generated_block_build_editor_config_bridge_state(table)

func source_block_on_picked_state(tile: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.on_picked_state(tile)

func generated_block_on_picked_bridge_state(tile: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.generated_block_on_picked_bridge_state(tile)

func source_block_get_config_state(tile: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.get_config_state(tile)

func generated_block_get_config_bridge_state(tile: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.generated_block_get_config_bridge_state(tile)

func source_block_changed_state(tile: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.block_changed_state(tile)

func generated_block_changed_bridge_state(tile: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.generated_block_changed_bridge_state(tile)

func source_block_place_began_state(tile: Variant, previous: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.place_began_state(tile, previous)

func generated_block_place_began_bridge_state(tile: Variant, previous: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.generated_block_place_began_bridge_state(tile, previous)

func source_block_place_began_builder_state(tile: Variant, previous: Variant, builder: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.place_began_builder_state(tile, previous, builder)

func generated_block_place_began_builder_bridge_state(tile: Variant, previous: Variant, builder: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.generated_block_place_began_builder_bridge_state(tile, previous, builder)

func source_block_place_ended_state(tile: Variant, builder: Variant, rotation_value: int, config: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.place_ended_state(tile, builder, rotation_value, config)

func generated_block_place_ended_bridge_state(tile: Variant, builder: Variant, rotation_value: int, config: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.generated_block_place_ended_bridge_state(tile, builder, rotation_value, config)

func source_block_before_place_began_state(tile: Variant, previous: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.before_place_began_state(tile, previous)

func generated_block_before_place_began_bridge_state(tile: Variant, previous: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.generated_block_before_place_began_bridge_state(tile, previous)

func source_block_editor_picked_state(tile: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.editor_picked_state(tile)

func generated_block_editor_picked_bridge_state(tile: Variant) -> Dictionary:
	return source_block_lifecycle_hook_state.generated_block_editor_picked_bridge_state(tile)

func source_block_is_multiblock_state(size_value: int) -> Dictionary:
	return source_block_query_basic_state_script.is_multiblock_state(size_value)

func generated_block_is_multiblock_bridge_state(size_value: int) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_is_multiblock_bridge_state(size_value)

func source_block_is_floor_state(is_floor_instance: bool) -> Dictionary:
	return source_block_query_basic_state_script.is_floor_state(is_floor_instance)

func generated_block_is_floor_bridge_state(is_floor_instance: bool) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_is_floor_bridge_state(is_floor_instance)

func source_block_is_overlay_state(is_overlay_floor_instance: bool) -> Dictionary:
	return source_block_query_basic_state_script.is_overlay_state(is_overlay_floor_instance)

func generated_block_is_overlay_bridge_state(is_overlay_floor_instance: bool) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_is_overlay_bridge_state(is_overlay_floor_instance)

func source_block_as_floor_state(self_block: Variant) -> Dictionary:
	return source_block_query_basic_state_script.as_floor_state(self_block)

func generated_block_as_floor_bridge_state(self_block: Variant) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_as_floor_bridge_state(self_block)

func source_block_is_air_state(id_value: int) -> Dictionary:
	return source_block_query_basic_state_script.is_air_state(id_value)

func generated_block_is_air_bridge_state(id_value: int) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_is_air_bridge_state(id_value)

func source_block_can_be_built_state(build_visibility_value: String) -> Dictionary:
	return source_block_query_basic_state_script.can_be_built_state(build_visibility_value)

func generated_block_can_be_built_bridge_state(build_visibility_value: String) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_can_be_built_bridge_state(build_visibility_value)

func source_block_environment_buildable_state(is_on_planet_value: bool) -> Dictionary:
	return source_block_query_basic_state_script.environment_buildable_state(is_on_planet_value)

func generated_block_environment_buildable_bridge_state(is_on_planet_value: bool) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_environment_buildable_bridge_state(is_on_planet_value)

func source_block_is_static_state(cache_layer_value: String) -> Dictionary:
	return source_block_query_basic_state_script.is_static_state(cache_layer_value)

func generated_block_is_static_bridge_state(cache_layer_value: String) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_is_static_bridge_state(cache_layer_value)

func source_block_percent_solid_state(tile_exists: bool, x_value: int, y_value: int, linked_non_liquid_count: float, size_value: float) -> Dictionary:
	return source_block_display_query_state_script.percent_solid_state(tile_exists, x_value, y_value, linked_non_liquid_count, size_value)

func generated_block_percent_solid_bridge_state(tile_exists: bool, x_value: int, y_value: int, linked_non_liquid_count: float, size_value: float) -> Dictionary:
	return source_block_display_query_state_script.generated_block_percent_solid_bridge_state(tile_exists, x_value, y_value, linked_non_liquid_count, size_value)

func source_block_get_display_icon_state(tile_build_present: bool, ui_icon: Variant, build_display_icon: Variant) -> Dictionary:
	return source_block_display_query_state_script.get_display_icon_state(tile_build_present, ui_icon, build_display_icon)

func generated_block_get_display_icon_bridge_state(tile_build_present: bool, ui_icon: Variant, build_display_icon: Variant) -> Dictionary:
	return source_block_display_query_state_script.generated_block_get_display_icon_bridge_state(tile_build_present, ui_icon, build_display_icon)

func source_block_get_display_name_state(tile_build_present: bool, localized_name: String, build_display_name: String) -> Dictionary:
	return source_block_display_query_state_script.get_display_name_state(tile_build_present, localized_name, build_display_name)

func generated_block_get_display_name_bridge_state(tile_build_present: bool, localized_name: String, build_display_name: String) -> Dictionary:
	return source_block_display_query_state_script.generated_block_get_display_name_bridge_state(tile_build_present, localized_name, build_display_name)

func source_block_minimap_color_state(tile: Variant) -> Dictionary:
	return source_block_display_query_state_script.minimap_color_state(tile)

func generated_block_minimap_color_bridge_state(tile: Variant) -> Dictionary:
	return source_block_display_query_state_script.generated_block_minimap_color_bridge_state(tile)

func source_block_get_color_state(minimap_color: int, map_color: Variant, tmp_c3_set_color: Variant) -> Dictionary:
	return source_block_display_query_state_script.get_color_state(minimap_color, map_color, tmp_c3_set_color)

func generated_block_get_color_bridge_state(minimap_color: int, map_color: Variant, tmp_c3_set_color: Variant) -> Dictionary:
	return source_block_display_query_state_script.generated_block_get_color_bridge_state(minimap_color, map_color, tmp_c3_set_color)

func source_block_is_banned_state(rules_is_banned_value: bool) -> Dictionary:
	return source_block_query_basic_state_script.is_banned_state(rules_is_banned_value)

func generated_block_is_banned_bridge_state(rules_is_banned_value: bool) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_is_banned_bridge_state(rules_is_banned_value)

func source_block_supports_env_state(env_enabled: int, env_disabled: int, env_required: int, env_value: int) -> Dictionary:
	return source_block_query_basic_state_script.supports_env_state(env_enabled, env_disabled, env_required, env_value)

func generated_block_supports_env_bridge_state(env_enabled: int, env_disabled: int, env_required: int, env_value: int) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_supports_env_bridge_state(env_enabled, env_disabled, env_required, env_value)

func source_block_has_consumer_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.has_consumer_state(consume_builder_contains, cons)

func generated_block_has_consumer_bridge_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.generated_block_has_consumer_bridge_state(consume_builder_contains, cons)

func source_block_find_consumer_state(consumers_length: int, consume_builder_match: Variant, consumers_match: Variant, filter: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.find_consumer_state(consumers_length, consume_builder_match, consumers_match, filter)

func generated_block_find_consumer_bridge_state(consumers_length: int, consume_builder_match: Variant, consumers_match: Variant, filter: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.generated_block_find_consumer_bridge_state(consumers_length, consume_builder_match, consumers_match, filter)

func source_block_remove_consumer_state(consumers_length: int, cons: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.remove_consumer_state(consumers_length, cons)

func generated_block_remove_consumer_bridge_state(consumers_length: int, cons: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.generated_block_remove_consumer_bridge_state(consumers_length, cons)

func source_block_remove_consumers_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.remove_consumers_state(consume_builder_contains_power_after_remove, b)

func generated_block_remove_consumers_bridge_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.generated_block_remove_consumers_bridge_state(consume_builder_contains_power_after_remove, b)
