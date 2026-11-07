extends RefCounted
class_name SourceConsumeLiquidBaseGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const source_consume_liquid_base_state := preload("res://src/game/SourceConsumeLiquidBaseState.gd")

const SOURCE_CONSUME_LIQUID_BASE_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BASE_GENERATED_CLASS
const SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_BASE_APPLY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BASE_APPLY_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_BASE_CONSUMES_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BASE_CONSUMES_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_BASE_APPLY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BASE_APPLY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_BASE_CONSUMES_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BASE_CONSUMES_GENERATED_OWNER

static func generated_constructor_bridge_state(amount: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_BASE_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_JAVA_METHOD, [amount], null)
	var canonical = source_consume_liquid_base_state.constructor_state(amount)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_apply_bridge_state(block_has_liquids_before: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_BASE_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_BASE_APPLY_JAVA_METHOD, [block_has_liquids_before], null)
	var canonical = source_consume_liquid_base_state.apply_state(block_has_liquids_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_BASE_APPLY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_abstract_consumes_bridge_state(liquid: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_BASE_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_BASE_CONSUMES_JAVA_METHOD, [liquid], null)
	var canonical = source_consume_liquid_base_state.abstract_consumes_state(liquid)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BASE_ABSTRACT_CONSUMES_STATE, "generated_owner": SOURCE_CONSUME_LIQUID_BASE_CONSUMES_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
