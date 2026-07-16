# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemEfficiency.java
# Do not edit by hand.
extends RefCounted

const SourceTimeDefaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_TICK_RATE := SourceTimeDefaults.TICK_RATE

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemEfficiency"
const JAVA_EXTENDS := "ConsumeItemFilter"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "itemDurationMultipliers", "type": "ObjectFloatMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemEfficiency", "parameters": [{"name": "item", "type": "Boolf", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeItemEfficiency", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_display_0(_args: Array = []) -> Variant:
	var booster: bool = bool(_args[0] if _args.size() > 0 else false)
	var stats_time_period: float = float(_args[1] if _args.size() > 1 else -1.0)
	var filtered_item_ids: Array = (_args[2] as Array).duplicate() if _args.size() > 2 and _args[2] is Array else []
	var item_efficiency_multipliers: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []
	var item_duration_multipliers: Array = (_args[4] as Array).duplicate() if _args.size() > 4 and _args[4] is Array else []
	var table_has_cells: bool = bool(_args[5] if _args.size() > 5 else false)
	var source_tick_rate: float = float(_args[6] if _args.size() > 6 else SOURCE_TICK_RATE)
	var selected_stat: String = "booster" if booster else "input"
	var display_rows: Array = []
	for index in filtered_item_ids.size():
		var item_id: int = int(filtered_item_ids[index])
		var efficiency_multiplier: float = float(item_efficiency_multipliers[index] if index < item_efficiency_multipliers.size() else 1.0)
		var time_multiplier: float = float(item_duration_multipliers[index] if index < item_duration_multipliers.size() else 1.0)
		var time_value: float = 1.0 / (stats_time_period * time_multiplier / source_tick_rate)
		var efficiency_percent: float = efficiency_multiplier * 100.0
		display_rows.append({"item_id": item_id, "efficiency_multiplier": efficiency_multiplier, "efficiency_percent": efficiency_percent, "time_multiplier": time_multiplier, "time": time_value, "time_period": stats_time_period})
	return {"source_owner": "PortGame.source_consume_item_efficiency_display_state", "source": "core/src/mindustry/world/consumers/ConsumeItemEfficiency.java", "method": "public void display(Stats stats){", "item_duration_multipliers_field": "public @Nullable ObjectFloatMap<Item> itemDurationMultipliers;", "stats_add_expr": "stats.add(booster ? Stat.booster : Stat.input, StatValues.itemEffMultiplier(this::itemEfficiencyMultiplier, stats.timePeriod, filter, itemDurationMultipliers));", "stats_add_call": "stats.add", "selected_stat_expr": "booster ? Stat.booster : Stat.input", "selected_stat": selected_stat, "item_eff_multiplier_expr": "StatValues.itemEffMultiplier(this::itemEfficiencyMultiplier, stats.timePeriod, filter, itemDurationMultipliers)", "item_eff_multiplier_method": "public static StatValue itemEffMultiplier(Floatf<Item> efficiency, float timePeriod, Boolf<Item> filter, @Nullable ObjectFloatMap<Item> itemDurationMultipliers){", "table_cells_grow_expr": "if(table.getCells().size > 0) table.getCells().peek().growX();", "table_grow_previous_cell": table_has_cells, "content_filter_expr": "for(Item item : content.items().select(i -> filter.get(i) && i.unlockedNow() && !i.isHidden())){", "time_multiplier_expr": "float timeMultiplier = itemDurationMultipliers == null ? 1f : itemDurationMultipliers.get(item, 1f);", "time_expr": "float time = 1f / (timePeriod * timeMultiplier / 60f);", "efficiency_expr": "b.add(Core.bundle.format(\"stat.efficiency\", fixValue(efficiency.get(item) * 100f))).right().pad(10f).padRight(15f);", "booster": booster, "stats_time_period": stats_time_period, "filtered_item_ids": filtered_item_ids, "item_efficiency_multipliers": item_efficiency_multipliers, "item_duration_multipliers": item_duration_multipliers, "table_has_cells": table_has_cells, "display_rows": display_rows}

func java_constructor_ConsumeItemEfficiency_0(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var filter_after: Variant = item
	return {"source_owner": "PortGame.source_consume_item_efficiency_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemEfficiency.java", "constructor": "public ConsumeItemEfficiency(Boolf<Item> item){", "super_call_expr": "super(item);", "parent_constructor_expr": "public ConsumeItemFilter(Boolf<Item> item){", "filter_assignment_expr": "this.filter = item;", "filter_field": "public Boolf<Item> filter = i -> false;", "item": item, "filter_after": filter_after}

func java_constructor_ConsumeItemEfficiency_1(_args: Array = []) -> Variant:
	var filter_after: String = "i -> false"
	return {"source_owner": "PortGame.source_consume_item_efficiency_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemEfficiency.java", "constructor": "public ConsumeItemEfficiency(){", "parent_constructor_expr": "public ConsumeItemFilter(){", "filter_field": "public Boolf<Item> filter = i -> false;", "filter_after": filter_after}
