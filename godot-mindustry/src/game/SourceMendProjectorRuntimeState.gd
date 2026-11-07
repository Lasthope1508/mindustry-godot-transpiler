extends RefCounted
class_name SourceMendProjectorRuntimeState

const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_projector_boost_state := preload("res://src/game/SourceProjectorBoostState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_mend_projector_display_state := preload("res://src/game/SourceMendProjectorDisplayState.gd")

static func game_source_delta(_game: Object, seconds: float) -> float:
	return seconds * source_time_defaults.TICK_RATE

static func target_health(sprite) -> float:
	if not is_instance_valid(sprite):
		return 0.0
	return float(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_HEALTH_META_KEY, 0.0))

static func target_max_health(sprite) -> float:
	if not is_instance_valid(sprite):
		return 0.0
	return float(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0))

static func capture_heal_result(target, healed_amount: float) -> Dictionary:
	return {
		"healed": true,
		"healed_amount": healed_amount,
		"block_id": str(target.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")) if is_instance_valid(target) else "",
		"cell": target.get_meta("origin_cell", Vector2i.ZERO) if is_instance_valid(target) else Vector2i.ZERO,
		"target_health": target_health(target),
		"target_max_health": target_max_health(target),
	}

static func heal_application_state(healed_state: Dictionary, healed := true) -> Dictionary:
	var result := healed_state.duplicate(true)
	result["healed"] = healed
	return result

static func find_damaged_block_in_range(game: Object, mend_cell: Vector2i, mend_projector, phase_heat := 0.0):
	var mend_origin: Vector2 = game.call("source_block_sprite_base_position", mend_projector, mend_cell)
	var real_range := float(game.call("source_mend_projector_range", mend_projector, phase_heat))
	var placed_block_origins: Dictionary = game.get("placed_block_origins")
	for origin_key in placed_block_origins.keys():
		var sprite = placed_block_origins.get(origin_key)
		if not bool(game.call("source_block_is_damaged", sprite)):
			continue
		var target_block = _block_from_sprite(game, sprite)
		if target_block == null:
			continue
		var target_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		var target_origin: Vector2 = game.call("source_block_sprite_base_position", target_block, target_cell)
		if mend_origin.distance_to(target_origin) <= real_range:
			return sprite
	return null

static func heal_application_context(game, sprite, block, runtime_step: Dictionary) -> Dictionary:
	if game == null or sprite == null:
		return {"healed": false}
	var phase_heat := float(runtime_step.get("phase_heat", 0.0))
	var mend_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
	var target_block = find_damaged_block_in_range(game, mend_cell, block, phase_heat)
	if target_block == null:
		return {"healed": false, "healed_amount": 0.0, "block_id": "", "cell": Vector2i.ZERO, "target_health": 0.0, "target_max_health": 0.0}
	target_block = _block_from_sprite(game, target_block)
	var healed_amount := float(game.call("source_mend_projector_repair_amount", block, target_block, phase_heat))
	healed_amount *= float(runtime_step.get("efficiency", 1.0))
	game.call("repair_block_sprite", target_block, healed_amount)
	return capture_heal_result(target_block, healed_amount)

static func state_value(sprite, state: Dictionary, default_value: float) -> float:
	if not is_instance_valid(sprite):
		return default_value
	var key := str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_CELL_KEY_META_KEY, ""))
	if key.is_empty():
		return default_value
	return float(state.get(key, default_value))

static func phase_heat_at_cell(game: Object, x: int, y: int) -> float:
	var sprite = _sprite_at_cell(game, x, y)
	return state_value(sprite, _state_dict(game, "mend_projector_phase_heat"), 0.0)

static func smooth_efficiency_at_cell(game: Object, x: int, y: int) -> float:
	var sprite = _sprite_at_cell(game, x, y)
	return state_value(sprite, _state_dict(game, "mend_projector_smooth_efficiency"), 0.0)

static func heat_at_cell(game: Object, x: int, y: int) -> float:
	var sprite = _sprite_at_cell(game, x, y)
	return state_value(sprite, _state_dict(game, "mend_projector_heat"), 0.0)

static func charge_at_cell(game: Object, x: int, y: int) -> float:
	var sprite = _sprite_at_cell(game, x, y)
	return state_value(sprite, _state_dict(game, "mend_projector_charges"), 0.0)

static func progress_at_cell(game: Object, x: int, y: int) -> float:
	var sprite = _sprite_at_cell(game, x, y)
	var block = _block_from_sprite(game, sprite)
	if not _is_mend_projector(game, block):
		return 0.0
	return float(game.call("source_mend_projector_progress", block, charge_at_cell(game, x, y)))

