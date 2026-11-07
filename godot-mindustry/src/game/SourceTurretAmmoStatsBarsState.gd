extends RefCounted
class_name SourceTurretAmmoStatsBarsState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_ITEM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_GENERATED_CLASS
const SOURCE_LIQUID_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_LIQUID_TURRET_GENERATED_CLASS
const SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS

static func _item_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_ITEM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _liquid_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_LIQUID_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _continuous_liquid_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

const SOURCE_TURRET_SET_STATS_METHOD := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_METHOD
const SOURCE_TURRET_SET_STATS_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_STATS_SUPER_EXPR
const SOURCE_TURRET_SET_BARS_METHOD := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_METHOD
const SOURCE_TURRET_SET_BARS_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_SET_BARS_SUPER_EXPR
const SOURCE_ITEM_TURRET_SET_STATS_REMOVE_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_SET_STATS_REMOVE_EXPR
const SOURCE_NAMED_AMMO_TYPES_VALUES_EXPR := source_turret_source_text_state.SOURCE_NAMED_AMMO_TYPES_VALUES_EXPR
const SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR := source_turret_source_text_state.SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR
const SOURCE_ITEM_TURRET_SET_STATS_AMMO_CAPACITY_ADD_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_SET_STATS_AMMO_CAPACITY_ADD_EXPR
const SOURCE_ITEM_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_ITEM_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_ITEM_TURRET_SET_STATS_GENERATED_OWNER
const SOURCE_ITEM_TURRET_SET_BARS_ADD_BAR_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_SET_BARS_ADD_BAR_EXPR
const SOURCE_ITEM_TURRET_SET_BARS_FRACTION_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_SET_BARS_FRACTION_EXPR
const SOURCE_ITEM_TURRET_SET_BARS_JAVA_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_SET_BARS_JAVA_METHOD
const SOURCE_ITEM_TURRET_SET_BARS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_ITEM_TURRET_SET_BARS_GENERATED_OWNER
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_MIRROR_COMMENT := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_MIRROR_COMMENT
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_ASSIGN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_ASSIGN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_AMMO_VALUES_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_AMMO_VALUES_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_REPLACE_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_REPLACE_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_GENERATED_OWNER
const SOURCE_LIQUID_TURRET_SET_STATS_JAVA_METHOD := source_turret_source_text_state.SOURCE_LIQUID_TURRET_SET_STATS_JAVA_METHOD
const SOURCE_LIQUID_TURRET_SET_STATS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_LIQUID_TURRET_SET_STATS_GENERATED_OWNER


static func item_turret_set_stats_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	var ammo_capacity_divisor: float = maxf(ammo_per_shot, 1.0)
	var ammo_capacity: float = max_ammo / ammo_capacity_divisor
	var stats_item_capacity_remove_call: Dictionary = {"call": SOURCE_ITEM_TURRET_SET_STATS_REMOVE_EXPR, "stat": "Stat.itemCapacity"}
	var ammo_values_call: Dictionary = {"call": SOURCE_NAMED_AMMO_TYPES_VALUES_EXPR, "ammo_types": ammo_types, "name": name_value}
	var stats_ammo_add_call: Dictionary = {"call": SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	var stats_ammo_capacity_add_call: Dictionary = {"call": SOURCE_ITEM_TURRET_SET_STATS_AMMO_CAPACITY_ADD_EXPR, "stat": "Stat.ammoCapacity", "value": ammo_capacity, "unit": "StatUnit.shots"}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"stats_remove_expr": SOURCE_ITEM_TURRET_SET_STATS_REMOVE_EXPR,
		"stats_ammo_add_expr": SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR,
		"stats_ammo_capacity_add_expr": SOURCE_ITEM_TURRET_SET_STATS_AMMO_CAPACITY_ADD_EXPR,
		"ammo_types": ammo_types,
		"name_value": name_value,
		"max_ammo": max_ammo,
		"ammo_per_shot": ammo_per_shot,
		"ammo_capacity_divisor": ammo_capacity_divisor,
		"ammo_capacity": ammo_capacity,
		"super_set_stats_called": true,
		"stats_item_capacity_removed": true,
		"stats_ammo_added": true,
		"stats_ammo_capacity_added": true,
		"stats_item_capacity_remove_call": stats_item_capacity_remove_call,
		"ammo_values_call": ammo_values_call,
		"stats_ammo_add_call": stats_ammo_add_call,
		"stats_ammo_capacity_add_call": stats_ammo_capacity_add_call,
	}


