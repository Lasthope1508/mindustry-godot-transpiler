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

	# --- Draw rows (N2421): RepairPointBuild.draw()
	# (RepairTurret.java:164-174), the static drawBeam
	# (:106-150), drawSelect() (:177-179), drawPlace()
	# (:95-99), icons() (:102-104). draw() rects the
	# baseRegion, then the turret-layer shadow + region
	# rect at rotation - 90 -- the shadow shifts by
	# the FLOAT (size / 2f), so a size-2 repair-turret
	# shifts by 1.0 and a size-1 repair-point by 0.5
	# (NOT the MassDriver int division). drawBeam
	# seeds rand from id + target id, recomputes
	# lastEnd from the target (setLength(max(2, len))
	# + the offset.trns jitter rotated by the target
	# rotation), and draws the pulse circle + two
	# Drawf.laser calls when strength > 0.01. NO RNG
	# IN THE PURE: the four rand rolls are caller-
	# supplied inputs -- the pure computes geometry
	# deterministically from the already-rolled
	# values. drawSelect/drawPlace draw dash circles
	# at repairRadius (the place circle WITH the
	# Block offset). icons() returns [baseRegion,
	# region]. Pure-only: the tick never calls draw.

	# --- Base / shadow / region: a repair-turret
	# (size 2) at (100, 200), rotation 90 -- base
	# rect, shadow and region all at (100, 200)
	# except the shadow, which shifts by the FLOAT
	# size / 2f = 1.0 to (99, 199), rotation 0. At
	# rotation 0 the region draws at rotation -90.
	# A repair-point (size 1) shifts by 0.5 to
	# (99.5, 199.5) -- the FLOAT division, not the
	# MassDriver int division.
	var no_rolls: Dictionary = {"roll_angle": 0.0, "roll_phase": 0.0, "roll_magnitude": 0.0, "roll_f": 0.0}
	var turret_draw: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 90.0, 6.0, 1, null, 0.0, 2.0, 6.1, 1.1, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 145.0, 2, 0, 0)
	var turret_base: Dictionary = turret_draw.get("base_call", {})
	var turret_shadow: Dictionary = turret_draw.get("shadow_call", {})
	var turret_region: Dictionary = turret_draw.get("region_call", {})
	var flat_draw: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 0.0, 6.0, 1, null, 0.0, 2.0, 6.1, 1.1, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 145.0, 2, 0, 0)
	var flat_region: Dictionary = flat_draw.get("region_call", {})
	var point_draw: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 90.0, 5.0, 1, null, 0.0, 2.0, 5.0, 0.73, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 60.0, 1, 0, 0)
	var point_shadow: Dictionary = point_draw.get("shadow_call", {})
	proof["draw_base_shadow_region"] = is_equal_approx(float(turret_base.get("x", -1.0)), 100.0) and is_equal_approx(float(turret_base.get("y", -1.0)), 200.0) and str(turret_base.get("region", "")) == "baseRegion" and is_equal_approx(float(turret_shadow.get("x", -1.0)), 99.0) and is_equal_approx(float(turret_shadow.get("y", -1.0)), 199.0) and is_equal_approx(float(turret_shadow.get("rotation", -1.0)), 0.0) and str(turret_shadow.get("z", "")) == "Layer.turret" and is_equal_approx(float(turret_region.get("x", -1.0)), 100.0) and is_equal_approx(float(turret_region.get("y", -1.0)), 200.0) and is_equal_approx(float(turret_region.get("rotation", -1.0)), 0.0) and str(turret_region.get("z", "")) == "Layer.turret" and is_equal_approx(float(flat_region.get("rotation", -1.0)), -90.0) and is_equal_approx(float(turret_draw.get("size_half", -1.0)), 1.0) and is_equal_approx(float(point_shadow.get("x", -1.0)), 99.5) and is_equal_approx(float(point_shadow.get("y", -1.0)), 199.5) and is_equal_approx(float(point_draw.get("size_half", -1.0)), 0.5)

	# --- Beam with target: a repair-turret at (0, 0),
	# rotation 90, length 6 -- origin (0, 6). Target
	# at (0, 106), hit_size 10, rotation 0, id 7;
	# building id 3, so beam_seed is 10. With zero
	# rolls the jitter is (0, 0) and lastEnd is
	# (0, 106); strength 1.0 draws the beam: f 0,
	# alpha 1, stroke 2, circle radius 1 at (0, 106),
	# laser width 1.1 from (0, 6) to (0, 106) --
	# laser at Layer.flyingUnit + 1, laserTop at
	# Layer.flyingUnit + 1.1. With roll_phase
	# 55 * PI / 2 the sin is sin(PI / 2) = 1, so the
	# magnitude roll 4.0 is the full jitter: angle 0
	# gives (4, 0), rotated by the target rotation
	# 90 to (0, 4), so lastEnd is (0, 110) and
	# offset_after is (0, 4); roll_f 0.5 gives f 0.5,
	# alpha 1 - 0.5^5 = 0.96875, circle radius
	# 1 + 0.5 * 6.1 = 4.05. A target 1.0 from the
	# origin is stretched to the min length 2
	# (lastEnd (0, 8)); a target AT the origin
	# (rotation 0, origin (6, 0)) leaves lastEnd
	# (6, 0) -- setLength is a no-op at len 0.
	var target: Dictionary = {"x": 0.0, "y": 106.0, "hit_size": 10.0, "rotation": 0.0, "id": 7}
	var beam: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 90.0, 6.0, 3, target, 1.0, 2.0, 6.1, 1.1, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 145.0, 2, 0, 0)
	var beam_call: Dictionary = beam.get("beam_call", {})
	var beam_last_end: Dictionary = beam_call.get("last_end", {})
	var beam_lasers: Array = beam_call.get("laser_calls", [])
	var jitter_rolls: Dictionary = {"roll_angle": 0.0, "roll_phase": 55.0 * PI / 2.0, "roll_magnitude": 4.0, "roll_f": 0.5}
	var jitter_target: Dictionary = {"x": 0.0, "y": 106.0, "hit_size": 10.0, "rotation": 90.0, "id": 7}
	var jittered: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 90.0, 6.0, 3, jitter_target, 1.0, 2.0, 6.1, 1.1, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, jitter_rolls, 145.0, 2, 0, 0)
	var jittered_beam: Dictionary = jittered.get("beam_call", {})
	var jittered_last_end: Dictionary = jittered_beam.get("last_end", {})
	var jittered_offset: Dictionary = jittered.get("offset_after", {})
	var close_target: Dictionary = {"x": 0.0, "y": 7.0, "hit_size": 10.0, "rotation": 0.0, "id": 7}
	var close: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 90.0, 6.0, 3, close_target, 1.0, 2.0, 6.1, 1.1, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 145.0, 2, 0, 0)
	var close_last_end: Dictionary = close.get("last_end", {})
	var origin_target: Dictionary = {"x": 6.0, "y": 0.0, "hit_size": 10.0, "rotation": 0.0, "id": 7}
	var at_origin: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 0.0, 6.0, 3, origin_target, 1.0, 2.0, 6.1, 1.1, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 145.0, 2, 0, 0)
	var at_origin_last_end: Dictionary = at_origin.get("last_end", {})
	proof["draw_beam_with_target"] = int(beam.get("beam_seed", -1)) == 10 and is_equal_approx(float(beam.get("origin_x", -1.0)), 0.0) and is_equal_approx(float(beam.get("origin_y", -1.0)), 6.0) and is_equal_approx(float(beam_last_end.get("x", -1.0)), 0.0) and is_equal_approx(float(beam_last_end.get("y", -1.0)), 106.0) and is_equal_approx(float(beam_call.get("f", -1.0)), 0.0) and is_equal_approx(float(beam_call.get("alpha", -1.0)), 1.0) and is_equal_approx(float(beam_call.get("stroke", -1.0)), 2.0) and is_equal_approx(float(beam_call.get("circle_radius", -1.0)), 1.0) and is_equal_approx(float(beam_call.get("circle_x", -1.0)), 0.0) and is_equal_approx(float(beam_call.get("circle_y", -1.0)), 106.0) and beam_lasers.size() == 2 and str(beam_lasers[0].get("line", "")) == "laser" and str(beam_lasers[0].get("edge", "")) == "laserEnd" and str(beam_lasers[0].get("color", "")) == "laserColor" and str(beam_lasers[0].get("z", "")) == "Layer.flyingUnit + 1" and is_equal_approx(float(beam_lasers[0].get("width", -1.0)), 1.1) and is_equal_approx(float(beam_lasers[0].get("x1", -1.0)), 0.0) and is_equal_approx(float(beam_lasers[0].get("y1", -1.0)), 6.0) and is_equal_approx(float(beam_lasers[0].get("x2", -1.0)), 0.0) and is_equal_approx(float(beam_lasers[0].get("y2", -1.0)), 106.0) and str(beam_lasers[1].get("line", "")) == "laserTop" and str(beam_lasers[1].get("edge", "")) == "laserTopEnd" and str(beam_lasers[1].get("color", "")) == "laserTopColor" and str(beam_lasers[1].get("z", "")) == "Layer.flyingUnit + 1.1" and is_equal_approx(float(jittered_last_end.get("x", -1.0)), 0.0) and is_equal_approx(float(jittered_last_end.get("y", -1.0)), 110.0) and is_equal_approx(float(jittered_offset.get("x", -1.0)), 0.0) and is_equal_approx(float(jittered_offset.get("y", -1.0)), 4.0) and is_equal_approx(float(jittered.get("jitter_magnitude", -1.0)), 4.0) and is_equal_approx(float(jittered_beam.get("f", -1.0)), 0.5) and is_equal_approx(float(jittered_beam.get("alpha", -1.0)), 0.96875) and is_equal_approx(float(jittered_beam.get("circle_radius", -1.0)), 4.05) and is_equal_approx(float(close_last_end.get("x", -1.0)), 0.0) and is_equal_approx(float(close_last_end.get("y", -1.0)), 8.0) and is_equal_approx(float(at_origin_last_end.get("x", -1.0)), 6.0) and is_equal_approx(float(at_origin_last_end.get("y", -1.0)), 0.0)

	# --- Weak strength: at strength 0.01 the beam
	# does NOT draw (the gate is strength > 0.01f)
	# -- beam_call is null -- but the target branch
	# still runs, so lastEnd is (0, 106). At strength
	# 0.0 the beam is null too.
	var weak: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 90.0, 6.0, 3, target, 0.01, 2.0, 6.1, 1.1, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 145.0, 2, 0, 0)
	var weak_last_end: Dictionary = weak.get("last_end", {})
	var dead: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 90.0, 6.0, 3, target, 0.0, 2.0, 6.1, 1.1, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 145.0, 2, 0, 0)
	proof["draw_beam_weak_strength"] = weak.get("beam_call", {}) == null and not bool(weak.get("has_beam", true)) and is_equal_approx(float(weak_last_end.get("x", -1.0)), 0.0) and is_equal_approx(float(weak_last_end.get("y", -1.0)), 106.0) and dead.get("beam_call", {}) == null and not bool(dead.get("has_beam", true))

	# --- Null target: with no target lastEnd holds
	# its input (5, 7) and offset holds (3, 4) -- but
	# the beam still draws at strength 1.0, at the
	# held lastEnd: roll_f 0.25 gives f 0.25, alpha
	# 1 - 0.25^5 = 0.9990234375, circle radius
	# 1 + 0.25 * 6.1 = 2.525 at (5, 7), laser from
	# (0, 6) to (5, 7). The seed is the building id
	# alone (3) -- no target id to add.
	var held_rolls: Dictionary = {"roll_angle": 0.0, "roll_phase": 0.0, "roll_magnitude": 0.0, "roll_f": 0.25}
	var held: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 90.0, 6.0, 3, null, 1.0, 2.0, 6.1, 1.1, {"x": 5.0, "y": 7.0}, {"x": 3.0, "y": 4.0}, 0.0, held_rolls, 145.0, 2, 0, 0)
	var held_beam: Dictionary = held.get("beam_call", {})
	var held_last_end: Dictionary = held.get("last_end", {})
	var held_offset: Dictionary = held.get("offset_after", {})
	var held_lasers: Array = held_beam.get("laser_calls", [])
	proof["draw_beam_target_null"] = int(held.get("beam_seed", -1)) == 3 and is_equal_approx(float(held_last_end.get("x", -1.0)), 5.0) and is_equal_approx(float(held_last_end.get("y", -1.0)), 7.0) and is_equal_approx(float(held_offset.get("x", -1.0)), 3.0) and is_equal_approx(float(held_offset.get("y", -1.0)), 4.0) and bool(held.get("has_beam", false)) and is_equal_approx(float(held_beam.get("f", -1.0)), 0.25) and is_equal_approx(float(held_beam.get("alpha", -1.0)), 0.9990234375) and is_equal_approx(float(held_beam.get("circle_radius", -1.0)), 2.525) and is_equal_approx(float(held_beam.get("circle_x", -1.0)), 5.0) and is_equal_approx(float(held_beam.get("circle_y", -1.0)), 7.0) and held_lasers.size() == 2 and is_equal_approx(float(held_lasers[0].get("x2", -1.0)), 5.0) and is_equal_approx(float(held_lasers[0].get("y2", -1.0)), 7.0)

	# --- DrawSelect / drawPlace: selecting a
	# repair-turret at (100, 200) draws the accent
	# dash circle at (100, 200), radius 145. Placing
	# at tile (10, 20) draws the accent dash circle
	# at (84, 164) for the size-2 repair-turret --
	# x * tilesize + offset with the Block offset 4.0
	# -- and at (80, 160) for the size-1 repair-point
	# (offset 0.0). The super.drawPlace call is
	# recorded on the place call.
	var selected: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(100.0, 200.0, 90.0, 6.0, 1, null, 0.0, 2.0, 6.1, 1.1, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 145.0, 2, 10, 20)
	var select_call: Dictionary = selected.get("select_call", {})
	var place_call: Dictionary = selected.get("place_call", {})
	var point_place: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 90.0, 5.0, 1, null, 0.0, 2.0, 5.0, 0.73, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 60.0, 1, 10, 20)
	var point_place_call: Dictionary = point_place.get("place_call", {})
	proof["draw_select_place"] = is_equal_approx(float(select_call.get("x", -1.0)), 100.0) and is_equal_approx(float(select_call.get("y", -1.0)), 200.0) and is_equal_approx(float(select_call.get("radius", -1.0)), 145.0) and str(select_call.get("color", "")) == "Pal.accent" and is_equal_approx(float(place_call.get("x", -1.0)), 84.0) and is_equal_approx(float(place_call.get("y", -1.0)), 164.0) and is_equal_approx(float(place_call.get("radius", -1.0)), 145.0) and str(place_call.get("color", "")) == "Pal.accent" and str(place_call.get("super", "")) == "super.drawPlace(x, y, rotation, valid);" and is_equal_approx(float(selected.get("block_offset", -1.0)), 4.0) and is_equal_approx(float(point_place_call.get("x", -1.0)), 80.0) and is_equal_approx(float(point_place_call.get("y", -1.0)), 160.0) and is_equal_approx(float(point_place.get("block_offset", -1.0)), 0.0)

	# --- Icons: [baseRegion, region], in Java order --
	# folded into the draw pure (icons() takes no args
	# and the SSOT schema validator requires non-empty
	# input keys), the two regions draw() draws.
	var icons: Dictionary = repair_turret_build_state.source_repair_turret_draw_state(0.0, 0.0, 90.0, 5.0, 1, null, 0.0, 2.0, 5.0, 0.73, {"x": 0.0, "y": 0.0}, {"x": 0.0, "y": 0.0}, 0.0, no_rolls, 60.0, 1, 0, 0)
	proof["draw_icons"] = (icons.get("icon_regions", []) as Array) == ["baseRegion", "region"]

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
