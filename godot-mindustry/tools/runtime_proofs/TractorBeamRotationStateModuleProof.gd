extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceTractorBeamTurretBuildUpdateTileRotationMoveState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileRotationMoveState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceTractorBeamTurretBuildUpdateTileRotationMoveState.default_callbacks_state(game)
	var expected_callbacks := {
		"move_toward_angle": Callable(game, "source_arc_angles_move_toward"),
	}
	var wrapper := game.source_tractor_beam_turret_build_update_tile_rotation_move_state(true, 15.0, 90.0, 12.0, 0.25)
	var module := SourceTractorBeamTurretBuildUpdateTileRotationMoveState.rotation_move_state(true, 15.0, 90.0, 12.0, 0.25, callbacks.get("move_toward_angle", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretBuildUpdateTileRotationMoveState",
		"wrapper_matches": wrapper == module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"module_matches": wrapper == module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("TRACTOR_BEAM_ROTATION_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