static func generated_item_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	var result = _item_turret_call(SOURCE_ITEM_TURRET_SET_STATS_JAVA_METHOD, [ammo_types, name_value, max_ammo, ammo_per_shot])
	var canonical = item_turret_set_stats_state(ammo_types, name_value, max_ammo, ammo_per_shot)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_ITEM_TURRET_SET_STATS_STATE,
		"generated_owner": SOURCE_ITEM_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("stats_ammo_capacity_add_call", null) == canonical.get("stats_ammo_capacity_add_call", null) and result.get("stats_ammo_add_call", null) == canonical.get("stats_ammo_add_call", null) and result.get("stats_item_capacity_remove_call", null) == canonical.get("stats_item_capacity_remove_call", null),
	}


static func generated_item_turret_set_stats_default_bridge_state(max_ammo: float, ammo_per_shot: float) -> Dictionary:
	var result = _item_turret_call(SOURCE_ITEM_TURRET_SET_STATS_JAVA_METHOD, [])
	var canonical = item_turret_set_stats_state(null, "", max_ammo, ammo_per_shot)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_ITEM_TURRET_SET_STATS_STATE,
		"generated_owner": SOURCE_ITEM_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["max_ammo", "ammo_per_shot"],
		"max_ammo": max_ammo,
		"ammo_per_shot": ammo_per_shot,
		"ammo_capacity": max_ammo / maxf(ammo_per_shot, 1.0),
		"matches": result.get("stats_ammo_capacity_add_call", null) == canonical.get("stats_ammo_capacity_add_call", null),
	}


static func item_turret_set_bars_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var ammo_bar_fraction: float = total_ammo / max_ammo
	var bar_call: Dictionary = {"call": SOURCE_ITEM_TURRET_SET_BARS_ADD_BAR_EXPR, "name": "ammo", "bar_text": "stat.ammo", "color": "Pal.ammo", "fraction": ammo_bar_fraction}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_SET_BARS_STATE,
		"method": SOURCE_TURRET_SET_BARS_METHOD,
		"override_expr": "@Override",
		"super_set_bars_expr": SOURCE_TURRET_SET_BARS_SUPER_EXPR,
		"add_bar_expr": SOURCE_ITEM_TURRET_SET_BARS_ADD_BAR_EXPR,
		"bar_fraction_expr": SOURCE_ITEM_TURRET_SET_BARS_FRACTION_EXPR,
		"total_ammo": total_ammo,
		"max_ammo": max_ammo,
		"ammo_bar_fraction": ammo_bar_fraction,
		"super_set_bars_called": true,
		"bar_added": true,
		"bar_call": bar_call,
	}

static func _item_turret_bar_call_matches(result: Dictionary, canonical: Dictionary) -> bool:
	var result_bar_call: Dictionary = result.get("bar_call", {}) if result.get("bar_call", {}) is Dictionary else {}
	var canonical_bar_call: Dictionary = canonical.get("bar_call", {}) if canonical.get("bar_call", {}) is Dictionary else {}
	return result_bar_call.get("name", null) == canonical_bar_call.get("name", null) and result_bar_call.get("bar_text", null) == canonical_bar_call.get("bar_text", null) and result_bar_call.get("color", null) == canonical_bar_call.get("color", null) and result_bar_call.get("fraction", null) == canonical_bar_call.get("fraction", null) and result.get("add_bar_expr", null) == canonical.get("add_bar_expr", null) and result.get("ammo_bar_fraction", null) == canonical.get("ammo_bar_fraction", null)


