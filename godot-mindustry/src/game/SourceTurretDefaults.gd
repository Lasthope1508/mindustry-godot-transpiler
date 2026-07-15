extends RefCounted
class_name SourceTurretDefaults

var catalog: Variant
var profile: Dictionary = {}
var defaults: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_turret_profile()

func load_turret_profile() -> void:
	var document: Dictionary = catalog.load_document("turret_profile")
	if not bool(document.get("loaded", false)):
		profile = {"source": {}, "defaults": {}}
		defaults = {}
		return
	var data: Dictionary = document.get("data", {})
	profile = data.get("turret", {})
	defaults = profile.get("defaults", {})

func _float_default(key: String) -> float:
	return float(defaults.get(key, 0.0))

func _int_default(key: String) -> int:
	return int(defaults.get(key, 0))

func reload_default() -> float:
	return _float_default("reload")

func range_default() -> float:
	return _float_default("range")

func rotate_speed_default() -> float:
	return _float_default("rotate_speed")

func shoot_cone_default() -> float:
	return _float_default("shoot_cone")

func recoil_default() -> float:
	return _float_default("recoil")

func recoils_default() -> int:
	return _int_default("recoils")

func recoil_time_default() -> float:
	return _float_default("recoil_time")

func recoil_pow() -> float:
	return _float_default("recoil_pow")

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"defaults": defaults.duplicate(),
		"recoil_pow": recoil_pow(),
	}
