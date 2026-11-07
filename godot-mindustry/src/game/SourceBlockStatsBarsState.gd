extends RefCounted
class_name SourceBlockStatsBarsState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_stats_bars_source_text_state := preload("res://src/game/SourceBlockStatsBarsSourceTextState.gd")
const source_block_reinitialize_consumers_state := preload("res://src/game/SourceBlockReinitializeConsumersState.gd")
const source_consume_module_registry := preload("res://src/game/SourceConsumeModuleRegistry.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_STATS_BARS_SOURCE := source_block_stats_bars_source_text_state.SOURCE_BLOCK_STATS_BARS_SOURCE
const SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_NAME_PREFIX := source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_NAME_PREFIX
const SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_NAME := source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_NAME
const SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_EMPTY_TEXT := source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_EMPTY_TEXT
const SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_CLEAR_COLOR := source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_CLEAR_COLOR
const SOURCE_BLOCK_AFTER_PATCH_ITEM_FILTER_EXPR := source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_ITEM_FILTER_EXPR
const SOURCE_BLOCK_AFTER_PATCH_LIQUID_FILTER_EXPR := source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_LIQUID_FILTER_EXPR
const SOURCE_BLOCK_AFTER_PATCH_CONSUMER_SIZE_GUARD_EXPR := source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_CONSUMER_SIZE_GUARD_EXPR
const SOURCE_BLOCK_AFTER_PATCH_CONSUMER_LOOP_EXPR := source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_CONSUMER_LOOP_EXPR
const SOURCE_BLOCK_AFTER_PATCH_CONSUMER_APPLY_EXPR := source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_CONSUMER_APPLY_EXPR

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func set_stats_state(size_value: int, synthetic_value: bool, health: float, armor: float, buildable_value: bool, requirements_length: int, build_time: float, instant_transfer: bool, consumers: Array, has_liquids: bool, liquid_capacity: float, has_items: bool, item_capacity: int) -> Dictionary:
	var armor_stat_called: bool = synthetic_value and armor > 0.0
	var build_cost_stats_called: bool = buildable_value and requirements_length > 0
	var consumer_display_calls: Array = []
	for consumer in consumers:
		consumer_display_calls.append({"call": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_CONSUMER_DISPLAY_EXPR, "consumer": consumer})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SET_STATS_STATE, "source": SOURCE_BLOCK_STATS_BARS_SOURCE, "method": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_METHOD, "super_set_stats_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_SUPER_EXPR, "size_stat_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_SIZE_STAT_EXPR, "synthetic_guard_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_SYNTHETIC_GUARD_EXPR, "health_stat_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_HEALTH_STAT_EXPR, "armor_guard_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_ARMOR_GUARD_EXPR, "armor_stat_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_ARMOR_STAT_EXPR, "build_cost_guard_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_BUILD_COST_GUARD_EXPR, "build_time_stat_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_BUILD_TIME_STAT_EXPR, "build_cost_stat_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_BUILD_COST_STAT_EXPR, "instant_transfer_guard_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_INSTANT_TRANSFER_GUARD_EXPR, "max_consecutive_stat_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_MAX_CONSECUTIVE_STAT_EXPR, "consumer_display_loop_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_CONSUMER_DISPLAY_LOOP_EXPR, "consumer_display_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_CONSUMER_DISPLAY_EXPR, "liquid_capacity_stat_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_LIQUID_CAPACITY_STAT_EXPR, "item_capacity_stat_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_ITEM_CAPACITY_STAT_EXPR, "size": size_value, "synthetic": synthetic_value, "health": health, "armor": armor, "can_be_built": buildable_value, "requirements_length": requirements_length, "build_time": build_time, "instant_transfer": instant_transfer, "consumers": consumers, "has_liquids": has_liquids, "liquid_capacity": liquid_capacity, "has_items": has_items, "item_capacity": item_capacity, "super_set_stats_called": true, "health_stat_called": synthetic_value, "armor_stat_called": armor_stat_called, "build_cost_stats_called": build_cost_stats_called, "instant_transfer_stat_called": instant_transfer, "consumer_display_calls": consumer_display_calls, "liquid_capacity_stat_called": has_liquids, "item_capacity_stat_called": has_items and item_capacity > 0}

static func add_bar_state(bar_name: String, bar_supplier: Variant, bar_map_before: Dictionary) -> Dictionary:
	var bar_map_after: Dictionary = bar_map_before.duplicate()
	bar_map_after[bar_name] = bar_supplier
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ADD_BAR_STATE, "source": SOURCE_BLOCK_STATS_BARS_SOURCE, "method": source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_BAR_METHOD, "bar_map_put_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_BAR_MAP_PUT_EXPR, "name": bar_name, "supplier": bar_supplier, "bar_map_before": bar_map_before, "bar_map_after": bar_map_after, "bar_registered": true}

static func remove_bar_state(bar_name: String, bar_map_before: Dictionary) -> Dictionary:
	var bar_map_after: Dictionary = bar_map_before.duplicate()
	bar_map_after.erase(bar_name)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REMOVE_BAR_STATE, "source": SOURCE_BLOCK_STATS_BARS_SOURCE, "method": source_block_stats_bars_source_text_state.SOURCE_BLOCK_REMOVE_BAR_METHOD, "bar_map_remove_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_REMOVE_BAR_MAP_REMOVE_EXPR, "name": bar_name, "bar_map_before": bar_map_before, "bar_map_after": bar_map_after, "bar_removed": true}

static func list_bars_state(bar_map: Dictionary) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LIST_BARS_STATE, "source": SOURCE_BLOCK_STATS_BARS_SOURCE, "method": source_block_stats_bars_source_text_state.SOURCE_BLOCK_LIST_BARS_METHOD, "return_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_LIST_BARS_RETURN_EXPR, "bar_map": bar_map, "bars": bar_map.values()}

static func add_liquid_bar_static_state(liquid_name: String, liquid_unlocked: bool, liquid_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant) -> Dictionary:
	var bar_name: String = SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_NAME_PREFIX + liquid_name
	var fraction: float = 0.0 if liquid_capacity == 0.0 else liquid_amount / liquid_capacity
	var bar_call: Variant = null
	if liquid_unlocked:
		bar_call = {"call": "new Bar(() -> liq.localizedName, liq::barColor, () -> entity.liquids.get(liq) / liquidCapacity)", "name": bar_name, "text": localized_name, "color": bar_color, "fraction": fraction}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_STATE, "source": SOURCE_BLOCK_STATS_BARS_SOURCE, "method": source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_METHOD, "add_bar_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_ADD_BAR_EXPR, "liquid_name": liquid_name, "bar_name": bar_name, "unlocked": liquid_unlocked, "liquid_amount": liquid_amount, "liquid_capacity": liquid_capacity, "localized_name": localized_name, "bar_color": bar_color, "bar_call": bar_call}

static func add_liquid_bar_dynamic_state(current_liquid: Variant, current_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant, empty_threshold: float = source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_EMPTY_THRESHOLD) -> Dictionary:
	var liquid_present: bool = current_liquid != null
	var bar_text: String = SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_EMPTY_TEXT if (not liquid_present or current_amount <= empty_threshold) else localized_name
	var resolved_color: Variant = bar_color if liquid_present else SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_CLEAR_COLOR
	var fraction: float = 0.0 if (not liquid_present or liquid_capacity == 0.0) else current_amount / liquid_capacity
	var bar_call: Dictionary = {"call": "new Bar(() -> current.get((T)entity) == null || entity.liquids.get(current.get((T)entity)) <= 0.001f ? Core.bundle.get(\"bar.liquid\") : current.get((T)entity).localizedName, () -> current.get((T)entity) == null ? Color.clear : current.get((T)entity).barColor(), () -> current.get((T)entity) == null ? 0f : entity.liquids.get(current.get((T)entity)) / liquidCapacity)", "name": SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_NAME, "text": bar_text, "color": resolved_color, "fraction": fraction}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_STATE, "source": SOURCE_BLOCK_STATS_BARS_SOURCE, "method": source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_METHOD, "add_bar_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_ADD_BAR_EXPR, "dynamic_bar_name": SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_NAME, "current_liquid": current_liquid, "current_amount": current_amount, "liquid_capacity": liquid_capacity, "localized_name": localized_name, "bar_color": bar_color, "empty_threshold": empty_threshold, "liquid_present": liquid_present, "bar_text": bar_text, "resolved_color": resolved_color, "fraction": fraction, "bar_call": bar_call}

static func set_bars_state(cons_power_present: bool, has_items: bool, configurable: bool, item_total: int, item_capacity: int, unit_cap_modifier: int, has_liquids: bool, static_liquid_bar_added: bool) -> Dictionary:
	var item_fraction: float = 0.0 if item_capacity == 0 else float(item_total) / float(item_capacity)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SET_BARS_STATE, "source": SOURCE_BLOCK_STATS_BARS_SOURCE, "method": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_METHOD, "health_bar_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_HEALTH_BAR_EXPR, "power_guard_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_POWER_GUARD_EXPR, "power_bar_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_POWER_BAR_EXPR, "items_guard_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_ITEMS_GUARD_EXPR, "items_bar_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_ITEMS_BAR_EXPR, "unit_cap_guard_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_UNIT_CAP_GUARD_EXPR, "unit_cap_stat_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_UNIT_CAP_STAT_EXPR, "has_liquids_guard_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_HAS_LIQUIDS_GUARD_EXPR, "dynamic_liquid_bar_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_DYNAMIC_LIQUID_BAR_EXPR, "cons_power_present": cons_power_present, "has_items": has_items, "configurable": configurable, "item_total": item_total, "item_capacity": item_capacity, "unit_cap_modifier": unit_cap_modifier, "has_liquids": has_liquids, "static_liquid_bar_added": static_liquid_bar_added, "health_bar_added": true, "power_bar_added": cons_power_present, "items_bar_added": has_items and configurable, "item_fraction": item_fraction, "max_units_stat_called": unit_cap_modifier != 0, "dynamic_liquid_bar_added": has_liquids and not static_liquid_bar_added}

static func after_patch_stats_bars_state(size_value: int, source_tilesize: float, content_items_size: int, content_liquids_size: int, consume_builder: Array) -> Dictionary:
	var offset_after: float = float((size_value + 1) % 2) * source_tilesize / 2.0
	var size_offset_after: int = -int(float(size_value - 1) / 2.0)
	var filters := source_block_reinitialize_consumers_state.item_liquid_filters_state(content_items_size, content_liquids_size)
	var apply_projection := source_consume_module_registry.source_consume_state.consumer_apply_calls(consume_builder, source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_CONSUMER_APPLY_EXPR, source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_CONSUMER_THIS_ARG)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_AFTER_PATCH_STATS_BARS_STATE, "source": SOURCE_BLOCK_STATS_BARS_SOURCE, "method": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_METHOD, "super_after_patch_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_SUPER_EXPR, "bar_map_clear_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_BAR_MAP_CLEAR_EXPR, "set_bars_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_SET_BARS_EXPR, "offset_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_OFFSET_EXPR, "size_offset_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_SIZE_OFFSET_EXPR, "item_filter_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_ITEM_FILTER_EXPR, "liquid_filter_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_LIQUID_FILTER_EXPR, "consumer_size_guard_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_CONSUMER_SIZE_GUARD_EXPR, "consumer_loop_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_CONSUMER_LOOP_EXPR, "consumer_apply_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_CONSUMER_APPLY_EXPR, "consumer_apply_method_expr": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_CONSUMER_APPLY_METHOD_EXPR, "size": size_value, "tilesize": source_tilesize, "content_items_size": content_items_size, "content_liquids_size": content_liquids_size, "bar_map_cleared": true, "set_bars_called": true, "offset": offset_after, "sizeOffset": size_offset_after, "item_filter": filters["item_filter"], "liquid_filter": filters["liquid_filter"], "consume_builder": consume_builder, "consumer_apply_calls": apply_projection[source_consume_module_registry.source_consume_state.SOURCE_CONSUME_APPLY_CALLS_KEY], "consumer_apply_call_count": apply_projection[source_consume_module_registry.source_consume_state.SOURCE_CONSUME_APPLY_CALL_COUNT_KEY]}

