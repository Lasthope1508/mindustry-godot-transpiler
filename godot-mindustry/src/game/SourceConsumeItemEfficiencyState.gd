extends RefCounted
class_name SourceConsumeItemEfficiencyState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_SOURCE
const DISPLAY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_METHOD
const ITEM_DURATION_MULTIPLIERS_FIELD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_ITEM_DURATION_MULTIPLIERS_FIELD
const STATS_ADD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_STATS_ADD_EXPR
const STATS_ADD_CALL := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_STATS_ADD_CALL
const SELECTED_STAT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_SELECTED_STAT_EXPR
const ITEM_EFF_MULTIPLIER_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_ITEM_EFF_MULTIPLIER_EXPR
const ITEM_EFF_MULTIPLIER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_ITEM_EFF_MULTIPLIER_METHOD
const TABLE_CELLS_GROW_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_TABLE_CELLS_GROW_EXPR
const CONTENT_FILTER_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_CONTENT_FILTER_EXPR
const TIME_MULTIPLIER_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_TIME_MULTIPLIER_EXPR
const TIME_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_TIME_EXPR
const EFFICIENCY_EXPR := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_EFFICIENCY_EXPR

static func constructor_state(item: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_STATE, "filter_after": item}

static func default_constructor_state(default_filter_expr: String) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_STATE, "filter_after": default_filter_expr}

static func display_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool, source_tick_rate: float) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_rows: Array = []
	for index in range(filtered_item_ids.size()):
		var item_id: int = int(filtered_item_ids[index])
		var efficiency_multiplier: float = float(item_efficiency_multipliers[index] if index < item_efficiency_multipliers.size() else 1.0)
		var time_multiplier: float = float(item_duration_multipliers[index] if index < item_duration_multipliers.size() else 1.0)
		var time_value: float = 1.0 / (stats_time_period * time_multiplier / source_tick_rate)
		var efficiency_percent: float = efficiency_multiplier * 100.0
		display_rows.append({
			"item_id": item_id,
			"efficiency_multiplier": efficiency_multiplier,
			"efficiency_percent": efficiency_percent,
			"time_multiplier": time_multiplier,
			"time": time_value,
			"time_period": stats_time_period,
		})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_STATE,
		"source": SOURCE,
		"method": DISPLAY_METHOD,
		"item_duration_multipliers_field": ITEM_DURATION_MULTIPLIERS_FIELD,
		"stats_add_expr": STATS_ADD_EXPR,
		"stats_add_call": STATS_ADD_CALL,
		"selected_stat_expr": SELECTED_STAT_EXPR,
		"selected_stat": selected_stat,
		"item_eff_multiplier_expr": ITEM_EFF_MULTIPLIER_EXPR,
		"item_eff_multiplier_method": ITEM_EFF_MULTIPLIER_METHOD,
		"table_cells_grow_expr": TABLE_CELLS_GROW_EXPR,
		"table_grow_previous_cell": table_has_cells,
		"content_filter_expr": CONTENT_FILTER_EXPR,
		"time_multiplier_expr": TIME_MULTIPLIER_EXPR,
		"time_expr": TIME_EXPR,
		"efficiency_expr": EFFICIENCY_EXPR,
		"booster": booster,
		"stats_time_period": stats_time_period,
		"filtered_item_ids": filtered_item_ids.duplicate(true),
		"item_efficiency_multipliers": item_efficiency_multipliers.duplicate(true),
		"item_duration_multipliers": item_duration_multipliers.duplicate(true),
		"table_has_cells": table_has_cells,
		"display_rows": display_rows,
	}
