extends "res://src/game/SourceGameBootstrapPortBridge.gd"

const source_block_get_dependencies_state := preload("res://src/game/SourceBlockGetDependenciesState.gd")
const source_block_post_init_state := preload("res://src/game/SourceBlockPostInitState.gd")
const source_block_check_content_array_capacity_state_script := preload("res://src/game/SourceBlockCheckContentArrayCapacityState.gd")
const source_block_reinitialize_consumers_state := preload("res://src/game/SourceBlockReinitializeConsumersState.gd")
const source_block_load_state := preload("res://src/game/SourceBlockLoadState.gd")
const source_block_icon_state := preload("res://src/game/SourceBlockIconState.gd")
const source_block_draw_state := preload("res://src/game/SourceBlockDrawState.gd")
const source_block_stats_bars_state := preload("res://src/game/SourceBlockStatsBarsState.gd")
const source_block_plan_state := preload("res://src/game/SourceBlockPlanState.gd")
const source_block_sense_state := preload("res://src/game/SourceBlockSenseState.gd")
const source_block_attribute_state := preload("res://src/game/SourceBlockAttributeState.gd")
const source_attributes_state := preload("res://src/game/SourceAttributesState.gd")
const source_floor_state := preload("res://src/game/SourceFloorState.gd")

func source_floor_get_display_icon_state(liquid_drop_present: bool, super_display_icon: Variant, liquid_drop_icon: Variant) -> Dictionary:
	return source_floor_state.get_display_icon_state(liquid_drop_present, super_display_icon, liquid_drop_icon)

func source_floor_get_display_name_state(liquid_drop_present: bool, super_display_name: String, liquid_drop_name: String) -> Dictionary:
	return source_floor_state.get_display_name_state(liquid_drop_present, super_display_name, liquid_drop_name)

func source_floor_draw_main_state(tile_x: int, tile_y: int, tiling_variants: int, tiling_size: int, tiling_regions: Array, autotile: bool, autotile_variants: int, autotile_variant_regions: Array, autotile_regions: Array, autotile_mid_variants: int, autotile_mid_regions: Array, autotile_same: Array, tile_bitmask_values: Array, variant_regions: Array) -> Dictionary:
	return source_floor_state.draw_main_state(tile_x, tile_y, tiling_variants, tiling_size, tiling_regions, autotile, autotile_variants, autotile_variant_regions, autotile_regions, autotile_mid_variants, autotile_mid_regions, autotile_same, tile_bitmask_values, variant_regions)

func source_floor_should_index_state(tile: Variant) -> Dictionary:
	return source_floor_state.should_index_state(tile)

func source_floor_update_render_state(tile: Variant) -> Dictionary:
	return source_floor_state.update_render_state(tile)

func source_floor_render_update_state(tile: Variant) -> Dictionary:
	return source_floor_state.render_update_state(tile)

func source_floor_has_surface_state(is_liquid: bool, solid: bool) -> Dictionary:
	return source_floor_state.has_surface_state(is_liquid, solid)

func source_floor_is_deep_state(drown_time: float) -> Dictionary:
	return source_floor_state.is_deep_state(drown_time)

func source_floor_damages_state(damage_taken: float, status_damage: float, status_present: bool) -> Dictionary:
	return source_floor_state.damages_state(damage_taken, status_damage, status_present)

func source_floor_real_blend_id_state(tile_floor_is_liquid: bool, tile_overlay_is_air: bool, tile_overlay_is_ore: bool, tile_overlay_blend_id: int, tile_floor_blend_id: int, blend_id: int) -> Dictionary:
	return source_floor_state.real_blend_id_state(tile_floor_is_liquid, tile_overlay_is_air, tile_overlay_is_ore, tile_overlay_blend_id, tile_floor_blend_id, blend_id)

func source_floor_edges_state(blend_group_edges: Variant) -> Dictionary:
	return source_floor_state.edges_state(blend_group_edges)

func source_floor_edge_state(edges_grid: Array, x: int, y: int, rx: int, ry: int) -> Dictionary:
	return source_floor_state.edge_state(edges_grid, x, y, rx, ry)

func source_floor_do_edge_state(other_real_blend_id: int, self_real_blend_id: int, edges_present: bool) -> Dictionary:
	return source_floor_state.do_edge_state(other_real_blend_id, self_real_blend_id, edges_present)

func source_floor_draw_non_layer_state(neighbors: Array, layer: Variant, tile_x: int, tile_y: int) -> Dictionary:
	return source_floor_state.draw_non_layer_state(neighbors, layer, tile_x, tile_y)

func source_floor_draw_blended_state(blenders: Array, neighbors: Array, dirs: Array, tile_floor_is_this: bool, check_id: bool) -> Dictionary:
	return source_floor_state.draw_blended_state(blenders, neighbors, dirs, tile_floor_is_this, check_id)

func source_floor_draw_edges_state(neighbors: Array, real_cache_layer: Variant, tile_floor_is_this: bool, tile_x: int, tile_y: int, self_real_blend_id: int, self_edges_present: bool) -> Dictionary:
	return source_floor_state.draw_edges_state(neighbors, real_cache_layer, tile_floor_is_this, tile_x, tile_y, self_real_blend_id, self_edges_present)

func source_floor_draw_base_state(draw_edge_in: bool, tile_overlay_is_air: bool, tile_floor_is_this: bool, is_liquid: bool, overlay_alpha: float, draw_edges_result: Dictionary = {}) -> Dictionary:
	return source_floor_state.draw_base_state(draw_edge_in, tile_overlay_is_air, tile_floor_is_this, is_liquid, overlay_alpha, draw_edges_result)

func source_floor_draw_overlay_state(overlay_is_air: bool, overlay_is_this: bool, overlay_draw_base_result: Dictionary = {}) -> Dictionary:
	return source_floor_state.draw_overlay_state(overlay_is_air, overlay_is_this, overlay_draw_base_result)

