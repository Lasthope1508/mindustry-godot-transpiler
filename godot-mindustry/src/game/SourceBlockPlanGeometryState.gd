extends RefCounted
class_name SourceBlockPlanGeometryState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_plan_source_text_state := preload("res://src/game/SourceBlockPlanSourceTextState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

const SOURCE_BLOCK_PLAN_COMMENT_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_COMMENT_KEY
const SOURCE_BLOCK_PLAN_CORNER_EXPR_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_CORNER_EXPR_KEY
const SOURCE_BLOCK_PLAN_CORNER_X_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_CORNER_X_KEY
const SOURCE_BLOCK_PLAN_CORNER_Y_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_CORNER_Y_KEY
const SOURCE_BLOCK_PLAN_EDGES_CALL_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_EDGES_CALL_KEY
const SOURCE_BLOCK_PLAN_EDGES_SOURCE_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_EDGES_SOURCE_KEY
const SOURCE_BLOCK_PLAN_GUARD_EXPR_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_GUARD_EXPR_KEY
const SOURCE_BLOCK_PLAN_INDEX_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_INDEX_KEY
const SOURCE_BLOCK_PLAN_IS_MULTIBLOCK_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_IS_MULTIBLOCK_KEY
const SOURCE_BLOCK_PLAN_METHOD_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_METHOD_KEY
const SOURCE_BLOCK_PLAN_NEARBY_SIDE_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_NEARBY_SIDE_KEY
const SOURCE_BLOCK_PLAN_OFFSET_EXPR_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_OFFSET_EXPR_KEY
const SOURCE_BLOCK_PLAN_OUT_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_OUT_KEY
const SOURCE_BLOCK_PLAN_PLACER_CALLS_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_PLACER_CALLS_KEY
const SOURCE_BLOCK_PLAN_PLACER_GET_EXPR_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_PLACER_GET_EXPR_KEY
const SOURCE_BLOCK_PLAN_PLACER_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_PLACER_KEY
const SOURCE_BLOCK_PLAN_ROTATION_2_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_ROTATION_2_KEY
const SOURCE_BLOCK_PLAN_RETURN_EXPR_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_RETURN_EXPR_KEY
const SOURCE_BLOCK_PLAN_SINGLE_GET_EXPR_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_SINGLE_GET_EXPR_KEY
const SOURCE_BLOCK_PLAN_SIZE_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_SIZE_KEY
const SOURCE_BLOCK_PLAN_SOURCE_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_SOURCE_KEY
const SOURCE_BLOCK_PLAN_SOURCE_OWNER_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_SOURCE_OWNER_KEY
const SOURCE_BLOCK_PLAN_SOURCE := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_SOURCE
const SOURCE_BLOCK_PLAN_SWITCH_EXPR_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_SWITCH_EXPR_KEY
const SOURCE_BLOCK_PLAN_X_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_X_KEY
const SOURCE_BLOCK_PLAN_Y_KEY := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_Y_KEY

const SOURCE_BLOCK_PLAN_NEARBY_SIDE_COMMENT := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_NEARBY_SIDE_COMMENT
const SOURCE_BLOCK_PLAN_NEARBY_SIDE_METHOD := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_NEARBY_SIDE_METHOD
const SOURCE_BLOCK_PLAN_NEARBY_SIDE_CORNER_EXPR := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_NEARBY_SIDE_CORNER_EXPR
const SOURCE_BLOCK_PLAN_NEARBY_SIDE_SWITCH_EXPR := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_NEARBY_SIDE_SWITCH_EXPR
const SOURCE_BLOCK_PLAN_GET_EDGES_METHOD := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_GET_EDGES_METHOD
const SOURCE_BLOCK_PLAN_GET_EDGES_RETURN_EXPR := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_GET_EDGES_RETURN_EXPR
const SOURCE_BLOCK_PLAN_GET_INSIDE_EDGES_METHOD := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_GET_INSIDE_EDGES_METHOD
const SOURCE_BLOCK_PLAN_GET_INSIDE_EDGES_RETURN_EXPR := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_GET_INSIDE_EDGES_RETURN_EXPR
const SOURCE_BLOCK_PLAN_ITERATE_TAKEN_COMMENT := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_ITERATE_TAKEN_COMMENT
const SOURCE_BLOCK_PLAN_ITERATE_TAKEN_METHOD := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_ITERATE_TAKEN_METHOD
const SOURCE_BLOCK_PLAN_ITERATE_TAKEN_GUARD_EXPR := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_ITERATE_TAKEN_GUARD_EXPR
const SOURCE_BLOCK_PLAN_ITERATE_TAKEN_OFFSET_EXPR := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_ITERATE_TAKEN_OFFSET_EXPR
const SOURCE_BLOCK_PLAN_ITERATE_TAKEN_PLACER_GET_EXPR := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_ITERATE_TAKEN_PLACER_GET_EXPR
const SOURCE_BLOCK_PLAN_ITERATE_TAKEN_SINGLE_GET_EXPR := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_ITERATE_TAKEN_SINGLE_GET_EXPR
const SOURCE_BLOCK_PLAN_EDGES_SOURCE := source_block_plan_source_text_state.SOURCE_BLOCK_PLAN_EDGES_SOURCE

static func nearby_side_state(x_value: int, y_value: int, rotation: int, index_value: int, size_value: int, out_value: Variant) -> Dictionary:
	var corner_offset: int = int(float(size_value - 1) / 2.0)
	var corner_x: int = x_value - corner_offset
	var corner_y: int = y_value - corner_offset
	var nearby_side: Dictionary = {SOURCE_BLOCK_PLAN_X_KEY: corner_x + size_value, SOURCE_BLOCK_PLAN_Y_KEY: corner_y + index_value}
	match rotation:
		1: nearby_side = {SOURCE_BLOCK_PLAN_X_KEY: corner_x + index_value, SOURCE_BLOCK_PLAN_Y_KEY: corner_y + size_value}
		2: nearby_side = {SOURCE_BLOCK_PLAN_X_KEY: corner_x - 1, SOURCE_BLOCK_PLAN_Y_KEY: corner_y + index_value}
		3: nearby_side = {SOURCE_BLOCK_PLAN_X_KEY: corner_x + index_value, SOURCE_BLOCK_PLAN_Y_KEY: corner_y - 1}
	return {SOURCE_BLOCK_PLAN_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_NEARBY_SIDE_STATE, SOURCE_BLOCK_PLAN_SOURCE_KEY: SOURCE_BLOCK_PLAN_SOURCE, SOURCE_BLOCK_PLAN_COMMENT_KEY: SOURCE_BLOCK_PLAN_NEARBY_SIDE_COMMENT, SOURCE_BLOCK_PLAN_METHOD_KEY: SOURCE_BLOCK_PLAN_NEARBY_SIDE_METHOD, SOURCE_BLOCK_PLAN_CORNER_EXPR_KEY: SOURCE_BLOCK_PLAN_NEARBY_SIDE_CORNER_EXPR, SOURCE_BLOCK_PLAN_SWITCH_EXPR_KEY: SOURCE_BLOCK_PLAN_NEARBY_SIDE_SWITCH_EXPR, SOURCE_BLOCK_PLAN_X_KEY: x_value, SOURCE_BLOCK_PLAN_Y_KEY: y_value, SOURCE_BLOCK_PLAN_ROTATION_2_KEY: rotation, SOURCE_BLOCK_PLAN_INDEX_KEY: index_value, SOURCE_BLOCK_PLAN_SIZE_KEY: size_value, SOURCE_BLOCK_PLAN_OUT_KEY: out_value, SOURCE_BLOCK_PLAN_CORNER_X_KEY: corner_x, SOURCE_BLOCK_PLAN_CORNER_Y_KEY: corner_y, SOURCE_BLOCK_PLAN_NEARBY_SIDE_KEY: nearby_side}

static func get_edges_state(size_value: int) -> Dictionary:
	return {SOURCE_BLOCK_PLAN_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_EDGES_STATE, SOURCE_BLOCK_PLAN_SOURCE_KEY: SOURCE_BLOCK_PLAN_SOURCE, SOURCE_BLOCK_PLAN_METHOD_KEY: SOURCE_BLOCK_PLAN_GET_EDGES_METHOD, SOURCE_BLOCK_PLAN_RETURN_EXPR_KEY: SOURCE_BLOCK_PLAN_GET_EDGES_RETURN_EXPR, SOURCE_BLOCK_PLAN_SIZE_KEY: size_value, SOURCE_BLOCK_PLAN_EDGES_SOURCE_KEY: SOURCE_BLOCK_PLAN_EDGES_SOURCE, SOURCE_BLOCK_PLAN_EDGES_CALL_KEY: "Edges.getEdges(size)"}

static func edge_points_state(size_value: int) -> Array[Vector2i]:
	var safe_size: int = maxi(size_value, 1)
	var index: int = safe_size - 1
	var bottom: int = -int(float(index) / 2.0) - 1
	var top: int = int(float(index) / 2.0 + 0.5) + 1
	var points: Array[Vector2i] = []
	for point_index in range(safe_size):
		points.append(Vector2i(bottom + 1 + point_index, bottom))
		points.append(Vector2i(bottom + 1 + point_index, top))
		points.append(Vector2i(bottom, bottom + point_index + 1))
		points.append(Vector2i(top, bottom + point_index + 1))
	# Edges.java sorts by Mathf.angle in [0, 360); first edge wins distance ties.
	points.sort_custom(func(left: Vector2i, right: Vector2i) -> bool: return source_math_state.source_vec2_angle(left.x, left.y) < source_math_state.source_vec2_angle(right.x, right.y))
	return points

static func get_inside_edges_state(size_value: int) -> Dictionary:
	return {SOURCE_BLOCK_PLAN_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_INSIDE_EDGES_STATE, SOURCE_BLOCK_PLAN_SOURCE_KEY: SOURCE_BLOCK_PLAN_SOURCE, SOURCE_BLOCK_PLAN_METHOD_KEY: SOURCE_BLOCK_PLAN_GET_INSIDE_EDGES_METHOD, SOURCE_BLOCK_PLAN_RETURN_EXPR_KEY: SOURCE_BLOCK_PLAN_GET_INSIDE_EDGES_RETURN_EXPR, SOURCE_BLOCK_PLAN_SIZE_KEY: size_value, SOURCE_BLOCK_PLAN_EDGES_SOURCE_KEY: SOURCE_BLOCK_PLAN_EDGES_SOURCE, SOURCE_BLOCK_PLAN_EDGES_CALL_KEY: "Edges.getInsideEdges(size)"}

static func iterate_taken_state(x_value: int, y_value: int, size_value: int, placer: Variant) -> Dictionary:
	var is_multiblock_value: bool = size_value > 1
	var placer_calls: Array = []
	if is_multiblock_value:
		var tile_offset: int = -int(float(size_value - 1) / 2.0)
		var offset_x: int = tile_offset
		var offset_y: int = tile_offset
		for dx in range(size_value):
			for dy in range(size_value):
				placer_calls.append({SOURCE_BLOCK_PLAN_X_KEY: dx + offset_x + x_value, SOURCE_BLOCK_PLAN_Y_KEY: dy + offset_y + y_value})
	else:
		placer_calls.append({SOURCE_BLOCK_PLAN_X_KEY: x_value, SOURCE_BLOCK_PLAN_Y_KEY: y_value})
	return {SOURCE_BLOCK_PLAN_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ITERATE_TAKEN_STATE, SOURCE_BLOCK_PLAN_SOURCE_KEY: SOURCE_BLOCK_PLAN_SOURCE, SOURCE_BLOCK_PLAN_COMMENT_KEY: SOURCE_BLOCK_PLAN_ITERATE_TAKEN_COMMENT, SOURCE_BLOCK_PLAN_METHOD_KEY: SOURCE_BLOCK_PLAN_ITERATE_TAKEN_METHOD, SOURCE_BLOCK_PLAN_GUARD_EXPR_KEY: SOURCE_BLOCK_PLAN_ITERATE_TAKEN_GUARD_EXPR, SOURCE_BLOCK_PLAN_OFFSET_EXPR_KEY: SOURCE_BLOCK_PLAN_ITERATE_TAKEN_OFFSET_EXPR, SOURCE_BLOCK_PLAN_PLACER_GET_EXPR_KEY: SOURCE_BLOCK_PLAN_ITERATE_TAKEN_PLACER_GET_EXPR, SOURCE_BLOCK_PLAN_SINGLE_GET_EXPR_KEY: SOURCE_BLOCK_PLAN_ITERATE_TAKEN_SINGLE_GET_EXPR, SOURCE_BLOCK_PLAN_X_KEY: x_value, SOURCE_BLOCK_PLAN_Y_KEY: y_value, SOURCE_BLOCK_PLAN_SIZE_KEY: size_value, SOURCE_BLOCK_PLAN_PLACER_KEY: placer, SOURCE_BLOCK_PLAN_IS_MULTIBLOCK_KEY: is_multiblock_value, SOURCE_BLOCK_PLAN_PLACER_CALLS_KEY: placer_calls}
