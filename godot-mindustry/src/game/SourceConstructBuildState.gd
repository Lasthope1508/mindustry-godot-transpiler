extends RefCounted
class_name SourceConstructBuildState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_construct_block_source_text_state := preload("res://src/game/SourceConstructBlockSourceTextState.gd")
const source_construct_build_io_state := preload("res://src/game/SourceConstructBuildIoState.gd")
const source_construct_build_work_state := preload("res://src/game/SourceConstructBuildWorkState.gd")
const source_math_callback_registry := preload("res://src/game/SourceMathCallbackRegistry.gd")

const SOURCE_CONSTRUCT_BLOCK_SOURCE := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SOURCE
const SOURCE_CONSTRUCT_BUILD_CLASS_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BUILD_CLASS_EXPR
const CONSTRUCT_BUILD_COLOR_LERP_PROGRESS := 0.2
const CONSTRUCT_BUILD_CLASS_EXPR := SOURCE_CONSTRUCT_BUILD_CLASS_EXPR
const SOURCE_CONSTRUCT_BUILD_LERP_DELTA_KEY := source_math_callback_registry.LERP_DELTA_KEY
const SOURCE_CONSTRUCT_BUILD_LERP_DELTA_FALLBACK := source_math_callback_registry.MATHF_LERP_DELTA_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_construct_build_method_names"):
		var names = game.call("_construct_build_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_CONSTRUCT_BUILD_LERP_DELTA_KEY: Callable(game, runtime_method_name(method_names, SOURCE_CONSTRUCT_BUILD_LERP_DELTA_KEY, SOURCE_CONSTRUCT_BUILD_LERP_DELTA_FALLBACK)),
	}

