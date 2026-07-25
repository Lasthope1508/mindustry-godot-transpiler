extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingLiquidState := preload("res://src/game/SourceBuildingLiquidState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceBuildingLiquidState.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get("increment_dump_cursor", Callable()) == Callable(game, "source_increment_dump_cursor")
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
	var module := SourceBuildingLiquidState.dump_liquid_routing_gate_state(
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
		callbacks.get("increment_dump_cursor", Callable())
	)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingLiquidState",
		"matches": wrapper == module,
		"module_matches": wrapper == module,
		"default_callbacks_match": default_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("BUILDING_LIQUID_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
