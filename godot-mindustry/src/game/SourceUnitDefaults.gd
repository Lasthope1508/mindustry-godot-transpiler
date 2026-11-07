extends RefCounted
class_name SourceUnitDefaults

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")

const SPEED_DEFAULT := 0.0
const HIT_SIZE_DEFAULT := 6.0
const HEALTH_DEFAULT := 200.0
const PHYSIC_SIZE_MULTIPLIER := 0.7

const PAYLOAD_OVERLAY_DURATION := 40.0
const PAYLOAD_OVERLAY_ALPHA := 0.8
const PAYLOAD_WARNING_SIZE := 8.0

const GROUNDED_EPSILON := 0.001
const FLYING_ELEVATION_MIN := 0.09
const WOBBLE_SIN_SCL := 25.0
const WOBBLE_MAG := 0.05
const BOOSTING_TARGET_ELEVATION := 1.0
const BOOSTING_BASE_ELEVATION := 0.0
const DROWN_HIT_SIZE_DIVISOR := 8.0
const FOG_SMALL_HIT_SIZE_MAX := 16.0
const FOG_LARGE_TRANSLATION_DIVISOR := 2.0
const DROWN_UPDATE_EFFECT_CHANCE := 0.05
const DROWN_KILL_THRESHOLD := 0.999
const DROWN_DRY_DECAY_DIVISOR := 50.0
const HEAL_AMOUNT_POSITIVE_THRESHOLD := 0.0
const HEAL_TIME_RESET_THRESHOLD := -1.0
const HEAL_TIME_RESET_VALUE := 1.0
const HEAL_TIME_DECAY_DIVISOR := 20.0
const WALK_EFFECT_THRESHOLD_BASE := 7.0
const WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR := 8.0
const FLYING_TRANSITION_LAND_EFFECT_LIQUID_ROTATION := 1.0
const FLYING_TRANSITION_LAND_EFFECT_SOLID_ROTATION := 0.5
const FALL_ENGINE_OFFSET_DIVISOR := 2.0
const FALL_ENGINE_ROTATION_OFFSET := source_math_defaults.HALF_CIRCLE_DEGREES
const FALL_ENGINE_TRAIL_CHANCE := 0.2
const TRAIL_SCALE_DEFAULT := 1.0
const DRAG_FLOOR_FACTOR_DEFAULT := 1.0
const FALLING_DRAG_MIN := 0.01
const FALL_SMOKE_CHANCE := 0.1
const SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET := 1.0
const SPAWN_KNOCKBACK_STRENGTH_OFFSET := 0.1
const SPAWN_KNOCKBACK_SCALE := 0.45
const SPAWN_KNOCKBACK_HIT_SIZE_DIVISOR := 2.0
const SOLID_TILE_BOOST_ELEVATION := 1.0
const LANDED_SHAKE_THRESHOLD := 0.0

const DESTROY_INITIAL_EXPLOSIVENESS_BASE := 2.0
const DESTROY_INITIAL_EXPLOSIVENESS_MULTIPLIER := 1.53
const DESTROY_INITIAL_FLAMMABILITY_DIVISOR := 1.9
const DESTROY_INITIAL_POWER_EXPONENT := 1.11
const DESTROY_INITIAL_POWER_MULTIPLIER := 160.0
const DESTROY_EXPLOSION_LEG_LENGTH_DIVISOR := 1.7
const DESTROY_EXPLOSION_RADIUS_DIVISOR := 2.0
const DESTROY_EXPLOSION_CORE_ROTATION_DIVISOR := 8.0
const DESTROY_VISUAL_DEATH_SHAKE_BASE := 3.0
const DESTROY_VISUAL_DEATH_SHAKE_HIT_SIZE_DIVISOR := 3.0
const DESTROY_VISUAL_SCORCH_HIT_SIZE_DIVISOR := 5.0
const DESTROY_SOUND_PITCH := 1.0
const DESTROY_SUICIDE_BOMB_EXPLOSIVENESS_THRESHOLD := 7.0
const DESTROY_SHOOT_ON_DEATH_TOTAL_SHOTS_THRESHOLD := 0
const DESTROY_SHOOT_ON_DEATH_RELOAD_RESET := 0.0
const CRASH_DAMAGE_HIT_SIZE_EXPONENT := 0.75
const CRASH_DAMAGE_MULTIPLIER := 2.5
const CRASH_DAMAGE_RADIUS_EXPONENT := 0.94
const CRASH_DAMAGE_RADIUS_MULTIPLIER := 1.25
const WRECK_DECAL_RANGE_DIVISOR := 4.0
const WRECK_DECAL_ROTATION_OFFSET := source_math_defaults.QUARTER_CIRCLE_DEGREES
const KILLED_HEALTH_CLAMP_MAX := 0.0
const KILLED_WRECK_SOUND_PITCH := 1.0

var catalog: Variant
var profile: Dictionary = {}
var defaults: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_unit_profile()

func load_unit_profile() -> void:
	profile = catalog.document_root_data("unit_profile", "unit")
	if profile.is_empty():
		profile = {"source": {}, "defaults": {}}
		defaults = {}
		return
	defaults = profile.get("defaults", {})

func _float_default(key: String) -> float:
	return float(defaults.get(key, 0.0))

func _int_default(key: String) -> int:
	return int(defaults.get(key, 0))

func speed_default() -> float:
	return _float_default("speed")

func hit_size_default() -> float:
	return _float_default("hit_size")

func health_default() -> float:
	return _float_default("health")

func destroy_shoot_on_death_total_shots_threshold() -> int:
	return _int_default("destroy_shoot_on_death_total_shots_threshold")

func destroy_shoot_on_death_reload_reset() -> float:
	return _float_default("destroy_shoot_on_death_reload_reset")

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"defaults": defaults.duplicate(),
	}
