extends RefCounted
class_name SourceConsumeLiquidFilterState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func constructor_state(filter_handle: Variant, amount: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_CONSTRUCTOR_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"constructor": "public ConsumeLiquidFilter(Boolf<Liquid> liquid, float amount){",
		"filter_field": "public Boolf<Liquid> filter = l -> false;",
		"filter_handle": filter_handle,
		"amount": amount,
		"amount_after": amount,
		"filter_after": filter_handle,
	}

static func default_constructor_state(default_filter_expr: String) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_DEFAULT_CONSTRUCTOR_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"constructor": "public ConsumeLiquidFilter(){",
		"filter_field": "public Boolf<Liquid> filter = l -> false;",
		"empty_constructor_body": "public ConsumeLiquidFilter(){\n    }",
		"no_op": true,
		"filter_after": default_filter_expr,
	}

static func apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, filtered_liquid_ids: Array) -> Dictionary:
	var liquid_filter_after := liquid_filter_before.duplicate()
	for liquid_id in filtered_liquid_ids:
		var index := int(liquid_id)
		if index >= 0 and index < liquid_filter_after.size():
			liquid_filter_after[index] = true
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_APPLY_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"method": "public void apply(Block block){",
		"block_has_liquids_before": block_has_liquids_before,
		"block_has_liquids_after": true,
		"liquid_filter_before": liquid_filter_before,
		"filtered_liquid_ids": filtered_liquid_ids,
		"liquid_filter_after": liquid_filter_after,
	}

static func build_state(filtered_liquid_ids: Array, consumed_liquid: Variant, source_ui_icon_med: float) -> Dictionary:
	var req_images: Array = []
	for liquid_id in filtered_liquid_ids:
		var valid: bool = liquid_id == consumed_liquid
		req_images.append({"liquid_id": liquid_id, "valid": valid, "image_expr": "liquid.uiIcon", "valid_expr": "getConsumed(build) == liquid"})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_BUILD_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"method": "public void build(Building build, Table table){",
		"filtered_liquid_ids": filtered_liquid_ids,
		"consumed_liquid": consumed_liquid,
		"multi_req_image_created": true,
		"req_images": req_images,
		"req_image_count": req_images.size(),
		"table_add_image": true,
		"table_image_size": source_ui_icon_med,
	}

static func get_consumed_state(current_liquid: Variant, current_filter_get_liquid: bool, current_amount: float, content_liquids: Array, filter_get_liquid_flags: Array, build_liquid_amounts: Array) -> Dictionary:
	var current_branch_matched: bool = current_filter_get_liquid and current_amount > 0.0
	var consumed_liquid: Variant = current_liquid if current_branch_matched else null
	var consumed_index: int = -1
	var checked_liquids: Array = []
	if not current_branch_matched:
		for i in range(content_liquids.size()):
			var liquid: Variant = content_liquids[i]
			var filter_get_liquid: bool = bool(filter_get_liquid_flags[i]) if i < filter_get_liquid_flags.size() else false
			var build_liquids_get: float = float(build_liquid_amounts[i]) if i < build_liquid_amounts.size() else 0.0
			var liquid_matches: bool = filter_get_liquid and build_liquids_get > 0.0
			checked_liquids.append({"index": i, "liquid": liquid, "filter_get_liquid": filter_get_liquid, "build_liquids_get": build_liquids_get, "liquid_matches": liquid_matches})
			if consumed_liquid == null and liquid_matches:
				consumed_liquid = liquid
				consumed_index = i
				break
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_GET_CONSUMED_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"method": "public @Nullable Liquid getConsumed(Building build){",
		"current_liquid": current_liquid,
		"current_filter_get_liquid": current_filter_get_liquid,
		"current_amount": current_amount,
		"content_liquids": content_liquids,
		"filter_get_liquid_flags": filter_get_liquid_flags,
		"build_liquid_amounts": build_liquid_amounts,
		"current_branch_matched": current_branch_matched,
		"checked_liquids": checked_liquids,
		"consumed_liquid": consumed_liquid,
		"consumed_index": consumed_index,
	}

static func update_state(consumed_liquid: Variant, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var remove_called: bool = consumed_liquid != null
	var remove_amount: float = amount * build_edelta * multiplier_get_build if remove_called else 0.0
	var remove_call: Dictionary = {"call": "build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));", "liquid": consumed_liquid, "amount": remove_amount} if remove_called else {}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_UPDATE_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"method": "public void update(Building build){",
		"consumed_liquid": consumed_liquid,
		"amount": amount,
		"build_edelta": build_edelta,
		"multiplier_get_build": multiplier_get_build,
		"remove_called": remove_called,
		"remove_amount": remove_amount,
		"remove_call": remove_call,
	}

