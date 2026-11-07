extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_text := preload("res://src/game/SourceUnitBuildingCommandSourceTextState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var target := Vector2(17.0, 29.0)
	var results: Array = []
	for class_name_value in source_text.SOURCE_UNIT_BUILDING_CLASS_NAMES:
		var source_path := str(source_text.SOURCE_UNIT_BUILDING_SOURCE_PATHS[class_name_value])
		var on_command := game.generated_unit_building_on_command_bridge_state(class_name_value, source_path, target)
		var command_position := game.generated_unit_building_get_command_position_bridge_state(class_name_value, source_path, target)
		results.append({"class": class_name_value, "on_command": on_command, "command_position": command_position})
	var matches := true
	for result in results:
		matches = matches and bool(result.on_command.get("matches", false)) and bool(result.command_position.get("matches", false))
	var proof := {"module": "UNIT_BUILDING_COMMAND_MODULE_PROOF", "results": results, "matches": matches}
	runtime_proof_state.write_proof("UnitBuildingCommandModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
