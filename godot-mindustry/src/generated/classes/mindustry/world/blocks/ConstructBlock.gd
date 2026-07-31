# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/ConstructBlock.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks"
const JAVA_KIND := "class"
const JAVA_NAME := "ConstructBlock"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "consBlocks", "type": "ConstructBlock"}, {"modifiers": ["private", "static"], "name": "lastTime", "type": "long"}, {"modifiers": ["private", "static"], "name": "pitchSeq", "type": "int"}, {"modifiers": ["private", "static"], "name": "lastPlayed", "type": "long"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConstructBlock", "parameters": [{"name": "size", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "get", "parameters": [{"name": "size", "type": "int", "varargs": false}], "return_type": "ConstructBlock"}, {"modifiers": ["public", "static"], "name": "deconstructFinish", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "constructFinish", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "byte", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "shouldPlay", "parameters": [], "return_type": "boolean"}, {"modifiers": ["static"], "name": "calcPitch", "parameters": [{"name": "up", "type": "boolean", "varargs": false}], "return_type": "float"}, {"modifiers": ["public", "static"], "name": "playRepairSound", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "constructed", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "byte", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_building_destruction_state := preload("res://src/game/SourceBuildingDestructionState.gd")
const source_construct_block_state := preload("res://src/game/SourceConstructBlockState.gd")

func java_method_get_0(_args: Array = []) -> Variant:
	var size: int = int(_args[0] if _args.size() > 0 else source_block_defaults.SIZE_DEFAULT)
	var max_block_size: int = int(_args[1] if _args.size() > 1 else source_block_defaults.SIZE_DEFAULT)
	return source_construct_block_state.get_state(size, max_block_size)

func java_method_deconstructFinish_1(_args: Array = []) -> Variant:
	var tile_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var headless: bool = bool(_args[1] if _args.size() > 1 else false)
	var visible_tile: bool = bool(_args[2] if _args.size() > 2 else false)
	var should_play: bool = bool(_args[3] if _args.size() > 3 else false)
	var break_pitch_change: bool = bool(_args[4] if _args.size() > 4 else false)
	var calc_pitch_down: float = float(_args[5] if _args.size() > 5 else 1.0)
	var block_size: int = int(_args[6] if _args.size() > 6 else source_block_defaults.SIZE_DEFAULT)
	var block_map_color: Variant = _args[7] if _args.size() > 7 else null
	return source_building_destruction_state.construct_block_deconstruct_finish_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, block_size, block_map_color)

func java_method_constructFinish_2(_args: Array = []) -> Variant:
	var tile_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var block_kind: String = str(_args[1] if _args.size() > 1 else "")
	var tile_has_building: bool = bool(_args[2] if _args.size() > 2 else false)
	var tile_build_matches_block: bool = bool(_args[3] if _args.size() > 3 else false)
	var healthf: float = float(_args[4] if _args.size() > 4 else 1.0)
	var prev_build_count: int = int(_args[5] if _args.size() > 5 else 0)
	var floor_supports_overlay: bool = bool(_args[6] if _args.size() > 6 else false)
	var current_overlay_is_overlay_floor: bool = bool(_args[7] if _args.size() > 7 else false)
	var config_present: bool = bool(_args[8] if _args.size() > 8 else false)
	var builder_has_controller_name: bool = bool(_args[9] if _args.size() > 9 else false)
	var controller_name: String = str(_args[10] if _args.size() > 10 else "")
	var headless: bool = bool(_args[11] if _args.size() > 11 else false)
	var builder_is_player_unit: bool = bool(_args[12] if _args.size() > 12 else false)
	var visible_tile: bool = bool(_args[13] if _args.size() > 13 else false)
	var should_play: bool = bool(_args[14] if _args.size() > 14 else false)
	var place_pitch_change: bool = bool(_args[15] if _args.size() > 15 else false)
	var calc_pitch_up: float = float(_args[16] if _args.size() > 16 else 1.0)
	var block_size: int = int(_args[17] if _args.size() > 17 else source_block_defaults.SIZE_DEFAULT)
	var block_health: float = float(_args[18] if _args.size() > 18 else source_block_defaults.HEALTH_DEFAULT)
	var rotation: int = int(_args[19] if _args.size() > 19 else 0)
	var config_state: Variant = _args[20] if _args.size() > 20 else null
	return source_building_destruction_state.construct_block_construct_finish_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, block_size, block_health, rotation, config_state)

