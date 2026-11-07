extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_turret_runtime_property_stats_state := preload("res://src/game/SourceTurretRuntimePropertyStatsState.gd")
const source_turret_property_state := preload("res://src/game/SourceTurretPropertyState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var turret_properties := {
		"reload": 20.0,
		"range": 160.0,
		"recoilTime": -1.0,
		"shootPattern": {"type": "ShootAlternate", "spread": 3.5},
	}
	var reload_state := source_turret_property_state.reload_seconds_state(turret_properties, source_turret_property_state.SOURCE_TURRET_RELOAD_KEY, 10.0, 60.0)
	var range_state := source_turret_property_state.range_state(turret_properties, source_turret_property_state.SOURCE_TURRET_RANGE_KEY, 80.0)
	var recoil_time_state := source_turret_property_state.recoil_time_state(turret_properties, source_turret_property_state.SOURCE_TURRET_RECOIL_TIME_KEY, -1.0, float(reload_state.get("reload_seconds", 0.0)), 60.0)
	var selected_range_wrapper := game.selected_turret_range()
	var selected_range_module := source_turret_runtime_property_stats_state.selected_turret_float_stat(game, source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_RANGE_METHOD)
	var selected_pattern_wrapper := game.selected_turret_shoot_pattern()
	var selected_pattern_module := source_turret_runtime_property_stats_state.selected_turret_dict_stat(game, source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_SHOOT_PATTERN_METHOD)
	var selected_recoils_wrapper := game.selected_turret_recoils()
	var selected_recoils_module := source_turret_runtime_property_stats_state.selected_turret_int_stat(game, source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_RECOILS_METHOD)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "TURRET_PROPERTY_MODULE_PROOF",
		"reload_seconds_matches": is_equal_approx(float(reload_state.get("reload_seconds", 0.0)), 20.0 / 60.0),
		"range_matches": is_equal_approx(float(range_state.get("range", 0.0)), 160.0),
		"recoil_time_fallback_matches": is_equal_approx(float(recoil_time_state.get("recoil_time", 0.0)), 20.0),
		"selected_float_stat_matches": selected_range_wrapper == selected_range_module,
		"selected_dict_stat_matches": selected_pattern_wrapper == selected_pattern_module,
		"selected_int_stat_matches": selected_recoils_wrapper == selected_recoils_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["reload_seconds_matches"] and proof["range_matches"] and proof["recoil_time_fallback_matches"] and proof["selected_float_stat_matches"] and proof["selected_dict_stat_matches"] and proof["selected_int_stat_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TURRET_PROPERTY_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TurretPropertyModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

