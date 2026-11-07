extends RefCounted
class_name SourceConsumeLiquidState

const source_runtime_storage := preload("res://src/game/SourceLiquidModuleState.gd")
const source_runtime_time := preload("res://src/game/SourceBuildingTimeState.gd")

class RuntimeConsumer extends RefCounted:
	var definition: Dictionary
	var liquids: Dictionary
	var cache_sums: Array
	var cost_multiplier: Callable
	var source_delta: float
	var time_scale: float

	func efficiency(build: Dictionary) -> float:
		var available = SourceConsumeLiquidState.source_runtime_storage.source_get_state(liquids, definition["liquid"])["amount"]
		var edelta = SourceConsumeLiquidState.source_runtime_time.edelta(source_delta, time_scale, build["efficiency"])
		return SourceConsumeLiquidState.efficiency_state(available, definition["amount"], edelta, build["efficiency_scale"], cost_multiplier.call(build)["multiplier"])["efficiency"]

	func update(build: Dictionary) -> void:
		var edelta = SourceConsumeLiquidState.source_runtime_time.edelta(source_delta, time_scale, build["efficiency"])
		var request = SourceConsumeLiquidState.update_state(definition["liquid"], definition["amount"], edelta, cost_multiplier.call(build)["multiplier"])
		SourceConsumeLiquidState.source_runtime_storage.source_remove_state(liquids, definition["liquid"], request["remove_amount"], cache_sums)

static func source_runtime_consumer_state(definition: Dictionary, liquids: Dictionary, cache_sums: Array, cost_multiplier: Callable) -> Dictionary:
	var consumer := RuntimeConsumer.new()
	consumer.definition = definition
	consumer.liquids = liquids
	consumer.cache_sums = cache_sums
	consumer.cost_multiplier = cost_multiplier
	return {"consumer": consumer}

const source_liquid_consumer_catalog := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_liquid_consumer_base := preload("res://src/game/SourceConsumeState.gd")
const SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY := "source_block_liquid_consumers"
const SOURCE_BLOCK_LIQUID_APPLY_META_KEY := "source_block_liquid_apply"
const source_liquid_base_apply := preload("res://src/game/SourceConsumeLiquidBaseState.gd")
const source_liquid_filter_init := preload("res://src/game/SourceBlockInitItemLiquidFiltersState.gd")

static func source_apply_filter_state(liquid_filter_before: Array, liquid_id: int) -> Dictionary:
	var liquid_filter_after := liquid_filter_before.duplicate()
	liquid_filter_after[liquid_id] = true
	return {"liquid_filter_after": liquid_filter_after}

static func source_apply_liquid_consumers_state(block: Object, content_catalog: Object) -> Dictionary:
	if block.has_meta(SOURCE_BLOCK_LIQUID_APPLY_META_KEY):
		return block.get_meta(SOURCE_BLOCK_LIQUID_APPLY_META_KEY)
	var consumers: Array = source_bind_liquid_consumers_state(block, content_catalog)["consumers"]
	assert(not consumers.is_empty(), "Apply capability requires at least one resolved ConsumeLiquid")
	var filters := source_liquid_filter_init.item_liquid_filters_state(content_catalog.call("get_many", "item").size(), content_catalog.call("get_many", "liquid").size())
	var liquid_filter: Array = filters["liquid_filter"]
	var applied: Dictionary = {}
	for consumer in consumers:
		var capability := source_liquid_base_apply.source_apply_capability_state()
		liquid_filter = source_apply_filter_state(liquid_filter, consumer["liquid"])["liquid_filter_after"]
		applied = {"has_liquids": capability["block_has_liquids_after"], "liquid_filter": liquid_filter}
	block.set_meta(SOURCE_BLOCK_LIQUID_APPLY_META_KEY, applied)
	return applied

static func source_liquid_consumer_definitions_state(block: Object) -> Dictionary:
	return {"consume_builder": block.properties["consumeLiquid"]}

