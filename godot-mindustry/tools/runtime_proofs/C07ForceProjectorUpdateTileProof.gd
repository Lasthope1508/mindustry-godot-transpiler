extends Node

const main_scene := preload("res://scenes/Main.tscn")
const force_projector_build_state := preload("res://src/game/SourceForceProjectorBuildState.gd")
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

	# --- Pure advance (N2235): ForceBuild.updateTile()
	# (ForceProjector.java:207-268): the phaseValid /
	# phaseHeat fold (:208-210), the consume gate (:212-214,
	# timer cadence + consume() application deferred,
	# reported as a pure `consumed` result), the radscl fold
	# toward the OLD warmup (:216, before the warmup update
	# at :222), the buildup cooldown with the coolant branch
	# (:224-237, explicit coolant inputs), the broken clear
	# (:239-241) and set (:243-251, threshold folds the NEW
	# phaseHeat), the hit decay (:253-255, Time.delta, not
	# delta()), and deflectBullets (:257-268) through the
	# faithfully ported Intersector.isInRegularPolygon, with
	# the absorbed bullets + buildup delta as pure results
	# (no live bullet is written). source_delta is Time.delta
	# in ticks (1.0 = one tick). The force-projector def
	# values are shieldHealth 750f, cooldownNormal 1.5f,
	# cooldownLiquid 1.2f, cooldownBrokenBase 0.35f, radius
	# 101.7f, phaseRadiusBoost 80f, phaseShieldBoost 400f,
	# sides 6, shieldRotation 0f (Blocks.java:1964-1976, the
	# DEF wins over the class defaults 700f / 1.75f / 1.5f).
	# The building sits at (0, 0) for the pure calls; its
	# team is derelict (0), the enemy team is sharded (1)
	# (Team.java:33-34). The bullet dict contract: x / y,
	# team (missing = own team), absorbable (default true),
	# absorbed (default false), shield_damage (default 0.0),
	# id (default: the bullet's index in the list).
	var base_frame := {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}

	# phaseHeat lerps toward num(phaseValid) at 0.1f: from 0
	# with a valid booster it rises to 0.1; from 0.5 with an
	# invalid booster (efficiency 0, or no item consumer at
	# all) it falls to 0.45. The consume gate reports
	# through the pure consumed result: it fires only when
	# phaseValid && !broken && consume_tick && efficiency >
	# 0 -- no tick, a broken shield (the INCOMING broken,
	# before the clear), no power, or an invalid booster all
	# leave it false.
	var heat_up: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(base_frame, 1.0, 1.0, 0.0, 0.0, [], false, true, 1.0)
	var heat_down: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.5, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false, true, 0.0)
	var heat_absent: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.5, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false, false, 1.0)
	var consume_fires: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(base_frame, 1.0, 1.0, 0.0, 0.0, [], true, true, 1.0)
	var consume_no_tick: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(base_frame, 1.0, 1.0, 0.0, 0.0, [], false, true, 1.0)
	var consume_broken: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 10.0, "broken": true, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], true, true, 1.0)
	var consume_no_power: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], true, true, 1.0)
	var consume_invalid: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(base_frame, 1.0, 1.0, 0.0, 0.0, [], true, true, 0.0)
	proof["phase_heat_tracks_booster"] = is_equal_approx(float(heat_up.get("phase_heat", -1.0)), 0.1) and bool(heat_up.get("consumed", true)) == false and is_equal_approx(float(heat_down.get("phase_heat", -1.0)), 0.45) and is_equal_approx(float(heat_absent.get("phase_heat", -1.0)), 0.45) and bool(consume_fires.get("consumed", false)) and is_equal_approx(float(consume_fires.get("phase_heat", -1.0)), 0.1) and bool(consume_no_tick.get("consumed", true)) == false and bool(consume_broken.get("consumed", true)) == false and bool(consume_no_power.get("consumed", true)) == false and bool(consume_invalid.get("consumed", true)) == false

	# radscl lerps toward warmup at 0.05f (0 -> 0.05 from
	# warmup 1.0) and toward 0 when broken (0.5 -> 0.475);
	# it folds the OLD warmup -- with warmup 0 and full
	# efficiency it stays 0 while warmup rises to 0.1 (the
	# :216-before-:222 ordering). Warmup lerps toward the
	# folded efficiency at 0.1f: 0.5 -> 0.55 at full power,
	# 0.5 -> 0.45 at no power.
	var radscl_up: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 1.0, "buildup": 0.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var radscl_broken: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.5, "warmup": 1.0, "buildup": 10.0, "broken": true, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var radscl_old_warmup: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var warmup_up: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.5, "buildup": 0.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var warmup_down: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.5, "buildup": 0.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	proof["radscl_follows_warmup"] = is_equal_approx(float(radscl_up.get("radscl", -1.0)), 0.05) and is_equal_approx(float(radscl_up.get("warmup", -1.0)), 0.9) and is_equal_approx(float(radscl_broken.get("radscl", -1.0)), 0.475) and is_equal_approx(float(radscl_old_warmup.get("radscl", -1.0)), 0.0) and is_equal_approx(float(radscl_old_warmup.get("warmup", -1.0)), 0.1) and is_equal_approx(float(warmup_up.get("warmup", -1.0)), 0.55) and is_equal_approx(float(warmup_down.get("warmup", -1.0)), 0.45)

	# Buildup cools by delta() * scale: 10 -> 8.5 unbroken
	# (cooldownNormal 1.5f), 10 -> 9.65 broken
	# (cooldownBrokenBase 0.35f). The coolant branch folds
	# cooldownLiquid * (1 + (heatCapacity - 0.4) * 0.9):
	# with heatCapacity 0.5 the scale is 1.5 * 1.2 * 1.09 =
	# 1.962, so 10 -> 8.038; with the 0.4 baseline the scale
	# is 1.5 * 1.2 = 1.8, so 10 -> 8.2. The branch needs the
	# coolant present AND its efficiency above 0, or it
	# cools at the plain rate. timeScale scales the decay
	# (delta() = Time.delta * timeScale): at timeScale 2 the
	# unbroken decay is 3.0, so 10 -> 7.0. A broken shield
	# with buildup 0.2 decays to -0.15 -- buildup has NO
	# clamp -- and the negative buildup clears broken. At
	# buildup 0 there is no decay at all.
	var cool_normal: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 10.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var cool_broken: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 10.0, "broken": true, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var cool_liquid: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 10.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false, false, 0.0, true, 1.0, 0.5)
	var cool_liquid_baseline: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 10.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false, false, 0.0, true, 1.0, 0.4)
	var cool_no_eff: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 10.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false, false, 0.0, true, 0.0, 0.5)
	var cool_absent: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 10.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false, false, 0.0, false, 1.0, 0.5)
	var cool_timescale: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 10.0, "broken": false, "hit": 0.0}, 1.0, 2.0, 0.0, 0.0, [], false)
	var broken_clears: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.2, "broken": true, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var no_decay_at_zero: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(base_frame, 1.0, 1.0, 0.0, 0.0, [], false)
	proof["buildup_cools_down"] = is_equal_approx(float(cool_normal.get("buildup", -1.0)), 8.5) and is_equal_approx(float(cool_broken.get("buildup", -1.0)), 9.65) and bool(cool_broken.get("broken", false)) and is_equal_approx(float(cool_liquid.get("buildup", -1.0)), 8.038) and is_equal_approx(float(cool_liquid_baseline.get("buildup", -1.0)), 8.2) and is_equal_approx(float(cool_no_eff.get("buildup", -1.0)), 8.5) and is_equal_approx(float(cool_absent.get("buildup", -1.0)), 8.5) and is_equal_approx(float(cool_timescale.get("buildup", -1.0)), 7.0) and bool(broken_clears.get("broken", true)) == false and is_equal_approx(float(broken_clears.get("buildup", -1.0)), -0.15) and is_equal_approx(float(no_decay_at_zero.get("buildup", -1.0)), 0.0)

	# Broken sets when buildup >= shieldHealth +
	# phaseShieldBoost * phaseHeat (750f def): 752 decays to
	# 750.5 and breaks, resetting buildup to exactly 750;
	# 749 decays to 747.5 and holds; 751.5 decays to exactly
	# 750.0 and breaks (>=, not >). With phaseHeat 1.0 the
	# threshold is 1150: 1152 breaks, 1151 holds. An
	# already-broken shield keeps its buildup (799.65 after
	# the broken-rate decay) -- the !broken guard blocks the
	# reset.
	var breaks: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 752.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var holds: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 749.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var boundary: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 751.5, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	var breaks_boosted: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 1.0, "radscl": 0.0, "warmup": 0.0, "buildup": 1152.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false, true, 1.0)
	var holds_boosted: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 1.0, "radscl": 0.0, "warmup": 0.0, "buildup": 1151.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false, true, 1.0)
	var stays_broken: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 800.0, "broken": true, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], false)
	proof["broken_sets_at_shield_health"] = bool(breaks.get("broken", false)) and is_equal_approx(float(breaks.get("buildup", -1.0)), 750.0) and bool(holds.get("broken", true)) == false and is_equal_approx(float(holds.get("buildup", -1.0)), 747.5) and bool(boundary.get("broken", false)) and is_equal_approx(float(boundary.get("buildup", -1.0)), 750.0) and bool(breaks_boosted.get("broken", false)) and is_equal_approx(float(breaks_boosted.get("buildup", -1.0)), 750.0) and bool(holds_boosted.get("broken", true)) == false and is_equal_approx(float(holds_boosted.get("buildup", -1.0)), 1149.5) and bool(stays_broken.get("broken", false)) and is_equal_approx(float(stays_broken.get("buildup", -1.0)), 799.65)

	# Deflect: the shield is a 6-sided regular polygon of
	# radius realRadius = (101.7 + phaseHeat * 80) * radscl =
	# 101.7 at radscl 1.0. An enemy bullet at the center and
	# one at (50, 50) are inside and absorbed (buildup delta
	# 10 + 5 = 15, hit set to 1.0); a bullet at (95, 50) is
	# inside the 2x rect but OUTSIDE the hexagon (its
	# 30-degree projection 107.27 exceeds the apothem 88.07)
	# and is not absorbed; a bullet at (200, 0) is outside
	# entirely; a same-team bullet, a non-absorbable bullet,
	# and an already-absorbed bullet at the center are all
	# skipped. A bullet with no absorbable / absorbed /
	# shield_damage / id keys defaults to absorbable, not
	# absorbed, 0 damage, and its list index as id. Absorbed
	# buildup does NOT break the shield this tick (deflect
	# runs after the broken check): 745 decays to 743.5,
	# then +10 takes it to 753.5 with broken still false.
	# With a broken shield (realRadius 96.615 > 0) or a zero
	# radius (radscl 0) nothing deflects and hit just decays
	# (0.6 -> 0.4); with no bullets hit decays the same way.
	var shield_frame := {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 1.0, "warmup": 1.0, "buildup": 0.0, "broken": false, "hit": 0.0}
	var bullet_center := {"id": "center", "x": 0.0, "y": 0.0, "team": 1, "absorbable": true, "absorbed": false, "shield_damage": 10.0}
	var bullet_inside := {"id": "inside", "x": 50.0, "y": 50.0, "team": 1, "absorbable": true, "absorbed": false, "shield_damage": 5.0}
	var bullet_corner := {"id": "corner", "x": 95.0, "y": 50.0, "team": 1, "absorbable": true, "absorbed": false, "shield_damage": 7.0}
	var bullet_far := {"id": "far", "x": 200.0, "y": 0.0, "team": 1, "absorbable": true, "absorbed": false, "shield_damage": 3.0}
	var bullet_ally := {"id": "ally", "x": 0.0, "y": 0.0, "team": 0, "absorbable": true, "absorbed": false, "shield_damage": 10.0}
	var bullet_heavy := {"id": "heavy", "x": 0.0, "y": 0.0, "team": 1, "absorbable": false, "absorbed": false, "shield_damage": 10.0}
	var bullet_spent := {"id": "spent", "x": 0.0, "y": 0.0, "team": 1, "absorbable": true, "absorbed": true, "shield_damage": 10.0}
	var deflect: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(shield_frame, 1.0, 1.0, 0.0, 0.0, [bullet_center, bullet_inside, bullet_corner, bullet_far, bullet_ally, bullet_heavy, bullet_spent], false)
	var no_keys: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(shield_frame, 1.0, 1.0, 0.0, 0.0, [{"x": 10.0, "y": 0.0, "team": 1}], false)
	var deflect_no_break: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 1.0, "warmup": 1.0, "buildup": 745.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [bullet_center], false)
	var deflect_broken: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 1.0, "warmup": 1.0, "buildup": 10.0, "broken": true, "hit": 0.6}, 1.0, 1.0, 0.0, 0.0, [bullet_center], false)
	var deflect_zero_radius: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.6}, 1.0, 1.0, 0.0, 0.0, [bullet_center], false)
	var hit_decay: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 1.0, "warmup": 1.0, "buildup": 0.0, "broken": false, "hit": 0.6}, 1.0, 1.0, 0.0, 0.0, [], false)
	var hit_set: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 1.0, "warmup": 1.0, "buildup": 0.0, "broken": false, "hit": 0.6}, 1.0, 1.0, 0.0, 0.0, [bullet_center], false)
	proof["deflect_absorbs_bullet_in_polygon"] = deflect.get("absorbed_bullets", []) == ["center", "inside"] and is_equal_approx(float(deflect.get("buildup_delta", -1.0)), 15.0) and is_equal_approx(float(deflect.get("buildup", -1.0)), 15.0) and is_equal_approx(float(deflect.get("hit", -1.0)), 1.0) and is_equal_approx(float(deflect.get("real_radius", -1.0)), 101.7) and no_keys.get("absorbed_bullets", []) == [0] and is_equal_approx(float(no_keys.get("buildup_delta", -1.0)), 0.0) and bool(deflect_no_break.get("broken", true)) == false and is_equal_approx(float(deflect_no_break.get("buildup", -1.0)), 753.5) and deflect_broken.get("absorbed_bullets", [-1]) == [] and is_equal_approx(float(deflect_broken.get("hit", -1.0)), 0.4) and is_equal_approx(float(deflect_broken.get("real_radius", -1.0)), 96.615) and deflect_zero_radius.get("absorbed_bullets", [-1]) == [] and is_equal_approx(float(deflect_zero_radius.get("real_radius", -1.0)), 0.0) and is_equal_approx(float(hit_decay.get("hit", -1.0)), 0.4) and is_equal_approx(float(hit_set.get("hit", -1.0)), 1.0)

	# --- Live tick: a force-projector placed live at cell
	# (28, 20) -- building world position (224, 160)
	# (tile.drawx / drawy, BuildingComp.java:124, offset 0
	# for size 3) -- with the advance keys seeded (radscl
	# 0.2, warmup 0.5, buildup 10, hit 0.6, unbroken) and
	# power_status stamped 0.5. The tick driver is called
	# directly (as the N2158/N2229 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is
	# one source tick: efficiency folds the power min 0.5,
	# phaseHeat stays 0 (the driver passes no item state),
	# radscl lerps 0.2 -> 0.215 toward the old warmup 0.5,
	# warmup stays 0.5 (already at the folded efficiency),
	# buildup cools 10 -> 8.5, hit decays 0.6 -> 0.4,
	# nothing is consumed or absorbed (the driver passes
	# consume_tick false and no bullets), and real_radius is
	# 101.7 * 0.215 = 21.8655. A second tick at no power
	# folds efficiency 0: warmup 0.5 -> 0.45, radscl 0.215
	# -> 0.22925, buildup 8.5 -> 7.0, hit 0.4 -> 0.2.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var projector_cell := Vector2i(28, 20)
	var projector := Sprite2D.new()
	game.add_child(projector)
	game.call("record_placed_block", projector, blocks_by_id["force-projector"], projector_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# seed the advance keys on it).
	force_projector_build_state.source_force_projector_bind_frame_state(projector, blocks_by_id["force-projector"])
	var projector_frame: Dictionary = projector.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})

	projector_frame["phase_heat"] = 0.0
	projector_frame["radscl"] = 0.2
	projector_frame["warmup"] = 0.5
	projector_frame["buildup"] = 10.0
	projector_frame["broken"] = false
	projector_frame["hit"] = 0.6
	projector_frame["power_status"] = 0.5
	force_projector_build_state.source_force_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	var live_first: bool = is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(projector_frame.get("phase_heat", -1.0)), 0.0) and is_equal_approx(float(projector_frame.get("radscl", -1.0)), 0.215) and is_equal_approx(float(projector_frame.get("warmup", -1.0)), 0.5) and is_equal_approx(float(projector_frame.get("buildup", -1.0)), 8.5) and bool(projector_frame.get("broken", true)) == false and is_equal_approx(float(projector_frame.get("hit", -1.0)), 0.4) and bool(projector_frame.get("consumed", true)) == false and projector_frame.get("absorbed_bullets", [-1]) == [] and is_equal_approx(float(projector_frame.get("buildup_delta", -1.0)), 0.0) and is_equal_approx(float(projector_frame.get("real_radius", -1.0)), 21.8655)

	projector_frame["power_status"] = 0.0
	force_projector_build_state.source_force_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	proof["live_tick_writes_advance_frame_keys"] = live_first and is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(projector_frame.get("phase_heat", -1.0)), 0.0) and is_equal_approx(float(projector_frame.get("radscl", -1.0)), 0.22925) and is_equal_approx(float(projector_frame.get("warmup", -1.0)), 0.45) and is_equal_approx(float(projector_frame.get("buildup", -1.0)), 7.0) and bool(projector_frame.get("broken", true)) == false and is_equal_approx(float(projector_frame.get("hit", -1.0)), 0.2) and bool(projector_frame.get("consumed", true)) == false and projector_frame.get("absorbed_bullets", [-1]) == [] and is_equal_approx(float(projector_frame.get("buildup_delta", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ForceProjectorUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
