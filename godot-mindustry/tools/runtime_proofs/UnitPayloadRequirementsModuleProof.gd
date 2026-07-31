extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_unit_payload_requirements_state_script := preload("res://src/game/SourceUnitPayloadRequirementsState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var unit_type := "flare"
	var total_requirements := [{"item": "copper", "amount": 5}]
	var build_time := 90.0
	var requirements_bridge := game.generated_unit_payload_requirements_bridge_state(unit_type, total_requirements)
	var build_time_bridge := game.generated_unit_payload_build_time_bridge_state(unit_type, build_time)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
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
	var proof_json := JSON.stringify(proof)
	print("UNIT_PAYLOAD_REQUIREMENTS_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/UnitPayloadRequirementsModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
