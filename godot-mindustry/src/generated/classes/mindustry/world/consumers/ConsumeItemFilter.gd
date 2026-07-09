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
	return null

func java_method_efficiency_4(_args: Array = []) -> Variant:
	return null

func java_method_getConsumed_5(_args: Array = []) -> Variant:
	return null

func java_method_display_6(_args: Array = []) -> Variant:
	return null

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
