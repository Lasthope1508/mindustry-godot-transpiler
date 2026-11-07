extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_serialization_state := preload("res://src/game/SourceBuildingSerializationState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var facade := game.source_building_version_state()
	var module := source_building_serialization_state.version_state()
	var generated := game.generated_building_comp_version_bridge_state()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BuildingVersionModuleProof",
		"facade_matches": facade == module,
		"version_is_zero": int(module.get("version", -1)) == 0,
		"generated_matches": bool(generated.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["facade_matches"] and proof["version_is_zero"] and proof["generated_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BuildingVersionModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
