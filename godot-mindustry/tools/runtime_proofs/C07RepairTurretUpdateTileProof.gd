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

	# --- Pure advance (N2226): RepairPointBuild.updateTile()
	# (RepairTurret.java:187-218): the target clear when dead /
	# out of range / full health (RepairTurret.java:193-194),
	# the offset zero when the target is null (:197-199), the
	# heal branch (:203-210) -- angle from Angles.angle, the
	# 30-degree angleDist gate, heal amount repairSpeed *
	# strength * edelta() * multiplier, rotation slerpDelta
	# toward the angle at 0.5f * efficiency * timeScale -- the
	# strength lerpDelta toward (healed ? 1 : 0) at 0.08f *
	# Time.delta (:212), and the timer re-acquire selection
	# (:214-217) as a pure function over an explicit candidate
	# list (Units.closest = min dst2 among the damaged, valid,
	# in-range candidates). source_delta is Time.delta in ticks
	# (1.0 = one tick). The multiplier is 1.0 (power-only first
	# pass; the coolant branch waits for the coolant row). The
	# target is a Dictionary of explicit inputs: dead,
	# distance (dst - hitSize/2), health / max_health, x / y,
	# hit_size / damaged / valid. The building sits at (0, 0)
	# for the pure calls; repair-point values 0.45f / 60f.
	var dead_target: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"x": 10.0, "y": 0.0, "distance": 10.0, "dead": true, "health": 50.0, "max_health": 100.0}, "offset": {"x": 3.0, "y": 4.0}, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var dead_offset: Dictionary = dead_target.get("offset", {})
	var out_of_range: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"x": 70.0, "y": 0.0, "distance": 70.0, "dead": false, "health": 50.0, "max_health": 100.0}, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var at_range_edge: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"x": 60.0, "y": 0.0, "distance": 60.0, "dead": false, "health": 50.0, "max_health": 100.0}, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var full_health: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"x": 10.0, "y": 0.0, "distance": 10.0, "dead": false, "health": 100.0, "max_health": 100.0}, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var almost_full: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"x": 10.0, "y": 0.0, "distance": 10.0, "dead": false, "health": 99.9, "max_health": 100.0}, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var no_health_data: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"type": "dart", "x": 10.0, "y": 0.0, "distance": 10.0}, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var no_target: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": null, "offset": {"x": 3.0, "y": 4.0}, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var no_target_offset: Dictionary = no_target.get("offset", {})
	proof["target_clears_when_dead_or_out_of_range"] = dead_target.get("target", {}) == null and is_equal_approx(float(dead_offset.get("x", -1.0)), 0.0) and is_equal_approx(float(dead_offset.get("y", -1.0)), 0.0) and is_equal_approx(float(dead_target.get("heal_amount", -1.0)), 0.0) and bool(dead_target.get("healed", true)) == false and out_of_range.get("target", {}) == null and at_range_edge.get("target", null) != null and full_health.get("target", {}) == null and almost_full.get("target", null) != null and no_health_data.get("target", null) != null and no_target.get("target", {}) == null and is_equal_approx(float(no_target_offset.get("x", -1.0)), 0.0) and is_equal_approx(float(no_target_offset.get("y", -1.0)), 0.0)

	# Rotation slerps toward the target angle at 0.5 *
	# efficiency * timeScale per tick (RepairTurret.java:209):
	# from 90 toward 0 it lands on 45 after one tick; the wrap
	# takes the short way (from 350 toward 0 it lands on 355,
	# not 345); with no target or no efficiency the rotation
	# does not move (the branch gate, RepairTurret.java:203).
	var slerp_down: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"x": 10.0, "y": 0.0, "distance": 10.0, "health": 50.0, "max_health": 100.0}, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var slerp_wrap: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"x": 10.0, "y": 0.0, "distance": 10.0, "health": 50.0, "max_health": 100.0}, "strength": 0.0, "rotation": 350.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var slerp_no_power: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.0, "target": {"x": 10.0, "y": 0.0, "distance": 10.0, "health": 50.0, "max_health": 100.0}, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var slerp_no_target: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var slerp_at_angle: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"x": 10.0, "y": 0.0, "distance": 10.0, "health": 50.0, "max_health": 100.0}, "strength": 0.0, "rotation": 0.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	proof["rotation_slerps_toward_target"] = is_equal_approx(float(slerp_down.get("rotation", -1.0)), 45.0) and is_equal_approx(float(slerp_wrap.get("rotation", -1.0)), 355.0) and is_equal_approx(float(slerp_no_power.get("rotation", -1.0)), 90.0) and is_equal_approx(float(slerp_no_target.get("rotation", -1.0)), 90.0) and is_equal_approx(float(slerp_at_angle.get("rotation", -1.0)), 0.0)

	# Strength lerps toward 1 while healing and toward 0 while
	# not (RepairTurret.java:212, 0.08 * Time.delta, with the
	# lerpDelta double delta): one healing tick from 0 lands on
	# 0.08; after 60 healing ticks it is past 0.99; one idle
	# tick from 1 lands on 0.92; after 60 idle ticks it is
	# under 0.01. A target beyond the 30-degree gate does not
	# heal, so strength decays even with a target locked.
	var heal_target := {"x": 0.0, "y": 10.0, "distance": 10.0, "health": 50.0, "max_health": 100.0}
	var strength_one: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": heal_target, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var strength_frame: Dictionary = {"efficiency": 1.0, "target": heal_target, "strength": 0.0, "rotation": 90.0}
	for iteration in range(60):
		var advanced: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state(strength_frame, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
		strength_frame["target"] = advanced["target"]
		strength_frame["offset"] = advanced["offset"]
		strength_frame["strength"] = advanced["strength"]
		strength_frame["rotation"] = advanced["rotation"]
	var decay_one: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": null, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var decay_frame: Dictionary = {"efficiency": 1.0, "target": null, "strength": 1.0, "rotation": 90.0}
	for iteration in range(60):
		var decayed: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state(decay_frame, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
		decay_frame["target"] = decayed["target"]
		decay_frame["offset"] = decayed["offset"]
		decay_frame["strength"] = decayed["strength"]
		decay_frame["rotation"] = decayed["rotation"]
	var beyond_gate: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": {"x": 10.0, "y": 0.0, "distance": 10.0, "health": 50.0, "max_health": 100.0}, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	proof["strength_approaches_one_when_healing"] = is_equal_approx(float(strength_one.get("strength", -1.0)), 0.08) and bool(strength_one.get("healed", false)) and float(strength_frame.get("strength", -1.0)) > 0.99 and is_equal_approx(float(decay_one.get("strength", -1.0)), 0.92) and float(decay_frame.get("strength", -1.0)) < 0.01 and bool(beyond_gate.get("healed", true)) == false and is_equal_approx(float(beyond_gate.get("strength", -1.0)), 0.92)

	# Heal amount = repairSpeed * strength * edelta() *
	# multiplier (RepairTurret.java:207) with multiplier 1.0:
	# repair-point 0.45 * 1.0 * (0.5 * 1.0 * 1.0) = 0.225;
	# repair-turret values 3.0 * 0.5 * (1.0 * 1.0 * 2.0) =
	# 3.0 (edelta folds timeScale); half timeScale halves the
	# amount; zero strength heals zero (but still counts as
	# healing); no efficiency heals nothing.
	var heal_base: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.5, "target": heal_target, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var heal_turret: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": heal_target, "strength": 0.5, "rotation": 90.0}, 1.0, 2.0, 3.0, 145.0, 0.0, 0.0, [])
	var heal_half_scale: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": heal_target, "strength": 1.0, "rotation": 90.0}, 1.0, 0.5, 0.45, 60.0, 0.0, 0.0, [])
	var heal_no_strength: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 1.0, "target": heal_target, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var heal_no_power: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.0, "target": heal_target, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	proof["heal_amount_folds_repair_speed_strength"] = is_equal_approx(float(heal_base.get("heal_amount", -1.0)), 0.225) and is_equal_approx(float(heal_turret.get("heal_amount", -1.0)), 3.0) and is_equal_approx(float(heal_half_scale.get("heal_amount", -1.0)), 0.225) and is_equal_approx(float(heal_no_strength.get("heal_amount", -1.0)), 0.0) and bool(heal_no_strength.get("healed", false)) and is_equal_approx(float(heal_no_power.get("heal_amount", -1.0)), 0.0) and bool(heal_no_power.get("healed", true)) == false

	# Re-acquire picks the closest damaged, valid, in-range
	# candidate (Units.closest, Units.java:358-372): B at
	# dst2 100 wins over A at 900, the undamaged C, the
	# invalid D and the out-of-range E; with no qualifying
	# candidate the target is overwritten to null (Java
	# assigns unconditionally, RepairTurret.java:216); with
	# an EMPTY candidate list the target is untouched (the
	# timer did not fire); hitSize extends the reach (65 away
	# with hitSize 20 is within 60 + 10, with hitSize 0 it is
	# not); the within check is STRICT (exactly at the reach
	# is out); ties go to the first candidate (strict <).
	var candidate_a := {"x": 30.0, "y": 0.0, "hit_size": 0.0, "damaged": true, "valid": true}
	var candidate_b := {"x": 10.0, "y": 0.0, "hit_size": 0.0, "damaged": true, "valid": true}
	var candidate_c := {"x": 5.0, "y": 0.0, "hit_size": 0.0, "damaged": false, "valid": true}
	var candidate_d := {"x": 8.0, "y": 0.0, "hit_size": 0.0, "damaged": true, "valid": false}
	var candidate_e := {"x": 100.0, "y": 0.0, "hit_size": 0.0, "damaged": true, "valid": true}
	var picked: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [candidate_a, candidate_b, candidate_c, candidate_d, candidate_e])
	var picked_target: Variant = picked.get("target", null)
	var picked_x: float = float(picked_target.get("x", -1.0)) if picked_target is Dictionary else -1.0
	var none_qualify: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.0, "target": candidate_b, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [candidate_c])
	var no_query: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.0, "target": candidate_b, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [])
	var no_query_target: Variant = no_query.get("target", null)
	var no_query_x: float = float(no_query_target.get("x", -1.0)) if no_query_target is Dictionary else -1.0
	var candidate_f := {"x": 65.0, "y": 0.0, "hit_size": 20.0, "damaged": true, "valid": true}
	var reach_hit_size: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [candidate_f])
	var reach_hit_size_target: Variant = reach_hit_size.get("target", null)
	var reach_hit_size_x: float = float(reach_hit_size_target.get("x", -1.0)) if reach_hit_size_target is Dictionary else -1.0
	var candidate_g := {"x": 65.0, "y": 0.0, "hit_size": 0.0, "damaged": true, "valid": true}
	var reach_no_hit_size: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [candidate_g])
	var candidate_h := {"x": 60.0, "y": 0.0, "hit_size": 0.0, "damaged": true, "valid": true}
	var reach_boundary: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [candidate_h])
	var candidate_i := {"x": 10.0, "y": 0.0, "hit_size": 0.0, "damaged": true, "valid": true}
	var candidate_j := {"x": 0.0, "y": 10.0, "hit_size": 0.0, "damaged": true, "valid": true}
	var tie: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.45, 60.0, 0.0, 0.0, [candidate_i, candidate_j])
	var tie_target: Variant = tie.get("target", null)
	var tie_x: float = float(tie_target.get("x", -1.0)) if tie_target is Dictionary else -1.0
	proof["reacquire_picks_closest_damaged_candidate"] = is_equal_approx(picked_x, 10.0) and none_qualify.get("target", {}) == null and is_equal_approx(no_query_x, 10.0) and is_equal_approx(reach_hit_size_x, 65.0) and reach_no_hit_size.get("target", {}) == null and reach_boundary.get("target", {}) == null and is_equal_approx(tie_x, 10.0)

	# --- Live tick: a repair-point placed live at cell (28,
	# 21) -- building world position (224, 168) (tile.drawx /
	# drawy, BuildingComp.java:124, offset 0 for size 1) --
	# with a target seeded directly above it at (224, 198)
	# (angle 90, the rotation default, so the 30-degree gate
	# holds) and strength 1.0. The tick driver is called
	# directly (as the N2174/N2212 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. One 1/60s tick is one source
	# tick: the gate is true (target present), so efficiency
	# folds the power min 0.5, the heal amount is 0.45 * 1.0 *
	# 0.5 * 1.0 = 0.225, rotation stays 90, strength stays 1.
	# A second tick with the target nulled folds efficiency 0
	# (gate false), heals nothing, and decays strength to
	# 0.92. The driver passes no candidates, so no live
	# re-acquire happens.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var repair_turret_cell := Vector2i(28, 21)
	var repair_turret := Sprite2D.new()
	game.add_child(repair_turret)
	game.call("record_placed_block", repair_turret, blocks_by_id["repair-point"], repair_turret_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the target and strength on it).
	repair_turret_build_state.source_repair_turret_bind_frame_state(repair_turret, blocks_by_id["repair-point"])
	var repair_turret_frame: Dictionary = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})

	repair_turret_frame["target"] = {"x": 224.0, "y": 198.0, "distance": 30.0, "dead": false, "health": 50.0, "max_health": 100.0}
	repair_turret_frame["strength"] = 1.0
	repair_turret_frame["power_status"] = 0.5
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	repair_turret_frame = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	var live_offset: Dictionary = repair_turret_frame.get("offset", {})
	var live_first: bool = is_equal_approx(float(repair_turret_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(repair_turret_frame.get("strength", -1.0)), 1.0) and is_equal_approx(float(repair_turret_frame.get("rotation", -1.0)), 90.0) and is_equal_approx(float(repair_turret_frame.get("heal_amount", -1.0)), 0.225) and bool(repair_turret_frame.get("healed", false)) and repair_turret_frame.get("target", null) != null and is_equal_approx(float(live_offset.get("x", -1.0)), 0.0) and is_equal_approx(float(live_offset.get("y", -1.0)), 0.0)

	repair_turret_frame["target"] = null
	repair_turret_frame["power_status"] = 0.5
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	repair_turret_frame = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["live_tick_writes_advance_frame_keys"] = live_first and is_equal_approx(float(repair_turret_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(repair_turret_frame.get("strength", -1.0)), 0.92) and is_equal_approx(float(repair_turret_frame.get("rotation", -1.0)), 90.0) and is_equal_approx(float(repair_turret_frame.get("heal_amount", -1.0)), 0.0) and bool(repair_turret_frame.get("healed", true)) == false and repair_turret_frame.get("target", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
