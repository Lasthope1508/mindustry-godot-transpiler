extends Node

const port_game_script := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_build_update_tile_active_strength_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileActiveStrengthState.gd")
const source_tractor_beam_turret_build_update_tile_inactive_strength_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := port_game_script.new()
	var active_callbacks := source_tractor_beam_turret_build_update_tile_active_strength_state_script.default_callbacks_state(game)
	var inactive_callbacks := source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.default_callbacks_state(game)
	var active_expected_callbacks := {
		source_tractor_beam_turret_build_update_tile_active_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY: Callable(game, source_tractor_beam_turret_build_update_tile_active_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_FALLBACK),
	}
	var inactive_expected_callbacks := {
		source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY: Callable(game, source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_FALLBACK),
	}
	var active_override_callbacks := source_tractor_beam_turret_build_update_tile_active_strength_state_script.default_callbacks_state(self)
	var inactive_override_callbacks := source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.default_callbacks_state(self)
	var active_override_callbacks_match: bool = active_override_callbacks.get(source_tractor_beam_turret_build_update_tile_active_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()) == Callable(self, "proof_lerp_delta")
	var inactive_override_callbacks_match: bool = inactive_override_callbacks.get(source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()) == Callable(self, "proof_lerp_delta")
	var active_wrapper := game.source_tractor_beam_turret_build_update_tile_active_strength_state(true, 12.0, 0.25)
	var active_module := source_tractor_beam_turret_build_update_tile_active_strength_state_script.active_strength_state(true, 12.0, 0.25, active_callbacks.get(source_tractor_beam_turret_build_update_tile_active_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()))
	var active_override_module := source_tractor_beam_turret_build_update_tile_active_strength_state_script.game_active_strength_state(self, true, 12.0, 0.25)
	var active_primitive_override_module := source_tractor_beam_turret_build_update_tile_active_strength_state_script.active_strength_state(true, 12.0, 0.25, Callable(self, "proof_lerp_delta"))
	var inactive_wrapper := game.source_tractor_beam_turret_build_update_tile_inactive_strength_state(false, false, 8.0, 0.25)
	var inactive_module := source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.inactive_strength_state(false, false, 8.0, 0.25, inactive_callbacks.get(source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()))
	var inactive_override_module := source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.game_inactive_strength_state(self, false, false, 8.0, 0.25)
	var inactive_primitive_override_module := source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.inactive_strength_state(false, false, 8.0, 0.25, Callable(self, "proof_lerp_delta"))
	var active_generated_wrapper := game.generated_tractor_beam_turret_build_update_tile_active_strength_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, null, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, true, null, 1.0, 10.0, 4.0, 0.0, 0.0, 1.0)
	var active_generated_module := source_tractor_beam_turret_build_update_tile_active_strength_state_script.generated_active_strength_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, null, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, true, null, 1.0, 10.0, 4.0, 0.0, 0.0, 1.0, active_callbacks.get(source_tractor_beam_turret_build_update_tile_active_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()))
	var inactive_generated_wrapper := game.generated_tractor_beam_turret_build_update_tile_inactive_strength_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, null, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, true, null, 1.0, 10.0, 4.0, 0.0, 0.0, 1.0)
	var inactive_generated_module := source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.generated_inactive_strength_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, null, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, true, null, 1.0, 10.0, 4.0, 0.0, 0.0, 1.0, inactive_callbacks.get(source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()))
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretStrengthState",
		"active_matches": active_wrapper == active_module,
		"inactive_matches": inactive_wrapper == inactive_module,
		"active_override_callbacks_match": active_override_callbacks_match,
		"inactive_override_callbacks_match": inactive_override_callbacks_match,
		"active_override_module_matches": active_override_module == active_primitive_override_module,
		"inactive_override_module_matches": inactive_override_module == inactive_primitive_override_module,
		"module_matches": active_wrapper == active_module and inactive_wrapper == inactive_module,
		"active_generated_wrapper_matches": active_generated_wrapper == active_generated_module,
		"inactive_generated_wrapper_matches": inactive_generated_wrapper == inactive_generated_module,
		"default_callbacks_match": active_callbacks == active_expected_callbacks and inactive_callbacks == inactive_expected_callbacks,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["active_generated_wrapper_matches"] and proof["inactive_generated_wrapper_matches"] and proof["default_callbacks_match"] and proof["active_override_callbacks_match"] and proof["inactive_override_callbacks_match"] and proof["active_override_module_matches"] and proof["inactive_override_module_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TRACTOR_BEAM_STRENGTH_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TractorBeamStrengthStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func proof_lerp_delta(from: float, to: float, progress: float, time_delta: float) -> float:
	return lerpf(from, to, clampf(progress * time_delta, 0.0, 1.0))

func _tractor_beam_active_strength_method_names() -> Dictionary:
	return {
		source_tractor_beam_turret_build_update_tile_active_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY: "proof_lerp_delta",
	}

func _tractor_beam_inactive_strength_method_names() -> Dictionary:
	return {
		source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY: "proof_lerp_delta",
	}

