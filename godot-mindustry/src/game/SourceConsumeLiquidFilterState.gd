extends RefCounted
class_name SourceConsumeLiquidFilterState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE_CONSUME_LIQUID_FILTER_SOURCE := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_SOURCE
const SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR
const SOURCE_CONSUME_LIQUID_FILTER_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_FIELD_EXPR
const SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR
const SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_EMPTY_BODY := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_EMPTY_BODY
const SOURCE_CONSUME_LIQUID_FILTER_APPLY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_APPLY_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_BUILD_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_BUILD_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_BUILD_IMAGE_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_BUILD_IMAGE_EXPR
const SOURCE_CONSUME_LIQUID_FILTER_BUILD_VALID_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_BUILD_VALID_EXPR
const SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_UPDATE_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_UPDATE_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_UPDATE_REMOVE_CALL_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_UPDATE_REMOVE_CALL_EXPR
const SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_STATS_ADD_CALL_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_STATS_ADD_CALL_EXPR
const SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_STAT_VALUES_LIQUIDS_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_STAT_VALUES_LIQUIDS_EXPR
const SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_METHOD

static func constructor_state(filter_handle: Variant, amount: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"constructor": SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR,
		"filter_field": SOURCE_CONSUME_LIQUID_FILTER_FIELD_EXPR,
		"filter_handle": filter_handle,
		"amount": amount,
		"amount_after": amount,
		"filter_after": filter_handle,
	}

static func default_constructor_state(default_filter_expr: String) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"constructor": SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR,
		"filter_field": SOURCE_CONSUME_LIQUID_FILTER_FIELD_EXPR,
		"empty_constructor_body": SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_EMPTY_BODY,
		"no_op": true,
		"filter_after": default_filter_expr,
	}

static func apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, filtered_liquid_ids: Array) -> Dictionary:
	var liquid_filter_after := liquid_filter_before.duplicate()
	for liquid_id in filtered_liquid_ids:
		var index := int(liquid_id)
		if index >= 0 and index < liquid_filter_after.size():
			liquid_filter_after[index] = true
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_APPLY_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FILTER_APPLY_METHOD,
		"block_has_liquids_before": block_has_liquids_before,
		"block_has_liquids_after": true,
		"liquid_filter_before": liquid_filter_before,
		"filtered_liquid_ids": filtered_liquid_ids,
		"liquid_filter_after": liquid_filter_after,
	}

static func build_state(filtered_liquid_ids: Array, consumed_liquid: Variant, source_ui_icon_med: float) -> Dictionary:
	var req_images: Array = []
	for liquid_id in filtered_liquid_ids:
		var valid: bool = liquid_id == consumed_liquid
		req_images.append({"liquid_id": liquid_id, "valid": valid, "image_expr": SOURCE_CONSUME_LIQUID_FILTER_BUILD_IMAGE_EXPR, "valid_expr": SOURCE_CONSUME_LIQUID_FILTER_BUILD_VALID_EXPR})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_BUILD_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FILTER_BUILD_METHOD,
		"filtered_liquid_ids": filtered_liquid_ids,
		"consumed_liquid": consumed_liquid,
		"multi_req_image_created": true,
		"req_images": req_images,
		"req_image_count": req_images.size(),
		"table_add_image": true,
		"table_image_size": source_ui_icon_med,
	}

static func get_consumed_state(current_liquid: Variant, current_filter_get_liquid: bool, current_amount: float, content_liquids: Array, filter_get_liquid_flags: Array, build_liquid_amounts: Array) -> Dictionary:
	var current_branch_matched: bool = current_filter_get_liquid and current_amount > 0.0
	var consumed_liquid: Variant = current_liquid if current_branch_matched else null
	var consumed_index: int = -1
	var checked_liquids: Array = []
	if not current_branch_matched:
		for i in range(content_liquids.size()):
			var liquid: Variant = content_liquids[i]
			var filter_get_liquid: bool = bool(filter_get_liquid_flags[i]) if i < filter_get_liquid_flags.size() else false
			var build_liquids_get: float = float(build_liquid_amounts[i]) if i < build_liquid_amounts.size() else 0.0
			var liquid_matches: bool = filter_get_liquid and build_liquids_get > 0.0
			checked_liquids.append({"index": i, "liquid": liquid, "filter_get_liquid": filter_get_liquid, "build_liquids_get": build_liquids_get, "liquid_matches": liquid_matches})
			if consumed_liquid == null and liquid_matches:
				consumed_liquid = liquid
				consumed_index = i
				break
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_METHOD,
		"current_liquid": current_liquid,
		"current_filter_get_liquid": current_filter_get_liquid,
		"current_amount": current_amount,
		"content_liquids": content_liquids,
		"filter_get_liquid_flags": filter_get_liquid_flags,
		"build_liquid_amounts": build_liquid_amounts,
		"current_branch_matched": current_branch_matched,
		"checked_liquids": checked_liquids,
		"consumed_liquid": consumed_liquid,
		"consumed_index": consumed_index,
	}

