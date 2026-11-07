class_name SourceBlockQueryFilterState
extends RefCounted

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_query_filter_source_text_state := preload("res://src/game/SourceBlockQueryFilterSourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_CONSUMES_ITEM_METHOD := source_block_source_text_state.SOURCE_BLOCK_CONSUMES_ITEM_METHOD
const SOURCE_BLOCK_CONSUMES_LIQUID_METHOD := source_block_source_text_state.SOURCE_BLOCK_CONSUMES_LIQUID_METHOD
const SOURCE_BLOCK_CONSUMES_ITEM_SOURCE := source_block_query_filter_source_text_state.SOURCE_BLOCK_CONSUMES_ITEM_SOURCE
const SOURCE_BLOCK_CONSUMES_ITEM_RETURN_EXPR := source_block_query_filter_source_text_state.SOURCE_BLOCK_CONSUMES_ITEM_RETURN_EXPR
const SOURCE_BLOCK_CONSUMES_ITEM_JAVA_METHOD_CONSUMES_ITEM_33 := source_block_query_filter_source_text_state.SOURCE_BLOCK_CONSUMES_ITEM_JAVA_METHOD_CONSUMES_ITEM_33
const SOURCE_BLOCK_CONSUMES_ITEM_GENERATED_OWNER := source_block_query_filter_source_text_state.SOURCE_BLOCK_CONSUMES_ITEM_GENERATED_OWNER
const SOURCE_BLOCK_CONSUMES_LIQUID_SOURCE := source_block_query_filter_source_text_state.SOURCE_BLOCK_CONSUMES_LIQUID_SOURCE
const SOURCE_BLOCK_CONSUMES_LIQUID_RETURN_EXPR := source_block_query_filter_source_text_state.SOURCE_BLOCK_CONSUMES_LIQUID_RETURN_EXPR
const SOURCE_BLOCK_CONSUMES_LIQUID_JAVA_METHOD_CONSUMES_LIQUID_34 := source_block_query_filter_source_text_state.SOURCE_BLOCK_CONSUMES_LIQUID_JAVA_METHOD_CONSUMES_LIQUID_34
const SOURCE_BLOCK_CONSUMES_LIQUID_GENERATED_OWNER := source_block_query_filter_source_text_state.SOURCE_BLOCK_CONSUMES_LIQUID_GENERATED_OWNER

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func consumes_item_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	var consumes_item_value: bool = bool(item_filter[item_id])
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CONSUMES_ITEM_STATE, "source": SOURCE_BLOCK_CONSUMES_ITEM_SOURCE, "method": SOURCE_BLOCK_CONSUMES_ITEM_METHOD, "return_expr": SOURCE_BLOCK_CONSUMES_ITEM_RETURN_EXPR, "itemFilter": item_filter, "item_id": item_id, "item": item, "consumes_item": consumes_item_value}

static func consumes_liquid_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	var consumes_liquid_value: bool = bool(liquid_filter[liquid_id])
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CONSUMES_LIQUID_STATE, "source": SOURCE_BLOCK_CONSUMES_LIQUID_SOURCE, "method": SOURCE_BLOCK_CONSUMES_LIQUID_METHOD, "return_expr": SOURCE_BLOCK_CONSUMES_LIQUID_RETURN_EXPR, "liquidFilter": liquid_filter, "liq_id": liquid_id, "liq": liq, "consumes_liquid": consumes_liquid_value}

static func generated_block_consumes_item_bridge_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_CONSUMES_ITEM_JAVA_METHOD_CONSUMES_ITEM_33, [item_filter, item_id, item])
	var canonical = consumes_item_state(item_filter, item_id, item)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CONSUMES_ITEM_STATE, "generated_owner": SOURCE_BLOCK_CONSUMES_ITEM_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_consumes_liquid_bridge_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_CONSUMES_LIQUID_JAVA_METHOD_CONSUMES_LIQUID_34, [liquid_filter, liquid_id, liq])
	var canonical = consumes_liquid_state(liquid_filter, liquid_id, liq)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CONSUMES_LIQUID_STATE, "generated_owner": SOURCE_BLOCK_CONSUMES_LIQUID_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