static func light_state_at_cell(game: Object, x: int, y: int) -> Dictionary:
	var sprite = _sprite_at_cell(game, x, y)
	var block = _block_from_sprite(game, sprite)
	if not _is_mend_projector(game, block):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return source_mend_projector_display_state.light_state(block, smooth_efficiency_at_cell(game, x, y))

static func select_state_at_cell(game: Object, x: int, y: int) -> Dictionary:
	var sprite = _sprite_at_cell(game, x, y)
	var block = _block_from_sprite(game, sprite)
	if not _is_mend_projector(game, block):
		return {"range": 0.0, "color": ""}
	return source_mend_projector_display_state.select_state(block, phase_heat_at_cell(game, x, y))

static func draw_state_at_cell(game: Object, x: int, y: int, source_time_ticks := 0.0, tile_size := 0.0) -> Dictionary:
	var sprite = _sprite_at_cell(game, x, y)
	var block = _block_from_sprite(game, sprite)
	if not _is_mend_projector(game, block):
		return source_mend_projector_display_state.draw_state(null, 0.0, 0.0, tile_size, source_time_ticks, false, 0.0)
	return source_mend_projector_display_state.draw_state(block, heat_at_cell(game, x, y), phase_heat_at_cell(game, x, y), tile_size, source_time_ticks)

static func state_at_cell(game: Object, x: int, y: int) -> Dictionary:
	var sprite = _sprite_at_cell(game, x, y)
	var mend_state := capture_state(
		sprite,
		_state_dict(game, "mend_projector_heat"),
		_state_dict(game, "mend_projector_smooth_efficiency"),
		_state_dict(game, "mend_projector_phase_heat"),
		_state_dict(game, "mend_projector_charges")
	)
	var block = _block_from_sprite(game, sprite)
	mend_state["progress"] = float(game.call("source_mend_projector_progress", block, float(mend_state.get("charge", 0.0)))) if _is_mend_projector(game, block) else 0.0
	return mend_state

static func capture_state(sprite, heat: Dictionary, smooth_efficiency: Dictionary, phase_heat: Dictionary, charge: Dictionary) -> Dictionary:
	var key := str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_CELL_KEY_META_KEY, "")) if is_instance_valid(sprite) else ""
	if key.is_empty():
		return {
			"cell_key": key,
			"heat": 0.0,
			"smooth_efficiency": 0.0,
			"phase_heat": 0.0,
			"charge": 0.0,
			"progress": 0.0,
		}
	return {
		"cell_key": key,
		"heat": float(heat.get(key, 0.0)),
		"smooth_efficiency": float(smooth_efficiency.get(key, 0.0)),
		"phase_heat": float(phase_heat.get(key, 0.0)),
		"charge": float(charge.get(key, 0.0)),
		"progress": 0.0,
	}

static func runtime_step_state(current_state: Dictionary, source_delta: float, booster_items: int, use_time_value: float, reload_value: float) -> Dictionary:
	var smooth_efficiency_after: float = source_math_state.source_lerp_delta(float(current_state.get("smooth_efficiency", 0.0)), 1.0, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, source_delta)
	var heat_after: float = source_math_state.source_lerp_delta(float(current_state.get("heat", 0.0)), 1.0, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, source_delta)
	var charge_after: float = float(current_state.get("charge", 0.0)) + heat_after * source_delta
	var optional_efficiency_before := 1.0 if booster_items > 0 else 0.0
	var phase_heat_after: float = source_math_state.source_lerp_delta(float(current_state.get("phase_heat", 0.0)), optional_efficiency_before, source_projector_boost_state.SOURCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS, source_delta)
	var booster_timer_after: float = float(current_state.get("booster_timer", 0.0)) + source_delta
	var booster_items_after := booster_items
	if booster_timer_after >= use_time_value:
		booster_timer_after = fmod(booster_timer_after, use_time_value) if use_time_value > 0.0 else 0.0
		booster_items_after = max(0, booster_items_after - 1)
	return {
		"smooth_efficiency": smooth_efficiency_after,
		"heat": heat_after,
		"charge": charge_after,
		"phase_heat": phase_heat_after,
		"booster_timer": booster_timer_after,
		"booster_items": booster_items_after,
		"charge_ready": charge_after >= reload_value,
	}

static func runtime_step_context(game, key: String, block, source_delta: float) -> Dictionary:
	return {
		"game": game,
		"key": key,
		"block": block,
		"source_delta": source_delta,
		"current_state": {
			"heat": float(game.mend_projector_heat.get(key, 0.0)),
			"smooth_efficiency": float(game.mend_projector_smooth_efficiency.get(key, 0.0)),
			"phase_heat": float(game.mend_projector_phase_heat.get(key, 0.0)),
			"charge": float(game.mend_projector_charges.get(key, 0.0)),
			"booster_timer": float(game.mend_projector_booster_timers.get(key, 0.0)),
		},
		"booster_items": int(game.mend_projector_booster_items.get(key, 0)),
		"reload_value": game.call("source_mend_projector_reload", block),
		"use_time_value": game.call("source_mend_projector_use_time", block),
	}

