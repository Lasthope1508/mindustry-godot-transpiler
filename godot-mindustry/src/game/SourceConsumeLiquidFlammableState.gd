extends RefCounted
class_name SourceConsumeLiquidFlammableState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")

static func display_state(booster: bool, amount: float, filtered_liquid_ids: Array, liquid_efficiency_values: Array, table_has_cells: bool, source_tick_rate: float) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_amount_per_second: float = amount * source_tick_rate
	var display_rows: Array = []
	for index in range(filtered_liquid_ids.size()):
		var liquid_id: int = int(filtered_liquid_ids[index])
		var efficiency: float = float(liquid_efficiency_values[index] if index < liquid_efficiency_values.size() else 0.0)
		var efficiency_percent: float = efficiency * source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_EFFICIENCY_PERCENT_SCALE
		display_rows.append({"liquid_id": liquid_id, "display_amount_per_second": display_amount_per_second, "efficiency": efficiency, "efficiency_percent": efficiency_percent})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.liquidEffMultiplier(l -> l.flammability, amount * 60f, filter)", "amount": amount, "display_amount_per_second": display_amount_per_second, "filtered_liquid_ids": filtered_liquid_ids}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_DISPLAY_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java",
		"method": "public void display(Stats stats){",
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
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java",
		"method": "public float liquidEfficiencyMultiplier(Liquid liquid){",
		"liquid_flammability": liquid_flammability,
		"efficiency_multiplier": liquid_flammability,
	}

static func constructor_state(min_flammability: float, amount: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_CONSTRUCTOR_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java",
		"constructor": "public ConsumeLiquidFlammable(float minFlammability, float amount){",
		"min_flammability_field": "public float minFlammability;",
		"amount_field": "public float amount;",
		"amount_assignment_expr": "this.amount = amount;",
		"assignment_expr": "this.minFlammability = minFlammability;",
		"filter_assignment_expr": "this.filter = liquid -> liquid.flammability >= this.minFlammability;",
		"filter_expr": "liquid -> liquid.flammability >= this.minFlammability",
		"liquid_flammability_field": "public float flammability;",
		"min_flammability": min_flammability,
		"amount": amount,
		"amount_after": amount,
		"min_flammability_after": min_flammability,
	}

static func amount_constructor_state(amount: float, default_min_flammability: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_CONSTRUCTOR_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java",
		"constructor": "public ConsumeLiquidFlammable(float amount){",
		"default_call_expr": "this(0.2f, amount);",
		"typed_constructor_expr": "public ConsumeLiquidFlammable(float minFlammability, float amount){",
		"amount_assignment_expr": "this.amount = amount;",
		"assignment_expr": "this.minFlammability = minFlammability;",
		"filter_assignment_expr": "this.filter = liquid -> liquid.flammability >= this.minFlammability;",
		"filter_expr": "liquid -> liquid.flammability >= this.minFlammability",
		"default_min_flammability": default_min_flammability,
		"amount": amount,
		"amount_after": amount,
		"min_flammability_after": default_min_flammability,
	}

static func default_constructor_state(default_amount: float, default_min_flammability: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_DEFAULT_CONSTRUCTOR_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java",
		"constructor": "public ConsumeLiquidFlammable(){",
		"default_call_expr": "this(0.2f);",
		"amount_constructor_expr": "public ConsumeLiquidFlammable(float amount){",
		"amount_constructor_default_call_expr": "this(0.2f, amount);",
		"typed_constructor_expr": "public ConsumeLiquidFlammable(float minFlammability, float amount){",
		"amount_assignment_expr": "this.amount = amount;",
		"assignment_expr": "this.minFlammability = minFlammability;",
		"filter_assignment_expr": "this.filter = liquid -> liquid.flammability >= this.minFlammability;",
		"filter_expr": "liquid -> liquid.flammability >= this.minFlammability",
		"default_amount": default_amount,
		"default_min_flammability": default_min_flammability,
		"amount_after": default_amount,
		"min_flammability_after": default_min_flammability,
	}

static func generated_display_bridge_state(booster: bool, amount: float, filtered_liquid_ids: Array, liquid_efficiency_values: Array, table_has_cells: bool, source_tick_rate: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFlammable.gd")
	var instance = script.new()
	var result = instance.java_method_display_0([booster, amount, filtered_liquid_ids, liquid_efficiency_values, table_has_cells, source_tick_rate])
	var canonical = display_state(booster, amount, filtered_liquid_ids, liquid_efficiency_values, table_has_cells, source_tick_rate)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_DISPLAY_STATE, "generated_owner": "consume_liquid_flammable.display", "result": result, "canonical": canonical, "matches": result.get("selected_stat", null) == canonical.get("selected_stat", null) and result.get("display_amount_per_second", null) == canonical.get("display_amount_per_second", null) and result.get("display_rows", []) == canonical.get("display_rows", []) and result.get("stats_add_call", {}) == canonical.get("stats_add_call", {})}

static func generated_liquid_efficiency_multiplier_bridge_state(liquid_flammability: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFlammable.gd")
	var instance = script.new()
	var result = instance.java_method_liquidEfficiencyMultiplier_1([liquid_flammability])
	var canonical = liquid_efficiency_multiplier_state(liquid_flammability)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_LIQUID_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_liquid_flammable.liquidEfficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null)}

static func generated_constructor_bridge_state(min_flammability: float, amount: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFlammable.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquidFlammable_0([min_flammability, amount])
	var canonical = constructor_state(min_flammability, amount)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_CONSTRUCTOR_STATE, "generated_owner": "consume_liquid_flammable.constructor", "result": result, "canonical": canonical, "matches": result.get("min_flammability_after", null) == canonical.get("min_flammability_after", null) and result.get("amount_after", null) == canonical.get("amount_after", null) and result.get("filter_expr", "") == canonical.get("filter_expr", "")}

static func generated_amount_constructor_bridge_state(amount: float, default_min_flammability: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFlammable.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquidFlammable_1([amount])
	var canonical = amount_constructor_state(amount, default_min_flammability)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_AMOUNT_CONSTRUCTOR_STATE, "generated_owner": "consume_liquid_flammable.amount_constructor", "result": result, "canonical": canonical, "matches": result.get("min_flammability_after", null) == canonical.get("min_flammability_after", null) and result.get("amount_after", null) == canonical.get("amount_after", null) and result.get("filter_expr", "") == canonical.get("filter_expr", "")}

static func generated_default_constructor_bridge_state(default_amount: float, default_min_flammability: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFlammable.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquidFlammable_2([])
	var canonical = default_constructor_state(default_amount, default_min_flammability)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FLAMMABLE_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": "consume_liquid_flammable.default_constructor", "result": result, "canonical": canonical, "matches": result.get("min_flammability_after", null) == canonical.get("min_flammability_after", null) and result.get("amount_after", null) == canonical.get("amount_after", null) and result.get("filter_expr", "") == canonical.get("filter_expr", "")}
