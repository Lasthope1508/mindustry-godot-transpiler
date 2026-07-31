extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var move_forward_game := PortGameScript.new()
	var move_forward_module_game := PortGameScript.new()
	var accept_wrapper := game.source_move_forward_accept_state(true, true, true)
	var accept_module := source_building_item_state.move_forward_accept_state(true, true, true)
	var move_forward_wrapper := move_forward_game.source_move_forward_to_core("copper")
	var move_forward_module := source_building_item_state.move_forward_to_core_runtime_state(move_forward_module_game, "copper", true, true)
	var stack_wrapper := game.source_building_accept_stack_state(true, true, true, 7, 4, 3)
	var stack_module := source_building_item_state.accept_stack_state(true, true, true, 7, 4, 3)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_ITEM_STATE_MODULE_PROOF",
		"move_forward_accept_matches": accept_wrapper == accept_module,
		"move_forward_to_core_matches": move_forward_wrapper == move_forward_module,
		"stack_matches": stack_wrapper == stack_module,
		"module_matches": accept_wrapper == accept_module and move_forward_wrapper == move_forward_module and stack_wrapper == stack_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("BUILDING_ITEM_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	move_forward_game.free()
	move_forward_module_game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
