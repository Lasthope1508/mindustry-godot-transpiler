extends Node

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var result := {"value": 1, "present": true}
	var canonical := {"value": 1, "present": true, "source_owner": "canonical.owner"}
	var ignored_result := {"value": 1}
	var ignored_canonical := {"value": 1, "volatile": 99, "source_owner": "canonical.owner"}
	var nan_result := {"nan": true, "identity": "same", "value": 0}
	var nan_canonical := {"nan": true, "identity": "same", "value": 1, "source_owner": "canonical.owner"}
	var subset_matches := source_generated_class_runtime.generated_state_matches_generated_subset_ignoring_source_owner(result, canonical)
	var ignored_extra_matches := source_generated_class_runtime.generated_state_matches_generated_subset_ignoring_source_owner(ignored_result, ignored_canonical, ["volatile"])
	var nan_matches := source_generated_class_runtime.generated_state_matches_generated_subset_or_nan_ignoring_source_owner(nan_result, nan_canonical, "nan", "identity")
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "GENERATED_CLASS_RUNTIME_MODULE_PROOF",
		"subset_matches": subset_matches,
		"ignored_extra_matches": ignored_extra_matches,
		"nan_matches": nan_matches,
		"module_matches": subset_matches and ignored_extra_matches and nan_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("GENERATED_CLASS_RUNTIME_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/GeneratedClassRuntimeModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
