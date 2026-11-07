extends Node

const source_power_generator_state := preload("res://src/game/SourcePowerGeneratorState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var random_angle_units := [0.25, 0.75]
	var random_range_units := [0.5, 1.0]
	var canonical := source_power_generator_state.create_explosion_puddle_vector_state(true, "water", 2, 16.0, random_angle_units, random_range_units)
	var result := source_power_generator_state.create_explosion_puddle_vector_state(true, "water", 2, 16.0, random_angle_units, random_range_units)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourcePowerGeneratorState",
		"puddle_vector_matches": result == canonical and bool(result.get("tmp_v1_vectors", []).size() == 2),
		"full_circle_matches": float(result.get("random_angle_range", 0.0)) == source_math_defaults.FULL_CIRCLE_DEGREES,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["puddle_vector_matches"] and proof["full_circle_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("POWER_GENERATOR_PUDDLE_VECTOR_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PowerGeneratorPuddleVectorModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

