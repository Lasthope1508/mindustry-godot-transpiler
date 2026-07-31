extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileShootWhenPossibleGuardState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.default_callbacks_state(game)
	var expected_callbacks := {
		source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_KEY: Callable(game, source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_FALLBACK),
	}
	var override_callbacks := source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_KEY, Callable()) == Callable(self, "proof_angle_dist")
	var wrapper := game.source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state(true, 10.0, 12.0, 6.0)
	var module := source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.shoot_when_possible_guard_state(true, 10.0, 12.0, 6.0, callbacks.get(source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_KEY, Callable()))
	var override_module := source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.game_shoot_when_possible_guard_state(self, true, 10.0, 12.0, 6.0)
	var primitive_override_module := source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.shoot_when_possible_guard_state(true, 10.0, 12.0, 6.0, Callable(self, "proof_angle_dist"))
	var generated_wrapper := game.generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, null, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, true, null, 1.0, 10.0, 4.0, 0.0, 0.0, 1.0, 6.0)
	var generated_module := source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.game_generated_shoot_when_possible_guard_bridge_state(game, 0.0, 0.25, 1.0, 1.0, 0.0, true, null, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, true, null, 1.0, 10.0, 4.0, 0.0, 0.0, 1.0, 6.0)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretBuildUpdateTileShootWhenPossibleGuardState",
		"wrapper_matches": wrapper == module,
		"generated_wrapper_matches": generated_wrapper == generated_module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"override_module_matches": override_module == primitive_override_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["wrapper_matches"] and proof["generated_wrapper_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_module_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TRACTOR_BEAM_SHOOT_WHEN_POSSIBLE_GUARD_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func proof_angle_dist(rotation: float, dest: float) -> float:
	return absf(rotation - dest)

func _tractor_beam_shoot_guard_method_names() -> Dictionary:
	return {
		source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_KEY: "proof_angle_dist",
	}
