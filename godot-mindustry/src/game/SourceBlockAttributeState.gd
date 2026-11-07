extends RefCounted
class_name SourceBlockAttributeState

const source_block_attribute_source_text_state := preload("res://src/game/SourceBlockAttributeSourceTextState.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerBlockRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

const SOURCE_BLOCK_ATTRIBUTE_SOURCE := source_block_attribute_source_text_state.SOURCE_BLOCK_ATTRIBUTE_SOURCE
const SOURCE_BLOCK_SUM_ATTRIBUTE_METHOD := source_block_attribute_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_METHOD
const SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_ATTR_GUARD := source_block_attribute_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_ATTR_GUARD
const SOURCE_BLOCK_SUM_ATTRIBUTE_TILE_LOOKUP := source_block_attribute_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_TILE_LOOKUP
const SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_TILE_GUARD := source_block_attribute_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_TILE_GUARD
const SOURCE_BLOCK_SUM_ATTRIBUTE_LINKED_TILES := source_block_attribute_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_LINKED_TILES
const SOURCE_BLOCK_SUM_ATTRIBUTE_JAVA_METHOD := source_block_attribute_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_JAVA_METHOD
const SOURCE_BLOCK_SUM_ATTRIBUTE_GENERATED_OWNER := source_block_attribute_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_GENERATED_OWNER
const SOURCE_BLOCK_GENERATED_SCRIPT := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS

static func sum_attribute_state(attr_present: bool, tile_present: bool, floating: bool, placeable_liquid: bool, linked_tile_deep_by_index: Array, linked_attribute_value_by_index: Array) -> Dictionary:
	var values: Array = []
	var total: float = 0.0
	if attr_present and tile_present:
		for index in range(linked_attribute_value_by_index.size()):
			var value: float = float(linked_attribute_value_by_index[index])
			var deep: bool = bool(linked_tile_deep_by_index[index] if index < linked_tile_deep_by_index.size() else false)
			var included: bool = floating or placeable_liquid or not deep
			var contribution: float = value if included else 0.0
			values.append({"index": index, "deep": deep, "value": value, "included": included, "contribution": contribution})
			total += contribution
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SUM_ATTRIBUTE_STATE, "source": SOURCE_BLOCK_ATTRIBUTE_SOURCE, "method": SOURCE_BLOCK_SUM_ATTRIBUTE_METHOD, "null_attr_guard_expr": SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_ATTR_GUARD, "tile_lookup_expr": SOURCE_BLOCK_SUM_ATTRIBUTE_TILE_LOOKUP, "null_tile_guard_expr": SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_TILE_GUARD, "linked_tiles_expr": SOURCE_BLOCK_SUM_ATTRIBUTE_LINKED_TILES, "attr_present": attr_present, "tile_present": tile_present, "floating": floating, "placeable_liquid": placeable_liquid, "linked_tile_deep_by_index": linked_tile_deep_by_index, "linked_attribute_value_by_index": linked_attribute_value_by_index, "values": values, "sum": total}

static func generated_block_sum_attribute_result_state(attr_present: bool, tile_present: bool, floating: bool, placeable_liquid: bool, linked_tile_deep_by_index: Array, linked_attribute_value_by_index: Array) -> Dictionary:
	return sum_attribute_state(attr_present, tile_present, floating, placeable_liquid, linked_tile_deep_by_index, linked_attribute_value_by_index)

static func generated_block_sum_attribute_bridge_state(attr_present: bool, tile_present: bool, floating: bool, placeable_liquid: bool, linked_tile_deep_by_index: Array, linked_attribute_value_by_index: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_SCRIPT, SOURCE_BLOCK_SUM_ATTRIBUTE_JAVA_METHOD, [attr_present, tile_present, floating, placeable_liquid, linked_tile_deep_by_index, linked_attribute_value_by_index])
	var canonical = sum_attribute_state(attr_present, tile_present, floating, placeable_liquid, linked_tile_deep_by_index, linked_attribute_value_by_index)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SUM_ATTRIBUTE_STATE, "generated_owner": SOURCE_BLOCK_SUM_ATTRIBUTE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
