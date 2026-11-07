extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_unit_state := preload("res://src/game/SourceBlockUnitState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var tile := {"name": "tile-alpha"}
	var ammof_bridge := game.generated_block_unit_comp_ammof_bridge_state(12.5)
	var tile_bridge := game.generated_block_unit_comp_tile_bridge_state(tile, 100.0, 64.0, 2.0, 8.0)
	var add_bridge := game.generated_block_unit_comp_add_bridge_state(true)
	var team_bridge := game.generated_block_unit_comp_team_bridge_state(true, "blue", "red", "green")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_UNIT_STATE_MODULE_PROOF",
		"ammof_bridge": ammof_bridge,
		"tile_bridge": tile_bridge,
		"add_bridge": add_bridge,
		"team_bridge": team_bridge,
		"ammof_bridge_matches": ammof_bridge == source_block_unit_state.generated_block_unit_comp_ammof_bridge_state(12.5),
		"tile_bridge_matches": tile_bridge == source_block_unit_state.generated_block_unit_comp_tile_bridge_state(tile, 100.0, 64.0, 2.0, 8.0),
		"add_bridge_matches": add_bridge == source_block_unit_state.generated_block_unit_comp_add_bridge_state(true),
		"team_bridge_matches": team_bridge == source_block_unit_state.generated_block_unit_comp_team_bridge_state(true, "blue", "red", "green"),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["ammof_bridge_matches"] and proof["tile_bridge_matches"] and proof["add_bridge_matches"] and proof["team_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BLOCK_UNIT_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BlockUnitStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

