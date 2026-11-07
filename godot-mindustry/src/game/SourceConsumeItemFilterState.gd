extends RefCounted
class_name SourceConsumeItemFilterState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE_CONSUME_ITEM_FILTER_SOURCE := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_SOURCE
const SOURCE_CONSUME_ITEM_FILTER_APPLY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_APPLY_METHOD
const SOURCE_CONSUME_ITEM_FILTER_APPLY_HAS_ITEMS_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_APPLY_HAS_ITEMS_ASSIGNMENT_EXPR
const SOURCE_CONSUME_ITEM_FILTER_APPLY_ACCEPTS_ITEMS_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_APPLY_ACCEPTS_ITEMS_ASSIGNMENT_EXPR
const SOURCE_CONSUME_ITEM_FILTER_APPLY_EACH_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_APPLY_EACH_EXPR
const SOURCE_CONSUME_ITEM_FILTER_APPLY_ITEM_FILTER_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_APPLY_ITEM_FILTER_ASSIGNMENT_EXPR
const SOURCE_CONSUME_ITEM_FILTER_BUILD_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_BUILD_METHOD
const SOURCE_CONSUME_ITEM_FILTER_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_FIELD_EXPR
const SOURCE_CONSUME_ITEM_FILTER_BUILD_IMAGE_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_BUILD_IMAGE_EXPR
const SOURCE_CONSUME_ITEM_FILTER_BUILD_EACH_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_BUILD_EACH_EXPR
const SOURCE_CONSUME_ITEM_FILTER_BUILD_TABLE_ADD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_BUILD_TABLE_ADD_EXPR
const SOURCE_CONSUME_ITEM_FILTER_MULTI_REQ_IMAGE_CLASS := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_MULTI_REQ_IMAGE_CLASS
const SOURCE_CONSUME_ITEM_FILTER_MULTI_REQ_IMAGE_ADD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_MULTI_REQ_IMAGE_ADD_EXPR
const SOURCE_CONSUME_ITEM_FILTER_REQ_IMAGE_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_REQ_IMAGE_CONSTRUCTOR
const SOURCE_CONSUME_ITEM_FILTER_REQ_IMAGE_VALID_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_REQ_IMAGE_VALID_EXPR
const SOURCE_CONSUME_ITEM_FILTER_STAT_VALUES_STACK_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_STAT_VALUES_STACK_METHOD
const SOURCE_CONSUME_ITEM_FILTER_STAT_VALUES_STACK_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_STAT_VALUES_STACK_EXPR
const SOURCE_CONSUME_ITEM_FILTER_BUILDING_ITEMS_FIELD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_BUILDING_ITEMS_FIELD
const SOURCE_CONSUME_ITEM_FILTER_ITEM_MODULE_HAS_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_ITEM_MODULE_HAS_EXPR
const SOURCE_CONSUME_ITEM_FILTER_BUILD_ITEMS_HAS_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_BUILD_ITEMS_HAS_EXPR
const SOURCE_CONSUME_ITEM_FILTER_CELL_SIZE_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_CELL_SIZE_EXPR
const SOURCE_CONSUME_ITEM_FILTER_UPDATE_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_UPDATE_METHOD
const SOURCE_CONSUME_ITEM_FILTER_UPDATE_EMPTY_BODY := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_UPDATE_EMPTY_BODY
const SOURCE_CONSUME_ITEM_FILTER_TRIGGER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_TRIGGER_METHOD
const SOURCE_CONSUME_ITEM_FILTER_TRIGGER_GET_CONSUMED_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_TRIGGER_GET_CONSUMED_EXPR
const SOURCE_CONSUME_ITEM_FILTER_TRIGGER_NULL_GUARD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_TRIGGER_NULL_GUARD_EXPR
const SOURCE_CONSUME_ITEM_FILTER_TRIGGER_REMOVE_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_TRIGGER_REMOVE_EXPR
const SOURCE_CONSUME_ITEM_FILTER_TRIGGER_REMOVE_CALL := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_TRIGGER_REMOVE_CALL
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_METHOD
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_RETURN_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_RETURN_EXPR
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_CONSUME_TRIGGER_VALID_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_CONSUME_TRIGGER_VALID_EXPR
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_GET_CONSUMED_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_GET_CONSUMED_EXPR
const SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_METHOD
const SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_LOOP_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_LOOP_EXPR
const SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_CONTENT_ITEM_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_CONTENT_ITEM_EXPR
const SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_GUARD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_GUARD_EXPR
const SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_RETURN_ITEM_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_RETURN_ITEM_EXPR
const SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_RETURN_NULL_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_RETURN_NULL_EXPR
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_METHOD
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_ITEM_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_ITEM_EXPR
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_ITEM_TIMED_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_ITEM_TIMED_EXPR
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STATS_ADD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STATS_ADD_EXPR
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STATS_ADD_CALL_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STATS_ADD_CALL_EXPR
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_SELECTED_STAT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_SELECTED_STAT_EXPR
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STAT_VALUES_ITEMS_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STAT_VALUES_ITEMS_EXPR
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STAT_VALUES_ITEMS_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STAT_VALUES_ITEMS_METHOD
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_CONTENT_FILTER_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_CONTENT_FILTER_EXPR
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_TABLE_ADD_ITEM_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_TABLE_ADD_ITEM_EXPR
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_METHOD
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_GET_CONSUMED_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_GET_CONSUMED_EXPR
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_RETURN_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_RETURN_EXPR
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_ITEM_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_ITEM_EXPR
const SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_METHOD
const SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_RETURN_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_RETURN_EXPR
const SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR
const SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_FILTER_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_FILTER_ASSIGNMENT_EXPR
const SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR

