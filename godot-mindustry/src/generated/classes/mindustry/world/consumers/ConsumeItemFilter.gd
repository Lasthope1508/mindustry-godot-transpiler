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
	return null

func java_method_build_1(_args: Array = []) -> Variant:
	return null

func java_method_update_2(_args: Array = []) -> Variant:
	return null

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