static func source_bind_liquid_consumers_state(block: Object, content_catalog: Object) -> Dictionary:
	if block.has_meta(SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY):
		return {"consumers": block.get_meta(SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY)}
	var catalog := source_liquid_consumer_catalog.source_liquid_catalog_state(content_catalog)
	var liquids: Array = content_catalog.call("get_many", "liquid")
	var consumers: Array = []
	for definition in source_liquid_consumer_definitions_state(block)["consume_builder"]:
		var matches := liquids.filter(func(liquid): return liquid.field == definition["liquid"])
		assert(matches.size() == 1, "ConsumeLiquid Java field must resolve uniquely in the typed liquid catalog")
		var constructor := constructor_state(catalog["liquid_id_by_name"][matches[0].id], definition["amount"])
		var consumer: Dictionary = definition.duplicate()
		consumer["liquid"] = constructor["liquid_after"]
		consumer["amount"] = constructor["amount_after"]
		consumer["ignored"] = source_liquid_consumer_base.ignore_state()["ignored"]
		consumers.append(consumer)
	block.set_meta(SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY, consumers)
	return {"consumers": consumers}

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const SOURCE_UI_ICON_MED := source_ui_defaults.ICON_MED
const SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY := "base_apply_state"
const SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_FALLBACK := "source_consume_liquid_base_apply_state"

