extends RefCounted
class_name SourceConsumeLiquidsDynamicState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")

static func constructor_state(liquids: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_CONSTRUCTOR_STATE,
		"liquids": liquids,
		"liquids_after": liquids,
	}

static func apply_state(block_has_liquids_before: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_APPLY_STATE,
		"block_has_liquids_before": block_has_liquids_before,
		"block_has_liquids_after": true,
	}

static func build_state(current_liquid_ids: Array, next_liquid_ids: Array) -> Dictionary:
	var liquid_ids_changed: bool = current_liquid_ids != next_liquid_ids
	var rebuild_calls: Array = [{"call": "rebuild(build, cont);", "phase": "initial", "liquid_ids": current_liquid_ids}]
	var current_liquid_ids_after_update: Array = current_liquid_ids.duplicate()
	if liquid_ids_changed:
		rebuild_calls.append({"call": "rebuild(build, cont);", "phase": "update", "liquid_ids": next_liquid_ids})
		current_liquid_ids_after_update = next_liquid_ids.duplicate()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_BUILD_STATE,
		"current_liquid_ids": current_liquid_ids.duplicate(true),
		"next_liquid_ids": next_liquid_ids.duplicate(true),
		"liquid_ids_changed": liquid_ids_changed,
		"rebuild_calls": rebuild_calls,
		"current_liquid_ids_after_update": current_liquid_ids_after_update,
	}

static func rebuild_state(liquid_ids: Array, liquid_amounts: Array, building_has_liquids: bool, source_ui_icon_med: float, source_ui_pad_right: float) -> Dictionary:
	var req_images: Array = []
	var row_calls: Array = []
	for index in range(liquid_ids.size()):
		var liquid_amount: float = float(liquid_amounts[index] if index < liquid_amounts.size() else 0.0)
		var valid: bool = building_has_liquids and liquid_amount > 0.0
		req_images.append({"liquid_id": int(liquid_ids[index]), "liquid_amount": liquid_amount, "valid": valid, "ui_icon_expr": "stack.liquid.uiIcon", "size": source_ui_icon_med, "pad_right": source_ui_pad_right})
		if (index + 1) % 4 == 0:
			row_calls.append({"call": "table.row();", "after_count": index + 1})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_REBUILD_STATE,
		"liquid_ids": liquid_ids.duplicate(true),
		"liquid_amounts": liquid_amounts.duplicate(true),
		"building_has_liquids": building_has_liquids,
		"req_images": req_images,
		"row_calls": row_calls,
		"cleared": true,
	}

static func update_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var remove_calls: Array = []
	for index in range(liquid_ids.size()):
		var stack_amount: float = float(liquid_stack_amounts[index] if index < liquid_stack_amounts.size() else 0.0)
		var remove_amount: float = stack_amount * build_edelta * multiplier_get_build
		remove_calls.append({"call": "build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);", "liquid_id": int(liquid_ids[index]), "stack_amount": stack_amount, "amount": remove_amount})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_UPDATE_STATE,
		"liquid_ids": liquid_ids.duplicate(true),
		"liquid_stack_amounts": liquid_stack_amounts.duplicate(true),
		"build_edelta": build_edelta,
		"multiplier_get_build": multiplier_get_build,
		"remove_calls": remove_calls,
	}

static func efficiency_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var ed: float = build_edelta
	if ed <= source_consumer_defaults.CONSUME_EFFICIENCY_EPSILON:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_STATE,
			"liquid_ids": liquid_ids.duplicate(true),
			"liquid_stack_amounts": liquid_stack_amounts.duplicate(true),
			"liquid_amounts": liquid_amounts.duplicate(true),
			"build_edelta": build_edelta,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_STATE,
		"liquid_ids": liquid_ids.duplicate(true),
		"liquid_stack_amounts": liquid_stack_amounts.duplicate(true),
		"liquid_amounts": liquid_amounts.duplicate(true),
		"build_edelta": build_edelta,
		"multiplier_get_build": multiplier_get_build,
		"ed": ed,
		"per_stack_efficiencies": per_stack_efficiencies,
		"efficiency": min_efficiency,
	}

static func generated_constructor_bridge_state(liquids: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidsDynamic.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquidsDynamic_0([liquids])
	var canonical = constructor_state(liquids)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_CONSTRUCTOR_STATE, "generated_owner": "consume_liquids_dynamic.constructor", "result": result, "canonical": canonical, "matches": result.get("liquids_after", null) == canonical.get("liquids_after", null)}

static func generated_apply_bridge_state(block_has_liquids_before: bool) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidsDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_apply_0([block_has_liquids_before])
	var canonical = apply_state(block_has_liquids_before)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_APPLY_STATE, "generated_owner": "consume_liquids_dynamic.apply", "result": result, "canonical": canonical, "matches": result.get("block_has_liquids_after", null) == canonical.get("block_has_liquids_after", null)}

static func generated_build_bridge_state(current_liquid_ids: Array, next_liquid_ids: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidsDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_build_1([current_liquid_ids, next_liquid_ids])
	var canonical = build_state(current_liquid_ids, next_liquid_ids)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_BUILD_STATE, "generated_owner": "consume_liquids_dynamic.build", "result": result, "canonical": canonical, "matches": result.get("rebuild_calls", []) == canonical.get("rebuild_calls", []) and result.get("current_liquid_ids_after_update", []) == canonical.get("current_liquid_ids_after_update", [])}

static func generated_rebuild_bridge_state(liquid_ids: Array, liquid_amounts: Array, building_has_liquids: bool, source_ui_icon_med: float, source_ui_pad_right: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidsDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_rebuild_2([liquid_ids, liquid_amounts, building_has_liquids, source_ui_icon_med, source_ui_pad_right])
	var canonical = rebuild_state(liquid_ids, liquid_amounts, building_has_liquids, source_ui_icon_med, source_ui_pad_right)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_REBUILD_STATE, "generated_owner": "consume_liquids_dynamic.rebuild", "result": result, "canonical": canonical, "matches": result.get("req_images", []) == canonical.get("req_images", []) and result.get("row_calls", []) == canonical.get("row_calls", []) and result.get("cleared", false) == canonical.get("cleared", false)}

static func generated_update_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidsDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_update_3([liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build])
	var canonical = update_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_UPDATE_STATE, "generated_owner": "consume_liquids_dynamic.update", "result": result, "canonical": canonical, "matches": result.get("remove_calls", []) == canonical.get("remove_calls", [])}

static func generated_efficiency_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidsDynamic.gd")
	var instance = script.new()
	var result = instance.java_method_efficiency_4([liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, multiplier_get_build])
	var canonical = efficiency_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, multiplier_get_build)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUIDS_DYNAMIC_EFFICIENCY_STATE, "generated_owner": "consume_liquids_dynamic.efficiency", "result": result, "canonical": canonical, "matches": result.get("efficiency", null) == canonical.get("efficiency", null) and result.get("per_stack_efficiencies", []) == canonical.get("per_stack_efficiencies", [])}
