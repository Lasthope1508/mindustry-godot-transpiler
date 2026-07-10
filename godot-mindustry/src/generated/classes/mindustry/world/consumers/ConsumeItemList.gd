# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemList.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemList"
const JAVA_EXTENDS := "ConsumeItemFilter"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "itemMultipliers", "type": "ObjectFloatMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemList", "parameters": [{"name": "items", "type": "Item", "varargs": true}]}, {"modifiers": ["public"], "name": "ConsumeItemList", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setMultipliers", "parameters": [{"name": "objects", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiencyMultiplier", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setMultipliers_0(_args: Array = []) -> Variant:
	var objects: Array = _args[0] if _args.size() > 0 else []
	var put_calls: Array = []
	var i := 0
	while i < objects.size():
		var item: Variant = objects[i]
		var multiplier: float = float(objects[i + 1])
		put_calls.append({"object_index": i, "multiplier_index": i + 1, "item": item, "multiplier": multiplier, "put_expr": "itemMultipliers.put((Item)objects[i], (Float)objects[i + 1]);"})
		i += 2
	return {"source_owner": "PortGame.source_consume_item_list_set_multipliers_state", "source": "core/src/mindustry/world/consumers/ConsumeItemList.java", "field": "public ObjectFloatMap<Item> itemMultipliers = new ObjectFloatMap<>();", "comment": "/** Initializes item efficiency multiplier map. Format: [item1, mult1, item2, mult2...] */", "method": "public void setMultipliers(Object... objects){", "loop_expr": "for(int i = 0; i < objects.length; i += 2){", "put_expr": "itemMultipliers.put((Item)objects[i], (Float)objects[i + 1]);", "objects": objects, "objects_length": objects.size(), "loop_step": 2, "put_calls": put_calls, "item_multiplier_entries": put_calls}

func java_method_efficiencyMultiplier_1(_args: Array = []) -> Variant:
	var consumed_item: Variant = _args[0] if _args.size() > 0 else null
	var item_multiplier_value: float = float(_args[1] if _args.size() > 1 else 1.0)
	var efficiency_multiplier: float = item_multiplier_value
	return {"source_owner": "PortGame.source_consume_item_list_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemList.java", "method": "public float efficiencyMultiplier(Building build){", "get_consumed_expr": "var item = getConsumed(build);", "map_get_expr": "itemMultipliers.get(item, 1f)", "return_expr": "return itemMultipliers.get(item, 1f);", "consumed_item": consumed_item, "item_multiplier_value": item_multiplier_value, "efficiency_multiplier": efficiency_multiplier}
