extends RefCounted
class_name SourceTurretDefaults

var catalog: Variant
var profile: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_turret_profile()

func load_turret_profile() -> void:
	var document: Dictionary = catalog.load_document("turret_profile")
	if not bool(document.get("loaded", false)):
		profile = {"source": {}}
		return
	var data: Dictionary = document.get("data", {})
	profile = data.get("turret", {})

func recoil_pow() -> float:
	return float(profile.get("recoil_pow", 0.0))

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"recoil_pow": recoil_pow(),
	}
