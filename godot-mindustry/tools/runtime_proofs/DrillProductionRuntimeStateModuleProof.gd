extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceDrillProductionRuntimeState := preload("res://src/game/SourceDrillProductionRuntimeState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceDrillProductionRuntimeState.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get("output_batch", Callable()) == Callable(game, "source_drill_output_batch") and callbacks.get("progress_fraction", Callable()) == Callable(game, "source_drill_progress_fraction")
	var wrapper := game.source_drill_production_runtime_state(0.25, 2.0, 1.5, 3, 8, 10)
	var module := SourceDrillProductionRuntimeState.production_state(
		0.25,
		2.0,
		1.5,
		3,
		8,
		10,
		callbacks.get("output_batch", Callable()),
		callbacks.get("progress_fraction", Callable())
	)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceDrillProductionRuntimeState",
		"matches": wrapper == module,
		"module_matches": wrapper == module,
		"default_callbacks_match": default_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("DRILL_PRODUCTION_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
