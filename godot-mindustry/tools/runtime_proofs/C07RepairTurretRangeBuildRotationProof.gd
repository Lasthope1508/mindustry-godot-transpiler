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

	# --- RepairTurret range() / buildRotation() (N2233):
	# RepairPointBuild.range() (RepairTurret.java:230-233,
	# `public float range(){` / `return repairRadius;`)
	# returns the per-def repairRadius: class default 50f
	# (`public float repairRadius = 50f;`,
	# RepairTurret.java:32), repair-point 60f
	# (`repairRadius = 60f;`, Blocks.java:6389),
	# repair-turret 145f (`repairRadius = 145f;`,
	# Blocks.java:6401) -- from the Ranged interface
	# (`public interface Ranged extends Posc, Teamc{` /
	# `float range();`, Ranged.java:5-6).
	# RepairPointBuild.buildRotation()
	# (RepairTurret.java:158-161, `public float
	# buildRotation(){` / `return rotation;`) returns the
	# rotation field (`public float strength, rotation = 90;`,
	# RepairTurret.java:156) -- from the RotBlock interface
	# (`public interface RotBlock{` / `float buildRotation();`,
	# RotBlock.java:4-5). The rotation is the live frame key
	# (stamped by the N2214 slerp + N2217 read/write),
	# absent folding to 90.0, the Java field init (the N2223
	# sense(rotation) precedent). There is no driver tick
	# line: both are pure reads (the N2223 sense / N2230
	# setStats / N2232 RepairTower range+warmup precedent).

	# Range at the repair-point radius (60f).
	var range_point: Dictionary = repair_turret_build_state.source_repair_turret_range_state(60.0)
	proof["range_catalog_repair_point_60"] = is_equal_approx(float(range_point.get("range", -1.0)), 60.0)

	# Range at the repair-turret radius (145f).
	var range_turret: Dictionary = repair_turret_build_state.source_repair_turret_range_state(145.0)
	proof["range_catalog_repair_turret_145"] = is_equal_approx(float(range_turret.get("range", -1.0)), 145.0)

	# Range at the class-default radius (50f).
	var range_default: Dictionary = repair_turret_build_state.source_repair_turret_range_state(50.0)
	proof["range_class_default_50"] = is_equal_approx(float(range_default.get("range", -1.0)), 50.0)

	# Build rotation reads the live frame rotation.
	var rotation_custom: Dictionary = repair_turret_build_state.source_repair_turret_build_rotation_state({"rotation": 45.0})
	proof["build_rotation_reads_frame"] = is_equal_approx(float(rotation_custom.get("build_rotation", -1.0)), 45.0)

	# Build rotation with the frame key absent (folds to 90.0, the Java field init).
	var rotation_default: Dictionary = repair_turret_build_state.source_repair_turret_build_rotation_state({})
	proof["build_rotation_absent_defaults_90"] = is_equal_approx(float(rotation_default.get("build_rotation", -1.0)), 90.0)

	# No driver tick line: the proof reads the state script
	# source and greps the driver body -- a runtime check,
	# not a hardcoded true.
	var source_text: String = FileAccess.get_file_as_string("res://src/game/SourceRepairTurretBuildState.gd")
	var driver_start: int = source_text.find("static func source_repair_turret_tick_buildings_state")
	var driver_end: int = source_text.find("\nstatic func ", driver_start + 1)
	var driver_body: String = source_text.substr(driver_start, driver_end - driver_start) if driver_end != -1 else source_text.substr(driver_start)
	proof["has_no_driver_tick_line"] = driver_start != -1 and not driver_body.contains("source_repair_turret_range_state") and not driver_body.contains("source_repair_turret_build_rotation_state")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretRangeBuildRotationProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
