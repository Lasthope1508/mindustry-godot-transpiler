extends RefCounted
class_name SourceConsumeItemDynamicState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func constructor_state(items: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_STATE, "items_after": items}

static func apply_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_STATE, "block_has_items_after": true or block_has_items_before, "block_accepts_items_after": true or block_accepts_items_before}

static func build_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	var rebuild_calls: Array = []
	if current_item_ids != next_item_ids:
		rebuild_calls.append({"call": "rebuild(build)", "next_item_ids": next_item_ids.duplicate(true)})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_STATE, "rebuild_calls": rebuild_calls, "current_item_ids_after_update": next_item_ids.duplicate(true)}

static func rebuild_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float, source_ui_pad_right: float) -> Dictionary:
	var req_images: Array = []
	var row_calls: Array = []
	if building_has_items:
		for index in range(item_ids.size()):
			var amount := float(item_stack_amounts[index]) * multiplier_get_build if index < item_stack_amounts.size() else 0.0
			req_images.append({"item": item_ids[index], "amount": amount, "pad_right": source_ui_pad_right})
			row_calls.append({"item": item_ids[index], "stored": item_amounts[index] if index < item_amounts.size() else 0})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_STATE, "req_images": req_images, "row_calls": row_calls}

static func trigger_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var remove_calls: Array = []
	for index in range(item_ids.size()):
		remove_calls.append({"item": item_ids[index], "amount": float(item_stack_amounts[index]) * multiplier_get_build if index < item_stack_amounts.size() else 0.0})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_STATE, "remove_calls": remove_calls}

static func efficiency_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var item_module_has_stacks := item_ids.size() > 0
	var efficiency := 1.0 if consume_trigger_valid else 0.0
	for index in range(item_ids.size()):
		var needed := float(item_stack_amounts[index]) * multiplier_get_build if index < item_stack_amounts.size() else 0.0
		var available := float(item_amounts[index]) if index < item_amounts.size() else 0.0
		if needed > 0.0:
			efficiency = minf(efficiency, available / needed)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_STATE, "efficiency": clampf(efficiency, 0.0, 1.0), "item_module_has_stacks": item_module_has_stacks}

static func generated_constructor_bridge_state(items: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemDynamic.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemDynamic_0([items])
	var canonical = constructor_state(items)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_CONSTRUCTOR_STATE, "generated_owner": "consume_item_dynamic.constructor", "result": result, "canonical": canonical, "matches": result.get("items_after", null) == canonical.get("items_after", null)}

static func generated_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_apply_0([block_has_items_before, block_accepts_items_before])
	var canonical = apply_state(block_has_items_before, block_accepts_items_before)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_APPLY_STATE, "generated_owner": "consume_item_dynamic.apply", "result": result, "canonical": canonical, "matches": result.get("block_has_items_after", null) == canonical.get("block_has_items_after", null) and result.get("block_accepts_items_after", null) == canonical.get("block_accepts_items_after", null)}

static func generated_build_bridge_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_build_1([current_item_ids, next_item_ids])
	var canonical = build_state(current_item_ids, next_item_ids)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_BUILD_STATE, "generated_owner": "consume_item_dynamic.build", "result": result, "canonical": canonical, "matches": result.get("rebuild_calls", []) == canonical.get("rebuild_calls", []) and result.get("current_item_ids_after_update", []) == canonical.get("current_item_ids_after_update", [])}

static func generated_rebuild_bridge_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float, source_ui_pad_right: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_rebuild_2([item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build])
	var canonical = rebuild_state(item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build, source_ui_pad_right)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_REBUILD_STATE, "generated_owner": "consume_item_dynamic.rebuild", "result": result, "canonical": canonical, "matches": result.get("req_images", []) == canonical.get("req_images", []) and result.get("row_calls", []) == canonical.get("row_calls", [])}

static func generated_trigger_bridge_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_trigger_3([item_ids, item_stack_amounts, multiplier_get_build])
	var canonical = trigger_state(item_ids, item_stack_amounts, multiplier_get_build)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_TRIGGER_STATE, "generated_owner": "consume_item_dynamic.trigger", "result": result, "canonical": canonical, "matches": result.get("remove_calls", []) == canonical.get("remove_calls", [])}

static func generated_efficiency_bridge_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_efficiency_4([consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build])
	var canonical = efficiency_state(consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_DYNAMIC_EFFICIENCY_STATE, "generated_owner": "consume_item_dynamic.efficiency", "result": result, "canonical": canonical, "matches": result.get("efficiency", null) == canonical.get("efficiency", null) and result.get("item_module_has_stacks", null) == canonical.get("item_module_has_stacks", null)}
