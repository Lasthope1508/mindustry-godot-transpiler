extends "res://src/game/SourceBuildSelectionRuntimePortBridge.gd"

const source_building_draw_state_script := preload("res://src/game/SourceBuildingDrawState.gd")
const source_building_draw_generated_state_script := preload("res://src/game/SourceBuildingDrawGeneratedState.gd")

func generated_building_comp_draw_status_bridge_state(enable_draw_status: bool, consumers_length: int, block_size_value: int, source_x: float, source_y: float, source_tilesize: float) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_status_bridge_state(enable_draw_status, consumers_length, block_size_value, source_x, source_y, source_tilesize)

func generated_building_comp_draw_cracks_bridge_state(draw_cracks: bool, damaged_state: bool, block_size_value: int, max_crack_size: int, health_fraction: float, crack_regions: int, position_id: int) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_cracks_bridge_state(draw_cracks, damaged_state, block_size_value, max_crack_size, health_fraction, crack_regions, position_id)

func generated_building_comp_draw_select_bridge_state(block_status: String, source_x: float, source_y: float, source_rotation: float, tile_x: int, tile_y: int, unit_activation_delay: float, state_tick: float) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_select_bridge_state(block_status, source_x, source_y, source_rotation, tile_x, tile_y, unit_activation_delay, state_tick)

func generated_building_comp_draw_item_selection_bridge_state(has_selection: bool, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, icon_small: float, selection_icon_ratio: float) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_item_selection_bridge_state(has_selection, source_x, source_y, block_size_value, source_tilesize, icon_small, selection_icon_ratio)

func generated_building_comp_draw_disabled_bridge_state(source_x: float, source_y: float) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_disabled_bridge_state(source_x, source_y)

func generated_building_comp_rotdeg_bridge_state(rotation_quadrants: int) -> Dictionary:
	return source_building_draw_generated_state_script.generated_rotdeg_bridge_state(rotation_quadrants)

func generated_building_comp_fog_radius_bridge_state(fog_radius_value: float) -> Dictionary:
	return source_building_draw_generated_state_script.generated_fog_radius_bridge_state(fog_radius_value)

