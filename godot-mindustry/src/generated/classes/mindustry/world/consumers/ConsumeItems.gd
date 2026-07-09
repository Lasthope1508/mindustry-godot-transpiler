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
	return null

func java_method_display_4(_args: Array = []) -> Variant:
	return null
