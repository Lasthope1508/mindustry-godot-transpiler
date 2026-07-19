extends RefCounted
class_name SourceConsumeItemFilterState

static func item_efficiency_multiplier_state() -> Dictionary:
	return {
		"method": "public float itemEfficiencyMultiplier(Item item){",
		"efficiency_multiplier": 1.0,
		"return_expr": "return 1f;",
	}

static func constructor_state(item: Variant) -> Dictionary:
	return {
		"source_owner": "PortGame.source_consume_item_filter_constructor_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"constructor": "public ConsumeItemFilter(Boolf<Item> item){",
		"filter_assignment_expr": "this.filter = item;",
		"filter_field": "public Boolf<Item> filter = i -> false;",
		"item": item,
		"filter_after": item,
	}

static func default_constructor_state(default_filter_expr: String) -> Dictionary:
	return {
		"source_owner": "PortGame.source_consume_item_filter_default_constructor_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"constructor": "public ConsumeItemFilter(){",
		"filter_field": "public Boolf<Item> filter = i -> false;",
		"default_filter_expr": default_filter_expr,
		"filter_after": default_filter_expr,
	}

static func apply_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, filtered_item_ids: Array) -> Dictionary:
	var item_filter_after := item_filter_before.duplicate()
	for item_id in filtered_item_ids:
		item_filter_after[int(item_id)] = true
	return {
		"source_owner": "PortGame.source_consume_item_filter_apply_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public void apply(Block block){",
		"filter_field": "public Boolf<Item> filter = i -> false;",
		"has_items_assignment_expr": "block.hasItems = true;",
		"accepts_items_assignment_expr": "block.acceptsItems = true;",
		"each_expr": "content.items().each(filter, item -> block.itemFilter[item.id] = true);",
		"item_filter_assignment_expr": "block.itemFilter[item.id] = true;",
		"block_has_items_field": "public @NoPatch boolean hasItems;",
		"block_accepts_items_field": "public boolean acceptsItems = false;",
		"block_item_filter_field": "public boolean[] itemFilter = {}, liquidFilter = {};",
		"block_has_items_before": block_has_items_before,
		"block_accepts_items_before": block_accepts_items_before,
		"item_filter_before": item_filter_before,
		"filtered_item_ids": filtered_item_ids,
		"block_has_items_after": true,
		"block_accepts_items_after": true,
		"item_filter_after": item_filter_after,
	}

@warning_ignore("shadowed_variable")
static func update_state(build_state: Variant) -> Dictionary:
	return {
		"source_owner": "PortGame.source_consume_item_filter_update_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public void update(Building build){",
		"empty_body": "public void update(Building build){\n    }",
		"build_state": build_state,
		"no_op": true,
	}

@warning_ignore("shadowed_variable")
static func trigger_state(build_state: Variant, consumed_item: Variant) -> Dictionary:
	var item_removed: bool = consumed_item != null
	var remove_amount: int = 1 if item_removed else 0
	var remove_call: Variant = null
	if item_removed:
		remove_call = {"call": "build.items.remove(item, 1)", "item": consumed_item, "amount": 1}
	return {
		"source_owner": "PortGame.source_consume_item_filter_trigger_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public void trigger(Building build){",
		"get_consumed_expr": "Item item = getConsumed(build);",
		"null_guard_expr": "if(item != null){",
		"remove_expr": "build.items.remove(item, 1);",
		"build_state": build_state,
		"consumed_item": consumed_item,
		"item_removed": item_removed,
		"remove_amount": remove_amount,
		"remove_call": remove_call,
	}

static func efficiency_state(consume_trigger_valid: bool, consumed_item: Variant) -> Dictionary:
	var has_consumed_item: bool = consumed_item != null
	var efficiency: float = 1.0 if consume_trigger_valid or has_consumed_item else 0.0
	return {
		"source_owner": "PortGame.source_consume_item_filter_efficiency_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public float efficiency(Building build){",
		"return_expr": "return build.consumeTriggerValid() || getConsumed(build) != null ? 1f : 0f;",
		"consume_trigger_valid_expr": "build.consumeTriggerValid()",
		"get_consumed_expr": "getConsumed(build) != null",
		"consume_trigger_valid": consume_trigger_valid,
		"consumed_item": consumed_item,
		"has_consumed_item": has_consumed_item,
		"efficiency": efficiency,
	}

static func build_state(filtered_item_ids: Array, build_items_has_item_flags: Array, source_ui_icon_med: float) -> Dictionary:
	var req_images: Array = []
	for index in filtered_item_ids.size():
		var valid: bool = bool(build_items_has_item_flags[index]) if index < build_items_has_item_flags.size() else false
		req_images.append({"item_id": int(filtered_item_ids[index]), "stack_amount": 1, "valid": valid, "stat_values_stack_expr": "StatValues.stack(item, 1)", "valid_expr": "build.items.has(item)"})
	var table_image_size: float = source_ui_icon_med
	return {
		"source_owner": "PortGame.source_consume_item_filter_build_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public void build(Building build, Table table){",
		"filter_field": "public Boolf<Item> filter = i -> false;",
		"image_expr": "MultiReqImage image = new MultiReqImage();",
		"each_expr": "content.items().each(i -> filter.get(i) && i.unlockedNow() && !i.hidden, item -> image.add(new ReqImage(StatValues.stack(item, 1), () -> build.items.has(item))));",
		"table_add_expr": "table.add(image).size(8 * 4);",
		"multi_req_image_class": "public class MultiReqImage extends Stack{",
		"multi_req_image_add_expr": "public void add(ReqImage display){",
		"req_image_constructor": "public ReqImage(Element image, Boolp valid){",
		"req_image_valid_expr": "public boolean valid(){",
		"stat_values_stack_expr": "public static Stack stack(UnlockableContent item, int amount){",
		"building_items_field": "@Nullable ItemModule items;",
		"item_module_has_expr": "public boolean has(Item item){",
		"cell_size_expr": "public Cell<T> size(float size){",
		"filtered_item_ids": filtered_item_ids,
		"build_items_has_item_flags": build_items_has_item_flags,
		"multi_req_image_created": true,
		"req_images": req_images,
		"req_image_count": req_images.size(),
		"table_add_image": true,
		"table_image_size": table_image_size,
	}

static func get_consumed_state(content_items: Array, build_items_has_item_flags: Array, filter_get_item_flags: Array) -> Dictionary:
	var consumed_item: Variant = null
	var consumed_index: int = -1
	var checked_items: Array = []
	for i in range(content_items.size()):
		var item: Variant = content_items[i]
		var build_items_has_item: bool = bool(build_items_has_item_flags[i]) if i < build_items_has_item_flags.size() else false
		var filter_get_item: bool = bool(filter_get_item_flags[i]) if i < filter_get_item_flags.size() else false
		var item_matches: bool = build_items_has_item and filter_get_item
		checked_items.append({"index": i, "item": item, "build_items_has_item": build_items_has_item, "filter_get_item": filter_get_item, "item_matches": item_matches})
		if item_matches:
			consumed_item = item
			consumed_index = i
			break
	return {
		"source_owner": "PortGame.source_consume_item_filter_get_consumed_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public @Nullable Item getConsumed(Building build){",
		"loop_expr": "for(int i = 0; i < content.items().size; i++){",
		"content_item_expr": "Item item = content.item(i);",
		"guard_expr": "if(build.items.has(item) && this.filter.get(item)){",
		"return_item_expr": "return item;",
		"return_null_expr": "return null;",
		"content_items": content_items,
		"build_items_has_item_flags": build_items_has_item_flags,
		"filter_get_item_flags": filter_get_item_flags,
		"checked_items": checked_items,
		"consumed_item": consumed_item,
		"consumed_index": consumed_index,
	}

static func display_state(booster: bool, stats_time_period: float, filtered_item_ids: Array) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_items: Array = []
	for item_id in filtered_item_ids:
		var display_expr: String = "displayItem(item)" if stats_time_period <= 0.0 else "displayItem(item, 1, timePeriod, true)"
		display_items.append({"item_id": int(item_id), "time_period": stats_time_period, "display_expr": display_expr})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.items(stats.timePeriod, filter)", "time_period": stats_time_period, "filtered_item_ids": filtered_item_ids}
	return {
		"source_owner": "PortGame.source_consume_item_filter_display_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public void display(Stats stats){",
		"stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, StatValues.items(stats.timePeriod, filter));",
		"stats_add_call_expr": "stats.add",
		"selected_stat_expr": "booster ? Stat.booster : Stat.input",
		"stat_values_items_expr": "StatValues.items(stats.timePeriod, filter)",
		"stat_values_items_method": "public static StatValue items(float timePeriod, Boolf<Item> filter){",
		"content_filter_expr": "Seq<Item> list = content.items().select(i -> filter.get(i) && i.unlockedNow() && !i.isHidden());",
		"display_item_expr": "table.add(timePeriod <= 0 ? displayItem(item) : displayItem(item, 1, timePeriod, true)).padRight(5);",
		"booster": booster,
		"selected_stat": selected_stat,
		"stats_time_period": stats_time_period,
		"filtered_item_ids": filtered_item_ids,
		"stats_add_call": stats_add_call,
		"display_items": display_items,
	}

static func efficiency_multiplier_state(consumed_item: Variant, item_efficiency_multiplier: float) -> Dictionary:
	var has_consumed_item: bool = consumed_item != null
	var efficiency_multiplier: float = item_efficiency_multiplier if has_consumed_item else 0.0
	return {
		"source_owner": "PortGame.source_consume_item_filter_efficiency_multiplier_state",
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public float efficiencyMultiplier(Building build){",
		"get_consumed_expr": "var item = getConsumed(build);",
		"return_expr": "return item == null ? 0f : itemEfficiencyMultiplier(item);",
		"item_efficiency_multiplier_expr": "itemEfficiencyMultiplier(item)",
		"consumed_item": consumed_item,
		"item_efficiency_multiplier": item_efficiency_multiplier,
		"has_consumed_item": has_consumed_item,
		"efficiency_multiplier": efficiency_multiplier,
	}
