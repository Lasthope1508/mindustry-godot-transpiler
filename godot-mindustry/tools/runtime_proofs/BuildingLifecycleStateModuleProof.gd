extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingLifecycleState := preload("res://src/game/SourceBuildingLifecycleState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceBuildingLifecycleState.default_callbacks_state(game)
	var expected_callbacks := {
		"chance_delta_threshold": Callable(game, "source_arc_chance_delta_threshold"),
	}
	var suppression_wrapper := game.source_building_check_suppression_state(true, 3.0, 10.0, 0.5, 8.0, 9.0, 2, 8.0, "red")
	var suppression_module := SourceBuildingLifecycleState.check_suppression_state(true, 3.0, 10.0, 0.5, 8.0, 9.0, 2, 8.0, "red", callbacks.get("chance_delta_threshold", Callable()))
	var heal_suppressed_wrapper := game.source_building_is_heal_suppressed_state(true, 3.0, 10.0)
	var heal_suppressed_module := SourceBuildingLifecycleState.is_heal_suppressed_state(true, 3.0, 10.0)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingLifecycleState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"check_suppression_matches": suppression_wrapper == suppression_module,
		"heal_suppressed_matches": heal_suppressed_wrapper == heal_suppressed_module,
		"module_matches": suppression_wrapper == suppression_module and heal_suppressed_wrapper == heal_suppressed_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("BUILDING_LIFECYCLE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
