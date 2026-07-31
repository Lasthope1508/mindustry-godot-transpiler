extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_control_state := preload("res://src/game/SourceBuildingControlState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var control_enabled_state := source_building_control_state.control_enabled_state(true, "config", 0.0, 0.0)
	var control_config_state := source_building_control_state.control_config_state("config", true, false, 123)
	var control_enabled_bridge := game.generated_building_comp_control_enabled_bridge_state(true, "enabled", 1.0)
	var control_config_bridge := game.generated_building_comp_control_config_bridge_state("config", true, false, 123)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_CONTROL_STATE_MODULE_PROOF",
		"control_enabled_state": control_enabled_state,
		"control_config_state": control_config_state,
		"control_enabled_bridge": control_enabled_bridge,
		"control_config_bridge": control_config_bridge,
		"control_enabled_bridge_matches": control_enabled_bridge == source_building_control_state.generated_control_enabled_bridge_state(true, "enabled", 1.0, source_math_defaults.FLOAT_ROUNDING_ERROR),
		"control_config_bridge_matches": control_config_bridge == source_building_control_state.generated_control_config_bridge_state("config", true, false, 123),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["control_enabled_bridge_matches"] and proof["control_config_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_CONTROL_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildingControlStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
