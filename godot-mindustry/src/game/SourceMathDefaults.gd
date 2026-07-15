extends RefCounted
class_name SourceMathDefaults

var catalog: Variant
var profile: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_math_profile()

func load_math_profile() -> void:
	var document: Dictionary = catalog.load_document("math_profile")
	if not bool(document.get("loaded", false)):
		profile = {"source": {}}
		return
	var data: Dictionary = document.get("data", {})
	profile = data.get("math", {})

func pi() -> float:
	return float(profile.get("pi", 0.0))

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

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"pi": pi(),
		"pi2": pi2(),
		"sin_bits": sin_bits(),
		"sin_mask": sin_mask(),
		"sin_count": sin_count(),
		"rad_full": rad_full(),
		"rad_to_index": rad_to_index(),
	}
