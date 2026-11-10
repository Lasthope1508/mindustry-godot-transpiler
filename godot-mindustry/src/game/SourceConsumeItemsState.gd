extends RefCounted
class_name SourceConsumeItemsState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_consume_state := preload("res://src/game/SourceConsumeState.gd")

class RuntimeConsumer extends RefCounted:
	var definition: Dictionary
	var items: Dictionary
	var cost_multiplier: Callable
	var source_delta: float
	var time_scale: float

	func efficiency(build: Dictionary) -> float:
		# ConsumeItems.efficiency (ConsumeItems.java:52): the stack is
		# valid when the building is burning a trigger consumer
		# (consumeTriggerValid, false by default,
		# BuildingComp.java:764-766) or its item module holds the
		# stack amount times the cost multiplier, rounded the way the
		# trigger removes it (Math.round, ConsumeItems.java:46).
		var required: int = int(round(float(definition.get("amount", 0)) * float(cost_multiplier.call(build).get("multiplier", 1.0))))
		var trigger_valid: bool = SourceConsumeItemsState.source_building_access_state.consume_trigger_valid_state()
		var has_stack: bool = SourceConsumeItemsState.source_inventory.item_count(items, String(definition.get("item", ""))) >= required
		return 1.0 if trigger_valid or has_stack else 0.0

	func update(_build: Dictionary) -> void:
		# ConsumeItems has no update body: Consume.update is empty
		# (Consume.java:52), so the per-tick second pass removes
		# nothing for items. The stacks leave only when craft() calls
		# consume() -> trigger() (GenericCrafter.java:301-303,
		# ConsumeItems.java:46 removes each stack once per craft);
		# the craft slice owns that trigger.
		pass

	func trigger(build: Dictionary) -> void:
		# ConsumeItems.trigger (ConsumeItems.java:45-48): removes each
		# stack once per craft — `build.items.remove(stack.item,
		# Math.round(stack.amount * multiplier.get(build)));`. The
		# removal clamps at what the module holds (ItemModule.java
		# `amount = Math.min(amount, items[item.id]);`), so a cheating
		# or empty module never goes negative; the multiplier is the
		# N2097 cost-multiplier callback (1.0 for a GenericCrafter
		# -family block). The craft slice owns this trigger (N2117):
		# item stacks leave only at craft, through
		# SourceFactoryBuildState.source_factory_consume_state.
		var amount: int = int(round(float(definition.get("amount", 0)) * float(cost_multiplier.call(build).get("multiplier", 1.0))))
		var item_name := String(definition.get("item", ""))
		var held: int = SourceConsumeItemsState.source_inventory.item_count(items, item_name)
		items[item_name] = maxi(held - mini(amount, held), 0)

static func source_runtime_consumer_state(definition: Dictionary, items: Dictionary, cost_multiplier: Callable) -> Dictionary:
	var consumer := RuntimeConsumer.new()
	consumer.definition = definition
	consumer.items = items
	consumer.cost_multiplier = cost_multiplier
	return {"consumer": consumer}

static func source_bind_item_consumers_state(block: Object, content_catalog: Object) -> Dictionary:
	# Block.consumeItems (Block.java:1175-1177) registers one
	# ConsumeItems per consumeItem(s) call; the registry captures
	# each call's stacks into properties["consumeItem"] (N2095), so
	# each stack is one row here, like each ConsumeLiquid row is one
	# row in SourceConsumeLiquidState
	# .source_bind_liquid_consumers_state. A row is the stack dict
	# itself (item name + amount); the item module is keyed by item
	# name, so no id resolution is needed, but the catalog must
	# carry the item or the row is not a real consumer. Consume
	# defaults apply (Consume.java:18 multiplier 1f, :43 ignore
	# false, :52 update empty), so every row is a non-optional
	# update consumer.
	var catalog_items: Array = content_catalog.call("get_many", "item")
	var consumers: Array = []
	for definition in block.properties.get("consumeItem", []):
		var matches := catalog_items.filter(func(item): return item.id == definition["item"])
		assert(matches.size() == 1, "ConsumeItems Java field must resolve uniquely in the typed item catalog")
		var consumer: Dictionary = definition.duplicate()
		consumer["ignored"] = source_consume_state.ignore_state()["ignored"]
		consumers.append(consumer)
	return {"consumers": consumers}

static func constructor_state(item_stacks: Array) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_CONSTRUCTOR_STATE,
		"item_stacks": item_stacks.duplicate(true),
		"items_after": item_stacks.duplicate(true),
	}

static func default_constructor_state(empty_stacks: Array) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_DEFAULT_CONSTRUCTOR_STATE,
		"item_stacks": empty_stacks.duplicate(true),
		"items_after": empty_stacks.duplicate(true),
	}

