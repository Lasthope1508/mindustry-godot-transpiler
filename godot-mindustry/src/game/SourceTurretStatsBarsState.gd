extends RefCounted
class_name SourceTurretStatsBarsState

const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_base_turret_stats_bars_state := preload("res://src/game/SourceBaseTurretStatsBarsState.gd")
const source_specialized_turret_stats_state := preload("res://src/game/SourceSpecializedTurretStatsState.gd")
const source_turret_ammo_stats_bars_state := preload("res://src/game/SourceTurretAmmoStatsBarsState.gd")

const SOURCE_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TURRET_GENERATED_CLASS
const SOURCE_TURRET_SET_STATS_METHOD := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_METHOD
const SOURCE_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_GENERATED_OWNER
const SOURCE_TURRET_SET_STATS_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_SUPER_EXPR
const SOURCE_TURRET_SET_STATS_INACCURACY_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_INACCURACY_EXPR
const SOURCE_TURRET_SET_STATS_RELOAD_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_RELOAD_EXPR
const SOURCE_TURRET_SET_STATS_TARGETS_AIR_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_TARGETS_AIR_EXPR
const SOURCE_TURRET_SET_STATS_TARGETS_GROUND_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_TARGETS_GROUND_EXPR
const SOURCE_TURRET_SET_STATS_AMMO_USE_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_AMMO_USE_EXPR
const SOURCE_TURRET_SET_STATS_INPUT_HEAT_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_INPUT_HEAT_EXPR
const SOURCE_TURRET_SET_STATS_MAX_EFFICIENCY_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_MAX_EFFICIENCY_EXPR
const SOURCE_TURRET_SET_STATS_AMMO_USE_GUARD_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_AMMO_USE_GUARD_EXPR
const SOURCE_TURRET_SET_STATS_INPUT_HEAT_GUARD_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_INPUT_HEAT_GUARD_EXPR
const SOURCE_TURRET_SET_STATS_MAX_EFFICIENCY_GUARD_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_MAX_EFFICIENCY_GUARD_EXPR
const SOURCE_TURRET_SET_BARS_METHOD := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_METHOD
const SOURCE_TURRET_SET_BARS_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_JAVA_METHOD
const SOURCE_TURRET_SET_BARS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_GENERATED_OWNER
const SOURCE_TURRET_SET_BARS_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_SUPER_EXPR
const SOURCE_TURRET_SET_BARS_HEAT_REQUIREMENT_GUARD := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_HEAT_REQUIREMENT_GUARD
const SOURCE_TURRET_SET_BARS_HEAT_ADD_BAR_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_HEAT_ADD_BAR_EXPR
const SOURCE_TURRET_SET_BARS_HEAT_BAR_NEW_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_HEAT_BAR_NEW_EXPR
const SOURCE_TURRET_SET_BARS_HEAT_TEXT_FORMAT_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_HEAT_TEXT_FORMAT_EXPR
const SOURCE_TURRET_SET_BARS_HEAT_COLOR_VALUE := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_HEAT_COLOR_VALUE
const SOURCE_TURRET_SET_BARS_HEAT_COLOR_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_HEAT_COLOR_EXPR
const SOURCE_TURRET_SET_BARS_HEAT_PROGRESS_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_HEAT_PROGRESS_EXPR
const SOURCE_TURRET_SET_BARS_HEAT_CALL_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_HEAT_CALL_EXPR

static func _turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)


static func base_turret_set_stats_state(range_value: float, source_tilesize: float, activation_time: float, tick_rate: float) -> Dictionary:
	return source_base_turret_stats_bars_state.base_turret_set_stats_state(range_value, source_tilesize, activation_time, tick_rate)


static func generated_base_turret_set_stats_bridge_state(range_value: float, source_tilesize: float, activation_time: float, tick_rate: float) -> Dictionary:
	return source_base_turret_stats_bars_state.generated_base_turret_set_stats_bridge_state(range_value, source_tilesize, activation_time, tick_rate)


static func base_turret_set_bars_state(activation_time: float, entity_activation_timer: float, tick_rate: float) -> Dictionary:
	return source_base_turret_stats_bars_state.base_turret_set_bars_state(activation_time, entity_activation_timer, tick_rate)


static func generated_base_turret_set_bars_bridge_state(activation_time: float, entity_activation_timer: float, tick_rate: float) -> Dictionary:
	return source_base_turret_stats_bars_state.generated_base_turret_set_bars_bridge_state(activation_time, entity_activation_timer, tick_rate)


