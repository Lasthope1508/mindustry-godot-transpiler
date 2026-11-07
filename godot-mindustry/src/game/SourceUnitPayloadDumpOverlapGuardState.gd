extends RefCounted
class_name SourceUnitPayloadDumpOverlapGuardState

const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_unit_payload_dump_source_text_state := preload("res://src/game/SourceUnitPayloadDumpSourceTextState.gd")
const source_unit_payload_dump_solidity_guard_state := preload("res://src/game/SourceUnitPayloadDumpSolidityGuardState.gd")
const source_unit_payload_dump_spawn_state := preload("res://src/game/SourceUnitPayloadDumpSpawnState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

const SOURCE_UNIT_PAYLOAD_OVERLAP_RADIUS_MULTIPLIER := source_world_defaults.UNIT_PAYLOAD_OVERLAP_RADIUS_MULTIPLIER
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
const SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD
const SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN
const SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_COMMENT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_COMMENT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_TYPE_FLYING_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_TYPE_FLYING_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_PHYSIC_SIZE_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_PHYSIC_SIZE_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_RADIUS_MULTIPLIER_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_RADIUS_MULTIPLIER_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_IS_GROUNDED_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_IS_GROUNDED_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_ALLOW_LEG_STEP_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_ALLOW_LEG_STEP_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_CLIENT_DUMPING_COMMENT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_CLIENT_DUMPING_COMMENT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_NET_CLIENT_GUARD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_NET_CLIENT_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_VARS_NET_FIELD := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_VARS_NET_FIELD
const SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR := source_unit_payload_dump_spawn_state.SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR

static func overlap_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int) -> Dictionary:
	var result := source_unit_payload_dump_solidity_guard_state.solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var canonical_overlap_fields := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_STATE,
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
		"overlap_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_COMMENT_EXPR,
		"overlap_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_EXPR,
		"unit_type_flying_expr": SOURCE_UNIT_PAYLOAD_DUMP_UNIT_TYPE_FLYING_EXPR,
		"units_count_expr": SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR,
		"physic_size_expr": SOURCE_UNIT_PAYLOAD_DUMP_PHYSIC_SIZE_EXPR,
		"radius_multiplier_expr": SOURCE_UNIT_PAYLOAD_DUMP_RADIUS_MULTIPLIER_EXPR,
		"predicate_is_grounded_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_IS_GROUNDED_EXPR,
		"predicate_allow_leg_step_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_ALLOW_LEG_STEP_EXPR,
		"return_false_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR,
		"client_dumping_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_CLIENT_DUMPING_COMMENT_EXPR
	}
	var before_solid_returned: bool = bool(result.get("before_solid_returned", false))
	var solid_guard: bool = bool(result.get("solid_guard", false))
	var before_overlap_returned: bool = before_solid_returned or solid_guard
	var overlap_evaluated: bool = not before_overlap_returned
	var units_count_evaluated: bool = overlap_evaluated and not unit_type_flying
	var overlap_radius: float = unit_physic_size * SOURCE_UNIT_PAYLOAD_OVERLAP_RADIUS_MULTIPLIER if units_count_evaluated else 0.0
	var overlap_guard: bool = units_count_evaluated and units_count > 0
	var dump_result: Variant = result.get("dump", null)
	if overlap_guard:
		dump_result = false
	var units_count_call: Dictionary = {}
	if units_count_evaluated:
		units_count_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR, "x": unit_x, "y": unit_y, "radius": overlap_radius, "result": units_count}
	var returned: bool = before_overlap_returned or overlap_guard
	var deferred_remaining_dump: bool = not returned
	var overlap_runtime_fields := {
		"unit_type_flying": unit_type_flying,
		"unit_physic_size": unit_physic_size,
		"units_count": units_count,
		"before_overlap_returned": before_overlap_returned,
		"overlap_evaluated": overlap_evaluated,
		"units_count_evaluated": units_count_evaluated,
		"units_count_call": units_count_call,
		"overlap_radius": overlap_radius,
		"overlap_guard": overlap_guard,
		"returned": returned,
		"dump": dump_result,
		"deferred_remaining_dump": deferred_remaining_dump,
	}
	for key in canonical_overlap_fields.keys():
		result[key] = canonical_overlap_fields[key]
	for key in overlap_runtime_fields.keys():
		result[key] = overlap_runtime_fields[key]
	return result

static func no_client_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool) -> Dictionary:
	var result := overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var canonical_no_client_fields := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_NO_CLIENT_GUARD_STATE,
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
		"overlap_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_COMMENT_EXPR,
		"overlap_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_EXPR,
		"unit_type_flying_expr": SOURCE_UNIT_PAYLOAD_DUMP_UNIT_TYPE_FLYING_EXPR,
		"units_count_expr": SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR,
		"physic_size_expr": SOURCE_UNIT_PAYLOAD_DUMP_PHYSIC_SIZE_EXPR,
		"radius_multiplier_expr": SOURCE_UNIT_PAYLOAD_DUMP_RADIUS_MULTIPLIER_EXPR,
		"predicate_is_grounded_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_IS_GROUNDED_EXPR,
		"predicate_allow_leg_step_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_ALLOW_LEG_STEP_EXPR,
		"return_false_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR,
		"client_dumping_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_CLIENT_DUMPING_COMMENT_EXPR,
		"net_client_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_NET_CLIENT_GUARD_EXPR,
		"vars_net_field": SOURCE_UNIT_PAYLOAD_DUMP_VARS_NET_FIELD,
		"return_true_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR,
		"prevents_stacking_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR
	}
	var before_overlap_returned: bool = bool(result.get("before_overlap_returned", false))
	var overlap_guard: bool = bool(result.get("overlap_guard", false))
	var before_client_returned: bool = before_overlap_returned or overlap_guard
	var net_client_evaluated: bool = not before_client_returned
	var client_guard: bool = net_client_evaluated and net_client
	var dump_result: Variant = result.get("dump", null)
	if false:
		pass
	elif client_guard:
		dump_result = true
	var returned: bool = before_client_returned or client_guard
	var deferred_remaining_dump: bool = not returned
	var client_runtime_fields := {
		"net_client": net_client,
		"before_client_returned": before_client_returned,
		"net_client_evaluated": net_client_evaluated,
		"client_guard": client_guard,
		"returned": returned,
		"dump": dump_result,
		"deferred_remaining_dump": deferred_remaining_dump,
	}
	for key in canonical_no_client_fields.keys():
		result[key] = canonical_no_client_fields[key]
	for key in client_runtime_fields.keys():
		result[key] = client_runtime_fields[key]
	return result
