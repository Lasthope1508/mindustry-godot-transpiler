class_name SourceBlockQueryState
extends RefCounted

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_query_source_text_state := preload("res://src/game/SourceBlockQuerySourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_QUERY_SOURCE := source_block_query_source_text_state.SOURCE_BLOCK_QUERY_SOURCE
const SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_FIELD_COMMENT := source_block_query_source_text_state.SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_FIELD_COMMENT
const SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_FIELD_EXPR := source_block_query_source_text_state.SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_FIELD_EXPR
const SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_METHOD := source_block_query_source_text_state.SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_METHOD
const SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_RETURN_EXPR := source_block_query_source_text_state.SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_RETURN_EXPR
const SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_JAVA_METHOD_OUTPUTS_ITEMS_17 := source_block_query_source_text_state.SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_JAVA_METHOD_OUTPUTS_ITEMS_17
const SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_GENERATED_OWNER := source_block_query_source_text_state.SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_GENERATED_OWNER

static func _block_call(generated_method: String, generated_args: Array, metadata: Variant = null) -> Variant:
	if metadata == null:
		return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null, metadata)

static func outputs_items_state(has_items: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_OUTPUTS_ITEMS_STATE, "source": SOURCE_BLOCK_QUERY_SOURCE, "field_comment": SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_FIELD_COMMENT, "field_expr": SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_FIELD_EXPR, "method": SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_METHOD, "return_expr": SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_RETURN_EXPR, "has_items": has_items, "outputs_items": has_items}

static func generated_outputs_items_result_state(has_items: bool) -> Dictionary:
	return outputs_items_state(has_items)

static func generated_block_outputs_items_bridge_state(has_items: bool) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_JAVA_METHOD_OUTPUTS_ITEMS_17, [has_items])
	var canonical = outputs_items_state(has_items)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_OUTPUTS_ITEMS_STATE, "generated_owner": SOURCE_BLOCK_QUERY_OUTPUTS_ITEMS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
