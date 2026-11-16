extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
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

	# --- Draw rows (N2428): RepairTowerBuild.draw()
	# (RepairTower.java:94-110) runs super.draw() and then,
	# unless warmup <= 0.001f, the Layer.effect circle (mod
	# = totalProgress % 1f, stroke circleStroke * (1 - mod)
	# * warmup, radius range * mod), the Pal.heal square
	# (radius squareRad * warmup, rotation Time.time /
	# squareSpinScl) and the additive glow (alpha warmup *
	# (1 - glowMag + absin(Time.time, glowScl, glowMag)) at
	# Layer.blockAdditive, Java-exact absin at the doubled
	# scale). drawSelect (:122-124) dash-circles the range
	# in Pal.placing at the building x/y; drawPlace
	# (:44-48) dash-circles the same range at the tile
	# position (x * tilesize + offset). setStats (:36-40)
	# adds the range row (range / tilesize blocks) and the
	# repairSpeed row (healAmount * 60 per second); range()
	# (:112-114) returns range and warmup() (:117-119)
	# returns warmup. Pure-only: the tick never calls draw
	# -- draw is called by the renderer, and the renderer
	# call site waits for a renderer slice, so this proof
	# has no live-tick key.

	# --- Warmup gate: at warmup 0.001 (the exact gate)
	# and at warmup 0 the circle / square / glow calls are
	# empty, but super.draw() still ran (it sits before the
	# gate) and drawSelect / drawPlace still draw (neither
	# has a warmup gate); at warmup 0.5 all three calls
	# draw.
	var warm: Dictionary = repair_tower_build_state.source_repair_tower_draw_state(100.0, 200.0, 0.5, 2.25, 100.0, 0.0, "Pal.heal", 3.0, 3.0, 0.8, "glowColor", 0.5, 8.0, 4.0, 10, 20)
	var cold: Dictionary = repair_tower_build_state.source_repair_tower_draw_state(100.0, 200.0, 0.001, 2.25, 100.0, 0.0, "Pal.heal", 3.0, 3.0, 0.8, "glowColor", 0.5, 8.0, 4.0, 10, 20)
	var frozen: Dictionary = repair_tower_build_state.source_repair_tower_draw_state(100.0, 200.0, 0.0, 2.25, 100.0, 0.0, "Pal.heal", 3.0, 3.0, 0.8, "glowColor", 0.5, 8.0, 4.0, 10, 20)
	proof["draw_warmup_gate"] = bool(warm.get("warmup_gated", true)) == false and bool(cold.get("warmup_gated", false)) == true and bool(frozen.get("warmup_gated", false)) == true and Dictionary(cold.get("circle_call", {"missing": true})).is_empty() and Dictionary(cold.get("square_call", {"missing": true})).is_empty() and Dictionary(cold.get("glow_call", {"missing": true})).is_empty() and Dictionary(frozen.get("circle_call", {"missing": true})).is_empty() and Dictionary(frozen.get("square_call", {"missing": true})).is_empty() and Dictionary(frozen.get("glow_call", {"missing": true})).is_empty() and not Dictionary(cold.get("super_call", {})).is_empty() and not Dictionary(cold.get("select_call", {})).is_empty() and not Dictionary(cold.get("place_call", {})).is_empty() and not Dictionary(warm.get("circle_call", {})).is_empty() and not Dictionary(warm.get("square_call", {})).is_empty() and not Dictionary(warm.get("glow_call", {})).is_empty()

	# --- Circle math: mod = totalProgress % 1f (2.25 ->
	# 0.25), stroke circleStroke * (1 - mod) * warmup =
	# 3 * 0.75 * 0.5 = 1.125, radius range * mod = 25, at
	# z Layer.effect in circleColor; the mod wraps (3.75
	# -> 0.75, radius 75, stroke 0.375) and a zero
	# totalProgress draws a zero-radius circle.
	var warm_circle: Dictionary = warm.get("circle_call", {})
	var wrapped: Dictionary = repair_tower_build_state.source_repair_tower_draw_state(0.0, 0.0, 0.5, 3.75, 100.0, 0.0, "Pal.heal", 3.0, 3.0, 0.8, "glowColor", 0.5, 8.0, 4.0, 0, 0)
	var wrapped_circle: Dictionary = wrapped.get("circle_call", {})
	var still: Dictionary = repair_tower_build_state.source_repair_tower_draw_state(0.0, 0.0, 1.0, 0.0, 100.0, 0.0, "Pal.heal", 3.0, 3.0, 0.8, "glowColor", 0.5, 8.0, 4.0, 0, 0)
	var still_circle: Dictionary = still.get("circle_call", {})
	proof["draw_circle"] = is_equal_approx(float(warm.get("mod", -1.0)), 0.25) and is_equal_approx(float(warm_circle.get("radius", -1.0)), 25.0) and is_equal_approx(float(warm_circle.get("stroke", -1.0)), 1.125) and str(warm_circle.get("color", "")) == "Pal.heal" and str(warm_circle.get("layer", "")) == "Layer.effect" and is_equal_approx(float(warm_circle.get("x", -1.0)), 100.0) and is_equal_approx(float(warm_circle.get("y", -1.0)), 200.0) and is_equal_approx(float(warm.get("circle_stroke_value", -1.0)), 1.125) and is_equal_approx(float(warm.get("circle_radius", -1.0)), 25.0) and is_equal_approx(float(wrapped.get("mod", -1.0)), 0.75) and is_equal_approx(float(wrapped_circle.get("radius", -1.0)), 75.0) and is_equal_approx(float(wrapped_circle.get("stroke", -1.0)), 0.375) and is_equal_approx(float(still_circle.get("radius", -1.0)), 0.0) and is_equal_approx(float(still_circle.get("stroke", -1.0)), 3.0)

	# --- Square + glow: the square radius is squareRad *
	# warmup = 1.5 at warmup 0.5, rotation Time.time /
	# squareSpinScl (0 at time 0, 10 at time 8), color
	# Pal.heal at Layer.effect; the glow alpha is warmup *
	# (1 - glowMag + absin) with the absin Java-exact at
	# the DOUBLED scale (helper(time, glowScl * 2, glowMag)
	# == Java absin(time, glowScl, glowMag)): at time 0
	# absin is 0.25 and alpha is 0.5 * 0.75 = 0.375; at
	# time 8 with warmup 1 the expected absin is computed
	# from sin(8 / 16) directly, which an undoubled scale
	# would miss.
	var warm_square: Dictionary = warm.get("square_call", {})
	var warm_glow: Dictionary = warm.get("glow_call", {})
	var timed: Dictionary = repair_tower_build_state.source_repair_tower_draw_state(0.0, 0.0, 1.0, 0.0, 100.0, 8.0, "Pal.heal", 3.0, 3.0, 0.8, "glowColor", 0.5, 8.0, 4.0, 0, 0)
	var timed_square: Dictionary = timed.get("square_call", {})
	var timed_glow: Dictionary = timed.get("glow_call", {})
	var expected_absin_8: float = (sin(8.0 / 16.0) * 0.5 + 0.5) * 0.5
	proof["draw_square_glow"] = is_equal_approx(float(warm_square.get("radius", -1.0)), 1.5) and is_equal_approx(float(warm_square.get("rotation", -1.0)), 0.0) and str(warm_square.get("color", "")) == "Pal.heal" and str(warm_square.get("layer", "")) == "Layer.effect" and is_equal_approx(float(warm.get("square_radius", -1.0)), 1.5) and is_equal_approx(float(warm_glow.get("alpha", -1.0)), 0.375) and is_equal_approx(float(warm.get("glow_absin", -1.0)), 0.25) and is_equal_approx(float(warm.get("glow_alpha", -1.0)), 0.375) and str(warm_glow.get("region", "")) == "glow" and str(warm_glow.get("color", "")) == "glowColor" and str(warm_glow.get("layer", "")) == "Layer.blockAdditive" and is_equal_approx(float(warm_glow.get("rotation", -1.0)), 0.0) and is_equal_approx(float(timed_square.get("rotation", -1.0)), 10.0) and is_equal_approx(float(timed_square.get("radius", -1.0)), 3.0) and is_equal_approx(float(timed.get("glow_absin", -1.0)), expected_absin_8) and is_equal_approx(float(timed_glow.get("alpha", -1.0)), 1.0 * (1.0 - 0.5 + expected_absin_8))

	# --- Select / place: drawSelect dash-circles the
	# range in Pal.placing at the building x/y; drawPlace
	# dash-circles the same range at the tile position
	# (tile 10, 20 with offset 4 -> center 84, 164); a
	# size-1 tower (offset 0) places at the bare tile
	# corner (tile 1, 2 -> 8, 16).
	var warm_select: Dictionary = warm.get("select_call", {})
	var warm_place: Dictionary = warm.get("place_call", {})
	var odd: Dictionary = repair_tower_build_state.source_repair_tower_draw_state(0.0, 0.0, 0.0, 0.0, 80.0, 0.0, "Pal.heal", 3.0, 3.0, 0.8, "glowColor", 0.5, 8.0, 0.0, 1, 2)
	var odd_place: Dictionary = odd.get("place_call", {})
	proof["draw_select_place"] = str(warm_select.get("color", "")) == "Pal.placing" and is_equal_approx(float(warm_select.get("x", -1.0)), 100.0) and is_equal_approx(float(warm_select.get("y", -1.0)), 200.0) and is_equal_approx(float(warm_select.get("radius", -1.0)), 100.0) and str(warm_place.get("color", "")) == "Pal.placing" and is_equal_approx(float(warm_place.get("x", -1.0)), 84.0) and is_equal_approx(float(warm_place.get("y", -1.0)), 164.0) and is_equal_approx(float(warm_place.get("radius", -1.0)), 100.0) and is_equal_approx(float(warm.get("place_x", -1.0)), 84.0) and is_equal_approx(float(warm.get("place_y", -1.0)), 164.0) and is_equal_approx(float(odd_place.get("x", -1.0)), 8.0) and is_equal_approx(float(odd_place.get("y", -1.0)), 16.0) and is_equal_approx(float(odd_place.get("radius", -1.0)), 80.0)

	# --- setStats rows: the def (range 100, healAmount
	# 1.5) reads 12.5 blocks and 90 per second; the class
	# defaults (range 80, healAmount 1) read 10 blocks
	# and 60 per second, with the Stat / StatUnit tokens
	# on each row.
	var stats: Dictionary = repair_tower_build_state.source_repair_tower_stats_state(100.0, 1.5, 0.5)
	var stats_range: Dictionary = stats.get("range_blocks", {})
	var stats_repair: Dictionary = stats.get("repair_per_second", {})
	var class_stats: Dictionary = repair_tower_build_state.source_repair_tower_stats_state(80.0, 1.0, 0.0)
	var class_range: Dictionary = class_stats.get("range_blocks", {})
	var class_repair: Dictionary = class_stats.get("repair_per_second", {})
	proof["draw_stats"] = str(stats_range.get("stat", "")) == "Stat.range" and str(stats_range.get("unit", "")) == "StatUnit.blocks" and is_equal_approx(float(stats_range.get("value", -1.0)), 12.5) and str(stats_repair.get("stat", "")) == "Stat.repairSpeed" and str(stats_repair.get("unit", "")) == "StatUnit.perSecond" and is_equal_approx(float(stats_repair.get("value", -1.0)), 90.0) and is_equal_approx(float(class_range.get("value", -1.0)), 10.0) and is_equal_approx(float(class_repair.get("value", -1.0)), 60.0)

	# --- Accessors: range() returns range and warmup()
	# returns warmup, straight through.
	proof["draw_accessors"] = is_equal_approx(float(stats.get("range_value", -1.0)), 100.0) and is_equal_approx(float(stats.get("warmup_value", -1.0)), 0.5) and is_equal_approx(float(class_stats.get("range_value", -1.0)), 80.0) and is_equal_approx(float(class_stats.get("warmup_value", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
