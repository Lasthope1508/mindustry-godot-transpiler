extends Node

const source_placed_power_battery_runtime_state := preload("res://src/game/SourcePlacedPowerBatteryRuntimeState.gd")
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
	"battery": FakeBlock.new("battery", {"powerCapacity": 10.0}),
}
var content_catalog = null
var placed_block_origins := {}

func block_from_sprite(sprite) -> Variant:
	if not is_instance_valid(sprite):
		return null
	return fake_blocks.get(str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")), null)

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

func proof_power_graph_battery_state(batteries: Array) -> Dictionary:
	return _source_power_graph_battery_state(batteries)

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

func proof_power_graph_charge_batteries_state(batteries: Array, charge_excess: float) -> Dictionary:
	return _source_power_graph_charge_batteries_state(batteries, charge_excess)

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

func proof_power_graph_use_batteries_state(batteries: Array, use_needed: float) -> Dictionary:
	return _source_power_graph_use_batteries_state(batteries, use_needed)

func _ready() -> void:
	content_catalog = FakeCatalog.new(fake_blocks)
	placed_block_origins = {"b": FakeSprite.new("battery")}
	var callbacks := {
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_BLOCK_FROM_SPRITE_KEY: Callable(self, "block_from_sprite"),
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_ROLE_FOR_BLOCK_KEY: Callable(self, "power_graph_role_for_block"),
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_POWER_NEEDED_KEY: Callable(self, "placed_power_needed_state"),
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_POWER_PRODUCED_KEY: Callable(self, "placed_power_produced_state"),
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_BATTERY_STATE_KEY: Callable(self, "_source_power_graph_battery_state"),
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_CHARGE_BATTERIES_KEY: Callable(self, "_source_power_graph_charge_batteries_state"),
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_USE_BATTERIES_KEY: Callable(self, "_source_power_graph_use_batteries_state"),
	}
	var defaults := {
		"power_capacity": 0.0,
	}
	var summary := source_placed_power_battery_runtime_state.summary_state(placed_block_origins, callbacks, defaults, 2.0)
	var game_summary := source_placed_power_battery_runtime_state.game_summary_state(self, 2.0)
	var override_callbacks := source_placed_power_battery_runtime_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_BATTERY_STATE_KEY, Callable()) == Callable(self, "proof_power_graph_battery_state") \
		and override_callbacks.get(source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_CHARGE_BATTERIES_KEY, Callable()) == Callable(self, "proof_power_graph_charge_batteries_state") \
		and override_callbacks.get(source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_USE_BATTERIES_KEY, Callable()) == Callable(self, "proof_power_graph_use_batteries_state")
	var registry := source_ssot_catalog.canonical_headquarter_registry_state()
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
		"game_summary_matches": game_summary == summary,
		"override_callbacks_match": override_callbacks_match,
		"battery_count": int(summary.get("battery_count", 0)),
		"charge_excess": float(summary.get("charge_excess", 0.0)),
		"use_needed": float(summary.get("use_needed", 0.0)),
		"charged": float(summary.get("charged", 0.0)),
		"used": float(summary.get("used", 0.0)),
		"one_headquarter_per_ssot": bool(registry.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry.get("errors", []).is_empty()),
	}
	print("PLACED_POWER_BATTERY_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _placed_power_battery_method_names() -> Dictionary:
	return {
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_BATTERY_STATE_KEY: "proof_power_graph_battery_state",
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_CHARGE_BATTERIES_KEY: "proof_power_graph_charge_batteries_state",
		source_placed_power_battery_runtime_state.SOURCE_PLACED_POWER_BATTERY_USE_BATTERIES_KEY: "proof_power_graph_use_batteries_state",
	}
