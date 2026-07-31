extends RefCounted
class_name SourceBuildingDestructionState

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := "res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd"
const SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY := "random_seed_float_max"
const SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_FALLBACK := "source_arc_random_seed_float_max"

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_building_destruction_method_names"):
		var names = game.call("_building_destruction_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY, SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_FALLBACK)),
	}

static func _random_seed_float_max(source_seed: int, max_value: float) -> float:
	return source_math_state.random_seed_float_max(source_seed, max_value)

static func _with_source_owner(source_exprs: Dictionary, state: Dictionary) -> Dictionary:
	var result := source_exprs.duplicate()
	result.merge(state)
	return result

static func begin_break_state(valid_break: bool, tile_has_building: bool, prev_healthf: float, previous_rotation: int, previous_instant_deconstruct: bool, previous_size: int, unit_has_controller_name: bool, controller_name: String) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_BUILD_BEGIN_BREAK_STATE}
	var prev_percent := prev_healthf if tile_has_building else 1.0
	var instant_deconstruct_call: Variant = null
	if previous_instant_deconstruct and valid_break:
		instant_deconstruct_call = {"call": "ConstructBlock.deconstructFinish(tile, previous, unit);"}
	var build_construct_block := valid_break and not previous_instant_deconstruct
	var prev_build_added := build_construct_block and tile_has_building
	var last_accessed_set := build_construct_block and unit_has_controller_name
	return _with_source_owner(source_exprs, {
		"source": "core/src/mindustry/world/Build.java",
		"method": "public static void beginBreak(@Nullable Unit unit, Team team, int x, int y){",
		"valid_break_guard_expr": "if(!validBreak(team, x, y)){",
		"tile_expr": "Tile tile = world.tileBuilding(x, y);",
		"prev_percent_default_expr": "float prevPercent = 1f;",
		"prev_percent_expr": "prevPercent = tile.build.healthf();",
		"rotation_expr": "int rotation = tile.build != null ? tile.build.rotation : 0;",
		"previous_expr": "Block previous = tile.block();",
		"instant_deconstruct_guard_expr": "if(previous.instantDeconstruct){",
		"instant_deconstruct_call_expr": "ConstructBlock.deconstructFinish(tile, previous, unit);",
		"sub_block_expr": "Block sub = ConstructBlock.get(previous.size);",
		"prev_build_expr": "Seq<Building> prevBuild = new Seq<>(1);",
		"prev_build_add_expr": "prevBuild.add(tile.build);",
		"on_deconstructed_expr": "tile.build.onDeconstructed(unit);",
		"dead_expr": "tile.build.dead = true;",
		"set_block_expr": "tile.setBlock(sub, team, rotation);",
		"set_deconstruct_expr": "build.setDeconstruct(previous);",
		"prev_build_assign_expr": "build.prevBuild = prevBuild;",
		"health_expr": "tile.build.health = tile.build.maxHealth * prevPercent;",
		"last_accessed_expr": "tile.build.lastAccessed = unit.getControllerName();",
		"event_expr": "Events.fire(new BlockBuildBeginEvent(tile, team, unit, true));",
		"valid_break": valid_break,
		"tile_has_building": tile_has_building,
		"prev_percent": prev_percent,
		"rotation": previous_rotation if tile_has_building else 0,
		"previous_instant_deconstruct": previous_instant_deconstruct,
		"previous_size": previous_size,
		"instant_deconstruct_call": instant_deconstruct_call,
		"construct_block_started": build_construct_block,
		"sub_block_size": previous_size if build_construct_block else 0,
		"prev_build_count": 1 if prev_build_added else 0,
		"on_deconstructed_called": prev_build_added,
		"tile_build_dead": prev_build_added,
		"tile_set_block_called": build_construct_block,
		"set_deconstruct_called": build_construct_block,
		"health_restored_from_prev_percent": build_construct_block,
		"last_accessed_set": last_accessed_set,
		"last_accessed": controller_name if last_accessed_set else "",
		"event_fired": build_construct_block,
		"returned_early": not valid_break or previous_instant_deconstruct,
	})

