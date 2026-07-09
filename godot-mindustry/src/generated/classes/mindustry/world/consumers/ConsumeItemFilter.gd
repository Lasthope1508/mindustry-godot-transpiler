# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemFilter.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemFilter"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "filter", "type": "Boolf"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemFilter", "parameters": [{"name": "item", "type": "Boolf", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeItemFilter", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "trigger", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getConsumed", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "Item"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiencyMultiplier", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "itemEfficiencyMultiplier", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_items_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var block_accepts_items_before: bool = bool(_args[1] if _args.size() > 1 else false)
	var item_filter_before: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var filtered_item_ids: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []
	var item_filter_after: Array = item_filter_before.duplicate()
	for item_id in filtered_item_ids:
		item_filter_after[int(item_id)] = true
	var block_has_items_after: bool = true
	var block_accepts_items_after: bool = true
	return {"source_owner": "PortGame.source_consume_item_filter_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void apply(Block block){", "has_items_assignment_expr": "block.hasItems = true;", "accepts_items_assignment_expr": "block.acceptsItems = true;", "each_expr": "content.items().each(filter, item -> block.itemFilter[item.id] = true);", "item_filter_assignment_expr": "block.itemFilter[item.id] = true;", "block_has_items_before": block_has_items_before, "block_accepts_items_before": block_accepts_items_before, "item_filter_before": item_filter_before, "filtered_item_ids": filtered_item_ids, "block_has_items_after": block_has_items_after, "block_accepts_items_after": block_accepts_items_after, "item_filter_after": item_filter_after}

func java_method_build_1(_args: Array = []) -> Variant:
	var filtered_item_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var build_items_has_item_flags: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var req_images: Array = []
	for index in filtered_item_ids.size():
		var valid: bool = bool(build_items_has_item_flags[index]) if index < build_items_has_item_flags.size() else false
		req_images.append({"item_id": int(filtered_item_ids[index]), "stack_amount": 1, "valid": valid, "stat_values_stack_expr": "StatValues.stack(item, 1)", "valid_expr": "build.items.has(item)"})
	var table_image_size: float = 8.0 * 4.0
	return {"source_owner": "PortGame.source_consume_item_filter_build_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void build(Building build, Table table){", "filter_field": "public Boolf<Item> filter = i -> false;", "image_expr": "MultiReqImage image = new MultiReqImage();", "each_expr": "content.items().each(i -> filter.get(i) && i.unlockedNow() && !i.hidden, item -> image.add(new ReqImage(StatValues.stack(item, 1), () -> build.items.has(item))));", "table_add_expr": "table.add(image).size(8 * 4);", "multi_req_image_class": "public class MultiReqImage extends Stack{", "multi_req_image_add_expr": "public void add(ReqImage display){", "req_image_constructor": "public ReqImage(Element image, Boolp valid){", "req_image_valid_expr": "public boolean valid(){", "stat_values_stack_expr": "public static Stack stack(UnlockableContent item, int amount){", "building_items_field": "@Nullable ItemModule items;", "item_module_has_expr": "public boolean has(Item item){", "cell_size_expr": "public Cell<T> size(float size){", "filtered_item_ids": filtered_item_ids, "build_items_has_item_flags": build_items_has_item_flags, "multi_req_image_created": true, "req_images": req_images, "req_image_count": req_images.size(), "table_add_image": true, "table_image_size": table_image_size}

