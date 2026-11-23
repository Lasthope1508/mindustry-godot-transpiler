extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _stats_case(drill_time: float, size: int, tier: int, blocked_items: Variant, optional_boost_intensity: float, booster_consumer_found: bool, booster_amount: float, booster_consumes: bool) -> Dictionary:
	# The two drillables filter legs (BeamDrill.java:123-124),
	# as the explicit drillables_filter Callable: a wall-ore
	# Floor, or a StaticWall, whose drop is hard enough for
	# the tier and not blocked.
	var drillables_filter: Callable = func(block: Dictionary) -> bool:
		var kind: String = block.get("kind", "")
		var item_drop: Variant = block.get("item_drop", null)
		if item_drop == null:
			return false
		if float(block.get("hardness", 0.0)) > float(tier):
			return false
		if blocked_items != null and item_drop in blocked_items:
			return false
		if kind == "floor":
			return bool(block.get("wall_ore", false))
		if kind == "static_wall":
			return true
		return false
	return state.source_beam_drill_set_stats_state({}, drill_time, size, tier, {}, blocked_items, optional_boost_intensity, booster_consumer_found, booster_amount, booster_consumes, drillables_filter)


func _block(kind: String, item_drop: Variant, hardness: float, wall_ore: bool = false) -> Dictionary:
	return {"kind": kind, "wall_ore": wall_ore, "item_drop": item_drop, "hardness": hardness}


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

	# --- BeamDrill.setStats() (N2388):
	# BeamDrill.setStats() (BeamDrill.java:119-137) adds the
	# drillTier row (StatValues.drillables with the
	# Floor/StaticWall filter legs), the drillSpeed row
	# (60f / drillTime * size -- the PLAIN size, NOT size *
	# size), and replaces the booster row with the PLAIN
	# optionalBoostIntensity when the guard holds. The proof
	# drives the pure function with per-def params (no live
	# tick): plasma-bore defaults (drillTime 160, tier 3,
	# size 2, optionalBoostIntensity 2.5, hydrogen booster
	# 0.25/60, Blocks.java:3038-3050) and large-plasma-bore
	# defaults (drillTime 100, tier 5, size 3, nitrogen
	# booster 3/60, Blocks.java:3052-3065). Copper hardness
	# 1, lead hardness 2, beryllium hardness 2, thorium
	# hardness 4. NO driver tick line: setStats is stat
	# display, not per-tick state.

	# Plasma-bore: the drillTier row pins the drillables
	# call args -- drillTime 160, drillMultiplier 0f, size
	# 2 (PLAIN, not size * size), tier 3, no blocked
	# items, empty drillMultipliers.
	var plasma: Dictionary = _stats_case(160.0, 2, 3, null, 2.5, true, 0.25 / 60.0, true)
	var plasma_tier_row: Dictionary = plasma.get("drill_tier_row", {})
	proof["drill_tier_row_args"] = is_equal_approx(float(plasma_tier_row.get("drill_time", -1.0)), 160.0) and is_equal_approx(float(plasma_tier_row.get("drill_multiplier", -1.0)), 0.0) and int(plasma_tier_row.get("size", -1)) == 2 and int(plasma_tier_row.get("tier", -1)) == 3 and plasma_tier_row.get("blocked_items", "x") == null and (plasma_tier_row.get("drill_multipliers", {}) as Dictionary).is_empty() and plasma_tier_row.get("filter", null) is Callable

	# The drillSpeed row is 60 / drillTime * size: 0.75
	# for plasma-bore (60/160*2), 1.8 for large-plasma-bore
	# (60/100*3) -- the PLAIN size, NOT size * size (the
	# Drill.java:181 trap would give 1.5 and 5.4).
	var large: Dictionary = _stats_case(100.0, 3, 5, null, 2.5, true, 3.0 / 60.0, true)
	var plasma_speed_row: Dictionary = plasma.get("drill_speed_row", {})
	var large_speed_row: Dictionary = large.get("drill_speed_row", {})
	proof["drill_speed_formula"] = is_equal_approx(float(plasma_speed_row.get("value", -1.0)), 0.75) and is_equal_approx(float(large_speed_row.get("value", -1.0)), 1.8)

	# The drillSpeed unit is StatUnit.itemsSecond,
	# localized "items/second".
	proof["drill_speed_unit"] = plasma_speed_row.get("unit", "") == "items/second" and large_speed_row.get("unit", "") == "items/second"

	# The Floor leg: a wall-ore Floor with a mineable drop
	# passes; a non-wall-ore Floor does not; a null drop
	# does not.
	var plasma_filter: Callable = plasma_tier_row.get("filter", Callable())
	proof["filter_floor_leg"] = bool(plasma_filter.call(_block("floor", "copper", 1.0, true))) and not bool(plasma_filter.call(_block("floor", "copper", 1.0, false))) and not bool(plasma_filter.call(_block("floor", null, 1.0, true)))

	# The StaticWall leg: a StaticWall with a mineable drop
	# passes; any other block kind does not.
	proof["filter_static_wall_leg"] = bool(plasma_filter.call(_block("static_wall", "beryllium", 2.0))) and not bool(plasma_filter.call(_block("ore", "copper", 1.0, true)))

	# A blocked drop fails both legs, while an unblocked
	# drop on the same tier still passes.
	var blocked_case: Dictionary = _stats_case(160.0, 2, 3, ["copper"], 2.5, true, 0.25 / 60.0, true)
	var blocked_filter: Callable = (blocked_case.get("drill_tier_row", {}) as Dictionary).get("filter", Callable())
	proof["filter_blocked_item"] = not bool(blocked_filter.call(_block("floor", "copper", 1.0, true))) and bool(blocked_filter.call(_block("floor", "lead", 2.0, true)))

	# The tier gate: thorium hardness 4 is too hard for
	# tier 3 (plasma-bore) but mineable at tier 5
	# (large-plasma-bore).
	var large_filter: Callable = (large.get("drill_tier_row", {}) as Dictionary).get("filter", Callable())
	proof["filter_tier_gate"] = not bool(plasma_filter.call(_block("floor", "thorium", 4.0, true))) and bool(large_filter.call(_block("floor", "thorium", 4.0, true)))

	# The booster row is present for plasma-bore (intensity
	# 2.5 != 1, consumer found): format "{0} x speed",
	# amount 0.25/60, strength false, consumes true, and
	# the replace ran.
	var plasma_booster_row: Dictionary = plasma.get("booster_row", {})
	proof["booster_row_present"] = bool(plasma.get("booster_row_replaced", false)) and plasma_booster_row.get("format", "") == "{0} x speed" and is_equal_approx(float(plasma_booster_row.get("amount", -1.0)), 0.25 / 60.0) and plasma_booster_row.get("strength", true) == false and plasma_booster_row.get("consumes", false) == true

	# The booster intensity is the PLAIN
	# optionalBoostIntensity 2.5 -- NOT the square 6.25
	# (the Drill.java:188 trap, whose super row uses the
	# squared liquidBoostIntensity).
	proof["booster_row_plain_intensity"] = is_equal_approx(float(plasma_booster_row.get("intensity", -1.0)), 2.5) and not is_equal_approx(float(plasma_booster_row.get("intensity", -1.0)), 6.25)

	# With optionalBoostIntensity == 1 the guard fails:
	# no replace, no booster row.
	var intensity_one: Dictionary = _stats_case(160.0, 2, 3, null, 1.0, true, 0.25 / 60.0, true)
	proof["booster_row_absent_intensity_one"] = intensity_one.get("booster_row_replaced", true) == false and intensity_one.get("booster_row", "x") == null

	# With no booster consumer found the guard fails: no
	# replace, no booster row.
	var no_consumer: Dictionary = _stats_case(160.0, 2, 3, null, 2.5, false, 0.25 / 60.0, true)
	proof["booster_row_absent_no_consumer"] = no_consumer.get("booster_row_replaced", true) == false and no_consumer.get("booster_row", "x") == null

	# Each result carries ONLY its own keys.
	proof["returns_only_four_keys"] = plasma.size() == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillSetStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
