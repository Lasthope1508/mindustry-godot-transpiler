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

	# --- absorbExplosion absorbEffect FX row (N2482):
	# ForceBuild.absorbExplosion()
	# (ForceProjector.java:269-277) fires
	# `absorbEffect.at(ex, ey);` (:272) when the
	# gate `boolean absorb = !broken &&
	# Intersector.isInRegularPolygon(sides, x, y,
	# realRadius(), shieldRotation, ex, ey);`
	# (:270) holds. The gate / hit / buildup are
	# live since N2423 (the pure
	# source_force_projector_absorb_explosion_state),
	# so this pure consumes the caller-supplied
	# absorb verdict (the N2423 pure's absorb
	# result key) and reports the effect as a pure
	# call record (the N2469 precedent -- no effect
	# spawned): absorb_effect_call {effect
	# "Fx.absorb", ex, ey} when absorb is true,
	# null otherwise (the N2397 null-when-absent
	# precedent). The effect is Fx.absorb
	# (`public Effect absorbEffect = Fx.absorb;`,
	# ForceProjector.java:49; `absorb = new
	# Effect(12, e -> {`, Fx.java:1356) and the
	# single force-projector def does NOT override
	# it (Blocks.java:1964-1976). The shield is a
	# 6-sided regular polygon of radius 101.7 at
	# rotation 0f, centered on the building at
	# (0, 0) (apothem 88.07): (50, 50) is inside,
	# (200, 0) is outside (the N2423 fixtures).
	# The shieldConsumer bullet path is a
	# DIFFERENT call site (ForceProjector.java:
	# 64-65, absorbEffect.at(bullet) + hitSound.at)
	# -- it defers under its own entry, not this
	# pure.

	# --- FX fires on absorb: absorb true at
	# (50, 50) records the Fx.absorb call at
	# exactly (50, 50).
	var fired: Dictionary = force_projector_build_state.source_force_projector_absorb_effect_state(true, 50.0, 50.0)
	var fired_call: Dictionary = fired.get("absorb_effect_call", {})
	proof["fx_on_absorb"] = str(fired_call.get("effect", "")) == "Fx.absorb" and is_equal_approx(float(fired_call.get("ex", -1.0)), 50.0) and is_equal_approx(float(fired_call.get("ey", -1.0)), 50.0)

	# --- FX is null when not absorbed: absorb
	# false records no call -- even at a
	# different position, so the coords alone
	# never fire the effect (the N2397
	# null-when-absent precedent).
	var idle: Dictionary = force_projector_build_state.source_force_projector_absorb_effect_state(false, 50.0, 50.0)
	var idle_moved: Dictionary = force_projector_build_state.source_force_projector_absorb_effect_state(false, 123.5, -45.25)
	proof["fx_null_when_not_absorbed"] = idle.get("absorb_effect_call", {}) == null and idle_moved.get("absorb_effect_call", {}) == null

	# --- Position: the effect lands at exactly
	# (ex, ey) -- (123.5, -45.25) here, and
	# (0, 0) at the building center; the pure
	# passes the explosion position through
	# untouched, with no offset or rounding.
	var placed: Dictionary = force_projector_build_state.source_force_projector_absorb_effect_state(true, 123.5, -45.25).get("absorb_effect_call", {})
	var placed_center: Dictionary = force_projector_build_state.source_force_projector_absorb_effect_state(true, 0.0, 0.0).get("absorb_effect_call", {})
	proof["fx_position"] = is_equal_approx(float(placed.get("ex", -1.0)), 123.5) and is_equal_approx(float(placed.get("ey", -1.0)), -45.25) and is_equal_approx(float(placed_center.get("ex", -1.0)), 0.0) and is_equal_approx(float(placed_center.get("ey", -1.0)), 0.0)

	# --- Token: the effect token is exactly
	# "Fx.absorb" (the N2469 "Fx.<name>" call-
	# record convention) -- not the bare "absorb",
	# not another Fx effect.
	var tokened: Dictionary = force_projector_build_state.source_force_projector_absorb_effect_state(true, 10.0, 20.0).get("absorb_effect_call", {})
	proof["fx_token"] = str(tokened.get("effect", "")) == "Fx.absorb" and str(tokened.get("effect", "")) != "absorb"

	# --- Broken: a broken shield absorbs nothing,
	# so no effect fires -- the live N2423 gate
	# runs first (broken true at the center keeps
	# hit at its incoming 0.6 and the buildup delta
	# at 0) and its absorb verdict (false) feeds
	# this pure, which records null.
	var broken_gate: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(true, 0.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.6)
	var broken_fx: Dictionary = force_projector_build_state.source_force_projector_absorb_effect_state(bool(broken_gate.get("absorb", true)), 0.0, 0.0)
	proof["fx_broken"] = bool(broken_gate.get("absorb", true)) == false and is_equal_approx(float(broken_gate.get("hit_value", -1.0)), 0.6) and is_equal_approx(float(broken_gate.get("buildup_delta", -1.0)), 0.0) and broken_fx.get("absorb_effect_call", {}) == null

	# --- Live input: the N2423 absorb verdict is
	# the input -- a live inside-polygon explosion
	# at (50, 50) absorbs (hit set to 1f, buildup
	# delta damage * 2f = 20.0) and the effect
	# fires at (50, 50); a live outside-polygon
	# explosion at (200, 0) does not absorb and
	# the effect is null.
	var live_gate: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 50.0, 50.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	var live_fx: Dictionary = force_projector_build_state.source_force_projector_absorb_effect_state(bool(live_gate.get("absorb", false)), 50.0, 50.0)
	var live_call: Dictionary = live_fx.get("absorb_effect_call", {})
	var live_miss_gate: Dictionary = force_projector_build_state.source_force_projector_absorb_explosion_state(false, 200.0, 0.0, 10.0, 6, 0.0, 0.0, 101.7, 0.0, 0.0)
	var live_miss_fx: Dictionary = force_projector_build_state.source_force_projector_absorb_effect_state(bool(live_miss_gate.get("absorb", true)), 200.0, 0.0)
	proof["fx_live_input"] = bool(live_gate.get("absorb", false)) and bool(live_gate.get("hit_set", false)) and is_equal_approx(float(live_gate.get("hit_value", -1.0)), 1.0) and is_equal_approx(float(live_gate.get("buildup_delta", -1.0)), 20.0) and str(live_call.get("effect", "")) == "Fx.absorb" and is_equal_approx(float(live_call.get("ex", -1.0)), 50.0) and is_equal_approx(float(live_call.get("ey", -1.0)), 50.0) and bool(live_miss_gate.get("absorb", true)) == false and live_miss_fx.get("absorb_effect_call", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ForceProjectorAbsorbEffectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
