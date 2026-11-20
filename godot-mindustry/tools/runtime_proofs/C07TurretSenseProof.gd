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

	# --- Turret sense() LAccess dispatch (N2283):
	# `public double sense(LAccess sensor){ return
	# switch(sensor){ case ammo -> totalAmmo; case
	# ammoCapacity -> maxAmmo; case rotation -> rotation;
	# case shootX -> World.conv(targetPos.x); case shootY
	# -> World.conv(targetPos.y); case shooting ->
	# isShooting ? 1 : 0; case progress -> progress();
	# default -> super.sense(sensor); }; }`
	# (Turret.java:405-419). Every Turret case has a live
	# or catalog input: ammo reads totalAmmo (`public int
	# totalAmmo;`, Turret.java:283, live in the driver as
	# duo_total from the game dict -- passed as an explicit
	# int param because the frame carries no total_ammo
	# key); ammoCapacity reads maxAmmo (`public int maxAmmo
	# = 30;`, Turret.java:47, duo never overrides it --
	# explicit int param); rotation reads the live frame
	# key stamped every tick by the aim call (absent folds
	# to 90.0, `public float rotation = 90;`,
	# BaseTurret.java:114); shootX/shootY read
	# World.conv(targetPos) (`public Vec2 targetPos = new
	# Vec2();`, Turret.java:290, default (0,0); `public
	# static float conv(float coord){` / `return coord /
	# tilesize;`, World.java:165-166; `public static final
	# int tilesize = 8;`, Vars.java:135) over the live
	# frame target_pos dict (null counts as (0,0));
	# shooting reads the live frame is_shooting (N2277
	# tick, `public boolean wasShooting, isShooting;`,
	# Turret.java:292); progress reads the live frame
	# progress (N2282 tick, `public float progress(){` /
	# `return Mathf.clamp(reloadCounter / reload);`,
	# Turret.java:425-427). The default falls through to
	# super.sense (BuildingComp.java:2093-2126, ~25 cases)
	# -- its own later slice -- so the pure function
	# reports handled false + NaN. There is no driver tick
	# line: sense is a logic read, not a tick write (the
	# N2206/N2208/N2223 precedent); the proof calls the
	# pure function directly with synthetic frames, and the
	# logic-processor dispatch hook is its own later slice.

	# Ammo at a live total (7 -> 7.0).
	var ammo: Dictionary = turret_build_state.source_turret_sense_state({}, "ammo", 7, 30, 8.0)
	proof["sense_ammo_live_total"] = bool(ammo.get("handled", false)) and is_equal_approx(float(ammo.get("sense_value", 0.0)), 7.0) and not bool(ammo.get("sense_value_is_nan", true))

	# Ammo capacity at the duo default (30 -> 30.0).
	var capacity: Dictionary = turret_build_state.source_turret_sense_state({}, "ammoCapacity", 7, 30, 8.0)
	proof["sense_ammo_capacity_default"] = bool(capacity.get("handled", false)) and is_equal_approx(float(capacity.get("sense_value", 0.0)), 30.0) and not bool(capacity.get("sense_value_is_nan", true))

	# Rotation with the frame key absent (folds to 90.0, the Java field init).
	var rotation_default: Dictionary = turret_build_state.source_turret_sense_state({}, "rotation", 7, 30, 8.0)
	proof["sense_rotation_default"] = bool(rotation_default.get("handled", false)) and is_equal_approx(float(rotation_default.get("sense_value", 0.0)), 90.0) and not bool(rotation_default.get("sense_value_is_nan", true))

	# Rotation with a custom frame value.
	var rotation_custom: Dictionary = turret_build_state.source_turret_sense_state({"rotation": 135.0}, "rotation", 7, 30, 8.0)
	proof["sense_rotation_custom"] = bool(rotation_custom.get("handled", false)) and is_equal_approx(float(rotation_custom.get("sense_value", 0.0)), 135.0) and not bool(rotation_custom.get("sense_value_is_nan", true))

	# ShootX converted through World.conv (80 world px / 8 = 10 tiles).
	var shoot_x: Dictionary = turret_build_state.source_turret_sense_state({"target_pos": {"x": 80.0, "y": 24.0}}, "shootX", 7, 30, 8.0)
	proof["sense_shoot_x_converted"] = bool(shoot_x.get("handled", false)) and is_equal_approx(float(shoot_x.get("sense_value", 0.0)), 10.0) and not bool(shoot_x.get("sense_value_is_nan", true))

	# ShootY converted through World.conv (24 world px / 8 = 3 tiles).
	var shoot_y: Dictionary = turret_build_state.source_turret_sense_state({"target_pos": {"x": 80.0, "y": 24.0}}, "shootY", 7, 30, 8.0)
	proof["sense_shoot_y_converted"] = bool(shoot_y.get("handled", false)) and is_equal_approx(float(shoot_y.get("sense_value", 0.0)), 3.0) and not bool(shoot_y.get("sense_value_is_nan", true))

	# Shooting while the frame flag is true (1.0).
	var shooting_true: Dictionary = turret_build_state.source_turret_sense_state({"is_shooting": true}, "shooting", 7, 30, 8.0)
	proof["sense_shooting_true"] = bool(shooting_true.get("handled", false)) and is_equal_approx(float(shooting_true.get("sense_value", 0.0)), 1.0) and not bool(shooting_true.get("sense_value_is_nan", true))

	# Shooting while the frame flag is false (0.0).
	var shooting_false: Dictionary = turret_build_state.source_turret_sense_state({"is_shooting": false}, "shooting", 7, 30, 8.0)
	proof["sense_shooting_false"] = bool(shooting_false.get("handled", false)) and is_equal_approx(float(shooting_false.get("sense_value", 0.0)), 0.0) and not bool(shooting_false.get("sense_value_is_nan", true))

	# Progress read live from the frame (0.5 -> 0.5).
	var progress: Dictionary = turret_build_state.source_turret_sense_state({"progress": 0.5}, "progress", 7, 30, 8.0)
	proof["sense_progress_live"] = bool(progress.get("handled", false)) and is_equal_approx(float(progress.get("sense_value", 0.0)), 0.5) and not bool(progress.get("sense_value_is_nan", true))

	# An unhandled sensor falls through to super.sense (handled false, NaN).
	var unhandled: Dictionary = turret_build_state.source_turret_sense_state({}, "health", 7, 30, 8.0)
	proof["sense_unhandled_sensor"] = not bool(unhandled.get("handled", true)) and unhandled.get("sense_value", 0.0) == null and bool(unhandled.get("sense_value_is_nan", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretSenseProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
