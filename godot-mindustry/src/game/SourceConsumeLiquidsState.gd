extends RefCounted
class_name SourceConsumeLiquidsState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_CONSUME_LIQUIDS_EMPTY_STACKS := []

static func constructor_state(liquid_stacks: Array) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_CONSTRUCTOR_STATE, "liquids_after": liquid_stacks.duplicate(true)}

static func default_constructor_state(_empty_stacks: Array) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DEFAULT_CONSTRUCTOR_STATE, "liquids_after": _empty_stacks.duplicate(true)}

static func apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_ids: Array) -> Dictionary:
	var liquid_filter_after := liquid_filter_before.duplicate(true)
	for liquid_id in liquid_ids:
		liquid_filter_after[int(liquid_id)] = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_APPLY_STATE, "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": true, "liquid_filter_before": liquid_filter_before, "liquid_ids": liquid_ids, "liquid_filter_after": liquid_filter_after}

static func build_state(liquid_ids: Array, liquid_amounts: Array) -> Dictionary:
	var req_images: Array = []
	var row_calls: Array = []
	var icon_size: String = "Vars.iconMed"
	var pad_right: float = 8.0
	for index in range(liquid_ids.size()):
		var amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)
		req_images.append({"liquid_id": liquid_ids[index], "amount": amount, "valid": amount > 0.0, "icon": "stack.liquid.uiIcon", "size": icon_size, "pad_right": pad_right})
		if (index + 1) % 4 == 0:
			row_calls.append(index + 1)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_BUILD_STATE,
		"liquid_ids": liquid_ids.duplicate(true),
		"liquid_amounts": liquid_amounts.duplicate(true),
		"req_images": req_images,
		"row_calls": row_calls,
		"table_left": true,
	}

static func update_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var remove_calls: Array = []
	for index in range(liquid_ids.size()):
		var amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)
		var remove_amount: float = amount * build_edelta * multiplier_get_build
		remove_calls.append({"liquid_id": liquid_ids[index], "amount": amount, "remove_amount": remove_amount})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_UPDATE_STATE,
		"liquid_ids": liquid_ids.duplicate(true),
		"liquid_stack_amounts": liquid_stack_amounts.duplicate(true),
		"build_edelta": build_edelta,
		"multiplier_get_build": multiplier_get_build,
		"remove_calls": remove_calls,
	}

static func efficiency_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	var ed: float = build_edelta * build_efficiency_scale
	if ed <= source_consumer_defaults.CONSUME_EFFICIENCY_EPSILON:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_EFFICIENCY_STATE,
			"liquid_ids": liquid_ids.duplicate(true),
			"liquid_stack_amounts": liquid_stack_amounts.duplicate(true),
			"liquid_amounts": liquid_amounts.duplicate(true),
			"build_edelta": build_edelta,
			"build_efficiency_scale": build_efficiency_scale,
			"multiplier_get_build": multiplier_get_build,
			"ed": ed,
			"per_stack_efficiencies": [],
			"efficiency": 0.0,
		}
	var min_efficiency: float = 1.0
	var per_stack_efficiencies: Array = []
	for index in range(liquid_ids.size()):
		var stack_amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)
		var liquid_amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)
		var denominator: float = stack_amount * ed * multiplier_get_build
		var stack_efficiency: float = liquid_amount / denominator
		min_efficiency = min(stack_efficiency, min_efficiency)
		per_stack_efficiencies.append({"liquid_id": int(liquid_ids[index]), "liquid_amount": liquid_amount, "stack_amount": stack_amount, "denominator": denominator, "efficiency": stack_efficiency})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_EFFICIENCY_STATE,
		"liquid_ids": liquid_ids.duplicate(true),
		"liquid_stack_amounts": liquid_stack_amounts.duplicate(true),
		"liquid_amounts": liquid_amounts.duplicate(true),
		"build_edelta": build_edelta,
		"build_efficiency_scale": build_efficiency_scale,
		"multiplier_get_build": multiplier_get_build,
		"ed": ed,
		"per_stack_efficiencies": per_stack_efficiencies,
		"efficiency": min_efficiency,
	}

