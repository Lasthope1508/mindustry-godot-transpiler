extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingItemDumpState := preload("res://src/game/SourceBuildingItemDumpState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var wrapper := game.source_dump_accumulate_attempt_state(0.25, 0.75)
	var module := SourceBuildingItemDumpState.dump_accumulate_state(0.25, 0.75)
	var wrap_again := game.source_dump_accumulate_attempt_state(1.25, 0.25)
	var module_again := SourceBuildingItemDumpState.dump_accumulate_state(1.25, 0.25)
	var callbacks := SourceBuildingItemDumpState.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get("increment_dump_cursor", Callable()) == Callable(game, "source_increment_dump_cursor")
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingItemDumpState",
		"matches": wrapper == module and wrap_again == module_again,
		"module_matches": wrapper == module and wrap_again == module_again,
		"default_callbacks_match": default_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("BUILDING_ITEM_DUMP_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
