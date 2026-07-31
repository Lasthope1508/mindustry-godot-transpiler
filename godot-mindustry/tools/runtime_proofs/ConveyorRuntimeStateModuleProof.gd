extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_conveyor_runtime_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_conveyor_runtime_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY: Callable(game, source_conveyor_runtime_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_FALLBACK),
	}
	var override_callbacks := source_conveyor_runtime_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_conveyor_runtime_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY, Callable()) == Callable(self, "proof_edelta_provider")
	var wrapper := game.source_conveyor_path_progress_delta("conveyor", 2.0, 1.5, 0.5)
	var module_bridge := source_conveyor_runtime_state.game_path_progress_delta(game, "conveyor", 2.0, 4, 8.0, SourceTimeDefaults.TICK_RATE, null, 1.5, 0.5)
	var module := source_conveyor_runtime_state.path_progress_delta("conveyor", 2.0, 4, 8.0, SourceTimeDefaults.TICK_RATE, null, 1.5, 0.5, callbacks.get(source_conveyor_runtime_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY, Callable()))
	var override_edelta_value: float = float(override_callbacks.get(source_conveyor_runtime_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY, Callable()).call(2.0, 3.0, 4.0))
	var cell_wrapper := game.source_conveyor_path_progress_delta_for_cell(0, 0, 2.0, 1.5)
	var cell_module := source_conveyor_runtime_state.game_path_progress_delta_for_cell(game, 0, 0, 2.0, 1.5)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConveyorRuntimeState",
		"wrapper_matches": is_equal_approx(wrapper, module),
		"bridge_matches": is_equal_approx(wrapper, module_bridge),
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"override_edelta_provider_matches": is_equal_approx(override_edelta_value, 24.0),
		"module_matches": is_equal_approx(wrapper, module) and is_equal_approx(wrapper, module_bridge),
		"cell_wrapper_matches": is_equal_approx(cell_wrapper, cell_module) and cell_module == 0.0,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["wrapper_matches"] and proof["bridge_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_edelta_provider_matches"] and proof["module_matches"] and proof["cell_wrapper_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONVEYOR_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func proof_edelta_provider(source_delta: float, time_scale: float, efficiency: float) -> float:
	return source_delta * time_scale * efficiency

func _conveyor_runtime_method_names() -> Dictionary:
	return {
		source_conveyor_runtime_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY: "proof_edelta_provider",
	}
