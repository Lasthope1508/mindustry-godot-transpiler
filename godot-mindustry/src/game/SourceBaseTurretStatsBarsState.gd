extends RefCounted
class_name SourceBaseTurretStatsBarsState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_BASE_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_BASE_TURRET_GENERATED_CLASS
const SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR := source_turret_source_text_state.SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR

const SOURCE_TURRET_SET_STATS_METHOD := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_METHOD
const SOURCE_TURRET_SET_STATS_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_SUPER_EXPR
const SOURCE_TURRET_SET_BARS_METHOD := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_METHOD
const SOURCE_TURRET_SET_BARS_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_SUPER_EXPR
const SOURCE_TURRET_SET_BARS_HEAT_BAR_NEW_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_HEAT_BAR_NEW_EXPR
const SOURCE_BASE_TURRET_SET_STATS_SHOOT_RANGE_EXPR := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_STATS_SHOOT_RANGE_EXPR
const SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_GUARD := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_GUARD
const SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_EXPR := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_EXPR
const SOURCE_BASE_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_BASE_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_STATS_GENERATED_OWNER
const SOURCE_BASE_TURRET_SET_BARS_ACTIVATION_TIME_GUARD := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_ACTIVATION_TIME_GUARD
const SOURCE_BASE_TURRET_SET_BARS_ADD_BAR_EXPR := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_ADD_BAR_EXPR
const SOURCE_BASE_TURRET_SET_BARS_TEXT_FORMAT_EXPR := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_TEXT_FORMAT_EXPR
const SOURCE_BASE_TURRET_SET_BARS_TEXT_GET_EXPR := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_TEXT_GET_EXPR
const SOURCE_BASE_TURRET_SET_BARS_ACTIVE_COLOR_VALUE := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_ACTIVE_COLOR_VALUE
const SOURCE_BASE_TURRET_SET_BARS_INACTIVE_COLOR_VALUE := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_INACTIVE_COLOR_VALUE
const SOURCE_BASE_TURRET_SET_BARS_COLOR_EXPR := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_COLOR_EXPR
const SOURCE_BASE_TURRET_SET_BARS_JAVA_METHOD := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_JAVA_METHOD
const SOURCE_BASE_TURRET_SET_BARS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_GENERATED_OWNER
const SOURCE_BASE_TURRET_SET_BARS_PROGRESS_EXPR := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_PROGRESS_EXPR
const SOURCE_BASE_TURRET_SET_BARS_CALL_EXPR := source_turret_source_text_state.SOURCE_BASE_TURRET_SET_BARS_CALL_EXPR

static func _base_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BASE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func base_turret_set_stats_state(range_value: float, source_tilesize: float, activation_time: float, tick_rate: float) -> Dictionary:
	var shoot_range_stat_call := {
		"call": SOURCE_BASE_TURRET_SET_STATS_SHOOT_RANGE_EXPR,
		"stat": "Stat.shootRange",
		"value": range_value / source_tilesize,
		"unit": "StatUnit.blocks",
	}
	var activation_time_stat_called: bool = activation_time > 0.0
	var activation_time_stat_call := {
		"call": SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_EXPR,
		"stat": "Stat.activationTime",
		"value": activation_time / tick_rate,
		"unit": "StatUnit.seconds",
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"super_set_stats_called": true,
		"activation_time_stat_called": activation_time_stat_called,
		"shoot_range_stat_expr": SOURCE_BASE_TURRET_SET_STATS_SHOOT_RANGE_EXPR,
		"activation_time_guard_expr": SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_GUARD,
		"activation_time_stat_expr": SOURCE_BASE_TURRET_SET_STATS_ACTIVATION_TIME_EXPR,
		"range": range_value,
		"tilesize": source_tilesize,
		"activation_time": activation_time,
		"shoot_range_blocks": range_value / source_tilesize,
		"shoot_range_stat_call": shoot_range_stat_call,
		"activation_time_stat_call": activation_time_stat_call,
	}