static func game_inner_runtime_state(game: Object, current_solid: bool, previous_solid: bool, interactable_with_player_team: bool, current_is_placeable: bool, player_is_builder: bool, build_was_auto_paused: bool, input_is_building: bool, tile_x: int, tile_y: int, rotation: int, current_block: Variant, last_config: Variant, sensor: String, progress: float, active_deconstruct: bool, super_sense_value: float, super_sense_object_value: Variant, floor_solid: bool, floor_has_surface: bool, source_x: float, source_y: float, block_size: int, current_is_air: bool, construct_color_before: float, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return inner_runtime_state(current_solid, previous_solid, interactable_with_player_team, current_is_placeable, player_is_builder, build_was_auto_paused, input_is_building, tile_x, tile_y, rotation, current_block, last_config, sensor, progress, active_deconstruct, super_sense_value, super_sense_object_value, floor_solid, floor_has_surface, source_x, source_y, block_size, current_is_air, construct_color_before, source_delta, callbacks.get(SOURCE_CONSTRUCT_BUILD_LERP_DELTA_KEY, Callable()))

static func set_construct_state(previous_block: Variant, block: Variant, build_cost_multiplier: float) -> Dictionary:
	return source_construct_build_work_state.set_construct_state(previous_block, block, build_cost_multiplier)

static func set_deconstruct_state(previous_block: Variant, build_cost_multiplier: float) -> Dictionary:
	return source_construct_build_work_state.set_deconstruct_state(previous_block, build_cost_multiplier)

static func check_required_state(requirements: Array, inventory: Dictionary, accumulator: Array, items_left: Array, amount: float, remove: bool, build_cost_multiplier: float, team_infinite_resources: bool, state_infinite_resources: bool) -> Dictionary:
	return source_construct_build_work_state.check_required_state(requirements, inventory, accumulator, items_left, amount, remove, build_cost_multiplier, team_infinite_resources, state_infinite_resources)

static func construct_state(previous_block: Variant, current_block: Variant, builder_state: Variant, core_inventory: Dictionary, amount: float, config: Variant, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, core_present: bool, team_infinite_resources: bool, state_infinite_resources: bool, builder_is_player: bool, last_builder_present: bool, net_client: bool, rotation_value: int) -> Dictionary:
	return source_construct_build_work_state.construct_state(previous_block, current_block, builder_state, core_inventory, amount, config, progress_before, accumulator, total_accumulator, items_left, build_cost_multiplier, core_present, team_infinite_resources, state_infinite_resources, builder_is_player, last_builder_present, net_client, rotation_value)

static func deconstruct_state(current_block: Variant, builder_state: Variant, core_inventory: Dictionary, amount: float, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, deconstruct_refund_multiplier: float, core_present: bool, state_infinite_resources: bool, builder_is_player: bool, was_constructing: bool, last_builder_present: bool, core_storage_capacity: int) -> Dictionary:
	return source_construct_build_work_state.deconstruct_state(current_block, builder_state, core_inventory, amount, progress_before, accumulator, total_accumulator, items_left, build_cost_multiplier, deconstruct_refund_multiplier, core_present, state_infinite_resources, builder_is_player, was_constructing, last_builder_present, core_storage_capacity)

static func progress_state(progress_value: float) -> Dictionary:
	return source_construct_build_io_state.progress_state(progress_value)

static func version_state() -> Dictionary:
	return source_construct_build_io_state.version_state()

static func write_state(progress_value: float, previous_block_id: int, current_block_id: int, accumulator: Variant, total_accumulator: Variant, items_left: Variant) -> Dictionary:
	return source_construct_build_io_state.write_state(progress_value, previous_block_id, current_block_id, accumulator, total_accumulator, items_left)

static func _lookup_content_block(content_blocks: Dictionary, block_id: int) -> Variant:
	return source_construct_build_io_state._lookup_content_block(content_blocks, block_id)

static func read_state(progress_value: float, previous_block_id: int, current_block_id: int, accumulator_size: int, accumulator_values: Array, total_accumulator_values: Array, items_left_values: Array, revision_value: int, content_blocks: Dictionary, air_block: Variant, build_cost_multiplier: float) -> Dictionary:
	return source_construct_build_io_state.read_state(progress_value, previous_block_id, current_block_id, accumulator_size, accumulator_values, total_accumulator_values, items_left_values, revision_value, content_blocks, air_block, build_cost_multiplier)

static func _block_identity(block: Variant) -> Variant:
	if block is Dictionary:
		if block.has("id"):
			return block.get("id")
		if block.has("name"):
			return block.get("name")
	return block

static func _blocks_match(left_block: Variant, right_block: Variant) -> bool:
	return _block_identity(left_block) == _block_identity(right_block)

static func draw_state(current_block: Variant, previous_block: Variant, air_block: Variant, source_x: float, source_y: float, rotation_degrees: float, progress_value: float, construct_color: float, source_time: float) -> Dictionary:
	var current_is_air: bool = _blocks_match(current_block, air_block)
	var previous_full_icon: Variant = previous_block.get("fullIcon", null) if previous_block is Dictionary else null
	var previous_full_icon_found: bool = bool(previous_block.get("fullIconFound", false)) if previous_block is Dictionary else false
	var previous_rotate: bool = bool(previous_block.get("rotate", false)) if previous_block is Dictionary else false
	var previous_drawn: bool = not current_is_air and not _blocks_match(previous_block, current_block) and not _blocks_match(previous_block, air_block) and previous_full_icon_found
	var previous_rect_call: Dictionary = {}
	if previous_drawn:
		previous_rect_call = {
			"call": "Draw.rect(previous.fullIcon, x, y, previous.rotate ? rotdeg() : 0);",
			"region": previous_full_icon,
			"x": source_x,
			"y": source_y,
			"rotation": rotation_degrees if previous_rotate else 0.0,
		}
	var generated_icons: Array = current_block.get("generatedIcons", []) if current_block is Dictionary else []
	var region_rotated_1: int = int(current_block.get("regionRotated1", -1)) if current_block is Dictionary else -1
	var region_rotated_2: int = int(current_block.get("regionRotated2", -1)) if current_block is Dictionary else -1
	var current_rotate: bool = bool(current_block.get("rotate", false)) if current_block is Dictionary else false
	var visual_rotation_offset: float = float(current_block.get("visualRotationOffset", 0.0)) if current_block is Dictionary else 0.0
	var no_overrides: bool = region_rotated_1 == -1 and region_rotated_2 == -1
	var icon_draws: Array = []
	if not current_is_air:
		for i in range(generated_icons.size()):
			var region: Variant = generated_icons[i]
			var rotate_icon: bool = current_rotate and (no_overrides or region_rotated_2 == i or region_rotated_1 == i)
			var icon_rotation: float = rotation_degrees + visual_rotation_offset if rotate_icon else 0.0
			icon_draws.append({
				"index": i,
				"region": region,
				"shader_region": region,
				"shader_time": source_time,
				"shader_progress": progress_value,
				"rotate_icon": rotate_icon,
				"rect_call": {
					"call": "Draw.rect(region, x, y, current.rotate && (noOverrides || current.regionRotated2 == i || current.regionRotated1 == i) ? rotdeg() + current.visualRotationOffset : 0);",
					"region": region,
					"x": source_x,
					"y": source_y,
					"rotation": icon_rotation,
				},
				"flush_call": {"call": "Draw.flush();"},
			})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_DRAW_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"draw_method": "public void draw(){",
		"air_guard_comment": "//do not draw air",
		"air_guard_expr": "if(current == Blocks.air) return;",
		"previous_draw_guard_expr": "if(previous != current && previous != Blocks.air && previous.fullIcon.found()){",
		"previous_rect_expr": "Draw.rect(previous.fullIcon, x, y, previous.rotate ? rotdeg() : 0);",
		"draw_layer_expr": "Draw.draw(Layer.blockBuilding, () -> {",
		"draw_color_expr": "Draw.color(Pal.accent, Pal.remove, constructColor);",
		"no_overrides_expr": "boolean noOverrides = current.regionRotated1 == -1 && current.regionRotated2 == -1;",
		"icon_loop_expr": "for(TextureRegion region : current.getGeneratedIcons()){",
		"shader_region_expr": "Shaders.blockbuild.region = region;",
		"shader_time_expr": "Shaders.blockbuild.time = Time.time;",
		"shader_progress_expr": "Shaders.blockbuild.progress = progress;",
		"current_rect_expr": "Draw.rect(region, x, y, current.rotate && (noOverrides || current.regionRotated2 == i || current.regionRotated1 == i) ? rotdeg() + current.visualRotationOffset : 0);",
		"flush_expr": "Draw.flush();",
		"draw_color_reset_expr": "Draw.color();",
		"current_block": current_block,
		"previous_block": previous_block,
		"air_block": air_block,
		"current_is_air": current_is_air,
		"returned_early": current_is_air,
		"source_x": source_x,
		"source_y": source_y,
		"rotation_degrees": rotation_degrees,
		"progress": progress_value,
		"construct_color": construct_color,
		"source_time": source_time,
		"previous_full_icon_found": previous_full_icon_found,
		"previous_drawn": previous_drawn,
		"previous_rect_call": previous_rect_call,
		"draw_layer_called": not current_is_air,
		"draw_layer": "Layer.blockBuilding",
		"draw_color_call": {"from": "Pal.accent", "to": "Pal.remove", "t": construct_color} if not current_is_air else {},
		"region_rotated_1": region_rotated_1,
		"region_rotated_2": region_rotated_2,
		"no_overrides": no_overrides,
		"generated_icons": generated_icons,
		"icon_draws": icon_draws,
		"draw_color_reset_called": not current_is_air,
	}

