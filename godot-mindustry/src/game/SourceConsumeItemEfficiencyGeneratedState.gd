extends RefCounted
class_name SourceConsumeItemEfficiencyGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_item_efficiency_state := preload("res://src/game/SourceConsumeItemEfficiencyState.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE_CONSUME_ITEM_EFFICIENCY_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_GENERATED_CLASS
const SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_JAVA_METHOD
const SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_GENERATED_OWNER

static func generated_constructor_bridge_state(item: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_EFFICIENCY_GENERATED_CLASS, SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_JAVA_METHOD, [item], null)
	var canonical = source_consume_item_efficiency_state.constructor_state(item)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_default_constructor_bridge_state(default_filter_expr: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_EFFICIENCY_GENERATED_CLASS, SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_JAVA_METHOD, [], null)
	var canonical = source_consume_item_efficiency_state.default_constructor_state(default_filter_expr)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_display_bridge_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool, source_tick_rate: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_EFFICIENCY_GENERATED_CLASS, SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_JAVA_METHOD, [booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, source_tick_rate], null)
	var canonical = source_consume_item_efficiency_state.display_state(booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, source_tick_rate)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_STATE, "generated_owner": SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
