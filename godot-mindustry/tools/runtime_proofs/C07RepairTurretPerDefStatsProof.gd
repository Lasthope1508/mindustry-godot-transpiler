extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- RepairTurret per-def stat rows (N2237):
	# repair-point repairSpeed 0.45f (`repairSpeed = 0.45f;`,
	# Blocks.java:6388), repairRadius 60f (`repairRadius = 60f;`,
	# Blocks.java:6389), beamWidth 0.73f (`beamWidth = 0.73f;`,
	# Blocks.java:6390), pulseRadius 5f (`pulseRadius = 5f;`,
	# Blocks.java:6392), length the 5f class default (`public
	# float length = 5f;`, RepairTurret.java:35 -- no override);
	# repair-turret length 6f (`length = 6f;`, Blocks.java:6399),
	# repairSpeed 3f (`repairSpeed = 3f;`, Blocks.java:6400),
	# repairRadius 145f (`repairRadius = 145f;`, Blocks.java:6401),
	# beamWidth 1.1f (`beamWidth = 1.1f;`, Blocks.java:6403),
	# pulseRadius 6.1f (`pulseRadius = 6.1f;`, Blocks.java:6404);
	# class defaults repairSpeed 0.3f (`public float repairSpeed
	# = 0.3f;`, RepairTurret.java:33), repairRadius 50f (`public
	# float repairRadius = 50f;`, RepairTurret.java:32), length
	# 5f (RepairTurret.java:35), beamWidth 1f (`public float
	# beamWidth = 1f;`, RepairTurret.java:36), pulseRadius 6f
	# (`public float pulseRadius = 6f;`, RepairTurret.java:37).
	# There is no driver tick line: a static read (the N2233
	# range / N2235 ambient volume precedent).

	# Stats at the repair-point def.
	var stats_point: Dictionary = repair_turret_build_state.source_repair_turret_per_def_stats_state("repair-point")
	proof["stats_repair_point"] = is_equal_approx(float(stats_point.get("repair_speed", -1.0)), 0.45) and is_equal_approx(float(stats_point.get("repair_radius", -1.0)), 60.0) and is_equal_approx(float(stats_point.get("length", -1.0)), 5.0) and is_equal_approx(float(stats_point.get("beam_width", -1.0)), 0.73) and is_equal_approx(float(stats_point.get("pulse_radius", -1.0)), 5.0)

	# Stats at the repair-turret def.
	var stats_turret: Dictionary = repair_turret_build_state.source_repair_turret_per_def_stats_state("repair-turret")
	proof["stats_repair_turret"] = is_equal_approx(float(stats_turret.get("repair_speed", -1.0)), 3.0) and is_equal_approx(float(stats_turret.get("repair_radius", -1.0)), 145.0) and is_equal_approx(float(stats_turret.get("length", -1.0)), 6.0) and is_equal_approx(float(stats_turret.get("beam_width", -1.0)), 1.1) and is_equal_approx(float(stats_turret.get("pulse_radius", -1.0)), 6.1)

	# Stats at an unknown def (class defaults).
	var stats_default: Dictionary = repair_turret_build_state.source_repair_turret_per_def_stats_state("unknown-def")
	proof["stats_class_default"] = is_equal_approx(float(stats_default.get("repair_speed", -1.0)), 0.3) and is_equal_approx(float(stats_default.get("repair_radius", -1.0)), 50.0) and is_equal_approx(float(stats_default.get("length", -1.0)), 5.0) and is_equal_approx(float(stats_default.get("beam_width", -1.0)), 1.0) and is_equal_approx(float(stats_default.get("pulse_radius", -1.0)), 6.0)

	# Stats at the empty id (class defaults).
	var stats_empty: Dictionary = repair_turret_build_state.source_repair_turret_per_def_stats_state("")
	proof["stats_empty_defaults"] = is_equal_approx(float(stats_empty.get("repair_speed", -1.0)), 0.3) and is_equal_approx(float(stats_empty.get("repair_radius", -1.0)), 50.0) and is_equal_approx(float(stats_empty.get("length", -1.0)), 5.0) and is_equal_approx(float(stats_empty.get("beam_width", -1.0)), 1.0) and is_equal_approx(float(stats_empty.get("pulse_radius", -1.0)), 6.0)

	# No driver tick line: the proof reads the state script
	# source and greps the driver body -- a runtime check,
	# not a hardcoded true.
	var source_text: String = FileAccess.get_file_as_string("res://src/game/SourceRepairTurretBuildState.gd")
	var driver_start: int = source_text.find("static func source_repair_turret_tick_buildings_state")
	var driver_end: int = source_text.find("\nstatic func ", driver_start + 1)
	var driver_body: String = source_text.substr(driver_start, driver_end - driver_start) if driver_end != -1 else source_text.substr(driver_start)
	proof["has_no_driver_tick_line"] = driver_start != -1 and not driver_body.contains("source_repair_turret_per_def_stats_state")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretPerDefStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
