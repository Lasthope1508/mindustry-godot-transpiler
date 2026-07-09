# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquidFilter.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquidFilter"
const JAVA_EXTENDS := "ConsumeLiquidBase"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "filter", "type": "Boolf"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquidFilter", "parameters": [{"name": "liquid", "type": "Boolf", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeLiquidFilter", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "efficiencyMultiplier", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getConsumed", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "Liquid"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "consumes", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "liquidEfficiencyMultiplier", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	var block_has_liquids_before: bool = bool(_args[0] if _args.size() > 0 else false)
	var liquid_filter_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var filtered_liquid_ids: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var liquid_filter_after: Array = liquid_filter_before.duplicate()
	for liquid_id in filtered_liquid_ids:
		liquid_filter_after[int(liquid_id)] = true
	var block_has_liquids_after: bool = true
	return {"source_owner": "PortGame.source_consume_liquid_filter_apply_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java", "method": "public void apply(Block block){", "has_liquids_assignment_expr": "block.hasLiquids = true;", "each_expr": "content.liquids().each(filter, item -> block.liquidFilter[item.id] = true);", "liquid_filter_assignment_expr": "block.liquidFilter[item.id] = true", "block_has_liquids_field": "public @NoPatch boolean hasLiquids;", "block_liquid_filter_field": "public boolean[] itemFilter = {}, liquidFilter = {};", "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": block_has_liquids_after, "liquid_filter_before": liquid_filter_before, "filtered_liquid_ids": filtered_liquid_ids, "liquid_filter_after": liquid_filter_after}

func java_method_build_1(_args: Array = []) -> Variant:
	return null

func java_method_update_2(_args: Array = []) -> Variant:
	return null

func java_method_efficiency_3(_args: Array = []) -> Variant:
	return null

func java_method_efficiencyMultiplier_4(_args: Array = []) -> Variant:
	return null

func java_method_getConsumed_5(_args: Array = []) -> Variant:
	var current_liquid: Variant = _args[0] if _args.size() > 0 else null
	var current_filter_get_liquid: bool = bool(_args[1] if _args.size() > 1 else false)
	var current_amount: float = float(_args[2] if _args.size() > 2 else 0.0)
	var content_liquids: Array = _args[3] if _args.size() > 3 else []
	var filter_get_liquid_flags: Array = _args[4] if _args.size() > 4 else []
	var build_liquid_amounts: Array = _args[5] if _args.size() > 5 else []
	var current_branch_matched: bool = current_filter_get_liquid and current_amount > 0.0
	var consumed_liquid: Variant = current_liquid if current_branch_matched else null
	var consumed_index: int = -1
	var checked_liquids: Array = []
	if not current_branch_matched:
		for i in range(content_liquids.size()):
			var liq: Variant = content_liquids[i]
			var filter_get_liquid: bool = bool(filter_get_liquid_flags[i]) if i < filter_get_liquid_flags.size() else false
			var build_liquids_get: float = float(build_liquid_amounts[i]) if i < build_liquid_amounts.size() else 0.0
			var liquid_matches: bool = filter_get_liquid and build_liquids_get > 0.0
			checked_liquids.append({"index": i, "liquid": liq, "filter_get_liquid": filter_get_liquid, "build_liquids_get": build_liquids_get, "liquid_matches": liquid_matches})
			if consumed_liquid == null and liquid_matches:
				consumed_liquid = liq
				consumed_index = i
				break
	return {"source_owner": "PortGame.source_consume_liquid_filter_get_consumed_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java", "method": "public @Nullable Liquid getConsumed(Building build){", "current_guard_expr": "if(filter.get(build.liquids.current()) && build.liquids.currentAmount() > 0){", "current_return_expr": "return build.liquids.current();", "content_liquids_expr": "var liqs = content.liquids();", "loop_expr": "for(int i = 0; i < liqs.size; i++){", "liquid_get_expr": "var liq = liqs.get(i);", "fallback_guard_expr": "if(filter.get(liq) && build.liquids.get(liq) > 0){", "fallback_return_expr": "return liq;", "return_null_expr": "return null;", "current_liquid": current_liquid, "current_filter_get_liquid": current_filter_get_liquid, "current_amount": current_amount, "content_liquids": content_liquids, "filter_get_liquid_flags": filter_get_liquid_flags, "build_liquid_amounts": build_liquid_amounts, "current_branch_matched": current_branch_matched, "checked_liquids": checked_liquids, "consumed_liquid": consumed_liquid, "consumed_index": consumed_index}

