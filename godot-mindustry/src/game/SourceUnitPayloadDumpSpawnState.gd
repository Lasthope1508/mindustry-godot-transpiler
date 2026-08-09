extends RefCounted
class_name SourceUnitPayloadDumpSpawnState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_unit_payload_dump_source_text_state := preload("res://src/game/SourceUnitPayloadDumpSourceTextState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

const SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_VELOCITY_RANGE := source_world_defaults.UNIT_PAYLOAD_DUMP_SPAWN_VELOCITY_RANGE
const SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_ARC_MATHF_SOURCE := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_ARC_MATHF_SOURCE
const SOURCE_UNIT_PAYLOAD_DUMP_UNITS_SOURCE := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_UNITS_SOURCE
const SOURCE_UNIT_PAYLOAD_DUMP_EVENT_TYPE_SOURCE := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_EVENT_TYPE_SOURCE
const SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_METHOD := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_METHOD
const SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_RETURN := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_RETURN
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_ADD_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_ADD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOADED_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOADED_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_COMMENT := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_COMMENT
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CLASS := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CLASS
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CONSTRUCTOR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CONSTRUCTOR
const SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_METHOD := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_METHOD
const SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_GUARD := source_unit_payload_dump_source_text_state.SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_GUARD

static func spawn_side_effects_state(state: Dictionary, range_x: float, range_y: float, unit_id: Variant) -> Dictionary:
	var result := state.duplicate(true)
	result["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_SIDE_EFFECTS_STATE
	result["arc_mathf_source"] = SOURCE_UNIT_PAYLOAD_DUMP_ARC_MATHF_SOURCE
	result["units_source"] = SOURCE_UNIT_PAYLOAD_DUMP_UNITS_SOURCE
	result["event_type_source"] = SOURCE_UNIT_PAYLOAD_DUMP_EVENT_TYPE_SOURCE
	result["prevents_stacking_comment_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR
	var before_spawn_returned: bool = bool(result.get("before_client_returned", false)) or bool(result.get("client_guard", false))
	var spawn_evaluated: bool = not before_spawn_returned
	var velocity_add_call: Dictionary = {}
	var unit_add_called: bool = false
	var unit_unloaded_called: bool = false
	var event_fire_call: Dictionary = {}
	var notify_unit_spawn_call: Dictionary = {}
	var velocity_range: float = SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_VELOCITY_RANGE
	if spawn_evaluated:
		velocity_add_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR, "range": velocity_range, "x": range_x, "y": range_y, "unit": unit_id}
		unit_add_called = true
		unit_unloaded_called = true
		event_fire_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR, "event": SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_EXPR, "unit": unit_id}
		notify_unit_spawn_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR, "unit": unit_id}
	result["velocity_add_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR
	result["mathf_range_float_method"] = SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_METHOD
	result["mathf_range_float_return"] = SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_RETURN
	result["unit_add_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_ADD_EXPR
	result["unit_unloaded_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOADED_EXPR
	result["event_fire_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR
	result["unit_unload_event_comment"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_COMMENT
	result["unit_unload_event_class"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CLASS
	result["unit_unload_event_constructor"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CONSTRUCTOR
	result["notify_unit_spawn_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR
	result["notify_unit_spawn_method"] = SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_METHOD
	result["notify_unit_spawn_guard"] = SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_GUARD
	result["final_return_true_expr"] = state.get("return_true_expr", "")
	result["before_spawn_returned"] = before_spawn_returned
	result["spawn_evaluated"] = spawn_evaluated
	result["velocity_add_call"] = velocity_add_call
	result["unit_add_called"] = unit_add_called
	result["unit_unloaded_called"] = unit_unloaded_called
	result["event_fire_call"] = event_fire_call
	result["notify_unit_spawn_call"] = notify_unit_spawn_call
	result["deferred_remaining_dump"] = false
	return result
