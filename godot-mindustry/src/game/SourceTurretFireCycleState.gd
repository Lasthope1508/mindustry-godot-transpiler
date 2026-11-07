extends RefCounted
class_name SourceTurretFireCycleState

const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_TURRET_UPDATE_TILE_METHOD := source_turret_source_text_state.SOURCE_TURRET_UPDATE_TILE_METHOD
const SOURCE_TURRET_UPDATE_RELOAD_EXPR := source_turret_source_text_state.SOURCE_TURRET_UPDATE_RELOAD_EXPR
const SOURCE_TURRET_RELOAD_CAP_EXPR := source_turret_source_text_state.SOURCE_TURRET_RELOAD_CAP_EXPR
const SOURCE_TURRET_TURN_TO_TARGET_EXPR := source_turret_source_text_state.SOURCE_TURRET_TURN_TO_TARGET_EXPR
const SOURCE_TURRET_SHOOT_GATE_EXPR := source_turret_source_text_state.SOURCE_TURRET_SHOOT_GATE_EXPR
const SOURCE_TURRET_RELOAD_MOD_EXPR := source_turret_source_text_state.SOURCE_TURRET_RELOAD_MOD_EXPR
const SOURCE_TURRET_CUR_RECOIL_ASSIGNMENT := source_turret_source_text_state.SOURCE_TURRET_CUR_RECOIL_ASSIGNMENT

static func cooldown_state(cooldown_seconds: float, seconds: float) -> Dictionary:
	var cooldown_after_tick: float = max(0.0, cooldown_seconds - seconds)
	return {
		"update_reload_expr": SOURCE_TURRET_UPDATE_RELOAD_EXPR,
		"reload_cap_expr": SOURCE_TURRET_RELOAD_CAP_EXPR,
		"cooldown_after_tick": cooldown_after_tick,
		"ready": cooldown_after_tick <= 0.0,
	}

static func fire_cycle_state(current_rotation: float, target_rotation: float, seconds: float, rotate_speed: float, shoot_cone: float, cooldown_seconds: float, reload_seconds: float, tick_rate: float, move_angle_toward: Callable, angle_distance: Callable) -> Dictionary:
	var cooldown_tick: Dictionary = cooldown_state(cooldown_seconds, seconds)
	var cooldown_after_tick: float = float(cooldown_tick.get("cooldown_after_tick", 0.0))
	if cooldown_after_tick > 0.0:
		var cooling_angle_delta: float = float(angle_distance.call(current_rotation, target_rotation))
		return {
			"update_tile_method": SOURCE_TURRET_UPDATE_TILE_METHOD,
			"update_reload_expr": SOURCE_TURRET_UPDATE_RELOAD_EXPR,
			"turn_to_target_expr": SOURCE_TURRET_TURN_TO_TARGET_EXPR,
			"shoot_gate_expr": SOURCE_TURRET_SHOOT_GATE_EXPR,
			"reload_mod_expr": SOURCE_TURRET_RELOAD_MOD_EXPR,
			"cur_recoil_assignment": SOURCE_TURRET_CUR_RECOIL_ASSIGNMENT,
			"cooldown_after_tick": cooldown_after_tick,
			"cooldown_after_fire": cooldown_after_tick,
			"next_rotation": current_rotation,
			"angle_delta": cooling_angle_delta,
			"within_shoot_cone": false,
			"should_fire": false,
		}
	var max_rotation_delta: float = rotate_speed * seconds * tick_rate
	var next_rotation: float = float(move_angle_toward.call(current_rotation, target_rotation, max_rotation_delta))
	var angle_delta: float = float(angle_distance.call(next_rotation, target_rotation))
	var within_shoot_cone: bool = angle_delta < shoot_cone
	return {
		"update_tile_method": SOURCE_TURRET_UPDATE_TILE_METHOD,
		"update_reload_expr": SOURCE_TURRET_UPDATE_RELOAD_EXPR,
		"turn_to_target_expr": SOURCE_TURRET_TURN_TO_TARGET_EXPR,
		"shoot_gate_expr": SOURCE_TURRET_SHOOT_GATE_EXPR,
		"reload_mod_expr": SOURCE_TURRET_RELOAD_MOD_EXPR,
		"cur_recoil_assignment": SOURCE_TURRET_CUR_RECOIL_ASSIGNMENT,
		"cooldown_after_tick": cooldown_after_tick,
		"cooldown_after_fire": reload_seconds if within_shoot_cone else cooldown_after_tick,
		"next_rotation": next_rotation,
		"angle_delta": angle_delta,
		"within_shoot_cone": within_shoot_cone,
		"should_fire": within_shoot_cone,
	}
