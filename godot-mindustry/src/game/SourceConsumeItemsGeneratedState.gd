extends RefCounted
class_name SourceConsumeItemsGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const source_consume_items_state := preload("res://src/game/SourceConsumeItemsState.gd")

const SOURCE_CONSUME_ITEMS_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_GENERATED_CLASS
const SOURCE_CONSUME_ITEMS_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_ITEMS_DEFAULT_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_DEFAULT_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_ITEMS_APPLY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_APPLY_JAVA_METHOD
const SOURCE_CONSUME_ITEMS_BUILD_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_BUILD_JAVA_METHOD
const SOURCE_CONSUME_ITEMS_TRIGGER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_TRIGGER_JAVA_METHOD
const SOURCE_CONSUME_ITEMS_EFFICIENCY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_EFFICIENCY_JAVA_METHOD
const SOURCE_CONSUME_ITEMS_DISPLAY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_DISPLAY_JAVA_METHOD
const SOURCE_CONSUME_ITEMS_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_ITEMS_DEFAULT_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_DEFAULT_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_ITEMS_APPLY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_APPLY_GENERATED_OWNER
const SOURCE_CONSUME_ITEMS_BUILD_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_BUILD_GENERATED_OWNER
const SOURCE_CONSUME_ITEMS_TRIGGER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_TRIGGER_GENERATED_OWNER
const SOURCE_CONSUME_ITEMS_EFFICIENCY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_EFFICIENCY_GENERATED_OWNER
const SOURCE_CONSUME_ITEMS_DISPLAY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEMS_DISPLAY_GENERATED_OWNER

static func generated_constructor_bridge_state(item_stacks: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEMS_GENERATED_CLASS, SOURCE_CONSUME_ITEMS_CONSTRUCTOR_JAVA_METHOD, [item_stacks], null)
	var canonical = source_consume_items_state.constructor_state(item_stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_ITEMS_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_default_constructor_bridge_state(empty_stacks: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEMS_GENERATED_CLASS, SOURCE_CONSUME_ITEMS_DEFAULT_CONSTRUCTOR_JAVA_METHOD, [], null)
	var canonical = source_consume_items_state.default_constructor_state(empty_stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_ITEMS_DEFAULT_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, item_stacks: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEMS_GENERATED_CLASS, SOURCE_CONSUME_ITEMS_APPLY_JAVA_METHOD, [block_has_items_before, block_accepts_items_before, item_filter_before, item_stacks], null)
	var canonical = source_consume_items_state.apply_state(block_has_items_before, block_accepts_items_before, item_filter_before, item_stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_APPLY_STATE, "generated_owner": SOURCE_CONSUME_ITEMS_APPLY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_bridge_state(item_stacks: Array, item_amounts: Array, multiplier_get_build: float, source_ui_pad_right: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEMS_GENERATED_CLASS, SOURCE_CONSUME_ITEMS_BUILD_JAVA_METHOD, [item_stacks, item_amounts, multiplier_get_build], null)
	var canonical = source_consume_items_state.build_state(item_stacks, item_amounts, multiplier_get_build, source_ui_pad_right)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_BUILD_STATE, "generated_owner": SOURCE_CONSUME_ITEMS_BUILD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_trigger_bridge_state(item_stacks: Array, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEMS_GENERATED_CLASS, SOURCE_CONSUME_ITEMS_TRIGGER_JAVA_METHOD, [item_stacks, multiplier_get_build], null)
	var canonical = source_consume_items_state.trigger_state(item_stacks, multiplier_get_build)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_TRIGGER_STATE, "generated_owner": SOURCE_CONSUME_ITEMS_TRIGGER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_efficiency_bridge_state(consume_trigger_valid: bool, item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEMS_GENERATED_CLASS, SOURCE_CONSUME_ITEMS_EFFICIENCY_JAVA_METHOD, [consume_trigger_valid, item_stacks, item_amounts, multiplier_get_build], null)
	var canonical = source_consume_items_state.efficiency_state(consume_trigger_valid, item_stacks, item_amounts, multiplier_get_build)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_EFFICIENCY_STATE, "generated_owner": SOURCE_CONSUME_ITEMS_EFFICIENCY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_display_bridge_state(booster: bool, stats_time_period: float, item_stacks: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEMS_GENERATED_CLASS, SOURCE_CONSUME_ITEMS_DISPLAY_JAVA_METHOD, [booster, stats_time_period, item_stacks], null)
	var canonical = source_consume_items_state.display_state(booster, stats_time_period, item_stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_DISPLAY_STATE, "generated_owner": SOURCE_CONSUME_ITEMS_DISPLAY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
