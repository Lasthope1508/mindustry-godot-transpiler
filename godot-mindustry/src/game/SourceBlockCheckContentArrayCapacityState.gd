extends RefCounted
class_name SourceBlockCheckContentArrayCapacityState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func check_content_array_capacity_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	var item_filter_after: Array = []
	for i in range(max(items, 0)):
		item_filter_after.append(bool(item_filter[i]) if i < item_filter.size() else false)
	var liquid_filter_after: Array = []
	for i in range(max(liquids, 0)):
		liquid_filter_after.append(bool(liquid_filter[i]) if i < liquid_filter.size() else false)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void checkContentArrayCapacity(int items, int liquids){", "liquid_resize_expr": "if(liquidFilter.length != liquids) liquidFilter = Arrays.copyOf(liquidFilter, liquids);", "item_resize_expr": "if(itemFilter.length != items) itemFilter = Arrays.copyOf(itemFilter, items);", "item_filter_before": item_filter, "liquid_filter_before": liquid_filter, "items": items, "liquids": liquids, "item_filter_after": item_filter_after, "liquid_filter_after": liquid_filter_after}

static func generated_block_check_content_array_capacity_bridge_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_checkContentArrayCapacity_125", [item_filter, liquid_filter, items, liquids], null)
	var canonical = check_content_array_capacity_state(item_filter, liquid_filter, items, liquids)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_STATE, "generated_owner": "block.java_method_checkContentArrayCapacity_125", "result": result, "canonical": canonical, "matches": matches}
