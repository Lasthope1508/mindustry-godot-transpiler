extends RefCounted
class_name SourceConstructBlockGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_construct_block_source_text_state := preload("res://src/game/SourceConstructBlockSourceTextState.gd")
const source_construct_block_state := preload("res://src/game/SourceConstructBlockState.gd")

const SOURCE_CONSTRUCT_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_GENERATED_CLASS
const SOURCE_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_JAVA_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_JAVA_METHOD
const SOURCE_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_JAVA_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_JAVA_METHOD
const SOURCE_CONSTRUCT_BLOCK_CONSTRUCTED_JAVA_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CONSTRUCTED_JAVA_METHOD
const SOURCE_CONSTRUCT_BLOCK_GET_JAVA_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_GET_JAVA_METHOD
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_JAVA_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_JAVA_METHOD
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_JAVA_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_JAVA_METHOD
const SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_JAVA_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_JAVA_METHOD
const SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_JAVA_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_JAVA_METHOD
const SOURCE_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_GENERATED_OWNER := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_GENERATED_OWNER
const SOURCE_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_GENERATED_OWNER := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_GENERATED_OWNER
const SOURCE_CONSTRUCT_BLOCK_CONSTRUCTED_GENERATED_OWNER := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CONSTRUCTED_GENERATED_OWNER
const SOURCE_CONSTRUCT_BLOCK_STATIC_HELPERS_GENERATED_OWNER := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_STATIC_HELPERS_GENERATED_OWNER

static func _construct_block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_CONSTRUCT_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func generated_construct_block_deconstruct_finish_bridge_state(tile_present: bool, headless: bool, visible_tile: bool, should_play: bool, break_pitch_change: bool, calc_pitch_down: float, construct_block_size: int, block_map_color: Variant) -> Dictionary:
	var result = _construct_block_call(SOURCE_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_JAVA_METHOD, [tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color])
	var canonical = source_construct_block_state.construct_block_deconstruct_finish_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_STATE,
		"generated_owner": SOURCE_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("returned_early", null) == canonical.get("returned_early", null) and result.get("break_effect_called", null) == canonical.get("break_effect_called", null) and result.get("break_sound_called", null) == canonical.get("break_sound_called", null) and result.get("event_fired", null) == canonical.get("event_fired", null) and result.get("tile_removed", null) == canonical.get("tile_removed", null),
	}

static func generated_construct_block_construct_finish_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant) -> Dictionary:
	var result = _construct_block_call(SOURCE_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_JAVA_METHOD, [tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state])
	var canonical = source_construct_block_state.construct_block_construct_finish_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_STATE,
		"generated_owner": SOURCE_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("returned_early", null) == canonical.get("returned_early", null) and result.get("set_overlay_called", null) == canonical.get("set_overlay_called", null) and result.get("set_floor_called", null) == canonical.get("set_floor_called", null) and result.get("clear_overlay_called", null) == canonical.get("clear_overlay_called", null) and result.get("set_block_called", null) == canonical.get("set_block_called", null) and result.get("configured_called", null) == canonical.get("configured_called", null) and result.get("overwrote_called", null) == canonical.get("overwrote_called", null) and result.get("last_accessed_set", null) == canonical.get("last_accessed_set", null) and result.get("place_sound_called", null) == canonical.get("place_sound_called", null) and result.get("event_fired", null) == canonical.get("event_fired", null),
	}

static func generated_construct_block_constructed_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	var result = _construct_block_call(SOURCE_CONSTRUCT_BLOCK_CONSTRUCTED_JAVA_METHOD, [tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish])
	var canonical = source_construct_block_state.construct_block_constructed_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_CONSTRUCTED_STATE,
		"generated_owner": SOURCE_CONSTRUCT_BLOCK_CONSTRUCTED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("construct_finish_called", null) == canonical.get("construct_finish_called", null) and result.get("placed_called", null) == canonical.get("placed_called", null) and result.get("returned_early", null) == canonical.get("returned_early", null) and result.get("construct_finish_state", {}).get("event_fired", null) == canonical.get("construct_finish_state", {}).get("event_fired", null),
	}

static func generated_construct_block_static_helpers_bridge_state(size: int, max_block_size: int, time_since_last_played_ms: int, current_millis: int, up: bool, time_since_last_time_ms: int, pitch_seq_before: int, random_pitch: float, headless: bool, visible_tile: bool) -> Dictionary:
	var get_result = _construct_block_call(SOURCE_CONSTRUCT_BLOCK_GET_JAVA_METHOD, [size, max_block_size])
	var should_play_result = _construct_block_call(SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_JAVA_METHOD, [time_since_last_played_ms, current_millis])
	var calc_pitch_result = _construct_block_call(SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_JAVA_METHOD, [up, time_since_last_time_ms, current_millis, pitch_seq_before, random_pitch])
	var repair_sound_result = _construct_block_call(SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_JAVA_METHOD, [headless, should_play_result.get("should_play", false), visible_tile, calc_pitch_result.get("pitch", 1.0)])
	var hidden_result = _construct_block_call(SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_JAVA_METHOD, [])
	var canonical_get = source_construct_block_state.get_state(size, max_block_size)
	var canonical_should_play = source_construct_block_state.should_play_state(time_since_last_played_ms, current_millis)
	var canonical_calc_pitch = source_construct_block_state.calc_pitch_state(up, time_since_last_time_ms, current_millis, pitch_seq_before, random_pitch)
	var canonical_repair_sound = source_construct_block_state.play_repair_sound_state(headless, canonical_should_play.get("should_play", false), visible_tile, canonical_calc_pitch.get("pitch", 1.0))
	var canonical_hidden = source_construct_block_state.is_hidden_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"generated_owner": SOURCE_CONSTRUCT_BLOCK_STATIC_HELPERS_GENERATED_OWNER,
		"get_result": get_result,
		"should_play_result": should_play_result,
		"calc_pitch_result": calc_pitch_result,
		"repair_sound_result": repair_sound_result,
		"hidden_result": hidden_result,
		"canonical_get": canonical_get,
		"canonical_should_play": canonical_should_play,
		"canonical_calc_pitch": canonical_calc_pitch,
		"canonical_repair_sound": canonical_repair_sound,
		"canonical_hidden": canonical_hidden,
		"matches": get_result.get("construct_block_index", null) == canonical_get.get("construct_block_index", null) and should_play_result.get("should_play", null) == canonical_should_play.get("should_play", null) and calc_pitch_result.get("pitch_seq_after", null) == canonical_calc_pitch.get("pitch_seq_after", null) and calc_pitch_result.get("pitch", null) == canonical_calc_pitch.get("pitch", null) and repair_sound_result.get("repair_sound_called", null) == canonical_repair_sound.get("repair_sound_called", null) and hidden_result.get("is_hidden", null) == canonical_hidden.get("is_hidden", null),
	}
