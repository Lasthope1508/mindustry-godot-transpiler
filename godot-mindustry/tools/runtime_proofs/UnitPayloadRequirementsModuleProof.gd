extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_unit_payload_requirements_state_script := preload("res://src/game/SourceUnitPayloadRequirementsState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var unit_type := "flare"
	var total_requirements := [{"item": "copper", "amount": 5}]
	var build_time := 90.0
	var requirements_bridge := game.generated_unit_payload_requirements_bridge_state(unit_type, total_requirements)
	var build_time_bridge := game.generated_unit_payload_build_time_bridge_state(unit_type, build_time)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "UNIT_PAYLOAD_REQUIREMENTS_MODULE_PROOF",
		"requirements_bridge": requirements_bridge,
		"build_time_bridge": build_time_bridge,
		"requirements_bridge_matches": requirements_bridge == source_unit_payload_requirements_state_script.generated_requirements_bridge_state(unit_type, total_requirements),
		"build_time_bridge_matches": build_time_bridge == source_unit_payload_requirements_state_script.generated_build_time_bridge_state(unit_type, build_time),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(requirements_bridge.get("matches", false)) and bool(build_time_bridge.get("matches", false)) and proof["requirements_bridge_matches"] and proof["build_time_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("UnitPayloadRequirementsModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

