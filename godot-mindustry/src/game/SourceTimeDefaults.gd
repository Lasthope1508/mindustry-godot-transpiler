extends RefCounted
class_name SourceTimeDefaults

const TICK_RATE := 60.0
const SOURCE_TIME_TO_SECONDS_FIELD := "public static final float toSeconds = 60f"

var catalog: Variant
var profile: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_time_profile()

func load_time_profile() -> void:
	profile = catalog.document_root_data("time_profile", "time")
	if profile.is_empty():
		profile = {"time": {}, "source": {}}

func tick_rate() -> float:
	return float(profile.get("tick_rate", TICK_RATE))

func runtime_summary() -> Dictionary:
	return {
		"loaded": not profile.is_empty(),
		"tick_rate": tick_rate(),
	}
