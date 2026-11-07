extends "res://src/game/SourceTractorBeamTurretBuildUpdateTileFlowPortBridge.gd"

const source_construct_block_state := preload("res://src/game/SourceConstructBlockState.gd")
const source_construct_block_generated_state := preload("res://src/game/SourceConstructBlockGeneratedState.gd")
const source_construct_build_state := preload("res://src/game/SourceConstructBuildState.gd")

func generated_construct_block_static_helpers_bridge_state(size: int, max_block_size: int, time_since_last_played_ms: int, current_millis: int, up: bool, time_since_last_time_ms: int, pitch_seq_before: int, random_pitch: float, headless: bool, visible_tile: bool) -> Dictionary:
	return source_construct_block_generated_state.generated_construct_block_static_helpers_bridge_state(size, max_block_size, time_since_last_played_ms, current_millis, up, time_since_last_time_ms, pitch_seq_before, random_pitch, headless, visible_tile)

func construct_block_deconstruct_finish_state(tile_present: bool, headless: bool, visible_tile: bool, should_play: bool, break_pitch_change: bool, calc_pitch_down: float, construct_block_size: int, block_map_color: Variant) -> Dictionary:
	return source_construct_block_state.construct_block_deconstruct_finish_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color)

func generated_construct_block_deconstruct_finish_bridge_state(tile_present: bool, headless: bool, visible_tile: bool, should_play: bool, break_pitch_change: bool, calc_pitch_down: float, construct_block_size: int, block_map_color: Variant) -> Dictionary:
	return source_construct_block_generated_state.generated_construct_block_deconstruct_finish_bridge_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color)

func construct_block_construct_finish_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant) -> Dictionary:
	return source_construct_block_state.construct_block_construct_finish_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state)

func generated_construct_block_construct_finish_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant) -> Dictionary:
	return source_construct_block_generated_state.generated_construct_block_construct_finish_bridge_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state)

func construct_block_constructed_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	return source_construct_block_state.construct_block_constructed_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish)

func generated_construct_block_constructed_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	return source_construct_block_generated_state.generated_construct_block_constructed_bridge_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish)

func construct_build_inner_runtime_state(current_solid: bool, previous_solid: bool, interactable_with_player_team: bool, current_is_placeable: bool, player_is_builder: bool, build_was_auto_paused: bool, input_is_building: bool, tile_x: int, tile_y: int, rotation_value: int, current_block: Variant, last_config: Variant, sensor: String, progress: float, active_deconstruct: bool, super_sense_value: float, super_sense_object_value: Variant, floor_solid: bool, floor_has_surface: bool, source_x: float, source_y: float, construct_build_block_size: int, current_is_air: bool, construct_color_before: float, source_delta: float) -> Dictionary:
	return source_construct_build_state.game_inner_runtime_state(self, current_solid, previous_solid, interactable_with_player_team, current_is_placeable, player_is_builder, build_was_auto_paused, input_is_building, tile_x, tile_y, rotation_value, current_block, last_config, sensor, progress, active_deconstruct, super_sense_value, super_sense_object_value, floor_solid, floor_has_surface, source_x, source_y, construct_build_block_size, current_is_air, construct_color_before, source_delta)

func construct_build_set_construct_state(previous_block: Variant, block: Variant, build_cost_multiplier: float) -> Dictionary:
	return source_construct_build_state.set_construct_state(previous_block, block, build_cost_multiplier)

func construct_build_set_deconstruct_state(previous_block: Variant, build_cost_multiplier: float) -> Dictionary:
	return source_construct_build_state.set_deconstruct_state(previous_block, build_cost_multiplier)

func construct_build_check_required_state(requirements: Array, inventory: Dictionary, accumulator: Array, items_left: Array, amount: float, remove: bool, build_cost_multiplier: float, team_infinite_resources: bool, state_infinite_resources: bool) -> Dictionary:
	return source_construct_build_state.check_required_state(requirements, inventory, accumulator, items_left, amount, remove, build_cost_multiplier, team_infinite_resources, state_infinite_resources)

func construct_build_construct_state(previous_block: Variant, current_block: Variant, builder_state: Variant, construct_core_inventory: Dictionary, amount: float, construct_config: Variant, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, core_present: bool, team_infinite_resources: bool, state_infinite_resources: bool, builder_is_player: bool, last_builder_present: bool, net_client: bool, rotation_value: int) -> Dictionary:
	return source_construct_build_state.construct_state(previous_block, current_block, builder_state, construct_core_inventory, amount, construct_config, progress_before, accumulator, total_accumulator, items_left, build_cost_multiplier, core_present, team_infinite_resources, state_infinite_resources, builder_is_player, last_builder_present, net_client, rotation_value)

func construct_build_deconstruct_state(current_block: Variant, builder_state: Variant, deconstruct_core_inventory: Dictionary, amount: float, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, deconstruct_refund_multiplier: float, core_present: bool, state_infinite_resources: bool, builder_is_player: bool, was_constructing: bool, last_builder_present: bool, core_storage_capacity: int) -> Dictionary:
	return source_construct_build_state.deconstruct_state(current_block, builder_state, deconstruct_core_inventory, amount, progress_before, accumulator, total_accumulator, items_left, build_cost_multiplier, deconstruct_refund_multiplier, core_present, state_infinite_resources, builder_is_player, was_constructing, last_builder_present, core_storage_capacity)

func construct_build_progress_state(progress_value: float) -> Dictionary:
	return source_construct_build_state.progress_state(progress_value)

func construct_build_version_state() -> Dictionary:
	return source_construct_build_state.version_state()

func construct_build_write_state(write_progress_value: float, write_previous_block_id: int, write_current_block_id: int, write_accumulator: Variant, write_total_accumulator: Variant, write_items_left: Variant) -> Dictionary:
	return source_construct_build_state.write_state(write_progress_value, write_previous_block_id, write_current_block_id, write_accumulator, write_total_accumulator, write_items_left)

func construct_build_read_state(read_progress_value: float, read_previous_block_id: int, read_current_block_id: int, read_accumulator_size: int, read_accumulator_values: Array, read_total_accumulator_values: Array, read_items_left_values: Array, read_revision_value: int, read_content_blocks: Dictionary, read_air_block: Variant, read_build_cost_multiplier: float) -> Dictionary:
	return source_construct_build_state.read_state(read_progress_value, read_previous_block_id, read_current_block_id, read_accumulator_size, read_accumulator_values, read_total_accumulator_values, read_items_left_values, read_revision_value, read_content_blocks, read_air_block, read_build_cost_multiplier)

func construct_build_draw_state(current_block: Variant, previous_block: Variant, draw_air_block: Variant, source_x: float, source_y: float, draw_rotation_degrees: float, draw_progress_value: float, draw_construct_color: float, source_time: float) -> Dictionary:
	return source_construct_build_state.draw_state(current_block, previous_block, draw_air_block, source_x, source_y, draw_rotation_degrees, draw_progress_value, draw_construct_color, source_time)
