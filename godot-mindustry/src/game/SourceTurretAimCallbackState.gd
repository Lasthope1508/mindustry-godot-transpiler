extends RefCounted
class_name SourceTurretAimCallbackState

const source_geometry_callback_registry := preload("res://src/game/SourceGeometryCallbackRegistry.gd")
const SOURCE_MOVE_ANGLE_TOWARD_CANONICAL_WRAPPER := "source_arc_angles_move_toward(current_degrees, target_degrees, max_delta)"
const SOURCE_TURRET_COMBAT_ANGLE_KEY := source_geometry_callback_registry.ANGLE_KEY
const SOURCE_TURRET_COMBAT_ANGLE_FALLBACK := source_geometry_callback_registry.ANGLE_FALLBACK
const SOURCE_TURRET_COMBAT_TRNS_VEC_KEY := source_geometry_callback_registry.TRNS_VEC_KEY
const SOURCE_TURRET_COMBAT_TRNS_VEC_FALLBACK := source_geometry_callback_registry.TRNS_VEC_FALLBACK

static func callback_registry() -> Dictionary:
	return {
		SOURCE_TURRET_COMBAT_ANGLE_KEY: SOURCE_TURRET_COMBAT_ANGLE_FALLBACK,
		SOURCE_TURRET_COMBAT_TRNS_VEC_KEY: SOURCE_TURRET_COMBAT_TRNS_VEC_FALLBACK,
	}
