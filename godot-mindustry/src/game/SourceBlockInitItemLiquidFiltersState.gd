extends RefCounted
class_name SourceBlockInitItemLiquidFiltersState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func item_liquid_filters_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	var item_filter: Array = []
	for _i in range(max(content_items_size, 0)):
		item_filter.append(false)
	var liquid_filter: Array = []
	for _i in range(max(content_liquids_size, 0)):
		liquid_filter.append(false)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_ITEM_LIQUID_FILTERS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "item_filter_expr": "itemFilter = new boolean[content.items().size];", "liquid_filter_expr": "liquidFilter = new boolean[content.liquids().size];", "content_items_size": content_items_size, "content_liquids_size": content_liquids_size, "item_filter": item_filter, "liquid_filter": liquid_filter, "item_filter_size": item_filter.size(), "liquid_filter_size": liquid_filter.size()}

static func generated_block_init_item_liquid_filters_bridge_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [content_items_size, content_liquids_size], null, {"mindustry_init_bridge_mode": "item_liquid_filters"})
	var canonical = item_liquid_filters_state(content_items_size, content_liquids_size)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_ITEM_LIQUID_FILTERS_STATE, "generated_owner": "block.java_method_init_123", "result": result, "canonical": canonical, "matches": matches}