func generated_building_comp_drawrot_bridge_state(block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return source_building_draw_generated_state_script.generated_drawrot_bridge_state(block_rotate, block_rotate_draw, rotation_quadrants)

func generated_building_comp_draw_bridge_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_bridge_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func generated_building_comp_draw_cached_bridge_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_cached_bridge_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func generated_building_comp_recache_bridge_state(headless: bool, building_cache_layer: Variant, tile_state: Variant) -> Dictionary:
	return source_building_draw_generated_state_script.generated_recache_bridge_state(headless, building_cache_layer, tile_state)

func generated_building_comp_payload_draw_bridge_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return source_building_draw_generated_state_script.generated_payload_draw_bridge_state(draw_cached, draw_dynamic, current_z, building_cache_layer_z, variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func generated_building_comp_draw_team_top_bridge_state(team_region_found: bool, team_region_matches_team: bool, team_color: String, source_x: float, source_y: float) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_team_top_bridge_state(team_region_found, team_region_matches_team, team_color, source_x, source_y)

func generated_building_comp_draw_light_bridge_state(has_liquids: bool, draw_liquid_light: bool, light_liquid_is_null: bool, current_liquid_color: String, current_liquid_alpha: float, light_liquid_color: String, light_liquid_alpha: float, selected_liquid_amount: float, visual_liquid: float, source_delta: float, source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_light_bridge_state(has_liquids, draw_liquid_light, light_liquid_is_null, current_liquid_color, current_liquid_alpha, light_liquid_color, light_liquid_alpha, selected_liquid_amount, visual_liquid, source_delta, source_x, source_y, block_size_value)

func generated_building_comp_draw_liquid_light_bridge_state(source_x: float, source_y: float, block_size_value: int, light_color: String, light_alpha: float, amount: float) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_liquid_light_bridge_state(source_x, source_y, block_size_value, light_color, light_alpha, amount)

func generated_building_comp_draw_team_bridge_state(team_color: String, source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_team_bridge_state(team_color, source_x, source_y, block_size_value, source_tilesize)

func generated_building_comp_draw_configure_bridge_state(source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_configure_bridge_state(source_x, source_y, block_size_value, source_tilesize)

func generated_building_comp_draw_configure_source_tilesize_default_bridge_state(source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	return source_building_draw_generated_state_script.generated_draw_configure_source_tilesize_default_bridge_state(source_x, source_y, block_size_value)

func source_building_draw_status_state(enable_draw_status: bool, consumers_length: int, block_size_value: int, source_x: float, source_y: float, source_tilesize: float) -> Dictionary:
	return source_building_draw_state_script.draw_status_state(enable_draw_status, consumers_length, block_size_value, source_x, source_y, source_tilesize)

func source_building_draw_cracks_state(draw_cracks: bool, damaged_state: bool, block_size_value: int, max_crack_size: int, health_fraction: float, crack_regions: int, position_id: int) -> Dictionary:
	return source_building_draw_state_script.draw_cracks_state(draw_cracks, damaged_state, block_size_value, max_crack_size, health_fraction, crack_regions, position_id)

func source_building_draw_select_state(block_status: String, source_x: float, source_y: float, source_rotation: float, tile_x: int, tile_y: int, unit_activation_delay: float, state_tick: float) -> Dictionary:
	return source_building_draw_state_script.draw_select_state(block_status, source_x, source_y, source_rotation, tile_x, tile_y, unit_activation_delay, state_tick)

func source_building_draw_item_selection_state(has_selection: bool, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, icon_small: float, selection_icon_ratio: float) -> Dictionary:
	return source_building_draw_state_script.draw_item_selection_state(has_selection, source_x, source_y, block_size_value, source_tilesize, icon_small, selection_icon_ratio)

func source_building_draw_disabled_state(source_x: float, source_y: float) -> Dictionary:
	return source_building_draw_state_script.draw_disabled_state(source_x, source_y)

func source_building_rotdeg_state(rotation_quadrants: int) -> float:
	return source_building_draw_state_script.rotdeg_state(rotation_quadrants)

func source_building_fog_radius_state(fog_radius_value: float) -> float:
	return source_building_draw_state_script.fog_radius_state(fog_radius_value)

func source_building_drawrot_state(block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> float:
	return source_building_draw_state_script.drawrot_state(block_rotate, block_rotate_draw, rotation_quadrants)

func source_building_draw_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return source_building_draw_state_script.game_draw_state(self, variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func source_building_draw_cached_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return source_building_draw_state_script.game_draw_cached_state(self, variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func source_building_recache_state(headless: bool, building_cache_layer: Variant, tile_state: Variant) -> Dictionary:
	return source_building_draw_state_script.recache_state(headless, building_cache_layer, tile_state)

func source_building_payload_draw_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return source_building_draw_state_script.game_payload_draw_state(self, draw_cached, draw_dynamic, current_z, building_cache_layer_z, variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func source_building_draw_team_top_state(team_region_found: bool, team_region_matches_team: bool, team_color: String, source_x: float, source_y: float) -> Dictionary:
	return source_building_draw_state_script.draw_team_top_state(team_region_found, team_region_matches_team, team_color, source_x, source_y)

func source_building_draw_liquid_light_state(source_x: float, source_y: float, block_size_value: int, light_color: String, light_alpha: float, amount: float) -> Dictionary:
	return source_building_draw_state_script.draw_liquid_light_state(source_x, source_y, block_size_value, light_color, light_alpha, amount)

func source_building_draw_light_state(has_liquids: bool, draw_liquid_light: bool, light_liquid_is_null: bool, current_liquid_color: String, current_liquid_alpha: float, light_liquid_color: String, light_liquid_alpha: float, selected_liquid_amount: float, visual_liquid: float, source_delta: float, source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	return source_building_draw_state_script.game_draw_light_state(self, has_liquids, draw_liquid_light, light_liquid_is_null, current_liquid_color, current_liquid_alpha, light_liquid_color, light_liquid_alpha, selected_liquid_amount, visual_liquid, source_delta, source_x, source_y, block_size_value)

func source_building_draw_team_state(team_color: String, source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_building_draw_state_script.draw_team_state(team_color, source_x, source_y, block_size_value, source_tilesize)

func source_building_block_half_extent(block_size_value: int, source_tilesize: float) -> float:
	return source_building_draw_state_script.block_half_extent(block_size_value, source_tilesize)

func source_building_draw_configure_state(source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_building_draw_state_script.draw_configure_state(source_x, source_y, block_size_value, source_tilesize)
