extends RefCounted
class_name SourceBlockCheckContentArrayCapacityState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_check_content_array_capacity_source_text_state := preload("res://src/game/SourceBlockCheckContentArrayCapacitySourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_SOURCE := source_block_check_content_array_capacity_source_text_state.SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_SOURCE
const SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_METHOD := source_block_check_content_array_capacity_source_text_state.SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_METHOD
const SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_JAVA_METHOD_CHECK_CONTENT_ARRAY_CAPACITY_125 := source_block_check_content_array_capacity_source_text_state.SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_JAVA_METHOD_CHECK_CONTENT_ARRAY_CAPACITY_125
const SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_GENERATED_OWNER := source_block_check_content_array_capacity_source_text_state.SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_GENERATED_OWNER
const SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_LIQUID_RESIZE_EXPR := source_block_check_content_array_capacity_source_text_state.SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_LIQUID_RESIZE_EXPR
const SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_ITEM_RESIZE_EXPR := source_block_check_content_array_capacity_source_text_state.SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_ITEM_RESIZE_EXPR

static func _block_call(generated_method: String, generated_args: Array, metadata: Variant = null) -> Variant:
	if metadata == null:
		return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null, metadata)

static func check_content_array_capacity_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	var item_filter_after: Array = []
	for i in range(max(items, 0)):
		item_filter_after.append(bool(item_filter[i]) if i < item_filter.size() else false)
	var liquid_filter_after: Array = []
	for i in range(max(liquids, 0)):
		liquid_filter_after.append(bool(liquid_filter[i]) if i < liquid_filter.size() else false)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_STATE, "source": SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_SOURCE, "method": SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_METHOD, "liquid_resize_expr": SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_LIQUID_RESIZE_EXPR, "item_resize_expr": SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_ITEM_RESIZE_EXPR, "item_filter_before": item_filter, "liquid_filter_before": liquid_filter, "items": items, "liquids": liquids, "item_filter_after": item_filter_after, "liquid_filter_after": liquid_filter_after}

static func generated_check_content_array_capacity_result_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	return check_content_array_capacity_state(item_filter, liquid_filter, items, liquids)

static func generated_block_check_content_array_capacity_bridge_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_JAVA_METHOD_CHECK_CONTENT_ARRAY_CAPACITY_125, [item_filter, liquid_filter, items, liquids])
	var canonical = check_content_array_capacity_state(item_filter, liquid_filter, items, liquids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_STATE, "generated_owner": SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
