extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _building_item_dump_state_method_names() -> Dictionary:
	return {
		source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY: "_proof_increment_dump_cursor",
	}

func _ready() -> void:
	var game := PortGameScript.new()
	var cursor_game := PortGameScript.new()
	var cursor_module_game := PortGameScript.new()
	var accum_game := PortGameScript.new()
	var accum_module_game := PortGameScript.new()
	var wrapper := game.source_dump_accumulate_attempt_state(0.25, 0.75)
	var module := source_building_item_dump_state.dump_accumulate_state(0.25, 0.75)
	var wrap_again := game.source_dump_accumulate_attempt_state(1.25, 0.25)
	var module_again := source_building_item_dump_state.dump_accumulate_state(1.25, 0.25)
	var put_wrapper := game.source_building_put_item_state("copper", 4, 1, [false, true, true, false], [false, false, true, true])
	var put_module := source_building_item_dump_state.game_put_item_state(game, "copper", 4, 1, [false, true, true, false], [false, false, true, true])
	var put_direct := source_building_item_dump_state.put_item_state("copper", 4, 1, [false, true, true, false], [false, false, true, true], source_building_item_dump_state.default_callbacks_state(game).get(source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()))
	var null_scan_wrapper := game.source_building_dump_null_proximity_scan_state(4, 1)
	var null_scan_module := source_building_item_dump_state.game_dump_null_proximity_scan_state(game, 4, 1)
	var null_scan_direct := source_building_item_dump_state.dump_null_proximity_scan_state(4, 1, source_building_item_dump_state.default_callbacks_state(game).get(source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()))
	cursor_game.drill_dump_cursor = 2
	cursor_module_game.drill_dump_cursor = 2
	var cursor_wrapper := game.source_increment_dump_cursor(2, 4)
	var cursor_module := source_building_item_dump_state.increment_dump_cursor_state(2, 4)
	var cursor_runtime_wrapper := cursor_game.increment_drill_dump(4)
	var cursor_runtime_module := source_building_item_dump_state.increment_dump_cursor_runtime_state(cursor_module_game, 4)
	accum_game.building_dump_accum = 0.75
	accum_module_game.building_dump_accum = 0.75
	var accum_runtime_wrapper := accum_game.step_building_dump_accum(1.5)
	var accum_runtime_module := source_building_item_dump_state.dump_accumulate_runtime_state(accum_module_game, 1.5)
	var callbacks := source_building_item_dump_state.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get(source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(game, source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	var override_callbacks := source_building_item_dump_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(self, "_proof_increment_dump_cursor")
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingItemDumpState",
		"matches": wrapper == module and wrap_again == module_again,
		"module_matches": wrapper == module and wrap_again == module_again,
		"game_put_matches": put_wrapper == put_module and put_module == put_direct,
		"game_null_scan_matches": null_scan_wrapper == null_scan_module and null_scan_module == null_scan_direct,
		"cursor_matches": cursor_wrapper == cursor_module,
		"cursor_runtime_matches": cursor_runtime_wrapper == cursor_runtime_module and cursor_game.drill_dump_cursor == cursor_module_game.drill_dump_cursor,
		"accum_runtime_matches": accum_runtime_wrapper == accum_runtime_module and accum_game.building_dump_accum == accum_module_game.building_dump_accum,
		"default_callbacks_match": default_callbacks_match,
		"override_callbacks_match": override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("BUILDING_ITEM_DUMP_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	cursor_game.free()
	cursor_module_game.free()
	accum_game.free()
	accum_module_game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _proof_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	return source_building_item_dump_state.increment_dump_cursor_state(current_dump, proximity_size)
