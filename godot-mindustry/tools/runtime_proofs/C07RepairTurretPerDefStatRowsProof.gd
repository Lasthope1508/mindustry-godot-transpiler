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

	# --- Per-def stat rows (N2489): RepairTurret.
	# The class defaults (RepairTurret.java:32-37)
	# are repairSpeed 0.3f / repairRadius 50f /
	# length 5f / beamWidth 1f / pulseRadius 6f.
	# The defs (Blocks.java:6386-6406) are
	# repair-point (repairSpeed 0.45f /
	# repairRadius 60f / beamWidth 0.73f /
	# pulseRadius 5f, NO length line -- the point
	# keeps the class 5f) and repair-turret
	# (length 6f / repairSpeed 3f / repairRadius
	# 145f / beamWidth 1.1f / pulseRadius 6.1f).
	# The stat anchor is setStats()
	# (RepairTurret.java:71-74): `stats.add(
	# Stat.range, repairRadius / tilesize,
	# StatUnit.blocks);` + `stats.add(
	# Stat.repairSpeed, repairSpeed * 60f,
	# StatUnit.perSecond);`. The pure returns the
	# def's five rows; an unknown def id falls
	# back to the CLASS defaults (the N2304
	# fallback precedent -- NOT the repair-point
	# fallback of the N2226 advance helpers).
	#
	# Fixture: the pure takes the catalog def id
	# ("repair-point" / "repair-turret") and
	# returns {repair_speed, repair_radius,
	# length, beam_width, pulse_radius} as data.
	# Pure-only: the tick never calls it -- the
	# advance / draw pures take these values as
	# caller-supplied inputs, and the live-input
	# keys below compose them.

	# --- Point row: repair-point reads 0.45 /
	# 60.0 / 5.0 / 0.73 / 5.0 -- the length is
	# the class default 5f, because the def sets
	# no length (Blocks.java:6386-6394).
	var point: Dictionary = repair_turret_build_state.source_repair_turret_per_def_stats_state("repair-point")
	proof["stats_point"] = float(point.get("repair_speed", 0.0)) == 0.45 and float(point.get("repair_radius", 0.0)) == 60.0 and float(point.get("length", 0.0)) == 5.0 and float(point.get("beam_width", 0.0)) == 0.73 and float(point.get("pulse_radius", 0.0)) == 5.0

	# --- Turret row: repair-turret reads 3.0 /
	# 145.0 / 6.0 / 1.1 / 6.1 -- every field is a
	# def override (Blocks.java:6396-6407).
	var turret: Dictionary = repair_turret_build_state.source_repair_turret_per_def_stats_state("repair-turret")
	proof["stats_turret"] = float(turret.get("repair_speed", 0.0)) == 3.0 and float(turret.get("repair_radius", 0.0)) == 145.0 and float(turret.get("length", 0.0)) == 6.0 and float(turret.get("beam_width", 0.0)) == 1.1 and float(turret.get("pulse_radius", 0.0)) == 6.1

	# --- Class fallback: an unknown def id (and
	# the empty id) reads the CLASS defaults 0.3
	# / 50.0 / 5.0 / 1.0 / 6.0 (RepairTurret.
	# java:32-37) -- the N2304 fallback
	# precedent, not the repair-point row.
	var unknown: Dictionary = repair_turret_build_state.source_repair_turret_per_def_stats_state("unknown-def")
	var empty: Dictionary = repair_turret_build_state.source_repair_turret_per_def_stats_state("")
	proof["stats_class_fallback"] = float(unknown.get("repair_speed", 0.0)) == 0.3 and float(unknown.get("repair_radius", 0.0)) == 50.0 and float(unknown.get("length", 0.0)) == 5.0 and float(unknown.get("beam_width", 0.0)) == 1.0 and float(unknown.get("pulse_radius", 0.0)) == 6.0 and float(empty.get("repair_speed", 0.0)) == 0.3 and float(empty.get("repair_radius", 0.0)) == 50.0 and float(empty.get("length", 0.0)) == 5.0 and float(empty.get("beam_width", 0.0)) == 1.0 and float(empty.get("pulse_radius", 0.0)) == 6.0

	# --- Speed / radius rows: the setStats rows
	# (RepairTurret.java:73-74) read off the
	# pure's values -- repairSpeed * 60f per
	# second (27.0 point / 180.0 turret) and
	# repairRadius / tilesize in blocks (7.5
	# point / 18.125 turret, tilesize 8.0).
	var point_per_second: float = float(point.get("repair_speed", 0.0)) * 60.0
	var point_blocks: float = float(point.get("repair_radius", 0.0)) / 8.0
	var turret_per_second: float = float(turret.get("repair_speed", 0.0)) * 60.0
	var turret_blocks: float = float(turret.get("repair_radius", 0.0)) / 8.0
	proof["stats_speed_radius"] = point_per_second == 27.0 and point_blocks == 7.5 and turret_per_second == 180.0 and turret_blocks == 18.125

	# --- Beam / pulse rows: the turret's length
	# / beamWidth / pulseRadius feed the N2421
	# draw pure as its caller-supplied inputs --
	# the draw echoes length 6.0 / beam_width 1.1
	# / pulse_radius 6.1, the laser width is
	# strength * beamWidth (1.0 * 1.1), and the
	# pulse circle radius is 1.0 at f = 0.
	var drawn: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 90.0, float(turret.get("length", 0.0)), 1, null, 1.0, 2.0, float(turret.get("pulse_radius", 0.0)), float(turret.get("beam_width", 0.0)), {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, {}, float(turret.get("repair_radius", 0.0)), 2, 0, 0)
	proof["stats_beam_pulse"] = float(drawn.get("length", 0.0)) == 6.0 and float(drawn.get("beam_width", 0.0)) == 1.1 and float(drawn.get("pulse_radius", 0.0)) == 6.1 and float(drawn.get("laser_width", 0.0)) == 1.1 and float(drawn.get("circle_radius", 0.0)) == 1.0

	# --- Live input: the point's repairSpeed /
	# repairRadius feed the N2226 advance pure as
	# its caller-supplied inputs -- a damaged
	# target at angle 90 (rotation 90, within the
	# 30-degree heal margin) with efficiency 1.0
	# / strength 1.0 / delta 1.0 heals 0.45 * 1.0
	# * 1.0 * 1.0 = 0.45 (RepairTurret.java:207,
	# `target.heal(repairSpeed * strength *
	# edelta() * multiplier);`).
	var target: Dictionary = {"dead": false, "distance": 0.0, "health": 50.0, "max_health": 100.0, "x": 0.0, "y": 1.0, "hit_size": 0.0, "damaged": true, "valid": true}
	var frame: Dictionary = {"efficiency": 1.0, "target": target, "strength": 1.0, "rotation": 90.0}
	var advanced: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state(frame, 1.0, 1.0, float(point.get("repair_speed", 0.0)), float(point.get("repair_radius", 0.0)), 0.0, 0.0, [])
	proof["stats_live_input"] = bool(advanced.get("healed", false)) and float(advanced.get("heal_amount", 0.0)) == 0.45

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretPerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
