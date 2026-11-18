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

	# --- Pure BurstDrill liquid rows (N2258): each def carries
	# one required liquid and one booster liquid (Blocks.java:
	# 3089-3090 impact, :3119-3120 eruption). BuildingComp.
	# updateConsumption (BuildingComp.java:1943-2004) folds the
	# required row into the first pass (BuildingComp.java:
	# 1969-1977) and the booster row into the optional pass
	# (BuildingComp.java:1980-1982). Each row's efficiency is
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-46,
	# `float ed = build.edelta() * build.efficiencyScale();` /
	# `if(ed <= 0.00000001f) return 0f;` /
	# `return Math.min(build.liquids.get(liquid) / (amount * ed
	# * multiplier.get(build)), 1f);`) with edelta()
	# (BuildingComp.java:1928, `return efficiency * delta();`)
	# and the default cost multiplier (Consume.java:18,
	# `public Floatf<Building> multiplier = b -> 1f;`), and
	# each row's removal is ConsumeLiquid.update
	# (ConsumeLiquid.java:37-38, `build.liquids.remove(liquid,
	# amount * build.edelta() * multiplier.get(build));`). The
	# proof calls the pure function
	# source_burst_drill_liquid_rows_state(frame, delta,
	# required_amount, booster_amount) directly with synthetic
	# frames. There is no removal-application key: the actual
	# liquids.remove call waits for the driver slice that owns
	# the liquids module, and the remove_amount results are the
	# observable signal that slice will consume. There is no
	# setStats booster-display key: the stats booster row
	# (Drill.java:183-189) waits for its own slice.

	# Required efficiency full: impact-drill water 10f/60f
	# (Blocks.java:3089, `consumeLiquid(Liquids.water,
	# 10f/60f);`) with 10f/60f stored and ozone 3f/60f booster
	# (Blocks.java:3090, `consumeLiquid(Liquids.ozone, 3f /
	# 60f).boost();`) with 3f/60f stored, efficiency 1.0 and
	# delta 1.0, so edelta is 1.0 * 1.0 = 1.0 and ed is 1.0 --
	# both rows read 1.0.
	var full: Dictionary = burst_drill_build_state.source_burst_drill_liquid_rows_state({"efficiency": 1.0, "efficiency_scale": 1.0, "required_liquid_stored": 10.0 / 60.0, "booster_liquid_stored": 3.0 / 60.0}, 1.0, 10.0 / 60.0, 3.0 / 60.0)
	proof["liquid_rows_required_efficiency_full"] = is_equal_approx(float(full.get("edelta", -1.0)), 1.0) and is_equal_approx(float(full.get("ed", -1.0)), 1.0) and is_equal_approx(float(full.get("required_efficiency", -1.0)), 1.0) and is_equal_approx(float(full.get("booster_efficiency", -1.0)), 1.0)

	# Required efficiency partial: half the required water
	# (5f/60f stored against 10f/60f per frame) reads 0.5
	# while the booster row stays full at 1.0.
	var partial: Dictionary = burst_drill_build_state.source_burst_drill_liquid_rows_state({"efficiency": 1.0, "efficiency_scale": 1.0, "required_liquid_stored": 5.0 / 60.0, "booster_liquid_stored": 3.0 / 60.0}, 1.0, 10.0 / 60.0, 3.0 / 60.0)
	proof["liquid_rows_required_efficiency_partial"] = is_equal_approx(float(partial.get("required_efficiency", -1.0)), 0.5) and is_equal_approx(float(partial.get("booster_efficiency", -1.0)), 1.0)

	# Booster efficiency partial: the required row stays full
	# while half the booster ozone (1.5f/60f stored against
	# 3f/60f per frame) reads 0.5 -- so the speed fold
	# (BurstDrill.java:94) runs at lerpf(1.0, 1.75, 0.5).
	var booster_partial: Dictionary = burst_drill_build_state.source_burst_drill_liquid_rows_state({"efficiency": 1.0, "efficiency_scale": 1.0, "required_liquid_stored": 10.0 / 60.0, "booster_liquid_stored": 1.5 / 60.0}, 1.0, 10.0 / 60.0, 3.0 / 60.0)
	proof["liquid_rows_booster_efficiency_partial"] = is_equal_approx(float(booster_partial.get("required_efficiency", -1.0)), 1.0) and is_equal_approx(float(booster_partial.get("booster_efficiency", -1.0)), 0.5)

	# No liquid means zero efficiency: both stored amounts 0
	# read 0.0 on both rows, and nothing is removed.
	var empty: Dictionary = burst_drill_build_state.source_burst_drill_liquid_rows_state({"efficiency": 1.0, "efficiency_scale": 1.0, "required_liquid_stored": 0.0, "booster_liquid_stored": 0.0}, 1.0, 10.0 / 60.0, 3.0 / 60.0)
	proof["liquid_rows_no_liquid_zero_efficiency"] = is_equal_approx(float(empty.get("required_efficiency", -1.0)), 0.0) and is_equal_approx(float(empty.get("booster_efficiency", -1.0)), 0.0) and is_equal_approx(float(empty.get("required_remove_amount", -1.0)), 0.0) and is_equal_approx(float(empty.get("booster_remove_amount", -1.0)), 0.0)

	# edelta zero guard: efficiency 0.0 gives edelta 0.0 and
	# ed 0.0, so the ed guard (ConsumeLiquid.java:44,
	# `if(ed <= 0.00000001f) return 0f;`) zeroes both rows
	# even with liquid stored, and both removals are 0.0.
	var guarded: Dictionary = burst_drill_build_state.source_burst_drill_liquid_rows_state({"efficiency": 0.0, "efficiency_scale": 1.0, "required_liquid_stored": 10.0 / 60.0, "booster_liquid_stored": 3.0 / 60.0}, 1.0, 10.0 / 60.0, 3.0 / 60.0)
	proof["liquid_rows_edelta_zero_guard"] = is_equal_approx(float(guarded.get("edelta", -1.0)), 0.0) and is_equal_approx(float(guarded.get("ed", -1.0)), 0.0) and is_equal_approx(float(guarded.get("required_efficiency", -1.0)), 0.0) and is_equal_approx(float(guarded.get("booster_efficiency", -1.0)), 0.0) and is_equal_approx(float(guarded.get("required_remove_amount", -1.0)), 0.0) and is_equal_approx(float(guarded.get("booster_remove_amount", -1.0)), 0.0)

	# Remove amounts: with edelta 1.0 the impact rows remove
	# exactly their per-frame amounts, water 10f/60f and ozone
	# 3f/60f (ConsumeLiquid.java:38).
	var removals: Dictionary = burst_drill_build_state.source_burst_drill_liquid_rows_state({"efficiency": 1.0, "efficiency_scale": 1.0, "required_liquid_stored": 10.0 / 60.0, "booster_liquid_stored": 3.0 / 60.0}, 1.0, 10.0 / 60.0, 3.0 / 60.0)
	proof["liquid_rows_remove_amounts"] = is_equal_approx(float(removals.get("required_remove_amount", -1.0)), 10.0 / 60.0) and is_equal_approx(float(removals.get("booster_remove_amount", -1.0)), 3.0 / 60.0)

	# Eruption def uses its amounts: hydrogen 4f/60f
	# (Blocks.java:3119, `consumeLiquid(Liquids.hydrogen, 4f /
	# 60f);`) with 2f/60f stored reads 0.5, cyanogen 0.75f/60f
	# booster (Blocks.java:3120,
	# `consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();`)
	# with 0.75f/60f stored reads 1.0, and the removals are
	# 4f/60f and 0.75f/60f.
	var eruption: Dictionary = burst_drill_build_state.source_burst_drill_liquid_rows_state({"efficiency": 1.0, "efficiency_scale": 1.0, "required_liquid_stored": 2.0 / 60.0, "booster_liquid_stored": 0.75 / 60.0}, 1.0, 4.0 / 60.0, 0.75 / 60.0)
	proof["liquid_rows_eruption_def_amounts"] = is_equal_approx(float(eruption.get("required_efficiency", -1.0)), 0.5) and is_equal_approx(float(eruption.get("booster_efficiency", -1.0)), 1.0) and is_equal_approx(float(eruption.get("required_remove_amount", -1.0)), 4.0 / 60.0) and is_equal_approx(float(eruption.get("booster_remove_amount", -1.0)), 0.75 / 60.0)

	# Rows shape: the required row carries the required
	# efficiency and is not power, the optional row carries
	# the booster efficiency, and has_liquids is true
	# (ConsumeLiquidBase.apply sets block.hasLiquids).
	var shaped: Dictionary = burst_drill_build_state.source_burst_drill_liquid_rows_state({"efficiency": 1.0, "efficiency_scale": 1.0, "required_liquid_stored": 5.0 / 60.0, "booster_liquid_stored": 1.5 / 60.0}, 1.0, 10.0 / 60.0, 3.0 / 60.0)
	var required_row: Dictionary = shaped.get("required_row", {})
	var optional_row: Dictionary = shaped.get("optional_row", {})
	proof["liquid_rows_rows_shape"] = is_equal_approx(float(required_row.get("result", -1.0)), 0.5) and bool(required_row.get("is_power", true)) == false and is_equal_approx(float(optional_row.get("result", -1.0)), 0.5) and bool(shaped.get("has_liquids", false)) == true

	# Overstock caps at one: twice the required water (20f/60f
	# stored) and twice the booster ozone (6f/60f stored) both
	# read 1.0 -- there can be more liquid than necessary, so
	# the row caps at 1 (ConsumeLiquid.java:45-46).
	var overstock: Dictionary = burst_drill_build_state.source_burst_drill_liquid_rows_state({"efficiency": 1.0, "efficiency_scale": 1.0, "required_liquid_stored": 20.0 / 60.0, "booster_liquid_stored": 6.0 / 60.0}, 1.0, 10.0 / 60.0, 3.0 / 60.0)
	proof["liquid_rows_overstock_caps_at_one"] = is_equal_approx(float(overstock.get("required_efficiency", -1.0)), 1.0) and is_equal_approx(float(overstock.get("booster_efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillLiquidRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