static func generated_build_begin_break_bridge_state(valid_break: bool, tile_has_building: bool, prev_healthf: float, previous_rotation: int, previous_instant_deconstruct: bool, previous_size: int, unit_has_controller_name: bool, controller_name: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Build.gd", "java_method_beginBreak_0", [valid_break, tile_has_building, prev_healthf, previous_rotation, previous_instant_deconstruct, previous_size, unit_has_controller_name, controller_name], null)
	var canonical = begin_break_state(valid_break, tile_has_building, prev_healthf, previous_rotation, previous_instant_deconstruct, previous_size, unit_has_controller_name, controller_name)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_BUILD_BEGIN_BREAK_STATE,
		"generated_owner": "build.java_method_beginBreak_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("returned_early", null) == canonical.get("returned_early", null) and result.get("construct_block_started", null) == canonical.get("construct_block_started", null) and result.get("instant_deconstruct_call", null) == canonical.get("instant_deconstruct_call", null) and result.get("event_fired", null) == canonical.get("event_fired", null),
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
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
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

static func generated_construct_block_deconstruct_finish_bridge_state(tile_present: bool, headless: bool, visible_tile: bool, should_play: bool, break_pitch_change: bool, calc_pitch_down: float, construct_block_size: int, block_map_color: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/ConstructBlock.gd", "java_method_deconstructFinish_1", [tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color], null)
	var canonical = construct_block_deconstruct_finish_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_STATE,
		"generated_owner": "construct_block.java_method_deconstructFinish_1",
		"result": result,
		"canonical": canonical,
		"matches": result.get("returned_early", null) == canonical.get("returned_early", null) and result.get("break_effect_called", null) == canonical.get("break_effect_called", null) and result.get("break_sound_called", null) == canonical.get("break_sound_called", null) and result.get("event_fired", null) == canonical.get("event_fired", null) and result.get("tile_removed", null) == canonical.get("tile_removed", null),
	}

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
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
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

static func generated_construct_block_construct_finish_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/ConstructBlock.gd", "java_method_constructFinish_2", [tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state], null)
	var canonical = construct_block_construct_finish_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_STATE,
		"generated_owner": "construct_block.java_method_constructFinish_2",
		"result": result,
		"canonical": canonical,
		"matches": result.get("returned_early", null) == canonical.get("returned_early", null) and result.get("set_overlay_called", null) == canonical.get("set_overlay_called", null) and result.get("set_floor_called", null) == canonical.get("set_floor_called", null) and result.get("clear_overlay_called", null) == canonical.get("clear_overlay_called", null) and result.get("set_block_called", null) == canonical.get("set_block_called", null) and result.get("configured_called", null) == canonical.get("configured_called", null) and result.get("overwrote_called", null) == canonical.get("overwrote_called", null) and result.get("last_accessed_set", null) == canonical.get("last_accessed_set", null) and result.get("place_sound_called", null) == canonical.get("place_sound_called", null) and result.get("event_fired", null) == canonical.get("event_fired", null),
	}

static func construct_block_constructed_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, block_size: int, block_health: float, rotation: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_CONSTRUCTED_STATE}
	var construct_finish_state := construct_block_construct_finish_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, block_size, block_health, rotation, config_state)
	var placed_called := tile_present and tile_has_building_after_construct_finish
	return _with_source_owner(source_exprs, {
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
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

static func generated_construct_block_constructed_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/ConstructBlock.gd", "java_method_constructed_6", [tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish], null)
	var canonical = construct_block_constructed_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_CONSTRUCTED_STATE,
		"generated_owner": "construct_block.java_method_constructed_6",
		"result": result,
		"canonical": canonical,
		"matches": result.get("construct_finish_called", null) == canonical.get("construct_finish_called", null) and result.get("placed_called", null) == canonical.get("placed_called", null) and result.get("returned_early", null) == canonical.get("returned_early", null) and result.get("construct_finish_state", {}).get("event_fired", null) == canonical.get("construct_finish_state", {}).get("event_fired", null),
	}

static func after_destroyed_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int, random_seed_float_max: Callable) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_AFTER_DESTROYED_STATE}
	if not has_destroy_bullet:
		return _with_source_owner(source_exprs, {"create_bullet": false})
	return _with_source_owner(source_exprs, {
		"create_bullet": true,
		"team": team_id if destroy_bullet_same_team else "derelict",
		"x": source_x,
		"y": source_y,
		"rotation": float(random_seed_float_max.call(building_id, source_math_defaults.FULL_CIRCLE_DEGREES)),
	})

