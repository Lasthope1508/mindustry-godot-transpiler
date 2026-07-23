extends RefCounted
class_name SourceConstructionDefaults

var catalog: Variant
var profile: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_construction_profile()

func load_construction_profile() -> void:
	profile = catalog.document_root_data("construction_profile", "construction")
	if profile.is_empty():
		profile = {"source": {}}

func alpha_build_speed() -> float:
	return float(profile.get("alpha_build_speed", 0.0))

func default_block_build_time() -> float:
	return float(profile.get("default_block_build_time", 0.0))

func deconstruct_refund_multiplier() -> float:
	return float(profile.get("deconstruct_refund_multiplier", 0.0))

func deconstruct_threshold() -> float:
	return float(profile.get("deconstruct_threshold", 0.0))

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"alpha_build_speed": alpha_build_speed(),
		"default_block_build_time": default_block_build_time(),
		"deconstruct_refund_multiplier": deconstruct_refund_multiplier(),
		"deconstruct_threshold": deconstruct_threshold(),
	}
