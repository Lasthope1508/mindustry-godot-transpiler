extends RefCounted
class_name SourceMathDefaults

const FLOAT_ROUNDING_ERROR := 0.000001
const FLOAT_MAX_VALUE := 3.4028234663852886e38
const PI2 := PI * 2.0
const ARC_PI := 3.1415927
const ARC_RAD_FULL := ARC_PI * 2.0
const FULL_CIRCLE_DEGREES := 360.0
const HALF_CIRCLE_DEGREES := FULL_CIRCLE_DEGREES / 2.0
const QUARTER_CIRCLE_DEGREES := FULL_CIRCLE_DEGREES / 4.0
const ARC_SIN_BITS := 14
const ARC_SIN_MASK := 16383
const ARC_SIN_COUNT := ARC_SIN_MASK + 1
const ARC_RAD_TO_INDEX := ARC_SIN_COUNT / ARC_RAD_FULL
const INT64_MIN := -9223372036854775807 - 1
const INT64_MAX := 9223372036854775807
const RAND_MURMUR_CONST1 := -49064778989728563
const RAND_MURMUR_CONST2 := -4265267296055464877
const UINT16_MASK := 65535
const RAND_NORM_FLOAT := 1.0 / 16777216.0
const RAND_MURMUR_CONST1_WORDS := [0x8ccd, 0xed55, 0xafd7, 0xff51]
const RAND_MURMUR_CONST2_WORDS := [0xec53, 0x1a85, 0xb9fe, 0xc4ce]
const LONG_MIN_WORDS := [0, 0, 0, 0x8000]

const LERP_DELTA_METHOD := "public static float lerpDelta(float fromValue, float toValue, float progress){\n        return lerp(fromValue, toValue, clamp(progress * Time.delta));\n    }"
const LERP_DELTA_SCALED_PROGRESS := "progress * Time.delta"
const LERP_DELTA_CLAMP_EXPR := "clamp(progress * Time.delta)"
const LERP_DELTA_LERP_EXPR := "lerp(fromValue, toValue, clamp(progress * Time.delta))"

var catalog: Variant
var profile: Dictionary = {}
var rand_profile: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_math_profile()

func load_math_profile() -> void:
	profile = catalog.document_root_data("math_profile", "math")
	if profile.is_empty():
		profile = {"source": {}}
		rand_profile = {}
		return
	rand_profile = profile.get("rand", {})

func _rand_int(key: String) -> int:
	return int(rand_profile.get(key, 0))

func _rand_words(key: String) -> Array:
	var values: Array = rand_profile.get(key, [])
	var words: Array = []
	for value in values:
		words.append(int(value))
	return words

func pi() -> float:
	return float(profile.get("pi", 0.0))

func float_rounding_error() -> float:
	return float(profile.get("float_rounding_error", 0.0))

func pi2() -> float:
	return pi() * 2.0

func sin_bits() -> int:
	return int(profile.get("sin_bits", 0))

func sin_mask() -> int:
	return ~(-1 << sin_bits())

func sin_count() -> int:
	return sin_mask() + 1

func rad_full() -> float:
	return pi() * 2.0

func rad_to_index() -> float:
	var full := rad_full()
	if full == 0.0:
		return 0.0
	return float(sin_count()) / full

func int64_min() -> int:
	return _rand_int("int64_min")

func int64_max() -> int:
	return _rand_int("int64_max")

func uint16_mask() -> int:
	return _rand_int("uint16_mask")

func rand_norm_float() -> float:
	return float(rand_profile.get("rand_norm_float", 0.0))

func murmur_const1() -> int:
	return _rand_int("murmur_const1")

func murmur_const2() -> int:
	return _rand_int("murmur_const2")

func murmur_const1_words() -> Array:
	return _rand_words("murmur_const1_words")

func murmur_const2_words() -> Array:
	return _rand_words("murmur_const2_words")

func long_min_words() -> Array:
	return _rand_words("long_min_words")

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"pi": pi(),
		"float_rounding_error": float_rounding_error(),
		"pi2": pi2(),
		"sin_bits": sin_bits(),
		"sin_mask": sin_mask(),
		"sin_count": sin_count(),
		"rad_full": rad_full(),
		"rad_to_index": rad_to_index(),
		"rand": {
			"loaded": not rand_profile.is_empty(),
			"int64_min": int64_min(),
			"int64_max": int64_max(),
			"uint16_mask": uint16_mask(),
			"rand_norm_float": rand_norm_float(),
			"murmur_const1": murmur_const1(),
			"murmur_const2": murmur_const2(),
			"murmur_const1_words": murmur_const1_words(),
			"murmur_const2_words": murmur_const2_words(),
			"long_min_words": long_min_words(),
		},
	}
