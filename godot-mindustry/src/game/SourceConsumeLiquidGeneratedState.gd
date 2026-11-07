extends RefCounted
class_name SourceConsumeLiquidGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")

const SOURCE_CONSUME_LIQUID_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_GENERATED_CLASS
const SOURCE_CONSUME_LIQUID_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_APPLY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_APPLY_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_BUILD_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BUILD_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_DISPLAY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_UPDATE_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_UPDATE_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_EFFICIENCY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_CONSUMES_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CONSUMES_JAVA_METHOD
const SOURCE_CONSUME_LIQUID_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_APPLY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_APPLY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_BUILD_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BUILD_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_DISPLAY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_DISPLAY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_UPDATE_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_UPDATE_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_EFFICIENCY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_EFFICIENCY_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_CONSUMES_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_LIQUID_CONSUMES_GENERATED_OWNER
const SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY := source_consume_liquid_state.SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY

static func game_generated_apply_bridge_state(game: Object, block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int) -> Dictionary:
	return generated_apply_bridge_state(
		block_has_liquids_before,
		liquid_filter_before,
		liquid_id,
		source_consume_liquid_state.default_callbacks_state(game).get(SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY, Callable())
	)

static func generated_constructor_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_CONSTRUCTOR_JAVA_METHOD, [liquid, amount], null)
	var canonical = source_consume_liquid_state.constructor_state(liquid, amount)
	var matches: bool = result.get("amount_after", null) == canonical.get("amount_after", null) and result.get("liquid_after", null) == canonical.get("liquid_after", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_CONSTRUCTOR_STATE,
		"generated_owner": SOURCE_CONSUME_LIQUID_CONSTRUCTOR_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_default_constructor_bridge_state(default_liquid: Variant, default_amount: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR_JAVA_METHOD, [], null)
	var canonical = source_consume_liquid_state.default_constructor_state(default_liquid, default_amount)
	var matches: bool = result.get("amount_after", null) == canonical.get("amount_after", null) and result.get("liquid_after", null) == canonical.get("liquid_after", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR_STATE,
		"generated_owner": SOURCE_CONSUME_LIQUID_DEFAULT_CONSTRUCTOR_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int, base_apply_state_provider: Callable) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_APPLY_JAVA_METHOD, [block_has_liquids_before, liquid_filter_before, liquid_id], null)
	var canonical = source_consume_liquid_state.apply_state(block_has_liquids_before, liquid_filter_before, liquid_id, base_apply_state_provider)
	var matches: bool = result.get("block_has_liquids_after", null) == canonical.get("block_has_liquids_after", null) and result.get("liquid_filter_after", []) == canonical.get("liquid_filter_after", [])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_APPLY_STATE,
		"generated_owner": SOURCE_CONSUME_LIQUID_APPLY_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_build_bridge_state(liquid_id: int, build_liquids_get: float, source_ui_icon_med: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_BUILD_JAVA_METHOD, [liquid_id, build_liquids_get, source_ui_icon_med], null)
	var canonical = source_consume_liquid_state.build_state(liquid_id, build_liquids_get, source_ui_icon_med)
	var matches: bool = result.get("req_image", {}) == canonical.get("req_image", {}) and result.get("table_image_size", null) == canonical.get("table_image_size", null) and result.get("table_top", null) == canonical.get("table_top", null) and result.get("table_left", null) == canonical.get("table_left", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BUILD_STATE,
		"generated_owner": SOURCE_CONSUME_LIQUID_BUILD_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_display_bridge_state(booster: bool, liquid_id: int, amount: float, source_tick_rate: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_DISPLAY_JAVA_METHOD, [booster, liquid_id, amount, source_tick_rate], null)
	var canonical = source_consume_liquid_state.display_state(booster, liquid_id, amount)
	var matches: bool = result.get("selected_stat", null) == canonical.get("selected_stat", null) and result.get("display_amount_per_second", null) == canonical.get("display_amount_per_second", null) and result.get("stats_add_call", {}) == canonical.get("stats_add_call", {})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_DISPLAY_STATE,
		"generated_owner": SOURCE_CONSUME_LIQUID_DISPLAY_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_update_bridge_state(liquid_id: int, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_UPDATE_JAVA_METHOD, [liquid_id, amount, build_edelta, multiplier_get_build], null)
	var canonical = source_consume_liquid_state.update_state(liquid_id, amount, build_edelta, multiplier_get_build)
	var matches: bool = result.get("remove_amount", null) == canonical.get("remove_amount", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_UPDATE_STATE,
		"generated_owner": SOURCE_CONSUME_LIQUID_UPDATE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_efficiency_bridge_state(build_liquids_get: float, amount: float, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_EFFICIENCY_JAVA_METHOD, [build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build], null)
	var canonical = source_consume_liquid_state.efficiency_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)
	var matches: bool = result.get("efficiency", null) == canonical.get("efficiency", null) and result.get("raw_efficiency", null) == canonical.get("raw_efficiency", null) and result.get("ed_guard", null) == canonical.get("ed_guard", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_EFFICIENCY_STATE,
		"generated_owner": SOURCE_CONSUME_LIQUID_EFFICIENCY_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_consumes_bridge_state(liquid_matches_self_liquid: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_LIQUID_GENERATED_CLASS, SOURCE_CONSUME_LIQUID_CONSUMES_JAVA_METHOD, [liquid_matches_self_liquid], null)
	var canonical = source_consume_liquid_state.consumes_state(liquid_matches_self_liquid)
	var matches: bool = result.get("consumes_liquid", null) == canonical.get("consumes_liquid", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_CONSUMES_STATE,
		"generated_owner": SOURCE_CONSUME_LIQUID_CONSUMES_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
