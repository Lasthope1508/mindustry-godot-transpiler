extends "res://src/game/SourceBuildingDrawPortBridge.gd"

const source_building_navigation_state := preload("res://src/game/SourceBuildingNavigationState.gd")
const source_building_navigation_source_text_state := preload("res://src/game/SourceBuildingNavigationSourceTextState.gd")
const source_building_heat_state := preload("res://src/game/SourceBuildingHeatState.gd")

func source_building_nearby_delta_state(tile_x: int, tile_y: int, delta_x: int, delta_y: int, world_build_lookup: Variant) -> Variant:
	return source_building_navigation_state.nearby_delta_state(tile_x, tile_y, delta_x, delta_y, world_build_lookup)

func source_building_nearby_rotation_state(tile_x: int, tile_y: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return source_building_navigation_state.nearby_rotation_state(tile_x, tile_y, rotation, world_build_lookup)

func source_building_relative_to_tile_state(tile_x: int, tile_y: int, self_block_size: int, other_x: int, other_y: int) -> int:
	return source_building_navigation_state.relative_to_tile_state(tile_x, tile_y, self_block_size, other_x, other_y)

func source_building_relative_to_building_state(self_x: float, self_y: float, other_x: float, other_y: float) -> int:
	return source_building_navigation_state.relative_to_building_state(self_x, self_y, other_x, other_y)

func source_building_relative_to_edge_state(tile_x: int, tile_y: int, self_block_size: int, other_x: int, other_y: int, other_block_size: int) -> int:
	return source_building_navigation_state.relative_to_edge_state(tile_x, tile_y, self_block_size, other_x, other_y, other_block_size)

func source_building_relative_to_coordinates_state(tile_x: int, tile_y: int, self_block_size: int, target_x: int, target_y: int) -> int:
	return source_building_navigation_state.relative_to_coordinates_state(tile_x, tile_y, self_block_size, target_x, target_y)

func source_building_front_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return source_building_navigation_state.front_state(tile_x, tile_y, block_size, rotation, world_build_lookup)

func source_building_back_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return source_building_navigation_state.back_state(tile_x, tile_y, block_size, rotation, world_build_lookup)

func source_building_left_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return source_building_navigation_state.left_state(tile_x, tile_y, block_size, rotation, world_build_lookup)

func source_building_right_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return source_building_navigation_state.right_state(tile_x, tile_y, block_size, rotation, world_build_lookup)

func source_building_find_closest_edge_state(to_position: Variant, tile_x: int, tile_y: int, block_size: int, world_tile_lookup: Variant, solid_lookup: Variant) -> Variant:
	return source_building_navigation_state.find_closest_edge_state(to_position, tile_x, tile_y, block_size, world_tile_lookup, solid_lookup)

func source_building_each_edge_state(tile_x: int, tile_y: int, block_size: int, block_edges_lookup: Variant, world_tile_lookup: Variant, cons_callback: Variant) -> Dictionary:
	return source_building_navigation_state.each_edge_state(tile_x, tile_y, block_size, block_edges_lookup, world_tile_lookup, cons_callback)

func source_building_calculate_heat_default_state(side_heat: Array, proximity: Array, team_id: int, self_x: float, self_y: float, block_size: int, tilesize: float, self_id: int, update_heat_callback: Variant = null) -> Dictionary:
	return source_building_heat_state.calculate_heat_default_state(side_heat, proximity, team_id, self_x, self_y, block_size, tilesize, self_id, update_heat_callback)

func source_building_calculate_heat_state(side_heat: Array, came_from: Array, proximity: Array, team_id: int, self_x: float, self_y: float, block_size: int, tilesize: float, self_id: int, update_heat_callback: Variant = null) -> Dictionary:
	return source_building_heat_state.calculate_heat_state(side_heat, came_from, proximity, team_id, self_x, self_y, block_size, tilesize, self_id, true, update_heat_callback)

func generated_building_comp_calculate_heat_default_bridge_state(side_heat: Array, proximity: Array, team_id: int, self_x: float, self_y: float, block_size: int, tilesize: float, self_id: int, update_heat_callback: Variant = null) -> Dictionary:
	return source_building_heat_state.generated_calculate_heat_default_bridge_state(side_heat, proximity, team_id, self_x, self_y, block_size, tilesize, self_id, update_heat_callback)

func generated_building_comp_calculate_heat_bridge_state(side_heat: Array, came_from: Array, proximity: Array, team_id: int, self_x: float, self_y: float, block_size: int, tilesize: float, self_id: int, update_heat_callback: Variant = null) -> Dictionary:
	return source_building_heat_state.generated_calculate_heat_bridge_state(side_heat, came_from, proximity, team_id, self_x, self_y, block_size, tilesize, self_id, update_heat_callback)

func generated_building_comp_nearby_delta_bridge_state(tile_x: int, tile_y: int, delta_x: int, delta_y: int, world_build_lookup: Variant) -> Dictionary:
	return source_building_navigation_state.generated_nearby_delta_bridge_state(tile_x, tile_y, delta_x, delta_y, world_build_lookup)

func generated_building_comp_nearby_rotation_bridge_state(tile_x: int, tile_y: int, rotation: int, world_build_lookup: Variant) -> Dictionary:
	return source_building_navigation_state.generated_nearby_rotation_bridge_state(tile_x, tile_y, rotation, world_build_lookup)

func generated_building_comp_relative_to_tile_bridge_state(tile_x: int, tile_y: int, self_block_size: int, other_x: int, other_y: int) -> Dictionary:
	return source_building_navigation_state.generated_relative_to_tile_bridge_state(tile_x, tile_y, self_block_size, other_x, other_y)

func generated_building_comp_relative_to_building_bridge_state(self_x: float, self_y: float, other_x: float, other_y: float) -> Dictionary:
	return source_building_navigation_state.generated_relative_to_building_bridge_state(self_x, self_y, other_x, other_y)

func generated_building_comp_relative_to_edge_bridge_state(tile_x: int, tile_y: int, self_block_size: int, other_x: int, other_y: int, other_block_size: int) -> Dictionary:
	return source_building_navigation_state.generated_relative_to_edge_bridge_state(tile_x, tile_y, self_block_size, other_x, other_y, other_block_size)

func generated_building_comp_relative_to_coordinates_bridge_state(tile_x: int, tile_y: int, self_block_size: int, target_x: int, target_y: int) -> Dictionary:
	return source_building_navigation_state.generated_relative_to_coordinates_bridge_state(tile_x, tile_y, self_block_size, target_x, target_y)

func generated_building_comp_front_bridge_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Dictionary:
	return source_building_navigation_state.generated_multiblock_neighbor_bridge_state(source_building_navigation_source_text_state.SOURCE_BUILDING_FRONT_JAVA_METHOD, source_building_navigation_source_text_state.SOURCE_BUILDING_FRONT_GENERATED_OWNER, 0, tile_x, tile_y, block_size, rotation, world_build_lookup)

func generated_building_comp_back_bridge_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Dictionary:
	return source_building_navigation_state.generated_multiblock_neighbor_bridge_state(source_building_navigation_source_text_state.SOURCE_BUILDING_BACK_JAVA_METHOD, source_building_navigation_source_text_state.SOURCE_BUILDING_BACK_GENERATED_OWNER, 2, tile_x, tile_y, block_size, rotation, world_build_lookup)

func generated_building_comp_left_bridge_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Dictionary:
	return source_building_navigation_state.generated_multiblock_neighbor_bridge_state(source_building_navigation_source_text_state.SOURCE_BUILDING_LEFT_JAVA_METHOD, source_building_navigation_source_text_state.SOURCE_BUILDING_LEFT_GENERATED_OWNER, 1, tile_x, tile_y, block_size, rotation, world_build_lookup)

func generated_building_comp_right_bridge_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Dictionary:
	return source_building_navigation_state.generated_multiblock_neighbor_bridge_state(source_building_navigation_source_text_state.SOURCE_BUILDING_RIGHT_JAVA_METHOD, source_building_navigation_source_text_state.SOURCE_BUILDING_RIGHT_GENERATED_OWNER, 3, tile_x, tile_y, block_size, rotation, world_build_lookup)

func generated_building_comp_find_closest_edge_bridge_state(to_position: Variant, tile_x: int, tile_y: int, block_size: int, world_tile_lookup: Variant, solid_lookup: Variant) -> Dictionary:
	return source_building_navigation_state.generated_find_closest_edge_bridge_state(to_position, tile_x, tile_y, block_size, world_tile_lookup, solid_lookup)

func generated_building_comp_each_edge_bridge_state(tile_x: int, tile_y: int, block_size: int, block_edges_lookup: Variant, world_tile_lookup: Variant, cons_callback: Variant) -> Dictionary:
	return source_building_navigation_state.generated_each_edge_bridge_state(tile_x, tile_y, block_size, block_edges_lookup, world_tile_lookup, cons_callback)
