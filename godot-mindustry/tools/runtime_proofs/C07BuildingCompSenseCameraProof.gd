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

	# --- BuildingComp.sense() `cameraX/cameraY/cameraWidth/cameraHeight` legs (N2518):
	# BuildingComp.sense() (`public double sense(LAccess
	# sensor){`, BuildingComp.java:2093-2126) answers
	# `case cameraX, cameraY, cameraWidth, cameraHeight ->
	# this instanceof ControlBlock c ? c.unit().sense(sensor)
	# : 0;` (:2122, the last leg of sense()), with the sensor
	# spellings the LAccess enum names (`cameraX,`
	# `cameraY,` `cameraWidth,` `cameraHeight,`,
	# LAccess.java:37-40). The four legs share ONE Java case
	# line and ONE delegation expression, so one pure
	# function ports all four with a `sensor` param. The
	# delegation target already exists in the port:
	# `SourceUnitSensorState.laccess_state` ports the
	# UnitComp.sense camera legs (`case cameraX ->
	# controller instanceof Player player ? World.conv
	# (player.con == null ? Core.camera.position.x :
	# player.con.viewX) : 0;`, UnitComp.java:283-286, and
	# cameraY/cameraWidth/cameraHeight analogously) -- 0
	# when the controller is not a Player, else `World.conv`
	# of the player view / core camera value. This slice
	# ports ONLY the BuildingComp gate (`instanceof
	# ControlBlock` + fallback 0 + pass-through of the unit
	# sense value). The three params are the live input a
	# future frame-stamp/wiring slice will supply (the
	# N2212/N2220 per-def-param precedent): `sensor` is one
	# of the four camera labels, `is_control_block` is
	# `this instanceof ControlBlock` (:2122, the gate of the
	# ternary) and `unit_sense_value` is
	# `c.unit().sense(sensor)`. The value is returned
	# exactly: 0.0 when not a control block, else
	# `unit_sense_value` (Java `sense()` returns double;
	# the float widens exactly), no clamping, no rounding,
	# no World.conv here (the conv already happened inside
	# the unit sense call). There is no driver tick line:
	# the leg is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517
	# precedent); the proof calls the pure function
	# directly with synthetic inputs.

	# Not a control block: `this instanceof ControlBlock`
	# fails, so the leg reads 0.0 (any sensor -- cameraY
	# with a non-zero unit value still reads 0.0).
	var not_control_result: Dictionary = turret_build_state.source_building_comp_sense_camera_state("cameraY", false, 9.5)
	proof["camera_not_control_num"] = bool(not_control_result.get("handled", false)) and float(not_control_result.get("sense_value", 1.0)) == 0.0 and not bool(not_control_result.get("sense_value_is_nan", true))

	# cameraX: a control block passes the unit sense value
	# through (12.5 reads back 12.5).
	var x_result: Dictionary = turret_build_state.source_building_comp_sense_camera_state("cameraX", true, 12.5)
	proof["camera_x_num"] = bool(x_result.get("handled", false)) and float(x_result.get("sense_value", 0.0)) == 12.5 and not bool(x_result.get("sense_value_is_nan", true))

	# cameraY: 7.25 reads back 7.25.
	var y_result: Dictionary = turret_build_state.source_building_comp_sense_camera_state("cameraY", true, 7.25)
	proof["camera_y_num"] = bool(y_result.get("handled", false)) and float(y_result.get("sense_value", 0.0)) == 7.25 and not bool(y_result.get("sense_value_is_nan", true))

	# cameraWidth: 40.0 reads back 40.0.
	var width_result: Dictionary = turret_build_state.source_building_comp_sense_camera_state("cameraWidth", true, 40.0)
	proof["camera_width_num"] = bool(width_result.get("handled", false)) and float(width_result.get("sense_value", 0.0)) == 40.0 and not bool(width_result.get("sense_value_is_nan", true))

	# cameraHeight: 22.5 reads back 22.5.
	var height_result: Dictionary = turret_build_state.source_building_comp_sense_camera_state("cameraHeight", true, 22.5)
	proof["camera_height_num"] = bool(height_result.get("handled", false)) and float(height_result.get("sense_value", 0.0)) == 22.5 and not bool(height_result.get("sense_value_is_nan", true))

	# Zero unit value: a control block whose unit senses 0.0
	# reads 0.0.
	var zero_result: Dictionary = turret_build_state.source_building_comp_sense_camera_state("cameraX", true, 0.0)
	proof["camera_zero_num"] = bool(zero_result.get("handled", false)) and float(zero_result.get("sense_value", 1.0)) == 0.0 and not bool(zero_result.get("sense_value_is_nan", true))

	# The leg always handles one of the four camera labels.
	proof["camera_handled_true"] = bool(x_result.get("handled", false))

	# The leg never yields NaN: `sense_value_is_nan` is
	# false always (the default `default -> Float.NaN;`
	# leg, BuildingComp.java:2123, never fires here).
	proof["camera_value_not_nan"] = not bool(x_result.get("sense_value_is_nan", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildingCompSenseCameraProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