static func display_state(booster: bool, liquid_ids: Array, liquid_stack_amounts: Array) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var source_tick_rate: float = source_time_defaults.new(source_ssot_catalog).tick_rate()
	var display_liquids: Array = []
	for index in range(liquid_ids.size()):
		var liquid_id: int = int(liquid_ids[index])
		var stack_amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)
		var display_amount_per_second: float = stack_amount * source_tick_rate
		display_liquids.append({"liquid_id": liquid_id, "stack_amount": stack_amount, "display_amount_per_second": display_amount_per_second, "per_second": true, "display_expr": "displayLiquid(stack.liquid, stack.amount * (60f / timePeriod), perSecond)", "pad_right": 5.0})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.liquids(1f, true, liquids)", "time_period": 1.0, "per_second": true, "liquid_ids": liquid_ids, "liquid_stack_amounts": liquid_stack_amounts}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DISPLAY_STATE,
		"liquid_ids": liquid_ids.duplicate(true),
		"liquid_stack_amounts": liquid_stack_amounts.duplicate(true),
		"selected_stat": selected_stat,
		"stats_add_call": stats_add_call,
		"display_liquids": display_liquids,
	}

static func generated_constructor_bridge_state(liquid_stacks: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquids.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquids_0([liquid_stacks])
	var canonical = constructor_state(liquid_stacks)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_CONSTRUCTOR_STATE, "generated_owner": "consume_liquids.constructor", "result": result, "canonical": canonical, "matches": result.get("liquids_after", []) == canonical.get("liquids_after", [])}

static func generated_default_constructor_bridge_state(empty_stacks: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquids.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquids_1([])
	var canonical = default_constructor_state(empty_stacks)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": "consume_liquids.default_constructor", "result": result, "canonical": canonical, "matches": result.get("liquids_after", []) == canonical.get("liquids_after", [])}

static func generated_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_ids: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquids.gd")
	var instance = script.new()
	var result = instance.java_method_apply_0([block_has_liquids_before, liquid_filter_before, liquid_ids])
	var canonical = apply_state(block_has_liquids_before, liquid_filter_before, liquid_ids)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_APPLY_STATE, "generated_owner": "consume_liquids.apply", "result": result, "canonical": canonical, "matches": result.get("block_has_liquids_after", null) == canonical.get("block_has_liquids_after", null) and result.get("liquid_filter_after", []) == canonical.get("liquid_filter_after", [])}

static func generated_build_bridge_state(liquid_ids: Array, liquid_amounts: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquids.gd")
	var instance = script.new()
	var result = instance.java_method_build_1([liquid_ids, liquid_amounts])
	var canonical = build_state(liquid_ids, liquid_amounts)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_BUILD_STATE, "generated_owner": "consume_liquids.build", "result": result, "canonical": canonical, "matches": result.get("req_images", []) == canonical.get("req_images", []) and result.get("row_calls", []) == canonical.get("row_calls", []) and result.get("table_left", null) == canonical.get("table_left", null)}

static func generated_update_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquids.gd")
	var instance = script.new()
	var result = instance.java_method_update_2([liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build])
	var canonical = update_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_UPDATE_STATE, "generated_owner": "consume_liquids.update", "result": result, "canonical": canonical, "matches": result.get("remove_calls", []) == canonical.get("remove_calls", [])}

static func generated_efficiency_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquids.gd")
	var instance = script.new()
	var result = instance.java_method_efficiency_3([liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build])
	var canonical = efficiency_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_EFFICIENCY_STATE, "generated_owner": "consume_liquids.efficiency", "result": result, "canonical": canonical, "matches": result.get("efficiency", null) == canonical.get("efficiency", null) and result.get("per_stack_efficiencies", []) == canonical.get("per_stack_efficiencies", [])}

static func generated_display_bridge_state(booster: bool, liquid_ids: Array, liquid_stack_amounts: Array, source_tick_rate: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquids.gd")
	var instance = script.new()
	var result = instance.java_method_display_4([booster, liquid_ids, liquid_stack_amounts, source_tick_rate])
	var canonical = display_state(booster, liquid_ids, liquid_stack_amounts)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DISPLAY_STATE, "generated_owner": "consume_liquids.display", "result": result, "canonical": canonical, "matches": result.get("selected_stat", null) == canonical.get("selected_stat", null) and result.get("display_liquids", []) == canonical.get("display_liquids", []) and result.get("stats_add_call", {}) == canonical.get("stats_add_call", {})}
