extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBlockUnitState := preload("res://src/game/SourceBlockUnitState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var tile := {"name": "tile-alpha"}
	var ammof_bridge := game.generated_block_unit_comp_ammof_bridge_state(12.5)
	var tile_bridge := game.generated_block_unit_comp_tile_bridge_state(tile, 100.0, 64.0, 2.0, 8.0)
	var add_bridge := game.generated_block_unit_comp_add_bridge_state(true)
	var team_bridge := game.generated_block_unit_comp_team_bridge_state(true, "blue", "red", "green")
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_UNIT_STATE_MODULE_PROOF",
		"ammof_bridge": ammof_bridge,
		"tile_bridge": tile_bridge,
		"add_bridge": add_bridge,
		"team_bridge": team_bridge,
		"ammof_bridge_matches": ammof_bridge == SourceBlockUnitState.generated_block_unit_comp_ammof_bridge_state(12.5),
		"tile_bridge_matches": tile_bridge == SourceBlockUnitState.generated_block_unit_comp_tile_bridge_state(tile, 100.0, 64.0, 2.0, 8.0),
		"add_bridge_matches": add_bridge == SourceBlockUnitState.generated_block_unit_comp_add_bridge_state(true),
		"team_bridge_matches": team_bridge == SourceBlockUnitState.generated_block_unit_comp_team_bridge_state(true, "blue", "red", "green"),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["ammof_bridge_matches"] and proof["tile_bridge_matches"] and proof["add_bridge_matches"] and proof["team_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_UNIT_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BlockUnitStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
