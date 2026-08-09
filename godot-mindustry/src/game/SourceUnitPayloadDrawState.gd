extends RefCounted
class_name SourceUnitPayloadDrawState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_payload_source_text_state := preload("res://src/game/SourcePayloadSourceTextState.gd")

const SOURCE_UNIT_PAYLOAD_GENERATED_CLASS := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_GENERATED_CLASS

static func _unit_payload_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_GENERATED_CLASS, generated_method, generated_args, null)

const SOURCE_UNIT_PAYLOAD_OVERLAY_DURATION := source_unit_defaults.PAYLOAD_OVERLAY_DURATION
const SOURCE_UNIT_PAYLOAD_OVERLAY_ALPHA := source_unit_defaults.PAYLOAD_OVERLAY_ALPHA
const SOURCE_UNIT_PAYLOAD_WARNING_SIZE := source_unit_defaults.PAYLOAD_WARNING_SIZE
const SOURCE_UNIT_PAYLOAD_DRAW_SHADOW_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_SHADOW_METHOD
const SOURCE_UNIT_PAYLOAD_DRAW_SOFT_SHADOW_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_SOFT_SHADOW_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_SNAPSHOT_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_SNAPSHOT_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_ZERO_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_ZERO_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_SCL_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_SCL_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_UNIT_TYPE_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_UNIT_TYPE_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_RESTORE_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_RESTORE_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_WARNING_COMMENT_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_WARNING_COMMENT_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_GUARD_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_Z_SNAPSHOT_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_Z_SNAPSHOT_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_Z_WARNING_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_Z_WARNING_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_REGION_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_REGION_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_COLOR_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_COLOR_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_ALPHA_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_ALPHA_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_SIZE_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_SIZE_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_RECT_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_RECT_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_RESET_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_RESET_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_TIME_UPDATE_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_TIME_UPDATE_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_Z_RESTORE_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_Z_RESTORE_EXPR
const SOURCE_UNIT_PAYLOAD_ICON_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_ICON_METHOD
const SOURCE_UNIT_PAYLOAD_ICON_RETURN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_ICON_RETURN_EXPR

static func draw_shadow_type_null_state(unit_type_null: bool, alpha: float, unit_id: Variant) -> Dictionary:
	var returned_early: bool = unit_type_null
	var draw_soft_shadow_called: bool = not returned_early
	var draw_soft_shadow_call: Dictionary = {}
	if draw_soft_shadow_called:
		draw_soft_shadow_call = {"call": SOURCE_UNIT_PAYLOAD_DRAW_SOFT_SHADOW_EXPR, "unit": unit_id, "alpha": alpha}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DRAW_SHADOW_TYPE_NULL_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_DRAW_SHADOW_METHOD,
		"todo_comment_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"type_null_guard_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TYPE_NULL_GUARD_EXPR,
		"draw_soft_shadow_expr": SOURCE_UNIT_PAYLOAD_DRAW_SOFT_SHADOW_EXPR,
		"unit_type_null": unit_type_null,
		"alpha": alpha,
		"unit_id": unit_id,
		"returned_early": returned_early,
		"draw_soft_shadow_called": draw_soft_shadow_called,
		"draw_soft_shadow_call": draw_soft_shadow_call,
	}

static func draw_type_null_state(unit_type_null: bool) -> Dictionary:
	var returned_early: bool = unit_type_null
	var deferred_remaining_draw: bool = not returned_early
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DRAW_TYPE_NULL_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_DRAW_METHOD,
		"todo_comment_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"type_null_guard_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TYPE_NULL_GUARD_EXPR,
		"next_expr": SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_SNAPSHOT_EXPR,
		"unit_type_null": unit_type_null,
		"returned_early": returned_early,
		"deferred_remaining_draw": deferred_remaining_draw,
	}

