extends RefCounted
class_name SourceConsumeItemFilterState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func apply_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, filtered_item_ids: Array) -> Dictionary:
	var item_filter_after := item_filter_before.duplicate()
	for item_id in filtered_item_ids:
		item_filter_after[int(item_id)] = true
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_APPLY_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public void apply(Block block){",
		"has_items_assignment_expr": "block.hasItems = true;",
		"accepts_items_assignment_expr": "block.acceptsItems = true;",
		"each_expr": "content.items().each(filter, item -> block.itemFilter[item.id] = true);",
		"item_filter_assignment_expr": "block.itemFilter[item.id] = true;",
		"block_has_items_before": block_has_items_before,
		"block_accepts_items_before": block_accepts_items_before,
		"item_filter_before": item_filter_before,
		"filtered_item_ids": filtered_item_ids,
		"block_has_items_after": true,
		"block_accepts_items_after": true,
		"item_filter_after": item_filter_after,
	}


static func build_state(filtered_item_ids: Array, build_items_has_item_flags: Array, source_ui_icon_med: float) -> Dictionary:
	var req_images: Array = []
	for index in filtered_item_ids.size():
		var valid: bool = bool(build_items_has_item_flags[index]) if index < build_items_has_item_flags.size() else false
		req_images.append({"item_id": int(filtered_item_ids[index]), "stack_amount": 1, "valid": valid, "stat_values_stack_expr": "StatValues.stack(item, 1)", "valid_expr": "build.items.has(item)"})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_BUILD_STATE,
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
		"table_image_size": source_ui_icon_med,
	}


@warning_ignore("shadowed_variable")
static func update_state(build_state: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_UPDATE_STATE,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_TRIGGER_STATE,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_STATE,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_GET_CONSUMED_STATE,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_DISPLAY_STATE,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_EFFICIENCY_MULTIPLIER_STATE,
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


static func item_efficiency_multiplier_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_ITEM_EFFICIENCY_MULTIPLIER_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"method": "public float itemEfficiencyMultiplier(Item item){",
		"efficiency_multiplier": 1.0,
		"return_expr": "return 1f;",
	}


static func constructor_state(item: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_CONSTRUCTOR_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"constructor": "public ConsumeItemFilter(Boolf<Item> item){",
		"filter_assignment_expr": "this.filter = item;",
		"filter_field": "public Boolf<Item> filter = i -> false;",
		"item": item,
		"filter_after": item,
	}


static func default_constructor_state(default_filter_expr: String) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FILTER_DEFAULT_CONSTRUCTOR_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeItemFilter.java",
		"constructor": "public ConsumeItemFilter(){",
		"filter_field": "public Boolf<Item> filter = i -> false;",
		"filter_after": default_filter_expr,
	}


static func generated_item_efficiency_multiplier_bridge_state() -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_method_itemEfficiencyMultiplier_8([])
	var canonical = item_efficiency_multiplier_state()
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_ITEM_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_item_filter.itemEfficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null)}


static func generated_constructor_bridge_state(item: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemFilter_0([item])
	var canonical = constructor_state(item)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_CONSTRUCTOR_STATE, "generated_owner": "consume_item_filter.constructor", "result": result, "canonical": canonical, "matches": result.get("filter_after", null) == canonical.get("filter_after", null)}


static func generated_default_constructor_bridge_state(default_filter_expr: String) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemFilter_1([])
	var canonical = default_constructor_state(default_filter_expr)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": "consume_item_filter.default_constructor", "result": result, "canonical": canonical, "matches": result.get("filter_after", null) == canonical.get("filter_after", null)}


static func generated_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, filtered_item_ids: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_method_apply_0([block_has_items_before, block_accepts_items_before, item_filter_before, filtered_item_ids])
	var canonical = apply_state(block_has_items_before, block_accepts_items_before, item_filter_before, filtered_item_ids)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_APPLY_STATE, "generated_owner": "consume_item_filter.apply", "result": result, "canonical": canonical, "matches": result.get("block_has_items_after", null) == canonical.get("block_has_items_after", null) and result.get("block_accepts_items_after", null) == canonical.get("block_accepts_items_after", null) and result.get("item_filter_after", []) == canonical.get("item_filter_after", [])}