static func set_stats_state(inaccuracy_value: float, reload_value: float, reload_while_charging: bool, shoot_first_shot_delay: float, shoot_shots: float, target_air: bool, target_ground: bool, ammo_per_shot: int, heat_requirement: float, max_heat_efficiency: float, tick_rate: float) -> Dictionary:
	var reload_stat_denominator: float = reload_value + (shoot_first_shot_delay if not reload_while_charging else 0.0)
	var reload_stat_rate: float = tick_rate / reload_stat_denominator * shoot_shots
	var inaccuracy_stat_call: Dictionary = {"call": SOURCE_TURRET_SET_STATS_INACCURACY_EXPR, "stat": "Stat.inaccuracy", "value": int(inaccuracy_value), "unit": "StatUnit.degrees"}
	var reload_stat_call: Dictionary = {"call": SOURCE_TURRET_SET_STATS_RELOAD_EXPR, "stat": "Stat.reload", "value": reload_stat_rate, "unit": "StatUnit.perSecond", "denominator": reload_stat_denominator}
	var targets_air_stat_call: Dictionary = {"call": SOURCE_TURRET_SET_STATS_TARGETS_AIR_EXPR, "stat": "Stat.targetsAir", "value": target_air}
	var targets_ground_stat_call: Dictionary = {"call": SOURCE_TURRET_SET_STATS_TARGETS_GROUND_EXPR, "stat": "Stat.targetsGround", "value": target_ground}
	var ammo_use_stat_called: bool = ammo_per_shot != 1
	var ammo_use_stat_call: Dictionary = {}
	if ammo_use_stat_called:
		ammo_use_stat_call = {"call": SOURCE_TURRET_SET_STATS_AMMO_USE_EXPR, "stat": "Stat.ammoUse", "value": ammo_per_shot, "unit": "StatUnit.perShot"}
	var input_heat_stat_called: bool = heat_requirement > 0.0
	var input_heat_stat_call: Dictionary = {}
	if input_heat_stat_called:
		input_heat_stat_call = {"call": SOURCE_TURRET_SET_STATS_INPUT_HEAT_EXPR, "stat": "Stat.input", "value": heat_requirement, "unit": "StatUnit.heatUnits"}
	var max_efficiency_stat_called: bool = heat_requirement > 0.0 and max_heat_efficiency > 0.0
	var max_efficiency_stat_call: Dictionary = {}
	if max_efficiency_stat_called:
		max_efficiency_stat_call = {"call": SOURCE_TURRET_SET_STATS_MAX_EFFICIENCY_EXPR, "stat": "Stat.maxEfficiency", "value": int(max_heat_efficiency * source_turret_defaults.TURRET_PERCENT_SCALE), "unit": "StatUnit.percent"}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"inaccuracy_stat_expr": SOURCE_TURRET_SET_STATS_INACCURACY_EXPR,
		"reload_stat_expr": SOURCE_TURRET_SET_STATS_RELOAD_EXPR,
		"targets_air_stat_expr": SOURCE_TURRET_SET_STATS_TARGETS_AIR_EXPR,
		"targets_ground_stat_expr": SOURCE_TURRET_SET_STATS_TARGETS_GROUND_EXPR,
		"ammo_use_guard_expr": SOURCE_TURRET_SET_STATS_AMMO_USE_GUARD_EXPR,
		"ammo_use_stat_expr": SOURCE_TURRET_SET_STATS_AMMO_USE_EXPR,
		"input_heat_guard_expr": SOURCE_TURRET_SET_STATS_INPUT_HEAT_GUARD_EXPR,
		"input_heat_stat_expr": SOURCE_TURRET_SET_STATS_INPUT_HEAT_EXPR,
		"max_efficiency_guard_expr": SOURCE_TURRET_SET_STATS_MAX_EFFICIENCY_GUARD_EXPR,
		"max_efficiency_stat_expr": SOURCE_TURRET_SET_STATS_MAX_EFFICIENCY_EXPR,
		"inaccuracy_value": inaccuracy_value,
		"reload_value": reload_value,
		"reload_while_charging": reload_while_charging,
		"shoot_first_shot_delay": shoot_first_shot_delay,
		"shoot_shots": shoot_shots,
		"target_air": target_air,
		"target_ground": target_ground,
		"ammo_per_shot": ammo_per_shot,
		"heat_requirement": heat_requirement,
		"max_heat_efficiency": max_heat_efficiency,
		"reload_stat_denominator": reload_stat_denominator,
		"reload_stat_rate": reload_stat_rate,
		"super_set_stats_called": true,
		"inaccuracy_stat_call": inaccuracy_stat_call,
		"reload_stat_call": reload_stat_call,
		"targets_air_stat_call": targets_air_stat_call,
		"targets_ground_stat_call": targets_ground_stat_call,
		"ammo_use_stat_called": ammo_use_stat_called,
		"ammo_use_stat_call": ammo_use_stat_call,
		"input_heat_stat_called": input_heat_stat_called,
		"input_heat_stat_call": input_heat_stat_call,
		"max_efficiency_stat_called": max_efficiency_stat_called,
		"max_efficiency_stat_call": max_efficiency_stat_call,
	}


