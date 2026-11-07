extends RefCounted
class_name SourcePlacedPowerDistributionRuntimeState

const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_placed_power_distribution_source_text_state := preload("res://src/game/SourcePlacedPowerDistributionSourceTextState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

const SOURCE_PLACED_POWER_DISTRIBUTION_BLOCK_FROM_SPRITE_KEY := source_placed_power_distribution_source_text_state.SOURCE_PLACED_POWER_DISTRIBUTION_BLOCK_FROM_SPRITE_KEY
const SOURCE_PLACED_POWER_DISTRIBUTION_ROLE_FOR_BLOCK_KEY := source_placed_power_distribution_source_text_state.SOURCE_PLACED_POWER_DISTRIBUTION_ROLE_FOR_BLOCK_KEY
const SOURCE_PLACED_POWER_DISTRIBUTION_ROLE_FOR_BLOCK_FALLBACK := source_placed_power_distribution_source_text_state.SOURCE_PLACED_POWER_DISTRIBUTION_ROLE_FOR_BLOCK_FALLBACK
const SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_KEY := source_placed_power_distribution_source_text_state.SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_KEY
const SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_FALLBACK := source_placed_power_distribution_source_text_state.SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_FALLBACK
const SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_KEY := source_placed_power_distribution_source_text_state.SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_KEY
const SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_FALLBACK := source_placed_power_distribution_source_text_state.SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_FALLBACK
const SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_KEY := source_placed_power_distribution_source_text_state.SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_KEY
const SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_FALLBACK := source_placed_power_distribution_source_text_state.SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_placed_power_distribution_method_names"):
		var names = game.call("_placed_power_distribution_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_PLACED_POWER_DISTRIBUTION_BLOCK_FROM_SPRITE_KEY: source_texture_runtime_state.block_from_sprite_callback(game),
		SOURCE_PLACED_POWER_DISTRIBUTION_ROLE_FOR_BLOCK_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_DISTRIBUTION_ROLE_FOR_BLOCK_KEY, SOURCE_PLACED_POWER_DISTRIBUTION_ROLE_FOR_BLOCK_FALLBACK)),
		SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_KEY, SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_FALLBACK)),
		SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_KEY, SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_FALLBACK)),
		SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_KEY, SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_FALLBACK)),
	}

static func game_tick_rate(_game: Object) -> float:
	return source_time_defaults.TICK_RATE

static func game_summary_state(game: Object) -> Dictionary:
	return summary_state(game.get("placed_block_origins"), default_callbacks_state(game), {
		"power_buffered": source_block_defaults.SOURCE_BLOCK_POWER_BUFFERED_DEFAULT,
		"power_usage": source_block_defaults.SOURCE_BLOCK_POWER_USAGE_DEFAULT,
		"power_capacity": source_block_defaults.SOURCE_BLOCK_POWER_CAPACITY_DEFAULT,
		"power_production": source_block_defaults.SOURCE_BLOCK_POWER_PRODUCTION_DEFAULT,
	}, game_tick_rate(game))

static func summary_state(placed_block_origins: Dictionary, callbacks: Dictionary, defaults: Dictionary, tick_rate: float) -> Dictionary:
	var block_from_sprite_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_DISTRIBUTION_BLOCK_FROM_SPRITE_KEY, Callable())
	var role_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_DISTRIBUTION_ROLE_FOR_BLOCK_KEY, Callable())
	var requested_power_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_KEY, Callable())
	var balance_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_KEY, Callable())
	var distribute_fn: Callable = callbacks.get(SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_KEY, Callable())
	var consumers: Array = []
	var producers: Array = []
	var batteries: Array = []
	for key in placed_block_origins.keys():
		var block = block_from_sprite_fn.call(placed_block_origins.get(key))
		if block == null:
			continue
		var properties := source_placed_block_state.properties(block)
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