static func generated_build_bridge_state(filtered_item_ids: Array, build_items_has_item_flags: Array, source_ui_icon_med: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_method_build_1([filtered_item_ids, build_items_has_item_flags])
	var canonical = build_state(filtered_item_ids, build_items_has_item_flags, source_ui_icon_med)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_BUILD_STATE, "generated_owner": "consume_item_filter.build", "result": result, "canonical": canonical, "matches": result.get("req_images", []) == canonical.get("req_images", []) and result.get("table_image_size", null) == canonical.get("table_image_size", null)}


@warning_ignore("shadowed_variable")
static func generated_update_bridge_state(build_state: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_method_update_2([build_state])
	var canonical = update_state(build_state)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_UPDATE_STATE, "generated_owner": "consume_item_filter.update", "result": result, "canonical": canonical, "matches": result.get("no_op", null) == canonical.get("no_op", null) and result.get("build_state", null) == canonical.get("build_state", null)}


@warning_ignore("shadowed_variable")
static func generated_trigger_bridge_state(build_state: Variant, consumed_item: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_method_trigger_3([build_state, consumed_item])
	var canonical = trigger_state(build_state, consumed_item)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_TRIGGER_STATE, "generated_owner": "consume_item_filter.trigger", "result": result, "canonical": canonical, "matches": result.get("item_removed", null) == canonical.get("item_removed", null) and result.get("remove_amount", null) == canonical.get("remove_amount", null) and result.get("consumed_item", null) == canonical.get("consumed_item", null)}


static func generated_efficiency_bridge_state(consume_trigger_valid: bool, consumed_item: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_method_efficiency_4([consume_trigger_valid, consumed_item])
	var canonical = efficiency_state(consume_trigger_valid, consumed_item)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_EFFICIENCY_STATE, "generated_owner": "consume_item_filter.efficiency", "result": result, "canonical": canonical, "matches": result.get("efficiency", null) == canonical.get("efficiency", null) and result.get("has_consumed_item", null) == canonical.get("has_consumed_item", null)}


static func generated_get_consumed_bridge_state(content_items: Array, build_items_has_item_flags: Array, filter_get_item_flags: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_method_getConsumed_5([content_items, build_items_has_item_flags, filter_get_item_flags])
	var canonical = get_consumed_state(content_items, build_items_has_item_flags, filter_get_item_flags)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_GET_CONSUMED_STATE, "generated_owner": "consume_item_filter.getConsumed", "result": result, "canonical": canonical, "matches": result.get("consumed_item", null) == canonical.get("consumed_item", null) and result.get("consumed_index", null) == canonical.get("consumed_index", null) and result.get("checked_items", []) == canonical.get("checked_items", [])}


static func generated_display_bridge_state(booster: bool, stats_time_period: float, filtered_item_ids: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_method_display_6([booster, stats_time_period, filtered_item_ids])
	var canonical = display_state(booster, stats_time_period, filtered_item_ids)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_DISPLAY_STATE, "generated_owner": "consume_item_filter.display", "result": result, "canonical": canonical, "matches": result.get("selected_stat", null) == canonical.get("selected_stat", null) and result.get("display_items", []) == canonical.get("display_items", []) and result.get("stats_add_call", {}) == canonical.get("stats_add_call", {})}


static func generated_efficiency_multiplier_bridge_state(consumed_item: Variant, item_efficiency_multiplier: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFilter.gd")
	var instance = script.new()
	var result = instance.java_method_efficiencyMultiplier_7([consumed_item, item_efficiency_multiplier])
	var canonical = efficiency_multiplier_state(consumed_item, item_efficiency_multiplier)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_FILTER_STATE_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_item_filter.efficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null) and result.get("has_consumed_item", null) == canonical.get("has_consumed_item", null)}