static func apply_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, filtered_item_ids: Array) -> Dictionary:
	var item_filter_after := item_filter_before.duplicate()
	for item_id in filtered_item_ids:
		item_filter_after[int(item_id)] = true
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_APPLY_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"method": SOURCE_CONSUME_ITEM_FILTER_APPLY_METHOD,
		"has_items_assignment_expr": SOURCE_CONSUME_ITEM_FILTER_APPLY_HAS_ITEMS_ASSIGNMENT_EXPR,
		"accepts_items_assignment_expr": SOURCE_CONSUME_ITEM_FILTER_APPLY_ACCEPTS_ITEMS_ASSIGNMENT_EXPR,
		"each_expr": SOURCE_CONSUME_ITEM_FILTER_APPLY_EACH_EXPR,
		"item_filter_assignment_expr": SOURCE_CONSUME_ITEM_FILTER_APPLY_ITEM_FILTER_ASSIGNMENT_EXPR,
		"block_has_items_before": block_has_items_before,
		"block_accepts_items_before": block_accepts_items_before,
		"item_filter_before": item_filter_before,
		"filtered_item_ids": filtered_item_ids,
		"block_has_items_after": true,
		"block_accepts_items_after": true,
		"item_filter_after": item_filter_after,
	}


static func build_state(filtered_item_ids: Array, build_items_has_item_flags: Array, source_ui_icon_med: float) -> Dictionary:
	var req_images: Array = []
	for index in filtered_item_ids.size():
		var valid: bool = bool(build_items_has_item_flags[index]) if index < build_items_has_item_flags.size() else false
		req_images.append({"item_id": int(filtered_item_ids[index]), "stack_amount": 1, "valid": valid, "stat_values_stack_expr": SOURCE_CONSUME_ITEM_FILTER_STAT_VALUES_STACK_EXPR, "valid_expr": SOURCE_CONSUME_ITEM_FILTER_BUILD_ITEMS_HAS_EXPR})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_BUILD_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"method": SOURCE_CONSUME_ITEM_FILTER_BUILD_METHOD,
		"filter_field": SOURCE_CONSUME_ITEM_FILTER_FIELD_EXPR,
		"image_expr": SOURCE_CONSUME_ITEM_FILTER_BUILD_IMAGE_EXPR,
		"each_expr": SOURCE_CONSUME_ITEM_FILTER_BUILD_EACH_EXPR,
		"table_add_expr": SOURCE_CONSUME_ITEM_FILTER_BUILD_TABLE_ADD_EXPR,
		"multi_req_image_class": SOURCE_CONSUME_ITEM_FILTER_MULTI_REQ_IMAGE_CLASS,
		"multi_req_image_add_expr": SOURCE_CONSUME_ITEM_FILTER_MULTI_REQ_IMAGE_ADD_EXPR,
		"req_image_constructor": SOURCE_CONSUME_ITEM_FILTER_REQ_IMAGE_CONSTRUCTOR,
		"req_image_valid_expr": SOURCE_CONSUME_ITEM_FILTER_REQ_IMAGE_VALID_EXPR,
		"stat_values_stack_expr": SOURCE_CONSUME_ITEM_FILTER_STAT_VALUES_STACK_METHOD,
		"building_items_field": SOURCE_CONSUME_ITEM_FILTER_BUILDING_ITEMS_FIELD,
		"item_module_has_expr": SOURCE_CONSUME_ITEM_FILTER_ITEM_MODULE_HAS_EXPR,
		"cell_size_expr": SOURCE_CONSUME_ITEM_FILTER_CELL_SIZE_EXPR,
		"filtered_item_ids": filtered_item_ids,
		"build_items_has_item_flags": build_items_has_item_flags,
		"multi_req_image_created": true,
		"req_images": req_images,
		"req_image_count": req_images.size(),
		"table_add_image": true,
		"table_image_size": source_ui_icon_med,
	}


