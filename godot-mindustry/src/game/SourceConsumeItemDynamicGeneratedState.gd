extends RefCounted
class_name SourceConsumeItemDynamicGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_item_dynamic_state := preload("res://src/game/SourceConsumeItemDynamicState.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS
const SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_JAVA_METHOD
const SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_JAVA_METHOD
const SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_JAVA_METHOD
const SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_JAVA_METHOD
const SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_JAVA_METHOD
const SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_GENERATED_OWNER
const SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_GENERATED_OWNER

static func generated_constructor_bridge_state(items: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_JAVA_METHOD, [items], null)
	var canonical = source_consume_item_dynamic_state.constructor_state(items)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_STATE, "generated_owner": SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_JAVA_METHOD, [block_has_items_before, block_accepts_items_before], null)
	var canonical = source_consume_item_dynamic_state.apply_state(block_has_items_before, block_accepts_items_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_STATE, "generated_owner": SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_bridge_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_JAVA_METHOD, [current_item_ids, next_item_ids], null)
	var canonical = source_consume_item_dynamic_state.build_state(current_item_ids, next_item_ids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_STATE, "generated_owner": SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_rebuild_bridge_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float, source_ui_pad_right: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_JAVA_METHOD, [item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build], null)
	var canonical = source_consume_item_dynamic_state.rebuild_state(item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build, source_ui_pad_right)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_STATE, "generated_owner": SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_trigger_bridge_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_JAVA_METHOD, [item_ids, item_stack_amounts, multiplier_get_build], null)
	var canonical = source_consume_item_dynamic_state.trigger_state(item_ids, item_stack_amounts, multiplier_get_build)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_STATE, "generated_owner": SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_efficiency_bridge_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS, SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_JAVA_METHOD, [consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build], null)
	var canonical = source_consume_item_dynamic_state.efficiency_state(consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_STATE, "generated_owner": SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
