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

	# --- BurstDrill setStats() (N2266):
	# BurstDrill.setStats() (BurstDrill.java:58-68,
	# `public void setStats(){`) calls the Drill super
	# (`super.setStats();`, :59, NOT this slice) and, only
	# when `liquidBoostIntensity != 1` and a booster
	# consumer is found (`if(liquidBoostIntensity != 1 &&
	# findConsumer(f -> f instanceof ConsumeLiquidBase &&
	# f.booster) instanceof ConsumeLiquidBase consBase){`,
	# :61), removes the booster row
	# (`stats.remove(Stat.booster);`, :62) and re-adds it
	# with the PLAIN intensity (`stats.add(Stat.booster,`,
	# :63, `StatValues.speedBoosters("{0}" + StatUnit.
	# timesSpeed.localized(),`, :64, `consBase.amount,
	# liquidBoostIntensity, false, consBase::consumes)`,
	# :65). The super's own booster row uses the SQUARED
	# intensity (`liquidBoostIntensity *
	# liquidBoostIntensity, false, consBase::consumes)`,
	# Drill.java:188), so the override's remove-then-add is
	# what pins the displayed speed to the plain intensity.
	# The unit format is "{0} x speed":
	# StatUnit.timesSpeed.localized() reads bundle key
	# "unit.timesspeed", English value "x speed"
	# (bundle.properties:1364). The `false` strength arg
	# (:65) means the displayed speed is the plain
	# intensity, not heatCapacity-scaled
	# (StatValues.java:522). findConsumer is NOT ported
	# here: the proof passes the found consumer as explicit
	# inputs (the N1688/N1753 findConsumer precedent).
	# There is NO driver tick line: setStats is a
	# block-level stat-display read, not a per-tick write
	# (the N2224 / N2246 setStats lifecycle precedent).
	# The proof calls the pure function directly with the
	# per-def intensities and booster amounts (the
	# N2224/N2225 pattern).

	# impact-drill (liquidBoostIntensity 1.75f,
	# Blocks.java:3084; booster ozone 3f/60f,
	# Blocks.java:3090): the booster row is present with
	# the plain intensity 1.75 and amount 3/60.
	var impact: Dictionary = burst_drill_build_state.source_burst_drill_set_stats_state({}, 1.75, true, 3.0 / 60.0, true)
	var impact_row: Dictionary = impact.get("booster_row", {})
	proof["set_stats_booster_impact_drill"] = bool(impact.get("booster_row_removed", false)) and impact_row.get("format", "") == "{0} x speed" and is_equal_approx(float(impact_row.get("amount", 0.0)), 3.0 / 60.0) and is_equal_approx(float(impact_row.get("intensity", 0.0)), 1.75) and impact_row.get("strength", true) == false and bool(impact_row.get("consumes", false))

	# eruption-drill (liquidBoostIntensity 2f,
	# Blocks.java:3115; booster cyanogen 0.75f/60f,
	# Blocks.java:3120): the booster row is present with
	# the plain intensity 2.0 and amount 0.75/60.
	var eruption: Dictionary = burst_drill_build_state.source_burst_drill_set_stats_state({}, 2.0, true, 0.75 / 60.0, true)
	var eruption_row: Dictionary = eruption.get("booster_row", {})
	proof["set_stats_booster_eruption_drill"] = bool(eruption.get("booster_row_removed", false)) and eruption_row.get("format", "") == "{0} x speed" and is_equal_approx(float(eruption_row.get("amount", 0.0)), 0.75 / 60.0) and is_equal_approx(float(eruption_row.get("intensity", 0.0)), 2.0) and eruption_row.get("strength", true) == false and bool(eruption_row.get("consumes", false))

	# intensity == 1: the guard fails, no row is removed
	# or added, even when a booster consumer exists.
	var intensity_one: Dictionary = burst_drill_build_state.source_burst_drill_set_stats_state({}, 1.0, true, 3.0 / 60.0, true)
	proof["set_stats_booster_absent_intensity_one"] = not bool(intensity_one.get("booster_row_removed", true)) and intensity_one.get("booster_row", {}) == null

	# No booster consumer found: the guard fails, no row
	# is removed or added, even at intensity 1.75.
	var no_consumer: Dictionary = burst_drill_build_state.source_burst_drill_set_stats_state({}, 1.75, false, 3.0 / 60.0, true)
	proof["set_stats_booster_absent_no_consumer"] = not bool(no_consumer.get("booster_row_removed", true)) and no_consumer.get("booster_row", {}) == null

	# The remove runs before the add: when the row is
	# present, booster_row_removed is true (the override
	# replaces the super's squared-intensity row instead
	# of adding a second booster row).
	proof["set_stats_booster_removed_before_add"] = bool(impact.get("booster_row_removed", false)) and bool(eruption.get("booster_row_removed", false)) and impact.get("booster_row", null) != null and eruption.get("booster_row", null) != null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillSetStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
