extends RefCounted
class_name SourceConsumeLiquidsGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const source_consume_liquids_state := preload("res://src/game/SourceConsumeLiquidsState.gd")

const SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS
const SOURCE_CONSUME_LIQUIDS_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_DEFAULT_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DEFAULT_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_APPLY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_APPLY_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_BUILD_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_BUILD_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_UPDATE_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_UPDATE_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_EFFICIENCY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_EFFICIENCY_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_DISPLAY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DISPLAY_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_DEFAULT_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DEFAULT_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_APPLY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_APPLY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_BUILD_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_BUILD_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_UPDATE_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_UPDATE_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_EFFICIENCY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_EFFICIENCY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_DISPLAY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DISPLAY_GENERATED_OWNER

static func generated_constructor_bridge_state(liquid_stacks: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_CONSTRUCTOR_JAVA_METHOD, [liquid_stacks], null)
	var canonical = source_consume_liquids_state.constructor_state(liquid_stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_default_constructor_bridge_state(empty_stacks: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_DEFAULT_CONSTRUCTOR_JAVA_METHOD, [], null)
	var canonical = source_consume_liquids_state.default_constructor_state(empty_stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_DEFAULT_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_ids: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_APPLY_JAVA_METHOD, [block_has_liquids_before, liquid_filter_before, liquid_ids], null)
	var canonical = source_consume_liquids_state.apply_state(block_has_liquids_before, liquid_filter_before, liquid_ids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_APPLY_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_APPLY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_bridge_state(liquid_ids: Array, liquid_amounts: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_BUILD_JAVA_METHOD, [liquid_ids, liquid_amounts], null)
	var canonical = source_consume_liquids_state.build_state(liquid_ids, liquid_amounts)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_BUILD_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_BUILD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_update_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_UPDATE_JAVA_METHOD, [liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build], null)
	var canonical = source_consume_liquids_state.update_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_UPDATE_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_UPDATE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_efficiency_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_EFFICIENCY_JAVA_METHOD, [liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build], null)
	var canonical = source_consume_liquids_state.efficiency_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_EFFICIENCY_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_EFFICIENCY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_display_bridge_state(booster: bool, liquid_ids: Array, liquid_stack_amounts: Array, source_tick_rate: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_DISPLAY_JAVA_METHOD, [booster, liquid_ids, liquid_stack_amounts, source_tick_rate], null)
	var canonical = source_consume_liquids_state.display_state(booster, liquid_ids, liquid_stack_amounts)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DISPLAY_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_DISPLAY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