static func update_state(consumed_liquid: Variant, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var remove_called: bool = consumed_liquid != null
	var remove_amount: float = amount * build_edelta * multiplier_get_build if remove_called else 0.0
	var remove_call: Dictionary = {"call": SOURCE_CONSUME_LIQUID_FILTER_UPDATE_REMOVE_CALL_EXPR, "liquid": consumed_liquid, "amount": remove_amount} if remove_called else {}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_UPDATE_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FILTER_UPDATE_METHOD,
		"consumed_liquid": consumed_liquid,
		"amount": amount,
		"build_edelta": build_edelta,
		"multiplier_get_build": multiplier_get_build,
		"remove_called": remove_called,
		"remove_amount": remove_amount,
		"remove_call": remove_call,
	}

static func efficiency_state(consumed_liquid: Variant, build_liquids_get: float, amount: float, build_edelta: float, multiplier_get_build: float, source_consume_efficiency_epsilon: float) -> Dictionary:
	var ed: float = build_edelta
	var ed_guard: bool = ed <= source_consume_efficiency_epsilon
	var has_consumed_liquid: bool = consumed_liquid != null
	var required_liquid_amount: float = amount * ed * multiplier_get_build
	var raw_efficiency: float = build_liquids_get / required_liquid_amount if has_consumed_liquid and not ed_guard else 0.0
	var efficiency: float = 0.0 if ed_guard else (min(raw_efficiency, 1.0) if has_consumed_liquid else 0.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_METHOD,
		"consumed_liquid": consumed_liquid,
		"build_liquids_get": build_liquids_get,
		"amount": amount,
		"build_edelta": build_edelta,
		"multiplier_get_build": multiplier_get_build,
		"ed": ed,
		"ed_guard": ed_guard,
		"has_consumed_liquid": has_consumed_liquid,
		"required_liquid_amount": required_liquid_amount,
		"raw_efficiency": raw_efficiency,
		"efficiency": efficiency,
	}

static func efficiency_multiplier_state(consumed_liquid: Variant, liquid_efficiency_multiplier: float) -> Dictionary:
	var has_consumed_liquid: bool = consumed_liquid != null
	var efficiency_multiplier: float = liquid_efficiency_multiplier if has_consumed_liquid else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_METHOD,
		"consumed_liquid": consumed_liquid,
		"liquid_efficiency_multiplier": liquid_efficiency_multiplier,
		"has_consumed_liquid": has_consumed_liquid,
		"efficiency_multiplier": efficiency_multiplier,
	}

static func liquid_efficiency_multiplier_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_METHOD,
		"efficiency_multiplier": 1.0,
	}

static func display_state(booster: bool, amount: float, filtered_liquid_ids: Array, source_tick_rate: float) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_amount_per_second: float = amount * source_tick_rate
	var display_liquids: Array = []
	for index in range(filtered_liquid_ids.size()):
		var liquid_id: int = int(filtered_liquid_ids[index])
		var has_separator_after: bool = index != filtered_liquid_ids.size() - 1
		display_liquids.append({"liquid_id": liquid_id, "display_amount_per_second": display_amount_per_second, "per_second": true, "has_separator_after": has_separator_after})
	var stats_add_call: Dictionary = {"call": SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_STATS_ADD_CALL_EXPR, "stat": selected_stat, "stat_value_expr": SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_STAT_VALUES_LIQUIDS_EXPR, "amount": amount, "display_amount_per_second": display_amount_per_second, "filtered_liquid_ids": filtered_liquid_ids}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_METHOD,
		"booster": booster,
		"amount": amount,
		"selected_stat": selected_stat,
		"display_amount_per_second": display_amount_per_second,
		"per_second": true,
		"filtered_liquid_ids": filtered_liquid_ids,
		"stats_add_call": stats_add_call,
		"display_liquids": display_liquids,
	}

static func consumes_state(filter_get_liquid: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_STATE,
		"source": SOURCE_CONSUME_LIQUID_FILTER_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_METHOD,
		"filter_get_liquid": filter_get_liquid,
		"consumes_liquid": filter_get_liquid,
	}
