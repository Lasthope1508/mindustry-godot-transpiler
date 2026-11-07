extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_overdrive_projector_state := preload("res://src/game/SourceOverdriveProjectorState.gd")
const source_overdrive_projector_runtime_state := preload("res://src/game/SourceOverdriveProjectorRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var cell_key := game.cell_key(Vector2i.ZERO)
	var sprite := Sprite2D.new()
	sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_CELL_KEY_META_KEY, cell_key)
	game.placed_blocks[cell_key] = sprite
	game.overdrive_projector_phase_heat[cell_key] = 0.25
	game.overdrive_projector_smooth_efficiency[cell_key] = 0.5
	game.overdrive_projector_heat[cell_key] = 0.75
	game.overdrive_projector_charges[cell_key] = 1.25
	game.overdrive_projector_use_progress[cell_key] = 1.75
	var current_state := {
		"heat": 0.0,
		"smooth_efficiency": 0.0,
		"phase_heat": 0.0,
		"charge": 0.0,
		"use_progress": 0.0,
	}
	var runtime_step := source_overdrive_projector_state.runtime_step_state(current_state, 1.0, 1, true, 5.0, 10.0)
	var direct_runtime_step := source_overdrive_projector_runtime_state.runtime_step_state(current_state, 1.0, 1, true, 5.0, 10.0)
	var runtime_context := {
		"current_state": current_state,
		"source_delta": 1.0,
		"booster_items": 1,
		"has_boost_value": true,
		"reload_value": 5.0,
		"use_time_value": 10.0,
	}
	var runtime_step_from_context := source_overdrive_projector_state.runtime_step_from_context(runtime_context)
	var direct_runtime_step_from_context := source_overdrive_projector_runtime_state.runtime_step_from_context(runtime_context)
	var boost_application := source_overdrive_projector_state.boost_application_state(10.0, 1.5, 6.0, {"block_id": "conveyor"}, true)
	var direct_boost_application := source_overdrive_projector_runtime_state.boost_application_state(10.0, 1.5, 6.0, {"block_id": "conveyor"}, true)
	var game_light_state := source_overdrive_projector_state.game_light_state_at_cell(game, 0, 0)
	var game_draw_state := source_overdrive_projector_state.game_draw_state_at_cell(game, 0, 0, 0.0)
	var game_state_value := source_overdrive_projector_state.game_state_value_at_cell(game, 0, 0, game.overdrive_projector_phase_heat, 0.0)
	var game_capture_state := source_overdrive_projector_state.game_capture_state_at_cell(game, 0, 0, game.overdrive_projector_heat, game.overdrive_projector_smooth_efficiency, game.overdrive_projector_phase_heat, game.overdrive_projector_charges, game.overdrive_projector_use_progress)
	var step_state := source_overdrive_projector_state.step_projectors(game, 0.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "OVERDRIVE_PROJECTOR_RUNTIME_MODULE_PROOF",
		"runtime_step_matches": runtime_step.has("charge_ready") and runtime_step_from_context.has("charge_ready"),
		"runtime_module_direct_matches": runtime_step == direct_runtime_step and runtime_step_from_context == direct_runtime_step_from_context,
		"boost_application_matches": bool(boost_application.get("applied", false)),
		"boost_application_module_direct_matches": boost_application == direct_boost_application,
		"game_light_at_cell_matches": game_light_state.get("color", "") == "" and float(game_light_state.get("radius", 1.0)) == 0.0 and float(game_light_state.get("alpha", 1.0)) == 0.0,
		"game_draw_at_cell_matches": not bool(game_draw_state.get("visible", true)) and float(game_draw_state.get("line_r", 1.0)) == 0.0 and float(game_draw_state.get("line_w", 1.0)) == 0.0,
		"game_state_value_at_cell_matches": game_state_value == 0.25,
		"game_capture_state_at_cell_matches": game_capture_state.get("cell_key", "") == cell_key and float(game_capture_state.get("heat", 0.0)) == 0.75 and float(game_capture_state.get("smooth_efficiency", 0.0)) == 0.5 and float(game_capture_state.get("phase_heat", 0.0)) == 0.25 and float(game_capture_state.get("charge", 0.0)) == 1.25 and float(game_capture_state.get("use_progress", 0.0)) == 1.75,
		"step_projectors_matches": step_state.has("last_overdrive_projector_boosted_time_scale"),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["runtime_step_matches"] and proof["runtime_module_direct_matches"] and proof["boost_application_matches"] and proof["boost_application_module_direct_matches"] and proof["game_light_at_cell_matches"] and proof["game_draw_at_cell_matches"] and proof["game_state_value_at_cell_matches"] and proof["game_capture_state_at_cell_matches"] and proof["step_projectors_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("OVERDRIVE_PROJECTOR_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("OverdriveProjectorRuntimeModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

