extends RefCounted
class_name SourceConsumeItemListGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_item_list_state := preload("res://src/game/SourceConsumeItemListState.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE_CONSUME_ITEM_LIST_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_ITEM_LIST_GENERATED_CLASS
const SOURCE_CONSUME_ITEM_LIST_SET_MULTIPLIERS_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_LIST_SET_MULTIPLIERS_JAVA_METHOD
const SOURCE_CONSUME_ITEM_LIST_EFFICIENCY_MULTIPLIER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_LIST_EFFICIENCY_MULTIPLIER_JAVA_METHOD
const SOURCE_CONSUME_ITEM_LIST_SET_MULTIPLIERS_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_LIST_SET_MULTIPLIERS_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_LIST_EFFICIENCY_MULTIPLIER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_LIST_EFFICIENCY_MULTIPLIER_GENERATED_OWNER

static func generated_set_multipliers_bridge_state(objects: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_LIST_GENERATED_CLASS, SOURCE_CONSUME_ITEM_LIST_SET_MULTIPLIERS_JAVA_METHOD, [objects], null)
	var canonical = source_consume_item_list_state.set_multipliers_state(objects)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_LIST_SET_MULTIPLIERS_STATE, "generated_owner": SOURCE_CONSUME_ITEM_LIST_SET_MULTIPLIERS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_efficiency_multiplier_bridge_state(consumed_item: Variant, item_multiplier_value: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_LIST_GENERATED_CLASS, SOURCE_CONSUME_ITEM_LIST_EFFICIENCY_MULTIPLIER_JAVA_METHOD, [consumed_item, item_multiplier_value], null)
	var canonical = source_consume_item_list_state.efficiency_multiplier_state(consumed_item, item_multiplier_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_LIST_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": SOURCE_CONSUME_ITEM_LIST_EFFICIENCY_MULTIPLIER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
