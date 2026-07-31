extends Node

const source_placed_power_distribution_runtime_state := preload("res://src/game/SourcePlacedPowerDistributionRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

class FakeBlock:
	extends RefCounted

	var role := ""
	var properties: Dictionary = {}

	func _init(next_role: String, next_properties: Dictionary) -> void:
		role = next_role
		properties = next_properties

class FakeSprite:
	extends RefCounted

	func _init(block_id: String) -> void:
		set_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, block_id)

class FakeCatalog:
	extends RefCounted

	var blocks: Dictionary = {}

	func _init(next_blocks: Dictionary) -> void:
		blocks = next_blocks

	func get_by_id(block_id: String):
		return blocks.get(block_id, null)

var fake_blocks := {
	"consumer": FakeBlock.new("consumer", {"powerUsage": 4.0, "powerCapacity": 20.0, "powerBuffered": false}),
	"producer": FakeBlock.new("producer", {"powerProduction": 6.0}),
	"battery": FakeBlock.new("battery", {"powerCapacity": 30.0}),
}
var content_catalog = null
var placed_block_origins := {}

func _block_from_sprite(sprite) -> Variant:
	if not is_instance_valid(sprite):
		return null
	return fake_blocks.get(str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")), null)

func block_from_sprite(sprite_key) -> Variant:
	return _block_from_sprite(sprite_key)

func _role_for_block(block) -> Dictionary:
	return {
		"add_consumer": block.role == "consumer",
		"add_producer": block.role == "producer",
		"add_battery": block.role == "battery",
	}

func power_graph_role_for_block(block) -> Dictionary:
	return _role_for_block(block)

func _requested_power(_buffered: bool, usage: float, _capacity: float, _power_status: float, should_consume: bool) -> Dictionary:
	return {"requested_power": usage if should_consume else 0.0}

func proof_consume_power_requested_power_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	return _requested_power(buffered, usage, capacity, power_status, should_consume)

func _balance(consumers: Array, producers: Array, batteries: Array, _last: float, tick_rate: float) -> Dictionary:
	var power_needed := 0.0
	for consumer in consumers:
		if typeof(consumer) == TYPE_DICTIONARY:
			power_needed += float(consumer.get("requested_power", 0.0))
	var power_produced := 0.0
	for producer in producers:
		if typeof(producer) == TYPE_DICTIONARY:
			power_produced += float(producer.get("power_production", 0.0)) * tick_rate
	return {
		"power_needed": power_needed,
		"power_produced": power_produced,
		"last_power_produced": power_produced,
		"last_power_stored": float(batteries.size()),
	}

func proof_power_graph_update_balance_state(consumers: Array, producers: Array, batteries: Array, last_power_produced: float, tick_rate: float) -> Dictionary:
	return _balance(consumers, producers, batteries, last_power_produced, tick_rate)

func _distribute(consumers: Array, _producers: Array, _batteries: Array, _needed: float, _produced: float, _last_produced: float, _last_stored: float) -> Dictionary:
	var distributed_consumers := []
	for consumer in consumers:
		var next_consumer: Dictionary = consumer.duplicate(true) if typeof(consumer) == TYPE_DICTIONARY else {}
		next_consumer["power_status"] = 0.75
		distributed_consumers.append(next_consumer)
	return {
		"consumers": distributed_consumers,
		"coverage": 0.75,
		"power_battery_used": 1.0,
		"power_battery_charged": 2.0,
	}

func proof_power_graph_update_battery_distribute_state(consumers: Array, producers: Array, batteries: Array, power_needed: float, power_produced: float, last_power_produced: float, last_power_stored: float) -> Dictionary:
	return _distribute(consumers, producers, batteries, power_needed, power_produced, last_power_produced, last_power_stored)

func _ready() -> void:
	content_catalog = FakeCatalog.new(fake_blocks)
	placed_block_origins = {"c": FakeSprite.new("consumer"), "p": FakeSprite.new("producer"), "b": FakeSprite.new("battery")}
	var callbacks := {
		source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_BLOCK_FROM_SPRITE_KEY: Callable(self, "_block_from_sprite"),
		source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_ROLE_FOR_BLOCK_KEY: Callable(self, "_role_for_block"),
		source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_KEY: Callable(self, "_requested_power"),
		source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_KEY: Callable(self, "_balance"),
		source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_KEY: Callable(self, "_distribute"),
	}
	var defaults := {
		"power_buffered": false,
		"power_usage": 0.0,
		"power_capacity": 0.0,
		"power_production": 0.0,
	}
	var summary := source_placed_power_distribution_runtime_state.summary_state(placed_block_origins, callbacks, defaults, 2.0)
	var game_summary := source_placed_power_distribution_runtime_state.game_summary_state(self, 2.0)
	var override_callbacks := source_placed_power_distribution_runtime_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_KEY, Callable()) == Callable(self, "proof_consume_power_requested_power_state") \
		and override_callbacks.get(source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_KEY, Callable()) == Callable(self, "proof_power_graph_update_balance_state") \
		and override_callbacks.get(source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_KEY, Callable()) == Callable(self, "proof_power_graph_update_battery_distribute_state")
	var registry := source_ssot_catalog.canonical_headquarter_registry_state()
	var summary_matches: bool = int(summary.get("consumer_count", 0)) == 1 \
		and int(summary.get("producer_count", 0)) == 1 \
		and int(summary.get("battery_count", 0)) == 1 \
		and float(summary.get("power_needed", 0.0)) == 4.0 \
		and float(summary.get("power_produced", 0.0)) == 12.0 \
		and float(summary.get("coverage", 0.0)) == 0.75 \
		and float(summary.get("first_consumer_power_status", 0.0)) == 0.75 \
		and float(summary.get("power_battery_used", 0.0)) == 1.0 \
		and float(summary.get("power_battery_charged", 0.0)) == 2.0
	var proof := {
		"module": "SourcePlacedPowerDistributionRuntimeState",
		"summary_matches": summary_matches,
		"game_summary_matches": game_summary == summary,
		"override_callbacks_match": override_callbacks_match,
		"consumer_count": int(summary.get("consumer_count", 0)),
		"producer_count": int(summary.get("producer_count", 0)),
		"battery_count": int(summary.get("battery_count", 0)),
		"power_needed": float(summary.get("power_needed", 0.0)),
		"power_produced": float(summary.get("power_produced", 0.0)),
		"coverage": float(summary.get("coverage", 0.0)),
		"one_headquarter_per_ssot": bool(registry.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry.get("errors", []).is_empty()),
	}
	print("PLACED_POWER_DISTRIBUTION_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _placed_power_distribution_method_names() -> Dictionary:
	return {
		source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_REQUESTED_POWER_KEY: "proof_consume_power_requested_power_state",
		source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_BALANCE_KEY: "proof_power_graph_update_balance_state",
		source_placed_power_distribution_runtime_state.SOURCE_PLACED_POWER_DISTRIBUTION_DISTRIBUTE_KEY: "proof_power_graph_update_battery_distribute_state",
	}
