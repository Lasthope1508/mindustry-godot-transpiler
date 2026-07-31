extends RefCounted
class_name SourceOverdriveProjectorState

const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_projector_boost_state := preload("res://src/game/SourceProjectorBoostState.gd")
const source_overdrive_boost_state := preload("res://src/game/SourceOverdriveBoostState.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")

const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_METHOD := "public float realBoost(){\n            return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;\n        }"
const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_RETURN := "return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;"
const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_SPEED_BOOST_FIELD := "public float speedBoost = 1.5f;"
const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_SPEED_BOOST_PHASE_FIELD := "public float speedBoostPhase = 0.75f;"
const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_PHASE_HEAT_FIELD := "public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency, useProgress;"
const SOURCE_OVERDRIVE_PROJECTOR_RANGE_METHOD := "public float range(){\n            return range;\n        }"
const SOURCE_OVERDRIVE_PROJECTOR_SELECT_METHOD := "public void drawSelect(){\n            float realRange = range + phaseHeat * phaseRangeBoost;"
const SOURCE_OVERDRIVE_PROJECTOR_PLACE_METHOD := "public void drawPlace(int x, int y, int rotation, boolean valid){\n        super.drawPlace(x, y, rotation, valid);"
const SOURCE_OVERDRIVE_PROJECTOR_TARGET_FILTER_BOOST_BRANCH := "if(charge >= reload){\n                float realRange = range + phaseHeat * phaseRangeBoost;"
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_METHOD := "public void setBars(){"
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_ADD_BAR := "addBar(\"boost\", (OverdriveBuild entity) -> new Bar(() -> Core.bundle.format(\"bar.boost\", Mathf.round(Math.max((entity.realBoost() * 100 - 100), 0))), () -> Pal.accent, () -> entity.realBoost() / (hasBoost ? speedBoost + speedBoostPhase : speedBoost)));"
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_REAL_BOOST_CALL := "entity.realBoost()"
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_DENOMINATOR := "hasBoost ? speedBoost + speedBoostPhase : speedBoost"
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_SPEED_BOOST_FIELD := "public float speedBoost = 1.5f;"
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_SPEED_BOOST_PHASE_FIELD := "public float speedBoostPhase = 0.75f;"
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_HAS_BOOST_FIELD := "public boolean hasBoost = true;"
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_METHOD := "public void drawLight(){"
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_CALL := "Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);"
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_EMIT_FIELD := "emitLight = true;"
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_RADIUS_FIELD := "lightRadius = 50f;"
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_BASE_COLOR_FIELD := "public Color baseColor = Color.valueOf(\"feb380\");"
const SOURCE_OVERDRIVE_PROJECTOR_LIGHT_SMOOTH_EFFICIENCY_FIELD := "public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency, useProgress;"
const SOURCE_OVERDRIVE_PROJECTOR_DRAW_METHOD := "public void draw(){"
const SOURCE_OVERDRIVE_PROJECTOR_DRAW_LOD_GUARD := "if(!Lod.l2) return;"
const SOURCE_OVERDRIVE_PROJECTOR_DRAW_LINE_DIMENSIONS := "float r = Math.max(0f, Mathf.clamp(2f - f * 2f) * size * tilesize / 2f - f - 0.2f), w = Mathf.clamp(0.5f - f) * size * tilesize;"

static func state_value(sprite, state: Dictionary, default_value: float) -> float:
	if not is_instance_valid(sprite):
		return default_value
	var key := str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_CELL_KEY_META_KEY, ""))
	if key.is_empty():
		return default_value
	return float(state.get(key, default_value))

static func game_state_value_at_cell(game: Object, x: int, y: int, state: Dictionary, default_value: float) -> float:
	var sprite = game_sprite_at_cell(game, x, y)
	return state_value(sprite, state, default_value)

static func capture_state(sprite, heat: Dictionary, smooth_efficiency: Dictionary, phase_heat: Dictionary, charge: Dictionary, use_progress: Dictionary) -> Dictionary:
	var key := str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_CELL_KEY_META_KEY, "")) if is_instance_valid(sprite) else ""
	return {
		"cell_key": key,
		"heat": float(heat.get(key, 0.0)),
		"smooth_efficiency": float(smooth_efficiency.get(key, 0.0)),
		"phase_heat": float(phase_heat.get(key, 0.0)),
		"charge": float(charge.get(key, 0.0)),
		"use_progress": float(use_progress.get(key, 0.0)),
	}

