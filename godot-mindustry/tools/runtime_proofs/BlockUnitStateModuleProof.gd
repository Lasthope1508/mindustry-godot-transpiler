extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_unit_state := preload("res://src/game/SourceBlockUnitState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var tile := {"name": "tile-alpha"}
	var ammof_bridge := game.generated_block_unit_comp_ammof_bridge_state(12.5)
	var tile_bridge := game.generated_block_unit_comp_tile_bridge_state(tile, 100.0, 64.0, 2.0, 8.0)
	var add_bridge := game.generated_block_unit_comp_add_bridge_state(true)
	var team_bridge := game.generated_block_unit_comp_team_bridge_state(true, "blue", "red", "green")
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
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
	var proof_json := JSON.stringify(proof)
	print("BLOCK_UNIT_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockUnitStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