const SOURCE_CONSUME_LIQUID_SOURCE := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_SOURCE
const SOURCE_CONSUME_LIQUID_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CONSTRUCTOR
const SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR
const SOURCE_CONSUME_LIQUID_DEFAULT_CALL_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DEFAULT_CALL_EXPR
const SOURCE_CONSUME_LIQUID_LIQUID_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_LIQUID_FIELD_EXPR
const SOURCE_CONSUME_LIQUID_SUPER_CALL_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_SUPER_CALL_EXPR
const SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_EXPR
const SOURCE_CONSUME_LIQUID_AMOUNT_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_AMOUNT_ASSIGNMENT_EXPR
const SOURCE_CONSUME_LIQUID_LIQUID_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_LIQUID_ASSIGNMENT_EXPR
const SOURCE_CONSUME_LIQUID_APPLY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_APPLY_METHOD
const SOURCE_CONSUME_LIQUID_APPLY_SUPER_APPLY_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_APPLY_SUPER_APPLY_EXPR
const SOURCE_CONSUME_LIQUID_APPLY_LIQUID_FILTER_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_APPLY_LIQUID_FILTER_ASSIGNMENT_EXPR
const SOURCE_CONSUME_LIQUID_BLOCK_LIQUID_FILTER_FIELD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BLOCK_LIQUID_FILTER_FIELD
const SOURCE_CONSUME_LIQUID_BUILD_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BUILD_METHOD
const SOURCE_CONSUME_LIQUID_BUILD_REQ_IMAGE_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BUILD_REQ_IMAGE_EXPR
const SOURCE_CONSUME_LIQUID_BUILD_UI_ICON_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BUILD_UI_ICON_EXPR
const SOURCE_CONSUME_LIQUID_BUILD_VALID_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BUILD_VALID_EXPR
const SOURCE_CONSUME_LIQUID_REQ_IMAGE_CONSTRUCTOR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_REQ_IMAGE_CONSTRUCTOR
const SOURCE_CONSUME_LIQUID_REQ_IMAGE_VALID_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_REQ_IMAGE_VALID_EXPR
const SOURCE_CONSUME_LIQUID_VARS_ICON_MED_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_VARS_ICON_MED_EXPR
const SOURCE_CONSUME_LIQUID_MODULE_GET_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_MODULE_GET_EXPR
const SOURCE_CONSUME_LIQUID_CELL_SIZE_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CELL_SIZE_EXPR
const SOURCE_CONSUME_LIQUID_CELL_TOP_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CELL_TOP_EXPR
const SOURCE_CONSUME_LIQUID_CELL_LEFT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CELL_LEFT_EXPR
const SOURCE_CONSUME_LIQUID_DISPLAY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_METHOD
const SOURCE_CONSUME_LIQUID_AMOUNT_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_AMOUNT_FIELD_EXPR
const SOURCE_CONSUME_LIQUID_BOOSTER_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BOOSTER_FIELD_EXPR
const SOURCE_CONSUME_LIQUID_DISPLAY_STATS_ADD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_STATS_ADD_EXPR
const SOURCE_CONSUME_LIQUID_DISPLAY_SELECTED_STAT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_SELECTED_STAT_EXPR
const SOURCE_CONSUME_LIQUID_DISPLAY_STAT_INPUT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_STAT_INPUT_EXPR
const SOURCE_CONSUME_LIQUID_DISPLAY_STAT_BOOSTER_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_STAT_BOOSTER_EXPR
const SOURCE_CONSUME_LIQUID_DISPLAY_STATS_ADD_LIQUID_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_STATS_ADD_LIQUID_METHOD
const SOURCE_CONSUME_LIQUID_DISPLAY_STAT_VALUES_LIQUID_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_STAT_VALUES_LIQUID_EXPR
const SOURCE_CONSUME_LIQUID_DISPLAY_STAT_VALUES_LIQUID_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_STAT_VALUES_LIQUID_METHOD
const SOURCE_CONSUME_LIQUID_DISPLAY_STAT_VALUES_DISPLAY_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_STAT_VALUES_DISPLAY_EXPR
const SOURCE_CONSUME_LIQUID_DISPLAY_STATS_ADD_CALL_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_STATS_ADD_CALL_EXPR
const SOURCE_CONSUME_LIQUID_UPDATE_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_UPDATE_METHOD
const SOURCE_CONSUME_LIQUID_UPDATE_REMOVE_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_UPDATE_REMOVE_EXPR
const SOURCE_CONSUME_LIQUID_MULTIPLIER_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_MULTIPLIER_FIELD_EXPR
const SOURCE_CONSUME_LIQUID_BUILDING_LIQUIDS_FIELD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BUILDING_LIQUIDS_FIELD_EXPR
const SOURCE_CONSUME_LIQUID_BUILDING_EDELTA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BUILDING_EDELTA_METHOD
const SOURCE_CONSUME_LIQUID_EFFICIENCY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_METHOD
const SOURCE_CONSUME_LIQUID_EFFICIENCY_ED_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_ED_EXPR
const SOURCE_CONSUME_LIQUID_EFFICIENCY_ED_GUARD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_ED_GUARD_EXPR
const SOURCE_CONSUME_LIQUID_EFFICIENCY_CAP_COMMENT := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_CAP_COMMENT
const SOURCE_CONSUME_LIQUID_EFFICIENCY_RETURN_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_RETURN_EXPR
const SOURCE_CONSUME_LIQUID_EFFICIENCY_BUILD_LIQUIDS_GET_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_BUILD_LIQUIDS_GET_EXPR
const SOURCE_CONSUME_LIQUID_EFFICIENCY_AMOUNT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_AMOUNT_EXPR
const SOURCE_CONSUME_LIQUID_EFFICIENCY_BUILD_EDELTA_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_BUILD_EDELTA_EXPR
const SOURCE_CONSUME_LIQUID_EFFICIENCY_BUILD_EFFICIENCY_SCALE_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_BUILD_EFFICIENCY_SCALE_EXPR
const SOURCE_CONSUME_LIQUID_EFFICIENCY_MULTIPLIER_GET_BUILD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_MULTIPLIER_GET_BUILD_EXPR
const SOURCE_CONSUME_LIQUID_CONSUMES_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CONSUMES_METHOD
const SOURCE_CONSUME_LIQUID_CONSUMES_RETURN_EXPR := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CONSUMES_RETURN_EXPR

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_consume_liquid_method_names"):
		var names = game.call("_consume_liquid_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY, SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_FALLBACK)),
	}

static func game_apply_state(game: Object, block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int) -> Dictionary:
	return apply_state(
		block_has_liquids_before,
		liquid_filter_before,
		liquid_id,
		default_callbacks_state(game).get(SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY, Callable())
	)

