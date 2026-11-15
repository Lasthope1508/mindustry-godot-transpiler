extends Node

const main_scene := preload("res://scenes/Main.tscn")
const build_turret_build_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
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

	# --- Pure advance (N2243): BuildTurretBuild.updateTile()
	# (BuildTurret.java:121-140): rotation = unit.rotation()
	# (:126), lookAt(angleTo(unit.buildPlan())) while actively
	# building (:128-130), checkSuppression() zeroes efficiency
	# + potentialEfficiency (:132-134), buildSpeedMultiplier /
	# speedMultiplier = potentialEfficiency * timeScale
	# (:136-137), warmup = lerpDelta(warmup, activelyBuilding ?
	# efficiency : 0, 0.1) (:139). source_delta is Time.delta
	# in ticks (1.0 = one tick). The port has no Unit object,
	# so the unit state arrives as explicit frame inputs
	# (unit_rotation, default 90.0, the init block;
	# actively_building, default false; build_plan_angle,
	# default 0.0) and suppression as the heal_suppressed
	# mirror (default false). Java order: rotation is read
	# BEFORE the lookAt, so this tick's rotation is the
	# pre-lookAt unit rotation; the warmup reads efficiency
	# AFTER the suppression zeroing.
	var follow: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"unit_rotation": 135.0}, 1.0, 1.0)
	var follow_default: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({}, 1.0, 1.0)
	proof["rotation_follows_unit"] = is_equal_approx(float(follow.get("rotation", -1.0)), 135.0) and is_equal_approx(float(follow_default.get("rotation", -1.0)), 90.0)

	var look_building: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"unit_rotation": 90.0, "actively_building": true, "build_plan_angle": 45.0}, 1.0, 1.0)
	var look_idle: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"unit_rotation": 135.0, "actively_building": false, "build_plan_angle": 45.0}, 1.0, 1.0)
	var look_no_plan: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"unit_rotation": 90.0, "actively_building": true}, 1.0, 1.0)
	proof["look_at_when_building"] = is_equal_approx(float(look_building.get("unit_look_angle", -1.0)), 45.0) and is_equal_approx(float(look_building.get("rotation", -1.0)), 90.0) and is_equal_approx(float(look_idle.get("unit_look_angle", -1.0)), 135.0) and is_equal_approx(float(look_no_plan.get("unit_look_angle", -1.0)), 0.0)

	var suppressed: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"heal_suppressed": true, "efficiency": 1.0, "potential_efficiency": 1.0, "actively_building": true, "warmup": 1.0}, 1.0, 1.0)
	var unsuppressed: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"heal_suppressed": false, "efficiency": 1.0, "potential_efficiency": 1.0, "actively_building": true, "warmup": 1.0}, 1.0, 1.0)
	proof["suppression_zeroes_efficiency"] = is_equal_approx(float(suppressed.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(suppressed.get("potential_efficiency", -1.0)), 0.0) and is_equal_approx(float(suppressed.get("build_speed_multiplier", -1.0)), 0.0) and is_equal_approx(float(suppressed.get("speed_multiplier", -1.0)), 0.0) and is_equal_approx(float(suppressed.get("warmup", -1.0)), 0.9) and is_equal_approx(float(unsuppressed.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(unsuppressed.get("potential_efficiency", -1.0)), 1.0) and is_equal_approx(float(unsuppressed.get("warmup", -1.0)), 1.0)

	var mult_half_scaled: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"efficiency": 0.5, "potential_efficiency": 0.5}, 1.0, 2.0)
	var mult_half: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"efficiency": 0.5, "potential_efficiency": 0.5}, 1.0, 1.0)
	var mult_zero: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"efficiency": 0.0, "potential_efficiency": 0.0}, 1.0, 1.0)
	var mult_default_potential: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"efficiency": 0.5}, 1.0, 1.0)
	proof["multipliers_scale_with_potential"] = is_equal_approx(float(mult_half_scaled.get("build_speed_multiplier", -1.0)), 1.0) and is_equal_approx(float(mult_half_scaled.get("speed_multiplier", -1.0)), 1.0) and is_equal_approx(float(mult_half.get("build_speed_multiplier", -1.0)), 0.5) and is_equal_approx(float(mult_half.get("speed_multiplier", -1.0)), 0.5) and is_equal_approx(float(mult_zero.get("build_speed_multiplier", -1.0)), 0.0) and is_equal_approx(float(mult_zero.get("speed_multiplier", -1.0)), 0.0) and is_equal_approx(float(mult_default_potential.get("build_speed_multiplier", -1.0)), 0.5) and is_equal_approx(float(mult_default_potential.get("speed_multiplier", -1.0)), 0.5)

	var warmup_cold: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"actively_building": true, "efficiency": 1.0, "warmup": 0.0}, 1.0, 1.0)
	var warmup_half: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"actively_building": true, "efficiency": 1.0, "warmup": 0.5}, 1.0, 1.0)
	var warmup_long_delta: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"actively_building": true, "efficiency": 1.0, "warmup": 0.0}, 3.0, 1.0)
	proof["warmup_lerps_when_building"] = is_equal_approx(float(warmup_cold.get("warmup", -1.0)), 0.1) and is_equal_approx(float(warmup_half.get("warmup", -1.0)), 0.55) and is_equal_approx(float(warmup_long_delta.get("warmup", -1.0)), 0.3)

	var decay_hot: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"actively_building": false, "efficiency": 1.0, "warmup": 1.0}, 1.0, 1.0)
	var decay_half: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"actively_building": false, "efficiency": 1.0, "warmup": 0.5}, 1.0, 1.0)
	var decay_cold: Dictionary = build_turret_build_state.source_build_turret_update_tile_advance_state({"actively_building": false, "efficiency": 1.0, "warmup": 0.0}, 1.0, 1.0)
	proof["warmup_decays_when_idle"] = is_equal_approx(float(decay_hot.get("warmup", -1.0)), 0.9) and is_equal_approx(float(decay_half.get("warmup", -1.0)), 0.45) and is_equal_approx(float(decay_cold.get("warmup", -1.0)), 0.0)

	# --- Live tick: a build-tower placed live; the tick driver
	# is called directly (as the N2184/N2215 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The frame inputs are seeded
	# (unit_rotation 135.0, actively_building true,
	# build_plan_angle 45.0, warmup 0.0) because the live
	# unit-state fill waits for its own slice, and the plans
	# fixture holds the N2215 gate open (the c36f1cb7
	# precedent: the gate closes on an empty frame). One
	# 1/60s tick is one source tick: efficiency folds the
	# power min 0.5, rotation follows the unit 135.0, the
	# lookAt angle is 45.0, both multipliers are 0.5, and
	# warmup lerps 0 -> 0.5 * 0.1 = 0.05. The live tick is
	# folded into rotation_follows_unit (the scope's 6 keys
	# carry no separate live-tick key).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var build_turret_cell := Vector2i(30, 21)
	var build_turret := Sprite2D.new()
	game.add_child(build_turret)
	game.call("record_placed_block", build_turret, blocks_by_id["build-tower"], build_turret_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status, plans
	# and the unit-state inputs on it).
	build_turret_build_state.source_build_turret_bind_frame_state(build_turret, blocks_by_id["build-tower"])
	var build_turret_frame: Dictionary = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})

	build_turret_frame["plans"] = [{"block": "conveyor", "x": 0, "y": 0}]
	build_turret_frame["power_status"] = 0.5
	build_turret_frame["unit_rotation"] = 135.0
	build_turret_frame["actively_building"] = true
	build_turret_frame["build_plan_angle"] = 45.0
	build_turret_frame["warmup"] = 0.0
	build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)
	build_turret_frame = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	proof["rotation_follows_unit"] = bool(proof["rotation_follows_unit"]) and is_equal_approx(float(build_turret_frame.get("rotation", -1.0)), 135.0) and is_equal_approx(float(build_turret_frame.get("unit_look_angle", -1.0)), 45.0) and is_equal_approx(float(build_turret_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(build_turret_frame.get("potential_efficiency", -1.0)), 0.5) and is_equal_approx(float(build_turret_frame.get("build_speed_multiplier", -1.0)), 0.5) and is_equal_approx(float(build_turret_frame.get("speed_multiplier", -1.0)), 0.5) and is_equal_approx(float(build_turret_frame.get("warmup", -1.0)), 0.05)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
