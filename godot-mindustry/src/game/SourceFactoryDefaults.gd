extends RefCounted
class_name SourceFactoryDefaults

var catalog: Variant
var profile: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_factory_profile()

func load_factory_profile() -> void:
	var document: Dictionary = catalog.load_document("factory_profile")
	if not bool(document.get("loaded", false)):
		profile = {"drill": {}, "block": {}, "conveyor": {}, "source": {}}
		return
	var data: Dictionary = document.get("data", {})
	profile = data.get("factory", {})

func drill_hardness_multiplier() -> float:
	var drill: Dictionary = profile.get("drill", {})
	return float(drill.get("hardness_drill_multiplier", 0.0))

func drill_time_default() -> float:
	var drill: Dictionary = profile.get("drill", {})
	return float(drill.get("drill_time_default", 0.0))

func item_hardness_default() -> int:
	var drill: Dictionary = profile.get("drill", {})
	return int(drill.get("item_hardness_default", 0))

func drill_warmup_speed() -> float:
	var drill: Dictionary = profile.get("drill", {})
	return float(drill.get("warmup_speed", 0.0))

func block_dump_time() -> float:
	var block: Dictionary = profile.get("block", {})
	return float(block.get("dump_time", 0.0))

func block_item_capacity() -> int:
	var block: Dictionary = profile.get("block", {})
	return int(block.get("item_capacity", 0))

func conveyor_tile_speed_scale() -> float:
	var conveyor: Dictionary = profile.get("conveyor", {})
	return float(conveyor.get("tile_speed_scale", 0.0))

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"drill_hardness_multiplier": drill_hardness_multiplier(),
		"drill_time_default": drill_time_default(),
		"item_hardness_default": item_hardness_default(),
		"drill_warmup_speed": drill_warmup_speed(),
		"block_dump_time": block_dump_time(),
		"block_item_capacity": block_item_capacity(),
		"conveyor_tile_speed_scale": conveyor_tile_speed_scale(),
	}
