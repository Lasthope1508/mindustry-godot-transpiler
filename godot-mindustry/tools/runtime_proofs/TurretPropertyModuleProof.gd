extends Node

const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_turret_property_state := preload("res://src/game/SourceTurretPropertyState.gd")

func _ready() -> void:
	var turret_properties := {
		"reload": 20.0,
		"range": 160.0,
		"recoilTime": -1.0,
		"shootPattern": {"type": "ShootAlternate", "spread": 3.5},
	}
	var reload_state := source_turret_property_state.reload_seconds_state(turret_properties, source_turret_property_state.SOURCE_TURRET_RELOAD_KEY, 10.0, 60.0)
	var range_state := source_turret_property_state.range_state(turret_properties, source_turret_property_state.SOURCE_TURRET_RANGE_KEY, 80.0)
	var recoil_time_state := source_turret_property_state.recoil_time_state(turret_properties, source_turret_property_state.SOURCE_TURRET_RECOIL_TIME_KEY, -1.0, float(reload_state.get("reload_seconds", 0.0)), 60.0)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "TURRET_PROPERTY_MODULE_PROOF",
		"reload_seconds_matches": is_equal_approx(float(reload_state.get("reload_seconds", 0.0)), 20.0 / 60.0),
		"range_matches": is_equal_approx(float(range_state.get("range", 0.0)), 160.0),
		"recoil_time_fallback_matches": is_equal_approx(float(recoil_time_state.get("recoil_time", 0.0)), 20.0),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("TURRET_PROPERTY_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
