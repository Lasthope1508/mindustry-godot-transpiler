extends RefCounted
class_name SourceConstructBlockState

const CONSTRUCT_BLOCK_SOUND_MIN_INTERVAL_MS := 32
const CONSTRUCT_BLOCK_PITCH_SEQUENCE_WINDOW_MS := 16 * 30
const CONSTRUCT_BLOCK_PITCH_SEQUENCE_LIMIT := 30
const CONSTRUCT_BLOCK_PITCH_UP_SCALE := 1.9
const CONSTRUCT_BLOCK_PITCH_DOWN_SCALE := -0.4
const CONSTRUCT_BLOCK_RANDOM_PITCH_MIN := 0.7
const CONSTRUCT_BLOCK_RANDOM_PITCH_MAX := 1.3

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_construct_block_source_text_state := preload("res://src/game/SourceConstructBlockSourceTextState.gd")

const SOURCE_CONSTRUCT_BLOCK_SOURCE := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SOURCE
const SOURCE_CONSTRUCT_BLOCK_GET_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_GET_METHOD
const SOURCE_CONSTRUCT_BLOCK_GET_MAX_BLOCK_SIZE_GUARD_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_GET_MAX_BLOCK_SIZE_GUARD_EXPR
const SOURCE_CONSTRUCT_BLOCK_GET_RETURN_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_GET_RETURN_EXPR
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_METHOD
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_GUARD_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_GUARD_EXPR
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_LAST_PLAYED_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_LAST_PLAYED_EXPR
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_RETURN_TRUE_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_RETURN_TRUE_EXPR
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_RETURN_FALSE_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_RETURN_FALSE_EXPR
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_METHOD
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_WINDOW_GUARD_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_WINDOW_GUARD_EXPR
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_LAST_TIME_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_LAST_TIME_EXPR
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_INCREMENT_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_INCREMENT_EXPR
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_RESET_GUARD_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_RESET_GUARD_EXPR
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_SEQUENCE_RETURN_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_SEQUENCE_RETURN_EXPR
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_RANDOM_RETURN_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_RANDOM_RETURN_EXPR
const SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_METHOD
const SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_EXPR
const SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_METHOD := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_METHOD
const SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_RETURN_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_RETURN_EXPR

static func _with_source_owner(source_exprs: Dictionary, state: Dictionary) -> Dictionary:
	var result := source_exprs.duplicate()
	result.merge(state)
	return result

static func get_state(size: int, max_block_size: int) -> Dictionary:
	var invalid_size := size > max_block_size
	var construct_block_index := size - 1
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"method": SOURCE_CONSTRUCT_BLOCK_GET_METHOD,
		"max_guard_expr": SOURCE_CONSTRUCT_BLOCK_GET_MAX_BLOCK_SIZE_GUARD_EXPR,
		"return_expr": SOURCE_CONSTRUCT_BLOCK_GET_RETURN_EXPR,
		"size": size,
		"max_block_size": max_block_size,
		"invalid_size": invalid_size,
		"construct_block_index": construct_block_index,
	}

static func should_play_state(time_since_last_played_ms: int, current_millis: int) -> Dictionary:
	var should_play := time_since_last_played_ms >= CONSTRUCT_BLOCK_SOUND_MIN_INTERVAL_MS
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"method": SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_METHOD,
		"guard_expr": SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_GUARD_EXPR,
		"last_played_expr": SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_LAST_PLAYED_EXPR,
		"return_true_expr": SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_RETURN_TRUE_EXPR,
		"return_false_expr": SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_RETURN_FALSE_EXPR,
		"time_since_last_played_ms": time_since_last_played_ms,
		"current_millis": current_millis,
		"last_played_after": current_millis if should_play else -1,
		"should_play": should_play,
	}

static func calc_pitch_state(up: bool, time_since_last_time_ms: int, current_millis: int, pitch_seq_before: int, random_pitch: float) -> Dictionary:
	var within_sequence_window := time_since_last_time_ms < CONSTRUCT_BLOCK_PITCH_SEQUENCE_WINDOW_MS
	var pitch_seq_after := 0
	var pitch := random_pitch
	if within_sequence_window:
		pitch_seq_after = pitch_seq_before + 1
		if pitch_seq_after > CONSTRUCT_BLOCK_PITCH_SEQUENCE_LIMIT:
			pitch_seq_after = 0
		var scale := CONSTRUCT_BLOCK_PITCH_UP_SCALE if up else CONSTRUCT_BLOCK_PITCH_DOWN_SCALE
		pitch = 1.0 + clampf(float(pitch_seq_after) / float(CONSTRUCT_BLOCK_PITCH_SEQUENCE_LIMIT), 0.0, 1.0) * scale
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"method": SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_METHOD,
		"window_guard_expr": SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_WINDOW_GUARD_EXPR,
		"last_time_expr": SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_LAST_TIME_EXPR,
		"increment_expr": SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_INCREMENT_EXPR,
		"reset_guard_expr": SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_RESET_GUARD_EXPR,
		"sequence_return_expr": SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_SEQUENCE_RETURN_EXPR,
		"random_return_expr": SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_RANDOM_RETURN_EXPR,
		"up": up,
		"time_since_last_time_ms": time_since_last_time_ms,
		"current_millis": current_millis,
		"pitch_seq_before": pitch_seq_before,
		"pitch_seq_after": pitch_seq_after,
		"random_pitch": random_pitch,
		"pitch": pitch,
	}

