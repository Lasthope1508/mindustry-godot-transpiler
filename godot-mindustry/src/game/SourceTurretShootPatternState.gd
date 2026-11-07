extends RefCounted
class_name SourceTurretShootPatternState

const source_shoot_pattern_source_text_state := preload("res://src/game/SourceShootPatternSourceTextState.gd")

const SOURCE_SHOOT_ALTERNATE_INDEX_FORMULA := source_shoot_pattern_source_text_state.SOURCE_SHOOT_ALTERNATE_INDEX_FORMULA
const SOURCE_SHOOT_ALTERNATE_HANDLER_CALL := source_shoot_pattern_source_text_state.SOURCE_SHOOT_ALTERNATE_HANDLER_CALL
const SOURCE_SHOOT_ALTERNATE_BARREL_INCREMENTER := source_shoot_pattern_source_text_state.SOURCE_SHOOT_ALTERNATE_BARREL_INCREMENTER

static func shoot_x_offset_state(pattern: Dictionary, counter: int) -> Dictionary:
	if str(pattern.get("type", "")) != "ShootAlternate":
		return {
			"shoot_alternate_index_formula": SOURCE_SHOOT_ALTERNATE_INDEX_FORMULA,
			"shoot_alternate_handler_call": SOURCE_SHOOT_ALTERNATE_HANDLER_CALL,
			"shoot_alternate_barrel_incrementer": SOURCE_SHOOT_ALTERNATE_BARREL_INCREMENTER,
			"counter": counter,
			"next_counter": counter,
			"spread": 0.0,
			"index": 0,
			"offset": 0.0,
			"used": false,
		}
	var spread := float(pattern.get("spread", 0.0))
	var index := counter % 2
	return {
		"shoot_alternate_index_formula": SOURCE_SHOOT_ALTERNATE_INDEX_FORMULA,
		"shoot_alternate_handler_call": SOURCE_SHOOT_ALTERNATE_HANDLER_CALL,
		"shoot_alternate_barrel_incrementer": SOURCE_SHOOT_ALTERNATE_BARREL_INCREMENTER,
		"counter": counter,
		"next_counter": counter + 1,
		"spread": spread,
		"index": index,
		"offset": (float(index) - 0.5) * spread,
		"used": true,
	}

static func use_turret_shoot_x_offset(game, cell: Vector2i, turret) -> float:
	var pattern: Dictionary = game.call("source_turret_shoot_pattern", turret)
	var key := str(game.call("cell_key", cell))
	var turret_barrel_counters: Dictionary = game.get("turret_barrel_counters")
	var counter := int(turret_barrel_counters.get(key, 0))
	var shoot_offset_state := shoot_x_offset_state(pattern, counter)
	if bool(shoot_offset_state.get("used", false)):
		turret_barrel_counters[key] = counter + 1
	else:
		turret_barrel_counters[key] = counter
	return float(shoot_offset_state.get("offset", 0.0))
