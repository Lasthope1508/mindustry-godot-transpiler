extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_world_initial_build_runtime_state := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")

const expected_build_world_constants := {
	"NODE_PATH_WORLD_TERRAIN_LAYER": "World/TerrainLayer",
	"NODE_PATH_WORLD_BLOCK_LAYER": "World/BlockLayer",
	"NODE_PATH_WORLD_UNIT_LAYER": "World/UnitLayer",
	"PROP_PLACED_BLOCK_ORIGINS": "placed_block_origins",
	"PROP_PLACED_BLOCKS": "placed_blocks",
	"PROP_PATH_POINTS": "path_points",
	"PROP_ORE_ITEMS_BY_CELL": "ore_items_by_cell",
	"PROP_DRILL_POS": "drill_pos",
	"PROP_DRILL_OUTPUT_ITEM_ID": "drill_output_item_id",
	"PROP_DRILL_ORE_CELL_COUNT": "drill_ore_cell_count",
	"PROP_DRILL_OUTPUT_RATE": "drill_output_rate",
	"PROP_CORE_MAX_HEALTH": "core_max_health",
	"PROP_CORE_HEALTH": "core_health",
	"PROP_CORE_ITEM_CAPACITY": "core_item_capacity",
	"PROP_CONVEYOR_WORLD_SPEED": "conveyor_world_speed",
	"PROP_CONVEYOR_PATH_PROGRESS_RATE": "conveyor_path_progress_rate",
	"PROP_BOOTSTRAPPED_SELECTED_TURRET_AMMO_LOAD_COUNT": "bootstrapped_selected_turret_ammo_load_count",
	"PROP_INITIAL_WORLD_BLOCK_COUNT": "initial_world_block_count",
	"PROP_INITIAL_OCCUPIED_CELL_COUNT": "initial_occupied_cell_count",
	"METHOD_SOURCE_WORLD_TERRAIN_RUNTIME_STATE": "source_world_terrain_runtime_state",
	"METHOD_SOURCE_DRILL_ORE_COUNT": "source_drill_ore_count",
	"METHOD_SOURCE_DRILL_OUTPUT_RATE": "source_drill_output_rate",
	"METHOD_ADD_SPRITE": "add_sprite",
	"METHOD_ADD_SOURCE_TILE_BATCH": "add_source_tile_batch",
	"METHOD_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE": "source_world_initial_build_runtime_state",
	"METHOD_ADD_SOURCE_BLOCK": "add_source_block",
	"METHOD_ADD_SOURCE_BLOCK_BATCH": "add_source_block_batch",
	"METHOD_SOURCE_ITEM_TRANSPORT_BOOTSTRAP_STATE": "source_item_transport_bootstrap_state",
	"METHOD_SOURCE_BLOCK_HEALTH": "source_block_health",
	"METHOD_SOURCE_BLOCK_ITEM_CAPACITY": "source_block_item_capacity",
	"METHOD_SOURCE_CONVEYOR_WORLD_SPEED": "source_conveyor_world_speed",
	"METHOD_SOURCE_CONVEYOR_PATH_PROGRESS_RATE": "source_conveyor_path_progress_rate",
	"METHOD_BOOTSTRAP_SELECTED_TURRET_AMMO": "bootstrap_selected_turret_ammo",
	"METHOD_SOURCE_CAMPAIGN_LAUNCH_CONTEXT_STATE": "source_campaign_launch_context_state",
	"METHOD_SOURCE_CAMPAIGN_MAP_FILE_STATE": "source_campaign_map_file_state",
	"METHOD_SOURCE_CAMPAIGN_MAP_CONTENT_HEADER_STATE": "source_campaign_map_content_header_state",
	"METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE": "source_campaign_map_tile_state",
	"KEY_BLOCK_PLACEMENTS": "block_placements",
	"KEY_PATH_POINTS": "path_points",
	"KEY_BLOCK_COUNT": "block_count",
	"KEY_CONVEYOR_COUNT": "conveyor_count",
	"KEY_PATH_POINT_COUNT": "path_point_count",
	"KEY_CAMPAIGN_LAUNCH_CONTEXT": "campaign_launch_context",
	"KEY_CAMPAIGN_MAP_FILE": "campaign_map_file",
	"KEY_CAMPAIGN_MAP_CONTENT_HEADER": "campaign_map_content_header",
	"KEY_CAMPAIGN_MAP_TILE": "campaign_map_tile",
	"KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_COUNT": "campaign_map_block_placement_count",
	"KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_NAME_COUNTS": "campaign_map_block_placement_name_counts",
	"KEY_STATIC_BLOCK_BATCHES": "static_block_batches",
	"KEY_DYNAMIC_BLOCK_PLACEMENTS": "dynamic_block_placements",
	"KEY_TERRAIN_BATCHES": "terrain_batches",
	"KEY_ORE_BATCHES": "ore_batches",
	"KEY_SOURCE_OWNER": "source_owner",
	"KEY_KEY": "key",
	"KEY_ROLE": "role",
	"KEY_CELL": "cell",
	"KEY_X": "x",
	"KEY_Y": "y",
	"KEY_TERRAIN_SPRITES": "terrain_sprites",
	"KEY_ORE_SPRITES": "ore_sprites",
	"KEY_ITEM_SPRITES": "item_sprites",
	"KEY_VISIBLE": "visible",
}

