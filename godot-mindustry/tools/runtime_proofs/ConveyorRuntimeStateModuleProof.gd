extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceConveyorRuntimeState := preload("res://src/game/SourceConveyorRuntimeState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceConveyorRuntimeState.default_callbacks_state(game)
	var expected_callbacks := {
		"edelta_provider": Callable(game, "source_building_edelta"),
	}
	var wrapper := game.source_conveyor_path_progress_delta("conveyor", 2.0, 1.5, 0.5)
	var module := SourceConveyorRuntimeState.path_progress_delta("conveyor", 2.0, 4, 8.0, SourceTimeDefaults.TICK_RATE, null, 1.5, 0.5, callbacks.get("edelta_provider", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConveyorRuntimeState",
		"wrapper_matches": is_equal_approx(wrapper, module),
		"default_callbacks_match": callbacks == expected_callbacks,
		"module_matches": is_equal_approx(wrapper, module),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("CONVEYOR_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
