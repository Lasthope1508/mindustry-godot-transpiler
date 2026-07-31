extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_mend_projector_state := preload("res://src/game/SourceMendProjectorState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var current_state := {
		"heat": 0.0,
		"smooth_efficiency": 0.0,
		"phase_heat": 0.0,
		"charge": 0.0,
		"booster_timer": 0.0,
	}
	var runtime_step := source_mend_projector_state.runtime_step_state(current_state, 1.0, 1, 10.0, 5.0)
	var runtime_context := {
		"current_state": current_state,
		"source_delta": 1.0,
		"booster_items": 1,
		"use_time_value": 10.0,
		"reload_value": 5.0,
	}
	var runtime_step_from_context := source_mend_projector_state.runtime_step_from_context(runtime_context)
	var heal_application := source_mend_projector_state.heal_application_state({"healed": false, "healed_amount": 0.0}, false)
	var step_state := source_mend_projector_state.step_projectors(game, 0.0)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "MEND_PROJECTOR_RUNTIME_MODULE_PROOF",
		"runtime_step_matches": runtime_step.has("charge_ready") and runtime_step_from_context.has("charge_ready"),
		"heal_application_matches": bool(heal_application.get("healed", true)) == false,
		"step_projectors_matches": step_state.has("last_mend_projector_target_health"),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["runtime_step_matches"] and proof["heal_application_matches"] and proof["step_projectors_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("MEND_PROJECTOR_RUNTIME_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/MendProjectorRuntimeModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
