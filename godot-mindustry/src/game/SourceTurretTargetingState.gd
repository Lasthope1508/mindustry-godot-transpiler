extends RefCounted
class_name SourceTurretTargetingState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_TURRET_FIND_TARGET_METHOD := source_turret_source_text_state.SOURCE_TURRET_FIND_TARGET_METHOD
const SOURCE_TURRET_FIND_TARGET_RANGE_EXPR := source_turret_source_text_state.SOURCE_TURRET_FIND_TARGET_RANGE_EXPR
const SOURCE_TURRET_FIND_TARGET_ASSIGN_EXPR := source_turret_source_text_state.SOURCE_TURRET_FIND_TARGET_ASSIGN_EXPR
const SOURCE_UNITS_BEST_ENEMY_RANGE_GUARD := source_turret_source_text_state.SOURCE_UNITS_BEST_ENEMY_RANGE_GUARD

static func target_selection_state(origin: Vector2, range_pixels: float, candidates: Array) -> Dictionary:
	var selected_target: Variant = null
	var selected_index := -1
	var selected_distance := range_pixels
	for index in candidates.size():
		var candidate: Dictionary = candidates[index] if candidates[index] is Dictionary else {}
		var position: Vector2 = candidate.get("position", origin) as Vector2
		var distance := origin.distance_to(position)
		if distance <= selected_distance:
			selected_target = candidate.get("target", null)
			selected_index = index
			selected_distance = distance
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_TARGET_SELECTION_STATE,
		"find_target_method": SOURCE_TURRET_FIND_TARGET_METHOD,
		"find_target_range_expr": SOURCE_TURRET_FIND_TARGET_RANGE_EXPR,
		"find_target_assign_expr": SOURCE_TURRET_FIND_TARGET_ASSIGN_EXPR,
		"best_enemy_range_guard": SOURCE_UNITS_BEST_ENEMY_RANGE_GUARD,
		"origin": origin,
		"range_pixels": range_pixels,
		"candidate_count": candidates.size(),
		"selected_index": selected_index,
		"selected_distance": selected_distance,
		"target": selected_target,
		"has_target": selected_target != null,
	}

static func target_candidates_from_enemy_units(enemy_units: Array) -> Array:
	var target_candidates: Array = []
	for enemy in enemy_units:
		if not (enemy is Dictionary):
			continue
		var sprite = enemy.get("sprite")
		if not is_instance_valid(sprite):
			continue
		target_candidates.append({"target": enemy, "position": sprite.position})
	return target_candidates

static func enemy_target_state(origin: Vector2, range_pixels: float, enemy_units: Array) -> Dictionary:
	var target_candidates := target_candidates_from_enemy_units(enemy_units)
	return target_selection_state(origin, range_pixels, target_candidates)
