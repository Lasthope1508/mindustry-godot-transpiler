# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItems.java
# Do not edit by hand.
extends RefCounted

const SourceUiDefaults := preload("res://src/game/SourceUiDefaults.gd")
const SOURCE_UI_ICON_MED := SourceUiDefaults.ICON_MED
const SOURCE_UI_PAD_RIGHT := SourceUiDefaults.PAD_RIGHT

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
	var item_stacks: Array = (_args[0] as Array).duplicate(true) if _args.size() > 0 and _args[0] is Array else []
	var item_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var multiplier_get_build: float = float(_args[2] if _args.size() > 2 else 1.0)
	var req_images: Array = []
	var row_calls: Array = []
	for index in item_stacks.size():
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
		req_images.append({"item_id": item_id, "stack_amount": stack_amount, "required_amount": required_amount, "item_amount": item_amount, "valid": valid, "stat_values_stack_expr": "StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build)))", "pad_right": SOURCE_UI_PAD_RIGHT})
		if (index + 1) % 4 == 0:
			row_calls.append({"call": "c.row();", "after_count": index + 1})
	var table_cell_left: bool = true
	return {"source_owner": "PortGame.source_consume_items_build_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public void build(Building build, Table table){", "items_field": "public final ItemStack[] items;", "table_expr": "table.table(c -> {", "i_initial_expr": "int i = 0;", "loop_expr": "for(var stack : items){", "add_expr": "c.add(new ReqImage(StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build))),", "stat_values_stack_expr": "StatValues.stack(stack.item, Math.round(stack.amount * multiplier.get(build)))", "valid_expr": "() -> build.items.has(stack.item, Math.round(stack.amount * multiplier.get(build))))).padRight(8);", "row_expr": "if(++i % 4 == 0) c.row();", "table_left_expr": "}).left();", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "building_items_field": "@Nullable ItemModule items;", "item_module_has_expr": "public boolean has(Item item, int amount){", "item_module_has_return_expr": "return get(item) >= amount;", "req_image_constructor": "public ReqImage(Element image, Boolp valid){", "req_image_valid_expr": "public boolean valid(){", "stat_values_stack_method": "public static Stack stack(UnlockableContent item, int amount){", "cell_pad_right_expr": "public Cell<T> padRight(float padRight){", "cell_left_expr": "public Cell<T> left(){", "item_stacks": item_stacks, "item_amounts": item_amounts, "multiplier_get_build": multiplier_get_build, "req_images": req_images, "row_calls": row_calls, "table_cell_left": table_cell_left}

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
	var booster: bool = bool(_args[0] if _args.size() > 0 else false)
	var stats_time_period: float = float(_args[1] if _args.size() > 1 else -1.0)
	var item_stacks: Array = (_args[2] as Array).duplicate(true) if _args.size() > 2 and _args[2] is Array else []
	var selected_stat: String = "booster" if booster else "input"
	var stat_values_items_expr: String = "StatValues.items(items)" if stats_time_period < 0.0 else "StatValues.items(stats.timePeriod, items)"
	var display_items: Array = []
	for stack in item_stacks:
		if not stack is Dictionary:
			continue
		var item_id: int = int(stack.get("item_id", -1))
		var amount: int = int(stack.get("amount", 0))
		var display_expr: String = "displayItem(stack.item, stack.amount, displayName)" if stats_time_period < 0.0 else "displayItem(stack.item, stack.amount, timePeriod, true)"
		display_items.append({"item_id": item_id, "amount": amount, "time_period": stats_time_period, "display_expr": display_expr})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": stat_values_items_expr, "time_period": stats_time_period, "item_stacks": item_stacks}
	return {"source_owner": "PortGame.source_consume_items_display_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "method": "public void display(Stats stats){", "items_field": "public final ItemStack[] items;", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, stats.timePeriod < 0 ? StatValues.items(items) : StatValues.items(stats.timePeriod, items));", "stats_add_call_expr": "stats.add", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "time_period_branch_expr": "stats.timePeriod < 0 ? StatValues.items(items) : StatValues.items(stats.timePeriod, items)", "stat_values_items_expr": stat_values_items_expr, "stat_values_items_method": "public static StatValue items(ItemStack... stacks){", "stat_values_timed_items_method": "public static StatValue items(float timePeriod, ItemStack... stacks){", "display_item_untimed_expr": "displayItem(stack.item, stack.amount, displayName)", "display_item_timed_expr": "displayItem(stack.item, stack.amount, timePeriod, true)", "stats_add_method": "public void add(Stat stat, StatValue value){", "stats_time_period_field": "public float timePeriod = -1;", "booster_field": "public boolean booster;", "stat_input_expr": "input = new Stat(\"input\", StatCat.crafting),", "stat_booster_expr": "booster = new Stat(\"booster\", StatCat.optional),", "item_stack_item_field": "public Item item;", "item_stack_amount_field": "public int amount = 0;", "booster": booster, "selected_stat": selected_stat, "stats_time_period": stats_time_period, "item_stacks": item_stacks, "display_items": display_items, "stats_add_call": stats_add_call}

func java_constructor_ConsumeItems_0(_args: Array = []) -> Variant:
	var item_stacks: Array = (_args[0] as Array).duplicate(true) if _args.size() > 0 and _args[0] is Array else []
	var items_after: Array = item_stacks.duplicate(true)
	return {"source_owner": "PortGame.source_consume_items_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "constructor": "public ConsumeItems(ItemStack[] items){", "assignment_expr": "this.items = items;", "items_field": "public final ItemStack[] items;", "item_stacks": item_stacks, "items_after": items_after}

func java_constructor_ConsumeItems_1(_args: Array = []) -> Variant:
	var item_stacks: Array = []
	var items_after: Array = item_stacks.duplicate(true)
	return {"source_owner": "PortGame.source_consume_items_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItems.java", "constructor": "protected ConsumeItems(){", "default_call_expr": "this(ItemStack.empty);", "item_stack_empty_expr": "public static final ItemStack[] empty = {};", "items_field": "public final ItemStack[] items;", "item_stacks": item_stacks, "items_after": items_after}
