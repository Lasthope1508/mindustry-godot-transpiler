extends Node

const main_scene := preload("res://scenes/Main.tscn")
const impact_reactor_build_state := preload("res://src/game/SourceImpactReactorBuildState.gd")
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

	# --- Bar / stats rows (N2450): ImpactReactor.
	# setBars() (ImpactReactor.java:44-52) adds
	# the "power" bar -- the label is Core.bundle.
	# format("bar.poweroutput", Strings.fixed(
	# Math.max(entity.getPowerProduction() -
	# (consPower == null ? 0f : consPower.usage),
	# 0) * 60 * entity.timeScale(), 1)), the
	# color is Pal.powerBar, the fraction is
	# entity.productionEfficiency RAW (the Bar
	# clamps at render, Bar.java:33/:80). Strings.
	# fixed TRUNCATES (arc Strings.java:735),
	# it does NOT round (the N2426 lesson). The
	# single impact-reactor def sets
	# powerProduction 130f (Blocks.java:2636)
	# and consumePower 25f (Blocks.java:2642),
	# so the full-production net is (130 - 25)
	# * 60 = 6300.0. setStats() (ImpactReactor.
	# java:56-70) adds productionTime
	# (itemDuration / 60f, StatUnit.seconds)
	# when hasItems -- the def itemDuration is
	# 140f (Blocks.java:2637), NOT the class
	# default 60f -- and the warmupTime
	# composite label when consPower != null:
	# max = -ln(0.001) / warmupSpeed / 60 and
	# equal = -ln(1 - (usage / powerProduction)
	# ^(1/5)) / warmupSpeed / 60, autoFixed to
	# 2 places then joined with the LOCALIZED
	# units "seconds" (unit.seconds, bundle.
	# properties:1360) and "power equilibrium"
	# (unit.powerequilibrium, bundle.properties:
	# 1357). warmupSpeed is NOT overridden by
	# the def, so the class default 0.001f
	# (ImpactReactor.java:19) applies: max
	# 115.12s, equal 21.16s at the def. Pure-only:
	# the tick never calls setBars / setStats.

	# --- Bar label net: the def net (130 - 25)
	# * 60 * 1 = 6300.0 under the bar.poweroutput
	# key in Pal.powerBar; a null consPower
	# reads usage 0f, so the net is 130 * 60 =
	# 7800.0; the truncation case 100.001 * 60
	# = 6000.06 formats "6000.0", NOT "6000.1"
	# (Strings.fixed truncates); at timeScale
	# 0.5 the net halves to 3150.0.
	var full_bar: Dictionary = impact_reactor_build_state.source_impact_reactor_power_bar_state(130.0, 25.0, 1.0, 1.0)
	var full_label: Dictionary = full_bar.get("label", {})
	var null_cons_bar: Dictionary = impact_reactor_build_state.source_impact_reactor_power_bar_state(130.0, null, 1.0, 1.0)
	var null_cons_label: Dictionary = null_cons_bar.get("label", {})
	var trunc_bar: Dictionary = impact_reactor_build_state.source_impact_reactor_power_bar_state(100.001, 0.0, 1.0, 1.0)
	var trunc_label: Dictionary = trunc_bar.get("label", {})
	var half_bar: Dictionary = impact_reactor_build_state.source_impact_reactor_power_bar_state(130.0, 25.0, 0.5, 1.0)
	var half_label: Dictionary = half_bar.get("label", {})
	proof["bar_label_net"] = str(full_label.get("key", "")) == "bar.poweroutput" and str(full_label.get("amount", "")) == "6300.0" and str(full_bar.get("color", "")) == "Pal.powerBar" and is_equal_approx(float(full_bar.get("net_per_second", -1.0)), 6300.0) and str(null_cons_label.get("amount", "")) == "7800.0" and str(trunc_label.get("amount", "")) == "6000.0" and str(half_label.get("amount", "")) == "3150.0"

	# --- Bar label zero floor: Math.max(net, 0)
	# floors the label at 0 -- production below
	# the usage (10 vs 25), exactly at the usage
	# (25 vs 25) and zero production all format
	# "0.0".
	var below_bar: Dictionary = impact_reactor_build_state.source_impact_reactor_power_bar_state(10.0, 25.0, 1.0, 0.0)
	var below_label: Dictionary = below_bar.get("label", {})
	var exact_bar: Dictionary = impact_reactor_build_state.source_impact_reactor_power_bar_state(25.0, 25.0, 1.0, 0.0)
	var exact_label: Dictionary = exact_bar.get("label", {})
	var zero_bar: Dictionary = impact_reactor_build_state.source_impact_reactor_power_bar_state(0.0, 25.0, 1.0, 0.0)
	var zero_label: Dictionary = zero_bar.get("label", {})
	proof["bar_label_zero_floor"] = str(below_label.get("amount", "")) == "0.0" and str(exact_label.get("amount", "")) == "0.0" and str(zero_label.get("amount", "")) == "0.0" and is_equal_approx(float(below_bar.get("net_per_second", -1.0)), 0.0)

	# --- Bar fraction raw: the fraction is the
	# productionEfficiency RAW -- 1.5 stays 1.5
	# (the Bar clamps it at render, Bar.java:33/
	# :80), 0.25 stays 0.25, 0.0 stays 0.0.
	var over_bar: Dictionary = impact_reactor_build_state.source_impact_reactor_power_bar_state(130.0, 25.0, 1.0, 1.5)
	var quarter_bar: Dictionary = impact_reactor_build_state.source_impact_reactor_power_bar_state(130.0, 25.0, 1.0, 0.25)
	proof["bar_fraction_raw"] = is_equal_approx(float(over_bar.get("fraction", -1.0)), 1.5) and is_equal_approx(float(quarter_bar.get("fraction", -1.0)), 0.25) and is_equal_approx(float(full_bar.get("fraction", -1.0)), 1.0) and is_equal_approx(float(zero_bar.get("fraction", -1.0)), 0.0)

	# --- Stats production time: itemDuration /
	# 60f -- 140 / 60 = 2.3333333 at the def,
	# 60 / 60 = 1.0 at the class default.
	var def_stats: Dictionary = impact_reactor_build_state.source_impact_reactor_stats_state(140.0, true, 0.001, 25.0, 130.0, true)
	var class_stats: Dictionary = impact_reactor_build_state.source_impact_reactor_stats_state(60.0, true, 0.001, 25.0, 130.0, true)
	proof["stats_production_time"] = is_equal_approx(float(def_stats.get("production_time_seconds", -1.0)), 2.3333333) and is_equal_approx(float(class_stats.get("production_time_seconds", -1.0)), 1.0)

	# --- Stats warmup label: the composite at
	# the def -- "115.12 seconds ~ 21.16 seconds
	# power equilibrium" (max -ln(0.001) / 0.001
	# / 60 = 115.129..., equal -ln(1 - (25 /
	# 130)^(1/5)) / 0.001 / 60 = 21.163...,
	# autoFixed to 2 places, joined with the
	# localized "seconds" and "power
	# equilibrium" units).
	proof["stats_warmup_label"] = str(def_stats.get("warmup_time_label", "")) == "115.12 seconds ~ 21.16 seconds power equilibrium" and is_equal_approx(float(def_stats.get("warmup_max", -1.0)), 115.12925) and is_equal_approx(float(def_stats.get("warmup_equal", -1.0)), 21.163596)

	# --- Stats gates null: no productionTime row
	# without items (production_time_seconds
	# null, the warmup label still present), no
	# warmupTime row without consPower
	# (warmup_time_label null, the production
	# time still present), both null when both
	# gates fail.
	var no_items_stats: Dictionary = impact_reactor_build_state.source_impact_reactor_stats_state(140.0, false, 0.001, 25.0, 130.0, true)
	var no_cons_stats: Dictionary = impact_reactor_build_state.source_impact_reactor_stats_state(140.0, true, 0.001, 25.0, 130.0, false)
	var neither_stats: Dictionary = impact_reactor_build_state.source_impact_reactor_stats_state(140.0, false, 0.001, 25.0, 130.0, false)
	proof["stats_gates_null"] = no_items_stats.get("production_time_seconds") == null and str(no_items_stats.get("warmup_time_label", "")) == "115.12 seconds ~ 21.16 seconds power equilibrium" and no_cons_stats.get("warmup_time_label") == null and is_equal_approx(float(no_cons_stats.get("production_time_seconds", -1.0)), 2.3333333) and neither_stats.get("production_time_seconds") == null and neither_stats.get("warmup_time_label") == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorBarStatsRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
