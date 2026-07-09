# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemCharged.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemCharged"
const JAVA_EXTENDS := "ConsumeItemEfficiency"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "minCharge", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemCharged", "parameters": [{"name": "minCharge", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeItemCharged", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "itemEfficiencyMultiplier", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_itemEfficiencyMultiplier_0(_args: Array = []) -> Variant:
	var item_charge: float = float(_args[0] if _args.size() > 0 else 0.0)
	var efficiency_multiplier: float = item_charge
	return {"source_owner": "PortGame.source_consume_item_charged_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemCharged.java", "method": "public float itemEfficiencyMultiplier(Item item){", "item_charge": item_charge, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return item.charge;"}

func java_constructor_ConsumeItemCharged_0(_args: Array = []) -> Variant:
	var min_charge: float = float(_args[0] if _args.size() > 0 else 0.0)
	var min_charge_after: float = min_charge
	var filter_expr: String = "item -> item.charge >= this.minCharge"
	return {"source_owner": "PortGame.source_consume_item_charged_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemCharged.java", "constructor": "public ConsumeItemCharged(float minCharge){", "min_charge_field": "public float minCharge;", "assignment_expr": "this.minCharge = minCharge;", "filter_assignment_expr": "filter = item -> item.charge >= this.minCharge;", "filter_expr": filter_expr, "item_charge_field": "public float charge = 0f;", "min_charge": min_charge, "min_charge_after": min_charge_after}
