extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_status_apply_state := preload("res://src/game/SourceStatusApplyState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var wrapper := game.source_status_apply_result("burning", 300.0, false)
	var module := source_status_apply_state.apply_result_state("burning", 300.0, false)
	var immune_wrapper := game.source_status_apply_result("burning", 300.0, true)
	var immune_module := source_status_apply_state.apply_result_state("burning", 300.0, true)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "StatusApplyModuleProof",
		"wrapper_matches_module": wrapper == module,
		"immune_wrapper_matches_module": immune_wrapper == immune_module,
		"status_applied": bool(module.get("statusApplied", false)),
		"immune_status_not_applied": not bool(immune_module.get("statusApplied", true)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["wrapper_matches_module"] and proof["immune_wrapper_matches_module"] and proof["status_applied"] and proof["immune_status_not_applied"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("StatusApplyModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
