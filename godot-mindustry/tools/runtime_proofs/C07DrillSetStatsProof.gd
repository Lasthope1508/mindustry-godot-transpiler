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

	# --- Drill.setStats() super leg (N2332):
	# Drill.setStats() (Drill.java:175-191, `public void
	# setStats(){`) calls the Block super
	# (`super.setStats();`, :176 -- Block.setStats is owned
	# by N1696 at PortGame, NOT this slice), adds the
	# drillTier row (`stats.add(Stat.drillTier,
	# StatValues.drillables(drillTime,
	# hardnessDrillMultiplier, size * size,
	# drillMultipliers, ...));`, :178-179), adds the
	# drillSpeed row (`stats.add(Stat.drillSpeed, 60f /
	# drillTime * size * size, StatUnit.itemsSecond);`,
	# :181), and, only when `liquidBoostIntensity != 1`
	# and a booster consumer is found (:183), removes the
	# booster row (:184) and re-adds it with the SQUARED
	# intensity (`liquidBoostIntensity *
	# liquidBoostIntensity, false, consBase::consumes)`,
	# :188) -- the TRAP vs N2309, whose BurstDrill
	# override row uses the PLAIN intensity
	# (BurstDrill.java:65). This slice CLOSES the
	# super-leg deferred entry N2309 carried. There is NO
	# driver tick line: setStats is a stat-display read,
	# not a per-tick write (the N2224 / N2246 setStats
	# lifecycle precedent).

	# Per-def inputs (Blocks.java): impact-drill
	# `drillTime = 60f * 12f;` (:3072, 720f), `size = 4;`,
	# `tier = 6;`, `liquidBoostIntensity = 1.75f;`,
	# `drillMultipliers.put(Items.beryllium, 2f);`,
	# ozone booster `3f / 60f`; eruption-drill
	# `drillTime = 281.25f;`, `size = 5;`, `tier = 7;`,
	# `liquidBoostIntensity = 2f;`, cyanogen booster
	# `0.75f / 60f`. Class defaults (Drill.java):
	# `hardnessDrillMultiplier = 50f;` (:28), `drillTime
	# = 300;` (:36), `liquidBoostIntensity = 1.6f;` (:38).
	var impact: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 720.0, 50.0, 4, 6, {"beryllium": 2.0}, ["thorium"], 1.75, true, 3.0 / 60.0, true)
	var eruption: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 281.25, 50.0, 5, 7, {"beryllium": 2.0}, null, 2.0, true, 0.75 / 60.0, true)

	# The drillTier row pins the drillables call args:
	# impact drillTime 720, size squared 16, tier 6,
	# beryllium multiplier 2.0, blocked thorium.
	var impact_tier: Dictionary = impact.get("drill_tier_row", {})
	proof["drill_tier_row_impact"] = is_equal_approx(float(impact_tier.get("drill_time", -1.0)), 720.0) and is_equal_approx(float(impact_tier.get("hardness_drill_multiplier", -1.0)), 50.0) and int(impact_tier.get("size_squared", -1)) == 16 and int(impact_tier.get("tier", -1)) == 6 and is_equal_approx(float(Dictionary(impact_tier.get("drill_multipliers", {})).get("beryllium", -1.0)), 2.0) and Array(impact_tier.get("blocked_items", [])).has("thorium")

	# Eruption drillTime 281.25, size squared 25, tier 7,
	# beryllium multiplier 2.0, no blocked items.
	var eruption_tier: Dictionary = eruption.get("drill_tier_row", {})
	proof["drill_tier_row_eruption"] = is_equal_approx(float(eruption_tier.get("drill_time", -1.0)), 281.25) and is_equal_approx(float(eruption_tier.get("hardness_drill_multiplier", -1.0)), 50.0) and int(eruption_tier.get("size_squared", -1)) == 25 and int(eruption_tier.get("tier", -1)) == 7 and is_equal_approx(float(Dictionary(eruption_tier.get("drill_multipliers", {})).get("beryllium", -1.0)), 2.0) and eruption_tier.get("blocked_items", false) == null

	# The drillSpeed row is 60/drillTime*size^2 with unit
	# "items/second" (bundle.properties:1354,
	# `unit.itemssecond = items/second`): class default
	# drillTime 300, size 1 gives 0.2.
	var class_default: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 300.0, 50.0, 1, 0, {}, null, 1.6, false, 0.0, false)
	var class_speed: Dictionary = class_default.get("drill_speed_row", {})
	proof["drill_speed_class_default"] = is_equal_approx(float(class_speed.get("value", -1.0)), 0.2) and String(class_speed.get("unit", "")) == "items/second"

	# Impact: 60/720*16 == 1.333... items/second.
	var impact_speed: Dictionary = impact.get("drill_speed_row", {})
	proof["drill_speed_impact"] = is_equal_approx(float(impact_speed.get("value", -1.0)), 60.0 / 720.0 * 16.0) and String(impact_speed.get("unit", "")) == "items/second"

	# Eruption: 60/281.25*25 == 5.333... items/second.
	var eruption_speed: Dictionary = eruption.get("drill_speed_row", {})
	proof["drill_speed_eruption"] = is_equal_approx(float(eruption_speed.get("value", -1.0)), 60.0 / 281.25 * 25.0) and String(eruption_speed.get("unit", "")) == "items/second"

	# The booster row uses the SQUARED intensity: impact
	# 1.75^2 == 3.0625, amount 3f/60f, and the super row
	# was removed first.
	var impact_booster: Dictionary = impact.get("booster_row", {})
	proof["booster_row_squared_impact"] = bool(impact.get("booster_row_removed", false)) and String(impact_booster.get("format", "")) == "{0} x speed" and is_equal_approx(float(impact_booster.get("amount", -1.0)), 3.0 / 60.0) and is_equal_approx(float(impact_booster.get("intensity", -1.0)), 1.75 * 1.75) and bool(impact_booster.get("strength", true)) == false and bool(impact_booster.get("consumes", false)) == true

	# Eruption 2^2 == 4.0, amount 0.75f/60f.
	var eruption_booster: Dictionary = eruption.get("booster_row", {})
	proof["booster_row_squared_eruption"] = bool(eruption.get("booster_row_removed", false)) and String(eruption_booster.get("format", "")) == "{0} x speed" and is_equal_approx(float(eruption_booster.get("amount", -1.0)), 0.75 / 60.0) and is_equal_approx(float(eruption_booster.get("intensity", -1.0)), 4.0) and bool(eruption_booster.get("strength", true)) == false and bool(eruption_booster.get("consumes", false)) == true

	# Intensity 1.0: the guard does not run, nothing is
	# removed and no booster row is added.
	var intensity_one: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 300.0, 50.0, 1, 0, {}, null, 1.0, true, 0.05, true)
	proof["booster_row_absent_intensity_one"] = bool(intensity_one.get("booster_row_removed", true)) == false and intensity_one.get("booster_row", false) == null

	# No booster consumer found: the guard does not run
	# even at intensity 1.75.
	var no_consumer: Dictionary = burst_drill_build_state.source_drill_set_stats_state({}, 720.0, 50.0, 4, 6, {"beryllium": 2.0}, ["thorium"], 1.75, false, 0.05, true)
	proof["booster_row_absent_no_consumer"] = bool(no_consumer.get("booster_row_removed", true)) == false and no_consumer.get("booster_row", false) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillSetStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
