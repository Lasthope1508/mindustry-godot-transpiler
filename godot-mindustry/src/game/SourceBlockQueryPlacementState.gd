class_name SourceBlockQueryPlacementState
extends RefCounted

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_query_placement_source_text_state := preload("res://src/game/SourceBlockQueryPlacementSourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_CAN_PLACE_ON_METHOD := source_block_source_text_state.SOURCE_BLOCK_CAN_PLACE_ON_METHOD
const SOURCE_BLOCK_CAN_BREAK_METHOD := source_block_source_text_state.SOURCE_BLOCK_CAN_BREAK_METHOD
const SOURCE_BLOCK_ROTATED_OUTPUT_METHOD := source_block_source_text_state.SOURCE_BLOCK_ROTATED_OUTPUT_METHOD
const SOURCE_BLOCK_ROTATED_OUTPUT_TILE_METHOD := source_block_source_text_state.SOURCE_BLOCK_ROTATED_OUTPUT_TILE_METHOD
const SOURCE_BLOCK_QUERY_PLACEMENT_SOURCE := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_SOURCE
const SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_COMMENT := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_COMMENT
const SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_RETURN_EXPR := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_RETURN_EXPR
const SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_JAVA_METHOD_CAN_PLACE_ON_18 := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_JAVA_METHOD_CAN_PLACE_ON_18
const SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_GENERATED_OWNER := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_GENERATED_OWNER
const SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_COMMENT := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_COMMENT
const SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_RETURN_EXPR := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_RETURN_EXPR
const SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_JAVA_METHOD_CAN_BREAK_19 := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_JAVA_METHOD_CAN_BREAK_19
const SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_GENERATED_OWNER := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_GENERATED_OWNER
const SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_FIELD_COMMENT := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_FIELD_COMMENT
const SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_FIELD_EXPR := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_FIELD_EXPR
const SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_RETURN_EXPR := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_RETURN_EXPR
const SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_JAVA_METHOD_ROTATED_OUTPUT_20 := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_JAVA_METHOD_ROTATED_OUTPUT_20
const SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_GENERATED_OWNER := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_GENERATED_OWNER
const SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_DELEGATE_CALL := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_DELEGATE_CALL
const SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_RETURN_EXPR := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_RETURN_EXPR
const SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_JAVA_METHOD_ROTATED_OUTPUT_21 := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_JAVA_METHOD_ROTATED_OUTPUT_21
const SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_GENERATED_OWNER := source_block_query_placement_source_text_state.SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_GENERATED_OWNER

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func can_place_on_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_PLACE_ON_STATE, "source": SOURCE_BLOCK_QUERY_PLACEMENT_SOURCE, "comment": SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_COMMENT, "method": SOURCE_BLOCK_CAN_PLACE_ON_METHOD, "return_expr": SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_RETURN_EXPR, "tile": tile, "team": team, "rotation": rotation_value, "can_place": true}

static func can_break_state(tile: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_BREAK_STATE, "source": SOURCE_BLOCK_QUERY_PLACEMENT_SOURCE, "comment": SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_COMMENT, "method": SOURCE_BLOCK_CAN_BREAK_METHOD, "return_expr": SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_RETURN_EXPR, "tile": tile, "can_break": true}

static func rotated_output_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ROTATED_OUTPUT_STATE, "source": SOURCE_BLOCK_QUERY_PLACEMENT_SOURCE, "field_comment": SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_FIELD_COMMENT, "field_expr": SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_FIELD_EXPR, "method": SOURCE_BLOCK_ROTATED_OUTPUT_METHOD, "return_expr": SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_RETURN_EXPR, "rotate": rotate_value, "x": x_value, "y": y_value, "rotated_output": rotate_value}

static func rotated_output_tile_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	var base_state := rotated_output_state(rotate_value, from_x, from_y)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ROTATED_OUTPUT_TILE_STATE, "source": SOURCE_BLOCK_QUERY_PLACEMENT_SOURCE, "method": SOURCE_BLOCK_ROTATED_OUTPUT_TILE_METHOD, "delegate_call": SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_DELEGATE_CALL, "return_expr": SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_RETURN_EXPR, "rotate": rotate_value, "fromX": from_x, "fromY": from_y, "destination": destination, "base_state": base_state, "rotated_output": base_state["rotated_output"]}

# Generated Block methods delegate to these canonical placement query entrypoints.
static func generated_can_place_on_result_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return can_place_on_state(tile, team, rotation_value)

static func generated_can_break_result_state(tile: Variant) -> Dictionary:
	return can_break_state(tile)

static func generated_rotated_output_result_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return rotated_output_state(rotate_value, x_value, y_value)

static func generated_rotated_output_tile_result_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	return rotated_output_tile_state(rotate_value, from_x, from_y, destination)

static func generated_block_can_place_on_bridge_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_JAVA_METHOD_CAN_PLACE_ON_18, [tile, team, rotation_value])
	var canonical = can_place_on_state(tile, team, rotation_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_PLACE_ON_STATE, "generated_owner": SOURCE_BLOCK_QUERY_PLACEMENT_CAN_PLACE_ON_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_can_break_bridge_state(tile: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_JAVA_METHOD_CAN_BREAK_19, [tile])
	var canonical = can_break_state(tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_BREAK_STATE, "generated_owner": SOURCE_BLOCK_QUERY_PLACEMENT_CAN_BREAK_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_rotated_output_bridge_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_JAVA_METHOD_ROTATED_OUTPUT_20, [rotate_value, x_value, y_value])
	var canonical = rotated_output_state(rotate_value, x_value, y_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ROTATED_OUTPUT_STATE, "generated_owner": SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_rotated_output_tile_bridge_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_JAVA_METHOD_ROTATED_OUTPUT_21, [rotate_value, from_x, from_y, destination])
	var canonical = rotated_output_tile_state(rotate_value, from_x, from_y, destination)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ROTATED_OUTPUT_TILE_STATE, "generated_owner": SOURCE_BLOCK_QUERY_PLACEMENT_ROTATED_OUTPUT_TILE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