static func game_capture_state_at_cell(game: Object, x: int, y: int, heat: Dictionary, smooth_efficiency: Dictionary, phase_heat: Dictionary, charge: Dictionary, use_progress: Dictionary) -> Dictionary:
	var sprite = game_sprite_at_cell(game, x, y)
	return capture_state(sprite, heat, smooth_efficiency, phase_heat, charge, use_progress)

static func game_sprite_at_cell(game: Object, x: int, y: int):
	return source_texture_runtime_state.game_sprite_at_cell(game, x, y)

static func game_block_from_sprite(game: Object, sprite):
	if game == null:
		return null
	return source_texture_runtime_state.block_from_sprite(game, sprite)

static func projector_block_size(overdrive_projector) -> int:
	return source_block_metadata_state.block_size(overdrive_projector)

static func projector_reload(overdrive_projector) -> float:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return float(properties.get("reload", source_projector_defaults.OVERDRIVE_RELOAD_DEFAULT))

static func use_time(overdrive_projector) -> float:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return float(properties.get("useTime", source_projector_defaults.OVERDRIVE_USE_TIME_DEFAULT))

static func has_boost(overdrive_projector) -> bool:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return bool(properties.get("hasBoost", source_projector_defaults.OVERDRIVE_HAS_BOOST_DEFAULT))

static func projector_range(overdrive_projector, phase_heat := 0.0) -> float:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	var base_range := float(properties.get("range", source_projector_defaults.OVERDRIVE_RANGE_DEFAULT))
	var phase_range_boost := float(properties.get("phaseRangeBoost", source_projector_defaults.OVERDRIVE_PHASE_RANGE_BOOST_DEFAULT))
	return base_range + phase_heat * phase_range_boost

static func select_state(overdrive_projector, phase_heat := 0.0) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return {
		"range": projector_range(overdrive_projector, phase_heat),
		"color": str(properties.get("baseColor", source_projector_defaults.OVERDRIVE_BASE_COLOR_DEFAULT)),
	}

static func place_state(overdrive_projector) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return {
		"range": float(properties.get("range", source_projector_defaults.OVERDRIVE_RANGE_DEFAULT)),
		"color": str(properties.get("baseColor", source_projector_defaults.OVERDRIVE_BASE_COLOR_DEFAULT)),
	}

static func target_filter_state(overdrive_projector, target_block, distance: float, phase_heat := 0.0) -> Dictionary:
	var real_range := projector_range(overdrive_projector, phase_heat)
	var can_overdrive := source_block_metadata_state.block_can_overdrive(target_block)
	var in_range := distance <= real_range
	return {
		"real_range": real_range,
		"distance": distance,
		"can_overdrive": can_overdrive,
		"in_range": in_range,
		"eligible": in_range and can_overdrive,
	}

