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
	return null

func java_method_efficiencyMultiplier_1(_args: Array = []) -> Variant:
	var consumed_item: Variant = _args[0] if _args.size() > 0 else null
	var item_multiplier_value: float = float(_args[1] if _args.size() > 1 else 1.0)
	var efficiency_multiplier: float = item_multiplier_value
	return {"source_owner": "PortGame.source_consume_item_list_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemList.java", "method": "public float efficiencyMultiplier(Building build){", "get_consumed_expr": "var item = getConsumed(build);", "map_get_expr": "itemMultipliers.get(item, 1f)", "return_expr": "return itemMultipliers.get(item, 1f);", "consumed_item": consumed_item, "item_multiplier_value": item_multiplier_value, "efficiency_multiplier": efficiency_multiplier}