func source_floor_variant_state(x: int, y: int, max_value: int, packed_position: int, variant_region_count: int = -1) -> Dictionary:
	return source_floor_state.variant_state(x, y, max_value, packed_position, variant_region_count)

func source_floor_check_autotile_same_state(other_present: bool, tile_floor_is_this: bool, other_floor_matches: bool, other_overlay_matches: bool) -> Dictionary:
	return source_floor_state.check_autotile_same_state(other_present, tile_floor_is_this, other_floor_matches, other_overlay_matches)

func source_floor_icons_state(name_value: String, atlas_has_name: bool, icon_region: Variant) -> Dictionary:
	return source_floor_state.icons_state(name_value, atlas_has_name, icon_region)

func source_floor_floor_changed_state(tile: Variant) -> Dictionary:
	return source_floor_state.floor_changed_state(tile)
const source_attribute_state := preload("res://src/game/SourceAttributeState.gd")

func source_attribute_env_state(state_present: bool, env_value: float) -> Dictionary:
	return source_attribute_state.env_state(state_present, env_value)

func source_attribute_to_string_state(attribute: Dictionary) -> Dictionary:
	return source_attribute_state.to_string_state(attribute)

func source_attribute_get_state(all_attributes: Array, attribute_map: Dictionary, name: String) -> Dictionary:
	return source_attribute_state.get_state(all_attributes, attribute_map, name)

func source_attribute_get_or_null_state(all_attributes: Array, attribute_map: Dictionary, name: String) -> Dictionary:
	return source_attribute_state.get_or_null_state(all_attributes, attribute_map, name)

func source_attribute_exists_state(all_attributes: Array, attribute_map: Dictionary, name: String) -> Dictionary:
	return source_attribute_state.exists_state(all_attributes, attribute_map, name)

func source_attribute_add_state(all_attributes: Array, attribute_map: Dictionary, name: String) -> Dictionary:
	return source_attribute_state.add_state(all_attributes, attribute_map, name)

func source_attributes_clear_state(attribute_all: Array, arr: Array) -> Dictionary:
	return source_attributes_state.clear_state(attribute_all, arr)

func source_attributes_get_state(attribute_all: Array, arr: Array, attr_id: int) -> Dictionary:
	return source_attributes_state.get_state(attribute_all, arr, attr_id)

func source_attributes_set_state(attribute_all: Array, arr: Array, attr_id: int, value: float) -> Dictionary:
	return source_attributes_state.set_state(attribute_all, arr, attr_id, value)

func source_attributes_add_state(attribute_all: Array, arr: Array, other_arr: Array) -> Dictionary:
	return source_attributes_state.add_state(attribute_all, arr, other_arr)

func source_attributes_add_scaled_state(attribute_all: Array, arr: Array, other_arr: Array, scale: float) -> Dictionary:
	return source_attributes_state.add_state(attribute_all, arr, other_arr, scale)

func source_attributes_write_state(attribute_all: Array, arr: Array) -> Dictionary:
	return source_attributes_state.write_state(attribute_all, arr)

func source_attributes_read_state(attribute_all: Array, arr: Array, data: Dictionary) -> Dictionary:
	return source_attributes_state.read_state(attribute_all, arr, data)

func source_attributes_check_state(attribute_all: Array, arr: Array) -> Dictionary:
	return source_attributes_state.check_state(attribute_all, arr)

func source_attributes_to_string_state(attribute_all: Array, arr: Array) -> Dictionary:
	return source_attributes_state.to_string_state(attribute_all, arr)

func generated_attributes_clear_bridge_state(attribute_all: Array, arr: Array) -> Dictionary:
	return source_attributes_state.generated_clear_bridge_state(attribute_all, arr)

func generated_attributes_get_bridge_state(attribute_all: Array, arr: Array, attr_id: int) -> Dictionary:
	return source_attributes_state.generated_get_bridge_state(attribute_all, arr, attr_id)

func generated_attributes_set_bridge_state(attribute_all: Array, arr: Array, attr_id: int, value: float) -> Dictionary:
	return source_attributes_state.generated_set_bridge_state(attribute_all, arr, attr_id, value)

func generated_attributes_add_bridge_state(attribute_all: Array, arr: Array, other_arr: Array) -> Dictionary:
	return source_attributes_state.generated_add_bridge_state(attribute_all, arr, other_arr)

func generated_attributes_add_scaled_bridge_state(attribute_all: Array, arr: Array, other_arr: Array, scale: float) -> Dictionary:
	return source_attributes_state.generated_add_scaled_bridge_state(attribute_all, arr, other_arr, scale)

func generated_attributes_write_bridge_state(attribute_all: Array, arr: Array) -> Dictionary:
	return source_attributes_state.generated_write_bridge_state(attribute_all, arr)

func generated_attributes_read_bridge_state(attribute_all: Array, arr: Array, data: Dictionary) -> Dictionary:
	return source_attributes_state.generated_read_bridge_state(attribute_all, arr, data)

func generated_attributes_check_bridge_state(attribute_all: Array, arr: Array) -> Dictionary:
	return source_attributes_state.generated_check_bridge_state(attribute_all, arr)

func generated_attributes_to_string_bridge_state(attribute_all: Array, arr: Array) -> Dictionary:
	return source_attributes_state.generated_to_string_bridge_state(attribute_all, arr)

func source_block_set_stats_state(size_value: int, synthetic_value: bool, health: float, armor: float, buildable_value: bool, requirements_length: int, build_time: float, instant_transfer: bool, consumers: Array, has_liquids: bool, liquid_capacity: float, has_items: bool, item_capacity: int) -> Dictionary:
	return source_block_stats_bars_state.set_stats_state(size_value, synthetic_value, health, armor, buildable_value, requirements_length, build_time, instant_transfer, consumers, has_liquids, liquid_capacity, has_items, item_capacity)

