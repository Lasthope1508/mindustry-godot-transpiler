extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceDrillRuntimeState := preload("res://src/game/SourceDrillRuntimeState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceDrillRuntimeState.default_callbacks_state(game)
	var expected_callbacks := {
		"occupied_cells": Callable(game, "occupied_cells"),
		"cell_key": Callable(game, "cell_key"),
		"delay": Callable(game, "source_drill_delay"),
		"approach_delta": Callable(game, "source_approach_delta"),
		"building_delta": Callable(game, "source_building_delta"),
	}
	var proof := {
		"module": "SourceDrillRuntimeState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"one_headquarter_per_ssot": bool(SourceSsotCatalog.canonical_headquarter_registry_state().get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(SourceSsotCatalog.canonical_headquarter_registry_state().get("errors", []).is_empty()),
	}
	print("DRILL_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
