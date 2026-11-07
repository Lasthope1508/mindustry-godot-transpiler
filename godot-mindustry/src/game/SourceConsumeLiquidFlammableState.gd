extends RefCounted
class_name SourceConsumeLiquidFlammableState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE_CONSUME_LIQUID_FLAMMABLE_SOURCE := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_SOURCE
const SOURCE_CONSUME_LIQUID_FLAMMABLE_DISPLAY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_DISPLAY_METHOD
const SOURCE_CONSUME_LIQUID_FLAMMABLE_DISPLAY_STAT_VALUES_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_DISPLAY_STAT_VALUES_EXPR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_LIQUID_EFFICIENCY_MULTIPLIER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_LIQUID_EFFICIENCY_MULTIPLIER_METHOD
const SOURCE_CONSUME_LIQUID_FLAMMABLE_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_CONSTRUCTOR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_MIN_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_MIN_FIELD_EXPR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_FIELD_EXPR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_ASSIGNMENT_EXPR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_ASSIGNMENT_EXPR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_ASSIGNMENT_EXPR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_EXPR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_LIQUID_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_LIQUID_FIELD_EXPR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_CONSTRUCTOR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_DEFAULT_CALL_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_DEFAULT_CALL_EXPR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_DEFAULT_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_DEFAULT_CONSTRUCTOR
const SOURCE_CONSUME_LIQUID_FLAMMABLE_DEFAULT_CALL_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_DEFAULT_CALL_EXPR

static func display_state(booster: bool, amount: float, filtered_liquid_ids: Array, liquid_efficiency_values: Array, table_has_cells: bool, source_tick_rate: float) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_amount_per_second: float = amount * source_tick_rate
	var display_rows: Array = []
	for index in range(filtered_liquid_ids.size()):
		var liquid_id: int = int(filtered_liquid_ids[index])
		var efficiency: float = float(liquid_efficiency_values[index] if index < liquid_efficiency_values.size() else 0.0)
		var efficiency_percent: float = efficiency * source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_EFFICIENCY_PERCENT_SCALE
		display_rows.append({"liquid_id": liquid_id, "display_amount_per_second": display_amount_per_second, "efficiency": efficiency, "efficiency_percent": efficiency_percent})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_DISPLAY_STAT_VALUES_EXPR, "amount": amount, "display_amount_per_second": display_amount_per_second, "filtered_liquid_ids": filtered_liquid_ids}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_DISPLAY_STATE,
		"source": SOURCE_CONSUME_LIQUID_FLAMMABLE_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FLAMMABLE_DISPLAY_METHOD,
		"booster": booster,
		"amount": amount,
		"filtered_liquid_ids": filtered_liquid_ids,
		"liquid_efficiency_values": liquid_efficiency_values,
		"table_grow_previous_cell": table_has_cells,
		"selected_stat": selected_stat,
		"display_amount_per_second": display_amount_per_second,
		"display_rows": display_rows,
		"stats_add_call": stats_add_call,
	}

static func liquid_efficiency_multiplier_state(liquid_flammability: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_LIQUID_EFFICIENCY_MULTIPLIER_STATE,
		"source": SOURCE_CONSUME_LIQUID_FLAMMABLE_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_FLAMMABLE_LIQUID_EFFICIENCY_MULTIPLIER_METHOD,
		"liquid_flammability": liquid_flammability,
		"efficiency_multiplier": liquid_flammability,
	}

static func constructor_state(min_flammability: float, amount: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_CONSTRUCTOR_STATE,
		"source": SOURCE_CONSUME_LIQUID_FLAMMABLE_SOURCE,
		"constructor": SOURCE_CONSUME_LIQUID_FLAMMABLE_CONSTRUCTOR,
		"min_flammability_field": SOURCE_CONSUME_LIQUID_FLAMMABLE_MIN_FIELD_EXPR,
		"amount_field": SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_FIELD_EXPR,
		"amount_assignment_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_ASSIGNMENT_EXPR,
		"assignment_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_ASSIGNMENT_EXPR,
		"filter_assignment_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_ASSIGNMENT_EXPR,
		"filter_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_EXPR,
		"liquid_flammability_field": SOURCE_CONSUME_LIQUID_FLAMMABLE_LIQUID_FIELD_EXPR,
		"min_flammability": min_flammability,
		"amount": amount,
		"amount_after": amount,
		"min_flammability_after": min_flammability,
	}

static func amount_constructor_state(amount: float, default_min_flammability: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_CONSTRUCTOR_STATE,
		"source": SOURCE_CONSUME_LIQUID_FLAMMABLE_SOURCE,
		"constructor": SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_CONSTRUCTOR,
		"default_call_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_DEFAULT_CALL_EXPR,
		"typed_constructor_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_CONSTRUCTOR,
		"amount_assignment_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_ASSIGNMENT_EXPR,
		"assignment_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_ASSIGNMENT_EXPR,
		"filter_assignment_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_ASSIGNMENT_EXPR,
		"filter_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_EXPR,
		"default_min_flammability": default_min_flammability,
		"amount": amount,
		"amount_after": amount,
		"min_flammability_after": default_min_flammability,
	}

static func default_constructor_state(default_amount: float, default_min_flammability: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_DEFAULT_CONSTRUCTOR_STATE,
		"source": SOURCE_CONSUME_LIQUID_FLAMMABLE_SOURCE,
		"constructor": SOURCE_CONSUME_LIQUID_FLAMMABLE_DEFAULT_CONSTRUCTOR,
		"default_call_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_DEFAULT_CALL_EXPR,
		"amount_constructor_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_CONSTRUCTOR,
		"amount_constructor_default_call_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_DEFAULT_CALL_EXPR,
		"typed_constructor_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_CONSTRUCTOR,
		"amount_assignment_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_ASSIGNMENT_EXPR,
		"assignment_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_ASSIGNMENT_EXPR,
		"filter_assignment_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_ASSIGNMENT_EXPR,
		"filter_expr": SOURCE_CONSUME_LIQUID_FLAMMABLE_FILTER_EXPR,
		"default_amount": default_amount,
		"default_min_flammability": default_min_flammability,
		"amount_after": default_amount,
		"min_flammability_after": default_min_flammability,
	}
