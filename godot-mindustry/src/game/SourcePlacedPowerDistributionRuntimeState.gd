extends RefCounted
class_name SourcePlacedPowerDistributionRuntimeState

const SourcePlacedBlockState := preload("res://src/game/SourcePlacedBlockState.gd")

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"block_from_sprite": Callable(game, "block_from_sprite"),
		"role_for_block": Callable(game, "power_graph_role_for_block"),
		"requested_power": Callable(game, "source_consume_power_requested_power_state"),
		"balance": Callable(game, "source_power_graph_update_balance_state"),
		"distribute": Callable(game, "source_power_graph_update_battery_distribute_state"),
	}

static func summary_state(placed_block_origins: Dictionary, callbacks: Dictionary, defaults: Dictionary, tick_rate: float) -> Dictionary:
	var block_from_sprite_fn: Callable = callbacks.get("block_from_sprite", Callable())
	var role_fn: Callable = callbacks.get("role_for_block", Callable())
	var requested_power_fn: Callable = callbacks.get("requested_power", Callable())
	var balance_fn: Callable = callbacks.get("balance", Callable())
	var distribute_fn: Callable = callbacks.get("distribute", Callable())
	var consumers: Array = []
	var producers: Array = []
	var batteries: Array = []
	for key in placed_block_origins.keys():
		var block = block_from_sprite_fn.call(placed_block_origins.get(key))
		if block == null:
			continue
		var properties := SourcePlacedBlockState.properties(block)
		var role_state: Dictionary = role_fn.call(block)
		if bool(role_state.get("add_consumer", false)):
			var consumer_state := {
				"shouldConsumePower": true,
				"buffered": bool(properties.get("powerBuffered", bool(defaults.get("power_buffered", false)))),
				"usage": float(properties.get("powerUsage", float(defaults.get("power_usage", 0.0)))),
				"capacity": float(properties.get("powerCapacity", float(defaults.get("power_capacity", 0.0)))),
				"power_status": 0.0,
				"should_consume": true,
				"delta": tick_rate,
			}
			var requested: Dictionary = requested_power_fn.call(
				bool(consumer_state.get("buffered", false)),
				float(consumer_state.get("usage", 0.0)),
				float(consumer_state.get("capacity", 0.0)),
				float(consumer_state.get("power_status", 0.0)),
				bool(consumer_state.get("should_consume", false))
			)
			consumer_state["requested_power"] = float(requested.get("requested_power", 0.0))
			consumers.append(consumer_state)
		if bool(role_state.get("add_producer", false)):
			producers.append({
				"power_production": float(properties.get("powerProduction", float(defaults.get("power_production", 0.0)))),
				"delta": tick_rate,
			})
		if bool(role_state.get("add_battery", false)):
			batteries.append({
				"enabled": true,
				"power_status": 0.0,
				"capacity": float(properties.get("powerCapacity", float(defaults.get("power_capacity", 0.0)))),
			})
	var balance: Dictionary = balance_fn.call(consumers, producers, batteries, 0.0, tick_rate)
	var distribution: Dictionary = distribute_fn.call(
		consumers,
		producers,
		batteries,
		float(balance.get("power_needed", 0.0)),
		float(balance.get("power_produced", 0.0)),
		float(balance.get("last_power_produced", 0.0)),
		float(balance.get("last_power_stored", 0.0))
	)
	var distributed_consumers: Array = distribution.get("consumers", [])
	var first_consumer_power_status := 0.0
	if not distributed_consumers.is_empty() and typeof(distributed_consumers[0]) == TYPE_DICTIONARY:
		first_consumer_power_status = float(distributed_consumers[0].get("power_status", 0.0))
	return {
		"balance": balance,
		"distribution": distribution,
		"consumer_count": consumers.size(),
		"producer_count": producers.size(),
		"battery_count": batteries.size(),
		"power_needed": float(balance.get("power_needed", 0.0)),
		"power_produced": float(balance.get("power_produced", 0.0)),
		"coverage": float(distribution.get("coverage", 0.0)),
		"first_consumer_power_status": first_consumer_power_status,
		"power_battery_used": float(distribution.get("power_battery_used", 0.0)),
		"power_battery_charged": float(distribution.get("power_battery_charged", 0.0)),
	}
