extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_control_state := preload("res://src/game/SourceBuildingControlState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var control_enabled_state := source_building_control_state.control_enabled_state(true, "config", 0.0, 0.0)
	var control_config_state := source_building_control_state.control_config_state("config", true, false, 123)
	var player_state := {"id": "player"}
	var target_state := {"x": 14.0, "y": 22.0}
	var can_control_select_state := source_building_control_state.can_control_select_state(player_state)
	var on_control_select_state := source_building_control_state.on_control_select_state(player_state)
	var on_command_state := source_building_control_state.on_command_state(target_state)
	var get_command_position_state := source_building_control_state.get_command_position_state()
	var control_enabled_bridge := game.generated_building_comp_control_enabled_bridge_state(true, "enabled", 1.0)
	var control_config_bridge := game.generated_building_comp_control_config_bridge_state("config", true, false, 123)
	var can_control_select_bridge := game.generated_building_comp_can_control_select_bridge_state(player_state)
	var on_control_select_bridge := game.generated_building_comp_on_control_select_bridge_state(player_state)
	var on_command_bridge := game.generated_building_comp_on_command_bridge_state(target_state)
	var get_command_position_bridge := game.generated_building_comp_get_command_position_bridge_state()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_CONTROL_STATE_MODULE_PROOF",
		"control_enabled_state": control_enabled_state,
		"control_config_state": control_config_state,
		"can_control_select_state": can_control_select_state,
		"on_control_select_state": on_control_select_state,
		"on_command_state": on_command_state,
		"get_command_position_state": get_command_position_state,
		"control_enabled_bridge": control_enabled_bridge,
		"control_config_bridge": control_config_bridge,
		"control_enabled_bridge_matches": control_enabled_bridge == source_building_control_state.generated_control_enabled_bridge_state(true, "enabled", 1.0, source_math_defaults.FLOAT_ROUNDING_ERROR),
		"control_config_bridge_matches": control_config_bridge == source_building_control_state.generated_control_config_bridge_state("config", true, false, 123),
		"can_control_select_bridge_matches": can_control_select_bridge == source_building_control_state.generated_can_control_select_bridge_state(player_state),
		"on_control_select_bridge_matches": on_control_select_bridge == source_building_control_state.generated_on_control_select_bridge_state(player_state),
		"on_command_bridge_matches": on_command_bridge == source_building_control_state.generated_on_command_bridge_state(target_state),
		"get_command_position_bridge_matches": get_command_position_bridge == source_building_control_state.generated_get_command_position_bridge_state(),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["control_enabled_bridge_matches"] and proof["control_config_bridge_matches"] and proof["can_control_select_bridge_matches"] and proof["on_control_select_bridge_matches"] and proof["on_command_bridge_matches"] and proof["get_command_position_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_CONTROL_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingControlStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

