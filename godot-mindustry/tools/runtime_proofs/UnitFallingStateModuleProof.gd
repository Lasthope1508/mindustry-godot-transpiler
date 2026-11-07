extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_unit_falling_state := preload("res://src/game/SourceUnitFallingState.gd")
const source_unit_environment_state := preload("res://src/game/SourceUnitEnvironmentState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var drag_module := source_unit_falling_state.falling_drag_state(true, 0.0, 0.7)
	var drag_facade := source_unit_environment_state.falling_drag_state(true, 0.0, 0.7)
	var smoke_module := source_unit_falling_state.falling_smoke_state(true, 0.0, true, 4.0, 5.0, 9.0, 0.25, 0.75)
	var smoke_facade := source_unit_environment_state.falling_smoke_state(true, 0.0, true, 4.0, 5.0, 9.0, 0.25, 0.75)
	var engine_module := source_unit_falling_state.falling_engine_trail_state(true, 0.0, true, 4.0, 5.0, 35.0, 0.5, 8.0, 3.0, 1.0, 0.25, 0.5, 0.75)
	var engine_facade := source_unit_environment_state.falling_engine_trail_state(true, 0.0, true, 4.0, 5.0, 35.0, 0.5, 8.0, 3.0, 1.0, 0.25, 0.5, 0.75)
	var descent_module := source_unit_falling_state.falling_descent_state(true, 0.0, 0.8, 0.2, 0.5, true, 100.0, 0.5, 42)
	var descent_facade := source_unit_environment_state.falling_descent_state(true, 0.0, 0.8, 0.2, 0.5, true, 100.0, 0.5, 42)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceUnitFallingState",
		"drag_matches": drag_module == drag_facade,
		"smoke_matches": smoke_module == smoke_facade,
		"falling_engine_trail_matches": engine_module == engine_facade,
		"descent_matches": descent_module == descent_facade,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["drag_matches"] and proof["smoke_matches"] and proof["falling_engine_trail_matches"] and proof["descent_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("UnitFallingStateModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

