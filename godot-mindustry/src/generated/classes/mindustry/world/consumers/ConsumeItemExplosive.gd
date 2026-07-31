# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemExplosive.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemExplosive"
const JAVA_EXTENDS := "ConsumeItemEfficiency"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "minExplosiveness", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemExplosive", "parameters": [{"name": "minCharge", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeItemExplosive", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "itemEfficiencyMultiplier", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const SOURCE_CONSUME_ITEM_EXPLOSIVE_MIN_CHARGE_DEFAULT := source_consumer_defaults.CONSUME_ITEM_EXPLOSIVE_MIN_CHARGE_DEFAULT

func java_method_itemEfficiencyMultiplier_0(_args: Array = []) -> Variant:
	var item_explosiveness: float = float(_args[0] if _args.size() > 0 else 0.0)
	var efficiency_multiplier: float = item_explosiveness
	return {"source_owner": "port_game.source_consume_item_explosive_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemExplosive.java", "method": "public float itemEfficiencyMultiplier(Item item){", "item_explosiveness": item_explosiveness, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return item.explosiveness;"}

func java_constructor_ConsumeItemExplosive_0(_args: Array = []) -> Variant:
	var min_charge: float = float(_args[0] if _args.size() > 0 else 0.0)
	var min_explosiveness_after: float = min_charge
	var filter_expr: String = "item -> item.explosiveness >= this.minExplosiveness"
	return {"source_owner": "port_game.source_consume_item_explosive_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemExplosive.java", "constructor": "public ConsumeItemExplosive(float minCharge){", "min_explosiveness_field": "public float minExplosiveness;", "assignment_expr": "this.minExplosiveness = minCharge;", "filter_assignment_expr": "filter = item -> item.explosiveness >= this.minExplosiveness;", "filter_expr": filter_expr, "item_explosiveness_field": "public float explosiveness = 0f;", "min_charge": min_charge, "min_explosiveness_after": min_explosiveness_after}

func java_constructor_ConsumeItemExplosive_1(_args: Array = []) -> Variant:
	var min_charge: float = SOURCE_CONSUME_ITEM_EXPLOSIVE_MIN_CHARGE_DEFAULT
	var min_explosiveness_after: float = min_charge
	var filter_expr: String = "item -> item.explosiveness >= this.minExplosiveness"
	return {"source_owner": "port_game.source_consume_item_explosive_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemExplosive.java", "constructor": "public ConsumeItemExplosive(){", "default_call_expr": "this(0.2f);", "typed_constructor_expr": "public ConsumeItemExplosive(float minCharge){", "assignment_expr": "this.minExplosiveness = minCharge;", "filter_assignment_expr": "filter = item -> item.explosiveness >= this.minExplosiveness;", "filter_expr": filter_expr, "default_min_charge": SOURCE_CONSUME_ITEM_EXPLOSIVE_MIN_CHARGE_DEFAULT, "min_explosiveness_after": min_explosiveness_after}
