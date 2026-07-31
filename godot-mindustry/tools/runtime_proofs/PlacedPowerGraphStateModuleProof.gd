extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

class FakeCatalog:
	extends RefCounted

	var entries: Dictionary = {}

	func _init(next_entries: Dictionary) -> void:
		entries = next_entries

	func get_by_id(id: String):
		return entries.get(id, null)

func _sprite_for_block(block_id: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, block_id)
	return sprite

func _ready() -> void:
	var game := PortGameScript.new()
	game.set("content_catalog", FakeCatalog.new({
		"consumer": {"properties": {"hasPower": true, "consumesPower": true, "powerUsage": 4.0}},
		"producer": {"properties": {"hasPower": true, "outputsPower": true, "powerProduction": 3.0}},
		"battery": {"properties": {"hasPower": true, "powerBuffered": true, "powerCapacity": 10.0}},
	}))
	game.set("placed_block_origins", {
		"c": _sprite_for_block("consumer"),
		"p": _sprite_for_block("producer"),
		"b": _sprite_for_block("battery"),
	})
	var callbacks := source_placed_power_graph_state.default_callbacks_state(game)
	var direct := source_placed_power_graph_state.runtime_state(game.get("placed_block_origins"), callbacks.get("block_from_sprite", Callable()), callbacks.get("role_for_block", Callable()), 60.0)
	var game_runtime := source_placed_power_graph_state.game_runtime_state(game, 60.0)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "PLACED_POWER_GRAPH_STATE_MODULE_PROOF",
		"matches": direct == game_runtime,
		"game_runtime_matches": direct == game_runtime,
		"producer_count": int(game_runtime.get("producer_count", 0)),
		"consumer_count": int(game_runtime.get("consumer_count", 0)),
		"battery_count": int(game_runtime.get("battery_count", 0)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("PLACED_POWER_GRAPH_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
