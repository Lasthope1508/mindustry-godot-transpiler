extends RefCounted
class_name SourceUnitDefaults

var catalog: Variant
var profile: Dictionary = {}
var defaults: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_unit_profile()

func load_unit_profile() -> void:
	var document: Dictionary = catalog.load_document("unit_profile")
	if not bool(document.get("loaded", false)):
		profile = {"source": {}, "defaults": {}}
		defaults = {}
		return
	var data: Dictionary = document.get("data", {})
	profile = data.get("unit", {})
	defaults = profile.get("defaults", {})

func _float_default(key: String) -> float:
	return float(defaults.get(key, 0.0))

func speed_default() -> float:
	return _float_default("speed")

func hit_size_default() -> float:
	return _float_default("hit_size")

func health_default() -> float:
	return _float_default("health")

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"defaults": defaults.duplicate(),
	}
