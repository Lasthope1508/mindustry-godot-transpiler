extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _building_liquid_state_method_names() -> Dictionary:
	return {
		source_building_liquid_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY: "_proof_increment_dump_cursor",
	}

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_building_liquid_state.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get(source_building_liquid_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(game, source_building_liquid_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	var override_callbacks := source_building_liquid_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_liquid_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(self, "_proof_increment_dump_cursor")
	var wrapper := game.source_building_dump_liquid_routing_gate_state(
		"water",
		3,
		1,
		-1,
		0,
		[0, 1, 2],
		[true, true, false],
		[true, true, false],
		[true, true, false],
		[true, true, false]
	)
	var module := source_building_liquid_state.dump_liquid_routing_gate_state(
		"water",
		3,
		1,
		-1,
		0,
		[0, 1, 2],
		[true, true, false],
		[true, true, false],
		[true, true, false],
		[true, true, false],
		callbacks.get(source_building_liquid_state.SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable())
	)
	var wrapper_module := source_building_liquid_state.game_dump_liquid_routing_gate_state(
		game,
		"water",
		3,
		1,
		-1,
		0,
		[0, 1, 2],
		[true, true, false],
		[true, true, false],
		[true, true, false],
		[true, true, false]
	)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingLiquidState",
		"matches": wrapper == module,
		"module_matches": wrapper == module,
		"game_routing_matches": wrapper_module == module,
		"default_callbacks_match": default_callbacks_match,
		"override_callbacks_match": override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("BUILDING_LIQUID_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _proof_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	if proximity_size != 0:
		return (current_dump + 1) % proximity_size
	return current_dump