class FakeInitialBuildGame extends RefCounted:
	var tile_size := 8
	var drill_pos := source_playable_scenario_defaults.DRILL_POS
	var core_pos := source_playable_scenario_defaults.CORE_POS
	var duo_pos := source_playable_scenario_defaults.DUO_POS

func _ready() -> void:
	var fake_game := FakeInitialBuildGame.new()
	var drill_cell := Vector2i(7, 8)
	var conveyor_cells: Array[Vector2i] = [Vector2i(8, 8), Vector2i(9, 8)]
	var core_cell := Vector2i(17, 8)
	var duo_cell := Vector2i(18, 7)
	var path_points_input: Array[Vector2] = [Vector2(56.0, 64.0), Vector2(64.0, 64.0), Vector2(72.0, 64.0)]
	var state := source_world_initial_build_runtime_state.initial_build_plan_state(
		drill_cell,
		conveyor_cells,
		core_cell,
		duo_cell,
		source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL,
		source_playable_scenario_defaults.BLOCK_CONVEYOR,
		source_playable_scenario_defaults.BLOCK_CORE_SHARD,
		source_playable_scenario_defaults.BLOCK_DUO,
		path_points_input,
		8
	)
	var game_state := source_world_initial_build_runtime_state.game_initial_build_plan_state(fake_game)
	var game_path_points := source_world_initial_build_runtime_state.game_path_points(fake_game)
	var placements: Array = state.get(source_world_initial_build_runtime_state.KEY_BLOCK_PLACEMENTS, [])
	var game_placements: Array = game_state.get(source_world_initial_build_runtime_state.KEY_BLOCK_PLACEMENTS, [])
	var roles: Array[String] = []
	var keys: Array[String] = []
	for placement in placements:
		roles.append(str(placement.get(source_world_initial_build_runtime_state.KEY_ROLE, "")))
		keys.append(str(placement.get(source_world_initial_build_runtime_state.KEY_KEY, "")))
	var expected_roles: Array[String] = [
		source_playable_scenario_defaults.INITIAL_BUILD_ROLE_DRILL,
		source_playable_scenario_defaults.INITIAL_BUILD_ROLE_CONVEYOR,
		source_playable_scenario_defaults.INITIAL_BUILD_ROLE_CONVEYOR,
		source_playable_scenario_defaults.INITIAL_BUILD_ROLE_CORE,
		source_playable_scenario_defaults.INITIAL_BUILD_ROLE_DUO,
	]
	var expected_keys: Array[String] = [
		source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL,
		source_playable_scenario_defaults.BLOCK_CONVEYOR,
		source_playable_scenario_defaults.BLOCK_CONVEYOR,
		source_playable_scenario_defaults.BLOCK_CORE_SHARD,
		source_playable_scenario_defaults.BLOCK_DUO,
	]
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceWorldInitialBuildRuntimeState",
		"build_world_constants_match": {
			"NODE_PATH_WORLD_TERRAIN_LAYER": source_world_initial_build_runtime_state.NODE_PATH_WORLD_TERRAIN_LAYER,
			"NODE_PATH_WORLD_BLOCK_LAYER": source_world_initial_build_runtime_state.NODE_PATH_WORLD_BLOCK_LAYER,
			"NODE_PATH_WORLD_UNIT_LAYER": source_world_initial_build_runtime_state.NODE_PATH_WORLD_UNIT_LAYER,
			"PROP_PLACED_BLOCK_ORIGINS": source_world_initial_build_runtime_state.PROP_PLACED_BLOCK_ORIGINS,
			"PROP_PLACED_BLOCKS": source_world_initial_build_runtime_state.PROP_PLACED_BLOCKS,
			"PROP_PATH_POINTS": source_world_initial_build_runtime_state.PROP_PATH_POINTS,
			"PROP_ORE_ITEMS_BY_CELL": source_world_initial_build_runtime_state.PROP_ORE_ITEMS_BY_CELL,
			"PROP_DRILL_POS": source_world_initial_build_runtime_state.PROP_DRILL_POS,
			"PROP_DRILL_OUTPUT_ITEM_ID": source_world_initial_build_runtime_state.PROP_DRILL_OUTPUT_ITEM_ID,
			"PROP_DRILL_ORE_CELL_COUNT": source_world_initial_build_runtime_state.PROP_DRILL_ORE_CELL_COUNT,
			"PROP_DRILL_OUTPUT_RATE": source_world_initial_build_runtime_state.PROP_DRILL_OUTPUT_RATE,
			"PROP_CORE_MAX_HEALTH": source_world_initial_build_runtime_state.PROP_CORE_MAX_HEALTH,
			"PROP_CORE_HEALTH": source_world_initial_build_runtime_state.PROP_CORE_HEALTH,
			"PROP_CORE_ITEM_CAPACITY": source_world_initial_build_runtime_state.PROP_CORE_ITEM_CAPACITY,
			"PROP_CONVEYOR_WORLD_SPEED": source_world_initial_build_runtime_state.PROP_CONVEYOR_WORLD_SPEED,
			"PROP_CONVEYOR_PATH_PROGRESS_RATE": source_world_initial_build_runtime_state.PROP_CONVEYOR_PATH_PROGRESS_RATE,
			"PROP_BOOTSTRAPPED_SELECTED_TURRET_AMMO_LOAD_COUNT": source_world_initial_build_runtime_state.PROP_BOOTSTRAPPED_SELECTED_TURRET_AMMO_LOAD_COUNT,
			"PROP_INITIAL_WORLD_BLOCK_COUNT": source_world_initial_build_runtime_state.PROP_INITIAL_WORLD_BLOCK_COUNT,
			"PROP_INITIAL_OCCUPIED_CELL_COUNT": source_world_initial_build_runtime_state.PROP_INITIAL_OCCUPIED_CELL_COUNT,
		"METHOD_SOURCE_WORLD_TERRAIN_RUNTIME_STATE": source_world_initial_build_runtime_state.METHOD_SOURCE_WORLD_TERRAIN_RUNTIME_STATE,
		"METHOD_SOURCE_DRILL_ORE_COUNT": source_world_initial_build_runtime_state.METHOD_SOURCE_DRILL_ORE_COUNT,
		"METHOD_SOURCE_DRILL_OUTPUT_RATE": source_world_initial_build_runtime_state.METHOD_SOURCE_DRILL_OUTPUT_RATE,
		"METHOD_ADD_SPRITE": source_world_initial_build_runtime_state.METHOD_ADD_SPRITE,
		"METHOD_ADD_SOURCE_TILE_BATCH": source_world_initial_build_runtime_state.METHOD_ADD_SOURCE_TILE_BATCH,
		"METHOD_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE": source_world_initial_build_runtime_state.METHOD_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE,
		"METHOD_ADD_SOURCE_BLOCK": source_world_initial_build_runtime_state.METHOD_ADD_SOURCE_BLOCK,
		"METHOD_ADD_SOURCE_BLOCK_BATCH": source_world_initial_build_runtime_state.METHOD_ADD_SOURCE_BLOCK_BATCH,
		"METHOD_SOURCE_ITEM_TRANSPORT_BOOTSTRAP_STATE": source_world_initial_build_runtime_state.METHOD_SOURCE_ITEM_TRANSPORT_BOOTSTRAP_STATE,
		"METHOD_SOURCE_BLOCK_HEALTH": source_world_initial_build_runtime_state.METHOD_SOURCE_BLOCK_HEALTH,
		"METHOD_SOURCE_BLOCK_ITEM_CAPACITY": source_world_initial_build_runtime_state.METHOD_SOURCE_BLOCK_ITEM_CAPACITY,
		"METHOD_SOURCE_CONVEYOR_WORLD_SPEED": source_world_initial_build_runtime_state.METHOD_SOURCE_CONVEYOR_WORLD_SPEED,
		"METHOD_SOURCE_CONVEYOR_PATH_PROGRESS_RATE": source_world_initial_build_runtime_state.METHOD_SOURCE_CONVEYOR_PATH_PROGRESS_RATE,
		"METHOD_BOOTSTRAP_SELECTED_TURRET_AMMO": source_world_initial_build_runtime_state.METHOD_BOOTSTRAP_SELECTED_TURRET_AMMO,
		"METHOD_SOURCE_CAMPAIGN_LAUNCH_CONTEXT_STATE": source_world_initial_build_runtime_state.METHOD_SOURCE_CAMPAIGN_LAUNCH_CONTEXT_STATE,
		"METHOD_SOURCE_CAMPAIGN_MAP_FILE_STATE": source_world_initial_build_runtime_state.METHOD_SOURCE_CAMPAIGN_MAP_FILE_STATE,
		"METHOD_SOURCE_CAMPAIGN_MAP_CONTENT_HEADER_STATE": source_world_initial_build_runtime_state.METHOD_SOURCE_CAMPAIGN_MAP_CONTENT_HEADER_STATE,
		"METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE": source_world_initial_build_runtime_state.METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE,
		"KEY_BLOCK_PLACEMENTS": source_world_initial_build_runtime_state.KEY_BLOCK_PLACEMENTS,
		"KEY_PATH_POINTS": source_world_initial_build_runtime_state.KEY_PATH_POINTS,
		"KEY_BLOCK_COUNT": source_world_initial_build_runtime_state.KEY_BLOCK_COUNT,
		"KEY_CONVEYOR_COUNT": source_world_initial_build_runtime_state.KEY_CONVEYOR_COUNT,
		"KEY_PATH_POINT_COUNT": source_world_initial_build_runtime_state.KEY_PATH_POINT_COUNT,
		"KEY_CAMPAIGN_LAUNCH_CONTEXT": source_world_initial_build_runtime_state.KEY_CAMPAIGN_LAUNCH_CONTEXT,
		"KEY_CAMPAIGN_MAP_FILE": source_world_initial_build_runtime_state.KEY_CAMPAIGN_MAP_FILE,
		"KEY_SOURCE_OWNER": source_world_initial_build_runtime_state.KEY_SOURCE_OWNER,
		"KEY_KEY": source_world_initial_build_runtime_state.KEY_KEY,
		"KEY_ROLE": source_world_initial_build_runtime_state.KEY_ROLE,
		"KEY_CELL": source_world_initial_build_runtime_state.KEY_CELL,
		"KEY_X": source_world_initial_build_runtime_state.KEY_X,
		"KEY_Y": source_world_initial_build_runtime_state.KEY_Y,
		"KEY_TERRAIN_SPRITES": source_world_initial_build_runtime_state.KEY_TERRAIN_SPRITES,
		"KEY_ORE_SPRITES": source_world_initial_build_runtime_state.KEY_ORE_SPRITES,
		"KEY_ITEM_SPRITES": source_world_initial_build_runtime_state.KEY_ITEM_SPRITES,
		"KEY_VISIBLE": source_world_initial_build_runtime_state.KEY_VISIBLE,
		"KEY_CAMPAIGN_MAP_CONTENT_HEADER": source_world_initial_build_runtime_state.KEY_CAMPAIGN_MAP_CONTENT_HEADER,
		"KEY_CAMPAIGN_MAP_TILE": source_world_initial_build_runtime_state.KEY_CAMPAIGN_MAP_TILE,
		"KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_COUNT": source_world_initial_build_runtime_state.KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_COUNT,
		"KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_NAME_COUNTS": source_world_initial_build_runtime_state.KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_NAME_COUNTS,
		"KEY_STATIC_BLOCK_BATCHES": source_world_initial_build_runtime_state.KEY_STATIC_BLOCK_BATCHES,
		"KEY_DYNAMIC_BLOCK_PLACEMENTS": source_world_initial_build_runtime_state.KEY_DYNAMIC_BLOCK_PLACEMENTS,
		"KEY_TERRAIN_BATCHES": source_world_initial_build_runtime_state.KEY_TERRAIN_BATCHES,
		"KEY_ORE_BATCHES": source_world_initial_build_runtime_state.KEY_ORE_BATCHES,
	} == expected_build_world_constants,
		"roles_match": roles == expected_roles,
		"keys_match": keys == expected_keys,
		"block_count_matches": int(state.get(source_world_initial_build_runtime_state.KEY_BLOCK_COUNT, -1)) == placements.size() and placements.size() == 5,
		"conveyor_count_matches": int(state.get(source_world_initial_build_runtime_state.KEY_CONVEYOR_COUNT, -1)) == conveyor_cells.size(),
		"path_point_count_matches": int(state.get(source_world_initial_build_runtime_state.KEY_PATH_POINT_COUNT, -1)) == path_points_input.size(),
		"game_path_points_match": game_path_points == source_playable_scenario_defaults.path_points(fake_game.tile_size),
		"game_plan_matches": int(game_state.get(source_world_initial_build_runtime_state.KEY_CONVEYOR_COUNT, -1)) == source_playable_scenario_defaults.conveyor_cells().size() and int(game_state.get(source_world_initial_build_runtime_state.KEY_PATH_POINT_COUNT, -1)) == game_path_points.size() and game_placements.size() == source_playable_scenario_defaults.conveyor_cells().size() + 3,
		"source_owner_matches": str(state.get(source_world_initial_build_runtime_state.KEY_SOURCE_OWNER, "")) == source_runtime_owner_registry.PORT_GAME_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["build_world_constants_match"] and proof["roles_match"] and proof["keys_match"] and proof["block_count_matches"] and proof["conveyor_count_matches"] and proof["path_point_count_matches"] and proof["game_path_points_match"] and proof["game_plan_matches"] and proof["source_owner_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("WORLD_INITIAL_BUILD_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("WorldInitialBuildRuntimeStateModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

