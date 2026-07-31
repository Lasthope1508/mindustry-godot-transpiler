class_name SourceBlockQueryState
extends RefCounted

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func outputs_items_state(has_items: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_OUTPUTS_ITEMS_STATE, "source": "core/src/mindustry/world/Block.java", "field_comment": "/** If true, buildings have an ItemModule. */", "field_expr": "public @NoPatch boolean hasItems;", "method": "public boolean outputsItems(){", "return_expr": "return hasItems;", "has_items": has_items, "outputs_items": has_items}


static func generated_block_outputs_items_bridge_state(has_items: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_outputsItems_17", [has_items], null)
	var canonical = outputs_items_state(has_items)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_OUTPUTS_ITEMS_STATE, "generated_owner": "block.java_method_outputsItems_17", "result": result, "canonical": canonical, "matches": matches}
