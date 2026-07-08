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
	var current_liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var next_liquid_ids: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var liquid_ids_changed: bool = current_liquid_ids != next_liquid_ids
	var rebuild_calls: Array = []
	rebuild_calls.append({"call": "rebuild(build, cont);", "phase": "initial", "liquid_ids": current_liquid_ids})
	var current_liquid_ids_after_update: Array = current_liquid_ids.duplicate()
	if liquid_ids_changed:
		rebuild_calls.append({"call": "rebuild(build, cont);", "phase": "update", "liquid_ids": next_liquid_ids})
		current_liquid_ids_after_update = next_liquid_ids.duplicate()
	return {"source_owner": "PortGame.source_consume_liquids_dynamic_build_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public void build(Building build, Table table){", "current_expr": "LiquidStack[][] current = {liquids.get(build)};", "table_expr": "table.table(cont -> {", "update_expr": "table.update(() -> {", "changed_expr": "if(current[0] != liquids.get(build)){", "rebuild_expr": "rebuild(build, cont);", "assignment_expr": "current[0] = liquids.get(build);", "current_liquid_ids": current_liquid_ids, "next_liquid_ids": next_liquid_ids, "liquid_ids_changed": liquid_ids_changed, "rebuild_calls": rebuild_calls, "current_liquid_ids_after_update": current_liquid_ids_after_update, "table_cell_created": true, "update_registered": true}

func java_method_rebuild_2(_args: Array = []) -> Variant:
	var liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var liquid_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var building_has_liquids: bool = bool(_args[2] if _args.size() > 2 else true)
	var req_images: Array = []
	var row_calls: Array = []
	for index in liquid_ids.size():
		var liquid_amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)
		var valid: bool = building_has_liquids and liquid_amount > 0.0
		req_images.append({"liquid_id": int(liquid_ids[index]), "liquid_amount": liquid_amount, "valid": valid, "ui_icon_expr": "stack.liquid.uiIcon", "size": 32.0, "pad_right": 8.0})
		if (index + 1) % 4 == 0:
			row_calls.append({"call": "table.row();", "after_count": index + 1})
	return {"source_owner": "PortGame.source_consume_liquids_dynamic_rebuild_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "private void rebuild(Building build, Table table){", "clear_expr": "table.clear();", "i_initial_expr": "int i = 0;", "loop_expr": "for(LiquidStack stack : liquids.get(build)){", "add_expr": "table.add(new ReqImage(stack.liquid.uiIcon, () -> build.liquids != null && build.liquids.get(stack.liquid) > 0)).size(Vars.iconMed).padRight(8);", "row_expr": "if(++i % 4 == 0) table.row();", "liquid_ids": liquid_ids, "liquid_amounts": liquid_amounts, "building_has_liquids": building_has_liquids, "req_images": req_images, "row_calls": row_calls, "cleared": true}

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
	var liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var liquid_stack_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var liquid_amounts: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var build_edelta: float = float(_args[3] if _args.size() > 3 else 0.0)
	var multiplier_get_build: float = float(_args[4] if _args.size() > 4 else 1.0)
	var ed: float = build_edelta
	if ed <= 0.00000001:
		return {"source_owner": "PortGame.source_consume_liquids_dynamic_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public float efficiency(Building build){", "ed_expr": "float ed = build.edelta();", "ed_guard_expr": "if(ed <= 0.00000001f) return 0f;", "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "liquid_amounts": liquid_amounts, "build_edelta": build_edelta, "multiplier_get_build": multiplier_get_build, "ed": ed, "min_initial_expr": "float min = 1f;", "loop_expr": "for(LiquidStack stack : liquids.get(build)){", "efficiency_expr": "Math.min(build.liquids.get(stack.liquid) / (stack.amount * ed * multiplier.get(build)), min)", "return_expr": "return min;", "per_stack_efficiencies": [], "efficiency": 0.0}
	var min_efficiency: float = 1.0
	var per_stack_efficiencies: Array = []
	for index in liquid_ids.size():
		var stack_amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)
		var liquid_amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)
		var denominator: float = stack_amount * ed * multiplier_get_build
		var stack_efficiency: float = liquid_amount / denominator
		min_efficiency = min(stack_efficiency, min_efficiency)
		per_stack_efficiencies.append({"liquid_id": int(liquid_ids[index]), "liquid_amount": liquid_amount, "stack_amount": stack_amount, "denominator": denominator, "efficiency": stack_efficiency})
	return {"source_owner": "PortGame.source_consume_liquids_dynamic_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidsDynamic.java", "method": "public float efficiency(Building build){", "ed_expr": "float ed = build.edelta();", "ed_guard_expr": "if(ed <= 0.00000001f) return 0f;", "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "liquid_amounts": liquid_amounts, "build_edelta": build_edelta, "multiplier_get_build": multiplier_get_build, "ed": ed, "min_initial_expr": "float min = 1f;", "loop_expr": "for(LiquidStack stack : liquids.get(build)){", "efficiency_expr": "Math.min(build.liquids.get(stack.liquid) / (stack.amount * ed * multiplier.get(build)), min)", "return_expr": "return min;", "per_stack_efficiencies": per_stack_efficiencies, "efficiency": min_efficiency}
