extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var reconstructor_block = blocks_by_id["additive-reconstructor"]

	# --- One tick of ReconstructorBuild.updateTile()
	# (Reconstructor.java:317-356), driven directly on a bound
	# additive-reconstructor frame (dagger -> mace, constructTime
	# 600, N2124, Blocks.java). Deterministic: no tick-driver
	# timing, the pure function takes construct_time, has_upgrade,
	# upgrade_unit, payload_in_position, edelta, unit_build_speed
	# and source_delta as inputs.
	var construct_time := 600.0

	# --- progress advance (Reconstructor.java:330):
	# `progress += edelta() * state.rules.unitBuildSpeed(team);`
	# efficiency 1.0, has_upgrade true, payload in position,
	# edelta 1.0, unit build speed 1.0: progress 0 -> 1.0,
	# constructing true.
	var advancing: Dictionary = unit_factory_build_state.source_reconstructor_production_tick_state({"efficiency": 1.0, "payload": {"unit": "dagger"}, "progress": 0.0, "time": 0.0, "speed_scl": 1.0}, construct_time, true, "mace", true, 1.0, 1.0, 1.0)
	proof["reconstructor_progress_advances"] = is_equal_approx(float(advancing.get("progress", -1.0)), 1.0) and bool(advancing.get("constructing", false)) == true and bool(advancing.get("completed", true)) == false

	# --- time advance (Reconstructor.java:355-356):
	# `time += edelta() * speedScl * state.rules.unitBuildSpeed(team);`
	# speed_scl 1.0, edelta 1.0: speed_scl stays 1.0, time 0 -> 1.0
	# (time uses the new speedScl).
	proof["reconstructor_time_advances"] = is_equal_approx(float(advancing.get("time", -1.0)), 1.0) and is_equal_approx(float(advancing.get("speed_scl", -1.0)), 1.0)

	# --- no payload, no progress (Reconstructor.java:319, 321,
	# 354-356): payload null keeps progress at 0, constructing
	# false, and speed_scl lerps toward 0 (1.0 -> 0.95 at
	# source_delta 1.0); time still advances with the lerped
	# speedScl (0 -> 0.95).
	var no_payload: Dictionary = unit_factory_build_state.source_reconstructor_production_tick_state({"efficiency": 1.0, "payload": null, "progress": 0.0, "time": 0.0, "speed_scl": 1.0}, construct_time, false, "", true, 1.0, 1.0, 1.0)
	proof["reconstructor_no_payload_no_progress"] = is_equal_approx(float(no_payload.get("progress", -1.0)), 0.0) and bool(no_payload.get("constructing", true)) == false and is_equal_approx(float(no_payload.get("speed_scl", -1.0)), 0.95) and is_equal_approx(float(no_payload.get("time", -1.0)), 0.95) and bool(no_payload.get("completed", true)) == false

	# --- not in position, no progress (PayloadBlock.java:186-196,
	# moveInPayload() false): payload present and upgradeable but
	# the payload has not arrived, so progress stays 0, valid
	# false, speed_scl 1.0 -> 0.95, nothing completes.
	var not_in_position: Dictionary = unit_factory_build_state.source_reconstructor_production_tick_state({"efficiency": 1.0, "payload": {"unit": "dagger"}, "progress": 0.0, "time": 0.0, "speed_scl": 1.0}, construct_time, true, "mace", false, 1.0, 1.0, 1.0)
	proof["reconstructor_not_in_position_no_progress"] = is_equal_approx(float(not_in_position.get("progress", -1.0)), 0.0) and is_equal_approx(float(not_in_position.get("speed_scl", -1.0)), 0.95) and bool(not_in_position.get("completed", true)) == false

	# --- completion (Reconstructor.java:331-348): progress 599.5 +
	# edelta 1.0 = 600.5 >= constructTime 600 -> completed, the
	# payload unit is the mace upgrade, progress fmod 1.0 -> 0.5,
	# the consume call fired and the UnitCreateEvent recorded.
	var completing: Dictionary = unit_factory_build_state.source_reconstructor_production_tick_state({"efficiency": 1.0, "payload": {"unit": "dagger"}, "progress": 599.5, "time": 0.0, "speed_scl": 1.0}, construct_time, true, "mace", true, 1.0, 1.0, 1.0)
	var completed_payload: Variant = completing.get("payload", null)
	proof["reconstructor_completes_upgrade"] = bool(completing.get("completed", false)) == true and is_equal_approx(float(completing.get("progress", -1.0)), 0.5) and completed_payload is Dictionary and str(completed_payload.get("unit", "")) == "mace" and bool(completing.get("consumed", false)) == true and bool(completing.get("unit_created_event", false)) == true

	# --- no upgrade, move out (Reconstructor.java:322-323):
	# has_upgrade false records moved_out, progress unchanged,
	# constructing false, nothing completes.
	var no_upgrade: Dictionary = unit_factory_build_state.source_reconstructor_production_tick_state({"efficiency": 1.0, "payload": {"unit": "dagger"}, "progress": 5.0, "time": 0.0, "speed_scl": 1.0}, construct_time, false, "", true, 1.0, 1.0, 1.0)
	proof["reconstructor_no_upgrade_moves_out"] = bool(no_upgrade.get("moved_out", false)) == true and is_equal_approx(float(no_upgrade.get("progress", -1.0)), 5.0) and bool(no_upgrade.get("constructing", true)) == false and bool(no_upgrade.get("completed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06ReconstructorProductionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
