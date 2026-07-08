# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquid.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquid"
const JAVA_EXTENDS := "ConsumeLiquidBase"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "liquid", "type": "Liquid"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["protected"], "name": "ConsumeLiquid", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "consumes", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var liquid_filter_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var liquid_id: int = int(_args[2] if _args.size() > 2 else 0)
	var base_apply_state: Dictionary = {"assignment_expr": "block.hasLiquids = true;", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": true, "method": "public void apply(Block block){", "source_owner": "PortGame.source_consume_liquid_base_apply_state"}
	var liquid_filter_after: Array = liquid_filter_before.duplicate()
	liquid_filter_after[liquid_id] = true
	return {"source_owner": "PortGame.source_consume_liquid_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquid.java", "method": "public void apply(Block block){", "super_apply_expr": "super.apply(block);", "liquid_filter_assignment_expr": "block.liquidFilter[liquid.id] = true;", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": base_apply_state["block_has_liquids_after"], "base_apply_state": base_apply_state, "liquid_filter_before": liquid_filter_before, "liquid_id": liquid_id, "liquid_filter_after": liquid_filter_after}

func java_method_build_1(_args: Array = []) -> Variant:
	return null

func java_method_update_2(_args: Array = []) -> Variant:
	return null

func java_method_efficiency_3(_args: Array = []) -> Variant:
	return null

func java_method_display_4(_args: Array = []) -> Variant:
	return null

func java_method_consumes_5(_args: Array = []) -> Variant:
	return null
