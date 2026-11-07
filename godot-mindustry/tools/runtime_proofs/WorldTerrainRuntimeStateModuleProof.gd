extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_world_terrain_runtime_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")

const TILE_SIZE := 32
var tile_size := TILE_SIZE

func _ready() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var expected_background_cells := source_playable_scenario_defaults.background_cells_for_viewport(Vector2i(int(viewport_size.x), int(viewport_size.y)))
	var expected_ore_cells := source_playable_scenario_defaults.ore_copper_cells()
	var state := source_world_terrain_runtime_state.game_terrain_plan_state(self)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceWorldTerrainRuntimeState",
		"viewport_width": int(viewport_size.x),
		"viewport_height": int(viewport_size.y),
		"terrain_count": int(state.get("terrain_count", 0)),
		"ore_count": int(state.get("ore_count", 0)),
		"world_cell_count": int(state.get("world_cell_count", 0)),
		"terrain_count_matches": int(state.get("terrain_count", -1)) == expected_background_cells.size(),
		"ore_count_matches": int(state.get("ore_count", -1)) == expected_ore_cells.size(),
		"world_cell_count_matches": int(state.get("world_cell_count", -1)) == expected_background_cells.size(),
		"source_owner_matches": str(state.get("source_owner", "")) == "port_game.source_world_terrain_runtime_state",
		"ore_items_by_cell_matches": int(state.get("ore_items_by_cell", {}).size()) == expected_ore_cells.size(),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["terrain_count_matches"] and proof["ore_count_matches"] and proof["world_cell_count_matches"] and proof["source_owner_matches"] and proof["ore_items_by_cell_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("WORLD_TERRAIN_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("WorldTerrainRuntimeStateModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

