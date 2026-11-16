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

	# --- RepairTurret sense(range)/sense(rotation) (N2223):
	# BuildingComp.sense reads the two RepairTurret-specific
	# legs (BuildingComp.java:2093, `public double
	# sense(LAccess sensor){`): `case range -> this
	# instanceof Ranged r ? r.range() / tilesize : 0;`
	# (BuildingComp.java:2105) with range() returning
	# repairRadius (RepairTurret.java:231-232), and `case
	# rotation -> rotation;` (BuildingComp.java:2106) over
	# the rotation field (RepairTurret.java:156, `public float
	# strength, rotation = 90;`). The sensor spellings are
	# the LAccess enum names `range,` (LAccess.java:48) and
	# `rotation,` (LAccess.java:30); tilesize is 8
	# (Vars.java:135). Any other sensor falls through to the
	# switch default (BuildingComp.java:2123, `default ->
	# Float.NaN; //gets converted to null in logic`). There
	# is no driver tick line: sense is a logic read, not a
	# tick write.

	# Range at the class-default radius (50f / 8 = 6.25 blocks).
	var range_default: Dictionary = repair_turret_build_state.source_repair_turret_sense_state({}, "range", 50.0, 8.0)
	proof["sense_range_default_radius"] = bool(range_default.get("handled", false)) and is_equal_approx(float(range_default.get("sense_value", 0.0)), 6.25) and not bool(range_default.get("sense_value_is_nan", true))

	# Range at the repair-point radius (60f / 8 = 7.5 blocks).
	var range_point: Dictionary = repair_turret_build_state.source_repair_turret_sense_state({}, "range", 60.0, 8.0)
	proof["sense_range_repair_point"] = bool(range_point.get("handled", false)) and is_equal_approx(float(range_point.get("sense_value", 0.0)), 7.5) and not bool(range_point.get("sense_value_is_nan", true))

	# Range at the repair-turret radius (145f / 8 = 18.125 blocks).
	var range_turret: Dictionary = repair_turret_build_state.source_repair_turret_sense_state({}, "range", 145.0, 8.0)
	proof["sense_range_repair_turret"] = bool(range_turret.get("handled", false)) and is_equal_approx(float(range_turret.get("sense_value", 0.0)), 18.125) and not bool(range_turret.get("sense_value_is_nan", true))

	# Rotation with the frame key absent (folds to 90.0, the Java field init).
	var rotation_default: Dictionary = repair_turret_build_state.source_repair_turret_sense_state({}, "rotation", 50.0, 8.0)
	proof["sense_rotation_default"] = bool(rotation_default.get("handled", false)) and is_equal_approx(float(rotation_default.get("sense_value", 0.0)), 90.0) and not bool(rotation_default.get("sense_value_is_nan", true))

	# Rotation with a custom frame value.
	var rotation_custom: Dictionary = repair_turret_build_state.source_repair_turret_sense_state({"rotation": 45.0}, "rotation", 50.0, 8.0)
	proof["sense_rotation_custom"] = bool(rotation_custom.get("handled", false)) and is_equal_approx(float(rotation_custom.get("sense_value", 0.0)), 45.0) and not bool(rotation_custom.get("sense_value_is_nan", true))

	# An unhandled sensor falls through to super.sense (handled false, NaN).
	var unhandled: Dictionary = repair_turret_build_state.source_repair_turret_sense_state({}, "health", 50.0, 8.0)
	proof["sense_unhandled_sensor"] = not bool(unhandled.get("handled", true)) and unhandled.get("sense_value", 0.0) == null and bool(unhandled.get("sense_value_is_nan", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretSenseRangeRotationProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
