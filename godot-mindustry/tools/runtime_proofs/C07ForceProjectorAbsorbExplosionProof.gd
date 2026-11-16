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

	# --- Pure absorbExplosion (N2423):
	# ForceBuild.absorbExplosion()
	# (ForceProjector.java:269-277), the ExplosionShield
	# method -- ForceBuild implements ExplosionShield
	# (ForceProjector.java:164), called from explosion
	# handling (Damage.explode, Damage.java:113; the unit
	# crash path, UnitComp.java:906), NOT from updateTile,
	# so there is no tick wiring: pure-only, like the draw
	# rows. The gate is `boolean absorb = !broken &&
	# Intersector.isInRegularPolygon(sides, x, y,
	# realRadius(), shieldRotation, ex, ey);` (:270) --
	# the SAME polygon test deflectBullets uses, so the
	# pure REUSEs the N2235 isInRegularPolygon port. On
	# absorb ONLY: hit is set to 1f (:273) and buildup
	# grows by damage * crashDamageMultiplier (:274, 2f,
	# :45; the absorbEffect.at FX at :272 defers, not
	# modeled). The pure reports hit_value (1f on absorb,
	# the incoming hit otherwise) PLUS a hit_set flag
	# (true only on absorb). real_radius is an explicit
	# input: the caller supplies the N2235 advance's
	# real_radius result ((radius + phaseHeat *
	# phaseRadiusBoost) * radscl, :280) -- 101.7 here
	# (radius 101.7f, phaseHeat 0, radscl 1.0). The shield
	# is a 6-sided regular polygon of radius 101.7 at
	# rotation 0f, centered on the building at (0, 0)
	# (apothem 88.07): (50, 50) is inside, (95, 50) is
	# inside the 2x rect but OUTSIDE the hexagon (its
	# 30-degree projection 107.27 exceeds the apothem),
	# (0, 95) is outside at rotation 0 (above the top edge
	# at y = 88.07) but inside at rotation 30 (the vertex
	# then points straight up to y = 101.7).

	# Absorb fires inside the hexagon: at the center, at
	# (50, 50), at (0, 95) with rotation 30, and at the
	# center of a building offset to (224, 160) -- each
	# with hit set to 1f and the buildup delta damage * 2f.
	var absorb_center: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	var absorb_inside: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 50.0, 50.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	var absorb_rotated: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 95.0, 5.0, 6, 0.0, 0.0, 101.7, 30.0, 0.0)
	var absorb_offset: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 224.0, 160.0, 10.0, 6, 224.0, 160.0, 101.7, 0.0, 0.0)
	proof["absorb_true_inside_polygon"] = bool(absorb_center.get("absorb", false)) and bool(absorb_center.get("hit_set", false)) and is_equal_approx(float(absorb_center.get("hit_value", -1.0)), 1.0) and is_equal_approx(float(absorb_center.get("buildup_delta", -1.0)), 20.0) and bool(absorb_inside.get("absorb", false)) and is_equal_approx(float(absorb_inside.get("buildup_delta", -1.0)), 20.0) and bool(absorb_rotated.get("absorb", false)) and is_equal_approx(float(absorb_rotated.get("buildup_delta", -1.0)), 10.0) and bool(absorb_offset.get("absorb", false)) and is_equal_approx(float(absorb_offset.get("buildup_delta", -1.0)), 20.0)

	# Absorb does NOT fire outside the hexagon: far away
	# at (200, 0), at (95, 50) inside the rect but outside
	# the polygon, at (0, 95) with rotation 0, or anywhere
	# when the radius is 0 (the polygon degenerates to a
	# point). Hit keeps its incoming value (0.6 here) and
	# the buildup delta is 0.
	var outside_far: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 200.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.6)
	var outside_corner: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 95.0, 50.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.6)
	var outside_top: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 95.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.6)
	var outside_zero_radius: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 10.0, 6, 0.0, 0.0, 0.0, 0.0, 0.6)
	proof["absorb_false_outside_polygon"] = bool(outside_far.get("absorb", true)) == false and bool(outside_far.get("hit_set", true)) == false and is_equal_approx(float(outside_far.get("hit_value", -1.0)), 0.6) and is_equal_approx(float(outside_far.get("buildup_delta", -1.0)), 0.0) and bool(outside_corner.get("absorb", true)) == false and is_equal_approx(float(outside_corner.get("buildup_delta", -1.0)), 0.0) and bool(outside_top.get("absorb", true)) == false and is_equal_approx(float(outside_top.get("buildup_delta", -1.0)), 0.0) and bool(outside_zero_radius.get("absorb", true)) == false and is_equal_approx(float(outside_zero_radius.get("buildup_delta", -1.0)), 0.0)

	# A broken shield absorbs nothing, even dead center:
	# the !broken half of the gate fails first.
	var broken_center: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(true, 0.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.6)
	var broken_inside: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(true, 50.0, 50.0, 100.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	proof["absorb_false_when_broken"] = bool(broken_center.get("absorb", true)) == false and bool(broken_center.get("hit_set", true)) == false and is_equal_approx(float(broken_center.get("hit_value", -1.0)), 0.6) and is_equal_approx(float(broken_center.get("buildup_delta", -1.0)), 0.0) and bool(broken_inside.get("absorb", true)) == false and is_equal_approx(float(broken_inside.get("buildup_delta", -1.0)), 0.0)

	# The buildup math is damage * crashDamageMultiplier
	# (2f): 10 -> 20, 7.5 -> 15, 100 -> 200. The
	# multiplier is an explicit input, so a proof can vary
	# it: 10 at 3.0 -> 30, 10 at 0.5 -> 5.
	var delta_ten: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	var delta_seven_half: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 7.5, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	var delta_hundred: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 100.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	var delta_triple: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0, 3.0)
	var delta_half: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0, 0.5)
	proof["buildup_delta_math"] = is_equal_approx(float(delta_ten.get("buildup_delta", -1.0)), 20.0) and is_equal_approx(float(delta_seven_half.get("buildup_delta", -1.0)), 15.0) and is_equal_approx(float(delta_hundred.get("buildup_delta", -1.0)), 200.0) and is_equal_approx(float(delta_triple.get("buildup_delta", -1.0)), 30.0) and is_equal_approx(float(delta_half.get("buildup_delta", -1.0)), 5.0)

	# Hit is set to 1f exactly when absorb fires -- from
	# 0.0 and from 0.6 alike. When absorb does not fire,
	# hit keeps its incoming value and hit_set is false:
	# the flag is what distinguishes a fresh set from a hit
	# that was already 1f (incoming 1.0, outside: hit_value
	# 1.0, hit_set false).
	var hit_from_zero: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	var hit_from_half: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.6)
	var hit_kept: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 200.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.6)
	var hit_already_one: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 200.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 1.0)
	proof["hit_set"] = bool(hit_from_zero.get("hit_set", false)) and is_equal_approx(float(hit_from_zero.get("hit_value", -1.0)), 1.0) and bool(hit_from_half.get("hit_set", false)) and is_equal_approx(float(hit_from_half.get("hit_value", -1.0)), 1.0) and bool(hit_kept.get("hit_set", true)) == false and is_equal_approx(float(hit_kept.get("hit_value", -1.0)), 0.6) and bool(hit_already_one.get("hit_set", true)) == false and is_equal_approx(float(hit_already_one.get("hit_value", -1.0)), 1.0)

	# Edge: zero damage still absorbs (the gate never
	# checks damage) and still sets hit -- but the buildup
	# delta is 0 * 2f = 0. A zero-damage explosion outside
	# the polygon still does nothing at all.
	var zero_inside: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 0.0, 0.0, 0.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	var zero_outside: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 200.0, 0.0, 0.0, 6, 0.0, 0.0, 101.7, 0.0, 0.4)
	proof["edge_damage_zero"] = bool(zero_inside.get("absorb", false)) and bool(zero_inside.get("hit_set", false)) and is_equal_approx(float(zero_inside.get("hit_value", -1.0)), 1.0) and is_equal_approx(float(zero_inside.get("buildup_delta", -1.0)), 0.0) and bool(zero_outside.get("absorb", true)) == false and bool(zero_outside.get("hit_set", true)) == false and is_equal_approx(float(zero_outside.get("hit_value", -1.0)), 0.4) and is_equal_approx(float(zero_outside.get("buildup_delta", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ForceProjectorAbsorbExplosionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
