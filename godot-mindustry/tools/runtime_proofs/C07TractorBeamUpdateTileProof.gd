extends Node

const main_scene := preload("res://scenes/Main.tscn")
const tractor_beam_turret_build_state := preload("res://src/game/SourceTractorBeamTurretBuildState.gd")
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

	# --- Pure advance (N2230): TractorBeamBuild.updateTile()
	# (TractorBeamTurret.java:78-139): the activation early
	# return (:79-82), the eff/edelta fold (:84), the retarget
	# through Units.closestEnemy with its PRIORITY semantics
	# (:87-90, Units.java:296-313), the coolant consume
	# (:92-106, null for parallax, modeled with explicit
	# inputs), the look-at guard (:111), the rotation
	# moveToward + lastX/lastY + strength lerpDelta (:116-120),
	# the shoot cone (:123) with the damage / status / impulse
	# as PURE RESULTS, and the strength decay (:134-136).
	# source_delta is Time.delta in ticks (1.0 = one tick).
	# The building sits at (0, 0) for the pure calls, team 1
	# (sharded); candidates are enemy team 2 (crux). Parallax
	# values: force 16f, scaledForce 9f, range 300f, damage
	# 0.5f, rotateSpeed 12, shootCone 6f.
	var candidate_a := {"x": 100.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var candidate_b := {"x": 50.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var candidate_grounded := {"x": 10.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": false, "grounded": true, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var candidate_dead := {"x": 5.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": true, "targetable": true, "in_fog": false}
	var candidate_derelict := {"x": 20.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 0, "dead": false, "targetable": true, "in_fog": false}
	var candidate_far := {"x": 400.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var candidate_fog := {"x": 15.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": true}
	var candidate_untargetable := {"x": 30.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": false, "in_fog": false}
	var retarget_list: Array = [candidate_a, candidate_b, candidate_grounded, candidate_dead, candidate_derelict, candidate_far, candidate_fog, candidate_untargetable]
	var picked: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, retarget_list, true, false, 0.0, 0.0, 0.0, 1.0, false)
	var picked_target: Variant = picked.get("target", null)
	var picked_x: float = float(picked_target.get("x", -1.0)) if picked_target is Dictionary else -1.0
	var no_tick: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": candidate_a, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, retarget_list, false, false, 0.0, 0.0, 0.0, 1.0, false)
	var no_tick_target: Variant = no_tick.get("target", null)
	var no_tick_x: float = float(no_tick_target.get("x", -1.0)) if no_tick_target is Dictionary else -1.0
	var empty_tick: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": candidate_b, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], true, false, 0.0, 0.0, 0.0, 1.0, false)
	var derelict_team: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 0, retarget_list, true, false, 0.0, 0.0, 0.0, 1.0, false)
	proof["retarget_picks_closest_flying_enemy"] = is_equal_approx(picked_x, 50.0) and is_equal_approx(no_tick_x, 100.0) and empty_tick.get("target", {}) == null and derelict_team.get("target", {}) == null

	# Priority beats distance (Units.java:296-313): the far
	# priority-1 unit wins over the near priority-0 unit in
	# EITHER list order; equal priority needs strictly closer
	# (the near one wins); ties go to the first candidate
	# (strict <); dst2 subtracts hitSize squared (60 away
	# with hitSize 20 scores 3200, beating 57 away with
	# hitSize 0 at 3249); exactly at range is out (strict <).
	var near_low := {"x": 50.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var far_high := {"x": 100.0, "y": 0.0, "hit_size": 0.0, "target_priority": 1.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var priority_first: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [near_low, far_high], true, false, 0.0, 0.0, 0.0, 1.0, false)
	var priority_first_target: Variant = priority_first.get("target", null)
	var priority_first_x: float = float(priority_first_target.get("x", -1.0)) if priority_first_target is Dictionary else -1.0
	var priority_second: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [far_high, near_low], true, false, 0.0, 0.0, 0.0, 1.0, false)
	var priority_second_target: Variant = priority_second.get("target", null)
	var priority_second_x: float = float(priority_second_target.get("x", -1.0)) if priority_second_target is Dictionary else -1.0
	var far_low := {"x": 100.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var equal_priority: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [far_low, near_low], true, false, 0.0, 0.0, 0.0, 1.0, false)
	var equal_priority_target: Variant = equal_priority.get("target", null)
	var equal_priority_x: float = float(equal_priority_target.get("x", -1.0)) if equal_priority_target is Dictionary else -1.0
	var tie_a := {"x": 10.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var tie_b := {"x": 0.0, "y": 10.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var tie: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [tie_a, tie_b], true, false, 0.0, 0.0, 0.0, 1.0, false)
	var tie_target: Variant = tie.get("target", null)
	var tie_x: float = float(tie_target.get("x", -1.0)) if tie_target is Dictionary else -1.0
	var hit_size_big := {"x": 60.0, "y": 0.0, "hit_size": 20.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var hit_size_none := {"x": 57.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var hit_size_wins: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [hit_size_none, hit_size_big], true, false, 0.0, 0.0, 0.0, 1.0, false)
	var hit_size_target: Variant = hit_size_wins.get("target", null)
	var hit_size_x: float = float(hit_size_target.get("x", -1.0)) if hit_size_target is Dictionary else -1.0
	var at_range := {"x": 300.0, "y": 0.0, "hit_size": 0.0, "target_priority": 0.0, "flying": true, "grounded": false, "team": 2, "dead": false, "targetable": true, "in_fog": false}
	var at_range_edge: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [at_range], true, false, 0.0, 0.0, 0.0, 1.0, false)
	proof["priority_beats_distance"] = is_equal_approx(priority_first_x, 100.0) and is_equal_approx(priority_second_x, 100.0) and is_equal_approx(equal_priority_x, 50.0) and is_equal_approx(tie_x, 10.0) and is_equal_approx(hit_size_x, 60.0) and at_range_edge.get("target", {}) == null

	# Rotation moves toward the target angle at rotateSpeed *
	# edelta (TractorBeamTurret.java:117): from 90 toward 0 it
	# lands on 78 after one tick at full efficiency (12 * 1.0)
	# and on 66 with coolantMultiplier 2.0 (12 * 2.0); already
	# aimed it stays, strength rises 0 -> 0.1 in one tick and
	# past 0.99 after 60 ticks, damage is 0.5 * eff *
	# timeScale * blockDamage (0.5 base, 1.0 with the doubled
	# multiplier), any is true, status is not applied
	# (parallax status is none), and lastX/lastY track the
	# target. The guard fails on low efficiency (0.01 <=
	# 0.02), an out-of-range target, a same-team target, and a
	# grounded target -- strength decays instead. hitSize
	# extends the reach (305 away with hitSize 20 is within
	# 300 + 10; with hitSize 0 it is not).
	var above_target := {"x": 0.0, "y": 100.0, "hit_size": 0.0, "flying": true, "grounded": false, "team": 2}
	var aimed: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": above_target, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var aimed_last: Dictionary = aimed.get("last_target_position", {})
	var east_target := {"x": 100.0, "y": 0.0, "hit_size": 0.0, "flying": true, "grounded": false, "team": 2}
	var turning: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": east_target, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var turning_boosted: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "coolant_multiplier": 2.0, "target": east_target, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var aimed_boosted: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "coolant_multiplier": 2.0, "target": above_target, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var strength_frame: Dictionary = {"efficiency": 1.0, "target": above_target, "strength": 0.0, "rotation": 90.0}
	for iteration in range(60):
		var advanced: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state(strength_frame, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
		strength_frame["target"] = advanced["target"]
		strength_frame["rotation"] = advanced["rotation"]
		strength_frame["strength"] = advanced["strength"]
	var low_power: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.01, "target": above_target, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var far_target := {"x": 400.0, "y": 0.0, "hit_size": 0.0, "flying": true, "grounded": false, "team": 2}
	var out_of_range: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": far_target, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var friendly_target := {"x": 0.0, "y": 100.0, "hit_size": 0.0, "flying": true, "grounded": false, "team": 1}
	var friendly: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": friendly_target, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var ground_target := {"x": 0.0, "y": 100.0, "hit_size": 0.0, "flying": false, "grounded": true, "team": 2}
	var grounded: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": ground_target, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var edge_big := {"x": 305.0, "y": 0.0, "hit_size": 20.0, "flying": true, "grounded": false, "team": 2}
	var edge_reached: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": edge_big, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var edge_small := {"x": 305.0, "y": 0.0, "hit_size": 0.0, "flying": true, "grounded": false, "team": 2}
	var edge_missed: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": edge_small, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	proof["rotation_moves_and_strength_rises"] = is_equal_approx(float(aimed.get("rotation", -1.0)), 90.0) and is_equal_approx(float(aimed.get("strength", -1.0)), 0.1) and is_equal_approx(float(aimed.get("damage_dealt", -1.0)), 0.5) and bool(aimed.get("any", false)) and bool(aimed.get("status_applied", true)) == false and is_equal_approx(float(aimed_last.get("x", -1.0)), 0.0) and is_equal_approx(float(aimed_last.get("y", -1.0)), 100.0) and is_equal_approx(float(turning.get("rotation", -1.0)), 78.0) and is_equal_approx(float(turning.get("strength", -1.0)), 0.1) and is_equal_approx(float(turning.get("damage_dealt", -1.0)), 0.0) and bool(turning.get("any", true)) == false and is_equal_approx(float(turning_boosted.get("rotation", -1.0)), 66.0) and is_equal_approx(float(aimed_boosted.get("damage_dealt", -1.0)), 1.0) and float(strength_frame.get("strength", -1.0)) > 0.99 and is_equal_approx(float(low_power.get("strength", -1.0)), 0.9) and is_equal_approx(float(low_power.get("damage_dealt", -1.0)), 0.0) and is_equal_approx(float(out_of_range.get("strength", -1.0)), 0.9) and is_equal_approx(float(out_of_range.get("rotation", -1.0)), 90.0) and is_equal_approx(float(friendly.get("strength", -1.0)), 0.9) and is_equal_approx(float(grounded.get("strength", -1.0)), 0.9) and is_equal_approx(float(edge_reached.get("rotation", -1.0)), 78.0) and is_equal_approx(float(edge_missed.get("strength", -1.0)), 0.9)

	# Impulse = (building - target) limited to (force + (1 -
	# dst / range) * scaledForce) * edelta
	# (TractorBeamTurret.java:132): at 100 away the limit is
	# (16 + (1 - 100/300) * 9) * 1.0 = 22, so the (-100, 0)
	# vector clamps to (-22, 0); at 10 away the limit is 24.7
	# but the (-10, 0) vector is shorter, so it is NOT clamped
	# -- limit clamps the length, it does not set it; at half
	# efficiency the limit halves to 11; at timeScale 2 the
	# limit doubles to 44 and the damage doubles to 1.0; the
	# block-damage multiplier scales the damage only (2.0 ->
	# 1.0), never the impulse.
	var impulse_far: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": east_target, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var impulse_far_vec: Dictionary = impulse_far.get("impulse", {})
	var near_target := {"x": 10.0, "y": 0.0, "hit_size": 0.0, "flying": true, "grounded": false, "team": 2}
	var impulse_near: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": near_target, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var impulse_near_vec: Dictionary = impulse_near.get("impulse", {})
	var impulse_half: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.5, "target": east_target, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var impulse_half_vec: Dictionary = impulse_half.get("impulse", {})
	var impulse_scaled: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": east_target, "strength": 1.0, "rotation": 0.0}, 1.0, 2.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var impulse_scaled_vec: Dictionary = impulse_scaled.get("impulse", {})
	var damage_doubled: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": east_target, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 2.0, false)
	var damage_doubled_vec: Dictionary = damage_doubled.get("impulse", {})
	proof["impulse_folds_force_and_range"] = is_equal_approx(float(impulse_far_vec.get("x", 0.0)), -22.0) and is_equal_approx(float(impulse_far_vec.get("y", -1.0)), 0.0) and is_equal_approx(float(impulse_far.get("damage_dealt", -1.0)), 0.5) and is_equal_approx(float(impulse_near_vec.get("x", 0.0)), -10.0) and is_equal_approx(float(impulse_near_vec.get("y", -1.0)), 0.0) and is_equal_approx(float(impulse_half_vec.get("x", 0.0)), -11.0) and is_equal_approx(float(impulse_half.get("damage_dealt", -1.0)), 0.25) and is_equal_approx(float(impulse_scaled_vec.get("x", 0.0)), -44.0) and is_equal_approx(float(impulse_scaled.get("damage_dealt", -1.0)), 1.0) and is_equal_approx(float(damage_doubled.get("damage_dealt", -1.0)), 1.0) and is_equal_approx(float(damage_doubled_vec.get("x", 0.0)), -22.0)

	# Coolant consume (TractorBeamTurret.java:92-106): used =
	# min(min(held, maxUsed * Time.delta), max(0, (1 /
	# coolantMultiplier) / heatCapacity)); the multiplier
	# becomes 1 + used * heatCapacity * multiplier. With
	# held 10, amount 0.1, heat 0.5, multiplier 1.0: used
	# 0.1, multiplier 1.05 -- and this tick's damage still
	# uses the INCOMING multiplier (0.5, not 0.525), because
	# eff is computed at :84 before the coolant branch. With
	# held 0 the used is 0 and the multiplier resets to 1.0
	# from 2.0 (the :105 formula itself yields 1f). With the
	# heat cap binding (held 10, amount 10, heat 0.5): used
	# 2.0, multiplier 2.0. With the held cap binding (held
	# 0.05): used 0.05, multiplier 1.025. Without coolant
	# the multiplier persists at 2.0 and used is 0; without
	# a target the branch never runs.
	var coolant_base: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": east_target, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, true, 0.1, 10.0, 0.5, 1.0, false)
	var coolant_empty: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "coolant_multiplier": 2.0, "target": east_target, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, true, 0.1, 0.0, 0.5, 1.0, false)
	var coolant_heat_cap: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": east_target, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, true, 10.0, 10.0, 0.5, 1.0, false)
	var coolant_held_cap: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": east_target, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, true, 10.0, 0.05, 0.5, 1.0, false)
	var coolant_absent: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "coolant_multiplier": 2.0, "target": east_target, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var coolant_no_target: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "coolant_multiplier": 2.0, "target": null, "strength": 1.0, "rotation": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, true, 0.1, 10.0, 0.5, 1.0, false)
	proof["coolant_consume_folds_heat_capacity"] = is_equal_approx(float(coolant_base.get("coolant_used", -1.0)), 0.1) and is_equal_approx(float(coolant_base.get("coolant_multiplier", -1.0)), 1.05) and is_equal_approx(float(coolant_base.get("damage_dealt", -1.0)), 0.5) and is_equal_approx(float(coolant_empty.get("coolant_used", -1.0)), 0.0) and is_equal_approx(float(coolant_empty.get("coolant_multiplier", -1.0)), 1.0) and is_equal_approx(float(coolant_heat_cap.get("coolant_used", -1.0)), 2.0) and is_equal_approx(float(coolant_heat_cap.get("coolant_multiplier", -1.0)), 2.0) and is_equal_approx(float(coolant_held_cap.get("coolant_used", -1.0)), 0.05) and is_equal_approx(float(coolant_held_cap.get("coolant_multiplier", -1.0)), 1.025) and is_equal_approx(float(coolant_absent.get("coolant_used", -1.0)), 0.0) and is_equal_approx(float(coolant_absent.get("coolant_multiplier", -1.0)), 2.0) and is_equal_approx(float(coolant_no_target.get("coolant_used", -1.0)), 0.0) and is_equal_approx(float(coolant_no_target.get("coolant_multiplier", -1.0)), 2.0)

	# Strength decays toward 0 without a target
	# (TractorBeamTurret.java:134-136): one tick from 1 lands
	# on 0.9; after 60 ticks it is under 0.01; rotation,
	# lastX/lastY, the coolant multiplier and the activation
	# timer are untouched; no damage, no impulse, any false.
	var decay_one: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "target": null, "strength": 1.0, "rotation": 45.0, "last_x": 5.0, "last_y": 6.0, "coolant_multiplier": 1.5, "activation_timer": 0.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var decay_one_last: Dictionary = decay_one.get("last_target_position", {})
	var decay_one_impulse: Dictionary = decay_one.get("impulse", {})
	var decay_frame: Dictionary = {"efficiency": 1.0, "target": null, "strength": 1.0, "rotation": 90.0}
	for iteration in range(60):
		var decayed: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state(decay_frame, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
		decay_frame["target"] = decayed["target"]
		decay_frame["rotation"] = decayed["rotation"]
		decay_frame["strength"] = decayed["strength"]
	proof["strength_decays_without_target"] = is_equal_approx(float(decay_one.get("strength", -1.0)), 0.9) and float(decay_frame.get("strength", -1.0)) < 0.01 and is_equal_approx(float(decay_one.get("rotation", -1.0)), 45.0) and is_equal_approx(float(decay_one_last.get("x", -1.0)), 5.0) and is_equal_approx(float(decay_one_last.get("y", -1.0)), 6.0) and is_equal_approx(float(decay_one.get("coolant_multiplier", -1.0)), 1.5) and is_equal_approx(float(decay_one.get("activation_timer", -1.0)), 0.0) and is_equal_approx(float(decay_one.get("damage_dealt", -1.0)), 0.0) and is_equal_approx(float(decay_one_impulse.get("x", -1.0)), 0.0) and is_equal_approx(float(decay_one_impulse.get("y", -1.0)), 0.0) and bool(decay_one.get("any", true)) == false

	# Activation blocks the whole update
	# (TractorBeamTurret.java:79-82): with the timer at 5.0
	# one tick decrements it to 4.0 and NOTHING else moves --
	# no retarget even with retarget_tick true and candidates,
	# no rotation, no strength change in EITHER direction (the
	# early return skips the decay branch too), any keeps its
	# previous value (the return skips the `any = false;`
	# reset), no coolant, no damage. The decrement has no
	# clamp (0.5 - 1.0 = -0.5), and a zero timer proceeds.
	var blocked: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "activation_timer": 5.0, "target": east_target, "strength": 0.5, "rotation": 90.0, "any": true, "coolant_multiplier": 1.5}, 1.0, 1.0, 0.0, 0.0, 1, retarget_list, true, true, 0.1, 10.0, 0.5, 1.0, false)
	var blocked_target: Variant = blocked.get("target", null)
	var blocked_x: float = float(blocked_target.get("x", -1.0)) if blocked_target is Dictionary else -1.0
	var blocked_last: Dictionary = blocked.get("last_target_position", {})
	var underflow: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "activation_timer": 0.5, "target": null, "strength": 1.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var unblocked: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 1.0, "activation_timer": 0.0, "target": above_target, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], false, false, 0.0, 0.0, 0.0, 1.0, false)
	proof["activation_timer_blocks_update"] = is_equal_approx(float(blocked.get("activation_timer", -1.0)), 4.0) and is_equal_approx(blocked_x, 100.0) and is_equal_approx(float(blocked.get("rotation", -1.0)), 90.0) and is_equal_approx(float(blocked.get("strength", -1.0)), 0.5) and bool(blocked.get("any", false)) and is_equal_approx(float(blocked.get("coolant_multiplier", -1.0)), 1.5) and is_equal_approx(float(blocked.get("coolant_used", -1.0)), 0.0) and is_equal_approx(float(blocked.get("damage_dealt", -1.0)), 0.0) and is_equal_approx(float(blocked_last.get("x", -1.0)), 0.0) and is_equal_approx(float(blocked_last.get("y", -1.0)), 0.0) and is_equal_approx(float(underflow.get("activation_timer", -1.0)), -0.5) and is_equal_approx(float(underflow.get("strength", -1.0)), 1.0) and is_equal_approx(float(unblocked.get("strength", -1.0)), 0.1)

	# --- Live tick: a parallax placed live at cell (28, 21)
	# -- building world position (228, 172) (tile.drawx /
	# drawy, BuildingComp.java:124, offset 4 for size 2) --
	# with a flying enemy target seeded directly above it at
	# (228, 202) (angle 90, the rotation default, so the
	# 6-degree shoot cone holds) and strength 1.0. The tick
	# driver is called directly (as the N2152/N2218 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is
	# one source tick: the gate is true (target present), so
	# efficiency folds the power min 0.5, the damage is 0.5 *
	# 0.5 * 1.0 * 1.0 = 0.25, the impulse is (0, -12.05)
	# ((16 + (1 - 30/300) * 9) * 0.5 = 12.05, clamping the
	# (0, -30) vector), rotation stays 90, strength stays 1,
	# lastX/lastY track the target, any is true. A second
	# tick with the target nulled folds efficiency 0 (gate
	# false), pulls nothing, and decays strength to 0.9. The
	# retarget cadence is live since N2317 (the frame-local
	# Interval, 5f), but the two ticks here only accumulate
	# the clock to 2.0 -- below the threshold -- so no live
	# retarget fires inside this proof.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var parallax_cell := Vector2i(28, 21)
	var parallax := Sprite2D.new()
	game.add_child(parallax)
	game.call("record_placed_block", parallax, blocks_by_id["parallax"], parallax_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the target and strength on it).
	tractor_beam_turret_build_state.source_tractor_beam_turret_bind_frame_state(parallax, blocks_by_id["parallax"])
	var parallax_frame: Dictionary = parallax.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})

	parallax_frame["target"] = {"x": 228.0, "y": 202.0, "hit_size": 0.0, "flying": true, "grounded": false, "team": 2}
	parallax_frame["strength"] = 1.0
	parallax_frame["power_status"] = 0.5
	tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)
	parallax_frame = parallax.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	var live_impulse: Dictionary = parallax_frame.get("impulse", {})
	var live_first: bool = is_equal_approx(float(parallax_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(parallax_frame.get("strength", -1.0)), 1.0) and is_equal_approx(float(parallax_frame.get("rotation", -1.0)), 90.0) and is_equal_approx(float(parallax_frame.get("damage_dealt", -1.0)), 0.25) and bool(parallax_frame.get("any", false)) and bool(parallax_frame.get("status_applied", true)) == false and is_equal_approx(float(live_impulse.get("x", -1.0)), 0.0) and is_equal_approx(float(live_impulse.get("y", 0.0)), -12.05) and is_equal_approx(float(parallax_frame.get("last_x", -1.0)), 228.0) and is_equal_approx(float(parallax_frame.get("last_y", -1.0)), 202.0) and parallax_frame.get("target", null) != null and is_equal_approx(float(parallax_frame.get("activation_timer", -1.0)), 0.0) and is_equal_approx(float(parallax_frame.get("coolant_multiplier", -1.0)), 1.0) and is_equal_approx(float(parallax_frame.get("coolant_used", -1.0)), 0.0)

	parallax_frame["target"] = null
	parallax_frame["power_status"] = 0.5
	tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)
	parallax_frame = parallax.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	proof["live_tick_writes_advance_frame_keys"] = live_first and is_equal_approx(float(parallax_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(parallax_frame.get("strength", -1.0)), 0.9) and is_equal_approx(float(parallax_frame.get("rotation", -1.0)), 90.0) and is_equal_approx(float(parallax_frame.get("damage_dealt", -1.0)), 0.0) and bool(parallax_frame.get("any", true)) == false and parallax_frame.get("target", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TractorBeamUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