static func play_repair_sound_state(headless: bool, should_play: bool, visible_tile: bool, calc_pitch_up: float) -> Dictionary:
	var repair_sound_called := not headless and should_play and visible_tile
	var repair_sound_call: Variant = null
	if repair_sound_called:
		repair_sound_call = {"call": "Sounds.blockRepair.at(tile, calcPitch(true));", "pitch": calc_pitch_up}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"method": SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_METHOD,
		"repair_sound_expr": SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_EXPR,
		"headless": headless,
		"should_play": should_play,
		"visible_tile": visible_tile,
		"calc_pitch_up": calc_pitch_up,
		"repair_sound_called": repair_sound_called,
		"repair_sound_call": repair_sound_call,
	}

static func is_hidden_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"method": SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_METHOD,
		"return_expr": SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_RETURN_EXPR,
		"is_hidden": true,
	}

static func construct_block_deconstruct_finish_state(tile_present: bool, headless: bool, visible_tile: bool, should_play: bool, break_pitch_change: bool, calc_pitch_down: float, block_size: int, block_map_color: Variant) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_STATE}
	var visible_effect_gate: bool = tile_present and not headless and visible_tile
	var break_effect_call: Variant = null
	var break_sound_call: Variant = null
	if visible_effect_gate:
		break_effect_call = {"call": "block.breakEffect.at(tile.drawx(), tile.drawy(), block.size, block.mapColor);", "size": block_size, "map_color": block_map_color}
		if should_play:
			break_sound_call = {"call": "block.breakSound.at(tile, block.breakPitchChange ? calcPitch(false) : 1f);", "pitch": calc_pitch_down if break_pitch_change else 1.0}
	return _with_source_owner(source_exprs, {
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"method": "public static void deconstructFinish(Tile tile, Block block, Unit builder){",
		"tile_null_guard_expr": "if(tile == null) return;",
		"team_expr": "Team team = tile.team();",
		"visible_guard_expr": "if(!headless && fogControl.isVisibleTile(Vars.player.team(), tile.x, tile.y)){",
		"break_effect_expr": "block.breakEffect.at(tile.drawx(), tile.drawy(), block.size, block.mapColor);",
		"break_sound_expr": "if(shouldPlay()) block.breakSound.at(tile, block.breakPitchChange ? calcPitch(false) : 1f);",
		"event_expr": "Events.fire(new BlockBuildEndEvent(tile, builder, team, true, null));",
		"remove_expr": "tile.remove();",
		"tile_present": tile_present,
		"headless": headless,
		"visible_tile": visible_tile,
		"should_play": should_play,
		"break_pitch_change": break_pitch_change,
		"calc_pitch_down": calc_pitch_down,
		"block_size": block_size,
		"block_map_color": block_map_color,
		"visible_effect_gate": visible_effect_gate,
		"break_effect_called": break_effect_call != null,
		"break_sound_called": break_sound_call != null,
		"break_effect_call": break_effect_call,
		"break_sound_call": break_sound_call,
		"event_fired": tile_present,
		"tile_removed": tile_present,
		"returned_early": not tile_present,
	})