static func game_after_destroyed_state(game: Object, has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return after_destroyed_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id, callbacks.get(SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY, Callable()))

static func explosion_item_cap_state(item_capacity: int) -> int:
	return item_capacity

static func splash_liquid_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SPLASH_LIQUID_STATE}
	var splash := clampf(amount / 4.0, 0.0, 10.0)
	var deposit_count := int(ceil(clampf(amount / 5.0, 0.0, 30.0)))
	var delays: Array[float] = []
	for i in deposit_count:
		delays.append(float(i) / 2.0)
	return _with_source_owner(source_exprs, {
		"method": "public void splashLiquid(Liquid liquid, float amount){",
		"splash_expr": "float splash = Mathf.clamp(amount / 4f, 0f, 10f);",
		"loop": "for(int i = 0; i < Mathf.clamp(amount / 5, 0, 30); i++){",
		"delay_expr": "Time.run(i / 2f, () -> {",
		"tile_world": "Tile other = world.tileWorld(x + Mathf.range(block.size * tilesize / 2), y + Mathf.range(block.size * tilesize / 2));",
		"deposit_guard": "if(other != null){",
		"deposit": "Puddles.deposit(other, liquid, splash);",
		"liquid": liquid,
		"amount": amount,
		"source_block_size": source_block_size,
		"source_tilesize": source_tilesize,
		"splash": splash,
		"deposit_count": deposit_count,
		"delays": delays,
		"random_range": float(source_block_size) * source_tilesize / 2.0,
		"deposit_if_tile_exists": true,
	})

static func on_deconstructed_liquid_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DECONSTRUCTED_LIQUID_STATE}
	var can_drop_liquid := not current_incinerable or deconstruct_drop_all_liquid
	var base := {
		"method": "public void onDeconstructed(@Nullable Unit builder){",
		"has_liquids_module": has_liquids_module,
		"current_amount": current_amount,
		"current_incinerable": current_incinerable,
		"deconstruct_drop_all_liquid": deconstruct_drop_all_liquid,
		"source_block_size": source_block_size,
		"can_drop_liquid": can_drop_liquid,
	}
	if not has_liquids_module or current_amount <= 0.0 or not can_drop_liquid:
		base.merge({"deposit_linked_tiles": false, "per_cell": 0.0, "deposit_call": false}, true)
		return _with_source_owner(source_exprs, base)
	base.merge({
		"deposit_linked_tiles": true,
		"per_cell": current_amount / float(source_block_size * source_block_size) * 2.0,
		"deposit_call": true,
	}, true)
	return _with_source_owner(source_exprs, base)

static func on_destroyed_item_explosion_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_ITEM_EXPLOSION_STATE}
	var explosiveness := base_explosiveness
	var flammability := 0.0
	var power := 0.0
	if has_items:
		for item_state in item_states:
			var item_amount: int = min(int(item_state.get("amount", 0)), item_cap)
			explosiveness += float(item_state.get("explosiveness", 0.0)) * float(item_amount)
			flammability += float(item_state.get("flammability", 0.0)) * float(item_amount)
			power += float(item_state.get("charge", 0.0)) * pow(float(item_amount), 1.1) * 150.0
	return _with_source_owner(source_exprs, {
		"method": "public void onDestroyed(){",
		"base_explosiveness": base_explosiveness,
		"has_items": has_items,
		"item_cap": item_cap,
		"explosiveness": explosiveness,
		"flammability": flammability,
		"power": power,
	})