static func constructor_state(liquid: Variant, amount: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_CONSTRUCTOR_STATE,
		"source": SOURCE_CONSUME_LIQUID_SOURCE,
		"constructor": SOURCE_CONSUME_LIQUID_CONSTRUCTOR,
		"liquid_field": SOURCE_CONSUME_LIQUID_LIQUID_FIELD_EXPR,
		"super_call_expr": SOURCE_CONSUME_LIQUID_SUPER_CALL_EXPR,
		"base_constructor_expr": SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_EXPR,
		"amount_assignment_expr": SOURCE_CONSUME_LIQUID_AMOUNT_ASSIGNMENT_EXPR,
		"liquid_assignment_expr": SOURCE_CONSUME_LIQUID_LIQUID_ASSIGNMENT_EXPR,
		"liquid": liquid,
		"amount": amount,
		"amount_after": amount,
		"liquid_after": liquid,
	}

static func default_constructor_state(default_liquid: Variant, default_amount: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR_STATE,
		"source": SOURCE_CONSUME_LIQUID_SOURCE,
		"constructor": SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR,
		"default_call_expr": SOURCE_CONSUME_LIQUID_DEFAULT_CALL_EXPR,
		"typed_constructor_expr": SOURCE_CONSUME_LIQUID_CONSTRUCTOR,
		"liquid_field": SOURCE_CONSUME_LIQUID_LIQUID_FIELD_EXPR,
		"super_call_expr": SOURCE_CONSUME_LIQUID_SUPER_CALL_EXPR,
		"base_constructor_expr": SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_EXPR,
		"amount_assignment_expr": SOURCE_CONSUME_LIQUID_AMOUNT_ASSIGNMENT_EXPR,
		"liquid_assignment_expr": SOURCE_CONSUME_LIQUID_LIQUID_ASSIGNMENT_EXPR,
		"default_liquid": default_liquid,
		"default_amount": default_amount,
		"amount_after": default_amount,
		"liquid_after": default_liquid,
	}

static func apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int, base_apply_state_provider: Callable) -> Dictionary:
	var base_apply_state: Dictionary = base_apply_state_provider.call(block_has_liquids_before)
	var liquid_filter_after: Array = source_apply_filter_state(liquid_filter_before, liquid_id)["liquid_filter_after"]
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_APPLY_STATE,
		"source": SOURCE_CONSUME_LIQUID_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_APPLY_METHOD,
		"super_apply_expr": SOURCE_CONSUME_LIQUID_APPLY_SUPER_APPLY_EXPR,
		"liquid_filter_assignment_expr": SOURCE_CONSUME_LIQUID_APPLY_LIQUID_FILTER_ASSIGNMENT_EXPR,
		"block_liquid_filter_field": SOURCE_CONSUME_LIQUID_BLOCK_LIQUID_FILTER_FIELD,
		"block_has_liquids_before": block_has_liquids_before,
		"block_has_liquids_after": base_apply_state.get("block_has_liquids_after", null),
		"base_apply_state": base_apply_state,
		"liquid_filter_before": liquid_filter_before,
		"liquid_id": liquid_id,
		"liquid_filter_after": liquid_filter_after,
	}