static func draw_elevation_setup_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant) -> Dictionary:
	var returned_early: bool = unit_type_null
	var elevation_snapshot: float = unit_elevation
	var elevation_after_zero: float = 0.0 if not returned_early else unit_elevation
	var draw_scl_called: bool = not returned_early
	var unit_type_draw_called: bool = not returned_early
	var draw_scl_call: Dictionary = {"sx": 1.0, "sy": 1.0} if not returned_early else {}
	var unit_type_draw_call: Dictionary = {"unit": unit_id} if not returned_early else {}
	var elevation_after_restore: float = elevation_snapshot if not returned_early else unit_elevation
	var deferred_remaining_draw: bool = not returned_early
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_SETUP_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_DRAW_METHOD,
		"todo_comment_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"type_null_guard_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TYPE_NULL_GUARD_EXPR,
		"elevation_snapshot_expr": SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_SNAPSHOT_EXPR,
		"elevation_zero_expr": SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_ZERO_EXPR,
		"draw_scl_expr": SOURCE_UNIT_PAYLOAD_DRAW_SCL_EXPR,
		"unit_type_draw_expr": SOURCE_UNIT_PAYLOAD_DRAW_UNIT_TYPE_EXPR,
		"elevation_restore_expr": SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_RESTORE_EXPR,
		"next_expr": SOURCE_UNIT_PAYLOAD_DRAW_WARNING_COMMENT_EXPR,
		"unit_type_null": unit_type_null,
		"unit_elevation": unit_elevation,
		"unit_id": unit_id,
		"returned_early": returned_early,
		"elevation_snapshot": elevation_snapshot,
		"elevation_after_zero": elevation_after_zero,
		"draw_scl_called": draw_scl_called,
		"draw_scl_call": draw_scl_call,
		"unit_type_draw_called": unit_type_draw_called,
		"unit_type_draw_call": unit_type_draw_call,
		"elevation_after_restore": elevation_after_restore,
		"deferred_remaining_draw": deferred_remaining_draw,
	}

static func draw_overlay_warning_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant, overlay_time: float, overlay_region: Variant, unit_x: float, unit_y: float, time_delta: float, draw_z_before: float, interp_exp5_out_overlay_time: float) -> Dictionary:
	var returned_early: bool = unit_type_null
	var overlay_guard: bool = not unit_type_null and overlay_time > 0.0
	var overlay_duration: float = SOURCE_UNIT_PAYLOAD_OVERLAY_DURATION
	var draw_alpha_value: float = SOURCE_UNIT_PAYLOAD_OVERLAY_ALPHA * interp_exp5_out_overlay_time if overlay_guard else 0.0
	var warning_size: float = SOURCE_UNIT_PAYLOAD_WARNING_SIZE
	var overlay_region_resolved: Variant = overlay_region
	var draw_z_snapshot: float = draw_z_before if overlay_guard else 0.0
	var draw_z_warning_call: Dictionary = {"z": "Layer.groundUnit + 1f"} if overlay_guard else {}
	var draw_color_call: Dictionary = {"color": "Color.scarlet"} if overlay_guard else {}
	var draw_alpha_call: Dictionary = {"alpha": draw_alpha_value} if overlay_guard else {}
	var draw_rect_call: Dictionary = {}
	if overlay_guard:
		draw_rect_call = {"region": overlay_region, "x": unit_x, "y": unit_y, "width": warning_size, "height": warning_size}
	var draw_reset_called: bool = overlay_guard
	var draw_z_restore_call: Dictionary = {"z": draw_z_before} if overlay_guard else {}
	var overlay_time_after: float = max(overlay_time - time_delta / overlay_duration, 0.0) if overlay_guard else overlay_time
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_WARNING_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"overlay_duration_field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_DURATION_FIELD_EXPR,
		"overlay_time_field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR,
		"overlay_region_field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR,
		"method": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_DRAW_METHOD,
		"draw_warning_comment_expr": SOURCE_UNIT_PAYLOAD_DRAW_WARNING_COMMENT_EXPR,
		"overlay_guard_expr": SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_GUARD_EXPR,
		"draw_z_snapshot_expr": SOURCE_UNIT_PAYLOAD_DRAW_Z_SNAPSHOT_EXPR,
		"draw_z_warning_expr": SOURCE_UNIT_PAYLOAD_DRAW_Z_WARNING_EXPR,
		"region_expr": SOURCE_UNIT_PAYLOAD_DRAW_REGION_EXPR,
		"draw_color_expr": SOURCE_UNIT_PAYLOAD_DRAW_COLOR_EXPR,
		"draw_alpha_expr": SOURCE_UNIT_PAYLOAD_DRAW_ALPHA_EXPR,
		"size_expr": SOURCE_UNIT_PAYLOAD_DRAW_SIZE_EXPR,
		"draw_rect_expr": SOURCE_UNIT_PAYLOAD_DRAW_RECT_EXPR,
		"draw_reset_expr": SOURCE_UNIT_PAYLOAD_DRAW_RESET_EXPR,
		"overlay_time_update_expr": SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_TIME_UPDATE_EXPR,
		"draw_z_restore_expr": SOURCE_UNIT_PAYLOAD_DRAW_Z_RESTORE_EXPR,
		"unit_type_null": unit_type_null,
		"unit_elevation": unit_elevation,
		"unit_id": unit_id,
		"overlay_time": overlay_time,
		"overlay_region": overlay_region,
		"unit_x": unit_x,
		"unit_y": unit_y,
		"time_delta": time_delta,
		"draw_z_before": draw_z_before,
		"returned_early": returned_early,
		"deferred_remaining_draw": false,
		"interp_exp5_out_overlay_time": interp_exp5_out_overlay_time,
		"overlay_duration": overlay_duration,
		"overlay_guard": overlay_guard,
		"overlay_region_resolved": overlay_region_resolved,
		"draw_z_snapshot": draw_z_snapshot,
		"draw_z_warning_call": draw_z_warning_call,
		"draw_color_call": draw_color_call,
		"draw_alpha_value": draw_alpha_value,
		"draw_alpha_call": draw_alpha_call,
		"warning_size": warning_size,
		"draw_rect_call": draw_rect_call,
		"draw_reset_called": draw_reset_called,
		"draw_z_restore_call": draw_z_restore_call,
		"overlay_time_after": overlay_time_after,
	}

