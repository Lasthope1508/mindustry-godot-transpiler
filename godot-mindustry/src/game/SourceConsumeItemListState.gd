extends RefCounted
class_name SourceConsumeItemListState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func set_multipliers_state(objects: Array) -> Dictionary:
	var put_calls: Array = []
	var i := 0
	while i < objects.size():
		var item: Variant = objects[i]
		var multiplier: float = float(objects[i + 1])
		put_calls.append({"object_index": i, "multiplier_index": i + 1, "item": item, "multiplier": multiplier, "put_expr": "itemMultipliers.put((Item)objects[i], (Float)objects[i + 1]);"})
		i += 2
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_LIST_SET_MULTIPLIERS_STATE,
		"objects": objects,
		"objects_length": objects.size(),
		"loop_step": 2,
		"put_calls": put_calls,
		"item_multiplier_entries": put_calls,
	}

static func efficiency_multiplier_state(consumed_item: Variant, item_multiplier_value: float) -> Dictionary:
	var efficiency_multiplier: float = item_multiplier_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_LIST_EFFICIENCY_MULTIPLIER_STATE,
		"consumed_item": consumed_item,
		"item_multiplier_value": item_multiplier_value,
		"efficiency_multiplier": efficiency_multiplier,
	}

static func generated_set_multipliers_bridge_state(objects: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemList.gd")
	var instance = script.new()
	var result = instance.java_method_setMultipliers_0([objects])
	var canonical = set_multipliers_state(objects)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_LIST_SET_MULTIPLIERS_STATE, "generated_owner": "consume_item_list.setMultipliers", "result": result, "canonical": canonical, "matches": result.get("put_calls", []) == canonical.get("put_calls", []) and result.get("objects_length", null) == canonical.get("objects_length", null)}

static func generated_efficiency_multiplier_bridge_state(consumed_item: Variant, item_multiplier_value: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemList.gd")
	var instance = script.new()
	var result = instance.java_method_efficiencyMultiplier_1([consumed_item, item_multiplier_value])
	var canonical = efficiency_multiplier_state(consumed_item, item_multiplier_value)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_LIST_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_item_list.efficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null) and result.get("item_multiplier_value", null) == canonical.get("item_multiplier_value", null)}
