extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
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

	# --- Pure advance (N2229): PointDefenseBuild.updateTile()
	# (PointDefenseTurret.java:62-103): the timer retarget
	# (:65-67) -- Groups.bullet RECTANGLE intersect + min raw
	# dst2, as a pure selection over an explicit bullet list
	# with a retarget_tick bool -- the pooled clear when the
	# bullet is no longer added (:70-72), the coolant branch
	# (:74-76, updateCooling, ReloadTurret.java:28-41, modeled
	# with explicit coolant params, a no-op for the segment),
	# and the look-at branch (:78-103) -- the within / team /
	# type / hittable guard, rotation moveToward at rotateSpeed
	# * edelta(), reloadCounter += edelta(), and the shot when
	# within the cone and reloaded: realDamage = bulletDamage *
	# blockDamage(team), damage > realDamage returns the
	# remaining damage as a pure result, otherwise the bullet
	# is removed (as a pure result). source_delta is
	# Time.delta in ticks (1.0 = one tick). The segment def
	# values are range 180f, bulletDamage 30f, reload 8f
	# (Blocks.java:3835-3847). The building sits at (0, 0) for
	# the pure calls; its team is derelict (0), the enemy team
	# is sharded (1) (Team.java:33-34). The target / bullet
	# dict contract: x / y, team (missing = own team), type
	# (null = no type), hittable (default true), added
	# (default true), damage.
	var bullet_a := {"x": 30.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}
	var bullet_b := {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}
	var bullet_c := {"x": 5.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": false, "added": true, "damage": 100.0}
	var bullet_d := {"x": 8.0, "y": 0.0, "team": 0, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}
	var bullet_e := {"x": 0.0, "y": 10.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}
	var picked: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": null, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [bullet_a, bullet_b, bullet_c, bullet_d], true)
	var picked_target: Variant = picked.get("target", null)
	var picked_x: float = float(picked_target.get("x", -1.0)) if picked_target is Dictionary else -1.0
	var overwrite: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": bullet_a, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [bullet_b], true)
	var overwrite_target: Variant = overwrite.get("target", null)
	var overwrite_x: float = float(overwrite_target.get("x", -1.0)) if overwrite_target is Dictionary else -1.0
	var tie: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": null, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [bullet_b, bullet_e], true)
	var tie_target: Variant = tie.get("target", null)
	var tie_x: float = float(tie_target.get("x", -1.0)) if tie_target is Dictionary else -1.0
	var tie_y: float = float(tie_target.get("y", -1.0)) if tie_target is Dictionary else -1.0
	var none_qualify: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": bullet_b, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [bullet_c, bullet_d], true)
	var no_tick: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": bullet_a, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [bullet_b], false)
	var no_tick_target: Variant = no_tick.get("target", null)
	var no_tick_x: float = float(no_tick_target.get("x", -1.0)) if no_tick_target is Dictionary else -1.0
	var empty_tick: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": bullet_a, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], true)
	# Retarget picks the closest hittable enemy bullet (B at
	# dst2 100 wins over A at 900, the unhittable C and the
	# same-team D); a retarget tick overwrites a held target
	# (Java assigns unconditionally, PointDefenseTurret.java:
	# 66); ties go to the LAST candidate (Seq.min's `if(val <=
	# min){`, Seq.java:329 -- B and E share dst2 100, E wins);
	# with no qualifying bullet the target is overwritten to
	# null; with retarget_tick false the target is untouched
	# (the timer did not fire); an empty list on a tick clears
	# the target (min over an empty Seq is null).
	proof["retarget_picks_closest_hittable_bullet"] = is_equal_approx(picked_x, 10.0) and is_equal_approx(overwrite_x, 10.0) and is_equal_approx(tie_x, 0.0) and is_equal_approx(tie_y, 10.0) and none_qualify.get("target", {}) == null and is_equal_approx(no_tick_x, 30.0) and empty_tick.get("target", {}) == null

	# A pooled target clears: the bullet with added false is
	# nulled, and the look-at branch never runs (rotation and
	# reloadCounter untouched). An added target is kept (and
	# the look-at runs: rotation 90 -> 70 toward (10, 0),
	# reloadCounter 3 -> 4). A target without an `added` key
	# defaults to added and is kept. A retargeted bullet that
	# is pooled clears in the same tick (retarget first, then
	# the pooled clear, PointDefenseTurret.java:65-72).
	var pooled: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": false, "damage": 100.0}, "rotation": 90.0, "reload_counter": 3.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var kept: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 3.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var no_added_key: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var retargeted_pooled: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": null, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [{"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": false, "damage": 100.0}], true)
	proof["pooled_target_clears"] = pooled.get("target", {}) == null and is_equal_approx(float(pooled.get("rotation", -1.0)), 90.0) and is_equal_approx(float(pooled.get("reload_counter", -1.0)), 3.0) and kept.get("target", null) != null and is_equal_approx(float(kept.get("rotation", -1.0)), 70.0) and is_equal_approx(float(kept.get("reload_counter", -1.0)), 4.0) and no_added_key.get("target", null) != null and retargeted_pooled.get("target", {}) == null

	# Rotation moves toward the target at rotateSpeed *
	# edelta() (PointDefenseTurret.java:81, rotateSpeed 20f):
	# from 90 toward 0 it lands on 70 after one tick at full
	# efficiency; the wrap takes the short way (from 350
	# toward 0 at quarter efficiency it lands on 355, not
	# 345); at the target angle it stays; with no efficiency
	# it stays; out of range (200 away) it stays; exactly at
	# range (180 away) it stays -- the within is STRICT
	# (Position.java:44-46, dst2 < range^2); just inside
	# (179 away) it moves; a same-team target, a null type,
	# or an unhittable target all fail the guard and the
	# rotation stays.
	var move_down: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var move_wrap: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.25, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 350.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var at_angle: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 0.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var no_power: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var out_of_range: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 200.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var at_edge: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 180.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var just_inside: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 179.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var same_team: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 0, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var no_type: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": null, "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var not_hittable: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": false, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	proof["rotation_moves_toward_target"] = is_equal_approx(float(move_down.get("rotation", -1.0)), 70.0) and is_equal_approx(float(move_down.get("reload_counter", -1.0)), 1.0) and is_equal_approx(float(move_wrap.get("rotation", -1.0)), 355.0) and is_equal_approx(float(at_angle.get("rotation", -1.0)), 0.0) and is_equal_approx(float(no_power.get("rotation", -1.0)), 90.0) and is_equal_approx(float(out_of_range.get("rotation", -1.0)), 90.0) and is_equal_approx(float(at_edge.get("rotation", -1.0)), 90.0) and is_equal_approx(float(just_inside.get("rotation", -1.0)), 70.0) and is_equal_approx(float(same_team.get("rotation", -1.0)), 90.0) and is_equal_approx(float(no_type.get("rotation", -1.0)), 90.0) and is_equal_approx(float(not_hittable.get("rotation", -1.0)), 90.0)

	# reloadCounter charges by edelta() while looking at a
	# target (PointDefenseTurret.java:82) and fires when
	# within the 5-degree cone and reloaded (reload 8f,
	# :85-86): one tick at full efficiency charges 0 -> 1,
	# half efficiency charges 0 -> 0.5; from 7.5 at full
	# efficiency the counter reaches 8.5 and fires, resetting
	# to 0; out of the cone (rotation 70 after the move,
	# angleDist 70 > 5) the counter still charges to 8.5 but
	# does not fire; with no target the counter does not move.
	# Cooling (updateCooling, ReloadTurret.java:28-41) charges
	# amount * edelta() * capacity * coolantMultiplier * 1.0
	# with amount = coolant.amount * coolant.efficiency: 2.0 *
	# 0.5 * 1.0 * 1.0 * 2.0 * 1.0 = 2.0; it is blocked when
	# already reloaded (canReload, reloadCounter < reload)
	# and absent without coolant or without efficiency.
	var above_target := {"x": 0.0, "y": 10.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}
	var charge: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": above_target, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var charge_half: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.5, "team_id": 0, "target": above_target, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var fire: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": above_target, "rotation": 90.0, "reload_counter": 7.5}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var out_of_cone: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 7.5}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var no_target_charge: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": null, "rotation": 90.0, "reload_counter": 3.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var cooling: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": null, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false, 1.0, true, 2.0, 0.5, 1.0)
	var cooling_blocked: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": null, "rotation": 90.0, "reload_counter": 8.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false, 1.0, true, 2.0, 0.5, 1.0)
	var no_coolant: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": null, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var cooling_no_power: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": null, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false, 1.0, true, 2.0, 0.5, 1.0)
	proof["reload_counter_charges_and_fires"] = is_equal_approx(float(charge.get("reload_counter", -1.0)), 1.0) and bool(charge.get("fired", true)) == false and is_equal_approx(float(charge_half.get("reload_counter", -1.0)), 0.5) and bool(fire.get("fired", false)) and is_equal_approx(float(fire.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(out_of_cone.get("reload_counter", -1.0)), 8.5) and bool(out_of_cone.get("fired", true)) == false and is_equal_approx(float(no_target_charge.get("reload_counter", -1.0)), 3.0) and is_equal_approx(float(cooling.get("reload_counter", -1.0)), 2.0) and is_equal_approx(float(cooling_blocked.get("reload_counter", -1.0)), 8.0) and is_equal_approx(float(no_coolant.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(cooling_no_power.get("reload_counter", -1.0)), 0.0)

	# A shot against a strong bullet reduces its damage pool:
	# damage 100 - realDamage 30 = 70 remaining, not removed,
	# fired, counter reset to 0. With blockDamageMultiplier
	# 2.0 the realDamage is 60, so 100 - 60 = 40 remains. A
	# shot that does not fire (out of the cone) leaves no
	# remaining damage and removes nothing.
	var reduce: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": above_target, "rotation": 90.0, "reload_counter": 7.5}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var reduce_remaining: Variant = reduce.get("target_damage_remaining", null)
	var reduce_doubled: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": above_target, "rotation": 90.0, "reload_counter": 7.5}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false, 2.0)
	var reduce_doubled_remaining: Variant = reduce_doubled.get("target_damage_remaining", null)
	var no_fire_reduce: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}, "rotation": 90.0, "reload_counter": 7.5}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	proof["shot_reduces_bullet_damage"] = reduce_remaining != null and is_equal_approx(float(reduce_remaining), 70.0) and bool(reduce.get("target_removed", true)) == false and bool(reduce.get("fired", false)) and is_equal_approx(float(reduce.get("reload_counter", -1.0)), 0.0) and reduce_doubled_remaining != null and is_equal_approx(float(reduce_doubled_remaining), 40.0) and no_fire_reduce.get("target_damage_remaining", -1.0) == null and bool(no_fire_reduce.get("target_removed", true)) == false and bool(no_fire_reduce.get("fired", true)) == false

	# A shot against a weak bullet removes it: damage 20 <=
	# realDamage 30, so target_removed is true and there is no
	# remaining damage; the target field itself stays set
	# (Java keeps it -- `target.remove();` only un-adds the
	# bullet, and the pooled clear nulls it next tick). The
	# boundary is strict: damage exactly 30 is NOT greater
	# than realDamage 30, so it is removed too. A weak bullet
	# out of the cone is not shot and not removed.
	var remove: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 0.0, "y": 10.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 20.0}, "rotation": 90.0, "reload_counter": 7.5}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var boundary: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 0.0, "y": 10.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 30.0}, "rotation": 90.0, "reload_counter": 7.5}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var weak_no_fire: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "target": {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 20.0}, "rotation": 90.0, "reload_counter": 7.5}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	proof["shot_removes_weak_bullet"] = bool(remove.get("target_removed", false)) and remove.get("target_damage_remaining", -1.0) == null and bool(remove.get("fired", false)) and is_equal_approx(float(remove.get("reload_counter", -1.0)), 0.0) and remove.get("target", null) != null and bool(boundary.get("target_removed", false)) and boundary.get("target_damage_remaining", -1.0) == null and bool(weak_no_fire.get("target_removed", true)) == false and bool(weak_no_fire.get("fired", true)) == false

	# --- Live tick: a segment placed live at cell (28, 20) --
	# building world position (228, 164) (tile.drawx / drawy,
	# BuildingComp.java:124, offset 4 for size 2) -- with a
	# bullet seeded directly above it at (228, 194) (angle 90,
	# the rotation default, so the 5-degree cone holds) and
	# damage 20. The placed segment is sharded (team 1, the
	# record_placed_block default), so the bullet is crux
	# (team 2, Team.java:35) -- an enemy bullet. The tick driver is called directly (as the
	# N2151/N2217 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. One 1/60s tick is one source tick: the gate
	# is true (target present), so efficiency folds the power
	# min 0.5, the reload counter charges 0 -> 0.5, rotation
	# stays 90, nothing fires yet. A second tick with the
	# counter seeded at 7.6 charges it to 8.1 and fires:
	# realDamage 30 >= damage 20, so the bullet is removed
	# (pure result), the counter resets to 0, and the target
	# field stays set until the pooled clear. The driver
	# passes retarget_tick false and no bullets, so no live
	# retarget happens.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var segment_cell := Vector2i(28, 20)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["segment"], segment_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the target and reload counter on it).
	point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment, blocks_by_id["segment"])
	var segment_frame: Dictionary = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})

	segment_frame["target"] = {"x": 228.0, "y": 194.0, "team": 2, "type": "bullet", "hittable": true, "added": true, "damage": 20.0}
	segment_frame["power_status"] = 0.5
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	segment_frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var live_first: bool = is_equal_approx(float(segment_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(segment_frame.get("reload_counter", -1.0)), 0.5) and is_equal_approx(float(segment_frame.get("rotation", -1.0)), 90.0) and bool(segment_frame.get("fired", true)) == false and bool(segment_frame.get("target_removed", true)) == false and segment_frame.get("target_damage_remaining", -1.0) == null and segment_frame.get("target", null) != null

	segment_frame["reload_counter"] = 7.6
	segment_frame["power_status"] = 0.5
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	segment_frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["live_tick_writes_advance_frame_keys"] = live_first and is_equal_approx(float(segment_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(segment_frame.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(segment_frame.get("rotation", -1.0)), 90.0) and bool(segment_frame.get("fired", false)) and bool(segment_frame.get("target_removed", false)) and segment_frame.get("target_damage_remaining", -1.0) == null and segment_frame.get("target", null) != null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
