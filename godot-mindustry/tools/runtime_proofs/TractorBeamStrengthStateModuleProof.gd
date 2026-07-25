extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const ActiveStrengthState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileActiveStrengthState.gd")
const InactiveStrengthState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	# SourceTractorBeamTurretBuildUpdateTileActiveStrengthState.default_callbacks_state
	# SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState.default_callbacks_state
	var active_callbacks := ActiveStrengthState.default_callbacks_state(game)
	var inactive_callbacks := InactiveStrengthState.default_callbacks_state(game)
	var expected_callbacks := {
		"lerp_delta": Callable(game, "source_mathf_lerp_delta"),
	}
	var active_wrapper := game.source_tractor_beam_turret_build_update_tile_active_strength_state(true, 12.0, 0.25)
	var active_module := ActiveStrengthState.active_strength_state(true, 12.0, 0.25, active_callbacks.get("lerp_delta", Callable()))
	var inactive_wrapper := game.source_tractor_beam_turret_build_update_tile_inactive_strength_state(false, false, 8.0, 0.25)
	var inactive_module := InactiveStrengthState.inactive_strength_state(false, false, 8.0, 0.25, inactive_callbacks.get("lerp_delta", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretStrengthState",
		"active_matches": active_wrapper == active_module,
		"inactive_matches": inactive_wrapper == inactive_module,
		"module_matches": active_wrapper == active_module and inactive_wrapper == inactive_module,
		"default_callbacks_match": active_callbacks == expected_callbacks and inactive_callbacks == expected_callbacks,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("TRACTOR_BEAM_STRENGTH_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
