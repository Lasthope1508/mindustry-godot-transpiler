extends Node

const source_power_generator_state := preload("res://src/game/SourcePowerGeneratorState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var random_angle_units := [0.25, 0.75]
	var random_range_units := [0.5, 1.0]
	var canonical := source_power_generator_state.create_explosion_puddle_vector_state(true, "water", 2, 16.0, random_angle_units, random_range_units)
	var result := source_power_generator_state.create_explosion_puddle_vector_state(true, "water", 2, 16.0, random_angle_units, random_range_units)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourcePowerGeneratorState",
		"puddle_vector_matches": result == canonical and bool(result.get("tmp_v1_vectors", []).size() == 2),
		"full_circle_matches": float(result.get("random_angle_range", 0.0)) == source_math_defaults.FULL_CIRCLE_DEGREES,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["puddle_vector_matches"] and proof["full_circle_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("POWER_GENERATOR_PUDDLE_VECTOR_MODULE_PROOF " + JSON.stringify(proof))
	var proof_json := JSON.stringify(proof)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/PowerGeneratorPuddleVectorModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.close()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