static func on_destroyed_liquid_explosion_state(current_explosiveness: float, current_flammability: float, has_liquids: bool, liquid_states: Array) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_LIQUID_EXPLOSION_STATE}
	var explosiveness := current_explosiveness
	var flammability := current_flammability
	if has_liquids:
		for liquid_state in liquid_states:
			flammability += float(liquid_state.get("flammability", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
			explosiveness += float(liquid_state.get("explosiveness", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
	return _with_source_owner(source_exprs, {
		"method": "public void onDestroyed(){",
		"current_explosiveness": current_explosiveness,
		"current_flammability": current_flammability,
		"has_liquids": has_liquids,
		"explosiveness": explosiveness,
		"flammability": flammability,
	})

static func on_destroyed_buffered_power_state(current_power: float, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BUFFERED_POWER_STATE}
	var apply_buffered_power := has_cons_power and cons_power_buffered
	var buffered_power_contribution := power_status * cons_power_capacity if apply_buffered_power else 0.0
	return _with_source_owner(source_exprs, {
		"method": "public void onDestroyed(){",
		"current_power": current_power,
		"has_cons_power": has_cons_power,
		"cons_power_buffered": cons_power_buffered,
		"power_status": power_status,
		"cons_power_capacity": cons_power_capacity,
		"apply_buffered_power": apply_buffered_power,
		"buffered_power_contribution": buffered_power_contribution,
		"power": current_power + buffered_power_contribution,
	})

static func on_destroyed_splash_liquid_state(has_liquids: bool, damage_explosions: bool, liquid_states: Array) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_SPLASH_LIQUID_STATE}
	var should_splash := has_liquids and damage_explosions
	return _with_source_owner(source_exprs, {
		"method": "public void onDestroyed(){",
		"has_liquids": has_liquids,
		"damage_explosions": damage_explosions,
		"splash_liquids": should_splash,
		"call": "liquids.each(this::splashLiquid);" if should_splash else "",
		"liquid_count": liquid_states.size() if should_splash else 0,
		"liquids": liquid_states.duplicate() if should_splash else [],
	})

static func on_destroyed_dynamic_explosion_call_state(source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, damage_explosions: bool, destroy_effect: String, base_shake: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_STATE}
	return _with_source_owner(source_exprs, {
		"method": "public void onDestroyed(){",
		"comment": "//cap explosiveness so fluid tanks/vaults don't instakill units",
		"call": "Damage.dynamicExplosion(x, y, flammability * block.flammabilityScale, explosiveness * 3.5f * block.explosivenessScale, power, tilesize * block.size / 2f, state.rules.damageExplosions, block.destroyEffect, block.baseShake);",
		"x": source_x,
		"y": source_y,
		"flammability": flammability * flammability_scale,
		"explosiveness": explosiveness * 3.5 * explosiveness_scale,
		"power": power,
		"radius": source_tilesize * float(source_block_size) / 2.0,
		"damage_explosions": damage_explosions,
		"effect": destroy_effect,
		"shake": base_shake,
	})

static func on_destroyed_rubble_state(source_x: float, source_y: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, source_block_size: int) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_RUBBLE_STATE}
	var should_create_rubble := create_rubble and not floor_solid and not floor_is_liquid
	return _with_source_owner(source_exprs, {
		"method": "public void onDestroyed(){",
		"source_x": source_x,
		"source_y": source_y,
		"floor_solid": floor_solid,
		"floor_is_liquid": floor_is_liquid,
		"source_block_size": source_block_size,
		"create_rubble": should_create_rubble,
		"call": "Effect.rubble(x, y, block.size);" if should_create_rubble else "",
		"x": source_x,
		"y": source_y,
		"size": source_block_size if should_create_rubble else 0,
	})

static func on_destroyed_base_sound_state(headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BASE_SOUND_STATE}
	var should_play_sound := not headless
	return _with_source_owner(source_exprs, {
		"method": "public void onDestroyed(){",
		"headless": headless,
		"destroy_sound": destroy_sound,
		"destroy_pitch_min": destroy_pitch_min,
		"destroy_pitch_max": destroy_pitch_max,
		"destroy_sound_volume": destroy_sound_volume,
		"play_destroy_sound": should_play_sound,
		"sound": destroy_sound if should_play_sound else "",
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	})

static func on_destroyed_reactive_sound_state(headless: bool, explosiveness: float, flammability: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_REACTIVE_SOUND_STATE}
	var should_play_reactive_sound := not headless
	var silent_state := {
		"method": "public void onDestroyed(){",
		"headless": headless,
		"explosiveness": explosiveness,
		"flammability": flammability,
		"play_reactive_sound": false,
		"reactive_sound_kind": "",
		"sound": "",
		"sound_choices": [],
		"chance": 0.0,
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	}
	if not should_play_reactive_sound:
		return _with_source_owner(source_exprs, silent_state)
	if explosiveness > 40.0:
		return _with_source_owner(source_exprs, {
			"method": "public void onDestroyed(){",
			"headless": headless,
			"explosiveness": explosiveness,
			"flammability": flammability,
			"play_reactive_sound": true,
			"reactive_sound_kind": "explosive",
			"sound": "",
			"sound_choices": ["blockExplodeExplosive", "blockExplodeExplosiveAlt"],
			"chance": 0.5,
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		})
	if flammability > 5.0:
		return _with_source_owner(source_exprs, {
			"method": "public void onDestroyed(){",
			"headless": headless,
			"explosiveness": explosiveness,
			"flammability": flammability,
			"play_reactive_sound": true,
			"reactive_sound_kind": "flammable",
			"sound": "blockExplodeFlammable",
			"sound_choices": [],
			"chance": 0.0,
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		})
	return _with_source_owner(source_exprs, silent_state)

static func on_destroyed_power_sound_state(headless: bool, power: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_POWER_SOUND_STATE}
	var should_play_power_sound := not headless
	var silent_state := {
		"method": "public void onDestroyed(){",
		"headless": headless,
		"power": power,
		"play_power_sound": false,
		"power_sound_kind": "",
		"sound": "",
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	}
	if not should_play_power_sound:
		return _with_source_owner(source_exprs, silent_state)
	if power > 30000.0:
		return _with_source_owner(source_exprs, {
			"method": "public void onDestroyed(){",
			"headless": headless,
			"power": power,
			"play_power_sound": true,
			"power_sound_kind": "big",
			"sound": "blockExplodeElectricBig",
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		})
	if power > 2000.0:
		return _with_source_owner(source_exprs, {
			"method": "public void onDestroyed(){",
			"headless": headless,
			"power": power,
			"play_power_sound": true,
			"power_sound_kind": "normal",
			"sound": "blockExplodeElectric",
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		})
	return _with_source_owner(source_exprs, silent_state)

static func generated_after_destroyed_bridge_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	var result = _building_comp_call("java_method_afterDestroyed_151", [has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id])
	var canonical = after_destroyed_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id, Callable(SourceBuildingDestructionState, "_random_seed_float_max"))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_AFTER_DESTROYED_STATE,
		"generated_owner": "building_comp.java_method_afterDestroyed_151",
		"result": result,
		"canonical": canonical,
	}

