extends RefCounted
class_name SourceSpecializedTurretStatsState

const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS
const SOURCE_RELOAD_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_RELOAD_TURRET_GENERATED_CLASS
const SOURCE_POINT_DEFENSE_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_POINT_DEFENSE_TURRET_GENERATED_CLASS
const SOURCE_POWER_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_POWER_TURRET_GENERATED_CLASS
const SOURCE_CONTINUOUS_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_CONTINUOUS_TURRET_GENERATED_CLASS
const SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_GENERATED_OWNER
const SOURCE_RELOAD_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_RELOAD_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_RELOAD_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_RELOAD_TURRET_SET_STATS_GENERATED_OWNER
const SOURCE_POINT_DEFENSE_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_POINT_DEFENSE_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_POINT_DEFENSE_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_POINT_DEFENSE_TURRET_SET_STATS_GENERATED_OWNER
const SOURCE_POWER_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_POWER_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_POWER_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_POWER_TURRET_SET_STATS_GENERATED_OWNER
const SOURCE_CONTINUOUS_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_CONTINUOUS_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_CONTINUOUS_TURRET_SET_STATS_GENERATED_OWNER

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _reload_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_RELOAD_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _point_defense_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_POINT_DEFENSE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _power_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_POWER_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _continuous_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_CONTINUOUS_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

const SOURCE_TURRET_SET_STATS_METHOD := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_METHOD
const SOURCE_TURRET_SET_STATS_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_SUPER_EXPR
const SOURCE_TURRET_SET_STATS_TARGETS_AIR_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_TARGETS_AIR_EXPR
const SOURCE_TURRET_SET_STATS_TARGETS_GROUND_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_TARGETS_GROUND_EXPR
const SOURCE_RELOAD_TURRET_SET_STATS_COOLANT_GATE := source_turret_source_text_state.SOURCE_RELOAD_TURRET_SET_STATS_COOLANT_GATE
const SOURCE_RELOAD_TURRET_SET_STATS_BOOSTER_EXPR := source_turret_source_text_state.SOURCE_RELOAD_TURRET_SET_STATS_BOOSTER_EXPR
const SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_EXPR := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_EXPR
const SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_ADD_EXPR := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_ADD_EXPR
const SOURCE_POINT_DEFENSE_TURRET_SET_STATS_RELOAD_EXPR := source_turret_source_text_state.SOURCE_POINT_DEFENSE_TURRET_SET_STATS_RELOAD_EXPR
const SOURCE_POINT_DEFENSE_TURRET_SET_STATS_DAMAGE_EXPR := source_turret_source_text_state.SOURCE_POINT_DEFENSE_TURRET_SET_STATS_DAMAGE_EXPR
const SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR := source_turret_source_text_state.SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR
const SOURCE_POWER_TURRET_SET_STATS_VALUES_EXPR := source_turret_source_text_state.SOURCE_POWER_TURRET_SET_STATS_VALUES_EXPR
const SOURCE_POWER_TURRET_SET_STATS_OBJECT_MAP_EXPR := source_turret_source_text_state.SOURCE_POWER_TURRET_SET_STATS_OBJECT_MAP_EXPR
const SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_RELOAD_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_RELOAD_EXPR
const SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_INACCURACY_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_INACCURACY_EXPR

static func tractor_beam_turret_set_stats_state(target_air: bool, target_ground: bool, damage: float, tick_rate: float) -> Dictionary:
	var damage_per_second: float = damage * tick_rate
	var damage_stat_added: bool = damage > 0.0
	var damage_stat_call := {
		"call": SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_ADD_EXPR,
		"value": damage_per_second,
		"added": damage_stat_added,
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"targets_air_stat_expr": SOURCE_TURRET_SET_STATS_TARGETS_AIR_EXPR,
		"targets_ground_stat_expr": SOURCE_TURRET_SET_STATS_TARGETS_GROUND_EXPR,
		"damage_stat_expr": SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_DAMAGE_EXPR,
		"targets_air_stat_call": {"value": target_air},
		"targets_ground_stat_call": {"value": target_ground},
		"damage_stat_added": damage_stat_added,
		"damage_stat_call": damage_stat_call,
	}

static func generated_tractor_beam_turret_set_stats_bridge_state(target_air: bool, target_ground: bool, damage: float, tick_rate: float) -> Dictionary:
	var result = _tractor_beam_turret_call(SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_JAVA_METHOD, [target_air, target_ground, damage, tick_rate])
	var canonical = tractor_beam_turret_set_stats_state(target_air, target_ground, damage, tick_rate)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_TRACTOR_BEAM_TURRET_SET_STATS_STATE,
		"generated_owner": SOURCE_TRACTOR_BEAM_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("targets_air_stat_call", null) == canonical.get("targets_air_stat_call", null) and result.get("targets_ground_stat_call", null) == canonical.get("targets_ground_stat_call", null) and result.get("damage_stat_added", null) == canonical.get("damage_stat_added", null) and result.get("damage_stat_call", null) == canonical.get("damage_stat_call", null),
	}

static func reload_turret_set_stats_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	var booster_replace_called: bool = coolant_present
	var booster_replace_call: Dictionary = {}
	if booster_replace_called:
		booster_replace_call = {"call": SOURCE_RELOAD_TURRET_SET_STATS_BOOSTER_EXPR, "stat": "Stat.booster", "reload": reload_value, "coolant_amount": coolant_amount, "coolant_multiplier": coolant_multiplier, "base": true, "consumes": "coolant::consumes"}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_RELOAD_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"coolant_gate": SOURCE_RELOAD_TURRET_SET_STATS_COOLANT_GATE,
		"booster_replace_expr": SOURCE_RELOAD_TURRET_SET_STATS_BOOSTER_EXPR,
		"coolant_present": coolant_present,
		"reload_value": reload_value,
		"coolant_amount": coolant_amount,
		"coolant_multiplier": coolant_multiplier,
		"super_set_stats_called": true,
		"booster_replace_called": booster_replace_called,
		"booster_replace_call": booster_replace_call,
	}

