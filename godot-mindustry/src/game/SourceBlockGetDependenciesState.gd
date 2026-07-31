extends RefCounted
class_name SourceBlockGetDependenciesState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func requirements_state(requirements: Array) -> Dictionary:
	var dependency_items: Array = []
	for requirement in requirements:
		dependency_items.append(requirement.get("item"))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void getDependencies(Cons<UnlockableContent> cons){", "requirements_comment": "//just requires items", "requirements_loop_expr": "for(ItemStack stack : requirements){", "cons_get_item_expr": "cons.get(stack.item);", "requirements": requirements, "dependency_items": dependency_items}

static func consume_builder_optional_state(requirements: Array, consume_builder: Array) -> Dictionary:
	var dependency_items: Array = []
	for requirement in requirements:
		dependency_items.append(requirement.get("item"))
	var consume_loop_indices: Array = []
	var skipped_optional_indices: Array = []
	var non_optional_indices: Array = []
	for i in range(consume_builder.size()):
		consume_loop_indices.append(i)
		var consume: Dictionary = consume_builder[i]
		if bool(consume.get("optional", false)):
			skipped_optional_indices.append(i)
			continue
		non_optional_indices.append(i)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_BUILDER_OPTIONAL_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void getDependencies(Cons<UnlockableContent> cons){", "inputs_comment": "//also requires inputs", "consume_builder_loop_expr": "for(var c : consumeBuilder){", "optional_guard_expr": "if(c.optional) continue;", "requirements": requirements, "dependency_items": dependency_items, "consume_builder": consume_builder, "consume_loop_indices": consume_loop_indices, "skipped_optional_indices": skipped_optional_indices, "non_optional_indices": non_optional_indices}

static func consume_items_state(requirements: Array, consume_builder: Array) -> Dictionary:
	var dependency_items: Array = []
	for requirement in requirements:
		dependency_items.append(requirement.get("item"))
	var consume_loop_indices: Array = []
	var skipped_optional_indices: Array = []
	var non_optional_indices: Array = []
	var consume_items_indices: Array = []
	var consume_item_dependency_items: Array = []
	for i in range(consume_builder.size()):
		var consume: Dictionary = consume_builder[i]
		consume_loop_indices.append(i)
		if bool(consume.get("optional", false)):
			skipped_optional_indices.append(i)
			continue
		non_optional_indices.append(i)
		if str(consume.get("type", "")) != "ConsumeItems":
			continue
		consume_items_indices.append(i)
		for stack in consume.get("items", []):
			consume_item_dependency_items.append(stack.get("item"))
			dependency_items.append(stack.get("item"))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void getDependencies(Cons<UnlockableContent> cons){", "consume_items_guard_expr": "if(c instanceof ConsumeItems i){", "consume_items_loop_expr": "for(ItemStack stack : i.items){", "consume_items_cons_get_item_expr": "cons.get(stack.item);", "requirements": requirements, "dependency_items": dependency_items, "consume_builder": consume_builder, "consume_loop_indices": consume_loop_indices, "skipped_optional_indices": skipped_optional_indices, "non_optional_indices": non_optional_indices, "consume_items_indices": consume_items_indices, "consume_item_dependency_items": consume_item_dependency_items}

static func generated_block_get_dependencies_requirements_bridge_state(requirements: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_getDependencies_119", [requirements], null)
	var canonical = requirements_state(requirements)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_STATE, "generated_owner": "block.java_method_getDependencies_119", "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_getDependencies_119", [requirements, consume_builder], null)
	var canonical = consume_builder_optional_state(requirements, consume_builder)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_BUILDER_OPTIONAL_STATE, "generated_owner": "block.java_method_getDependencies_119", "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_get_dependencies_consume_items_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_getDependencies_119", [requirements, consume_builder, true], null)
	var canonical = consume_items_state(requirements, consume_builder)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_STATE, "generated_owner": "block.java_method_getDependencies_119", "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}
