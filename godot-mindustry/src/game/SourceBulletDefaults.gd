extends RefCounted
class_name SourceBulletDefaults

const TICKS_PER_SECOND := 60.0
const RANGE_CHANGE_DEFAULT := 0.0
const EXTRA_RANGE_MARGIN_DEFAULT := 0.0
const INACCURACY_DEFAULT := 0.0
const LIFETIME_DEFAULT := 40.0
const WORLD_SPEED_DEFAULT := 1.0
const HIT_SIZE_DEFAULT := 4.0
const DAMAGE_DEFAULT := 1.0
const AMMO_MULTIPLIER_DEFAULT := 2.0
const RELOAD_MULTIPLIER_DEFAULT := 1.0
const SCALE_WIDTH_DEFAULT := 5.0
const SCALE_HEIGHT_DEFAULT := 7.0
const BUILDING_DAMAGE_MULTIPLIER_DEFAULT := 1.0
const SHIELD_DAMAGE_MULTIPLIER_DEFAULT := 1.0
const DAMAGE_MULTIPLIER_DEFAULT := 1.0
const OWNER_UNIT_DAMAGE_MULTIPLIER_DEFAULT := 1.0
const RULES_UNIT_DAMAGE_DEFAULT := 1.0
const RULES_BLOCK_DAMAGE_DEFAULT := 1.0
const HEAL_SOUND_PITCH_RANGE := 0.1
const HIT_SOUND_PITCH_RANGE_DEFAULT := 0.1
const HEAL_PERCENT_DIVISOR := 100.0
const STATUS_DURATION_DEFAULT := TICKS_PER_SECOND * 8.0
const SUPPRESSION_DURATION_DEFAULT := TICKS_PER_SECOND * 8.0
const DESPAWN_UNIT_RADIUS_DEFAULT := 0.1
const PUDDLE_AMOUNT_DEFAULT := 5.0
const INCEND_SPREAD_DEFAULT := 8.0
const TRAIL_LENGTH_DEFAULT := -1
const TRAIL_WIDTH_DEFAULT := 2.0
const TRAIL_PARAM_DEFAULT := 2.0
const ROTATION_ZERO_MARGIN := 0.001
const INTERVAL_DELAY_DEFAULT := -1.0
const INTERVAL_BULLETS_DEFAULT := 1
const INTERVAL_SPREAD_DEFAULT := 0.0
const INTERVAL_ANGLE_DEFAULT := 0.0
const BULLET_INTERVAL_DEFAULT := 20.0
const TRAIL_SIN_MAG_DEFAULT := 0.0
const HOMING_POWER_DEFAULT := 0.0
const HOMING_POWER_EPSILON := 0.0001
const HOMING_DELAY_DEFAULT := -1.0
const AIM_UNSET_DEFAULT := -1.0
const HOMING_RANGE_DEFAULT := 50.0
const FOLLOW_AIM_SPEED_DEFAULT := 0.0
const WEAVE_MAG_DEFAULT := 0.0
const WEAVE_SCALE_DEFAULT := 1.0
const WEAVE_RANDOM_DEFAULT := true
const ROTATE_SPEED_DEFAULT := 0.0
const CIRCLE_SHOOTER_RADIUS_DEFAULT := 13.0
const CIRCLE_SHOOTER_RADIUS_SMOOTH_DEFAULT := 10.0
const CIRCLE_SHOOTER_ROTATE_SPEED_DEFAULT := 0.3
const TRAIL_MIN_VELOCITY_DEFAULT := 0.0
const TRAIL_CHANCE_DEFAULT := -0.0001
const TRAIL_SPREAD_DEFAULT := 0.0
const TRAIL_INTERVAL_DEFAULT := 0.0
const TRAIL_COLOR_DEFAULT := "Pal.missileYellowBack"
const TRAIL_EFFECT_DEFAULT := "Fx.missileTrail"
const INSTANT_DISAPPEAR_LIFETIME_MARGIN := 1.0
const SPAWN_BULLET_RANDOM_SPREAD_DEFAULT := 0.0

var catalog: Variant
var profile: Dictionary = {}
var defaults: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_bullet_profile()

func load_bullet_profile() -> void:
	profile = catalog.document_root_data("bullet_profile", "bullet")
	if profile.is_empty():
		profile = {"source": {}, "defaults": {}}
		defaults = {}
		return
	defaults = profile.get("defaults", {})

func _float_default(key: String) -> float:
	return float(defaults.get(key, 0.0))

func _bool_default(key: String) -> bool:
	return bool(defaults.get(key, false))

func _string_default(key: String) -> String:
	return str(defaults.get(key, ""))

func range_change_default() -> float:
	return _float_default("range_change")

func inaccuracy_default() -> float:
	return _float_default("inaccuracy")

func lifetime_default() -> float:
	return _float_default("lifetime")

func speed_default() -> float:
	return _float_default("speed")

func hit_size_default() -> float:
	return _float_default("hit_size")

func damage_default() -> float:
	return _float_default("damage")

func ammo_multiplier_default() -> float:
	return _float_default("ammo_multiplier")

func reload_multiplier_default() -> float:
	return _float_default("reload_multiplier")

func width_default() -> float:
	return _float_default("width")

func height_default() -> float:
	return _float_default("height")

func charge_effect_default() -> String:
	return _string_default("charge_effect")

func keep_velocity_default() -> bool:
	return _bool_default("keep_velocity")

func scale_keep_velocity_default() -> bool:
	return _bool_default("scale_keep_velocity")

func kill_shooter_default() -> bool:
	return _bool_default("kill_shooter")

func instant_disappear_default() -> bool:
	return _bool_default("instant_disappear")

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"defaults": defaults.duplicate(),
	}
