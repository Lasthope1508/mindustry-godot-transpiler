extends RefCounted
class_name SourceConsumeItemEfficiencyState

const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func constructor_state(item: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_STATE, "filter_after": item}

static func default_constructor_state(default_filter_expr: String) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_STATE, "filter_after": default_filter_expr}

static func display_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool, source_tick_rate: float) -> Dictionary:
	var display_rows: Array = []
	for index in range(filtered_item_ids.size()):
		display_rows.append({
			"item": filtered_item_ids[index],
			"efficiency_multiplier": item_efficiency_multipliers[index] if index < item_efficiency_multipliers.size() else 1.0,
			"duration_multiplier": item_duration_multipliers[index] if index < item_duration_multipliers.size() else 1.0,
		})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_STATE,
		"selected_stat": "booster" if booster else "input",
		"display_rows": display_rows,
		"table_grow_previous_cell": table_has_cells,
		"stats_time_period": stats_time_period,
		"source_tick_rate": source_tick_rate,
	}

static func generated_constructor_bridge_state(item: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemEfficiency.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemEfficiency_0([item])
	var canonical = constructor_state(item)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_CONSTRUCTOR_STATE, "generated_owner": "consume_item_efficiency.constructor", "result": result, "canonical": canonical, "matches": result.get("filter_after", null) == canonical.get("filter_after", null)}

static func generated_default_constructor_bridge_state(default_filter_expr: String) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemEfficiency.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemEfficiency_1([])
	var canonical = default_constructor_state(default_filter_expr)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": "consume_item_efficiency.default_constructor", "result": result, "canonical": canonical, "matches": result.get("filter_after", null) == canonical.get("filter_after", null)}

static func generated_display_bridge_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool, source_tick_rate: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemEfficiency.gd")
	var instance = script.new()
	var result = instance.java_method_display_0([booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, source_tick_rate])
	var canonical = display_state(booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, source_tick_rate)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EFFICIENCY_DISPLAY_STATE, "generated_owner": "consume_item_efficiency.display", "result": result, "canonical": canonical, "matches": result.get("selected_stat", null) == canonical.get("selected_stat", null) and result.get("display_rows", []) == canonical.get("display_rows", []) and result.get("table_grow_previous_cell", null) == canonical.get("table_grow_previous_cell", null)}