static func efficiency_state(consumed_liquid: Variant, build_liquids_get: float, amount: float, build_edelta: float, multiplier_get_build: float, source_consume_efficiency_epsilon: float) -> Dictionary:
	var ed: float = build_edelta
	var ed_guard: bool = ed <= source_consume_efficiency_epsilon
	var has_consumed_liquid: bool = consumed_liquid != null
	var required_liquid_amount: float = amount * ed * multiplier_get_build
	var raw_efficiency: float = build_liquids_get / required_liquid_amount if has_consumed_liquid and not ed_guard else 0.0
	var efficiency: float = 0.0 if ed_guard else (min(raw_efficiency, 1.0) if has_consumed_liquid else 0.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"method": "public float efficiency(Building build){",
		"consumed_liquid": consumed_liquid,
		"build_liquids_get": build_liquids_get,
		"amount": amount,
		"build_edelta": build_edelta,
		"multiplier_get_build": multiplier_get_build,
		"ed": ed,
		"ed_guard": ed_guard,
		"has_consumed_liquid": has_consumed_liquid,
		"required_liquid_amount": required_liquid_amount,
		"raw_efficiency": raw_efficiency,
		"efficiency": efficiency,
	}

static func efficiency_multiplier_state(consumed_liquid: Variant, liquid_efficiency_multiplier: float) -> Dictionary:
	var has_consumed_liquid: bool = consumed_liquid != null
	var efficiency_multiplier: float = liquid_efficiency_multiplier if has_consumed_liquid else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_EFFICIENCY_MULTIPLIER_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"method": "public float efficiencyMultiplier(Building build){",
		"consumed_liquid": consumed_liquid,
		"liquid_efficiency_multiplier": liquid_efficiency_multiplier,
		"has_consumed_liquid": has_consumed_liquid,
		"efficiency_multiplier": efficiency_multiplier,
	}

static func liquid_efficiency_multiplier_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_LIQUID_EFFICIENCY_MULTIPLIER_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"method": "public float liquidEfficiencyMultiplier(Liquid liquid){",
		"efficiency_multiplier": 1.0,
	}

static func display_state(booster: bool, amount: float, filtered_liquid_ids: Array, source_tick_rate: float) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_amount_per_second: float = amount * source_tick_rate
	var display_liquids: Array = []
	for index in range(filtered_liquid_ids.size()):
		var liquid_id: int = int(filtered_liquid_ids[index])
		var has_separator_after: bool = index != filtered_liquid_ids.size() - 1
		display_liquids.append({"liquid_id": liquid_id, "display_amount_per_second": display_amount_per_second, "per_second": true, "has_separator_after": has_separator_after})
	var stats_add_call: Dictionary = {"call": "stats.add", "stat": selected_stat, "stat_value_expr": "StatValues.liquids(filter, amount * 60f, true)", "amount": amount, "display_amount_per_second": display_amount_per_second, "filtered_liquid_ids": filtered_liquid_ids}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_DISPLAY_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"method": "public void display(Stats stats){",
		"booster": booster,
		"amount": amount,
		"selected_stat": selected_stat,
		"display_amount_per_second": display_amount_per_second,
		"per_second": true,
		"filtered_liquid_ids": filtered_liquid_ids,
		"stats_add_call": stats_add_call,
		"display_liquids": display_liquids,
	}

static func consumes_state(filter_get_liquid: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_FILTER_CONSUMES_STATE,
		"source": "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java",
		"method": "public boolean consumes(Liquid liquid){",
		"filter_get_liquid": filter_get_liquid,
		"consumes_liquid": filter_get_liquid,
	}

static func generated_constructor_bridge_state(filter_handle: Variant, amount: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquidFilter_0([filter_handle, amount])
	var canonical = constructor_state(filter_handle, amount)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_CONSTRUCTOR_STATE, "generated_owner": "consume_liquid_filter.constructor", "result": result, "canonical": canonical, "matches": result.get("amount_after", null) == canonical.get("amount_after", null) and result.get("filter_after", null) == canonical.get("filter_after", null)}

static func generated_default_constructor_bridge_state(default_filter_expr: String) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquidFilter_1([])
	var canonical = default_constructor_state(default_filter_expr)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": "consume_liquid_filter.default_constructor", "result": result, "canonical": canonical, "matches": result.get("no_op", null) == canonical.get("no_op", null) and result.get("constructor", "") == canonical.get("constructor", "") and result.get("filter_after", null) == canonical.get("filter_after", null)}

static func generated_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, filtered_liquid_ids: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_method_apply_0([block_has_liquids_before, liquid_filter_before, filtered_liquid_ids])
	var canonical = apply_state(block_has_liquids_before, liquid_filter_before, filtered_liquid_ids)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_APPLY_STATE, "generated_owner": "consume_liquid_filter.apply", "result": result, "canonical": canonical, "matches": result.get("block_has_liquids_after", null) == canonical.get("block_has_liquids_after", null) and result.get("liquid_filter_after", []) == canonical.get("liquid_filter_after", [])}

