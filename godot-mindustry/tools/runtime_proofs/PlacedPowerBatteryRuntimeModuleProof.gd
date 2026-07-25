extends Node

const SourcePlacedPowerBatteryRuntimeState := preload("res://src/game/SourcePlacedPowerBatteryRuntimeState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

class FakeBlock:
	extends RefCounted

	var role := ""
	var properties: Dictionary = {}

	func _init(next_role: String, next_properties: Dictionary) -> void:
		role = next_role
		properties = next_properties

var fake_blocks := {
	"battery": FakeBlock.new("battery", {"powerCapacity": 10.0}),
}

func block_from_sprite(sprite_key) -> Variant:
	return fake_blocks.get(str(sprite_key), null)

func power_graph_role_for_block(block) -> Dictionary:
	return {
		"add_battery": block.role == "battery",
	}

func placed_power_needed_state() -> Dictionary:
	return {"power_needed": 4.0}

func placed_power_produced_state() -> Dictionary:
	return {"power_produced": 9.0}

func _source_power_graph_battery_state(batteries: Array) -> Dictionary:
	var stored := 0.0
	var capacity := 0.0
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		var next_capacity := float(battery.get("capacity", 0.0))
		capacity += next_capacity
		stored += float(battery.get("power_status", 0.0)) * next_capacity
	return {
		"stored": stored,
		"capacity": capacity,
	}

func _source_power_graph_charge_batteries_state(batteries: Array, charge_excess: float) -> Dictionary:
	var charged_batteries := []
	for battery in batteries:
		var next_battery: Dictionary = battery.duplicate(true) if typeof(battery) == TYPE_DICTIONARY else {}
		next_battery["power_status"] = 0.5
		charged_batteries.append(next_battery)
	return {
		"charged": charge_excess,
		"batteries": charged_batteries,
	}

func _source_power_graph_use_batteries_state(batteries: Array, use_needed: float) -> Dictionary:
	var used_batteries := []
	for battery in batteries:
		var next_battery: Dictionary = battery.duplicate(true) if typeof(battery) == TYPE_DICTIONARY else {}
		next_battery["power_status"] = 0.0
		used_batteries.append(next_battery)
	return {
		"used": use_needed,
		"batteries": used_batteries,
	}

func _ready() -> void:
	var callbacks := {
		"block_from_sprite": Callable(self, "block_from_sprite"),
		"role_for_block": Callable(self, "power_graph_role_for_block"),
		"power_needed": Callable(self, "placed_power_needed_state"),
		"power_produced": Callable(self, "placed_power_produced_state"),
		"battery_state": Callable(self, "_source_power_graph_battery_state"),
		"charge_batteries": Callable(self, "_source_power_graph_charge_batteries_state"),
		"use_batteries": Callable(self, "_source_power_graph_use_batteries_state"),
	}
	var defaults := {
		"power_capacity": 0.0,
	}
	var summary := SourcePlacedPowerBatteryRuntimeState.summary_state({"b": "battery"}, callbacks, defaults, 2.0)
	var registry := SourceSsotCatalog.canonical_headquarter_registry_state()
	var summary_matches: bool = int(summary.get("battery_count", 0)) == 1 \
		and float(summary.get("charge_excess", 0.0)) == 5.0 \
		and float(summary.get("use_needed", 0.0)) == 5.0 \
		and float(summary.get("charged", 0.0)) == 5.0 \
		and float(summary.get("used", 0.0)) == 5.0 \
		and float(summary.get("charged_battery_stored", 0.0)) == 5.0 \
		and float(summary.get("used_battery_stored", 0.0)) == 0.0 \
		and float(summary.get("charged_battery_capacity", 0.0)) == 10.0 \
		and float(summary.get("used_battery_capacity", 0.0)) == 10.0
	var proof := {
		"module": "SourcePlacedPowerBatteryRuntimeState",
		"summary_matches": summary_matches,
		"battery_count": int(summary.get("battery_count", 0)),
		"charge_excess": float(summary.get("charge_excess", 0.0)),
		"use_needed": float(summary.get("use_needed", 0.0)),
		"charged": float(summary.get("charged", 0.0)),
		"used": float(summary.get("used", 0.0)),
		"one_headquarter_per_ssot": bool(registry.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry.get("errors", []).is_empty()),
	}
	print("PLACED_POWER_BATTERY_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(10.0).timeout
	get_tree().quit(0)
