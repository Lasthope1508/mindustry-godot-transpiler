extends RefCounted
class_name SourceUnitPayloadDumpSolidityGuardState

const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_unit_payload_dump_source_text_state := preload("res://src/game/SourceUnitPayloadDumpSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD := source_world_defaults.UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD
const SOURCE_UNIT_PAYLOAD_DUMP_METHOD := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_METHOD
const SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_TIME_ASSIGN_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_TIME_ASSIGN_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_REGION_ASSIGN_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_REGION_ASSIGN_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_ARC_VEC2_SOURCE := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_ARC_VEC2_SOURCE
const SOURCE_UNIT_PAYLOAD_DUMP_WORLD_SOURCE := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_WORLD_SOURCE
const SOURCE_UNIT_PAYLOAD_DUMP_VARS_SOURCE := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_VARS_SOURCE
const SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_COMMENT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_COMMENT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_ASSIGN_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_ASSIGN_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_GUARD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_TRNS_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_TRNS_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_VEC2_ROTATE_RAD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_VEC2_ROTATE_RAD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD
const SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN
const SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_CALL_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_CALL_EXPR

static func trns_vec_state(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	var result := source_math_state.source_angles_trns_vec(angle_degrees, x_value, y_value)
	result["source"] = SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR
	result["vec2RotateSource"] = SOURCE_UNIT_PAYLOAD_DUMP_VEC2_ROTATE_RAD_EXPR
	return result

static func solidity_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool) -> Dictionary:
	var can_create_evaluated: bool = not unit_type_null
	var can_create_guard: bool = can_create_evaluated and not units_can_create
	var before_solid_returned: bool = unit_type_null or can_create_guard
	var solid_evaluated: bool = not before_solid_returned
	var solid_present_guard: bool = solid_evaluated and solid_present
	var solid_lookahead: float = SOURCE_UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD
	var trns_vec: Dictionary = trns_vec_state(unit_rotation, solid_lookahead, 0.0) if solid_present_guard else {"x": 0.0, "y": 0.0}
	var tx: int = int(round((unit_x + float(trns_vec.get("x", 0.0))) / source_world_defaults.TILESIZE)) if solid_present_guard else 0
	var ty: int = int(round((unit_y + float(trns_vec.get("y", 0.0))) / source_world_defaults.TILESIZE)) if solid_present_guard else 0
	var solid_solid_evaluated: bool = solid_present_guard
	var solid_guard: bool = solid_solid_evaluated and solid_solid
	var returned: bool = before_solid_returned or solid_guard
	var dump_result: Variant = null
	if unit_type_null:
		dump_result = true
	elif can_create_guard:
		dump_result = false
	elif solid_guard:
		dump_result = false
	var overlayTime_after: float = 1.0 if can_create_guard else 0.0
	var overlayRegion_after: Variant = null
	var solid_call: Dictionary = {}
	if solid_solid_evaluated:
		solid_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_CALL_EXPR, "tx": tx, "ty": ty, "result": solid_solid}
	var deferred_remaining_dump: bool = not returned
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_GUARD_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"arc_vec2_source": SOURCE_UNIT_PAYLOAD_DUMP_ARC_VEC2_SOURCE,
		"world_source": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_SOURCE,
		"vars_source": SOURCE_UNIT_PAYLOAD_DUMP_VARS_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"field_overlay_time_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR,
		"field_overlay_region_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_DUMP_METHOD,
		"todo_comment_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"type_null_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR,
		"can_create_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_EXPR,
		"overlay_time_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_TIME_ASSIGN_EXPR,
		"overlay_region_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_REGION_ASSIGN_EXPR,
		"solidity_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_COMMENT_EXPR,
		"solid_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_ASSIGN_EXPR,
		"solid_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_GUARD_EXPR,
		"trns_expr": SOURCE_UNIT_PAYLOAD_DUMP_TRNS_EXPR,
		"vec2_trns_amount_expr": SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_EXPR,
		"vec2_trns_amount_return_expr": SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR,
		"tile_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR,
		"world_to_tile_method": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD,
		"world_to_tile_return": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN,
		"vars_tilesize_field": SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD,
		"solid_block_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR,
		"solid_solid_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR,
		"return_false_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR,
		"unit_type_null": unit_type_null,
		"units_can_create": units_can_create,
		"solid_present": solid_present,
		"unit_rotation": unit_rotation,
		"unit_x": unit_x,
		"unit_y": unit_y,
		"solid_solid": solid_solid,
		"can_create_evaluated": can_create_evaluated,
		"can_create_guard": can_create_guard,
		"before_solid_returned": before_solid_returned,
		"solid_evaluated": solid_evaluated,
		"solid_present_guard": solid_present_guard,
		"trns_vec": trns_vec,
		"tx": tx,
		"ty": ty,
		"solid_solid_evaluated": solid_solid_evaluated,
		"solid_call": solid_call,
		"solid_guard": solid_guard,
		"returned": returned,
		"dump": dump_result,
		"overlayTime_after": overlayTime_after,
		"overlayRegion_after": overlayRegion_after,
		"deferred_remaining_dump": deferred_remaining_dump,
	}