@warning_ignore("shadowed_variable")
static func update_state(build_state: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_UPDATE_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"method": SOURCE_CONSUME_ITEM_FILTER_UPDATE_METHOD,
		"empty_body": SOURCE_CONSUME_ITEM_FILTER_UPDATE_EMPTY_BODY,
		"build_state": build_state,
		"no_op": true,
	}


@warning_ignore("shadowed_variable")
static func trigger_state(build_state: Variant, consumed_item: Variant) -> Dictionary:
	var item_removed: bool = consumed_item != null
	var remove_amount: int = 1 if item_removed else 0
	var remove_call: Variant = null
	if item_removed:
		remove_call = {"call": SOURCE_CONSUME_ITEM_FILTER_TRIGGER_REMOVE_CALL, "item": consumed_item, "amount": 1}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_TRIGGER_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"method": SOURCE_CONSUME_ITEM_FILTER_TRIGGER_METHOD,
		"get_consumed_expr": SOURCE_CONSUME_ITEM_FILTER_TRIGGER_GET_CONSUMED_EXPR,
		"null_guard_expr": SOURCE_CONSUME_ITEM_FILTER_TRIGGER_NULL_GUARD_EXPR,
		"remove_expr": SOURCE_CONSUME_ITEM_FILTER_TRIGGER_REMOVE_EXPR,
		"build_state": build_state,
		"consumed_item": consumed_item,
		"item_removed": item_removed,
		"remove_amount": remove_amount,
		"remove_call": remove_call,
	}


static func efficiency_state(consume_trigger_valid: bool, consumed_item: Variant) -> Dictionary:
	var has_consumed_item: bool = consumed_item != null
	var efficiency: float = 1.0 if consume_trigger_valid or has_consumed_item else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"method": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_METHOD,
		"return_expr": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_RETURN_EXPR,
		"consume_trigger_valid_expr": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_CONSUME_TRIGGER_VALID_EXPR,
		"get_consumed_expr": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_GET_CONSUMED_EXPR,
		"consume_trigger_valid": consume_trigger_valid,
		"consumed_item": consumed_item,
		"has_consumed_item": has_consumed_item,
		"efficiency": efficiency,
	}


