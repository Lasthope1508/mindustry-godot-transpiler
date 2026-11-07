extends RefCounted
class_name SourceConsumeItemFilterGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const source_consume_item_filter_state := preload("res://src/game/SourceConsumeItemFilterState.gd")

const SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS
const SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_APPLY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_APPLY_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_BUILD_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_BUILD_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_UPDATE_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_UPDATE_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_TRIGGER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_TRIGGER_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_JAVA_METHOD
const SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_APPLY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_APPLY_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_BUILD_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_BUILD_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_UPDATE_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_UPDATE_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_TRIGGER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_TRIGGER_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_DISPLAY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_DISPLAY_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_GENERATED_OWNER

static func generated_item_efficiency_multiplier_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_JAVA_METHOD, [], null)
	var canonical = source_consume_item_filter_state.item_efficiency_multiplier_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_ITEM_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_constructor_bridge_state(item: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_JAVA_METHOD, [item], null)
	var canonical = source_consume_item_filter_state.constructor_state(item)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_default_constructor_bridge_state(default_filter_expr: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR_JAVA_METHOD, [], null)
	var canonical = source_consume_item_filter_state.default_constructor_state(default_filter_expr)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, filtered_item_ids: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_APPLY_JAVA_METHOD, [block_has_items_before, block_accepts_items_before, item_filter_before, filtered_item_ids], null)
	var canonical = source_consume_item_filter_state.apply_state(block_has_items_before, block_accepts_items_before, item_filter_before, filtered_item_ids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_APPLY_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_APPLY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_bridge_state(filtered_item_ids: Array, build_items_has_item_flags: Array, source_ui_icon_med: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_BUILD_JAVA_METHOD, [filtered_item_ids, build_items_has_item_flags], null)
	var canonical = source_consume_item_filter_state.build_state(filtered_item_ids, build_items_has_item_flags, source_ui_icon_med)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_BUILD_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_BUILD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

@warning_ignore("shadowed_variable")
static func generated_update_bridge_state(build_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_UPDATE_JAVA_METHOD, [build_state], null)
	var canonical = source_consume_item_filter_state.update_state(build_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_UPDATE_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_UPDATE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

@warning_ignore("shadowed_variable")
static func generated_trigger_bridge_state(build_state: Variant, consumed_item: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_TRIGGER_JAVA_METHOD, [build_state, consumed_item], null)
	var canonical = source_consume_item_filter_state.trigger_state(build_state, consumed_item)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_TRIGGER_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_TRIGGER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_efficiency_bridge_state(consume_trigger_valid: bool, consumed_item: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_JAVA_METHOD, [consume_trigger_valid, consumed_item], null)
	var canonical = source_consume_item_filter_state.efficiency_state(consume_trigger_valid, consumed_item)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_EFFICIENCY_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_get_consumed_bridge_state(content_items: Array, build_items_has_item_flags: Array, filter_get_item_flags: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_JAVA_METHOD, [content_items, build_items_has_item_flags, filter_get_item_flags], null)
	var canonical = source_consume_item_filter_state.get_consumed_state(content_items, build_items_has_item_flags, filter_get_item_flags)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_GET_CONSUMED_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_display_bridge_state(booster: bool, stats_time_period: float, filtered_item_ids: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_DISPLAY_JAVA_METHOD, [booster, stats_time_period, filtered_item_ids], null)
	var canonical = source_consume_item_filter_state.display_state(booster, stats_time_period, filtered_item_ids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_DISPLAY_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_DISPLAY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_efficiency_multiplier_bridge_state(consumed_item: Variant, item_efficiency_multiplier: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS, SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_JAVA_METHOD, [consumed_item, item_efficiency_multiplier], null)
	var canonical = source_consume_item_filter_state.efficiency_multiplier_state(consumed_item, item_efficiency_multiplier)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