# Generated Block methods delegate to these canonical state entrypoints.
static func generated_set_stats_result_state(size_value: int, synthetic_value: bool, health: float, armor: float, buildable_value: bool, requirements_length: int, build_time: float, instant_transfer: bool, consumers: Array, has_liquids: bool, liquid_capacity: float, has_items: bool, item_capacity: int) -> Dictionary:
	return set_stats_state(size_value, synthetic_value, health, armor, buildable_value, requirements_length, build_time, instant_transfer, consumers, has_liquids, liquid_capacity, has_items, item_capacity)

static func generated_add_bar_result_state(bar_name: String, bar_supplier: Variant, bar_map_before: Dictionary) -> Dictionary:
	return add_bar_state(bar_name, bar_supplier, bar_map_before)

static func generated_remove_bar_result_state(bar_name: String, bar_map_before: Dictionary) -> Dictionary:
	return remove_bar_state(bar_name, bar_map_before)

static func generated_list_bars_result_state(bar_map: Dictionary) -> Dictionary:
	return list_bars_state(bar_map)

static func generated_add_liquid_bar_static_result_state(liquid_name: String, liquid_unlocked: bool, liquid_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant) -> Dictionary:
	return add_liquid_bar_static_state(liquid_name, liquid_unlocked, liquid_amount, liquid_capacity, localized_name, bar_color)