static func generated_turret_set_stats_bridge_state(inaccuracy_value: float, reload_value: float, reload_while_charging: bool, shoot_first_shot_delay: float, shoot_shots: float, target_air: bool, target_ground: bool, ammo_per_shot: int, heat_requirement: float, max_heat_efficiency: float) -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_SET_STATS_JAVA_METHOD, [inaccuracy_value, reload_value, reload_while_charging, shoot_first_shot_delay, shoot_shots, target_air, target_ground, ammo_per_shot, heat_requirement, max_heat_efficiency])
	var canonical = set_stats_state(inaccuracy_value, reload_value, reload_while_charging, shoot_first_shot_delay, shoot_shots, target_air, target_ground, ammo_per_shot, heat_requirement, max_heat_efficiency, source_time_defaults.TICK_RATE)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_SET_STATS_STATE,
		"generated_owner": SOURCE_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("reload_stat_call", null) == canonical.get("reload_stat_call", null) and result.get("ammo_use_stat_call", null) == canonical.get("ammo_use_stat_call", null) and result.get("max_efficiency_stat_call", null) == canonical.get("max_efficiency_stat_call", null),
	}


static func set_bars_state(heat_requirement: float, entity_heat_req: float, max_heat_efficiency: float) -> Dictionary:
	var heat_bar_added: bool = heat_requirement > 0.0
	var heat_bar_percent: int = 0
	var heat_bar_fraction: float = 0.0
	var heat_bar_text_call: Dictionary = {}
	var heat_bar_color: String = ""
	var heat_bar_call: Dictionary = {}
	if heat_bar_added:
		heat_bar_percent = int(min(entity_heat_req / heat_requirement, max_heat_efficiency) * source_turret_defaults.TURRET_PERCENT_SCALE)
		heat_bar_fraction = entity_heat_req / heat_requirement
		heat_bar_text_call = {"call": SOURCE_TURRET_SET_BARS_HEAT_TEXT_FORMAT_EXPR, "key": "bar.heatpercent", "heat_req": int(entity_heat_req), "percent": heat_bar_percent}
		heat_bar_color = SOURCE_TURRET_SET_BARS_HEAT_COLOR_VALUE
		heat_bar_call = {"call": SOURCE_TURRET_SET_BARS_HEAT_CALL_EXPR, "name": "heat", "text_call": heat_bar_text_call, "color": heat_bar_color, "fraction": heat_bar_fraction}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_SET_BARS_STATE,
		"method": SOURCE_TURRET_SET_BARS_METHOD,
		"override_expr": "@Override",
		"super_set_bars_expr": SOURCE_TURRET_SET_BARS_SUPER_EXPR,
		"heat_requirement_guard_expr": SOURCE_TURRET_SET_BARS_HEAT_REQUIREMENT_GUARD,
		"add_bar_expr": SOURCE_TURRET_SET_BARS_HEAT_ADD_BAR_EXPR,
		"bar_new_expr": SOURCE_TURRET_SET_BARS_HEAT_BAR_NEW_EXPR,
		"bar_text_format_expr": SOURCE_TURRET_SET_BARS_HEAT_TEXT_FORMAT_EXPR,
		"bar_color_expr": SOURCE_TURRET_SET_BARS_HEAT_COLOR_EXPR,
		"bar_progress_expr": SOURCE_TURRET_SET_BARS_HEAT_PROGRESS_EXPR,
		"heat_requirement": heat_requirement,
		"entity_heat_req": entity_heat_req,
		"max_heat_efficiency": max_heat_efficiency,
		"super_set_bars_called": true,
		"heat_bar_added": heat_bar_added,
		"heat_bar_percent": heat_bar_percent,
		"heat_bar_fraction": heat_bar_fraction,
		"heat_bar_text_call": heat_bar_text_call,
		"heat_bar_color": heat_bar_color,
		"heat_bar_call": heat_bar_call,
	}