static func icon_state(unit_type_full_icon: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_ICON_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_ICON_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_ICON_RETURN_EXPR,
		"unit_type_full_icon": unit_type_full_icon,
		"icon": unit_type_full_icon,
	}

static func generated_shadow_type_null_bridge_state(unit_type_null: bool, alpha: float, unit_id: Variant) -> Dictionary:
	var result = _unit_payload_call("java_method_drawShadow_14", [unit_type_null, alpha, unit_id])
	var canonical = draw_shadow_type_null_state(unit_type_null, alpha, unit_id)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DRAW_SHADOW_TYPE_NULL_STATE,
		"generated_owner": "unit_payload.java_method_drawShadow_14",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_type_null_bridge_state(unit_type_null: bool) -> Dictionary:
	var result = _unit_payload_call("java_method_draw_15", [unit_type_null])
	var canonical = draw_type_null_state(unit_type_null)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DRAW_TYPE_NULL_STATE,
		"generated_owner": "unit_payload.java_method_draw_15",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_elevation_setup_bridge_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant) -> Dictionary:
	var result = _unit_payload_call("java_method_draw_15", [unit_type_null, unit_elevation, unit_id])
	var canonical = draw_elevation_setup_state(unit_type_null, unit_elevation, unit_id)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_SETUP_STATE,
		"generated_owner": "unit_payload.java_method_draw_15",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_overlay_warning_bridge_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant, overlay_time: float, overlay_region: Variant, unit_x: float, unit_y: float, time_delta: float, draw_z_before: float, interp_exp5_out_overlay_time: float) -> Dictionary:
	var result = _unit_payload_call("java_method_draw_15", [unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time])
	var canonical = draw_overlay_warning_state(unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_WARNING_STATE,
		"generated_owner": "unit_payload.java_method_draw_15",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_icon_bridge_state(unit_type_full_icon: Variant) -> Dictionary:
	var result = _unit_payload_call("java_method_icon_16", [unit_type_full_icon])
	var canonical = icon_state(unit_type_full_icon)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_ICON_STATE,
		"generated_owner": "unit_payload.java_method_icon_16",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
