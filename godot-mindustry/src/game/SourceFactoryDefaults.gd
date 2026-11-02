extends RefCounted
class_name SourceFactoryDefaults

const DRILL_HARDNESS_MULTIPLIER := 50.0
const DRILL_DELAY_DRILL_TIME_DEFAULT := 300.0
const DRILL_DELAY_ITEM_HARDNESS_DEFAULT := 0
const DRILL_WARMUP_SPEED := 0.015
const DRILL_LIQUID_BOOST_INTENSITY := 1.6
const DRILL_UNBOOSTED_SPEED := 1.0
const BLOCK_DUMP_TIME := 5.0
const CONVEYOR_WORLD_SPEED_DEFAULT := 0.0
const CONVEYOR_TILE_SPEED_SCALE := 55.0
const HEAT_LERP_PROGRESS := 0.15

var catalog: Variant
var profile: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_factory_profile()

func load_factory_profile() -> void:
	profile = catalog.document_root_data("factory_profile", "factory")
	if profile.is_empty():
		profile = {"drill": {}, "block": {}, "conveyor": {}, "source": {}}

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
