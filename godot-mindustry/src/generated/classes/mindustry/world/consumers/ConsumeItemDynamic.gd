# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemDynamic.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemDynamic"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "items", "type": "Func"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemDynamic", "parameters": [{"name": "items", "type": "Func", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "rebuild", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "trigger", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_items_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var block_accepts_items_before: bool = bool(_args[1] if _args.size() > 1 else false)
	var block_has_items_after: bool = true
	var block_accepts_items_after: bool = true
	return {"source_owner": "PortGame.source_consume_item_dynamic_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeItemDynamic.java", "method": "public void apply(Block block){", "has_items_assignment_expr": "block.hasItems = true;", "accepts_items_assignment_expr": "block.acceptsItems = true;", "block_has_items_before": block_has_items_before, "block_accepts_items_before": block_accepts_items_before, "block_has_items_after": block_has_items_after, "block_accepts_items_after": block_accepts_items_after}

func java_method_build_1(_args: Array = []) -> Variant:
	var current_item_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var next_item_ids: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var item_ids_changed: bool = current_item_ids != next_item_ids
	var rebuild_calls: Array = []
	rebuild_calls.append({"call": "rebuild(build, cont);", "phase": "initial", "item_ids": current_item_ids})
	var current_item_ids_after_update: Array = current_item_ids.duplicate()
	if item_ids_changed:
		rebuild_calls.append({"call": "rebuild(build, cont);", "phase": "update", "item_ids": next_item_ids})
		current_item_ids_after_update = next_item_ids.duplicate()
	return {"source_owner": "PortGame.source_consume_item_dynamic_build_state", "source": "core/src/mindustry/world/consumers/ConsumeItemDynamic.java", "method": "public void build(Building build, Table table){", "current_expr": "ItemStack[][] current = {items.get(build)};", "table_expr": "table.table(cont -> {", "update_expr": "table.update(() -> {", "changed_expr": "if(current[0] != items.get(build)){", "rebuild_expr": "rebuild(build, cont);", "assignment_expr": "current[0] = items.get(build);", "current_item_ids": current_item_ids, "next_item_ids": next_item_ids, "item_ids_changed": item_ids_changed, "rebuild_calls": rebuild_calls, "current_item_ids_after_update": current_item_ids_after_update, "table_cell_created": true, "update_registered": true}

func java_method_rebuild_2(_args: Array = []) -> Variant:
	return null

func java_method_trigger_3(_args: Array = []) -> Variant:
	return null

func java_method_efficiency_4(_args: Array = []) -> Variant:
	return null

func java_constructor_ConsumeItemDynamic_0(_args: Array = []) -> Variant:
	var items: Variant = _args[0] if _args.size() > 0 else null
	var items_after: Variant = items
	return {"source_owner": "PortGame.source_consume_item_dynamic_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemDynamic.java", "constructor": "public <T extends Building> ConsumeItemDynamic(Func<T, ItemStack[]> items){", "suppress_warnings_expr": "@SuppressWarnings(\"unchecked\")", "assignment_expr": "this.items = (Func<Building, ItemStack[]>)items;", "cast_expr": "(Func<Building, ItemStack[]>)items", "items": items, "items_after": items_after}
