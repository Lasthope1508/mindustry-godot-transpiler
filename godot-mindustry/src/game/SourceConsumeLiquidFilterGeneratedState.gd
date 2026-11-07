extends RefCounted
class_name SourceConsumeLiquidFilterGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const source_consume_liquid_filter_state := preload("res://src/game/SourceConsumeLiquidFilterState.gd")

const SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS
const SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_APPLY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_APPLY_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_BUILD_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_BUILD_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_UPDATE_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_UPDATE_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_APPLY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_APPLY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_BUILD_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_BUILD_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_UPDATE_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_UPDATE_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_GENERATED_OWNER

static func generated_constructor_bridge_state(filter_handle: Variant, amount: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR_JAVA_METHOD, [filter_handle, amount], null)
	var canonical = source_consume_liquid_filter_state.constructor_state(filter_handle, amount)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_default_constructor_bridge_state(default_filter_expr: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR_JAVA_METHOD, [], null)
	var canonical = source_consume_liquid_filter_state.default_constructor_state(default_filter_expr)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, filtered_liquid_ids: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_APPLY_JAVA_METHOD, [block_has_liquids_before, liquid_filter_before, filtered_liquid_ids], null)
	var canonical = source_consume_liquid_filter_state.apply_state(block_has_liquids_before, liquid_filter_before, filtered_liquid_ids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_APPLY_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_APPLY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_bridge_state(filtered_liquid_ids: Array, consumed_liquid: Variant, source_ui_icon_med: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_BUILD_JAVA_METHOD, [filtered_liquid_ids, consumed_liquid], null)
	var canonical = source_consume_liquid_filter_state.build_state(filtered_liquid_ids, consumed_liquid, source_ui_icon_med)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_BUILD_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_BUILD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_get_consumed_bridge_state(current_liquid: Variant, current_filter_get_liquid: bool, current_amount: float, content_liquids: Array, filter_get_liquid_flags: Array, build_liquid_amounts: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_JAVA_METHOD, [current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts], null)
	var canonical = source_consume_liquid_filter_state.get_consumed_state(current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_GET_CONSUMED_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_update_bridge_state(consumed_liquid: Variant, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_UPDATE_JAVA_METHOD, [consumed_liquid, amount, build_edelta, multiplier_get_build], null)
	var canonical = source_consume_liquid_filter_state.update_state(consumed_liquid, amount, build_edelta, multiplier_get_build)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_UPDATE_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_UPDATE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_efficiency_bridge_state(consumed_liquid: Variant, build_liquids_get: float, amount: float, build_edelta: float, multiplier_get_build: float, source_consume_efficiency_epsilon: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_JAVA_METHOD, [consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build], null)
	var canonical = source_consume_liquid_filter_state.efficiency_state(consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build, source_consume_efficiency_epsilon)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_EFFICIENCY_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_efficiency_multiplier_bridge_state(consumed_liquid: Variant, liquid_efficiency_multiplier: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_JAVA_METHOD, [consumed_liquid, liquid_efficiency_multiplier], null)
	var canonical = source_consume_liquid_filter_state.efficiency_multiplier_state(consumed_liquid, liquid_efficiency_multiplier)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_liquid_efficiency_multiplier_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_JAVA_METHOD, [], null)
	var canonical = source_consume_liquid_filter_state.liquid_efficiency_multiplier_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_LIQUID_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_display_bridge_state(booster: bool, amount: float, filtered_liquid_ids: Array, source_tick_rate: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_JAVA_METHOD, [booster, amount, filtered_liquid_ids, source_tick_rate], null)
	var canonical = source_consume_liquid_filter_state.display_state(booster, amount, filtered_liquid_ids, source_tick_rate)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_DISPLAY_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_consumes_bridge_state(filter_get_liquid: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_JAVA_METHOD, [filter_get_liquid], null)
	var canonical = source_consume_liquid_filter_state.consumes_state(filter_get_liquid)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_CONSUMES_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
