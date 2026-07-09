# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquidFlammable.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquidFlammable"
const JAVA_EXTENDS := "ConsumeLiquidFilter"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "minFlammability", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquidFlammable", "parameters": [{"name": "minFlammability", "type": "float", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeLiquidFlammable", "parameters": [{"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeLiquidFlammable", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "liquidEfficiencyMultiplier", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_display_0(_args: Array = []) -> Variant:
	return null

func java_method_liquidEfficiencyMultiplier_1(_args: Array = []) -> Variant:
	var liquid_flammability: float = float(_args[0] if _args.size() > 0 else 0.0)
	var efficiency_multiplier: float = liquid_flammability
	return {"source_owner": "PortGame.source_consume_liquid_flammable_liquid_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java", "method": "public float liquidEfficiencyMultiplier(Liquid liquid){", "liquid_flammability": liquid_flammability, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return liquid.flammability;"}

func java_constructor_ConsumeLiquidFlammable_0(_args: Array = []) -> Variant:
	var min_flammability: float = float(_args[0] if _args.size() > 0 else 0.0)
	var amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var amount_after: float = amount
	var min_flammability_after: float = min_flammability
	var filter_expr: String = "liquid -> liquid.flammability >= this.minFlammability"
	return {"source_owner": "PortGame.source_consume_liquid_flammable_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java", "constructor": "public ConsumeLiquidFlammable(float minFlammability, float amount){", "min_flammability_field": "public float minFlammability;", "amount_field": "public float amount;", "amount_assignment_expr": "this.amount = amount;", "assignment_expr": "this.minFlammability = minFlammability;", "filter_assignment_expr": "this.filter = liquid -> liquid.flammability >= this.minFlammability;", "filter_expr": filter_expr, "liquid_flammability_field": "public float flammability;", "min_flammability": min_flammability, "amount": amount, "amount_after": amount_after, "min_flammability_after": min_flammability_after}

func java_constructor_ConsumeLiquidFlammable_1(_args: Array = []) -> Variant:
	var amount: float = float(_args[0] if _args.size() > 0 else 0.0)
	var min_flammability: float = 0.2
	var amount_after: float = amount
	var min_flammability_after: float = min_flammability
	var filter_expr: String = "liquid -> liquid.flammability >= this.minFlammability"
	return {"source_owner": "PortGame.source_consume_liquid_flammable_amount_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java", "constructor": "public ConsumeLiquidFlammable(float amount){", "default_call_expr": "this(0.2f, amount);", "typed_constructor_expr": "public ConsumeLiquidFlammable(float minFlammability, float amount){", "amount_assignment_expr": "this.amount = amount;", "assignment_expr": "this.minFlammability = minFlammability;", "filter_assignment_expr": "this.filter = liquid -> liquid.flammability >= this.minFlammability;", "filter_expr": filter_expr, "default_min_flammability": 0.2, "amount": amount, "amount_after": amount_after, "min_flammability_after": min_flammability_after}
