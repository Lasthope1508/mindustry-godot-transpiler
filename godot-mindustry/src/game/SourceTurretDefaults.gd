extends RefCounted
class_name SourceTurretDefaults

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const LIQUID_AMMO_EPSILON := 0.001
const RELOAD_DEFAULT := 10.0
const TARGET_GROUND_DEFAULT := true
const TARGET_AIR_DEFAULT := true
const RANGE_DEFAULT := 80.0
const LIMIT_RANGE_MARGIN_DEFAULT := 0.0
const PLACE_OVERLAP_MARGIN_DEFAULT := 56.0
const FOG_RADIUS_MULTIPLIER_DEFAULT := 1.0
const DISABLE_OVERLAP_CHECK_DEFAULT := false
const ACTIVATION_TIME_DEFAULT := 0.0
const SHOOT_X_DEFAULT := 0.0
const SHOOT_Y_DEFAULT := 0.0
const SHOOT_Y_IS_NEGATIVE_INFINITY_DEFAULT := true
const BULLET_ORIGIN_ROTATION_OFFSET_DEGREES := source_math_defaults.QUARTER_CIRCLE_DEGREES
const ROTATE_SPEED_DEFAULT := 5.0
const INACCURACY_DEFAULT := 0.0
const SHOOT_CONE_DEFAULT := 8.0
const RECOIL_DEFAULT := 1.0
const RECOILS_DEFAULT := -1
const RECOIL_TIME_DEFAULT := -1.0
const RECOIL_POW := 1.8
const RECOIL_OFFSET_RECOIL_POW_DEFAULT := 1.8
const MAX_AMMO_DEFAULT := 30
const AMMO_PER_SHOT_DEFAULT := 1
const CONSUME_AMMO_ONCE_DEFAULT := true
const COOLDOWN_TIME_DEFAULT := 20.0
const NEW_TARGET_INTERVAL_DEFAULT := -1.0
const TARGET_INTERVAL_DEFAULT := 20.0
const ELEVATION_DEFAULT := -1.0
const TRACKING_RANGE_DEFAULT := 0.0
const TRACTOR_BEAM_TARGET_AIR_DEFAULT := true
const TRACTOR_BEAM_TARGET_GROUND_DEFAULT := false
const LOOK_TARGET_EFFICIENCY_MIN := 0.02
const TRACTOR_BEAM_ROTATE_SPEED_DEFAULT := 10.0
const TRACTOR_BEAM_STRENGTH_LERP_PROGRESS := 0.1
const TRACTOR_BEAM_SHOOT_CONE_DEFAULT := 6.0
const TRACTOR_BEAM_STATUS_DURATION_DEFAULT := 300.0
const TRACTOR_BEAM_FORCE_DEFAULT := 0.3
const TRACTOR_BEAM_COOLANT_EFFECT_CHANCE := 0.06
const TRACTOR_BEAM_DRAW_ROTATION_OFFSET_DEGREES := source_math_defaults.QUARTER_CIRCLE_DEGREES
const RELOAD_WHILE_CHARGING_DEFAULT := true
const HEAT_REQUIREMENT_DEFAULT := -1.0
const MAX_HEAT_EFFICIENCY_DEFAULT := 3.0
const TURRET_PERCENT_SCALE := 100.0

var catalog: Variant
var profile: Dictionary = {}
var defaults: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_turret_profile()

func load_turret_profile() -> void:
	profile = catalog.document_root_data("turret_profile", "turret")
	if profile.is_empty():
		profile = {"source": {}, "defaults": {}}
		defaults = {}
		return
	defaults = profile.get("defaults", {})

func _float_default(key: String, fallback: float) -> float:
	return float(defaults.get(key, fallback))

func _int_default(key: String, fallback: int) -> int:
	return int(defaults.get(key, fallback))

func reload_default() -> float:
	return _float_default("reload", RELOAD_DEFAULT)

func range_default() -> float:
	return _float_default("range", RANGE_DEFAULT)

func rotate_speed_default() -> float:
	return _float_default("rotate_speed", ROTATE_SPEED_DEFAULT)

func inaccuracy_default() -> float:
	return _float_default("inaccuracy", INACCURACY_DEFAULT)

func shoot_y_sentinel() -> String:
	return str(profile.get("source", {}).get("shoot_y_sentinel", ""))

func shoot_y_default(size: float, source_tilesize: float) -> float:
	return size * source_tilesize / 2.0

func shoot_cone_default() -> float:
	return _float_default("shoot_cone", SHOOT_CONE_DEFAULT)

func recoil_default() -> float:
	return _float_default("recoil", RECOIL_DEFAULT)

func recoils_default() -> int:
	return _int_default("recoils", RECOILS_DEFAULT)

func recoil_time_default() -> float:
	return _float_default("recoil_time", RECOIL_TIME_DEFAULT)

func recoil_pow() -> float:
	return _float_default("recoil_pow", RECOIL_POW)

func max_ammo_default() -> int:
	return _int_default("max_ammo", MAX_AMMO_DEFAULT)

func ammo_per_shot_default() -> int:
	return _int_default("ammo_per_shot", AMMO_PER_SHOT_DEFAULT)

func consume_ammo_once_default() -> bool:
	return bool(defaults.get("consume_ammo_once", CONSUME_AMMO_ONCE_DEFAULT))

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"defaults": defaults.duplicate(),
		"recoil_pow": recoil_pow(),
	}