static func generated_explosion_item_cap_bridge_state(item_capacity: int) -> Dictionary:
	var result = _building_comp_call("java_method_explosionItemCap_152", [item_capacity])
	var canonical = explosion_item_cap_state(item_capacity)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_EXPLOSION_ITEM_CAP_STATE,
		"generated_owner": "building_comp.java_method_explosionItemCap_152",
		"result": result,
		"canonical": canonical,
	}

static func generated_splash_liquid_bridge_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call("java_method_splashLiquid_153", [liquid, amount, source_block_size, source_tilesize])
	var canonical = splash_liquid_state(liquid, amount, source_block_size, source_tilesize)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SPLASH_LIQUID_STATE,
		"generated_owner": "building_comp.java_method_splashLiquid_153",
		"result": result,
		"canonical": canonical,
	}

static func generated_splash_liquid_source_tilesize_default_bridge_state(liquid: Variant, amount: float, source_block_size: int) -> Dictionary:
	var result = _building_comp_call("java_method_splashLiquid_153", [liquid, amount, source_block_size])
	var canonical = splash_liquid_state(liquid, amount, source_block_size, source_world_defaults.TILESIZE)
	var matches := source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SPLASH_LIQUID_STATE,
		"generated_owner": "building_comp.java_method_splashLiquid_153",
		"defaulted_arg": "source_tilesize",
		"source_tilesize": source_world_defaults.TILESIZE,
		"matches": matches,
		"result": result,
		"canonical": canonical,
	}

