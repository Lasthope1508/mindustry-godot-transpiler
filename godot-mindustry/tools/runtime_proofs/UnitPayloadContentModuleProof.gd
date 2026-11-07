extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_unit_payload_content_state_script := preload("res://src/game/SourceUnitPayloadContentState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var unit_type := "flare"
	var other_unit_type := "flare"
	var unit := {"id": 7, "type": unit_type}
	var unit_holder := {"id": 1}
	var building_holder := {"id": 2}
	var content_equals_bridge := game.generated_unit_payload_content_equals_bridge_state(true, other_unit_type, unit_type)
	var update_bridge := game.generated_unit_payload_update_bridge_state(unit_type, unit, unit_holder, building_holder)
	var content_bridge := game.generated_unit_payload_content_bridge_state(unit_type)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "UNIT_PAYLOAD_CONTENT_MODULE_PROOF",
		"content_equals_bridge": content_equals_bridge,
		"update_bridge": update_bridge,
		"content_bridge": content_bridge,
		"content_equals_bridge_matches": content_equals_bridge == source_unit_payload_content_state_script.generated_content_equals_bridge_state(true, other_unit_type, unit_type),
		"update_bridge_matches": update_bridge == source_unit_payload_content_state_script.generated_update_bridge_state(unit_type, unit, unit_holder, building_holder),
		"content_bridge_matches": content_bridge == source_unit_payload_content_state_script.generated_content_bridge_state(unit_type),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(content_equals_bridge.get("matches", false)) and bool(update_bridge.get("matches", false)) and bool(content_bridge.get("matches", false)) and proof["content_equals_bridge_matches"] and proof["update_bridge_matches"] and proof["content_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("UnitPayloadContentModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