static func apply_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, item_stacks: Array) -> Dictionary:
	var item_filter_after := item_filter_before.duplicate()
	for stack in item_stacks:
		if not stack is Dictionary:
			continue
		var item_id := int(stack.get("item_id", -1))
		if item_id >= 0 and item_id < item_filter_after.size():
			item_filter_after[item_id] = true
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_APPLY_STATE,
		"block_has_items_before": block_has_items_before,
		"block_accepts_items_before": block_accepts_items_before,
		"item_filter_before": item_filter_before,
		"item_stacks": item_stacks,
		"block_has_items_after": true,
		"block_accepts_items_after": true,
		"item_filter_after": item_filter_after,
	}

static func build_state(item_stacks: Array, item_amounts: Array, multiplier_get_build: float, source_ui_pad_right: float) -> Dictionary:
	var req_images: Array = []
	var row_calls: Array = []
	for index in range(item_stacks.size()):
		var stack: Variant = item_stacks[index]
		if not stack is Dictionary:
			continue
		var item_id: int = int(stack.get("item_id", -1))
		var stack_amount: float = float(stack.get("amount", 0.0))
		var required_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))
		var item_amount: float = 0.0
		if item_id < item_amounts.size():
			item_amount = float(item_amounts[item_id])
		var valid: bool = item_id < item_amounts.size() and item_amount >= required_amount
		req_images.append({
			"item_id": item_id,
			"stack_amount": stack_amount,
			"required_amount": required_amount,
			"item_amount": item_amount,
			"valid": valid,
			"stat_values_stack_expr": "StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build)))",
			"pad_right": source_ui_pad_right,
		})
		if (index + 1) % 4 == 0:
			row_calls.append({"call": "c.row();", "after_count": index + 1})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_BUILD_STATE,
		"item_stacks": item_stacks.duplicate(true),
		"item_amounts": item_amounts.duplicate(),
		"multiplier_get_build": multiplier_get_build,
		"req_images": req_images,
		"row_calls": row_calls,
		"table_cell_left": true,
	}

static func trigger_state(item_stacks: Array, multiplier_get_build: float) -> Dictionary:
	var remove_calls: Array = []
	for stack in item_stacks:
		if not stack is Dictionary:
			continue
		var item_id: int = int(stack.get("item_id", -1))
		var stack_amount: float = float(stack.get("amount", 0.0))
		var remove_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))
		remove_calls.append({"call": "build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));", "item_id": item_id, "stack_amount": stack_amount, "amount": remove_amount})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_TRIGGER_STATE,
		"item_stacks": item_stacks.duplicate(true),
		"multiplier_get_build": multiplier_get_build,
		"remove_calls": remove_calls,
	}

static func efficiency_state(consume_trigger_valid: bool, item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	var item_module_has_stacks: bool = true
	var stack_checks: Array = []
	for stack in item_stacks:
		if not stack is Dictionary:
			continue
		var item_id: int = int(stack.get("item_id", -1))
		var stack_amount: float = float(stack.get("amount", 0.0))
		var required_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))
		var item_amount: float = 0.0
		if item_id < item_amounts.size():
			item_amount = float(item_amounts[item_id])
		var has_stack: bool = item_id < item_amounts.size() and item_amount >= required_amount
		stack_checks.append({"item_id": item_id, "stack_amount": stack_amount, "required_amount": required_amount, "item_amount": item_amount, "has_stack": has_stack})
		if item_id >= item_amounts.size() or float(item_amounts[item_id]) < required_amount:
			item_module_has_stacks = false
			break
	var efficiency_value: float = 1.0 if consume_trigger_valid or item_module_has_stacks else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_EFFICIENCY_STATE,
		"consume_trigger_valid": consume_trigger_valid,
		"item_stacks": item_stacks.duplicate(true),
		"item_amounts": item_amounts.duplicate(),
		"multiplier_get_build": multiplier_get_build,
		"item_module_has_stacks": item_module_has_stacks,
		"stack_checks": stack_checks,
		"efficiency": efficiency_value,
	}

static func display_state(booster: bool, stats_time_period: float, item_stacks: Array) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_items: Array = []
	for stack in item_stacks:
		if not stack is Dictionary:
			continue
		var item_id: int = int(stack.get("item_id", -1))
		var amount: int = int(stack.get("amount", 0))
		var display_expr: String = "displayItem(stack.item, stack.amount, displayName)" if stats_time_period < 0.0 else "displayItem(stack.item, stack.amount, timePeriod, true)"
		display_items.append({"item_id": item_id, "amount": amount, "time_period": stats_time_period, "display_expr": display_expr})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.items(items)" if stats_time_period < 0.0 else "StatValues.items(stats.timePeriod, items)", "time_period": stats_time_period, "item_stacks": item_stacks}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEMS_DISPLAY_STATE,
		"booster": booster,
		"selected_stat": selected_stat,
		"stats_time_period": stats_time_period,
		"item_stacks": item_stacks.duplicate(true),
		"display_items": display_items,
		"stats_add_call": stats_add_call,
	}