func generated_block_set_stats_bridge_state(size_value: int, synthetic_value: bool, health: float, armor: float, buildable_value: bool, requirements_length: int, build_time: float, instant_transfer: bool, consumers: Array, has_liquids: bool, liquid_capacity: float, has_items: bool, item_capacity: int) -> Dictionary:
	return source_block_stats_bars_state.generated_block_set_stats_bridge_state(size_value, synthetic_value, health, armor, buildable_value, requirements_length, build_time, instant_transfer, consumers, has_liquids, liquid_capacity, has_items, item_capacity)

func source_block_add_bar_state(bar_name: String, bar_supplier: Variant, bar_map_before: Dictionary) -> Dictionary:
	return source_block_stats_bars_state.add_bar_state(bar_name, bar_supplier, bar_map_before)

func generated_block_add_bar_bridge_state(bar_name: String, bar_supplier: Variant, bar_map_before: Dictionary) -> Dictionary:
	return source_block_stats_bars_state.generated_block_add_bar_bridge_state(bar_name, bar_supplier, bar_map_before)

func source_block_remove_bar_state(bar_name: String, bar_map_before: Dictionary) -> Dictionary:
	return source_block_stats_bars_state.remove_bar_state(bar_name, bar_map_before)

func generated_block_remove_bar_bridge_state(bar_name: String, bar_map_before: Dictionary) -> Dictionary:
	return source_block_stats_bars_state.generated_block_remove_bar_bridge_state(bar_name, bar_map_before)

func source_block_list_bars_state(bar_map: Dictionary) -> Dictionary:
	return source_block_stats_bars_state.list_bars_state(bar_map)

func generated_block_list_bars_bridge_state(bar_map: Dictionary) -> Dictionary:
	return source_block_stats_bars_state.generated_block_list_bars_bridge_state(bar_map)

func source_block_add_liquid_bar_static_state(liquid_name: String, liquid_unlocked: bool, liquid_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant) -> Dictionary:
	return source_block_stats_bars_state.add_liquid_bar_static_state(liquid_name, liquid_unlocked, liquid_amount, liquid_capacity, localized_name, bar_color)

func generated_block_add_liquid_bar_static_bridge_state(liquid_name: String, liquid_unlocked: bool, liquid_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant) -> Dictionary:
	return source_block_stats_bars_state.generated_block_add_liquid_bar_static_bridge_state(liquid_name, liquid_unlocked, liquid_amount, liquid_capacity, localized_name, bar_color)

func source_block_add_liquid_bar_dynamic_state(current_liquid: Variant, current_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant, empty_threshold: float = 0.001) -> Dictionary:
	return source_block_stats_bars_state.add_liquid_bar_dynamic_state(current_liquid, current_amount, liquid_capacity, localized_name, bar_color, empty_threshold)

func generated_block_add_liquid_bar_dynamic_bridge_state(current_liquid: Variant, current_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant, empty_threshold: float = 0.001) -> Dictionary:
	return source_block_stats_bars_state.generated_block_add_liquid_bar_dynamic_bridge_state(current_liquid, current_amount, liquid_capacity, localized_name, bar_color, empty_threshold)

func source_block_set_bars_state(cons_power_present: bool, has_items: bool, configurable: bool, item_total: int, item_capacity: int, unit_cap_modifier: int, has_liquids: bool, static_liquid_bar_added: bool) -> Dictionary:
	return source_block_stats_bars_state.set_bars_state(cons_power_present, has_items, configurable, item_total, item_capacity, unit_cap_modifier, has_liquids, static_liquid_bar_added)

func generated_block_set_bars_bridge_state(cons_power_present: bool, has_items: bool, configurable: bool, item_total: int, item_capacity: int, unit_cap_modifier: int, has_liquids: bool, static_liquid_bar_added: bool) -> Dictionary:
	return source_block_stats_bars_state.generated_block_set_bars_bridge_state(cons_power_present, has_items, configurable, item_total, item_capacity, unit_cap_modifier, has_liquids, static_liquid_bar_added)

func source_block_after_patch_stats_bars_state(size_value: int, source_tilesize: float, content_items_size: int, content_liquids_size: int, consume_builder: Array) -> Dictionary:
	return source_block_stats_bars_state.after_patch_stats_bars_state(size_value, source_tilesize, content_items_size, content_liquids_size, consume_builder)

func generated_block_after_patch_stats_bars_bridge_state(size_value: int, source_tilesize: float, content_items_size: int, content_liquids_size: int, consume_builder: Array) -> Dictionary:
	return source_block_stats_bars_state.generated_block_after_patch_stats_bars_bridge_state(size_value, source_tilesize, content_items_size, content_liquids_size, consume_builder)

func source_block_draw_base_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	return source_block_draw_state.draw_base_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)

func generated_block_draw_base_bridge_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	return source_block_draw_state.generated_block_draw_base_bridge_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)

func source_block_draw_base_cached_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	return source_block_draw_state.draw_base_cached_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)

func generated_block_draw_base_cached_bridge_state(tile_build_present: bool, variants: int, region_value: Variant, variant_region: Variant, tile_drawx: float, tile_drawy: float) -> Dictionary:
	return source_block_draw_state.generated_block_draw_base_cached_bridge_state(tile_build_present, variants, region_value, variant_region, tile_drawx, tile_drawy)

func source_block_draw_shadow_state(tile: Variant, variants: int, custom_shadow_region: Variant, variant_shadow_region: Variant, tile_drawx: float, tile_drawy: float, shadow_alpha: float) -> Dictionary:
	return source_block_draw_state.draw_shadow_state(tile, variants, custom_shadow_region, variant_shadow_region, tile_drawx, tile_drawy, shadow_alpha)

func generated_block_draw_shadow_bridge_state(tile: Variant, variants: int, custom_shadow_region: Variant, variant_shadow_region: Variant, tile_drawx: float, tile_drawy: float, shadow_alpha: float) -> Dictionary:
	return source_block_draw_state.generated_block_draw_shadow_bridge_state(tile, variants, custom_shadow_region, variant_shadow_region, tile_drawx, tile_drawy, shadow_alpha)

