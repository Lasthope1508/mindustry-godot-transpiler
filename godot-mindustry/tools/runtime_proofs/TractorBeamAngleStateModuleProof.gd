extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_build_update_tile_angle_to_target_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.default_callbacks_state(game)
	var expected_callbacks := {
		source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.SOURCE_TRACTOR_BEAM_ANGLE_TO_TARGET_KEY: Callable(game, source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.SOURCE_TRACTOR_BEAM_ANGLE_TO_TARGET_FALLBACK),
	}
	var override_callbacks := source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.SOURCE_TRACTOR_BEAM_ANGLE_TO_TARGET_KEY, Callable()) == Callable(self, "proof_angle_to_target")
	var target_after := {
		"x": 16.0,
		"y": 8.0,
	}
	var wrapper := game.source_tractor_beam_turret_build_update_tile_angle_to_target_state(true, 4.0, 6.0, target_after)
	var module := source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.angle_to_target_state(true, 4.0, 6.0, target_after, callbacks.get(source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.SOURCE_TRACTOR_BEAM_ANGLE_TO_TARGET_KEY, Callable()))
	var override_module := source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.game_angle_to_target_state(self, true, 4.0, 6.0, target_after)
	var primitive_override_module := source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.angle_to_target_state(true, 4.0, 6.0, target_after, Callable(self, "proof_angle_to_target"))
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretBuildUpdateTileAngleToTargetState",
		"wrapper_matches": wrapper == module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"override_module_matches": override_module == primitive_override_module,
		"module_matches": wrapper == module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_module_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TRACTOR_BEAM_ANGLE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func proof_angle_to_target(_origin: Dictionary, _target: Variant) -> float:
	return 33.0

func _tractor_beam_angle_method_names() -> Dictionary:
	return {
		source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.SOURCE_TRACTOR_BEAM_ANGLE_TO_TARGET_KEY: "proof_angle_to_target",
	}
