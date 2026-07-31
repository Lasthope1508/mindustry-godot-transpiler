extends Node

const port_game_script := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_build_update_tile_any_true_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileAnyTrueState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := port_game_script.new()
	var wrapper := game.source_tractor_beam_turret_build_update_tile_any_true_state(true, false)
	var module := source_tractor_beam_turret_build_update_tile_any_true_state_script.any_true_state(true, false)
	var generated_wrapper := game.generated_tractor_beam_turret_build_update_tile_any_true_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, null, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, true, null, 1.0, 10.0, 4.0, 0.0, 0.0, 1.0, 6.0, 2.0, 1.0, 1.0, "shocked", 30.0)
	var generated_module := source_tractor_beam_turret_build_update_tile_any_true_state_script.generated_any_true_bridge_state(0.0, 0.25, 1.0, 1.0, 0.0, true, null, null, "sharded", 0.0, 0.0, 80.0, true, true, false, 0.0, null, 0.0, 0.0, false, 1.0, 8.0, 0.0, 0.0, true, true, "crux", true, 4.0, true, null, 1.0, 10.0, 4.0, 0.0, 0.0, 1.0, 6.0, 2.0, 1.0, 1.0, "shocked", 30.0)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretBuildUpdateTileAnyTrueState",
		"module_matches": wrapper == module,
		"generated_wrapper_matches": generated_wrapper == generated_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("TRACTOR_BEAM_ANY_TRUE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