static func generated_splash_liquid_source_block_size_default_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	var result = _building_comp_call("java_method_splashLiquid_153", [liquid, amount])
	var canonical = splash_liquid_state(liquid, amount, source_block_defaults.SIZE_DEFAULT, source_world_defaults.TILESIZE)
	var matches := source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SPLASH_LIQUID_STATE,
		"generated_owner": "building_comp.java_method_splashLiquid_153",
		"defaulted_arg": "source_block_size",
		"source_block_size": source_block_defaults.SIZE_DEFAULT,
		"source_tilesize": source_world_defaults.TILESIZE,
		"matches": matches,
		"result": result,
		"canonical": canonical,
	}

static func generated_on_deconstructed_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	var result = _building_comp_call("java_method_onDeconstructed_154", [has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size])
	var canonical = on_deconstructed_liquid_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DECONSTRUCTED_LIQUID_STATE,
		"generated_owner": "building_comp.java_method_onDeconstructed_154",
		"result": result,
		"canonical": canonical,
	}

static func generated_on_deconstructed_source_block_size_default_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool) -> Dictionary:
	var result = _building_comp_call("java_method_onDeconstructed_154", [has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid])
	var canonical = on_deconstructed_liquid_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_defaults.SIZE_DEFAULT)
	var on_deconstructed_matches = result.get("source_block_size", null) == canonical.get("source_block_size", null) \
		and result.get("can_drop_liquid", null) == canonical.get("can_drop_liquid", null) \
		and result.get("deposit_linked_tiles", null) == canonical.get("deposit_linked_tiles", null) \
		and result.get("per_cell", null) == canonical.get("per_cell", null) \
		and result.get("deposit_call", null) == canonical.get("deposit_call", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DECONSTRUCTED_LIQUID_STATE,
		"generated_owner": "building_comp.java_method_onDeconstructed_154",
		"defaulted_arg": "source_block_size",
		"source_block_size": source_block_defaults.SIZE_DEFAULT,
		"matches": on_deconstructed_matches,
		"result": result,
		"canonical": canonical,
	}

static func generated_on_destroyed_item_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap])
	var canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_ITEM_EXPLOSION_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"result": result,
		"canonical": canonical,
	}

static func generated_on_destroyed_liquid_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_LIQUID_EXPLOSION_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"result": result,
		"item_canonical": item_canonical,
		"canonical": canonical,
	}

static func generated_on_destroyed_buffered_power_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var canonical = on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BUFFERED_POWER_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"result": result,
		"item_canonical": item_canonical,
		"liquid_canonical": liquid_canonical,
		"canonical": canonical,
	}

static func generated_on_destroyed_splash_liquid_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var canonical = on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_SPLASH_LIQUID_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"result": result,
		"item_canonical": item_canonical,
		"liquid_canonical": liquid_canonical,
		"buffered_power_canonical": buffered_power_canonical,
		"canonical": canonical,
	}

static func generated_on_destroyed_dynamic_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var canonical = on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"result": result,
		"item_canonical": item_canonical,
		"liquid_canonical": liquid_canonical,
		"buffered_power_canonical": buffered_power_canonical,
		"splash_canonical": splash_canonical,
		"canonical": canonical,
	}

static func generated_on_destroyed_dynamic_explosion_source_tilesize_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var canonical = on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_world_defaults.TILESIZE, source_block_defaults.SIZE_DEFAULT, damage_explosions, "", 0.0)
	var dynamic_explosion_matches = result.get("dynamic_explosion_x", null) == canonical.get("x", null) \
		and result.get("dynamic_explosion_y", null) == canonical.get("y", null) \
		and result.get("dynamic_explosion_flammability", null) == canonical.get("flammability", null) \
		and result.get("dynamic_explosion_explosiveness", null) == canonical.get("explosiveness", null) \
		and result.get("dynamic_explosion_power", null) == canonical.get("power", null) \
		and result.get("dynamic_explosion_radius", null) == canonical.get("radius", null) \
		and result.get("dynamic_explosion_damage_explosions", null) == canonical.get("damage_explosions", null) \
		and result.get("dynamic_explosion_effect", null) == canonical.get("effect", null) \
		and result.get("dynamic_explosion_shake", null) == canonical.get("shake", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"defaulted_arg": "source_tilesize",
		"source_tilesize": source_world_defaults.TILESIZE,
		"source_block_size": source_block_defaults.SIZE_DEFAULT,
		"matches": dynamic_explosion_matches,
		"result": result,
		"item_canonical": item_canonical,
		"liquid_canonical": liquid_canonical,
		"buffered_power_canonical": buffered_power_canonical,
		"splash_canonical": splash_canonical,
		"canonical": canonical,
	}