static func build_state(liquid_id: int, build_liquids_get: float, _source_ui_icon_med: float) -> Dictionary:
	var valid: bool = build_liquids_get > 0.0
	var req_image: Dictionary = {"liquid_id": liquid_id, "icon": SOURCE_CONSUME_LIQUID_BUILD_UI_ICON_EXPR, "valid": valid, "valid_expr": SOURCE_CONSUME_LIQUID_BUILD_VALID_EXPR}
	var table_image_size: float = SOURCE_UI_ICON_MED
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BUILD_STATE,
		"source": SOURCE_CONSUME_LIQUID_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_BUILD_METHOD,
		"liquid_field": SOURCE_CONSUME_LIQUID_LIQUID_FIELD_EXPR,
		"req_image_expr": SOURCE_CONSUME_LIQUID_BUILD_REQ_IMAGE_EXPR,
		"liquid_ui_icon_expr": SOURCE_CONSUME_LIQUID_BUILD_UI_ICON_EXPR,
		"valid_expr": SOURCE_CONSUME_LIQUID_BUILD_VALID_EXPR,
		"req_image_constructor": SOURCE_CONSUME_LIQUID_REQ_IMAGE_CONSTRUCTOR,
		"req_image_valid": SOURCE_CONSUME_LIQUID_REQ_IMAGE_VALID_EXPR,
		"vars_icon_med": SOURCE_CONSUME_LIQUID_VARS_ICON_MED_EXPR,
		"liquid_module_get": SOURCE_CONSUME_LIQUID_MODULE_GET_EXPR,
		"cell_size_expr": SOURCE_CONSUME_LIQUID_CELL_SIZE_EXPR,
		"cell_top_expr": SOURCE_CONSUME_LIQUID_CELL_TOP_EXPR,
		"cell_left_expr": SOURCE_CONSUME_LIQUID_CELL_LEFT_EXPR,
		"liquid_id": liquid_id,
		"build_liquids_get": build_liquids_get,
		"valid": valid,
		"req_image": req_image,
		"table_image_size": table_image_size,
		"table_top": true,
		"table_left": true,
	}

static func display_state(booster: bool, liquid_id: int, amount: float) -> Dictionary:
	var selected_stat: String = "booster" if booster else "input"
	var display_amount_per_second: float = amount * source_time_defaults.TICK_RATE
	var stats_add_call: Dictionary = {"call": SOURCE_CONSUME_LIQUID_DISPLAY_STATS_ADD_CALL_EXPR, "stat": selected_stat, "liquid_id": liquid_id, "amount": display_amount_per_second, "per_second": true}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_DISPLAY_STATE,
		"source": SOURCE_CONSUME_LIQUID_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_DISPLAY_METHOD,
		"liquid_field": SOURCE_CONSUME_LIQUID_LIQUID_FIELD_EXPR,
		"amount_field": SOURCE_CONSUME_LIQUID_AMOUNT_FIELD_EXPR,
		"booster_field": SOURCE_CONSUME_LIQUID_BOOSTER_FIELD_EXPR,
		"stats_add_expr": SOURCE_CONSUME_LIQUID_DISPLAY_STATS_ADD_EXPR,
		"selected_stat_expr": SOURCE_CONSUME_LIQUID_DISPLAY_SELECTED_STAT_EXPR,
		"stat_input_expr": SOURCE_CONSUME_LIQUID_DISPLAY_STAT_INPUT_EXPR,
		"stat_booster_expr": SOURCE_CONSUME_LIQUID_DISPLAY_STAT_BOOSTER_EXPR,
		"stats_add_liquid_method": SOURCE_CONSUME_LIQUID_DISPLAY_STATS_ADD_LIQUID_METHOD,
		"stat_values_liquid_expr": SOURCE_CONSUME_LIQUID_DISPLAY_STAT_VALUES_LIQUID_EXPR,
		"stat_values_liquid_method": SOURCE_CONSUME_LIQUID_DISPLAY_STAT_VALUES_LIQUID_METHOD,
		"stat_values_display_expr": SOURCE_CONSUME_LIQUID_DISPLAY_STAT_VALUES_DISPLAY_EXPR,
		"booster": booster,
		"liquid_id": liquid_id,
		"amount": amount,
		"selected_stat": selected_stat,
		"display_amount_per_second": display_amount_per_second,
		"per_second": true,
		"stats_add_call": stats_add_call,
	}