static func construct_block_construct_finish_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, block_size: int, block_health: float, rotation: int, config_state: Variant) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_STATE}
	var set_overlay_called := false
	var set_floor_called := false
	var clear_overlay_called := false
	var set_block_called := false
	if tile_present:
		if block_kind == "overlay_floor":
			set_overlay_called = true
		elif block_kind == "floor":
			set_floor_called = true
			clear_overlay_called = not current_overlay_is_overlay_floor and not floor_supports_overlay
		else:
			set_block_called = true
	var post_place_applied := tile_present and tile_build_matches_block
	var visible_effect_gate := tile_present and visible_tile
	var place_effect_call: Variant = null
	var place_sound_call: Variant = null
	if visible_effect_gate:
		place_effect_call = {"call": "block.placeEffect.at(tile.drawx(), tile.drawy(), block.size);", "size": block_size}
		if should_play:
			place_sound_call = {"call": "block.placeSound.at(tile, block.placePitchChange ? calcPitch(true) : 1f);", "pitch": calc_pitch_up if place_pitch_change else 1.0}
	return _with_source_owner(source_exprs, {
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"method": "public static void constructFinish(Tile tile, Block block, @Nullable Unit builder, byte rotation, Team team, Object config){",
		"tile_null_guard_expr": "if(tile == null) return;",
		"healthf_expr": "float healthf = tile.build == null ? 1f : tile.build.healthf();",
		"prev_expr": "Seq<Building> prev = tile.build instanceof ConstructBuild co ? co.prevBuild : null;",
		"overlay_branch_expr": "if(block instanceof OverlayFloor overlay){",
		"set_overlay_expr": "tile.setOverlay(overlay);",
		"floor_branch_expr": "}else if(block instanceof Floor floor){",
		"set_floor_expr": "tile.setFloor(floor);",
		"clear_overlay_guard_expr": "if(!(tile.overlay() instanceof OverlayFloor) && !floor.supportsOverlay){",
		"clear_overlay_expr": "tile.setOverlay(Blocks.air);",
		"set_block_expr": "tile.setBlock(block, team, rotation);",
		"post_place_guard_expr": "if(tile.build != null && tile.build.block == block){",
		"health_expr": "tile.build.health = block.health * healthf;",
		"configured_expr": "tile.build.configured(builder, config);",
		"overwrote_expr": "tile.build.overwrote(prev);",
		"last_accessed_expr": "tile.build.lastAccessed = builder.getControllerName();",
		"notify_health_expr": "indexer.notifyHealthChanged(tile.build);",
		"player_placed_guard_expr": "if(!headless && builder == player.unit()){",
		"player_placed_expr": "tile.build.playerPlaced(config);",
		"visible_guard_expr": "if(fogControl.isVisibleTile(team, tile.x, tile.y)){",
		"place_effect_expr": "block.placeEffect.at(tile.drawx(), tile.drawy(), block.size);",
		"place_sound_expr": "if(shouldPlay()) block.placeSound.at(tile, block.placePitchChange ? calcPitch(true) : 1f);",
		"place_ended_expr": "block.placeEnded(tile, builder, rotation, config);",
		"event_expr": "Events.fire(new BlockBuildEndEvent(tile, builder, team, false, config));",
		"tile_present": tile_present,
		"block_kind": block_kind,
		"tile_has_building": tile_has_building,
		"tile_build_matches_block": tile_build_matches_block,
		"healthf": healthf if tile_has_building else 1.0,
		"prev_build_count": prev_build_count if tile_has_building else 0,
		"floor_supports_overlay": floor_supports_overlay,
		"current_overlay_is_overlay_floor": current_overlay_is_overlay_floor,
		"config_present": config_present,
		"builder_has_controller_name": builder_has_controller_name,
		"controller_name": controller_name if builder_has_controller_name else "",
		"headless": headless,
		"builder_is_player_unit": builder_is_player_unit,
		"visible_tile": visible_tile,
		"should_play": should_play,
		"place_pitch_change": place_pitch_change,
		"calc_pitch_up": calc_pitch_up,
		"block_size": block_size,
		"block_health": block_health,
		"rotation": rotation,
		"config_state": config_state,
		"set_overlay_called": set_overlay_called,
		"set_floor_called": set_floor_called,
		"clear_overlay_called": clear_overlay_called,
		"set_block_called": set_block_called,
		"post_place_applied": post_place_applied,
		"health_after": block_health * (healthf if tile_has_building else 1.0) if post_place_applied else 0.0,
		"configured_called": post_place_applied and config_present,
		"overwrote_called": post_place_applied and prev_build_count > 0,
		"last_accessed_set": post_place_applied and builder_has_controller_name,
		"last_accessed": controller_name if post_place_applied and builder_has_controller_name else "",
		"notify_health_changed": post_place_applied,
		"player_placed_called": post_place_applied and not headless and builder_is_player_unit,
		"visible_effect_gate": visible_effect_gate,
		"place_effect_called": place_effect_call != null,
		"place_sound_called": place_sound_call != null,
		"place_effect_call": place_effect_call,
		"place_sound_call": place_sound_call,
		"place_ended_called": tile_present,
		"event_fired": tile_present,
		"returned_early": not tile_present,
	})

static func construct_block_constructed_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, block_size: int, block_health: float, rotation: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_CONSTRUCTED_STATE}
	var construct_finish_state := construct_block_construct_finish_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, block_size, block_health, rotation, config_state)
	var placed_called := tile_present and tile_has_building_after_construct_finish
	return _with_source_owner(source_exprs, {
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"method": "public static void constructed(Tile tile, Block block, Unit builder, byte rotation, Team team, Object config){",
		"construct_finish_expr": "Call.constructFinish(tile, block, builder, rotation, team, config);",
		"placed_guard_expr": "if(tile.build != null){",
		"placed_expr": "tile.build.placed();",
		"tile_present": tile_present,
		"tile_has_building_after_construct_finish": tile_has_building_after_construct_finish,
		"construct_finish_state": construct_finish_state,
		"construct_finish_called": true,
		"placed_called": placed_called,
		"returned_early": not tile_present,
	})
