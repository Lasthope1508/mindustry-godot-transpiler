extends Node

const port_game_script := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_build_draw_state_script := preload("res://src/game/SourceTractorBeamTurretBuildDrawState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := port_game_script.new()
	var wrapper := game.source_tractor_beam_turret_build_draw_state("base-region", "tractor-region", 12.0, 18.0, 135.0, 8.0, true, false, 28.0, 22.0, "tractor-laser-color", 0.4, "laser", "laser-start", "laser-end", 6.0, 0.75, 0.8, 1.25)
	var module := source_tractor_beam_turret_build_draw_state_script.draw_state("base-region", "tractor-region", 12.0, 18.0, 135.0, 8.0, true, false, 28.0, 22.0, "tractor-laser-color", 0.4, "laser", "laser-start", "laser-end", 6.0, 0.75, 0.8, 1.25)
	var generated_wrapper := game.generated_tractor_beam_turret_build_draw_bridge_state("base-region", "tractor-region", 12.0, 18.0, 135.0, 8.0, true, false, 28.0, 22.0, "tractor-laser-color", 0.4, "laser", "laser-start", "laser-end", 6.0, 0.75, 0.8, 1.25)
	var generated_module := source_tractor_beam_turret_build_draw_state_script.generated_draw_bridge_state("base-region", "tractor-region", 12.0, 18.0, 135.0, 8.0, true, false, 28.0, 22.0, "tractor-laser-color", 0.4, "laser", "laser-start", "laser-end", 6.0, 0.75, 0.8, 1.25)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTractorBeamTurretBuildDrawState",
		"module_matches": wrapper == module,
		"generated_wrapper_matches": generated_wrapper == generated_module,
		"generated_matches_canonical": bool(generated_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("TRACTOR_BEAM_DRAW_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