static func update_state(liquid_id: int, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var remove_amount: float = amount * build_edelta * multiplier_get_build
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_UPDATE_STATE,
		"source": SOURCE_CONSUME_LIQUID_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_UPDATE_METHOD,
		"remove_expr": SOURCE_CONSUME_LIQUID_UPDATE_REMOVE_EXPR,
		"liquid_field": SOURCE_CONSUME_LIQUID_LIQUID_FIELD_EXPR,
		"amount_field": SOURCE_CONSUME_LIQUID_AMOUNT_FIELD_EXPR,
		"multiplier_field": SOURCE_CONSUME_LIQUID_MULTIPLIER_FIELD_EXPR,
		"building_liquids_field": SOURCE_CONSUME_LIQUID_BUILDING_LIQUIDS_FIELD_EXPR,
		"building_edelta_method": SOURCE_CONSUME_LIQUID_BUILDING_EDELTA_METHOD,
		"liquid_id": liquid_id,
		"amount": amount,
		"build_edelta": build_edelta,
		"multiplier_get_build": multiplier_get_build,
		"remove_amount": remove_amount,
	}

static func efficiency_state(build_liquids_get: float, amount: float, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	var ed: float = build_edelta * build_efficiency_scale
	var ed_guard: bool = ed <= source_consumer_defaults.CONSUME_EFFICIENCY_EPSILON
	var required_liquid_amount: float = amount * ed * multiplier_get_build
	var raw_efficiency: float = build_liquids_get / required_liquid_amount if not ed_guard else 0.0
	var efficiency: float = 0.0 if ed_guard else min(raw_efficiency, 1.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_EFFICIENCY_STATE,
		"source": SOURCE_CONSUME_LIQUID_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_EFFICIENCY_METHOD,
		"liquid_field": SOURCE_CONSUME_LIQUID_LIQUID_FIELD_EXPR,
		"ed_expr": SOURCE_CONSUME_LIQUID_EFFICIENCY_ED_EXPR,
		"ed_guard_expr": SOURCE_CONSUME_LIQUID_EFFICIENCY_ED_GUARD_EXPR,
		"cap_comment": SOURCE_CONSUME_LIQUID_EFFICIENCY_CAP_COMMENT,
		"return_expr": SOURCE_CONSUME_LIQUID_EFFICIENCY_RETURN_EXPR,
		"build_liquids_get_expr": SOURCE_CONSUME_LIQUID_EFFICIENCY_BUILD_LIQUIDS_GET_EXPR,
		"amount_expr": SOURCE_CONSUME_LIQUID_EFFICIENCY_AMOUNT_EXPR,
		"build_edelta_expr": SOURCE_CONSUME_LIQUID_EFFICIENCY_BUILD_EDELTA_EXPR,
		"build_efficiency_scale_expr": SOURCE_CONSUME_LIQUID_EFFICIENCY_BUILD_EFFICIENCY_SCALE_EXPR,
		"multiplier_get_build_expr": SOURCE_CONSUME_LIQUID_EFFICIENCY_MULTIPLIER_GET_BUILD_EXPR,
		"amount_field": SOURCE_CONSUME_LIQUID_AMOUNT_FIELD_EXPR,
		"multiplier_field": SOURCE_CONSUME_LIQUID_MULTIPLIER_FIELD_EXPR,
		"build_liquids_get": build_liquids_get,
		"amount": amount,
		"build_edelta": build_edelta,
		"build_efficiency_scale": build_efficiency_scale,
		"multiplier_get_build": multiplier_get_build,
		"ed": ed,
		"ed_guard": ed_guard,
		"required_liquid_amount": required_liquid_amount,
		"raw_efficiency": raw_efficiency,
		"efficiency": efficiency,
	}

static func consumes_state(liquid_matches_self_liquid: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_CONSUMES_STATE,
		"source": SOURCE_CONSUME_LIQUID_SOURCE,
		"method": SOURCE_CONSUME_LIQUID_CONSUMES_METHOD,
		"liquid_field": SOURCE_CONSUME_LIQUID_LIQUID_FIELD_EXPR,
		"liquid_matches_self_liquid": liquid_matches_self_liquid,
		"consumes_liquid": liquid_matches_self_liquid,
		"return_expr": SOURCE_CONSUME_LIQUID_CONSUMES_RETURN_EXPR,
	}
