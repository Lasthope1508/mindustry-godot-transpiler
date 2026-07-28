extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingControlState := preload("res://src/game/SourceBuildingControlState.gd")
const SourceMathDefaults := preload("res://src/game/SourceMathDefaults.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var control_enabled_state := SourceBuildingControlState.control_enabled_state(true, "config", 0.0, 0.0)
	var control_config_state := SourceBuildingControlState.control_config_state("config", true, false, 123)
	var control_enabled_bridge := game.generated_building_comp_control_enabled_bridge_state(true, "enabled", 1.0)
	var control_config_bridge := game.generated_building_comp_control_config_bridge_state("config", true, false, 123)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_CONTROL_STATE_MODULE_PROOF",
		"control_enabled_state": control_enabled_state,
		"control_config_state": control_config_state,
		"control_enabled_bridge": control_enabled_bridge,
		"control_config_bridge": control_config_bridge,
		"control_enabled_bridge_matches": control_enabled_bridge == SourceBuildingControlState.generated_control_enabled_bridge_state(true, "enabled", 1.0, SourceMathDefaults.FLOAT_ROUNDING_ERROR),
		"control_config_bridge_matches": control_config_bridge == SourceBuildingControlState.generated_control_config_bridge_state("config", true, false, 123),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["control_enabled_bridge_matches"] and proof["control_config_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_CONTROL_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuildingControlStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
