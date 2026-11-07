extends RefCounted
class_name SourceBuildingNavigationState

const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_block_plan_geometry_state := preload("res://src/game/SourceBlockPlanGeometryState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_building_navigation_source_text_state := preload("res://src/game/SourceBuildingNavigationSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerBuildingRegistry.gd")

static func _build_lookup(world_build_lookup: Variant, x: int, y: int) -> Variant:
	if world_build_lookup is Callable:
		return world_build_lookup.call(x, y)
	return null

static func _direction(rotation: int) -> Vector2i:
	match posmod(rotation, 4):
		0:
			return Vector2i(1, 0)
		1:
			return Vector2i(0, 1)
		2:
			return Vector2i(-1, 0)
	return Vector2i(0, -1)

static func nearby_delta_state(tile_x: int, tile_y: int, delta_x: int, delta_y: int, world_build_lookup: Variant) -> Variant:
	return _build_lookup(world_build_lookup, tile_x + delta_x, tile_y + delta_y)

static func nearby_rotation_state(tile_x: int, tile_y: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return source_block_geometry.tile_nearby_build_rotation_state(tile_x, tile_y, rotation, world_build_lookup)

static func relative_to_tile_state(tile_x: int, tile_y: int, self_block_size: int, other_x: int, other_y: int) -> int:
	return source_block_geometry.tile_absolute_relative_state(tile_x, tile_y, other_x, other_y, self_block_size)

static func relative_to_building_state(self_x: float, self_y: float, other_x: float, other_y: float) -> int:
	return source_block_geometry.tile_relative_float_state(self_x, self_y, other_x, other_y)

static func relative_to_edge_state(tile_x: int, tile_y: int, self_block_size: int, other_x: int, other_y: int, other_block_size: int) -> int:
	var facing_x := other_x
	var facing_y := other_y
	if other_block_size > 1:
		var lower: int = -int(float(other_block_size - 1) / 2.0)
		var upper: int = int(float(other_block_size) / 2.0)
		facing_x += clampi(tile_x - other_x, lower, upper)
		facing_y += clampi(tile_y - other_y, lower, upper)
	return relative_to_tile_state(tile_x, tile_y, self_block_size, facing_x, facing_y)

static func relative_to_coordinates_state(tile_x: int, tile_y: int, self_block_size: int, target_x: int, target_y: int) -> int:
	return source_block_geometry.tile_absolute_relative_state(tile_x, tile_y, target_x, target_y, self_block_size)

static func _multiblock_neighbor_state(tile_x: int, tile_y: int, block_size: int, rotation: int, direction_offset: int, world_build_lookup: Variant) -> Variant:
	var direction := _direction(rotation + direction_offset)
	var distance: int = int(float(block_size) / 2.0) + 1
	return nearby_delta_state(tile_x, tile_y, direction.x * distance, direction.y * distance, world_build_lookup)

static func front_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return _multiblock_neighbor_state(tile_x, tile_y, block_size, rotation, 0, world_build_lookup)

static func back_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return _multiblock_neighbor_state(tile_x, tile_y, block_size, rotation, 2, world_build_lookup)

static func left_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return _multiblock_neighbor_state(tile_x, tile_y, block_size, rotation, 1, world_build_lookup)

static func right_state(tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Variant:
	return _multiblock_neighbor_state(tile_x, tile_y, block_size, rotation, 3, world_build_lookup)

static func _tile_lookup(world_tile_lookup: Variant, x: int, y: int) -> Variant:
	if world_tile_lookup is Callable:
		return world_tile_lookup.call(x, y)
	return null

static func each_edge_state(tile_x: int, tile_y: int, block_size: int, block_edges_lookup: Variant, world_tile_lookup: Variant, cons_callback: Variant) -> Dictionary:
	var edges: Array = block_edges_lookup.call(block_size) if block_edges_lookup is Callable and block_edges_lookup.is_valid() else []
	var visited_tiles: Array = []
	var callback_tiles: Array = []
	for edge in edges:
		var edge_x := int(_coordinate(edge, "x"))
		var edge_y := int(_coordinate(edge, "y"))
		var other: Variant = _tile_lookup(world_tile_lookup, tile_x + edge_x, tile_y + edge_y)
		if other == null:
			continue
		visited_tiles.append(other)
		if cons_callback is Callable and cons_callback.is_valid():
			cons_callback.call(other)
			callback_tiles.append(other)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_NAVIGATION_STATE,
		"method": source_building_navigation_source_text_state.SOURCE_BUILDING_EACH_EDGE_METHOD,
		"each_edge": {"edges": edges, "visited_tiles": visited_tiles},
		"visited_tiles": visited_tiles,
		"callback_tiles": callback_tiles,
		"callback_count": callback_tiles.size(),
		"callback_called": not callback_tiles.is_empty(),
	}

static func _coordinate(value: Variant, axis: String) -> float:
	if value is Vector2 or value is Vector2i:
		return float(value.x if axis == "x" else value.y)
	if value is Dictionary:
		return float(value.get(axis, 0.0))
	if value is Object:
		var property_value: Variant = value.get(axis)
		if property_value != null:
			return float(property_value)
	return 0.0

static func _is_solid(solid_lookup: Variant, tile_value: Variant) -> bool:
	return bool(solid_lookup.call(tile_value)) if solid_lookup is Callable else false

static func find_closest_edge_state(to_position: Variant, tile_x: int, tile_y: int, block_size: int, world_tile_lookup: Variant, solid_lookup: Variant) -> Variant:
	if to_position == null:
		return null
	var best: Variant = null
	var minimum_distance_squared := 0.0
	var target_x := _coordinate(to_position, "x")
	var target_y := _coordinate(to_position, "y")
	for point in source_block_plan_geometry_state.edge_points_state(block_size):
		var other: Variant = _tile_lookup(world_tile_lookup, tile_x + point.x, tile_y + point.y)
		if other == null or _is_solid(solid_lookup, other):
			continue
		var distance_x := _coordinate(other, "x") - target_x
		var distance_y := _coordinate(other, "y") - target_y
		var distance_squared := distance_x * distance_x + distance_y * distance_y
		if best == null or distance_squared < minimum_distance_squared:
			best = other
			minimum_distance_squared = distance_squared
	return best

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(source_building_navigation_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func generated_nearby_delta_bridge_state(tile_x: int, tile_y: int, delta_x: int, delta_y: int, world_build_lookup: Variant) -> Dictionary:
	var result = _building_comp_call(source_building_navigation_source_text_state.SOURCE_BUILDING_NEARBY_DELTA_JAVA_METHOD, [tile_x, tile_y, delta_x, delta_y, world_build_lookup])
	var canonical = nearby_delta_state(tile_x, tile_y, delta_x, delta_y, world_build_lookup)
	return {"generated_owner": source_building_navigation_source_text_state.SOURCE_BUILDING_NEARBY_DELTA_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_nearby_rotation_bridge_state(tile_x: int, tile_y: int, rotation: int, world_build_lookup: Variant) -> Dictionary:
	var result = _building_comp_call(source_building_navigation_source_text_state.SOURCE_BUILDING_NEARBY_ROTATION_JAVA_METHOD, [tile_x, tile_y, rotation, world_build_lookup])
	var canonical = nearby_rotation_state(tile_x, tile_y, rotation, world_build_lookup)
	return {"generated_owner": source_building_navigation_source_text_state.SOURCE_BUILDING_NEARBY_ROTATION_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_relative_to_tile_bridge_state(tile_x: int, tile_y: int, self_block_size: int, other_x: int, other_y: int) -> Dictionary:
	var result = _building_comp_call(source_building_navigation_source_text_state.SOURCE_BUILDING_RELATIVE_TO_TILE_JAVA_METHOD, [tile_x, tile_y, self_block_size, other_x, other_y])
	var canonical = relative_to_tile_state(tile_x, tile_y, self_block_size, other_x, other_y)
	return {"generated_owner": source_building_navigation_source_text_state.SOURCE_BUILDING_RELATIVE_TO_TILE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_relative_to_building_bridge_state(self_x: float, self_y: float, other_x: float, other_y: float) -> Dictionary:
	var result = _building_comp_call(source_building_navigation_source_text_state.SOURCE_BUILDING_RELATIVE_TO_BUILDING_JAVA_METHOD, [self_x, self_y, other_x, other_y])
	var canonical = relative_to_building_state(self_x, self_y, other_x, other_y)
	return {"generated_owner": source_building_navigation_source_text_state.SOURCE_BUILDING_RELATIVE_TO_BUILDING_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_relative_to_edge_bridge_state(tile_x: int, tile_y: int, self_block_size: int, other_x: int, other_y: int, other_block_size: int) -> Dictionary:
	var result = _building_comp_call(source_building_navigation_source_text_state.SOURCE_BUILDING_RELATIVE_TO_EDGE_JAVA_METHOD, [tile_x, tile_y, self_block_size, other_x, other_y, other_block_size])
	var canonical = relative_to_edge_state(tile_x, tile_y, self_block_size, other_x, other_y, other_block_size)
	return {"generated_owner": source_building_navigation_source_text_state.SOURCE_BUILDING_RELATIVE_TO_EDGE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_relative_to_coordinates_bridge_state(tile_x: int, tile_y: int, self_block_size: int, target_x: int, target_y: int) -> Dictionary:
	var result = _building_comp_call(source_building_navigation_source_text_state.SOURCE_BUILDING_RELATIVE_TO_COORDINATES_JAVA_METHOD, [tile_x, tile_y, self_block_size, target_x, target_y])
	var canonical = relative_to_coordinates_state(tile_x, tile_y, self_block_size, target_x, target_y)
	return {"generated_owner": source_building_navigation_source_text_state.SOURCE_BUILDING_RELATIVE_TO_COORDINATES_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_find_closest_edge_bridge_state(to_position: Variant, tile_x: int, tile_y: int, block_size: int, world_tile_lookup: Variant, solid_lookup: Variant) -> Dictionary:
	var result = _building_comp_call(source_building_navigation_source_text_state.SOURCE_BUILDING_FIND_CLOSEST_EDGE_JAVA_METHOD, [to_position, solid_lookup, tile_x, tile_y, block_size, world_tile_lookup])
	var canonical = find_closest_edge_state(to_position, tile_x, tile_y, block_size, world_tile_lookup, solid_lookup)
	return {"generated_owner": source_building_navigation_source_text_state.SOURCE_BUILDING_FIND_CLOSEST_EDGE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_each_edge_bridge_state(tile_x: int, tile_y: int, block_size: int, block_edges_lookup: Variant, world_tile_lookup: Variant, cons_callback: Variant) -> Dictionary:
	var result = _building_comp_call(source_building_navigation_source_text_state.SOURCE_BUILDING_EACH_EDGE_JAVA_METHOD, [tile_x, tile_y, block_size, block_edges_lookup, world_tile_lookup, cons_callback])
	var canonical = each_edge_state(tile_x, tile_y, block_size, block_edges_lookup, world_tile_lookup, cons_callback)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"generated_owner": source_building_navigation_source_text_state.SOURCE_BUILDING_EACH_EDGE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_multiblock_neighbor_bridge_state(generated_method: String, generated_owner: String, direction_offset: int, tile_x: int, tile_y: int, block_size: int, rotation: int, world_build_lookup: Variant) -> Dictionary:
	var result = _building_comp_call(generated_method, [tile_x, tile_y, block_size, rotation, world_build_lookup])
	var canonical = _multiblock_neighbor_state(tile_x, tile_y, block_size, rotation, direction_offset, world_build_lookup)
	return {"generated_owner": generated_owner, "result": result, "canonical": canonical, "matches": result == canonical}