static func generated_build_bridge_state(filtered_liquid_ids: Array, consumed_liquid: Variant, source_ui_icon_med: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_method_build_1([filtered_liquid_ids, consumed_liquid])
	var canonical = build_state(filtered_liquid_ids, consumed_liquid, source_ui_icon_med)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_BUILD_STATE, "generated_owner": "consume_liquid_filter.build", "result": result, "canonical": canonical, "matches": result.get("req_images", []) == canonical.get("req_images", []) and result.get("table_image_size", null) == canonical.get("table_image_size", null)}

static func generated_get_consumed_bridge_state(current_liquid: Variant, current_filter_get_liquid: bool, current_amount: float, content_liquids: Array, filter_get_liquid_flags: Array, build_liquid_amounts: Array) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_method_getConsumed_5([current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts])
	var canonical = get_consumed_state(current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_GET_CONSUMED_STATE, "generated_owner": "consume_liquid_filter.getConsumed", "result": result, "canonical": canonical, "matches": result.get("consumed_liquid", null) == canonical.get("consumed_liquid", null) and result.get("consumed_index", null) == canonical.get("consumed_index", null) and result.get("current_branch_matched", null) == canonical.get("current_branch_matched", null) and result.get("checked_liquids", []) == canonical.get("checked_liquids", [])}

static func generated_update_bridge_state(consumed_liquid: Variant, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_method_update_2([consumed_liquid, amount, build_edelta, multiplier_get_build])
	var canonical = update_state(consumed_liquid, amount, build_edelta, multiplier_get_build)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_UPDATE_STATE, "generated_owner": "consume_liquid_filter.update", "result": result, "canonical": canonical, "matches": result.get("remove_call", {}) == canonical.get("remove_call", {}) and result.get("remove_called", null) == canonical.get("remove_called", null) and result.get("remove_amount", null) == canonical.get("remove_amount", null)}

static func generated_efficiency_bridge_state(consumed_liquid: Variant, build_liquids_get: float, amount: float, build_edelta: float, multiplier_get_build: float, source_consume_efficiency_epsilon: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_method_efficiency_3([consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build])
	var canonical = efficiency_state(consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build, source_consume_efficiency_epsilon)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_EFFICIENCY_STATE, "generated_owner": "consume_liquid_filter.efficiency", "result": result, "canonical": canonical, "matches": result.get("efficiency", null) == canonical.get("efficiency", null) and result.get("raw_efficiency", null) == canonical.get("raw_efficiency", null) and result.get("ed_guard", null) == canonical.get("ed_guard", null)}

static func generated_efficiency_multiplier_bridge_state(consumed_liquid: Variant, liquid_efficiency_multiplier: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_method_efficiencyMultiplier_4([consumed_liquid, liquid_efficiency_multiplier])
	var canonical = efficiency_multiplier_state(consumed_liquid, liquid_efficiency_multiplier)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_liquid_filter.efficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null) and result.get("has_consumed_liquid", null) == canonical.get("has_consumed_liquid", null)}

static func generated_liquid_efficiency_multiplier_bridge_state() -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_method_liquidEfficiencyMultiplier_8([])
	var canonical = liquid_efficiency_multiplier_state()
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_LIQUID_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_liquid_filter.liquidEfficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null)}

static func generated_display_bridge_state(booster: bool, amount: float, filtered_liquid_ids: Array, source_tick_rate: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_method_display_6([booster, amount, filtered_liquid_ids, source_tick_rate])
	var canonical = display_state(booster, amount, filtered_liquid_ids, source_tick_rate)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_DISPLAY_STATE, "generated_owner": "consume_liquid_filter.display", "result": result, "canonical": canonical, "matches": result.get("selected_stat", null) == canonical.get("selected_stat", null) and result.get("display_amount_per_second", null) == canonical.get("display_amount_per_second", null) and result.get("display_liquids", []) == canonical.get("display_liquids", []) and result.get("stats_add_call", {}) == canonical.get("stats_add_call", {})}

static func generated_consumes_bridge_state(filter_get_liquid: bool) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidFilter.gd")
	var instance = script.new()
	var result = instance.java_method_consumes_7([filter_get_liquid])
	var canonical = consumes_state(filter_get_liquid)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_LIQUID_FILTER_STATE_CONSUMES_STATE, "generated_owner": "consume_liquid_filter.consumes", "result": result, "canonical": canonical, "matches": result.get("consumes_liquid", null) == canonical.get("consumes_liquid", null)}