func java_method_display_6(_args: Array = []) -> Variant:
	var booster: bool = bool(_args[0] if _args.size() > 0 else false)
	var amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var filtered_liquid_ids: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var selected_stat: String = "booster" if booster else "input"
	var display_amount_per_second: float = amount * 60.0
	var display_liquids: Array = []
	for index in filtered_liquid_ids.size():
		var liquid_id: int = int(filtered_liquid_ids[index])
		var has_separator_after: bool = index != filtered_liquid_ids.size() - 1
		display_liquids.append({"liquid_id": liquid_id, "display_amount_per_second": display_amount_per_second, "per_second": true, "has_separator_after": has_separator_after})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.liquids(filter, amount * 60f, true)", "amount": amount, "display_amount_per_second": display_amount_per_second, "filtered_liquid_ids": filtered_liquid_ids}
	return {"source_owner": "PortGame.source_consume_liquid_filter_display_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java", "method": "public void display(Stats stats){", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, StatValues.liquids(filter, amount * 60f, true));", "stats_add_call_expr": "stats.add", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "selected_stat": selected_stat, "stat_values_liquids_expr": "StatValues.liquids(filter, amount * 60f, true)", "stat_values_liquids_method": "public static StatValue liquids(Boolf<Liquid> filter, float amount, boolean perSecond){", "content_filter_expr": "Seq<Liquid> list = content.liquids().select(i -> filter.get(i) && i.unlockedNow() && !i.isHidden());", "loop_expr": "for(int i = 0; i < list.size; i++){", "display_liquid_expr": "table.add(displayLiquid(list.get(i), amount, perSecond)).padRight(5);", "separator_guard_expr": "if(i != list.size - 1){", "separator_expr": "table.add(\"/\");", "booster": booster, "amount": amount, "display_amount_per_second": display_amount_per_second, "per_second": true, "filtered_liquid_ids": filtered_liquid_ids, "stats_add_call": stats_add_call, "display_liquids": display_liquids}

func java_method_consumes_7(_args: Array = []) -> Variant:
	var filter_get_liquid: bool = bool(_args[0] if _args.size() > 0 else false)
	var consumes_liquid: bool = filter_get_liquid
	return {"source_owner": "PortGame.source_consume_liquid_filter_consumes_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java", "method": "public boolean consumes(Liquid liquid){", "filter_get_liquid": filter_get_liquid, "consumes_liquid": consumes_liquid, "return_expr": "return filter.get(liquid);"}

func java_method_liquidEfficiencyMultiplier_8(_args: Array = []) -> Variant:
	var efficiency_multiplier: float = 1.0
	return {"source_owner": "PortGame.source_consume_liquid_filter_liquid_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java", "method": "public float liquidEfficiencyMultiplier(Liquid liquid){", "efficiency_multiplier": efficiency_multiplier, "return_expr": "return 1f;"}

func java_constructor_ConsumeLiquidFilter_0(_args: Array = []) -> Variant:
	var filter_handle: Variant = _args[0] if _args.size() > 0 else null
	var amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var amount_after: float = amount
	var filter_after: Variant = filter_handle
	return {"source_owner": "PortGame.source_consume_liquid_filter_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java", "constructor": "public ConsumeLiquidFilter(Boolf<Liquid> liquid, float amount){", "filter_field": "public Boolf<Liquid> filter = l -> false;", "super_call_expr": "super(amount);", "base_constructor_expr": "public ConsumeLiquidBase(float amount){", "amount_assignment_expr": "this.amount = amount;", "filter_assignment_expr": "this.filter = liquid;", "amount_field": "public float amount;", "filter_handle": filter_handle, "amount": amount, "amount_after": amount_after, "filter_after": filter_after}

func java_constructor_ConsumeLiquidFilter_1(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_consume_liquid_filter_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java", "constructor": "public ConsumeLiquidFilter(){", "filter_field": "public Boolf<Liquid> filter = l -> false;", "empty_constructor_body": "public ConsumeLiquidFilter(){\n    }", "no_op": true}
