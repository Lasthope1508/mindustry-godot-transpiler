class_name SourceBlockQueryFilterState
extends RefCounted

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func consumes_item_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	var consumes_item_value: bool = bool(item_filter[item_id])
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CONSUMES_ITEM_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean consumesItem(Item item){", "return_expr": "return itemFilter[item.id];", "itemFilter": item_filter, "item_id": item_id, "item": item, "consumes_item": consumes_item_value}

static func consumes_liquid_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	var consumes_liquid_value: bool = bool(liquid_filter[liquid_id])
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CONSUMES_LIQUID_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean consumesLiquid(Liquid liq){", "return_expr": "return liquidFilter[liq.id];", "liquidFilter": liquid_filter, "liq_id": liquid_id, "liq": liq, "consumes_liquid": consumes_liquid_value}

static func generated_block_consumes_item_bridge_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumesItem_33", [item_filter, item_id, item], null)
	var canonical = consumes_item_state(item_filter, item_id, item)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CONSUMES_ITEM_STATE, "generated_owner": "block.java_method_consumesItem_33", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_consumes_liquid_bridge_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_consumesLiquid_34", [liquid_filter, liquid_id, liq], null)
	var canonical = consumes_liquid_state(liquid_filter, liquid_id, liq)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CONSUMES_LIQUID_STATE, "generated_owner": "block.java_method_consumesLiquid_34", "result": result, "canonical": canonical, "matches": matches}