static func generated_item_turret_set_bars_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var result = _item_turret_call(SOURCE_ITEM_TURRET_SET_BARS_JAVA_METHOD, [total_ammo, max_ammo])
	var canonical = item_turret_set_bars_state(total_ammo, max_ammo)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_ITEM_TURRET_SET_BARS_STATE,
		"generated_owner": SOURCE_ITEM_TURRET_SET_BARS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": _item_turret_bar_call_matches(result, canonical),
	}


static func generated_item_turret_set_bars_default_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var result = _item_turret_call(SOURCE_ITEM_TURRET_SET_BARS_JAVA_METHOD, [total_ammo])
	var canonical = item_turret_set_bars_state(total_ammo, max_ammo)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_TURRET_STATS_BARS_STATE_ITEM_TURRET_SET_BARS_STATE,
		"generated_owner": SOURCE_ITEM_TURRET_SET_BARS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["max_ammo"],
		"max_ammo": max_ammo,
		"ammo_bar_fraction": total_ammo / max_ammo,
		"matches": _item_turret_bar_call_matches(result, canonical),
	}


static func continuous_liquid_turret_set_stats_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	var stat_liquid_consumed_updates: Array = []
	for entry in ammo_types:
		var entry_dict: Dictionary = entry if entry is Dictionary else {}
		stat_liquid_consumed_updates.append({"call": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_ASSIGN_EXPR, "liquid": entry_dict.get("liquid", null), "bullet": entry_dict.get("bullet", null), "stat_liquid_consumed": liquid_consumed})
	var ammo_values_call: Dictionary = {"call": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_AMMO_VALUES_EXPR, "ammo_types": ammo_types}
	var stats_replace_call: Dictionary = {"call": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_REPLACE_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"mirror_comment": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_MIRROR_COMMENT,
		"stat_liquid_consumed_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STAT_LIQUID_CONSUMED_EXPR,
		"stats_replace_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_REPLACE_EXPR,
		"ammo_types": ammo_types,
		"liquid_consumed": liquid_consumed,
		"super_set_stats_called": true,
		"stat_liquid_consumed_updates": stat_liquid_consumed_updates,
		"stats_replace_called": true,
		"ammo_values_call": ammo_values_call,
		"stats_replace_call": stats_replace_call,
	}


static func generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	var result = _continuous_liquid_turret_call(SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_JAVA_METHOD, [ammo_types, liquid_consumed])
	var canonical = continuous_liquid_turret_set_stats_state(ammo_types, liquid_consumed)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_STATE,
		"generated_owner": SOURCE_CONTINUOUS_LIQUID_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("stat_liquid_consumed_updates", []) == canonical.get("stat_liquid_consumed_updates", []) and result.get("stats_replace_call", {}) == canonical.get("stats_replace_call", {}),
	}


static func liquid_turret_set_stats_state(ammo_types: Variant, name_value: String) -> Dictionary:
	var ammo_values_call: Dictionary = {"call": SOURCE_NAMED_AMMO_TYPES_VALUES_EXPR, "ammo_types": ammo_types, "name": name_value}
	var stats_add_call: Dictionary = {"call": SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR, "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_LIQUID_TURRET_SET_STATS_STATE,
		"method": SOURCE_TURRET_SET_STATS_METHOD,
		"override_expr": "@Override",
		"super_set_stats_expr": SOURCE_TURRET_SET_STATS_SUPER_EXPR,
		"stats_add_expr": SOURCE_NAMED_AMMO_TYPES_STATS_ADD_EXPR,
		"ammo_types": ammo_types,
		"name_value": name_value,
		"super_set_stats_called": true,
		"stats_added": true,
		"ammo_values_call": ammo_values_call,
		"stats_add_call": stats_add_call,
	}


static func generated_liquid_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String) -> Dictionary:
	var result = _liquid_turret_call(SOURCE_LIQUID_TURRET_SET_STATS_JAVA_METHOD, [ammo_types, name_value])
	var canonical = liquid_turret_set_stats_state(ammo_types, name_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_LIQUID_TURRET_SET_STATS_STATE,
		"generated_owner": SOURCE_LIQUID_TURRET_SET_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("stats_add_call", {}) == canonical.get("stats_add_call", {}),
	}
