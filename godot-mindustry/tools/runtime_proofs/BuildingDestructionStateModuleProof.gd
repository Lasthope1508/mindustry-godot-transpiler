extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingDestructionState := preload("res://src/game/SourceBuildingDestructionState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceBuildingDestructionState.default_callbacks_state(game)
	var expected_callbacks := {
		"random_seed_float_max": Callable(game, "source_arc_random_seed_float_max"),
	}
	var destroyed_wrapper := game.source_building_after_destroyed_state(true, true, "sharded", 16.0, 24.0, 9)
	var destroyed_module := SourceBuildingDestructionState.after_destroyed_state(true, true, "sharded", 16.0, 24.0, 9, callbacks.get("random_seed_float_max", Callable()))
	var no_bullet_wrapper := game.source_building_after_destroyed_state(false, true, "sharded", 16.0, 24.0, 9)
	var no_bullet_module := SourceBuildingDestructionState.after_destroyed_state(false, true, "sharded", 16.0, 24.0, 9, callbacks.get("random_seed_float_max", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingDestructionState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"after_destroyed_matches": destroyed_wrapper == destroyed_module,
		"after_destroyed_no_bullet_matches": no_bullet_wrapper == no_bullet_module,
		"module_matches": destroyed_wrapper == destroyed_module and no_bullet_wrapper == no_bullet_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("BUILDING_DESTRUCTION_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
