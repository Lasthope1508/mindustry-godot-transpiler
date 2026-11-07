extends RefCounted
class_name SourceBlockRequirementsState

const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_requirements_source_text_state := preload("res://src/game/SourceBlockRequirementsSourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_REQUIREMENTS_SOURCE := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_SOURCE
const SOURCE_BLOCK_REQUIREMENTS_SETUP_SIMPLE_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_SETUP_SIMPLE_METHOD
const SOURCE_BLOCK_REQUIREMENTS_SETUP_SIMPLE_JAVA_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_SETUP_SIMPLE_JAVA_METHOD
const SOURCE_BLOCK_REQUIREMENTS_SETUP_SIMPLE_GENERATED_OWNER := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_SETUP_SIMPLE_GENERATED_OWNER
const SOURCE_BLOCK_REQUIREMENTS_SETUP_VISIBLE_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_SETUP_VISIBLE_METHOD
const SOURCE_BLOCK_REQUIREMENTS_SETUP_VISIBLE_JAVA_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_SETUP_VISIBLE_JAVA_METHOD
const SOURCE_BLOCK_REQUIREMENTS_SETUP_VISIBLE_GENERATED_OWNER := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_SETUP_VISIBLE_GENERATED_OWNER
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_UNLOCKED_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_UNLOCKED_METHOD
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_UNLOCKED_JAVA_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_UNLOCKED_JAVA_METHOD
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_UNLOCKED_GENERATED_OWNER := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_UNLOCKED_GENERATED_OWNER
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_SIMPLE_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_SIMPLE_METHOD
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_SIMPLE_JAVA_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_SIMPLE_JAVA_METHOD
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_SIMPLE_GENERATED_OWNER := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_SIMPLE_GENERATED_OWNER
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_VISIBLE_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_VISIBLE_METHOD
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_VISIBLE_JAVA_METHOD := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_VISIBLE_JAVA_METHOD
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_VISIBLE_GENERATED_OWNER := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_VISIBLE_GENERATED_OWNER
const SOURCE_BLOCK_REQUIREMENTS_DELEGATE_SETUP_SIMPLE_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_DELEGATE_SETUP_SIMPLE_EXPR
const SOURCE_BLOCK_REQUIREMENTS_DELEGATE_SETUP_VISIBLE_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_DELEGATE_SETUP_VISIBLE_EXPR
const SOURCE_BLOCK_REQUIREMENTS_DELEGATE_REQUIREMENTS_UNLOCKED_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_DELEGATE_REQUIREMENTS_UNLOCKED_EXPR
const SOURCE_BLOCK_REQUIREMENTS_DELEGATE_REQUIREMENTS_SIMPLE_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_DELEGATE_REQUIREMENTS_SIMPLE_EXPR
const SOURCE_BLOCK_REQUIREMENTS_ALWAYS_UNLOCKED_ASSIGNMENT_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_ALWAYS_UNLOCKED_ASSIGNMENT_EXPR
const SOURCE_BLOCK_REQUIREMENTS_COMMENT := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_COMMENT
const SOURCE_BLOCK_REQUIREMENTS_CATEGORY_ASSIGNMENT_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_CATEGORY_ASSIGNMENT_EXPR
const SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_ASSIGNMENT_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_ASSIGNMENT_EXPR
const SOURCE_BLOCK_REQUIREMENTS_BUILD_VISIBILITY_ASSIGNMENT_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_BUILD_VISIBILITY_ASSIGNMENT_EXPR
const SOURCE_BLOCK_REQUIREMENTS_SORT_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_SORT_EXPR
const SOURCE_BLOCK_REQUIREMENTS_SHOWN_VISIBILITY_VALUE := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_SHOWN_VISIBILITY_VALUE
const SOURCE_BLOCK_REQUIREMENTS_BUILD_COST_MULTIPLIER_FIELD_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_BUILD_COST_MULTIPLIER_FIELD_EXPR
const SOURCE_BLOCK_REQUIREMENTS_ITEM_MODULE_HAS_STACKS_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_ITEM_MODULE_HAS_STACKS_EXPR
const SOURCE_BLOCK_REQUIREMENTS_CORE_PLACE_HAS_REQUIREMENTS_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_CORE_PLACE_HAS_REQUIREMENTS_EXPR
const SOURCE_BLOCK_REQUIREMENTS_CORE_PLACE_SPEND_EXPR := source_block_requirements_source_text_state.SOURCE_BLOCK_REQUIREMENTS_CORE_PLACE_SPEND_EXPR

static func _block_call(generated_method: String, generated_args: Array, metadata: Variant = null) -> Variant:
	if metadata == null:
		return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null, metadata)

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"core_item_count": Callable(game, "core_item_count") if game != null and game.has_method("core_item_count") else Callable(),
		"core_remove_item": Callable(game, "core_remove_item") if game != null and game.has_method("core_remove_item") else Callable(),
	}

