extends Node

const SourcePlacedPowerDistributionRuntimeState := preload("res://src/game/SourcePlacedPowerDistributionRuntimeState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

class FakeBlock:
	extends RefCounted

	var role := ""
	var properties: Dictionary = {}

	func _init(next_role: String, next_properties: Dictionary) -> void:
		role = next_role
		properties = next_properties

var fake_blocks := {
	"consumer": FakeBlock.new("consumer", {"powerUsage": 4.0, "powerCapacity": 20.0, "powerBuffered": false}),
	"producer": FakeBlock.new("producer", {"powerProduction": 6.0}),
	"battery": FakeBlock.new("battery", {"powerCapacity": 30.0}),
}

func _block_from_sprite(sprite_key) -> Variant:
	return fake_blocks.get(str(sprite_key), null)

func _role_for_block(block) -> Dictionary:
	return {
		"add_consumer": block.role == "consumer",
		"add_producer": block.role == "producer",
		"add_battery": block.role == "battery",
	}

func _requested_power(_buffered: bool, usage: float, _capacity: float, _power_status: float, should_consume: bool) -> Dictionary:
	return {"requested_power": usage if should_consume else 0.0}

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

func _ready() -> void:
	var callbacks := {
		"block_from_sprite": Callable(self, "_block_from_sprite"),
		"role_for_block": Callable(self, "_role_for_block"),
		"requested_power": Callable(self, "_requested_power"),
		"balance": Callable(self, "_balance"),
		"distribute": Callable(self, "_distribute"),
	}
	var defaults := {
		"power_buffered": false,
		"power_usage": 0.0,
		"power_capacity": 0.0,
		"power_production": 0.0,
	}
	var placed_block_origins := {"c": "consumer", "p": "producer", "b": "battery"}
	var summary := SourcePlacedPowerDistributionRuntimeState.summary_state(placed_block_origins, callbacks, defaults, 2.0)
	var registry := SourceSsotCatalog.canonical_headquarter_registry_state()
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
	await get_tree().create_timer(10.0).timeout
	get_tree().quit(0)
