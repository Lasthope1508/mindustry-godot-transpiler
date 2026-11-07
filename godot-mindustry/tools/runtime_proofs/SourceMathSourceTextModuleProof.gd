extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_math_source_text_state := preload("res://src/game/SourceMathSourceTextState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var alias_matches := source_math_state.SOURCE_MATHF_DST_METHOD == source_math_source_text_state.SOURCE_MATHF_DST_METHOD
	var approach_value := source_math_state.source_approach_delta(0.0, 10.0, 2.0, 0.5)
	var distance_value := source_math_state.source_dst(0.0, 0.0, 3.0, 4.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceMathSourceTextState",
		"alias_matches": alias_matches,
		"approach_delta_matches": approach_value == 1.0,
		"dst_matches": distance_value == 5.0,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["alias_matches"] and proof["approach_delta_matches"] and proof["dst_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("SOURCE_MATH_SOURCE_TEXT_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("SourceMathSourceTextModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