static func generated_add_liquid_bar_dynamic_result_state(current_liquid: Variant, current_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant, empty_threshold: float = source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_EMPTY_THRESHOLD) -> Dictionary:
	return add_liquid_bar_dynamic_state(current_liquid, current_amount, liquid_capacity, localized_name, bar_color, empty_threshold)

static func generated_set_bars_result_state(cons_power_present: bool, has_items: bool, configurable: bool, item_total: int, item_capacity: int, unit_cap_modifier: int, has_liquids: bool, static_liquid_bar_added: bool) -> Dictionary:
	return set_bars_state(cons_power_present, has_items, configurable, item_total, item_capacity, unit_cap_modifier, has_liquids, static_liquid_bar_added)

static func generated_after_patch_result_state(size_value: int, source_tilesize: float, content_items_size: int, content_liquids_size: int, consume_builder: Array) -> Dictionary:
	return after_patch_stats_bars_state(size_value, source_tilesize, content_items_size, content_liquids_size, consume_builder)

static func generated_block_set_stats_bridge_state(size_value: int, synthetic_value: bool, health: float, armor: float, buildable_value: bool, requirements_length: int, build_time: float, instant_transfer: bool, consumers: Array, has_liquids: bool, liquid_capacity: float, has_items: bool, item_capacity: int) -> Dictionary:
	var result = _block_call(source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_JAVA_METHOD, [size_value, synthetic_value, health, armor, buildable_value, requirements_length, build_time, instant_transfer, consumers, has_liquids, liquid_capacity, has_items, item_capacity])
	var canonical = set_stats_state(size_value, synthetic_value, health, armor, buildable_value, requirements_length, build_time, instant_transfer, consumers, has_liquids, liquid_capacity, has_items, item_capacity)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SET_STATS_STATE, "generated_owner": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_STATS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_add_bar_bridge_state(bar_name: String, bar_supplier: Variant, bar_map_before: Dictionary) -> Dictionary:
	var result = _block_call(source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_BAR_JAVA_METHOD, [bar_name, bar_supplier, bar_map_before])
	var canonical = add_bar_state(bar_name, bar_supplier, bar_map_before)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ADD_BAR_STATE, "generated_owner": source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_BAR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_remove_bar_bridge_state(bar_name: String, bar_map_before: Dictionary) -> Dictionary:
	var result = _block_call(source_block_stats_bars_source_text_state.SOURCE_BLOCK_REMOVE_BAR_JAVA_METHOD, [bar_name, bar_map_before])
	var canonical = remove_bar_state(bar_name, bar_map_before)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REMOVE_BAR_STATE, "generated_owner": source_block_stats_bars_source_text_state.SOURCE_BLOCK_REMOVE_BAR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_list_bars_bridge_state(bar_map: Dictionary) -> Dictionary:
	var result = _block_call(source_block_stats_bars_source_text_state.SOURCE_BLOCK_LIST_BARS_JAVA_METHOD, [bar_map])
	var canonical = list_bars_state(bar_map)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_LIST_BARS_STATE, "generated_owner": source_block_stats_bars_source_text_state.SOURCE_BLOCK_LIST_BARS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_add_liquid_bar_static_bridge_state(liquid_name: String, liquid_unlocked: bool, liquid_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant) -> Dictionary:
	var result = _block_call(source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_JAVA_METHOD, [liquid_name, liquid_unlocked, liquid_amount, liquid_capacity, localized_name, bar_color])
	var canonical = add_liquid_bar_static_state(liquid_name, liquid_unlocked, liquid_amount, liquid_capacity, localized_name, bar_color)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_STATE, "generated_owner": source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_add_liquid_bar_dynamic_bridge_state(current_liquid: Variant, current_amount: float, liquid_capacity: float, localized_name: String, bar_color: Variant, empty_threshold: float = source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_EMPTY_THRESHOLD) -> Dictionary:
	var result = _block_call(source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_JAVA_METHOD, [current_liquid, current_amount, liquid_capacity, localized_name, bar_color, empty_threshold])
	var canonical = add_liquid_bar_dynamic_state(current_liquid, current_amount, liquid_capacity, localized_name, bar_color, empty_threshold)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_STATE, "generated_owner": source_block_stats_bars_source_text_state.SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_set_bars_bridge_state(cons_power_present: bool, has_items: bool, configurable: bool, item_total: int, item_capacity: int, unit_cap_modifier: int, has_liquids: bool, static_liquid_bar_added: bool) -> Dictionary:
	var result = _block_call(source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_JAVA_METHOD, [cons_power_present, has_items, configurable, item_total, item_capacity, unit_cap_modifier, has_liquids, static_liquid_bar_added])
	var canonical = set_bars_state(cons_power_present, has_items, configurable, item_total, item_capacity, unit_cap_modifier, has_liquids, static_liquid_bar_added)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SET_BARS_STATE, "generated_owner": source_block_stats_bars_source_text_state.SOURCE_BLOCK_SET_BARS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_after_patch_stats_bars_bridge_state(size_value: int, source_tilesize: float, content_items_size: int, content_liquids_size: int, consume_builder: Array) -> Dictionary:
	var result = _block_call(source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_JAVA_METHOD, [size_value, source_tilesize, content_items_size, content_liquids_size, consume_builder])
	var canonical = after_patch_stats_bars_state(size_value, source_tilesize, content_items_size, content_liquids_size, consume_builder)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_AFTER_PATCH_STATS_BARS_STATE, "generated_owner": source_block_stats_bars_source_text_state.SOURCE_BLOCK_AFTER_PATCH_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}