static func inner_runtime_state(current_solid: bool, previous_solid: bool, interactable_with_player_team: bool, current_is_placeable: bool, player_is_builder: bool, build_was_auto_paused: bool, input_is_building: bool, tile_x: int, tile_y: int, rotation: int, current_block: Variant, last_config: Variant, sensor: String, progress: float, active_deconstruct: bool, super_sense_value: float, super_sense_object_value: Variant, floor_solid: bool, floor_has_surface: bool, source_x: float, source_y: float, block_size: int, current_is_air: bool, construct_color_before: float, source_delta: float, lerp_delta: Callable) -> Dictionary:
	var display_name_value: String = str(current_block.get("localizedName", "")) if current_block is Dictionary else ""
	var display_icon_value: Variant = current_block.get("fullIcon", "") if current_block is Dictionary else ""
	var check_solid_value: bool = current_solid or previous_solid
	var cursor_value: String = "hand" if interactable_with_player_team else "arrow"
	var tapped_called: bool = current_is_placeable and player_is_builder
	var input_is_building_after: bool = input_is_building
	if tapped_called and build_was_auto_paused and not input_is_building:
		input_is_building_after = true
	var add_build_called: bool = tapped_called
	var sense_value: float = super_sense_value
	if sensor == "progress":
		sense_value = clampf(progress, 0.0, 1.0)
	elif sensor == "breaking":
		sense_value = 1.0 if active_deconstruct else 0.0
	var sense_object_value: Variant = super_sense_object_value
	if sensor == "building":
		sense_object_value = current_block
	var on_destroyed_smoke_called: bool = true
	var on_destroyed_rubble_called: bool = not floor_solid and floor_has_surface
	var update_tile_remove_called: bool = current_is_air
	var construct_color_target: float = 1.0 if active_deconstruct else 0.0
	var construct_color_after: float = float(lerp_delta.call(construct_color_before, construct_color_target, CONSTRUCT_BUILD_COLOR_LERP_PROGRESS, source_delta))
	var update_tile_reset_called: bool = true
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_INNER_RUNTIME_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"display_name_method": "public String getDisplayName(){",
		"display_icon_method": "public TextureRegion getDisplayIcon(){",
		"check_solid_method": "public boolean checkSolid(){",
		"check_solid_return_expr": "return current.solid || previous.solid;",
		"cursor_method": "public Cursor getCursor(){",
		"cursor_return_expr": "return interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;",
		"tapped_method": "public void tapped(){",
		"tapped_guard_expr": "if(current.isPlaceable() && player.isBuilder()){",
		"autopause_guard_expr": "if(control.input.buildWasAutoPaused && !control.input.isBuilding){",
		"add_build_expr": "player.unit().addBuild(new BuildPlan(tile.x, tile.y, rotation, current, lastConfig), false);",
		"sense_method": "public double sense(LAccess sensor){",
		"progress_case_expr": "case progress -> Mathf.clamp(progress);",
		"breaking_case_expr": "case breaking -> activeDeconstruct ? 1 : 0;",
		"sense_object_method": "public Object senseObject(LAccess sensor){",
		"building_case_expr": "case building -> current;",
		"on_destroyed_method": "public void onDestroyed(){",
		"smoke_expr": "Fx.blockExplosionSmoke.at(tile);",
		"rubble_guard_expr": "if(!tile.floor().solid && tile.floor().hasSurface()){",
		"rubble_expr": "Effect.rubble(x, y, size);",
		"update_tile_method": "public void updateTile(){",
		"air_remove_guard_expr": "if(current == Blocks.air){",
		"remove_expr": "remove();",
		"construct_color_expr": "constructColor = Mathf.lerpDelta(constructColor, activeDeconstruct ? 1f : 0f, 0.2f);",
		"active_deconstruct_reset_expr": "activeDeconstruct = false;",
		"display_name": display_name_value,
		"display_icon": display_icon_value,
		"check_solid": check_solid_value,
		"cursor": cursor_value,
		"tapped_called": tapped_called,
		"input_is_building_after": input_is_building_after,
		"add_build_called": add_build_called,
		"sense_value": sense_value,
		"sense_object_value": sense_object_value,
		"on_destroyed_smoke_called": on_destroyed_smoke_called,
		"on_destroyed_rubble_called": on_destroyed_rubble_called,
		"update_tile_remove_called": update_tile_remove_called,
		"construct_color_before": construct_color_before,
		"construct_color_target": construct_color_target,
		"construct_color_after": construct_color_after,
		"update_tile_reset_called": update_tile_reset_called,
		"current_solid": current_solid,
		"previous_solid": previous_solid,
		"interactable_with_player_team": interactable_with_player_team,
		"current_is_placeable": current_is_placeable,
		"player_is_builder": player_is_builder,
		"build_was_auto_paused": build_was_auto_paused,
		"input_is_building": input_is_building,
		"tile_x": tile_x,
		"tile_y": tile_y,
		"rotation": rotation,
		"current_block": current_block,
		"last_config": last_config,
		"sensor": sensor,
		"progress": progress,
		"active_deconstruct": active_deconstruct,
		"super_sense_value": super_sense_value,
		"super_sense_object_value": super_sense_object_value,
		"floor_solid": floor_solid,
		"floor_has_surface": floor_has_surface,
		"source_x": source_x,
		"source_y": source_y,
		"block_size": block_size,
		"current_is_air": current_is_air,
		"source_delta": source_delta,
	}
