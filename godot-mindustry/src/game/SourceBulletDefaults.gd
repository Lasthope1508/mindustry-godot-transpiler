extends RefCounted
class_name SourceBulletDefaults

var catalog: Variant
var profile: Dictionary = {}
var defaults: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_bullet_profile()

func load_bullet_profile() -> void:
	var document: Dictionary = catalog.load_document("bullet_profile")
	if not bool(document.get("loaded", false)):
		profile = {"source": {}, "defaults": {}}
		defaults = {}
		return
	var data: Dictionary = document.get("data", {})
	profile = data.get("bullet", {})
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
