extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_drill_inventory_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_core_inventory_runtime_state := preload("res://src/game/SourceCoreInventoryRuntimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var wrapper_game := PortGameScript.new()
	var module_game := PortGameScript.new()
	var core_wrapper_game := PortGameScript.new()
	var core_module_game := PortGameScript.new()
	var mutation_wrapper_game := PortGameScript.new()
	var mutation_module_game := PortGameScript.new()
	var drill_mutation_wrapper_game := PortGameScript.new()
	var drill_mutation_module_game := PortGameScript.new()
	wrapper_game.load_content_registry()
	module_game.load_content_registry()
	core_wrapper_game.load_content_registry()
	core_module_game.load_content_registry()
	for game in [wrapper_game, module_game, core_wrapper_game, core_module_game]:
		game.core_item_capacity = 1000
		game.core_inventory = 10
		game.core_items = {"copper": 10}
		game.core_incinerates = false
		game.core_incinerate_non_buildable = true
		game.drill_items = {"copper": 3}
	for game in [mutation_wrapper_game, mutation_module_game]:
		game.core_item_capacity = 20
		game.core_inventory = 4
		game.core_items = {}
	for game in [drill_mutation_wrapper_game, drill_mutation_module_game]:
		game.drill_items = {}
	var callbacks := source_drill_inventory_runtime_state.default_callbacks_state(module_game)
	var expected_callbacks := {
		source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_ITEM_COUNT_KEY: Callable(module_game, source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_ITEM_COUNT_FALLBACK),
		source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_CORE_ACCEPT_KEY: Callable(module_game, source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_CORE_ACCEPT_FALLBACK),
		source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_CORE_HANDLE_KEY: Callable(module_game, source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_CORE_HANDLE_FALLBACK),
		source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_REMOVE_ITEM_KEY: Callable(module_game, source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_REMOVE_ITEM_FALLBACK),
		source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_KEY: Callable(module_game, source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_FALLBACK),
	}
	var override_callbacks := source_drill_inventory_runtime_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_CORE_HANDLE_KEY, Callable()) == Callable(self, "proof_core_handle_item")
	var wrapper := wrapper_game.source_dump_drill_item_to_core("copper")
	var module := source_drill_inventory_runtime_state.game_dump_item_to_core_state(module_game, "copper")
	mutation_wrapper_game.sync_copper_inventory_alias()
	source_core_inventory_runtime_state.sync_copper_inventory_runtime_state(mutation_module_game)
	mutation_wrapper_game.set_core_item_count("copper", 8)
	source_core_inventory_runtime_state.set_item_count_runtime_state(mutation_module_game, "copper", 8)
	mutation_wrapper_game.add_core_item("copper", 3)
	source_core_inventory_runtime_state.add_item_runtime_state(mutation_module_game, "copper", 3)
	var mutation_wrapper_count := mutation_wrapper_game.core_item_count("copper")
	var mutation_module_count := source_core_inventory_runtime_state.item_count_runtime_state(mutation_module_game, "copper")
	drill_mutation_wrapper_game.add_drill_item("copper", 5)
	source_drill_inventory_runtime_state.add_item_runtime_state(drill_mutation_module_game, "copper", 5)
	drill_mutation_wrapper_game.source_offload_to_inventory("copper", 3)
	source_drill_inventory_runtime_state.offload_to_inventory_runtime_state(drill_mutation_module_game, "copper", 3)
	var drill_removed_wrapper := drill_mutation_wrapper_game.remove_drill_item("copper", 2)
	var drill_removed_module := source_drill_inventory_runtime_state.remove_item_runtime_state(drill_mutation_module_game, "copper", 2)
	var core_wrapper := core_wrapper_game.source_core_handle_item("copper")
	var core_module := source_core_inventory_runtime_state.game_handle_item(core_module_game, "copper")
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceDrillInventoryRuntimeState",
		"wrapper_matches": bool(wrapper) == bool(module.get("dump_success", false)),
		"core_inventory_mutation_matches": mutation_wrapper_game.core_items == mutation_module_game.core_items and mutation_wrapper_game.core_inventory == mutation_module_game.core_inventory and mutation_wrapper_count == mutation_module_count,
		"drill_inventory_mutation_matches": drill_mutation_wrapper_game.drill_items == drill_mutation_module_game.drill_items and drill_removed_wrapper == drill_removed_module,
		"core_handle_matches": bool(core_wrapper) == bool(core_module) and core_wrapper_game.core_items == core_module_game.core_items,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["wrapper_matches"]
	print("DRILL_INVENTORY_CALLBACK_MODULE_PROOF " + JSON.stringify(proof))
	wrapper_game.free()
	module_game.free()
	core_wrapper_game.free()
	core_module_game.free()
	mutation_wrapper_game.free()
	mutation_module_game.free()
	drill_mutation_wrapper_game.free()
	drill_mutation_module_game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func proof_core_handle_item(item_id: String) -> bool:
	return item_id != ""

func _drill_inventory_method_names() -> Dictionary:
	return {
		source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_CORE_HANDLE_KEY: "proof_core_handle_item",
	}
