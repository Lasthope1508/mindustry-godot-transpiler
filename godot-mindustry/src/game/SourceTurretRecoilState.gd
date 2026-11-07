extends RefCounted
class_name SourceTurretRecoilState

const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_TURRET_RECOIL_TIME_INIT_FALLBACK := source_turret_source_text_state.SOURCE_TURRET_RECOIL_TIME_INIT_FALLBACK
const SOURCE_TURRET_RECOIL_TIME_DECAY_USE := source_turret_source_text_state.SOURCE_TURRET_RECOIL_TIME_DECAY_USE
const SOURCE_TURRET_RECOIL_OFFSET_FORMULA := source_turret_source_text_state.SOURCE_TURRET_RECOIL_OFFSET_FORMULA
const SOURCE_RECOIL_POW := source_turret_defaults.RECOIL_POW
const SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_DEFAULT := source_turret_defaults.RECOIL_OFFSET_RECOIL_POW_DEFAULT

static func recoil_offset(recoil_rotation_degrees: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Vector2:
	var offset_state := source_math_state.source_angles_trns_vec(recoil_rotation_degrees, -pow(cur_recoil, recoil_pow) * recoil, 0.0)
	return Vector2(float(offset_state.get("x", 0.0)), float(offset_state.get("y", 0.0)))

static func recoil_step_state(cur_recoil: float, seconds: float, tick_rate: float, recoil_time: float) -> Dictionary:
	var cur_recoil_after := cur_recoil
	if recoil_time > 0.0:
		cur_recoil_after = max(0.0, cur_recoil - seconds * tick_rate / recoil_time)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_UPDATE_TURRET_RECOIL,
		"recoil_time_init_fallback": SOURCE_TURRET_RECOIL_TIME_INIT_FALLBACK,
		"recoil_time_decay_use": SOURCE_TURRET_RECOIL_TIME_DECAY_USE,
		"cur_recoil_before": cur_recoil,
		"seconds": seconds,
		"tick_rate": tick_rate,
		"recoil_time": recoil_time,
		"cur_recoil_after": cur_recoil_after,
	}

static func update_turret_recoil(game, cell: Vector2i, turret, delta: float, recoil_rotation_degrees: float) -> void:
	var key := str(game.call("cell_key", cell))
	var turret_recoils: Dictionary = game.get("turret_recoils")
	var cur_recoil := float(turret_recoils.get(key, 0.0))
	var recoil_state := recoil_step_state(
		cur_recoil,
		delta,
		source_time_defaults.TICK_RATE,
		float(game.call("source_turret_recoil_time", turret))
	)
	cur_recoil = float(recoil_state.get("cur_recoil_after", cur_recoil))
	turret_recoils[key] = cur_recoil
	game.set("last_turret_cur_recoil", cur_recoil)
	game.set("last_turret_recoil", float(game.call("source_turret_recoil", turret)))
	game.set("last_turret_recoils", int(game.call("source_turret_recoils", turret)))
	var computed_recoil_offset: Vector2 = game.call("source_turret_recoil_offset", turret, recoil_rotation_degrees, cur_recoil)
	game.set("last_turret_recoil_offset", computed_recoil_offset)
	apply_turret_recoil_offset(game, cell, turret, computed_recoil_offset)

static func apply_turret_recoil_offset(game, cell: Vector2i, turret, offset: Vector2) -> void:
	var key := str(game.call("cell_key", cell))
	var placed_block_origins: Dictionary = game.get("placed_block_origins")
	var sprite = placed_block_origins.get(key)
	if is_instance_valid(sprite):
		sprite.position = game.call("source_block_sprite_base_position", turret, cell) + offset
