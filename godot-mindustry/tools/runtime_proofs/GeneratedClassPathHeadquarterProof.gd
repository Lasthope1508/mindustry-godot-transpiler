extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_generated_class_path_headquarter := preload("res://src/game/SourceGeneratedClassPathHeadquarter.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_consume_base_source_text_state := preload("res://src/game/SourceConsumeBaseSourceTextState.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")


func _ready() -> void:
	var registry_state := source_generated_class_path_headquarter.registry_state()
	var headquarter_registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var turret_lookup := source_generated_class_path_headquarter.lookup_by_generated_path(source_turret_source_text_state.SOURCE_TURRET_GENERATED_CLASS)
	var consume_lookup := source_generated_class_path_headquarter.lookup_by_constant("SOURCE_CONSUME_GENERATED_CLASS")
	var proof := {
		"entry_count": 53,
		"runtime_entry_count": int(registry_state.get("entry_count", 0)),
		"owner_count": int(registry_state.get("owner_count", 0)),
		"generated_path_count": int(registry_state.get("generated_path_count", 0)),
		"duplicate_generated_paths": registry_state.get("duplicate_generated_paths", []),
		"duplicate_owner_constants": registry_state.get("duplicate_owner_constants", []),
		"registry_valid": bool(registry_state.get("valid", false)),
		"turret_lookup_owner": str(turret_lookup.get("owner", "")),
		"consume_lookup_path": str(consume_lookup.get("generated_path", "")),
		"turret_lookup_matches": str(turret_lookup.get("constant", "")) == "SOURCE_TURRET_GENERATED_CLASS",
		"consume_lookup_matches": str(consume_lookup.get("generated_path", "")) == source_consume_base_source_text_state.SOURCE_CONSUME_GENERATED_CLASS,
		"one_headquarter_per_ssot": bool(headquarter_registry_state.get("one_headquarter_per_ssot", false)),
		"headquarter_registry_valid": bool(headquarter_registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["runtime_entry_count"] == proof["entry_count"] and proof["registry_valid"] and proof["turret_lookup_matches"] and proof["consume_lookup_matches"] and proof["one_headquarter_per_ssot"] and proof["headquarter_registry_valid"]
	print("GENERATED_CLASS_PATH_HEADQUARTER_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("GeneratedClassPathHeadquarterProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

