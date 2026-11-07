extends RefCounted
class_name SourceConsumeLiquidsDynamicGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_liquids_dynamic_state := preload("res://src/game/SourceConsumeLiquidsDynamicState.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_APPLY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_APPLY_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_BUILD_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_BUILD_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_REBUILD_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_REBUILD_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_UPDATE_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_UPDATE_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_JAVA_METHOD
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_APPLY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_APPLY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_BUILD_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_BUILD_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_REBUILD_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_REBUILD_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_UPDATE_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_UPDATE_GENERATED_OWNER
const SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_GENERATED_OWNER

static func generated_constructor_bridge_state(liquids: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_DYNAMIC_CONSTRUCTOR_JAVA_METHOD, [liquids], null)
	var canonical = source_consume_liquids_dynamic_state.constructor_state(liquids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_DYNAMIC_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_apply_bridge_state(block_has_liquids_before: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_DYNAMIC_APPLY_JAVA_METHOD, [block_has_liquids_before], null)
	var canonical = source_consume_liquids_dynamic_state.apply_state(block_has_liquids_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_APPLY_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_DYNAMIC_APPLY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_bridge_state(current_liquid_ids: Array, next_liquid_ids: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_DYNAMIC_BUILD_JAVA_METHOD, [current_liquid_ids, next_liquid_ids], null)
	var canonical = source_consume_liquids_dynamic_state.build_state(current_liquid_ids, next_liquid_ids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_BUILD_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_DYNAMIC_BUILD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_rebuild_bridge_state(liquid_ids: Array, liquid_amounts: Array, building_has_liquids: bool, source_ui_icon_med: float, source_ui_pad_right: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_DYNAMIC_REBUILD_JAVA_METHOD, [liquid_ids, liquid_amounts, building_has_liquids, source_ui_icon_med, source_ui_pad_right], null)
	var canonical = source_consume_liquids_dynamic_state.rebuild_state(liquid_ids, liquid_amounts, building_has_liquids, source_ui_icon_med, source_ui_pad_right)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_REBUILD_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_DYNAMIC_REBUILD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_update_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_DYNAMIC_UPDATE_JAVA_METHOD, [liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build], null)
	var canonical = source_consume_liquids_dynamic_state.update_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_UPDATE_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_DYNAMIC_UPDATE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_efficiency_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_JAVA_METHOD, [liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, multiplier_get_build], null)
	var canonical = source_consume_liquids_dynamic_state.efficiency_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, multiplier_get_build)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_STATE, "generated_owner": SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
