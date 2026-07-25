extends RefCounted
class_name SourcePlacedPowerBatteryRuntimeState

const SourcePlacedBlockState := preload("res://src/game/SourcePlacedBlockState.gd")

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"block_from_sprite": Callable(game, "block_from_sprite"),
		"role_for_block": Callable(game, "power_graph_role_for_block"),
		"power_needed": Callable(game, "placed_power_needed_state"),
		"power_produced": Callable(game, "placed_power_produced_state"),
		"battery_state": Callable(game, "source_power_graph_battery_state"),
		"charge_batteries": Callable(game, "source_power_graph_charge_batteries_state"),
		"use_batteries": Callable(game, "source_power_graph_use_batteries_state"),
	}

static func summary_state(placed_block_origins: Dictionary, callbacks: Dictionary, defaults: Dictionary, tick_rate: float) -> Dictionary:
	var block_from_sprite_fn: Callable = callbacks.get("block_from_sprite", Callable())
	var role_fn: Callable = callbacks.get("role_for_block", Callable())
	var power_needed_fn: Callable = callbacks.get("power_needed", Callable())
	var power_produced_fn: Callable = callbacks.get("power_produced", Callable())
	var battery_state_fn: Callable = callbacks.get("battery_state", Callable())
	var charge_batteries_fn: Callable = callbacks.get("charge_batteries", Callable())
	var use_batteries_fn: Callable = callbacks.get("use_batteries", Callable())
	var batteries: Array = []
	for key in placed_block_origins.keys():
		var block = block_from_sprite_fn.call(placed_block_origins.get(key))
		if block == null:
			continue
		var role_state: Dictionary = role_fn.call(block)
		if not bool(role_state.get("add_battery", false)):
			continue
		var properties := SourcePlacedBlockState.properties(block)
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
