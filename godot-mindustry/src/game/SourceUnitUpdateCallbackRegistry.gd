extends RefCounted
class_name SourceUnitUpdateCallbackRegistry

const source_geometry_callback_registry := preload("res://src/game/SourceGeometryCallbackRegistry.gd")
const source_math_callback_registry := preload("res://src/game/SourceMathCallbackRegistry.gd")

const SOURCE_UNIT_UPDATE_SIN_SCALED_KEY := "sin_scaled"
const SOURCE_UNIT_UPDATE_SIN_SCALED_FALLBACK := "source_arc_mathf_sin_scaled"
const SOURCE_UNIT_UPDATE_COS_SCALED_KEY := "cos_scaled"
const SOURCE_UNIT_UPDATE_COS_SCALED_FALLBACK := "source_arc_mathf_cos_scaled"
const SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY := source_math_callback_registry.VEC2_LIMIT_KEY
const SOURCE_UNIT_UPDATE_VEC2_LIMIT_FALLBACK := source_math_callback_registry.ARC_VEC2_LIMIT_FALLBACK
const SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY := "vec2_angle"
const SOURCE_UNIT_UPDATE_VEC2_ANGLE_FALLBACK := "source_unit_vec2_angle"
const SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY := source_geometry_callback_registry.MOVE_TOWARD_ANGLE_KEY
const SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_FALLBACK := source_geometry_callback_registry.MOVE_TOWARD_ANGLE_FALLBACK
const SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY := source_geometry_callback_registry.ANGLES_ANGLE_KEY
const SOURCE_UNIT_UPDATE_ANGLES_ANGLE_FALLBACK := source_geometry_callback_registry.ANGLES_ANGLE_FALLBACK
