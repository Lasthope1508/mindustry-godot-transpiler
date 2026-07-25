extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceTractorBeamTurretBuildUpdateTileAngleToTargetState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.default_callbacks_state(game)
	var expected_callbacks := {
		"angle_to_target": Callable(game, "source_angle_to_target"),
	}
	var target_after := {
		"x": 16.0,
		"y": 8.0,
	}
	var wrapper := game.source_tractor_beam_turret_build_update_tile_angle_to_target_state(true, 4.0, 6.0, target_after)
	var module := SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.angle_to_target_state(true, 4.0, 6.0, target_after, callbacks.get("angle_to_target", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretBuildUpdateTileAngleToTargetState",
		"wrapper_matches": wrapper == module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"module_matches": wrapper == module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("TRACTOR_BEAM_ANGLE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