func source_block_draw_environment_light_state(tile_worldx: float, tile_worldy: float, light_radius: float, light_color: Variant, light_alpha: float) -> Dictionary:
	return source_block_draw_state.draw_environment_light_state(tile_worldx, tile_worldy, light_radius, light_color, light_alpha)

func generated_block_draw_environment_light_bridge_state(tile_worldx: float, tile_worldy: float, light_radius: float, light_color: Variant, light_alpha: float) -> Dictionary:
	return source_block_draw_state.generated_block_draw_environment_light_bridge_state(tile_worldx, tile_worldy, light_radius, light_color, light_alpha)

@warning_ignore("shadowed_variable_base_class")
func source_block_draw_place_state(x_value: int, y_value: int, rotation: int, valid: bool, source_tilesize: float, offset_value: float) -> Dictionary:
	return source_block_draw_state.draw_place_state(x_value, y_value, rotation, valid, source_tilesize, offset_value)

@warning_ignore("shadowed_variable_base_class")
func generated_block_draw_place_bridge_state(x_value: int, y_value: int, rotation: int, valid: bool, source_tilesize: float, offset_value: float) -> Dictionary:
	return source_block_draw_state.generated_block_draw_place_bridge_state(x_value, y_value, rotation, valid, source_tilesize, offset_value)

@warning_ignore("shadowed_variable_base_class")
func source_block_draw_overlay_state(x_value: float, y_value: float, rotation: int) -> Dictionary:
	return source_block_draw_state.draw_overlay_state(x_value, y_value, rotation)

@warning_ignore("shadowed_variable_base_class")
func generated_block_draw_overlay_bridge_state(x_value: float, y_value: float, rotation: int) -> Dictionary:
	return source_block_draw_state.generated_block_draw_overlay_bridge_state(x_value, y_value, rotation)

func source_block_draw_side_region_state(region_width: float, region_scale: float, x_value: float, y_value: float, block_size: float, source_tilesize: float, rotation: int) -> Dictionary:
	return source_block_draw_state.draw_side_region_state(region_width, region_scale, x_value, y_value, block_size, source_tilesize, rotation)

func generated_block_draw_side_region_bridge_state(region_width: float, region_scale: float, x_value: float, y_value: float, block_size: float, source_tilesize: float, rotation: int) -> Dictionary:
	return source_block_draw_state.generated_block_draw_side_region_bridge_state(region_width, region_scale, x_value, y_value, block_size, source_tilesize, rotation)

func source_block_draw_potential_links_state(consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, tile_present: bool, x_value: int, y_value: int, source_tilesize: float, offset_value: float, block_size: float, power_links: Array, beam_links: Array) -> Dictionary:
	return source_block_draw_state.draw_potential_links_state(consumes_power, outputs_power, has_power, connected_power, tile_present, x_value, y_value, source_tilesize, offset_value, block_size, power_links, beam_links)

func generated_block_draw_potential_links_bridge_state(consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, tile_present: bool, x_value: int, y_value: int, source_tilesize: float, offset_value: float, block_size: float, power_links: Array, beam_links: Array) -> Dictionary:
	return source_block_draw_state.generated_block_draw_potential_links_bridge_state(consumes_power, outputs_power, has_power, connected_power, tile_present, x_value, y_value, source_tilesize, offset_value, block_size, power_links, beam_links)