static func generated_turret_set_bars_bridge_state(heat_requirement: float, entity_heat_req: float, max_heat_efficiency: float) -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_SET_BARS_JAVA_METHOD, [heat_requirement, entity_heat_req, max_heat_efficiency])
	var canonical = set_bars_state(heat_requirement, entity_heat_req, max_heat_efficiency)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_SET_BARS_STATE,
		"generated_owner": SOURCE_TURRET_SET_BARS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("heat_bar_call", null) == canonical.get("heat_bar_call", null) and result.get("heat_bar_added", null) == canonical.get("heat_bar_added", null),
	}


static func tractor_beam_turret_set_stats_state(target_air: bool, target_ground: bool, damage: float, tick_rate: float) -> Dictionary:
	return source_specialized_turret_stats_state.tractor_beam_turret_set_stats_state(target_air, target_ground, damage, tick_rate)


static func generated_tractor_beam_turret_set_stats_bridge_state(target_air: bool, target_ground: bool, damage: float, tick_rate: float) -> Dictionary:
	return source_specialized_turret_stats_state.generated_tractor_beam_turret_set_stats_bridge_state(target_air, target_ground, damage, tick_rate)


static func reload_turret_set_stats_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	return source_specialized_turret_stats_state.reload_turret_set_stats_state(coolant_present, reload_value, coolant_amount, coolant_multiplier)


static func generated_reload_turret_set_stats_bridge_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	return source_specialized_turret_stats_state.generated_reload_turret_set_stats_bridge_state(coolant_present, reload_value, coolant_amount, coolant_multiplier)


static func point_defense_set_stats_state(bullet_damage: float, reload_value: float, tick_rate: float) -> Dictionary:
	return source_specialized_turret_stats_state.point_defense_set_stats_state(bullet_damage, reload_value, tick_rate)


static func generated_point_defense_turret_set_stats_default_bridge_state(bullet_damage: float, reload_value: float) -> Dictionary:
	return source_specialized_turret_stats_state.generated_point_defense_turret_set_stats_default_bridge_state(bullet_damage, reload_value)


static func power_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	return source_specialized_turret_stats_state.power_turret_set_stats_state(shoot_type)


static func generated_power_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	return source_specialized_turret_stats_state.generated_power_turret_set_stats_bridge_state(shoot_type)


static func continuous_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	return source_specialized_turret_stats_state.continuous_turret_set_stats_state(shoot_type)


static func generated_continuous_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	return source_specialized_turret_stats_state.generated_continuous_turret_set_stats_bridge_state(shoot_type)


static func item_turret_set_stats_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	return source_turret_ammo_stats_bars_state.item_turret_set_stats_state(ammo_types, name_value, max_ammo, ammo_per_shot)


static func generated_item_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	return source_turret_ammo_stats_bars_state.generated_item_turret_set_stats_bridge_state(ammo_types, name_value, max_ammo, ammo_per_shot)


static func generated_item_turret_set_stats_default_bridge_state(max_ammo: float, ammo_per_shot: float) -> Dictionary:
	return source_turret_ammo_stats_bars_state.generated_item_turret_set_stats_default_bridge_state(max_ammo, ammo_per_shot)


static func item_turret_set_bars_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_turret_ammo_stats_bars_state.item_turret_set_bars_state(total_ammo, max_ammo)


static func generated_item_turret_set_bars_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_turret_ammo_stats_bars_state.generated_item_turret_set_bars_bridge_state(total_ammo, max_ammo)


static func generated_item_turret_set_bars_default_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_turret_ammo_stats_bars_state.generated_item_turret_set_bars_default_bridge_state(total_ammo, max_ammo)


static func continuous_liquid_turret_set_stats_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	return source_turret_ammo_stats_bars_state.continuous_liquid_turret_set_stats_state(ammo_types, liquid_consumed)


static func generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	return source_turret_ammo_stats_bars_state.generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types, liquid_consumed)


static func liquid_turret_set_stats_state(ammo_types: Variant, name_value: String) -> Dictionary:
	return source_turret_ammo_stats_bars_state.liquid_turret_set_stats_state(ammo_types, name_value)


static func generated_liquid_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String) -> Dictionary:
	return source_turret_ammo_stats_bars_state.generated_liquid_turret_set_stats_bridge_state(ammo_types, name_value)
