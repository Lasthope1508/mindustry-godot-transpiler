extends RefCounted
class_name SourceConsumeItemDynamicState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func constructor_state(items: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_STATE, "items_after": items}

static func apply_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_STATE,
		"block_has_items_before": block_has_items_before,
		"block_accepts_items_before": block_accepts_items_before,
		"block_has_items_after": true,
		"block_accepts_items_after": true,
	}

static func build_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	var item_ids_changed: bool = current_item_ids != next_item_ids
	var rebuild_calls: Array = [{"call": "rebuild(build, cont);", "phase": "initial", "item_ids": current_item_ids.duplicate(true)}]
	var current_item_ids_after_update: Array = current_item_ids.duplicate(true)
	if item_ids_changed:
		rebuild_calls.append({"call": "rebuild(build, cont);", "phase": "update", "item_ids": next_item_ids.duplicate(true)})
		current_item_ids_after_update = next_item_ids.duplicate(true)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_STATE,
		"current_item_ids": current_item_ids.duplicate(true),
		"next_item_ids": next_item_ids.duplicate(true),
		"item_ids_changed": item_ids_changed,
		"rebuild_calls": rebuild_calls,
		"current_item_ids_after_update": current_item_ids_after_update,
		"table_cell_created": true,
		"update_registered": true,
	}

static func rebuild_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float, source_ui_pad_right: float) -> Dictionary:
	var req_images: Array = []
	var row_calls: Array = []
	for index in range(item_ids.size()):
		var stack_amount: float = float(item_stack_amounts[index] if index < item_stack_amounts.size() else 0.0)
		var item_amount: float = float(item_amounts[index] if index < item_amounts.size() else 0.0)
		var required_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))
		var valid: bool = building_has_items and item_amount >= required_amount
		req_images.append({"item_id": int(item_ids[index]), "stack_amount": stack_amount, "required_amount": required_amount, "item_amount": item_amount, "valid": valid, "stat_values_stack_expr": "StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build)))", "pad_right": source_ui_pad_right, "left": true})
		if (index + 1) % 4 == 0:
			row_calls.append({"call": "table.row();", "after_count": index + 1})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_STATE,
		"item_ids": item_ids.duplicate(true),
		"item_stack_amounts": item_stack_amounts.duplicate(true),
		"item_amounts": item_amounts.duplicate(true),
		"building_has_items": building_has_items,
		"multiplier_get_build": multiplier_get_build,
		"req_images": req_images,
		"row_calls": row_calls,
		"cleared": true,
	}

static func trigger_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var remove_calls: Array = []
	for index in range(item_ids.size()):
		var stack_amount: float = float(item_stack_amounts[index] if index < item_stack_amounts.size() else 0.0)
		var remove_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))
		remove_calls.append({"call": "build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));", "item_id": int(item_ids[index]), "stack_amount": stack_amount, "amount": remove_amount})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_STATE,
		"item_ids": item_ids.duplicate(true),
		"item_stack_amounts": item_stack_amounts.duplicate(true),
		"multiplier_get_build": multiplier_get_build,
		"remove_calls": remove_calls,
	}

static func efficiency_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var item_module_has_stacks: bool = true
	var stack_checks: Array = []
	for index in range(item_ids.size()):
		var item_id: int = int(item_ids[index])
		var stack_amount: float = float(item_stack_amounts[index] if index < item_stack_amounts.size() else 0.0)
		var required_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))
		var item_amount: float = 0.0
		if item_id < item_amounts.size():
			item_amount = float(item_amounts[item_id])
		var has_stack: bool = item_id < item_amounts.size() and item_amount >= required_amount
		stack_checks.append({"item_id": item_id, "stack_amount": stack_amount, "required_amount": required_amount, "item_amount": item_amount, "has_stack": has_stack})
		if not has_stack:
			item_module_has_stacks = false
			break
	var efficiency_value: float = 1.0 if consume_trigger_valid or item_module_has_stacks else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_STATE,
		"consume_trigger_valid": consume_trigger_valid,
		"item_ids": item_ids.duplicate(true),
		"item_stack_amounts": item_stack_amounts.duplicate(true),
		"item_amounts": item_amounts.duplicate(true),
		"multiplier_get_build": multiplier_get_build,
		"item_module_has_stacks": item_module_has_stacks,
		"stack_checks": stack_checks,
		"efficiency": efficiency_value,
	}
