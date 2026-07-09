# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItems.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItems"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "items", "type": "ItemStack"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItems", "parameters": [{"name": "items", "type": "ItemStack", "varargs": false}]}, {"modifiers": ["protected"], "name": "ConsumeItems", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "trigger", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_items_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var block_accepts_items_before: bool = bool(_args[1] if _args.size() > 1 else false)
	var item_filter_before: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var item_stacks: Array = (_args[3] as Array).duplicate(true) if _args.size() > 3 and _args[3] is Array else []
	var item_filter_after: Array = item_filter_before.duplicate()
	for stack in item_stacks:
		if not stack is Dictionary:
			continue
		var item_id := int(stack.get("item_id", -1))
		item_filter_after[item_id] = true
	var block_has_items_after: bool = true
	var block_accepts_items_after: bool = true
	return {"source_owner": "PortGame.source_consume_items_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public void apply(Block block){", "items_field": "public final ItemStack[] items;", "has_items_assignment_expr": "block.hasItems = true;", "accepts_items_assignment_expr": "block.acceptsItems = true;", "items_loop_expr": "for(var stack : items){", "item_filter_assignment_expr": "block.itemFilter[stack.item.id] = true;", "block_has_items_field": "public @NoPatch boolean hasItems;", "block_accepts_items_field": "public boolean acceptsItems = false;", "block_item_filter_field": "public boolean[] itemFilter = {}, liquidFilter = {};", "block_has_items_before": block_has_items_before, "block_accepts_items_before": block_accepts_items_before, "item_filter_before": item_filter_before, "item_stacks": item_stacks, "block_has_items_after": block_has_items_after, "block_accepts_items_after": block_accepts_items_after, "item_filter_after": item_filter_after}

func java_method_build_1(_args: Array = []) -> Variant:
	return null

func java_method_trigger_2(_args: Array = []) -> Variant:
	var item_stacks: Array = (_args[0] as Array).duplicate(true) if _args.size() > 0 and _args[0] is Array else []
	var multiplier_get_build: float = float(_args[1] if _args.size() > 1 else 1.0)
	var remove_calls: Array = []
	for stack in item_stacks:
		if not stack is Dictionary:
			continue
		var item_id: int = int(stack.get("item_id", -1))
		var stack_amount: float = float(stack.get("amount", 0.0))
		var remove_amount: int = int(floor(stack_amount * multiplier_get_build + 0.5))
		remove_calls.append({"call": "build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));", "item_id": item_id, "stack_amount": stack_amount, "amount": remove_amount})
	return {"source_owner": "PortGame.source_consume_items_trigger_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public void trigger(Building build){", "items_field": "public final ItemStack[] items;", "items_loop_expr": "for(var stack : items){", "remove_expr": "build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));", "round_expr": "Math.round(stack.amount * multiplier.get(build))", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "building_items_field": "@Nullable ItemModule items;", "item_module_remove_method": "public void remove(Item item, int amount){", "item_module_remove_clamp": "amount = Math.min(amount, items[item.id]);", "item_stacks": item_stacks, "multiplier_get_build": multiplier_get_build, "remove_calls": remove_calls}

func java_method_efficiency_3(_args: Array = []) -> Variant:
	var consume_trigger_valid: bool = bool(_args[0] if _args.size() > 0 else false)
	var item_stacks: Array = (_args[1] as Array).duplicate(true) if _args.size() > 1 and _args[1] is Array else []
	var item_amounts: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var multiplier_get_build: float = float(_args[3] if _args.size() > 3 else 1.0)
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
	return {"source_owner": "PortGame.source_consume_items_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public float efficiency(Building build){", "items_field": "public final ItemStack[] items;", "return_expr": "return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;", "consume_trigger_valid_expr": "build.consumeTriggerValid()", "item_module_has_stacks_expr": "public boolean has(ItemStack[] stacks, float multiplier){", "item_module_has_stack_guard_expr": "if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;", "item_module_has_stacks_return_expr": "return true;", "item_module_has_item_amount_expr": "public boolean has(Item item, int amount){", "item_module_has_item_amount_return_expr": "return get(item) >= amount;", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "consume_trigger_valid": consume_trigger_valid, "item_stacks": item_stacks, "item_amounts": item_amounts, "multiplier_get_build": multiplier_get_build, "item_module_has_stacks": item_module_has_stacks, "stack_checks": stack_checks, "efficiency": efficiency_value}

func java_method_display_4(_args: Array = []) -> Variant:
	return null