static func generated_reload_turret_set_stats_bridge_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	var result = _reload_turret_call(SOURCE_RELOAD_TURRET_SET_STATS_JAVA_METHOD, [coolant_present, reload_value, coolant_amount, coolant_multiplier])
	var canonical = reload_turret_set_stats_state(coolant_present, reload_value, coolant_amount, coolant_multiplier)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_RELOAD_TURRET_SET_STATS_STATE,
		"generated_owner": SOURCE_RELOAD_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("booster_replace_called", null) == canonical.get("booster_replace_called", null) and result.get("booster_replace_call", null) == canonical.get("booster_replace_call", null),
	}

static func point_defense_set_stats_state(bullet_damage: float, reload_value: float, tick_rate: float) -> Dictionary:
	var reload_stat_rate: float = tick_rate / reload_value
	var reload_stat_call: Dictionary = {"call": SOURCE_POINT_DEFENSE_TURRET_SET_STATS_RELOAD_EXPR, "stat": "Stat.reload", "value": reload_stat_rate, "unit": "StatUnit.perSecond"}
	var damage_stat_call: Dictionary = {"call": SOURCE_POINT_DEFENSE_TURRET_SET_STATS_DAMAGE_EXPR, "stat": "Stat.damage", "value": bullet_damage, "unit": "StatUnit.none"}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"reload_stat_expr": SOURCE_POINT_DEFENSE_TURRET_SET_STATS_RELOAD_EXPR,
		"damage_stat_expr": SOURCE_POINT_DEFENSE_TURRET_SET_STATS_DAMAGE_EXPR,
		"bullet_damage": bullet_damage,
		"reload": reload_value,
		"reload_stat_rate": reload_stat_rate,
		"super_set_stats_called": true,
		"reload_stat_call": reload_stat_call,
		"damage_stat_call": damage_stat_call,
	}

static func generated_point_defense_turret_set_stats_default_bridge_state(bullet_damage: float, reload_value: float) -> Dictionary:
	var result = _point_defense_turret_call(SOURCE_POINT_DEFENSE_TURRET_SET_STATS_JAVA_METHOD, [])
	var canonical = point_defense_set_stats_state(bullet_damage, reload_value, source_time_defaults.TICK_RATE)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_POINT_DEFENSE_SET_STATS_STATE,
		"generated_owner": SOURCE_POINT_DEFENSE_TURRET_SET_STATS_GENERATED_OWNER,
		"defaulted_args": ["bullet_damage", "reload"],
		"bullet_damage": bullet_damage,
		"reload": reload_value,
		"result": result,
		"canonical": canonical,
		"matches": result.get("reload_stat_call", null) == canonical.get("reload_stat_call", null) and result.get("damage_stat_call", null) == canonical.get("damage_stat_call", null),
	}

static func power_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	var object_map_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_OBJECT_MAP_EXPR, "owner": "this", "shoot_type": shoot_type}
	var ammo_values_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_VALUES_EXPR, "object_map_call": object_map_call}
	var stats_add_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"stats_add_expr": SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR,
		"shoot_type": shoot_type,
		"super_set_stats_called": true,
		"stats_add_called": true,
		"object_map_call": object_map_call,
		"ammo_values_call": ammo_values_call,
		"stats_add_call": stats_add_call,
	}

static func generated_power_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	var result = _power_turret_call(SOURCE_POWER_TURRET_SET_STATS_JAVA_METHOD, [shoot_type])
	var canonical = power_turret_set_stats_state(shoot_type)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_POWER_TURRET_SET_STATS_STATE,
		"generated_owner": SOURCE_POWER_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("stats_add_call", null) == canonical.get("stats_add_call", null) and result.get("shoot_type", null) == canonical.get("shoot_type", null),
	}

static func continuous_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	var object_map_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_OBJECT_MAP_EXPR, "this": "ContinuousTurret", "shoot_type": shoot_type}
	var ammo_values_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_VALUES_EXPR, "object_map_call": object_map_call}
	var stats_add_call: Dictionary = {"call": SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"stats_add_expr": SOURCE_POWER_TURRET_SET_STATS_ADD_EXPR,
		"remove_reload_expr": SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_RELOAD_EXPR,
		"remove_inaccuracy_expr": SOURCE_CONTINUOUS_TURRET_SET_STATS_REMOVE_INACCURACY_EXPR,
		"shoot_type": shoot_type,
		"super_set_stats_called": true,
		"stats_add_called": true,
		"remove_reload_called": true,
		"remove_inaccuracy_called": true,
		"object_map_call": object_map_call,
		"ammo_values_call": ammo_values_call,
		"stats_add_call": stats_add_call,
	}

static func generated_continuous_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	var result = _continuous_turret_call(SOURCE_CONTINUOUS_TURRET_SET_STATS_JAVA_METHOD, [shoot_type])
	var canonical = continuous_turret_set_stats_state(shoot_type)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_CONTINUOUS_TURRET_SET_STATS_STATE,
		"generated_owner": SOURCE_CONTINUOUS_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("stats_add_call", null) == canonical.get("stats_add_call", null) and result.get("remove_reload_called", null) == canonical.get("remove_reload_called", null),
	}
