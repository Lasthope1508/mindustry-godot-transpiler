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
