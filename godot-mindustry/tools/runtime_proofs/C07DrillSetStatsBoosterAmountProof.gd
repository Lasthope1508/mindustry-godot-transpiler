extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- Drill.setStats() booster amount arg (N2434):
	# Drill.setStats() (Drill.java:175-191) re-adds the
	# booster row with `StatValues.speedBoosters("{0}" +
	# StatUnit.timesSpeed.localized(), consBase.amount,
	# liquidBoostIntensity * liquidBoostIntensity, false,
	# consBase::consumes)` (:186-188). The `:187` line
	# `consBase.amount,` -- the speedBoosters amount arg,
	# the per-frame liquid amount (`public float amount;`,
	# ConsumeLiquidBase.java:8) -- was never registered as
	# an expr: N2332 registered the surrounding call
	# (`StatValues.speedBoosters("{0}" +
	# StatUnit.timesSpeed.localized(),`, `:186`) and the
	# squared-intensity tail (`liquidBoostIntensity *
	# liquidBoostIntensity, false, consBase::consumes)`,
	# `:188`), and used the amount only as the param value
	# `booster_amount` of the already-live func
	# source_drill_set_stats_state (N2332), which returns
	# it as `booster_row["amount"]`. This slice is
	# registration-only (the N2427/N2430 precedent): it
	# registers `:187` and pins `booster_row["amount"]`
	# with proof keys, with NO GD change. It is NOT the
	# TractorBeam :165 case (batch 35 §4c, rejected):
	# there N1239 had already registered all 4 fragments
	# of the call including the args, so the middle line
	# was a comma artifact; here `:187` was never
	# registered under any form. It is also NOT the
	# BurstDrill override line (BurstDrill.java:65,
	# `consBase.amount, liquidBoostIntensity, false,
	# consBase::consumes)` -- PLAIN intensity, owned at
	# N2309): this line is Drill.java:187, SQUARED
	# intensity on the next line. There is NO driver tick
	# line: setStats is a stat-display read, not a
	# per-tick write (the N2224 / N2246 setStats
	# lifecycle precedent).

	# Per-def inputs (Blocks.java): impact-drill
	# `drillTime = 60f * 12f;` (:3072, 720f), `size = 4;`,
	# `tier = 6;`, `liquidBoostIntensity = 1.75f;`,
	# ozone booster `3f / 60f`; eruption-drill
	# `drillTime = 281.25f;`, `size = 5;`, `tier = 7;`,
	# `liquidBoostIntensity = 2f;`, cyanogen booster
	# `0.75f / 60f`. Class defaults (Drill.java):
	# `hardnessDrillMultiplier = 50f;` (:28), `drillTime
	# = 300;` (:36), `liquidBoostIntensity = 1.6f;` (:38).
	var impact: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 720.0, 50.0, 4, 6, {"beryllium": 2.0}, ["thorium"], 1.75, true, 3.0 / 60.0, true)
	var eruption: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 281.25, 50.0, 5, 7, {"beryllium": 2.0}, null, 2.0, true, 0.75 / 60.0, true)
	var class_default: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 300.0, 50.0, 1, 0, {}, null, 1.6, true, 0.05, true)
	var zero_amount: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 720.0, 50.0, 4, 6, {"beryllium": 2.0}, ["thorium"], 1.75, true, 0.0, true)

	# The booster row's amount is consBase.amount, the
	# per-frame liquid amount: impact 3f/60f == 0.05.
	var impact_booster: Dictionary = impact.get("booster_row", {})
	proof["booster_amount_impact"] = is_equal_approx(float(impact_booster.get("amount", -1.0)), 3.0 / 60.0)

	# Eruption 0.75f/60f == 0.0125.
	var eruption_booster: Dictionary = eruption.get("booster_row", {})
	proof["booster_amount_eruption"] = is_equal_approx(float(eruption_booster.get("amount", -1.0)), 0.75 / 60.0)

	# Class defaults with a 0.05 booster: the amount
	# flows through unchanged at intensity 1.6.
	var class_booster: Dictionary = class_default.get("booster_row", {})
	proof["booster_amount_class_default"] = is_equal_approx(float(class_booster.get("amount", -1.0)), 0.05)

	# A zero amount flows through as 0.0 -- the row is
	# still added when the guard runs.
	var zero_booster: Dictionary = zero_amount.get("booster_row", {})
	proof["booster_amount_zero"] = is_equal_approx(float(zero_booster.get("amount", -1.0)), 0.0)

	# The amount slot holds consBase.amount, NOT the
	# intensity: impact amount 0.05 vs squared intensity
	# 1.75^2 == 3.0625 -- the two slots are distinct.
	proof["booster_amount_distinct_from_intensity"] = is_equal_approx(float(impact_booster.get("amount", -1.0)), 0.05) and is_equal_approx(float(impact_booster.get("intensity", -1.0)), 1.75 * 1.75) and not is_equal_approx(float(impact_booster.get("amount", -1.0)), float(impact_booster.get("intensity", -1.0)))

	# Intensity 1.0: the guard does not run, no booster
	# row is added, so there is no amount to pin.
	var intensity_one: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 300.0, 50.0, 1, 0, {}, null, 1.0, true, 0.05, true)
	proof["booster_amount_absent_intensity_one"] = intensity_one.get("booster_row", false) == null

	# No booster consumer found: the guard does not run
	# even at intensity 1.75.
	var no_consumer: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 720.0, 50.0, 4, 6, {"beryllium": 2.0}, ["thorium"], 1.75, false, 0.05, true)
	proof["booster_amount_absent_no_consumer"] = no_consumer.get("booster_row", false) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillSetStatsBoosterAmountProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
