extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceDrillInventoryRuntimeState := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var wrapper_game := PortGameScript.new()
	var module_game := PortGameScript.new()
	wrapper_game.load_content_registry()
	module_game.load_content_registry()
	for game in [wrapper_game, module_game]:
		game.core_item_capacity = 1000
		game.core_inventory = 10
		game.core_items = {"copper": 10}
		game.core_incinerates = false
		game.core_incinerate_non_buildable = true
		game.drill_items = {"copper": 3}
	var callbacks := SourceDrillInventoryRuntimeState.default_callbacks_state(module_game)
	var expected_callbacks := {
		"item_count": Callable(module_game, "drill_item_count"),
		"core_accept": Callable(module_game, "source_core_accept_item"),
		"core_handle": Callable(module_game, "source_core_handle_item"),
		"remove_item": Callable(module_game, "remove_drill_item"),
		"increment_dump": Callable(module_game, "increment_drill_dump"),
	}
	var wrapper := wrapper_game.source_dump_drill_item_to_core("copper")
	var module := SourceDrillInventoryRuntimeState.dump_item_to_core_state("copper", callbacks.get("item_count", Callable()), callbacks.get("core_accept", Callable()), callbacks.get("core_handle", Callable()), callbacks.get("remove_item", Callable()), callbacks.get("increment_dump", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceDrillInventoryRuntimeState",
		"wrapper_matches": bool(wrapper) == bool(module.get("dump_success", false)),
		"default_callbacks_match": callbacks == expected_callbacks,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["wrapper_matches"]
	print("DRILL_INVENTORY_CALLBACK_MODULE_PROOF " + JSON.stringify(proof))
	wrapper_game.free()
	module_game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