static func generated_base_turret_set_stats_bridge_state(range_value: float, source_tilesize: float, activation_time: float, tick_rate: float) -> Dictionary:
	var result = _base_turret_call(SOURCE_BASE_TURRET_SET_STATS_JAVA_METHOD, [range_value, source_tilesize, activation_time, tick_rate])
	var canonical = base_turret_set_stats_state(range_value, source_tilesize, activation_time, tick_rate)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_BASE_TURRET_SET_STATS_STATE,
		"generated_owner": SOURCE_BASE_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical),
	}

static func base_turret_set_bars_state(activation_time: float, entity_activation_timer: float, tick_rate: float) -> Dictionary:
	var activation_bar_added: bool = activation_time > 0.0
	var activation_timer_positive: bool = entity_activation_timer > 0.0
	var activation_bar_fraction: float = 0.0
	var activation_bar_text_call: Dictionary = {}
	var activation_bar_color: String = ""
	var activation_bar_call: Dictionary = {}
	if activation_bar_added:
		activation_bar_fraction = 1.0 - entity_activation_timer / activation_time
		if activation_timer_positive:
			activation_bar_text_call = {"call": SOURCE_BASE_TURRET_SET_BARS_TEXT_FORMAT_EXPR, "key": "bar.activationtimer", "seconds": ceil(entity_activation_timer / tick_rate)}
			activation_bar_color = SOURCE_BASE_TURRET_SET_BARS_ACTIVE_COLOR_VALUE
		else:
			activation_bar_text_call = {"call": SOURCE_BASE_TURRET_SET_BARS_TEXT_GET_EXPR, "key": "bar.activated"}
			activation_bar_color = SOURCE_BASE_TURRET_SET_BARS_INACTIVE_COLOR_VALUE
		activation_bar_call = {"call": SOURCE_BASE_TURRET_SET_BARS_CALL_EXPR, "name": "activationtimer", "text_call": activation_bar_text_call, "color": activation_bar_color, "fraction": activation_bar_fraction}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_SET_BARS_STATE,
		"method": SOURCE_TURRET_SET_BARS_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"super_set_bars_expr": SOURCE_TURRET_SET_BARS_SUPER_EXPR,
		"activation_time_guard_expr": SOURCE_BASE_TURRET_SET_BARS_ACTIVATION_TIME_GUARD,
		"add_bar_expr": SOURCE_BASE_TURRET_SET_BARS_ADD_BAR_EXPR,
		"bar_new_expr": SOURCE_TURRET_SET_BARS_HEAT_BAR_NEW_EXPR,
		"bar_text_format_expr": SOURCE_BASE_TURRET_SET_BARS_TEXT_FORMAT_EXPR,
		"bar_text_get_expr": SOURCE_BASE_TURRET_SET_BARS_TEXT_GET_EXPR,
		"bar_color_expr": SOURCE_BASE_TURRET_SET_BARS_COLOR_EXPR,
		"bar_progress_expr": SOURCE_BASE_TURRET_SET_BARS_PROGRESS_EXPR,
		"activation_time": activation_time,
		"entity_activation_timer": entity_activation_timer,
		"super_set_bars_called": true,
		"activation_bar_added": activation_bar_added,
		"activation_timer_positive": activation_timer_positive,
		"activation_bar_fraction": activation_bar_fraction,
		"activation_bar_text_call": activation_bar_text_call,
		"activation_bar_color": activation_bar_color,
		"activation_bar_call": activation_bar_call,
	}

static func generated_base_turret_set_bars_bridge_state(activation_time: float, entity_activation_timer: float, tick_rate: float) -> Dictionary:
	var result = _base_turret_call(SOURCE_BASE_TURRET_SET_BARS_JAVA_METHOD, [activation_time, entity_activation_timer, tick_rate])
	var canonical = base_turret_set_bars_state(activation_time, entity_activation_timer, tick_rate)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_BASE_TURRET_SET_BARS_STATE,
		"generated_owner": SOURCE_BASE_TURRET_SET_BARS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical),
	}
