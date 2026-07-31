extends RefCounted
class_name SourcePlacedPowerBatteryRuntimeState

const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")

const SOURCE_PLACED_POWER_BATTERY_BLOCK_FROM_SPRITE_KEY := "block_from_sprite"
const SOURCE_PLACED_POWER_BATTERY_ROLE_FOR_BLOCK_KEY := "role_for_block"
const SOURCE_PLACED_POWER_BATTERY_ROLE_FOR_BLOCK_FALLBACK := "power_graph_role_for_block"
const SOURCE_PLACED_POWER_BATTERY_POWER_NEEDED_KEY := "power_needed"
const SOURCE_PLACED_POWER_BATTERY_POWER_NEEDED_FALLBACK := "placed_power_needed_state"
const SOURCE_PLACED_POWER_BATTERY_POWER_PRODUCED_KEY := "power_produced"
const SOURCE_PLACED_POWER_BATTERY_POWER_PRODUCED_FALLBACK := "placed_power_produced_state"
const SOURCE_PLACED_POWER_BATTERY_BATTERY_STATE_KEY := "battery_state"
const SOURCE_PLACED_POWER_BATTERY_BATTERY_STATE_FALLBACK := "source_power_graph_battery_state"
const SOURCE_PLACED_POWER_BATTERY_CHARGE_BATTERIES_KEY := "charge_batteries"
const SOURCE_PLACED_POWER_BATTERY_CHARGE_BATTERIES_FALLBACK := "source_power_graph_charge_batteries_state"
const SOURCE_PLACED_POWER_BATTERY_USE_BATTERIES_KEY := "use_batteries"
const SOURCE_PLACED_POWER_BATTERY_USE_BATTERIES_FALLBACK := "source_power_graph_use_batteries_state"

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_placed_power_battery_method_names"):
		var names = game.call("_placed_power_battery_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_PLACED_POWER_BATTERY_BLOCK_FROM_SPRITE_KEY: source_texture_runtime_state.block_from_sprite_callback(game),
		SOURCE_PLACED_POWER_BATTERY_ROLE_FOR_BLOCK_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_BATTERY_ROLE_FOR_BLOCK_KEY, SOURCE_PLACED_POWER_BATTERY_ROLE_FOR_BLOCK_FALLBACK)),
		SOURCE_PLACED_POWER_BATTERY_POWER_NEEDED_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_BATTERY_POWER_NEEDED_KEY, SOURCE_PLACED_POWER_BATTERY_POWER_NEEDED_FALLBACK)),
		SOURCE_PLACED_POWER_BATTERY_POWER_PRODUCED_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_BATTERY_POWER_PRODUCED_KEY, SOURCE_PLACED_POWER_BATTERY_POWER_PRODUCED_FALLBACK)),
		SOURCE_PLACED_POWER_BATTERY_BATTERY_STATE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_BATTERY_BATTERY_STATE_KEY, SOURCE_PLACED_POWER_BATTERY_BATTERY_STATE_FALLBACK)),
		SOURCE_PLACED_POWER_BATTERY_CHARGE_BATTERIES_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_BATTERY_CHARGE_BATTERIES_KEY, SOURCE_PLACED_POWER_BATTERY_CHARGE_BATTERIES_FALLBACK)),
		SOURCE_PLACED_POWER_BATTERY_USE_BATTERIES_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_BATTERY_USE_BATTERIES_KEY, SOURCE_PLACED_POWER_BATTERY_USE_BATTERIES_FALLBACK)),
	}

static func game_summary_state(game: Object, tick_rate: float) -> Dictionary:
	return summary_state(game.get("placed_block_origins"), default_callbacks_state(game), {"power_capacity": source_block_defaults.SOURCE_BLOCK_POWER_CAPACITY_DEFAULT}, tick_rate)

static func summary_state(placed_block_origins: Dictionary, callbacks: Dictionary, defaults: Dictionary, tick_rate: float) -> Dictionary:
	var block_from_sprite_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_BATTERY_BLOCK_FROM_SPRITE_KEY, Callable())
	var role_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_BATTERY_ROLE_FOR_BLOCK_KEY, Callable())
	var power_needed_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_BATTERY_POWER_NEEDED_KEY, Callable())
	var power_produced_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_BATTERY_POWER_PRODUCED_KEY, Callable())
	var battery_state_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_BATTERY_BATTERY_STATE_KEY, Callable())
	var charge_batteries_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_BATTERY_CHARGE_BATTERIES_KEY, Callable())
	var use_batteries_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_BATTERY_USE_BATTERIES_KEY, Callable())
	var batteries: Array = []
	for key in placed_block_origins.keys():
		var block = block_from_sprite_fn.call(placed_block_origins.get(key))
		if block == null:
			continue
		var role_state: Dictionary = role_fn.call(block)
		if not bool(role_state.get("add_battery", false)):
			continue
		var properties := source_placed_block_state.properties(block)
		batteries.append({
			"enabled": true,
			"power_status": 0.0,
			"capacity": float(properties.get("powerCapacity", float(defaults.get("power_capacity", 0.0)))),
		})
	var needed: Dictionary = power_needed_fn.call()
	var produced: Dictionary = power_produced_fn.call()
	var charge_excess: float = max(0.0, float(produced.get("power_produced", 0.0)) - float(needed.get("power_needed", 0.0)))
	var charge_state: Dictionary = charge_batteries_fn.call(batteries, charge_excess)
	var charged_batteries: Array = charge_state.get("batteries", batteries)
	var charged_summary: Dictionary = battery_state_fn.call(charged_batteries)
	var use_needed: float = float(charged_summary.get("stored", 0.0))
	var use_state: Dictionary = use_batteries_fn.call(charged_batteries, use_needed)
	var used_batteries: Array = use_state.get("batteries", charged_batteries)
	var used_summary: Dictionary = battery_state_fn.call(used_batteries)
	return {
		"charge_excess": charge_excess,
		"use_needed": use_needed,
		"charged": float(charge_state.get("charged", 0.0)),
		"used": float(use_state.get("used", 0.0)),
		"charged_battery_stored": float(charged_summary.get("stored", 0.0)),
		"used_battery_stored": float(used_summary.get("stored", 0.0)),
		"charged_battery_capacity": float(charged_summary.get("capacity", 0.0)),
		"used_battery_capacity": float(used_summary.get("capacity", 0.0)),
		"battery_count": batteries.size(),
		"charge_state": charge_state,
		"use_state": use_state,
		"tick_rate": tick_rate,
	}