static func canonical_requirements_hint_state() -> Dictionary:
	return {
		"build_cost_multiplier_field_expr": SOURCE_BLOCK_REQUIREMENTS_BUILD_COST_MULTIPLIER_FIELD_EXPR,
		"item_module_has_stacks_expr": SOURCE_BLOCK_REQUIREMENTS_ITEM_MODULE_HAS_STACKS_EXPR,
		"core_place_has_requirements_expr": SOURCE_BLOCK_REQUIREMENTS_CORE_PLACE_HAS_REQUIREMENTS_EXPR,
		"core_place_spend_expr": SOURCE_BLOCK_REQUIREMENTS_CORE_PLACE_SPEND_EXPR,
		"can_afford": true,
	}

static func block_requirements(block) -> Array:
	var properties := source_block_metadata_state.block_properties(block)
	if properties is Dictionary and properties.get("requirements", []) is Array:
		return properties.get("requirements", []).duplicate(true)
	return []

static func block_requirements_text(block) -> String:
	var parts: Array = []
	for requirement in block_requirements(block):
		if not requirement is Dictionary:
			continue
		var item_name := str(requirement.get("item", requirement.get("item_id", "")))
		var amount := int(requirement.get("amount", 0))
		parts.append("%s x%d" % [item_name, amount])
	return ", ".join(parts)

static func can_afford_state(requirements: Array, build_cost_multiplier: float, item_count_fn: Callable) -> Dictionary:
	var missing: Array = []
	var spend_calls: Array = []
	for requirement in requirements:
		if not requirement is Dictionary:
			continue
		var item = requirement.get("item", requirement.get("item_id", ""))
		var amount = int(floor(float(requirement.get("amount", 0)) * build_cost_multiplier + 0.5))
		var available: int = int(item_count_fn.call(item)) if item_count_fn.is_valid() else 0
		spend_calls.append({"item_id": item, "next_amount": max(available - amount, 0)})
		if available < amount:
			missing.append({"item": item, "required": amount, "available": available})
	return {"can_afford": missing.is_empty(), "missing": missing, "requirements": requirements, "build_cost_multiplier": build_cost_multiplier, "spend_calls": spend_calls}

static func spend_requirements_state(requirements: Array, build_cost_multiplier: float, item_count_fn: Callable) -> Dictionary:
	var affordability := can_afford_state(requirements, build_cost_multiplier, item_count_fn)
	return {"spent": bool(affordability.get("can_afford", false)), "affordability": affordability, "spend_calls": affordability.get("spend_calls", []) if bool(affordability.get("can_afford", false)) else []}

static func game_can_afford(game: Object, block) -> bool:
	var callbacks := default_callbacks_state(game)
	var state := can_afford_state(block_requirements(block), game.rules_build_cost_multiplier, callbacks.get("core_item_count", Callable()))
	return bool(state.get("can_afford", false))

static func game_spend_requirements(game: Object, block) -> void:
	var callbacks := default_callbacks_state(game)
	var state := spend_requirements_state(block_requirements(block), game.rules_build_cost_multiplier, callbacks.get("core_item_count", Callable()))
	for spend_call in state.get("spend_calls", []):
		game.call("set_core_item_count", str(spend_call.get("item_id", "")), int(spend_call.get("next_amount", 0)))

static func setup_requirements_simple_state(cat: Variant, stacks: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SETUP_REQUIREMENTS_SIMPLE_STATE, "source": SOURCE_BLOCK_REQUIREMENTS_SOURCE, "method": SOURCE_BLOCK_REQUIREMENTS_SETUP_SIMPLE_METHOD, "delegate_call_expr": SOURCE_BLOCK_REQUIREMENTS_DELEGATE_SETUP_SIMPLE_EXPR, "cat": cat, "stacks": stacks, "delegate_called": true}

static func setup_requirements_visible_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SETUP_REQUIREMENTS_VISIBLE_STATE, "source": SOURCE_BLOCK_REQUIREMENTS_SOURCE, "method": SOURCE_BLOCK_REQUIREMENTS_SETUP_VISIBLE_METHOD, "delegate_call_expr": SOURCE_BLOCK_REQUIREMENTS_DELEGATE_SETUP_VISIBLE_EXPR, "cat": cat, "visible": build_visibility, "stacks": stacks, "delegate_called": true}

