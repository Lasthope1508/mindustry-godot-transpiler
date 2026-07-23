extends RefCounted
class_name SourceTurretDefaults

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

func inaccuracy_default() -> float:
	return _float_default("inaccuracy")

func shoot_y_sentinel() -> String:
	return str(profile.get("source", {}).get("shoot_y_sentinel", ""))

func shoot_y_default(size: float, source_tilesize: float) -> float:
	return size * source_tilesize / 2.0

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

func max_ammo_default() -> int:
	return _int_default("max_ammo")

func ammo_per_shot_default() -> int:
	return _int_default("ammo_per_shot")

func consume_ammo_once_default() -> bool:
	return bool(defaults.get("consume_ammo_once", true))

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"defaults": defaults.duplicate(),
		"recoil_pow": recoil_pow(),
	}
