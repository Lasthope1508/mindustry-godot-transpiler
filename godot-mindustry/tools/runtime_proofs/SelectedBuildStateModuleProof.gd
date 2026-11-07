extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var build_palette := [{"properties": {"hasPower": true}}]
	var selected := source_selected_build_state.selected_build(build_palette, 0)
	var selected_build_matches: bool = selected == build_palette[0]
	var has_power_matches: bool = source_selected_build_state.has_power(selected) == true
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceSelectedBuildState",
		"selected_build_matches": selected_build_matches,
		"has_power_matches": has_power_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["selected_build_matches"] and proof["has_power_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("SELECTED_BUILD_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("SelectedBuildStateModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