static func requirements_unlocked_state(cat: Variant, stacks: Variant, unlocked: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REQUIREMENTS_UNLOCKED_STATE, "source": SOURCE_BLOCK_REQUIREMENTS_SOURCE, "method": SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_UNLOCKED_METHOD, "delegate_call_expr": SOURCE_BLOCK_REQUIREMENTS_DELEGATE_REQUIREMENTS_UNLOCKED_EXPR, "always_unlocked_assignment_expr": SOURCE_BLOCK_REQUIREMENTS_ALWAYS_UNLOCKED_ASSIGNMENT_EXPR, "cat": cat, "build_visibility": SOURCE_BLOCK_REQUIREMENTS_SHOWN_VISIBILITY_VALUE, "stacks": stacks, "unlocked": unlocked, "delegate_called": true, "always_unlocked_assigned": true, "always_unlocked_after": unlocked}

static func requirements_simple_state(cat: Variant, stacks: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REQUIREMENTS_SIMPLE_STATE, "source": SOURCE_BLOCK_REQUIREMENTS_SOURCE, "method": SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_SIMPLE_METHOD, "delegate_call_expr": SOURCE_BLOCK_REQUIREMENTS_DELEGATE_REQUIREMENTS_SIMPLE_EXPR, "cat": cat, "build_visibility": SOURCE_BLOCK_REQUIREMENTS_SHOWN_VISIBILITY_VALUE, "stacks": stacks, "delegate_called": true}

static func requirements_visible_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	var requirements_after: Variant = stacks.duplicate(true) if stacks is Array else stacks
	if requirements_after is Array:
		requirements_after.sort_custom(func(left, right):
			return int(left["item"]["id"]) < int(right["item"]["id"])
		)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REQUIREMENTS_VISIBLE_STATE, "source": SOURCE_BLOCK_REQUIREMENTS_SOURCE, "method": SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_VISIBLE_METHOD, "comment": SOURCE_BLOCK_REQUIREMENTS_COMMENT, "category_assignment_expr": SOURCE_BLOCK_REQUIREMENTS_CATEGORY_ASSIGNMENT_EXPR, "requirements_assignment_expr": SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_ASSIGNMENT_EXPR, "build_visibility_assignment_expr": SOURCE_BLOCK_REQUIREMENTS_BUILD_VISIBILITY_ASSIGNMENT_EXPR, "sort_expr": SOURCE_BLOCK_REQUIREMENTS_SORT_EXPR, "cat": cat, "visible": build_visibility, "stacks": stacks, "category_after": cat, "requirements_after": requirements_after, "build_visibility_after": build_visibility, "sort_called": true}

static func generated_setup_requirements_simple_result_state(cat: Variant, stacks: Variant) -> Dictionary:
	return setup_requirements_simple_state(cat, stacks)

static func generated_setup_requirements_visible_result_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return setup_requirements_visible_state(cat, build_visibility, stacks)

static func generated_requirements_unlocked_result_state(cat: Variant, stacks: Variant, unlocked: bool) -> Dictionary:
	return requirements_unlocked_state(cat, stacks, unlocked)

static func generated_requirements_simple_result_state(cat: Variant, stacks: Variant) -> Dictionary:
	return requirements_simple_state(cat, stacks)

static func generated_requirements_visible_result_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return requirements_visible_state(cat, build_visibility, stacks)

static func generated_block_setup_requirements_simple_bridge_state(cat: Variant, stacks: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_REQUIREMENTS_SETUP_SIMPLE_JAVA_METHOD, [cat, stacks])
	var canonical = setup_requirements_simple_state(cat, stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SETUP_REQUIREMENTS_SIMPLE_STATE, "generated_owner": SOURCE_BLOCK_REQUIREMENTS_SETUP_SIMPLE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_setup_requirements_visible_bridge_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_REQUIREMENTS_SETUP_VISIBLE_JAVA_METHOD, [cat, build_visibility, stacks])
	var canonical = setup_requirements_visible_state(cat, build_visibility, stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SETUP_REQUIREMENTS_VISIBLE_STATE, "generated_owner": SOURCE_BLOCK_REQUIREMENTS_SETUP_VISIBLE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_requirements_unlocked_bridge_state(cat: Variant, stacks: Variant, unlocked: bool) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_UNLOCKED_JAVA_METHOD, [cat, stacks, unlocked])
	var canonical = requirements_unlocked_state(cat, stacks, unlocked)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REQUIREMENTS_UNLOCKED_STATE, "generated_owner": SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_UNLOCKED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_requirements_simple_bridge_state(cat: Variant, stacks: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_SIMPLE_JAVA_METHOD, [cat, stacks])
	var canonical = requirements_simple_state(cat, stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REQUIREMENTS_SIMPLE_STATE, "generated_owner": SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_SIMPLE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_requirements_visible_bridge_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_VISIBLE_JAVA_METHOD, [cat, build_visibility, stacks])
	var canonical = requirements_visible_state(cat, build_visibility, stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_REQUIREMENTS_VISIBLE_STATE, "generated_owner": SOURCE_BLOCK_REQUIREMENTS_REQUIREMENTS_VISIBLE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
