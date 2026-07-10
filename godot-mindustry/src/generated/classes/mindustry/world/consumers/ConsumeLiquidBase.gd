# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquidBase.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquidBase"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "amount", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquidBase", "parameters": [{"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeLiquidBase", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["abstract", "public"], "name": "consumes", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_constructor_ConsumeLiquidBase_0(_args: Array = []) -> Variant:
	var amount: float = float(_args[0] if _args.size() > 0 else 0.0)
	var amount_after: float = amount
	return {"source_owner": "PortGame.source_consume_liquid_base_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidBase.java", "constructor": "public ConsumeLiquidBase(float amount){", "amount_field": "public float amount;", "assignment_expr": "this.amount = amount;", "amount": amount, "amount_after": amount_after}

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var block_has_liquids_after: bool = true
	return {"source_owner": "PortGame.source_consume_liquid_base_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidBase.java", "method": "public void apply(Block block){", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": block_has_liquids_after, "assignment_expr": "block.hasLiquids = true;"}

func java_method_consumes_1(_args: Array = []) -> Variant:
	return null
