extends RefCounted
class_name SourceUnitDefaults

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
