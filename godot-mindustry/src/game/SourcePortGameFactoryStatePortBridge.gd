extends "res://src/game/SourcePortGameCombatStatePortBridge.gd"

const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_factory_defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const source_factory_runtime_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const source_factory_simulation_runtime_state_script := preload("res://src/game/SourceFactorySimulationRuntimeState.gd")
const source_factory_simulation_apply_state_script := preload("res://src/game/SourceFactorySimulationApplyState.gd")
const source_item_defaults := preload("res://src/game/SourceItemDefaults.gd")
const source_item_metadata_state := preload("res://src/game/SourceItemMetadataState.gd")

var drill_output_item_id := source_playable_scenario_defaults.ITEM_COPPER
var drill_ore_cell_count := 0
var drill_output_rate := 0.0
var drill_warmups: Dictionary = {}
var drill_time_drilled: Dictionary = {}
var drill_last_speeds: Dictionary = {}
var drill_items: Dictionary = {}
var drill_dump_timer := 0.0
var drill_dump_cursor := 0
var offload_neighbors: Array = []
var building_dump_accum := 0.0
var produced_total := 0
var item_progress := 0.0
var transport_progress := 0.0
var conveyor_world_speed := 0.0
var conveyor_path_progress_rate := 0.0
var item_sprites: Array[Sprite2D] = []