func java_method_update_2(_args: Array = []) -> Variant:
	var build_state: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_consume_item_filter_update_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void update(Building build){", "empty_body": "public void update(Building build){\n    }", "build_state": build_state, "no_op": true}

func java_method_trigger_3(_args: Array = []) -> Variant:
	var build_state: Variant = _args[0] if _args.size() > 0 else null
	var consumed_item: Variant = _args[1] if _args.size() > 1 else null
	var item_removed: bool = consumed_item != null
	var remove_amount: int = 1 if item_removed else 0
	var remove_call: Variant = null
	if item_removed:
		remove_call = {"call": "build.items.remove(item, 1)", "item": consumed_item, "amount": 1}
	return {"source_owner": "PortGame.source_consume_item_filter_trigger_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void trigger(Building build){", "get_consumed_expr": "Item item = getConsumed(build);", "null_guard_expr": "if(item != null){", "remove_expr": "build.items.remove(item, 1);", "build_state": build_state, "consumed_item": consumed_item, "item_removed": item_removed, "remove_amount": remove_amount, "remove_call": remove_call}

func java_method_efficiency_4(_args: Array = []) -> Variant:
	var consume_trigger_valid: bool = bool(_args[0] if _args.size() > 0 else false)
	var consumed_item: Variant = _args[1] if _args.size() > 1 else null
	var has_consumed_item: bool = consumed_item != null
	var efficiency: float = 1.0 if consume_trigger_valid or has_consumed_item else 0.0
	return {"source_owner": "PortGame.source_consume_item_filter_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public float efficiency(Building build){", "return_expr": "return build.consumeTriggerValid() || getConsumed(build) != null ? 1f : 0f;", "consume_trigger_valid_expr": "build.consumeTriggerValid()", "get_consumed_expr": "getConsumed(build) != null", "consume_trigger_valid": consume_trigger_valid, "consumed_item": consumed_item, "has_consumed_item": has_consumed_item, "efficiency": efficiency}

func java_method_getConsumed_5(_args: Array = []) -> Variant:
	var content_items: Array = _args[0] if _args.size() > 0 else []
	var build_items_has_item_flags: Array = _args[1] if _args.size() > 1 else []
	var filter_get_item_flags: Array = _args[2] if _args.size() > 2 else []
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
	return {"source_owner": "PortGame.source_consume_item_filter_get_consumed_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public @Nullable Item getConsumed(Building build){", "loop_expr": "for(int i = 0; i < content.items().size; i++){", "content_item_expr": "Item item = content.item(i);", "guard_expr": "if(build.items.has(item) && this.filter.get(item)){", "return_item_expr": "return item;", "return_null_expr": "return null;", "content_items": content_items, "build_items_has_item_flags": build_items_has_item_flags, "filter_get_item_flags": filter_get_item_flags, "checked_items": checked_items, "consumed_item": consumed_item, "consumed_index": consumed_index}

func java_method_display_6(_args: Array = []) -> Variant:
	var booster: bool = bool(_args[0] if _args.size() > 0 else false)
	var stats_time_period: float = float(_args[1] if _args.size() > 1 else -1.0)
	var filtered_item_ids: Array = _args[2] if _args.size() > 2 else []
	var selected_stat: String = "booster" if booster else "input"
	var display_items: Array = []
	for item_id in filtered_item_ids:
		var display_expr: String = "displayItem(item)" if stats_time_period <= 0.0 else "displayItem(item, 1, timePeriod, true)"
		display_items.append({"item_id": int(item_id), "time_period": stats_time_period, "display_expr": display_expr})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.items(stats.timePeriod, filter)", "time_period": stats_time_period, "filtered_item_ids": filtered_item_ids}
	return {"source_owner": "PortGame.source_consume_item_filter_display_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public void display(Stats stats){", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, StatValues.items(stats.timePeriod, filter));", "stats_add_call_expr": "stats.add", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "stat_values_items_expr": "StatValues.items(stats.timePeriod, filter)", "stat_values_items_method": "public static StatValue items(float timePeriod, Boolf<Item> filter){", "content_filter_expr": "Seq<Item> list = content.items().select(i -> filter.get(i) && i.unlockedNow() && !i.isHidden());", "display_item_expr": "table.add(timePeriod <= 0 ? displayItem(item) : displayItem(item, 1, timePeriod, true)).padRight(5);", "booster": booster, "selected_stat": selected_stat, "stats_time_period": stats_time_period, "filtered_item_ids": filtered_item_ids, "stats_add_call": stats_add_call, "display_items": display_items}

func java_method_efficiencyMultiplier_7(_args: Array = []) -> Variant:
	return null

func java_method_itemEfficiencyMultiplier_8(_args: Array = []) -> Variant:
	var efficiency_multiplier: float = 1.0
	return {"source_owner": "PortGame.source_consume_item_filter_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "method": "public float itemEfficiencyMultiplier(Item item){", "efficiency_multiplier": efficiency_multiplier, "return_expr": "return 1f;"}

func java_constructor_ConsumeItemFilter_0(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var filter_after: Variant = item
	return {"source_owner": "PortGame.source_consume_item_filter_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "constructor": "public ConsumeItemFilter(Boolf<Item> item){", "filter_assignment_expr": "this.filter = item;", "filter_field": "public Boolf<Item> filter = i -> false;", "item": item, "filter_after": filter_after}

func java_constructor_ConsumeItemFilter_1(_args: Array = []) -> Variant:
	var filter_after: String = "i -> false"
	return {"source_owner": "PortGame.source_consume_item_filter_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java", "constructor": "public ConsumeItemFilter(){", "filter_field": "public Boolf<Item> filter = i -> false;", "filter_after": filter_after}