func java_method_shouldPlay_3(_args: Array = []) -> Variant:
	var time_since_last_played_ms: int = int(_args[0] if _args.size() > 0 else 0)
	var current_millis: int = int(_args[1] if _args.size() > 1 else 0)
	return source_construct_block_state.should_play_state(time_since_last_played_ms, current_millis)

func java_method_calcPitch_4(_args: Array = []) -> Variant:
	var up: bool = bool(_args[0] if _args.size() > 0 else false)
	var time_since_last_time_ms: int = int(_args[1] if _args.size() > 1 else 0)
	var current_millis: int = int(_args[2] if _args.size() > 2 else 0)
	var pitch_seq_before: int = int(_args[3] if _args.size() > 3 else 0)
	var random_pitch: float = float(_args[4] if _args.size() > 4 else source_construct_block_state.CONSTRUCT_BLOCK_RANDOM_PITCH_MIN)
	return source_construct_block_state.calc_pitch_state(up, time_since_last_time_ms, current_millis, pitch_seq_before, random_pitch)

func java_method_playRepairSound_5(_args: Array = []) -> Variant:
	var headless: bool = bool(_args[0] if _args.size() > 0 else false)
	var should_play: bool = bool(_args[1] if _args.size() > 1 else false)
	var visible_tile: bool = bool(_args[2] if _args.size() > 2 else false)
	var calc_pitch_up: float = float(_args[3] if _args.size() > 3 else 1.0)
	return source_construct_block_state.play_repair_sound_state(headless, should_play, visible_tile, calc_pitch_up)

func java_method_constructed_6(_args: Array = []) -> Variant:
	var tile_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var block_kind: String = str(_args[1] if _args.size() > 1 else "")
	var tile_has_building: bool = bool(_args[2] if _args.size() > 2 else false)
	var tile_build_matches_block: bool = bool(_args[3] if _args.size() > 3 else false)
	var healthf: float = float(_args[4] if _args.size() > 4 else 1.0)
	var prev_build_count: int = int(_args[5] if _args.size() > 5 else 0)
	var floor_supports_overlay: bool = bool(_args[6] if _args.size() > 6 else false)
	var current_overlay_is_overlay_floor: bool = bool(_args[7] if _args.size() > 7 else false)
	var config_present: bool = bool(_args[8] if _args.size() > 8 else false)
	var builder_has_controller_name: bool = bool(_args[9] if _args.size() > 9 else false)
	var controller_name: String = str(_args[10] if _args.size() > 10 else "")
	var headless: bool = bool(_args[11] if _args.size() > 11 else false)
	var builder_is_player_unit: bool = bool(_args[12] if _args.size() > 12 else false)
	var visible_tile: bool = bool(_args[13] if _args.size() > 13 else false)
	var should_play: bool = bool(_args[14] if _args.size() > 14 else false)
	var place_pitch_change: bool = bool(_args[15] if _args.size() > 15 else false)
	var calc_pitch_up: float = float(_args[16] if _args.size() > 16 else 1.0)
	var block_size: int = int(_args[17] if _args.size() > 17 else source_block_defaults.SIZE_DEFAULT)
	var block_health: float = float(_args[18] if _args.size() > 18 else source_block_defaults.HEALTH_DEFAULT)
	var rotation: int = int(_args[19] if _args.size() > 19 else 0)
	var config_state: Variant = _args[20] if _args.size() > 20 else null
	var tile_has_building_after_construct_finish: bool = bool(_args[21] if _args.size() > 21 else false)
	return source_building_destruction_state.construct_block_constructed_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, block_size, block_health, rotation, config_state, tile_has_building_after_construct_finish)

func java_method_isHidden_7(_args: Array = []) -> Variant:
	return source_construct_block_state.is_hidden_state()