static func real_boost(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	var speed_boost := float(properties.get("speedBoost", source_projector_defaults.OVERDRIVE_SPEED_BOOST_DEFAULT))
	var speed_boost_phase := float(properties.get("speedBoostPhase", source_projector_defaults.OVERDRIVE_SPEED_BOOST_PHASE_DEFAULT))
	return (speed_boost + phase_heat * speed_boost_phase) * efficiency

static func boost_bar_fraction(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	var speed_boost := float(properties.get("speedBoost", source_projector_defaults.OVERDRIVE_SPEED_BOOST_DEFAULT))
	var speed_boost_phase := float(properties.get("speedBoostPhase", source_projector_defaults.OVERDRIVE_SPEED_BOOST_PHASE_DEFAULT))
	var boost_enabled := bool(properties.get("hasBoost", source_projector_defaults.OVERDRIVE_HAS_BOOST_DEFAULT))
	var denominator := speed_boost + speed_boost_phase if boost_enabled else speed_boost
	if denominator == 0.0:
		return 0.0
	return real_boost(overdrive_projector, phase_heat, efficiency) / denominator

static func light_state(overdrive_projector, smooth_efficiency: float) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	if not bool(properties.get("emitLight", source_projector_defaults.OVERDRIVE_EMIT_LIGHT_DEFAULT)):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return {
		"color": str(properties.get("baseColor", source_projector_defaults.OVERDRIVE_BASE_COLOR_DEFAULT)),
		"radius": float(properties.get("lightRadius", source_projector_defaults.OVERDRIVE_LIGHT_RADIUS_DEFAULT)) * smooth_efficiency,
		"alpha": source_projector_defaults.PROJECTOR_LIGHT_OPACITY_DEFAULT * smooth_efficiency,
	}

static func game_light_state_at_cell(game: Object, x: int, y: int) -> Dictionary:
	var sprite = game_sprite_at_cell(game, x, y)
	var block = game_block_from_sprite(game, sprite)
	if not bool(game.call("source_overdrive_projector_is_projector", block)):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return game.call("source_overdrive_projector_light_state", block, game.call("overdrive_projector_smooth_efficiency_at_cell", x, y))

static func draw_state(overdrive_projector, heat: float, phase_heat: float, tile_size: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	if overdrive_projector == null or not lod_l2:
		return {"visible": false, "f": 0.0, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "top_rect": false, "lod_alpha2": 0.0, "stroke": 0.0, "line_r": 0.0, "line_w": 0.0}
	var f := 1.0 - fmod(source_time_ticks / source_projector_defaults.PROJECTOR_TIME_LOOP_PERIOD, 1.0)
	var line_r: float = max(0.0, clamp(2.0 - f * 2.0, 0.0, 1.0) * float(projector_block_size(overdrive_projector)) * float(tile_size) / 2.0 - f - 0.2)
	var line_w: float = clamp(0.5 - f, 0.0, 1.0) * float(projector_block_size(overdrive_projector)) * float(tile_size)
	return {
		"visible": true,
		"f": f,
		"base_color": str(properties.get("baseColor", source_projector_defaults.OVERDRIVE_BASE_COLOR_DEFAULT)),
		"phase_color": str(properties.get("phaseColor", "ffd59e")),
		"phase_heat": phase_heat,
		"top_alpha": heat * source_math_state.source_absin(source_time_ticks, 50.0 / source_math_defaults.PI2, 1.0) * 0.5 * lod_alpha2,
		"top_rect": true,
		"lod_alpha2": lod_alpha2,
		"stroke": (2.0 * f + 0.1) * heat,
		"line_r": line_r,
		"line_w": line_w,
	}

static func game_draw_state_at_cell(game: Object, x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	var sprite = game_sprite_at_cell(game, x, y)
	var block = game_block_from_sprite(game, sprite)
	if not bool(game.call("source_overdrive_projector_is_projector", block)):
		return game.call("source_overdrive_projector_draw_state", null, 0.0, 0.0, source_time_ticks, false, 0.0)
	return game.call("source_overdrive_projector_draw_state", block, game.call("overdrive_projector_heat_at_cell", x, y), game.call("overdrive_projector_phase_heat_at_cell", x, y), source_time_ticks)

static func runtime_step_state(current_state: Dictionary, source_delta: float, booster_items: int, has_boost_value: bool, reload_value: float, use_time_value: float) -> Dictionary:
	var smooth_efficiency_after: float = source_math_state.source_lerp_delta(float(current_state.get("smooth_efficiency", 0.0)), 1.0, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, source_delta)
	var heat_after: float = source_math_state.source_lerp_delta(float(current_state.get("heat", 0.0)), 1.0, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, source_delta)
	var charge_after: float = float(current_state.get("charge", 0.0)) + heat_after * source_delta
	var optional_efficiency_before := 1.0 if booster_items > 0 else 0.0
	var phase_target := optional_efficiency_before if has_boost_value else 0.0
	var phase_heat_after: float = source_math_state.source_lerp_delta(float(current_state.get("phase_heat", 0.0)), phase_target, source_projector_boost_state.SOURCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS, source_delta)
	var use_progress_after: float = float(current_state.get("use_progress", 0.0)) + source_delta
	var charge_ready := charge_after >= reload_value
	return {
		"smooth_efficiency": smooth_efficiency_after,
		"heat": heat_after,
		"charge": 0.0 if charge_ready else charge_after,
		"phase_heat": phase_heat_after,
		"use_progress": fmod(use_progress_after, use_time_value) if use_time_value > 0.0 and use_progress_after >= use_time_value else use_progress_after,
		"charge_ready": charge_ready,
		"use_ready": use_time_value > 0.0 and use_progress_after >= use_time_value,
		"boost": real_boost(current_state.get("block", null), phase_heat_after),
		"boost_duration": reload_value + 1.0,
	}

static func runtime_step_context(game, key: String, block, source_delta: float) -> Dictionary:
	return {
		"game": game,
		"key": key,
		"block": block,
		"source_delta": source_delta,
		"current_state": {
			"block": block,
			"heat": float(game.overdrive_projector_heat.get(key, 0.0)),
			"smooth_efficiency": float(game.overdrive_projector_smooth_efficiency.get(key, 0.0)),
			"phase_heat": float(game.overdrive_projector_phase_heat.get(key, 0.0)),
			"charge": float(game.overdrive_projector_charges.get(key, 0.0)),
			"use_progress": float(game.overdrive_projector_use_progress.get(key, 0.0)),
		},
		"booster_items": int(game.overdrive_projector_booster_items.get(key, 0)),
		"reload_value": game.call("source_overdrive_projector_reload", block),
		"use_time_value": game.call("source_overdrive_projector_use_time", block),
		"has_boost_value": game.call("source_overdrive_projector_has_boost", block),
	}

static func runtime_step_from_context(context: Dictionary) -> Dictionary:
	return runtime_step_state(
		context.get("current_state", {}),
		float(context.get("source_delta", 0.0)),
		int(context.get("booster_items", 0)),
		bool(context.get("has_boost_value", false)),
		float(context.get("reload_value", source_projector_defaults.OVERDRIVE_RELOAD_DEFAULT)),
		float(context.get("use_time_value", source_projector_defaults.OVERDRIVE_USE_TIME_DEFAULT))
	)

static func boost_application_state(boost_range: float, boost: float, boost_duration: float, boosted_state: Dictionary, applied := true) -> Dictionary:
	return {
		"boost_range": boost_range,
		"boost": boost,
		"boost_duration": boost_duration,
		"boosted_state": boosted_state,
		"applied": applied,
	}

static func boost_application_context(game, sprite, block, runtime_step: Dictionary) -> Dictionary:
	var target_block = game_block_from_sprite(game, sprite)
	var distance := 0.0
	var filter_state: Dictionary = game.call("source_overdrive_projector_target_filter_state", block, target_block, distance, float(runtime_step.get("phase_heat", 0.0)))
	var boost_input := source_overdrive_boost_state.boost_input(sprite, target_block, source_block_defaults.TIME_SCALE_DEFAULT, source_block_defaults.CAN_OVERDRIVE_DEFAULT)
	var result: Dictionary = game.call("source_building_apply_boost_state", float(boost_input.get("time_scale", source_block_defaults.TIME_SCALE_DEFAULT)), float(boost_input.get("time_scale_duration", 0.0)), float(runtime_step.get("boost", 1.0)), float(runtime_step.get("boost_duration", source_projector_defaults.OVERDRIVE_USE_TIME_DEFAULT)), bool(boost_input.get("can_overdrive", source_block_defaults.CAN_OVERDRIVE_DEFAULT)))
	var boosted_state := source_overdrive_boost_state.apply_boost_result(sprite, result, source_block_defaults.TIME_SCALE_DEFAULT)
	game.set("last_overdrive_projector_boosted_block_id", str(boosted_state.get("block_id", "")))
	game.set("last_overdrive_projector_boosted_cell", boosted_state.get("cell", Vector2i.ZERO))
	return boost_application_state(float(filter_state.get("real_range", 0.0)), float(runtime_step.get("boost", 0.0)), float(runtime_step.get("boost_duration", 0.0)), boosted_state, bool(filter_state.get("eligible", false)))

static func find_overdrive_boost_target(game, overdrive_cell: Vector2i, overdrive_projector, phase_heat := 0.0):
	var overdrive_origin: Vector2 = game.call("source_block_sprite_base_position", overdrive_projector, overdrive_cell)
	for origin_key in game.placed_block_origins.keys():
		var target = game.placed_block_origins.get(origin_key)
		var target_block = game_block_from_sprite(game, target)
		var target_cell: Vector2i = target.get_meta("origin_cell", Vector2i.ZERO)
		var target_origin: Vector2 = game.call("source_block_sprite_base_position", target_block, target_cell)
		var distance := overdrive_origin.distance_to(target_origin)
		var filter_state: Dictionary = game.call("source_overdrive_projector_target_filter_state", overdrive_projector, target_block, distance, phase_heat)
		if bool(filter_state.get("eligible", false)):
			return target
	return null

static func apply_overdrive_boost_to_sprite(game, target, intensity: float, duration: float) -> Dictionary:
	if target == null:
		return {"applied": false}
	var target_block = game_block_from_sprite(game, target)
	var boost_input := source_overdrive_boost_state.boost_input(target, target_block, source_block_defaults.TIME_SCALE_DEFAULT, source_block_defaults.CAN_OVERDRIVE_DEFAULT)
	var result: Dictionary = game.call("source_building_apply_boost_state", float(boost_input.get("time_scale", source_block_defaults.TIME_SCALE_DEFAULT)), float(boost_input.get("time_scale_duration", 0.0)), intensity, duration, bool(boost_input.get("can_overdrive", source_block_defaults.CAN_OVERDRIVE_DEFAULT)))
	var boosted_state := source_overdrive_boost_state.apply_boost_result(target, result, source_block_defaults.TIME_SCALE_DEFAULT)
	game.set("last_overdrive_projector_boosted_block_id", str(boosted_state.get("block_id", "")))
	game.set("last_overdrive_projector_boosted_cell", boosted_state.get("cell", Vector2i.ZERO))
	return boosted_state

static func simulate_projectors(game, delta: float) -> void:
	if game == null:
		return
	var source_delta := delta * 1.0
	for key in game.overdrive_projector_heat.keys():
		var overdrive_cell := _cell_from_key(key)
		var sprite = game_sprite_at_cell(game, overdrive_cell.x, overdrive_cell.y)
		var block = game_block_from_sprite(game, sprite)
		if block == null or not bool(game.call("source_overdrive_projector_is_projector", block)):
			continue
		var runtime_context := runtime_step_context(game, key, block, source_delta)
		var runtime_step := runtime_step_from_context(runtime_context)
		game.overdrive_projector_smooth_efficiency[key] = float(runtime_step.get("smooth_efficiency", 0.0))
		game.overdrive_projector_heat[key] = float(runtime_step.get("heat", 0.0))
		game.overdrive_projector_phase_heat[key] = float(runtime_step.get("phase_heat", 0.0))
		game.overdrive_projector_charges[key] = float(runtime_step.get("charge", 0.0))
		game.overdrive_projector_use_progress[key] = float(runtime_step.get("use_progress", 0.0))
		var phase_heat := float(runtime_step.get("phase_heat", 0.0))
		var target = game.call("find_overdrive_boost_target", overdrive_cell, block, phase_heat)
		var boost := float(runtime_step.get("boost", 1.0))
		var boost_duration := float(runtime_step.get("boost_duration", source_projector_defaults.OVERDRIVE_RELOAD_DEFAULT + 1.0))
		if bool(runtime_step.get("charge_ready", false)):
			game.call("apply_overdrive_boost_to_sprite", target, boost, boost_duration)
		var boost_application := boost_application_context(game, sprite, block, runtime_step)
		game.set("last_overdrive_projector_boost_range", float(boost_application.get("boost_range", 0.0)))
		game.set("last_overdrive_projector_boost", float(boost_application.get("boost", 0.0)))
		game.set("last_overdrive_projector_boost_duration", float(boost_application.get("boost_duration", 0.0)))

static func step_projectors(game, seconds: float) -> Dictionary:
	simulate_projectors(game, seconds)
	var state: Dictionary = {}
	for key in game.overdrive_projector_heat.keys():
		var origin_cell := _cell_from_key(key)
		state = game.call("overdrive_projector_state_at_cell", origin_cell.x, origin_cell.y)
		break
	var last_overdrive_projector_boosted_cell := _vector2i_game_property(game, "last_overdrive_projector_boosted_cell")
	state["last_overdrive_projector_boosted_block_id"] = str(game.get("last_overdrive_projector_boosted_block_id"))
	state["last_overdrive_projector_boosted_cell"] = last_overdrive_projector_boosted_cell
	state["last_overdrive_projector_boosted_time_scale"] = game.call("source_block_time_scale_at_cell", last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y)
	state["last_overdrive_projector_boosted_time_scale_duration"] = game.call("source_block_time_scale_duration_at_cell", last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y)
	return state

static func _cell_from_key(key: String) -> Vector2i:
	var parts := key.split(",")
	if parts.size() != 2:
		return Vector2i.ZERO
	return Vector2i(int(parts[0]), int(parts[1]))

static func _vector2i_game_property(game: Object, property_name: String, default_value := Vector2i.ZERO) -> Vector2i:
	if game == null:
		return default_value
	var value = game.get(property_name)
	if value is Vector2i:
		return value
	return default_value
