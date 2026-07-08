# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquidsDynamic.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquidsDynamic"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "liquids", "type": "Func"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquidsDynamic", "parameters": [{"name": "liquids", "type": "Func", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "rebuild", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var block_has_liquids_after: bool = true
	return {"source_owner": "PortGame.source_consume_liquids_dynamic_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public void apply(Block block){", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": block_has_liquids_after, "assignment_expr": "block.hasLiquids = true;"}

func java_method_build_1(_args: Array = []) -> Variant:
	return null

func java_method_rebuild_2(_args: Array = []) -> Variant:
	return null

func java_method_update_3(_args: Array = []) -> Variant:
	var liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var liquid_stack_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var build_edelta: float = float(_args[2] if _args.size() > 2 else 0.0)
	var multiplier_get_build: float = float(_args[3] if _args.size() > 3 else 1.0)
	var remove_calls: Array = []
	for index in liquid_ids.size():
		var stack_amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)
		var remove_amount: float = stack_amount * build_edelta * multiplier_get_build
		remove_calls.append({"call": "build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);", "liquid_id": int(liquid_ids[index]), "stack_amount": stack_amount, "amount": remove_amount})
	return {"source_owner": "PortGame.source_consume_liquids_dynamic_update_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public void update(Building build){", "multiplier_expr": "float mult = multiplier.get(build);", "loop_expr": "for(LiquidStack stack : liquids.get(build)){", "remove_expr": "build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);", "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "build_edelta": build_edelta, "multiplier_get_build": multiplier_get_build, "remove_calls": remove_calls}

func java_method_efficiency_4(_args: Array = []) -> Variant:
	return null
