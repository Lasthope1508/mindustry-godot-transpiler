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
const SourceBuildingDestructionState := preload("res://src/game/SourceBuildingDestructionState.gd")

func java_method_get_0(_args: Array = []) -> Variant:
	return null

func java_method_deconstructFinish_1(_args: Array = []) -> Variant:
	var tile_present := bool(_args[0] if _args.size() > 0 else false)
	var headless := bool(_args[1] if _args.size() > 1 else false)
	var visible_tile := bool(_args[2] if _args.size() > 2 else false)
	var should_play := bool(_args[3] if _args.size() > 3 else false)
	var break_pitch_change := bool(_args[4] if _args.size() > 4 else false)
	var calc_pitch_down := float(_args[5] if _args.size() > 5 else 1.0)
	var block_size := int(_args[6] if _args.size() > 6 else 0)
	var block_map_color: Variant = _args[7] if _args.size() > 7 else null
	return SourceBuildingDestructionState.construct_block_deconstruct_finish_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, block_size, block_map_color)

func java_method_constructFinish_2(_args: Array = []) -> Variant:
	var tile_present := bool(_args[0] if _args.size() > 0 else false)
	var block_kind := str(_args[1] if _args.size() > 1 else "")
	var tile_has_building := bool(_args[2] if _args.size() > 2 else false)
	var tile_build_matches_block := bool(_args[3] if _args.size() > 3 else false)
	var healthf := float(_args[4] if _args.size() > 4 else 1.0)
	var prev_build_count := int(_args[5] if _args.size() > 5 else 0)
	var floor_supports_overlay := bool(_args[6] if _args.size() > 6 else false)
	var current_overlay_is_overlay_floor := bool(_args[7] if _args.size() > 7 else false)
	var config_present := bool(_args[8] if _args.size() > 8 else false)
	var builder_has_controller_name := bool(_args[9] if _args.size() > 9 else false)
	var controller_name := str(_args[10] if _args.size() > 10 else "")
	var headless := bool(_args[11] if _args.size() > 11 else false)
	var builder_is_player_unit := bool(_args[12] if _args.size() > 12 else false)
	var visible_tile := bool(_args[13] if _args.size() > 13 else false)
	var should_play := bool(_args[14] if _args.size() > 14 else false)
	var place_pitch_change := bool(_args[15] if _args.size() > 15 else false)
	var calc_pitch_up := float(_args[16] if _args.size() > 16 else 1.0)
	var block_size := int(_args[17] if _args.size() > 17 else 0)
	var block_health := float(_args[18] if _args.size() > 18 else 0.0)
	var rotation := int(_args[19] if _args.size() > 19 else 0)
	var config_state: Variant = _args[20] if _args.size() > 20 else null
	return SourceBuildingDestructionState.construct_block_construct_finish_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, block_size, block_health, rotation, config_state)

func java_method_shouldPlay_3(_args: Array = []) -> Variant:
	return null

func java_method_calcPitch_4(_args: Array = []) -> Variant:
	return null

func java_method_playRepairSound_5(_args: Array = []) -> Variant:
	return null

func java_method_constructed_6(_args: Array = []) -> Variant:
	var tile_present := bool(_args[0] if _args.size() > 0 else false)
	var block_kind := str(_args[1] if _args.size() > 1 else "")
	var tile_has_building := bool(_args[2] if _args.size() > 2 else false)
	var tile_build_matches_block := bool(_args[3] if _args.size() > 3 else false)
	var healthf := float(_args[4] if _args.size() > 4 else 1.0)
	var prev_build_count := int(_args[5] if _args.size() > 5 else 0)
	var floor_supports_overlay := bool(_args[6] if _args.size() > 6 else false)
	var current_overlay_is_overlay_floor := bool(_args[7] if _args.size() > 7 else false)
	var config_present := bool(_args[8] if _args.size() > 8 else false)
	var builder_has_controller_name := bool(_args[9] if _args.size() > 9 else false)
	var controller_name := str(_args[10] if _args.size() > 10 else "")
	var headless := bool(_args[11] if _args.size() > 11 else false)
	var builder_is_player_unit := bool(_args[12] if _args.size() > 12 else false)
	var visible_tile := bool(_args[13] if _args.size() > 13 else false)
	var should_play := bool(_args[14] if _args.size() > 14 else false)
	var place_pitch_change := bool(_args[15] if _args.size() > 15 else false)
	var calc_pitch_up := float(_args[16] if _args.size() > 16 else 1.0)
	var block_size := int(_args[17] if _args.size() > 17 else 0)
	var block_health := float(_args[18] if _args.size() > 18 else 0.0)
	var rotation := int(_args[19] if _args.size() > 19 else 0)
	var config_state: Variant = _args[20] if _args.size() > 20 else null
	var tile_has_building_after_construct_finish := bool(_args[21] if _args.size() > 21 else false)
	return SourceBuildingDestructionState.construct_block_constructed_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, block_size, block_health, rotation, config_state, tile_has_building_after_construct_finish)

func java_method_isHidden_7(_args: Array = []) -> Variant:
	return null