func source_block_draw_place_text_state(pixelate: bool, text_value: String, x_value: int, y_value: int, color: Variant, draw_line: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	return source_block_draw_state.draw_place_text_state(pixelate, text_value, x_value, y_value, color, draw_line, source_tilesize, offset_value, block_size, layout_width, layout_height)

func source_block_draw_place_text_simple_state(pixelate: bool, text_value: String, x_value: int, y_value: int, valid: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	return source_block_draw_state.draw_place_text_simple_state(pixelate, text_value, x_value, y_value, valid, source_tilesize, offset_value, block_size, layout_width, layout_height)

func generated_block_draw_place_text_bridge_state(pixelate: bool, text_value: String, x_value: int, y_value: int, color: Variant, draw_line: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	return source_block_draw_state.generated_block_draw_place_text_bridge_state(pixelate, text_value, x_value, y_value, color, draw_line, source_tilesize, offset_value, block_size, layout_width, layout_height)

func generated_block_draw_place_text_simple_bridge_state(pixelate: bool, text_value: String, x_value: int, y_value: int, valid: bool, source_tilesize: float, offset_value: float, block_size: float, layout_width: float, layout_height: float) -> Dictionary:
	return source_block_draw_state.generated_block_draw_place_text_simple_bridge_state(pixelate, text_value, x_value, y_value, valid, source_tilesize, offset_value, block_size, layout_width, layout_height)

func source_block_display_shadow_state(has_shadow: bool, tile: Variant) -> Dictionary:
	return source_block_draw_state.display_shadow_state(has_shadow, tile)

func generated_block_display_shadow_bridge_state(has_shadow: bool, tile: Variant) -> Dictionary:
	return source_block_draw_state.generated_block_display_shadow_bridge_state(has_shadow, tile)

func source_block_sum_attribute_state(attr_present: bool, tile_present: bool, floating: bool, placeable_liquid: bool, linked_tile_deep_by_index: Array, linked_attribute_value_by_index: Array) -> Dictionary:
	return source_block_attribute_state.sum_attribute_state(attr_present, tile_present, floating, placeable_liquid, linked_tile_deep_by_index, linked_attribute_value_by_index)

func generated_block_sum_attribute_bridge_state(attr_present: bool, tile_present: bool, floating: bool, placeable_liquid: bool, linked_tile_deep_by_index: Array, linked_attribute_value_by_index: Array) -> Dictionary:
	return source_block_attribute_state.generated_block_sum_attribute_bridge_state(attr_present, tile_present, floating, placeable_liquid, linked_tile_deep_by_index, linked_attribute_value_by_index)

func source_block_get_dependencies_requirements_state(requirements: Array) -> Dictionary:
	return source_block_get_dependencies_state.requirements_state(requirements)

func generated_block_get_dependencies_requirements_bridge_state(requirements: Array) -> Dictionary:
	return source_block_get_dependencies_state.generated_block_get_dependencies_requirements_bridge_state(requirements)

func source_block_get_dependencies_consume_builder_optional_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return source_block_get_dependencies_state.consume_builder_optional_state(requirements, consume_builder)

func generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return source_block_get_dependencies_state.generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements, consume_builder)

func source_block_get_dependencies_consume_items_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return source_block_get_dependencies_state.consume_items_state(requirements, consume_builder)

func generated_block_get_dependencies_consume_items_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return source_block_get_dependencies_state.generated_block_get_dependencies_consume_items_bridge_state(requirements, consume_builder)

func source_block_post_init_database_tag_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	return source_block_post_init_state.database_tag_state(database_tag_before, category_name)

func generated_block_post_init_database_tag_bridge_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	return source_block_post_init_state.generated_database_tag_bridge_state(database_tag_before, category_name)

func source_block_post_init_shown_planets_state(requirements: Array, shown_planets_before: Array, content_planets: Array) -> Dictionary:
	return source_block_post_init_state.shown_planets_state(requirements, shown_planets_before, content_planets)

func generated_block_post_init_shown_planets_bridge_state(requirements: Array, shown_planets_before: Array, content_planets: Array) -> Dictionary:
	return source_block_post_init_state.generated_shown_planets_bridge_state(requirements, shown_planets_before, content_planets)

func source_block_reinitialize_consumers_arrays_state(consume_builder: Array) -> Dictionary:
	return source_block_reinitialize_consumers_state.arrays_state(consume_builder)

func generated_block_reinitialize_consumers_arrays_bridge_state(consume_builder: Array) -> Dictionary:
	return source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_arrays_bridge_state(consume_builder)

func source_block_reinitialize_consumers_item_liquid_filters_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return source_block_reinitialize_consumers_state.item_liquid_filters_state(content_items_size, content_liquids_size)

func generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(content_items_size, content_liquids_size)

func source_block_reinitialize_consumers_outputs_power_state(outputs_power: bool, has_power_before: bool) -> Dictionary:
	return source_block_reinitialize_consumers_state.outputs_power_state(outputs_power, has_power_before)

func generated_block_reinitialize_consumers_outputs_power_bridge_state(outputs_power: bool, has_power_before: bool) -> Dictionary:
	return source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_outputs_power_bridge_state(outputs_power, has_power_before)

func source_block_reinitialize_consumers_apply_loop_state(consumers: Array) -> Dictionary:
	return source_block_reinitialize_consumers_state.apply_loop_state(consumers)

func generated_block_reinitialize_consumers_apply_loop_bridge_state(consumers: Array) -> Dictionary:
	return source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_apply_loop_bridge_state(consumers)

func source_block_check_content_array_capacity_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	return source_block_check_content_array_capacity_state_script.check_content_array_capacity_state(item_filter, liquid_filter, items, liquids)

func generated_block_check_content_array_capacity_bridge_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	return source_block_check_content_array_capacity_state_script.generated_block_check_content_array_capacity_bridge_state(item_filter, liquid_filter, items, liquids)

func source_block_load_base_regions_state(name_value: String) -> Dictionary:
	return source_block_load_state.base_regions_state(name_value)

func generated_block_load_base_regions_bridge_state(name_value: String) -> Dictionary:
	return source_block_load_state.generated_block_load_base_regions_bridge_state(name_value)

func source_block_load_team_regions_state(name_value: String, team_region_found: bool, team_region: Variant, teams: Array) -> Dictionary:
	return source_block_load_state.team_regions_state(name_value, team_region_found, team_region, teams)

func generated_block_load_team_regions_bridge_state(name_value: String, team_region_found: bool, team_region: Variant, teams: Array) -> Dictionary:
	return source_block_load_state.generated_block_load_team_regions_bridge_state(name_value, team_region_found, team_region, teams)

func source_block_load_variant_regions_state(name_value: String, variants: int) -> Dictionary:
	return source_block_load_state.variant_regions_state(name_value, variants)

func generated_block_load_variant_regions_bridge_state(name_value: String, variants: int) -> Dictionary:
	return source_block_load_state.generated_block_load_variant_regions_bridge_state(name_value, variants)

func source_block_load_variant_shadow_regions_state(name_value: String, variants: int, custom_shadow: bool) -> Dictionary:
	return source_block_load_state.variant_shadow_regions_state(name_value, variants, custom_shadow)

func generated_block_load_variant_shadow_regions_bridge_state(name_value: String, variants: int, custom_shadow: bool) -> Dictionary:
	return source_block_load_state.generated_block_load_variant_shadow_regions_bridge_state(name_value, variants, custom_shadow)

func source_block_make_icon_regions_state() -> Dictionary:
	return source_block_icon_state.make_icon_regions_state()

func generated_block_make_icon_regions_bridge_state() -> Dictionary:
	return source_block_icon_state.generated_block_make_icon_regions_bridge_state()

func source_block_icons_state(name_value: String, variants: int, region_value: Variant, team_region_found: bool, minfo_mod: Variant, team_regions: Array, team_sharded_id: int) -> Dictionary:
	return source_block_icon_state.icons_state(name_value, variants, region_value, team_region_found, minfo_mod, team_regions, team_sharded_id)

func generated_block_icons_bridge_state(name_value: String, variants: int, region_value: Variant, team_region_found: bool, minfo_mod: Variant, team_regions: Array, team_sharded_id: int) -> Dictionary:
	return source_block_icon_state.generated_block_icons_bridge_state(name_value, variants, region_value, team_region_found, minfo_mod, team_regions, team_sharded_id)

func source_block_get_regions_to_outline_state(out_before: Array) -> Dictionary:
	return source_block_icon_state.get_regions_to_outline_state(out_before)

func generated_block_get_regions_to_outline_bridge_state(out_before: Array) -> Dictionary:
	return source_block_icon_state.generated_block_get_regions_to_outline_bridge_state(out_before)

func source_block_get_generated_icons_state(generated_icons_before: Variant, icons_value: Array) -> Dictionary:
	return source_block_icon_state.get_generated_icons_state(generated_icons_before, icons_value)

func generated_block_get_generated_icons_bridge_state(generated_icons_before: Variant, icons_value: Array) -> Dictionary:
	return source_block_icon_state.generated_block_get_generated_icons_bridge_state(generated_icons_before, icons_value)

func source_block_reset_generated_icons_state(generated_icons_before: Variant) -> Dictionary:
	return source_block_icon_state.reset_generated_icons_state(generated_icons_before)

func generated_block_reset_generated_icons_bridge_state(generated_icons_before: Variant) -> Dictionary:
	return source_block_icon_state.generated_block_reset_generated_icons_bridge_state(generated_icons_before)

func source_block_variant_regions_state(variant_regions_before: Variant, full_icon: Variant) -> Dictionary:
	return source_block_icon_state.variant_regions_state(variant_regions_before, full_icon)

func generated_block_variant_regions_bridge_state(variant_regions_before: Variant, full_icon: Variant) -> Dictionary:
	return source_block_icon_state.generated_block_variant_regions_bridge_state(variant_regions_before, full_icon)

func source_block_create_icons_state(super_state: Dictionary, synthetic: bool, full_icon_width: int, full_icon_height: int, full_icon_center_color: Variant, map_color_before: Variant, name_value: String, team_region_found: bool, teams: Array, team_region: Variant, team_regions_before: Array, atlas_team_overrides: Array, outline_icon: bool, outlined_icon: int, outline_radius: int, generated_icons: Array, custom_regions_to_outline: Array) -> Dictionary:
	return source_block_icon_state.create_icons_state(super_state, synthetic, full_icon_width, full_icon_height, full_icon_center_color, map_color_before, name_value, team_region_found, teams, team_region, team_regions_before, atlas_team_overrides, outline_icon, outlined_icon, outline_radius, generated_icons, custom_regions_to_outline)

func generated_block_create_icons_bridge_state(super_state: Dictionary, synthetic: bool, full_icon_width: int, full_icon_height: int, full_icon_center_color: Variant, map_color_before: Variant, name_value: String, team_region_found: bool, teams: Array, team_region: Variant, team_regions_before: Array, atlas_team_overrides: Array, outline_icon: bool, outlined_icon: int, outline_radius: int, generated_icons: Array, custom_regions_to_outline: Array) -> Dictionary:
	return source_block_icon_state.generated_block_create_icons_bridge_state(super_state, synthetic, full_icon_width, full_icon_height, full_icon_center_color, map_color_before, name_value, team_region_found, teams, team_region, team_regions_before, atlas_team_overrides, outline_icon, outlined_icon, outline_radius, generated_icons, custom_regions_to_outline)

func source_block_is_hidden_state(build_visibility_visible: bool, revealed_blocks_contains_self: bool) -> Dictionary:
	return source_block_plan_state.is_hidden_state(build_visibility_visible, revealed_blocks_contains_self)

func generated_block_is_hidden_bridge_state(build_visibility_visible: bool, revealed_blocks_contains_self: bool) -> Dictionary:
	return source_block_plan_state.generated_block_is_hidden_bridge_state(build_visibility_visible, revealed_blocks_contains_self)

func source_block_is_visible_state(is_hidden_value: bool, state_rules_editor: bool, state_rules_hide_banned_blocks: bool, is_banned_value: bool) -> Dictionary:
	return source_block_plan_state.is_visible_state(is_hidden_value, state_rules_editor, state_rules_hide_banned_blocks, is_banned_value)

func generated_block_is_visible_bridge_state(is_hidden_value: bool, state_rules_editor: bool, state_rules_hide_banned_blocks: bool, is_banned_value: bool) -> Dictionary:
	return source_block_plan_state.generated_block_is_visible_bridge_state(is_hidden_value, state_rules_editor, state_rules_hide_banned_blocks, is_banned_value)

func source_block_is_placeable_state(is_visible_value: bool, is_banned_value: bool, state_rules_editor: bool, supports_env_value: bool) -> Dictionary:
	return source_block_plan_state.is_placeable_state(is_visible_value, is_banned_value, state_rules_editor, supports_env_value)

func generated_block_is_placeable_bridge_state(is_visible_value: bool, is_banned_value: bool, state_rules_editor: bool, supports_env_value: bool) -> Dictionary:
	return source_block_plan_state.generated_block_is_placeable_bridge_state(is_visible_value, is_banned_value, state_rules_editor, supports_env_value)

func source_block_plan_rotation_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	return source_block_plan_state.plan_rotation_state(rotate_value, lock_rotation, rot)

func generated_block_plan_rotation_bridge_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	return source_block_plan_state.generated_block_plan_rotation_bridge_state(rotate_value, lock_rotation, rot)

func source_block_flip_rotation_state(rotation_before: int, x_value: bool, invert_flip: bool, rotate_value: bool, lock_rotation: bool) -> Dictionary:
	return source_block_plan_state.game_flip_rotation_state(self, rotation_before, x_value, invert_flip, rotate_value, lock_rotation)

func generated_block_flip_rotation_bridge_state(rotation_before: int, x_value: bool, invert_flip: bool, rotate_value: bool, lock_rotation: bool) -> Dictionary:
	return source_block_plan_state.generated_block_flip_rotation_bridge_state(rotation_before, x_value, invert_flip, rotate_value, lock_rotation)

func source_block_get_plan_configs_state(options_before: Array, item_configured: bool, liquid_configured: bool, content_items: Array, content_liquids: Array) -> Dictionary:
	return source_block_plan_state.get_plan_configs_state(options_before, item_configured, liquid_configured, content_items, content_liquids)

func generated_block_get_plan_configs_bridge_state(options_before: Array, item_configured: bool, liquid_configured: bool, content_items: Array, content_liquids: Array) -> Dictionary:
	return source_block_plan_state.generated_block_get_plan_configs_bridge_state(options_before, item_configured, liquid_configured, content_items, content_liquids)

func source_block_get_replacement_state(req: Variant, plans: Variant, self_block: Variant) -> Dictionary:
	return source_block_plan_state.get_replacement_state(req, plans, self_block)

func generated_block_get_replacement_bridge_state(req: Variant, plans: Variant, self_block: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_get_replacement_bridge_state(req, plans, self_block)

@warning_ignore("shadowed_variable_base_class")
func source_block_change_placement_path_diagonal_state(points: Variant, rotation: int, diagonal_on: bool) -> Dictionary:
	return source_block_plan_state.change_placement_path_diagonal_state(points, rotation, diagonal_on)

@warning_ignore("shadowed_variable_base_class")
func generated_block_change_placement_path_diagonal_bridge_state(points: Variant, rotation: int, diagonal_on: bool) -> Dictionary:
	return source_block_plan_state.generated_block_change_placement_path_diagonal_bridge_state(points, rotation, diagonal_on)

@warning_ignore("shadowed_variable_base_class")
func source_block_change_placement_path_state(points: Variant, rotation: int) -> Dictionary:
	return source_block_plan_state.change_placement_path_state(points, rotation)

@warning_ignore("shadowed_variable_base_class")
func generated_block_change_placement_path_bridge_state(points: Variant, rotation: int) -> Dictionary:
	return source_block_plan_state.generated_block_change_placement_path_bridge_state(points, rotation)

func source_block_handle_placement_line_state(plans: Variant) -> Dictionary:
	return source_block_plan_state.handle_placement_line_state(plans)

func generated_block_handle_placement_line_bridge_state(plans: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_handle_placement_line_bridge_state(plans)

func source_block_config_senseable_state(item_configured: bool, liquid_configured: bool, unlockable_content_configured: bool, block_configured: bool, unit_type_configured: bool) -> Dictionary:
	return source_block_plan_state.config_senseable_state(item_configured, liquid_configured, unlockable_content_configured, block_configured, unit_type_configured)

func generated_block_config_senseable_bridge_state(item_configured: bool, liquid_configured: bool, unlockable_content_configured: bool, block_configured: bool, unit_type_configured: bool) -> Dictionary:
	return source_block_plan_state.generated_block_config_senseable_bridge_state(item_configured, liquid_configured, unlockable_content_configured, block_configured, unit_type_configured)

func source_block_next_config_state(save_config: bool, last_config: Variant) -> Dictionary:
	return source_block_plan_state.next_config_state(save_config, last_config)

func generated_block_next_config_bridge_state(save_config: bool, last_config: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_next_config_bridge_state(save_config, last_config)

func source_block_on_new_plan_state(plan: Variant) -> Dictionary:
	return source_block_plan_state.on_new_plan_state(plan)

func generated_block_on_new_plan_bridge_state(plan: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_on_new_plan_bridge_state(plan)

func source_block_draw_plan_default_alpha_state(plan: Variant, list: Variant, valid: bool) -> Dictionary:
	return source_block_plan_state.draw_plan_default_alpha_state(plan, list, valid)

func generated_block_draw_plan_default_alpha_bridge_state(plan: Variant, list: Variant, valid: bool) -> Dictionary:
	return source_block_plan_state.generated_block_draw_plan_default_alpha_bridge_state(plan, list, valid)

func source_block_draw_plan_state(plan: Variant, list: Variant, valid: bool, alpha: float, time_absin: float) -> Dictionary:
	return source_block_plan_state.draw_plan_state(plan, list, valid, alpha, time_absin)

func generated_block_draw_plan_bridge_state(plan: Variant, list: Variant, valid: bool, alpha: float, time_absin: float) -> Dictionary:
	return source_block_plan_state.generated_block_draw_plan_bridge_state(plan, list, valid, alpha, time_absin)

func source_block_draw_other_player_plan_state(plan: Variant, list: Variant, alpha: float) -> Dictionary:
	return source_block_plan_state.draw_other_player_plan_state(plan, list, alpha)

func generated_block_draw_other_player_plan_bridge_state(plan: Variant, list: Variant, alpha: float) -> Dictionary:
	return source_block_plan_state.generated_block_draw_other_player_plan_bridge_state(plan, list, alpha)

func source_block_draw_plan_region_state(plan: Variant, list: Variant) -> Dictionary:
	return source_block_plan_state.draw_plan_region_state(plan, list)

func generated_block_draw_plan_region_bridge_state(plan: Variant, list: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_draw_plan_region_bridge_state(plan, list)

func source_block_draw_default_plan_region_state(plan: Variant, list: Variant, rotate_value: bool, rotate_draw: bool, plan_rotation: float) -> Dictionary:
	return source_block_plan_state.draw_default_plan_region_state(plan, list, rotate_value, rotate_draw, plan_rotation)

func generated_block_draw_default_plan_region_bridge_state(plan: Variant, list: Variant, rotate_value: bool, rotate_draw: bool, plan_rotation: float) -> Dictionary:
	return source_block_plan_state.generated_block_draw_default_plan_region_bridge_state(plan, list, rotate_value, rotate_draw, plan_rotation)

func source_block_find_plan_default_size_state(list: Variant, x_value: int, y_value: int, predicate: Variant) -> Dictionary:
	return source_block_plan_state.find_plan_default_size_state(list, x_value, y_value, predicate)

func generated_block_find_plan_default_size_bridge_state(list: Variant, x_value: int, y_value: int, predicate: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_find_plan_default_size_bridge_state(list, x_value, y_value, predicate)

func source_block_find_plan_state(list: Variant, x_value: int, y_value: int, size_value: int, predicate: Variant, list_is_query_eachable: bool, query_find_result: Variant) -> Dictionary:
	return source_block_plan_state.find_plan_state(list, x_value, y_value, size_value, predicate, list_is_query_eachable, query_find_result)

func generated_block_find_plan_bridge_state(list: Variant, x_value: int, y_value: int, size_value: int, predicate: Variant, list_is_query_eachable: bool, query_find_result: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_find_plan_bridge_state(list, x_value, y_value, size_value, predicate, list_is_query_eachable, query_find_result)

func source_block_get_plan_region_state(plan: Variant, list: Variant, full_icon: Variant) -> Dictionary:
	return source_block_plan_state.get_plan_region_state(plan, list, full_icon)

func generated_block_get_plan_region_bridge_state(plan: Variant, list: Variant, full_icon: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_get_plan_region_bridge_state(plan, list, full_icon)

func source_block_draw_plan_config_state(plan: Variant, list: Variant) -> Dictionary:
	return source_block_plan_state.draw_plan_config_state(plan, list)

func generated_block_draw_plan_config_bridge_state(plan: Variant, list: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_draw_plan_config_bridge_state(plan, list)

func source_block_draw_plan_config_center_state(plan: Variant, content: Variant, region: String, cross: bool, content_color: Variant) -> Dictionary:
	return source_block_plan_state.draw_plan_config_center_state(plan, content, region, cross, content_color)

func generated_block_draw_plan_config_center_bridge_state(plan: Variant, content: Variant, region: String, cross: bool, content_color: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_draw_plan_config_center_bridge_state(plan, content, region, cross, content_color)

func source_block_draw_plan_config_center_default_cross_state(plan: Variant, content: Variant, region: String) -> Dictionary:
	return source_block_plan_state.draw_plan_config_center_default_cross_state(plan, content, region)

func generated_block_draw_plan_config_center_default_cross_bridge_state(plan: Variant, content: Variant, region: String) -> Dictionary:
	return source_block_plan_state.generated_block_draw_plan_config_center_default_cross_bridge_state(plan, content, region)

func source_block_draw_plan_config_top_state(plan: Variant, list: Variant) -> Dictionary:
	return source_block_plan_state.draw_plan_config_top_state(plan, list)

func generated_block_draw_plan_config_top_bridge_state(plan: Variant, list: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_draw_plan_config_top_bridge_state(plan, list)

func source_block_plan_config_clip_size_state(clip_size: float) -> Dictionary:
	return source_block_plan_state.plan_config_clip_size_state(clip_size)

func generated_block_plan_config_clip_size_bridge_state(clip_size: float) -> Dictionary:
	return source_block_plan_state.generated_block_plan_config_clip_size_bridge_state(clip_size)

func source_block_point_config_state(config: Variant, transformer: Variant) -> Dictionary:
	return source_block_plan_state.point_config_state(config, transformer)

func generated_block_point_config_bridge_state(config: Variant, transformer: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_point_config_bridge_state(config, transformer)

func source_block_config_clear_state(cons: Variant) -> Dictionary:
	return source_block_plan_state.config_clear_state(cons)

func generated_block_config_clear_bridge_state(cons: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_config_clear_bridge_state(cons)

func source_block_config_handler_state(type_value: Variant, config_handler: Variant) -> Dictionary:
	return source_block_plan_state.config_handler_state(type_value, config_handler)

func generated_block_config_handler_bridge_state(type_value: Variant, config_handler: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_config_handler_bridge_state(type_value, config_handler)

func source_block_is_accessible_state(has_items: bool, item_capacity: int) -> Dictionary:
	return source_block_plan_state.is_accessible_state(has_items, item_capacity)

func generated_block_is_accessible_bridge_state(has_items: bool, item_capacity: int) -> Dictionary:
	return source_block_plan_state.generated_block_is_accessible_bridge_state(has_items, item_capacity)

@warning_ignore("shadowed_variable_base_class")
func source_block_nearby_side_state(x_value: int, y_value: int, rotation: int, index_value: int, size_value: int, out_value: Variant) -> Dictionary:
	return source_block_plan_state.nearby_side_state(x_value, y_value, rotation, index_value, size_value, out_value)

@warning_ignore("shadowed_variable_base_class")
func generated_block_nearby_side_bridge_state(x_value: int, y_value: int, rotation: int, index_value: int, size_value: int, out_value: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_nearby_side_bridge_state(x_value, y_value, rotation, index_value, size_value, out_value)

func source_block_get_edges_state(size_value: int) -> Dictionary:
	return source_block_plan_state.get_edges_state(size_value)

func generated_block_get_edges_bridge_state(size_value: int) -> Dictionary:
	return source_block_plan_state.generated_block_get_edges_bridge_state(size_value)

func source_block_get_inside_edges_state(size_value: int) -> Dictionary:
	return source_block_plan_state.get_inside_edges_state(size_value)

func generated_block_get_inside_edges_bridge_state(size_value: int) -> Dictionary:
	return source_block_plan_state.generated_block_get_inside_edges_bridge_state(size_value)

func source_block_iterate_taken_state(x_value: int, y_value: int, size_value: int, placer: Variant) -> Dictionary:
	return source_block_plan_state.iterate_taken_state(x_value, y_value, size_value, placer)

func generated_block_iterate_taken_bridge_state(x_value: int, y_value: int, size_value: int, placer: Variant) -> Dictionary:
	return source_block_plan_state.generated_block_iterate_taken_bridge_state(x_value, y_value, size_value, placer)

func source_block_sense_laccess_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	return source_block_sense_state.laccess_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)

func generated_block_sense_laccess_bridge_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	return source_block_sense_state.generated_block_sense_laccess_bridge_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)

func source_block_sense_content_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	return source_block_sense_state.content_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)

func generated_block_sense_content_bridge_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	return source_block_sense_state.generated_block_sense_content_bridge_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)

func source_block_sense_object_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	return source_block_sense_state.object_state(sensor, block_name, no_sensed)

func generated_block_sense_object_bridge_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	return source_block_sense_state.generated_block_sense_object_bridge_state(sensor, block_name, no_sensed)
