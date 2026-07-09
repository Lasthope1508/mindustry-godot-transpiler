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
	var booster: bool = bool(_args[0] if _args.size() > 0 else false)
	var amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var filtered_liquid_ids: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var liquid_efficiency_values: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []
	var table_has_cells: bool = bool(_args[4] if _args.size() > 4 else false)
	var selected_stat: String = "booster" if booster else "input"
	var display_amount_per_second: float = amount * 60.0
	var display_rows: Array = []
	for index in filtered_liquid_ids.size():
		var liquid_id: int = int(filtered_liquid_ids[index])
		var efficiency: float = float(liquid_efficiency_values[index] if index < liquid_efficiency_values.size() else 0.0)
		var efficiency_percent: float = efficiency * 100.0
		display_rows.append({"liquid_id": liquid_id, "display_amount_per_second": display_amount_per_second, "efficiency": efficiency, "efficiency_percent": efficiency_percent})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.liquidEffMultiplier(l -> l.flammability, amount * 60f, filter)", "amount": amount, "display_amount_per_second": display_amount_per_second, "filtered_liquid_ids": filtered_liquid_ids}
	return {"source_owner": "PortGame.source_consume_liquid_flammable_display_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java", "method": "public void display(Stats stats){", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, StatValues.liquidEffMultiplier(l -> l.flammability, amount * 60f, filter));", "stats_add_call_expr": "stats.add", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "selected_stat": selected_stat, "liquid_eff_multiplier_expr": "StatValues.liquidEffMultiplier(l -> l.flammability, amount * 60f, filter)", "liquid_eff_multiplier_method": "public static StatValue liquidEffMultiplier(Floatf<Liquid> efficiency, float amount, Boolf<Liquid> filter){", "table_cells_grow_expr": "if(table.getCells().size > 0) table.getCells().peek().growX();", "table_grow_previous_cell": table_has_cells, "content_filter_expr": "for(Liquid liquid : content.liquids().select(l -> filter.get(l) && l.unlockedNow() && !l.isHidden())){", "display_liquid_expr": "b.add(displayLiquid(liquid, amount, true)).pad(10f).left().grow();", "efficiency_expr": "b.add(Core.bundle.format(\"stat.efficiency\", fixValue(efficiency.get(liquid) * 100f))).right().pad(10f).padRight(15f);", "booster": booster, "amount": amount, "display_amount_per_second": display_amount_per_second, "filtered_liquid_ids": filtered_liquid_ids, "liquid_efficiency_values": liquid_efficiency_values, "stats_add_call": stats_add_call, "display_rows": display_rows}

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

func java_constructor_ConsumeLiquidFlammable_2(_args: Array = []) -> Variant:
	var amount: float = 0.2
	var min_flammability: float = 0.2
	var amount_after: float = amount
	var min_flammability_after: float = min_flammability
	var filter_expr: String = "liquid -> liquid.flammability >= this.minFlammability"
	return {"source_owner": "PortGame.source_consume_liquid_flammable_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java", "constructor": "public ConsumeLiquidFlammable(){", "default_call_expr": "this(0.2f);", "amount_constructor_expr": "public ConsumeLiquidFlammable(float amount){", "amount_constructor_default_call_expr": "this(0.2f, amount);", "typed_constructor_expr": "public ConsumeLiquidFlammable(float minFlammability, float amount){", "amount_assignment_expr": "this.amount = amount;", "assignment_expr": "this.minFlammability = minFlammability;", "filter_assignment_expr": "this.filter = liquid -> liquid.flammability >= this.minFlammability;", "filter_expr": filter_expr, "default_amount": 0.2, "default_min_flammability": 0.2, "amount_after": amount_after, "min_flammability_after": min_flammability_after}
