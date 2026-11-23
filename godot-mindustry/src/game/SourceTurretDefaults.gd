extends RefCounted
class_name SourceTurretDefaults

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_range_defaults := preload("res://src/game/SourceRangeDefaults.gd")
const LIQUID_AMMO_EPSILON := 0.001
const RELOAD_DEFAULT := 10.0
const TARGET_GROUND_DEFAULT := true
const TARGET_AIR_DEFAULT := true
const RANGE_DEFAULT := source_range_defaults.DEFAULT_BLOCK_RANGE
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


static func source_turret_default_constructor_state(turret_defaults: Dictionary) -> Dictionary:
	# Turret(String name) (Turret.java:157-171):
	# `public Turret(String name){`
	# `super(name);` -- already the exact_expr of N2185,
	# the Block super-ctor runs before these assignments;
	# cited as evidence only, never re-registered.
	# `liquidCapacity = 20f;` -- N2085/N2089/N2091-owned
	# and `rotate = true;` -- N2091/N2180/N2181-owned;
	# neither is re-registered here. The 10 ctor
	# assignments below are the only exprs this slice
	# owns: each writes a literal field default into the
	# Turret def, so the function writes the same 10
	# literals into turret_defaults (in/out) and returns
	# them. No Draw is ported: these are block-level field
	# defaults, frame data only (bool/int/float literals).
	# `outlinedIcon = 1;`
	# `drawLiquidLight = false;`
	# `sync = true;`
	# `quickRotate = false;`
	# `drawArrow = false;`
	# `ignoreLineRotation = true;`
	# `rotateDrawEditor = false;`
	# `visualRotationOffset = -90f;`
	# `regionRotated1 = 1;`
	# `regionRotated2 = 2;`
	var outlined_icon := 1
	var draw_liquid_light := false
	var sync := true
	var quick_rotate := false
	var draw_arrow := false
	var ignore_line_rotation := true
	var rotate_draw_editor := false
	var visual_rotation_offset := -90.0
	var region_rotated_1 := 1
	var region_rotated_2 := 2
	turret_defaults["outlined_icon"] = outlined_icon
	turret_defaults["draw_liquid_light"] = draw_liquid_light
	turret_defaults["sync"] = sync
	turret_defaults["quick_rotate"] = quick_rotate
	turret_defaults["draw_arrow"] = draw_arrow
	turret_defaults["ignore_line_rotation"] = ignore_line_rotation
	turret_defaults["rotate_draw_editor"] = rotate_draw_editor
	turret_defaults["visual_rotation_offset"] = visual_rotation_offset
	turret_defaults["region_rotated_1"] = region_rotated_1
	turret_defaults["region_rotated_2"] = region_rotated_2
	return {"outlined_icon": outlined_icon, "draw_liquid_light": draw_liquid_light, "sync": sync, "quick_rotate": quick_rotate, "draw_arrow": draw_arrow, "ignore_line_rotation": ignore_line_rotation, "rotate_draw_editor": rotate_draw_editor, "visual_rotation_offset": visual_rotation_offset, "region_rotated_1": region_rotated_1, "region_rotated_2": region_rotated_2, "turret_defaults": turret_defaults}
