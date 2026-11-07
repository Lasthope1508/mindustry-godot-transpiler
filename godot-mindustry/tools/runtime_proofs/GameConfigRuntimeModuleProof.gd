extends Node

const port_game := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_game_config_runtime_state := preload("res://src/game/SourceGameConfigRuntimeState.gd")

func _ready() -> void:
	var game := port_game.new()
	source_game_config_runtime_state.load_config(game)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var config: Dictionary = game.config
	var proof := {
		"module": "SourceGameConfigRuntimeState",
		"config_loaded": not config.is_empty(),
		"tile_size": int(game.tile_size),
		"config_tile_size": int(config.get("tile_size", 0)),
		"tile_size_matches": int(game.tile_size) == int(config.get("tile_size", 0)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("GAME_CONFIG_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(20.0).timeout
