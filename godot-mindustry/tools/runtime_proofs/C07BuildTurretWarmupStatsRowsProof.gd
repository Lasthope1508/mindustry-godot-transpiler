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

	# --- Warmup / stats rows (N2451): the build
	# tower's warmup is a live frame key (N2243
	# ticks the lerp -- warmup = Mathf.
	# lerpDelta(warmup, unit.activelyBuilding()
	# ? efficiency : 0f, 0.1f),
	# BuildTurret.java:139) but NOTHING modeled
	# the warmup() accessor (public float
	# warmup() / return warmup,
	# BuildTurret.java:254-255, the override of
	# the BuildingComp default return 0f,
	# BuildingComp.java:608-610) or the
	# setStats row (stats.addPercent(
	# Stat.buildSpeed, buildSpeed),
	# BuildTurret.java:84). The warmup pure
	# returns the caller-supplied warmup
	# verbatim; the stats pure returns the
	# exact "buildSpeed" token (Stat.java:30)
	# + the RAW buildSpeed -- percent
	# formatting is a UI concern (the N2422
	# precedent): addPercent multiplies by 100
	# only at display time (add(stat,
	# StatValues.number((int)(value * 100),
	# StatUnit.percent)), Stats.java:38), so
	# the def 1.5f displays as 150% and the
	# class default 1f as 100%. Pure-only: the
	# tick never calls warmup() / setStats().

	# --- Warmup zero: a cold tower reads 0.0.
	var cold: Dictionary = build_turret_build_state.source_build_turret_warmup_state(0.0)
	proof["warmup_zero"] = is_equal_approx(float(cold.get("warmup_value", -1.0)), 0.0) and str(cold.get("warmup_expr", "")) == "return warmup;"

	# --- Warmup value: a half-warmed tower
	# reads its warmup verbatim (0.5 in, 0.5
	# out -- no lerp, no clamp, the accessor
	# only).
	var half: Dictionary = build_turret_build_state.source_build_turret_warmup_state(0.5)
	proof["warmup_value"] = is_equal_approx(float(half.get("warmup_value", -1.0)), 0.5)

	# --- Warmup one: a fully warmed tower
	# reads 1.0.
	var hot: Dictionary = build_turret_build_state.source_build_turret_warmup_state(1.0)
	proof["warmup_one"] = is_equal_approx(float(hot.get("warmup_value", -1.0)), 1.0)

	# --- Stats key: the exact "buildSpeed"
	# token (Stat.java:30) and the exact
	# setStats call.
	var def_stats: Dictionary = build_turret_build_state.source_build_turret_stats_state(1.5)
	proof["stats_key"] = str(def_stats.get("stat_key", "")) == "buildSpeed" and str(def_stats.get("set_stats_expr", "")) == "stats.addPercent(Stat.buildSpeed, buildSpeed);"

	# --- Stats value, def: the build-tower
	# def buildSpeed 1.5f (Blocks.java:2003)
	# rides RAW (1.5), displaying as 150%
	# once addPercent applies (int)(value *
	# 100) at display time (Stats.java:38).
	proof["stats_value_def"] = is_equal_approx(float(def_stats.get("stat_value", -1.0)), 1.5) and int(float(def_stats.get("stat_value", -1.0)) * 100.0) == 150

	# --- Stats value, class: the class
	# default buildSpeed 1f (BuildTurret.
	# java:33) rides RAW (1.0), displaying as
	# 100%.
	var class_stats: Dictionary = build_turret_build_state.source_build_turret_stats_state(1.0)
	proof["stats_value_class"] = is_equal_approx(float(class_stats.get("stat_value", -1.0)), 1.0) and int(float(class_stats.get("stat_value", -1.0)) * 100.0) == 100

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretWarmupStatsRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
