# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquids.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquids"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "liquids", "type": "LiquidStack"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquids", "parameters": [{"name": "liquids", "type": "LiquidStack", "varargs": false}]}, {"modifiers": ["protected"], "name": "ConsumeLiquids", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var liquid_filter_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var liquid_ids: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var liquid_filter_after: Array = liquid_filter_before.duplicate()
	for liquid_id in liquid_ids:
		liquid_filter_after[int(liquid_id)] = true
	return {"source_owner": "PortGame.source_consume_liquids_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquids.java", "method": "public void apply(Block block){", "has_liquids_assignment_expr": "block.hasLiquids = true;", "loop_expr": "for(var stack : liquids){", "liquid_filter_assignment_expr": "block.liquidFilter[stack.liquid.id] = true;", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": true, "liquid_filter_before": liquid_filter_before, "liquid_ids": liquid_ids, "liquid_filter_after": liquid_filter_after}

func java_method_build_1(_args: Array = []) -> Variant:
	var liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var liquid_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var req_images: Array = []
	var row_calls: Array = []
	var icon_size: String = "Vars.iconMed"
	var pad_right: float = 8.0
	for index in range(liquid_ids.size()):
		var amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)
		req_images.append({"liquid_id": liquid_ids[index], "amount": amount, "valid": amount > 0.0, "icon": "stack.liquid.uiIcon", "size": icon_size, "pad_right": pad_right})
		if (index + 1) % 4 == 0:
			row_calls.append(index + 1)
	return {"source_owner": "PortGame.source_consume_liquids_build_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquids.java", "method": "public void build(Building build, Table table){", "table_expr": "table.table(c -> {", "i_initial_expr": "int i = 0;", "loop_expr": "for(var stack : liquids){", "add_expr": "c.add(new ReqImage(stack.liquid.uiIcon,", "valid_expr": "() -> build.liquids.get(stack.liquid) > 0)).size(Vars.iconMed).padRight(8);", "row_expr": "if(++i % 4 == 0) c.row();", "table_left_expr": "}).left();", "req_image_constructor": "public ReqImage(TextureRegion region, Boolp valid){", "req_image_valid": "public boolean valid(){", "vars_icon_med": "iconMed = 8*4f", "liquid_ids": liquid_ids, "liquid_amounts": liquid_amounts, "req_images": req_images, "row_calls": row_calls, "table_left": true}

