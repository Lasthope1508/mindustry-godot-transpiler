extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- TurretBuild.sense() (N2293):
	# TurretBuild overrides sense (Turret.java:406-419,
	# `public double sense(LAccess sensor){` / `return
	# switch(sensor){` / `case ammo -> totalAmmo;` /
	# `case ammoCapacity -> maxAmmo;` / `case rotation
	# -> rotation;` / `case shootX -> World.conv(
	# targetPos.x);` / `case shootY -> World.conv(
	# targetPos.y);` / `case shooting -> isShooting ? 1
	# : 0;` / `case progress -> progress();` / `default
	# -> super.sense(sensor);`) over the base default
	# BuildingComp.sense (BuildingComp.java:2093), whose
	# default is `default -> Float.NaN; //gets converted
	# to null in logic` (BuildingComp.java:2123).
	# World.conv (World.java:165-166) divides by tilesize
	# (Vars.java:135, 8). The progress case calls the
	# N2254 pure function with explicit params. There is
	# no driver tick line: sense is a logic read, not a
	# tick write (the N2206 / N2208 / N2223 precedent).

	# Ammo reads totalAmmo (17).
	var ammo: Dictionary = turret_build_state.source_turret_sense_state({}, "ammo", 17, 30, 2, Vector2(80.0, 24.0), true, 5.0, 10.0, 8.0)
	proof["sense_ammo"] = bool(ammo.get("handled", false)) and is_equal_approx(float(ammo.get("sense_value", 0.0)), 17.0) and not bool(ammo.get("sense_value_is_nan", true))

	# Ammo capacity reads maxAmmo (30, Turret.java:47).
	var ammo_capacity: Dictionary = turret_build_state.source_turret_sense_state({}, "ammoCapacity", 17, 30, 2, Vector2(80.0, 24.0), true, 5.0, 10.0, 8.0)
	proof["sense_ammo_capacity"] = bool(ammo_capacity.get("handled", false)) and is_equal_approx(float(ammo_capacity.get("sense_value", 0.0)), 30.0) and not bool(ammo_capacity.get("sense_value_is_nan", true))

	# Rotation reads the Building int rotation (2).
	var rotation: Dictionary = turret_build_state.source_turret_sense_state({}, "rotation", 17, 30, 2, Vector2(80.0, 24.0), true, 5.0, 10.0, 8.0)
	proof["sense_rotation"] = bool(rotation.get("handled", false)) and is_equal_approx(float(rotation.get("sense_value", 0.0)), 2.0) and not bool(rotation.get("sense_value_is_nan", true))

	# ShootX reads targetPos.x / tilesize (80.0 / 8 = 10.0).
	var shoot_x: Dictionary = turret_build_state.source_turret_sense_state({}, "shootX", 17, 30, 2, Vector2(80.0, 24.0), true, 5.0, 10.0, 8.0)
	proof["sense_shoot_x"] = bool(shoot_x.get("handled", false)) and is_equal_approx(float(shoot_x.get("sense_value", 0.0)), 10.0) and not bool(shoot_x.get("sense_value_is_nan", true))

	# ShootY reads targetPos.y / tilesize (24.0 / 8 = 3.0).
	var shoot_y: Dictionary = turret_build_state.source_turret_sense_state({}, "shootY", 17, 30, 2, Vector2(80.0, 24.0), true, 5.0, 10.0, 8.0)
	proof["sense_shoot_y"] = bool(shoot_y.get("handled", false)) and is_equal_approx(float(shoot_y.get("sense_value", 0.0)), 3.0) and not bool(shoot_y.get("sense_value_is_nan", true))

	# Shooting reads 1 while isShooting.
	var shooting_true: Dictionary = turret_build_state.source_turret_sense_state({}, "shooting", 17, 30, 2, Vector2(80.0, 24.0), true, 5.0, 10.0, 8.0)
	proof["sense_shooting_true"] = bool(shooting_true.get("handled", false)) and is_equal_approx(float(shooting_true.get("sense_value", 0.0)), 1.0) and not bool(shooting_true.get("sense_value_is_nan", true))

	# Shooting reads 0 while not isShooting.
	var shooting_false: Dictionary = turret_build_state.source_turret_sense_state({}, "shooting", 17, 30, 2, Vector2(80.0, 24.0), false, 5.0, 10.0, 8.0)
	proof["sense_shooting_false"] = bool(shooting_false.get("handled", false)) and is_equal_approx(float(shooting_false.get("sense_value", 0.0)), 0.0) and not bool(shooting_false.get("sense_value_is_nan", true))

	# Progress reads the N2254 clamp (5.0 / 10.0 = 0.5).
	var progress: Dictionary = turret_build_state.source_turret_sense_state({}, "progress", 17, 30, 2, Vector2(80.0, 24.0), true, 5.0, 10.0, 8.0)
	proof["sense_progress"] = bool(progress.get("handled", false)) and is_equal_approx(float(progress.get("sense_value", 0.0)), 0.5) and not bool(progress.get("sense_value_is_nan", true))

	# An unhandled sensor falls through to super.sense (handled false, NaN).
	var unhandled: Dictionary = turret_build_state.source_turret_sense_state({}, "health", 17, 30, 2, Vector2(80.0, 24.0), true, 5.0, 10.0, 8.0)
	proof["sense_unhandled_sensor"] = not bool(unhandled.get("handled", true)) and unhandled.get("sense_value", 0.0) == null and bool(unhandled.get("sense_value_is_nan", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretSenseProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