static func get_consumed_state(content_items: Array, build_items_has_item_flags: Array, filter_get_item_flags: Array) -> Dictionary:
	var consumed_item: Variant = null
	var consumed_index: int = -1
	var checked_items: Array = []
	for i in range(content_items.size()):
		var item: Variant = content_items[i]
		var build_items_has_item: bool = bool(build_items_has_item_flags[i]) if i < build_items_has_item_flags.size() else false
		var filter_get_item: bool = bool(filter_get_item_flags[i]) if i < filter_get_item_flags.size() else false
		var item_matches: bool = build_items_has_item and filter_get_item
		checked_items.append({"index": i, "item": item, "build_items_has_item": build_items_has_item, "filter_get_item": filter_get_item, "item_matches": item_matches})
		if item_matches:
			consumed_item = item
			consumed_index = i
			break
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"method": SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_METHOD,
		"loop_expr": SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_LOOP_EXPR,
		"content_item_expr": SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_CONTENT_ITEM_EXPR,
		"guard_expr": SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_GUARD_EXPR,
		"return_item_expr": SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_RETURN_ITEM_EXPR,
		"return_null_expr": SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_RETURN_NULL_EXPR,
		"content_items": content_items,
		"build_items_has_item_flags": build_items_has_item_flags,
		"filter_get_item_flags": filter_get_item_flags,
		"checked_items": checked_items,
		"consumed_item": consumed_item,
		"consumed_index": consumed_index,
	}


static func display_state(booster: bool, stats_time_period: float, filtered_item_ids: Array) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_items: Array = []
	for item_id in filtered_item_ids:
		var display_expr: String = SOURCE_CONSUME_ITEM_FILTER_DISPLAY_ITEM_EXPR if stats_time_period <= 0.0 else SOURCE_CONSUME_ITEM_FILTER_DISPLAY_ITEM_TIMED_EXPR
		display_items.append({"item_id": int(item_id), "time_period": stats_time_period, "display_expr": display_expr})
	var stats_add_call: Dictionary = {"call": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STATS_ADD_CALL_EXPR, "stat": selected_stat, "stat_value_expr": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STAT_VALUES_ITEMS_EXPR, "time_period": stats_time_period, "filtered_item_ids": filtered_item_ids}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"method": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_METHOD,
		"stats_add_expr": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STATS_ADD_EXPR,
		"stats_add_call_expr": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STATS_ADD_CALL_EXPR,
		"selected_stat_expr": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_SELECTED_STAT_EXPR,
		"stat_values_items_expr": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STAT_VALUES_ITEMS_EXPR,
		"stat_values_items_method": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STAT_VALUES_ITEMS_METHOD,
		"content_filter_expr": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_CONTENT_FILTER_EXPR,
		"display_item_expr": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_TABLE_ADD_ITEM_EXPR,
		"booster": booster,
		"selected_stat": selected_stat,
		"stats_time_period": stats_time_period,
		"filtered_item_ids": filtered_item_ids,
		"stats_add_call": stats_add_call,
		"display_items": display_items,
	}


static func efficiency_multiplier_state(consumed_item: Variant, item_efficiency_multiplier: float) -> Dictionary:
	var has_consumed_item: bool = consumed_item != null
	var efficiency_multiplier: float = item_efficiency_multiplier if has_consumed_item else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"method": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_METHOD,
		"get_consumed_expr": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_GET_CONSUMED_EXPR,
		"return_expr": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_RETURN_EXPR,
		"item_efficiency_multiplier_expr": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_ITEM_EXPR,
		"consumed_item": consumed_item,
		"item_efficiency_multiplier": item_efficiency_multiplier,
		"has_consumed_item": has_consumed_item,
		"efficiency_multiplier": efficiency_multiplier,
	}


static func item_efficiency_multiplier_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"method": SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_METHOD,
		"efficiency_multiplier": 1.0,
		"return_expr": SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_RETURN_EXPR,
	}


static func constructor_state(item: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"constructor": SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR,
		"filter_assignment_expr": SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_FILTER_ASSIGNMENT_EXPR,
		"filter_field": SOURCE_CONSUME_ITEM_FILTER_FIELD_EXPR,
		"item": item,
		"filter_after": item,
	}


static func default_constructor_state(default_filter_expr: String) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR_STATE,
		"source": SOURCE_CONSUME_ITEM_FILTER_SOURCE,
		"constructor": SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR,
		"filter_field": SOURCE_CONSUME_ITEM_FILTER_FIELD_EXPR,
		"filter_after": default_filter_expr,
	}