func java_method_update_2(_args: Array = []) -> Variant:
	var liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var liquid_stack_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var build_edelta: float = float(_args[2] if _args.size() > 2 else 0.0)
	var multiplier_get_build: float = float(_args[3] if _args.size() > 3 else 1.0)
	var remove_calls: Array = []
	for index in range(liquid_ids.size()):
		var amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)
		var remove_amount: float = amount * build_edelta * multiplier_get_build
		remove_calls.append({"liquid_id": liquid_ids[index], "amount": amount, "remove_amount": remove_amount})
	return {"source_owner": "PortGame.source_consume_liquids_update_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquids.java", "method": "public void update(Building build){", "multiplier_expr": "float mult = multiplier.get(build);", "loop_expr": "for(var stack : liquids){", "remove_expr": "build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);", "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "build_edelta": build_edelta, "multiplier_get_build": multiplier_get_build, "remove_calls": remove_calls}

func java_method_efficiency_3(_args: Array = []) -> Variant:
	var liquid_ids: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var liquid_stack_amounts: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var liquid_amounts: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var build_edelta: float = float(_args[3] if _args.size() > 3 else 0.0)
	var build_efficiency_scale: float = float(_args[4] if _args.size() > 4 else 1.0)
	var multiplier_get_build: float = float(_args[5] if _args.size() > 5 else 1.0)
	var ed: float = build_edelta * build_efficiency_scale
	if ed <= 0.00000001:
		return {"source_owner": "PortGame.source_consume_liquids_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquids.java", "method": "public float efficiency(Building build){", "multiplier_expr": "float mult = multiplier.get(build);", "ed_expr": "float ed = build.edelta() * build.efficiencyScale();", "ed_guard_expr": "if(ed <= 0.00000001f) return 0f;", "liquids_field": "public final LiquidStack[] liquids;", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "liquid_stack_liquid_field": "public Liquid liquid;", "liquid_stack_amount_field": "public float amount;", "building_liquids_field": "@Nullable LiquidModule liquids;", "building_edelta_method": "public float edelta(){", "building_efficiency_scale_method": "public float efficiencyScale(){", "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "liquid_amounts": liquid_amounts, "build_edelta": build_edelta, "build_efficiency_scale": build_efficiency_scale, "multiplier_get_build": multiplier_get_build, "ed": ed, "min_initial_expr": "float min = 1f;", "loop_expr": "for(var stack : liquids){", "efficiency_expr": "Math.min(build.liquids.get(stack.liquid) / (stack.amount * ed * mult), min)", "return_expr": "return min;", "per_stack_efficiencies": [], "efficiency": 0.0}
	var min_efficiency: float = 1.0
	var per_stack_efficiencies: Array = []
	for index in liquid_ids.size():
		var stack_amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)
		var liquid_amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)
		var denominator: float = stack_amount * ed * multiplier_get_build
		var stack_efficiency: float = liquid_amount / denominator
		min_efficiency = min(stack_efficiency, min_efficiency)
		per_stack_efficiencies.append({"liquid_id": int(liquid_ids[index]), "liquid_amount": liquid_amount, "stack_amount": stack_amount, "denominator": denominator, "efficiency": stack_efficiency})
	return {"source_owner": "PortGame.source_consume_liquids_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquids.java", "method": "public float efficiency(Building build){", "multiplier_expr": "float mult = multiplier.get(build);", "ed_expr": "float ed = build.edelta() * build.efficiencyScale();", "ed_guard_expr": "if(ed <= 0.00000001f) return 0f;", "liquids_field": "public final LiquidStack[] liquids;", "multiplier_field": "public Floatf<Building> multiplier = b -> 1f;", "liquid_stack_liquid_field": "public Liquid liquid;", "liquid_stack_amount_field": "public float amount;", "building_liquids_field": "@Nullable LiquidModule liquids;", "building_edelta_method": "public float edelta(){", "building_efficiency_scale_method": "public float efficiencyScale(){", "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "liquid_amounts": liquid_amounts, "build_edelta": build_edelta, "build_efficiency_scale": build_efficiency_scale, "multiplier_get_build": multiplier_get_build, "ed": ed, "min_initial_expr": "float min = 1f;", "loop_expr": "for(var stack : liquids){", "efficiency_expr": "Math.min(build.liquids.get(stack.liquid) / (stack.amount * ed * mult), min)", "return_expr": "return min;", "per_stack_efficiencies": per_stack_efficiencies, "efficiency": min_efficiency}

func java_method_display_4(_args: Array = []) -> Variant:
	var booster: bool = bool(_args[0] if _args.size() > 0 else false)
	var liquid_ids: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var liquid_stack_amounts: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var selected_stat: String = "booster" if booster else "input"
	var display_liquids: Array = []
	for index in liquid_ids.size():
		var liquid_id: int = int(liquid_ids[index])
		var stack_amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)
		var display_amount_per_second: float = stack_amount * 60.0
		display_liquids.append({"liquid_id": liquid_id, "stack_amount": stack_amount, "display_amount_per_second": display_amount_per_second, "per_second": true, "display_expr": "displayLiquid(stack.liquid, stack.amount * (60f / timePeriod), perSecond)", "pad_right": 5.0})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.liquids(1f, true, liquids)", "time_period": 1.0, "per_second": true, "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts}
	return {"source_owner": "PortGame.source_consume_liquids_display_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquids.java", "method": "public void display(Stats stats){", "liquids_field": "public final LiquidStack[] liquids;", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, StatValues.liquids(1f, true, liquids));", "stats_add_call_expr": "stats.add", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "stat_values_liquids_expr": "StatValues.liquids(1f, true, liquids)", "stat_values_liquids_method": "public static StatValue liquids(float timePeriod, boolean perSecond, LiquidStack... stacks){", "display_liquid_expr": "table.add(displayLiquid(stack.liquid, stack.amount * (60f / timePeriod), perSecond)).padRight(5);", "stats_add_method": "public void add(Stat stat, StatValue value){", "booster_field": "public boolean booster;", "stat_input_expr": "input = new Stat(\"input\", StatCat.crafting),", "stat_booster_expr": "booster = new Stat(\"booster\", StatCat.optional),", "liquid_stack_liquid_field": "public Liquid liquid;", "liquid_stack_amount_field": "public float amount;", "booster": booster, "selected_stat": selected_stat, "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts, "time_period": 1.0, "per_second": true, "stats_add_call": stats_add_call, "display_liquids": display_liquids}
