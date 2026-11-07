extends RefCounted
class_name SourceBlockGetDependenciesState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_get_dependencies_source_text_state := preload("res://src/game/SourceBlockGetDependenciesSourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_GET_DEPENDENCIES_SOURCE := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_SOURCE
const SOURCE_BLOCK_GET_DEPENDENCIES_METHOD := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_METHOD
const SOURCE_BLOCK_GET_DEPENDENCIES_JAVA_METHOD_GET_DEPENDENCIES_119 := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_JAVA_METHOD_GET_DEPENDENCIES_119
const SOURCE_BLOCK_GET_DEPENDENCIES_GENERATED_OWNER := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_GENERATED_OWNER
const SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_COMMENT := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_COMMENT
const SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_LOOP_EXPR := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_LOOP_EXPR
const SOURCE_BLOCK_GET_DEPENDENCIES_CONS_GET_ITEM_EXPR := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_CONS_GET_ITEM_EXPR
const SOURCE_BLOCK_GET_DEPENDENCIES_INPUTS_COMMENT := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_INPUTS_COMMENT
const SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_BUILDER_LOOP_EXPR := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_BUILDER_LOOP_EXPR
const SOURCE_BLOCK_GET_DEPENDENCIES_OPTIONAL_GUARD_EXPR := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_OPTIONAL_GUARD_EXPR
const SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_GUARD_EXPR := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_GUARD_EXPR
const SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_LOOP_EXPR := source_block_get_dependencies_source_text_state.SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_LOOP_EXPR

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func requirements_state(requirements: Array) -> Dictionary:
	var dependency_items: Array = []
	for requirement in requirements:
		dependency_items.append(requirement.get("item"))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_STATE, "source": SOURCE_BLOCK_GET_DEPENDENCIES_SOURCE, "method": SOURCE_BLOCK_GET_DEPENDENCIES_METHOD, "requirements_comment": SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_COMMENT, "requirements_loop_expr": SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_LOOP_EXPR, "cons_get_item_expr": SOURCE_BLOCK_GET_DEPENDENCIES_CONS_GET_ITEM_EXPR, "requirements": requirements, "dependency_items": dependency_items}

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
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_BUILDER_OPTIONAL_STATE, "source": SOURCE_BLOCK_GET_DEPENDENCIES_SOURCE, "method": SOURCE_BLOCK_GET_DEPENDENCIES_METHOD, "inputs_comment": SOURCE_BLOCK_GET_DEPENDENCIES_INPUTS_COMMENT, "consume_builder_loop_expr": SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_BUILDER_LOOP_EXPR, "optional_guard_expr": SOURCE_BLOCK_GET_DEPENDENCIES_OPTIONAL_GUARD_EXPR, "requirements": requirements, "dependency_items": dependency_items, "consume_builder": consume_builder, "consume_loop_indices": consume_loop_indices, "skipped_optional_indices": skipped_optional_indices, "non_optional_indices": non_optional_indices}

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
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_STATE, "source": SOURCE_BLOCK_GET_DEPENDENCIES_SOURCE, "method": SOURCE_BLOCK_GET_DEPENDENCIES_METHOD, "consume_items_guard_expr": SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_GUARD_EXPR, "consume_items_loop_expr": SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_LOOP_EXPR, "consume_items_cons_get_item_expr": SOURCE_BLOCK_GET_DEPENDENCIES_CONS_GET_ITEM_EXPR, "requirements": requirements, "dependency_items": dependency_items, "consume_builder": consume_builder, "consume_loop_indices": consume_loop_indices, "skipped_optional_indices": skipped_optional_indices, "non_optional_indices": non_optional_indices, "consume_items_indices": consume_items_indices, "consume_item_dependency_items": consume_item_dependency_items}

static func generated_block_get_dependencies_requirements_bridge_state(requirements: Array) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_GET_DEPENDENCIES_JAVA_METHOD_GET_DEPENDENCIES_119, [requirements])
	var canonical = requirements_state(requirements)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_REQUIREMENTS_STATE, "generated_owner": SOURCE_BLOCK_GET_DEPENDENCIES_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_GET_DEPENDENCIES_JAVA_METHOD_GET_DEPENDENCIES_119, [requirements, consume_builder])
	var canonical = consume_builder_optional_state(requirements, consume_builder)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_BUILDER_OPTIONAL_STATE, "generated_owner": SOURCE_BLOCK_GET_DEPENDENCIES_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_block_get_dependencies_consume_items_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_GET_DEPENDENCIES_JAVA_METHOD_GET_DEPENDENCIES_119, [requirements, consume_builder, true])
	var canonical = consume_items_state(requirements, consume_builder)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DEPENDENCIES_CONSUME_ITEMS_STATE, "generated_owner": SOURCE_BLOCK_GET_DEPENDENCIES_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}