static func runtime_step_from_context(context: Dictionary) -> Dictionary:
	return runtime_step_state(
		context.get("current_state", {}),
		float(context.get("source_delta", 0.0)),
		int(context.get("booster_items", 0)),
		float(context.get("use_time_value", source_projector_defaults.MEND_USE_TIME_DEFAULT)),
		float(context.get("reload_value", source_projector_defaults.MEND_RELOAD_DEFAULT))
	)

static func simulate_projectors(game, delta: float) -> void:
	if game == null:
		return
	var source_delta := game_source_delta(game, delta)
	var charges: Dictionary = game.mend_projector_charges
	for key in game.mend_projector_heat.keys():
		var cell := _cell_from_key(key)
		var sprite = _sprite_at_cell(game, cell.x, cell.y)
		var block = _block_from_sprite(game, sprite)
		if block == null:
			continue
		if not bool(game.call("source_mend_projector_is_projector", block)):
			continue
		var runtime_context := runtime_step_context(game, key, block, source_delta)
		var runtime_step := runtime_step_from_context(runtime_context)
		game.mend_projector_smooth_efficiency[key] = float(runtime_step.get("smooth_efficiency", 0.0))
		game.mend_projector_heat[key] = float(runtime_step.get("heat", 0.0))
		game.mend_projector_phase_heat[key] = float(runtime_step.get("phase_heat", 0.0))
		charges[key] = float(runtime_step.get("charge", 0.0))
		game.mend_projector_booster_timers[key] = float(runtime_step.get("booster_timer", 0.0))
		game.mend_projector_booster_items[key] = int(runtime_step.get("booster_items", 0))
		if not bool(runtime_step.get("charge_ready", false)):
			continue
		var heal_application := heal_application_context(game, sprite, block, runtime_step)
		if not bool(heal_application.get("healed", false)):
			continue
		game.set("last_mend_projector_healed_amount", float(heal_application.get("healed_amount", 0.0)))
		game.set("last_mend_projector_healed_block_id", str(heal_application.get("block_id", "")))
		game.set("last_mend_projector_healed_cell", heal_application.get("cell", Vector2i.ZERO))
		game.set("last_mend_projector_target_health", float(heal_application.get("target_health", 0.0)))
		game.set("last_mend_projector_target_max_health", float(heal_application.get("target_max_health", 0.0)))

static func first_projector_state(game, key: String) -> Dictionary:
	var origin_cell := _cell_from_key(key)
	var state: Dictionary = game.call("mend_projector_state_at_cell", origin_cell.x, origin_cell.y)
	return state

static func step_projectors(game, seconds: float) -> Dictionary:
	simulate_projectors(game, seconds)
	var state: Dictionary = {}
	for key in game.mend_projector_heat.keys():
		state = first_projector_state(game, key)
		break
	var last_mend_projector_healed_cell := _vector2i_game_property(game, "last_mend_projector_healed_cell")
	state["last_mend_projector_healed_amount"] = float(game.get("last_mend_projector_healed_amount"))
	state["last_mend_projector_healed_block_id"] = str(game.get("last_mend_projector_healed_block_id"))
	state["last_mend_projector_healed_cell"] = {"x": last_mend_projector_healed_cell.x, "y": last_mend_projector_healed_cell.y}
	state["last_mend_projector_target_health"] = float(game.get("last_mend_projector_target_health"))
	state["last_mend_projector_target_max_health"] = float(game.get("last_mend_projector_target_max_health"))
	return state

static func _cell_from_key(key: String) -> Vector2i:
	var parts := key.split(",")
	if parts.size() != 2:
		return Vector2i.ZERO
	return Vector2i(int(parts[0]), int(parts[1]))

static func _state_dict(game: Object, property_name: String) -> Dictionary:
	if game == null:
		return {}
	var value = game.get(property_name)
	if value is Dictionary:
		return value
	return {}

static func _vector2i_game_property(game: Object, property_name: String, default_value := Vector2i.ZERO) -> Vector2i:
	if game == null:
		return default_value
	var value = game.get(property_name)
	if value is Vector2i:
		return value
	return default_value

static func _sprite_at_cell(game: Object, x: int, y: int):
	if game == null:
		return null
	return source_texture_runtime_state.game_sprite_at_cell(game, x, y)

static func _block_from_sprite(game: Object, sprite):
	if game == null:
		return null
	return source_texture_runtime_state.block_from_sprite(game, sprite)

static func _is_mend_projector(game: Object, block) -> bool:
	if game == null:
		return false
	return bool(game.call("source_mend_projector_is_projector", block))
