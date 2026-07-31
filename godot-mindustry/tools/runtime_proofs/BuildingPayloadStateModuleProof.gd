extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_payload_state := preload("res://src/game/SourceBuildingPayloadState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _building_payload_state_method_names() -> Dictionary:
	return {
		source_building_payload_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY: "_proof_increment_dump_cursor",
	}

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_building_payload_state.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get(source_building_payload_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(game, source_building_payload_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	var override_callbacks := source_building_payload_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_payload_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(self, "_proof_increment_dump_cursor")
	var wrapper := game.source_dump_payload_state(3, 0, [false, true, false])
	var module := source_building_payload_state.game_dump_payload_state(game, 3, 0, [false, true, false])
	var empty_wrapper := game.source_dump_payload_state(0, 2, [])
	var empty_module := source_building_payload_state.game_dump_payload_state(game, 0, 2, [])
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingPayloadState",
		"matches": wrapper == module and empty_wrapper == empty_module,
		"module_matches": wrapper == module and empty_wrapper == empty_module,
		"game_dump_matches": wrapper == module and empty_wrapper == empty_module,
		"default_callbacks_match": default_callbacks_match,
		"override_callbacks_match": override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("BUILDING_PAYLOAD_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _proof_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	return int((current_dump + 1) % proximity_size) if proximity_size > 0 else current_dump