static func generated_on_destroyed_source_block_size_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_defaults.SIZE_DEFAULT, damage_explosions, "", 0.0)
	var on_destroyed_matches = result.get("dynamic_explosion_radius", null) == dynamic_explosion_canonical.get("radius", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_STATE,
		"rubble_source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_RUBBLE_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"defaulted_arg": "source_block_size",
		"source_block_size": source_block_defaults.SIZE_DEFAULT,
		"matches": on_destroyed_matches,
		"result": result,
		"item_canonical": item_canonical,
		"liquid_canonical": liquid_canonical,
		"buffered_power_canonical": buffered_power_canonical,
		"splash_canonical": splash_canonical,
		"dynamic_explosion_canonical": dynamic_explosion_canonical,
	}

static func generated_on_destroyed_rubble_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	var canonical = on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_RUBBLE_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"result": result,
		"item_canonical": item_canonical,
		"liquid_canonical": liquid_canonical,
		"buffered_power_canonical": buffered_power_canonical,
		"splash_canonical": splash_canonical,
		"dynamic_explosion_canonical": dynamic_explosion_canonical,
		"canonical": canonical,
	}

static func generated_on_destroyed_base_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	var rubble_canonical = on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)
	var canonical = on_destroyed_base_sound_state(headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BASE_SOUND_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"result": result,
		"item_canonical": item_canonical,
		"liquid_canonical": liquid_canonical,
		"buffered_power_canonical": buffered_power_canonical,
		"splash_canonical": splash_canonical,
		"dynamic_explosion_canonical": dynamic_explosion_canonical,
		"rubble_canonical": rubble_canonical,
		"canonical": canonical,
	}

static func generated_on_destroyed_reactive_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	var rubble_canonical = on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)
	var base_sound_canonical = on_destroyed_base_sound_state(headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	var canonical = on_destroyed_reactive_sound_state(headless, float(liquid_canonical["explosiveness"]), float(liquid_canonical["flammability"]), destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_REACTIVE_SOUND_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"result": result,
		"item_canonical": item_canonical,
		"liquid_canonical": liquid_canonical,
		"buffered_power_canonical": buffered_power_canonical,
		"splash_canonical": splash_canonical,
		"dynamic_explosion_canonical": dynamic_explosion_canonical,
		"rubble_canonical": rubble_canonical,
		"base_sound_canonical": base_sound_canonical,
		"canonical": canonical,
	}

static func generated_on_destroyed_power_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var result = _building_comp_call("java_method_onDestroyed_155", [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume])
	var item_canonical = on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	var rubble_canonical = on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)
	var base_sound_canonical = on_destroyed_base_sound_state(headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	var reactive_sound_canonical = on_destroyed_reactive_sound_state(headless, float(liquid_canonical["explosiveness"]), float(liquid_canonical["flammability"]), destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	var canonical = on_destroyed_power_sound_state(headless, float(buffered_power_canonical["power"]), destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_POWER_SOUND_STATE,
		"generated_owner": "building_comp.java_method_onDestroyed_155",
		"result": result,
		"item_canonical": item_canonical,
		"liquid_canonical": liquid_canonical,
		"buffered_power_canonical": buffered_power_canonical,
		"splash_canonical": splash_canonical,
		"dynamic_explosion_canonical": dynamic_explosion_canonical,
		"rubble_canonical": rubble_canonical,
		"base_sound_canonical": base_sound_canonical,
		"reactive_sound_canonical": reactive_sound_canonical,
		"canonical": canonical,
	}

static func generated_play_destroy_sound_bridge_state(destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var result = _building_comp_call("java_method_playDestroySound_156", [destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume])
	var canonical = on_destroyed_base_sound_state(false, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BASE_SOUND_STATE,
		"generated_owner": "building_comp.java_method_playDestroySound_156",
		"result": result,
		"canonical": canonical,
	}
