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

	# --- RepairTurret drawBeam pulse phase (N2252):
	# The pulse is the FOURTH Rand draw from the same seeded
	# sequence as the N2251 jitter draws (`rand.setSeed(id +
	# (target instanceof Entityc e ? e.id() : 0));`,
	# RepairTurret.java:111): `float f = (Time.time / 85f +
	# rand.random(1f)) % 1f;` (RepairTurret.java:138),
	# `Draw.alpha(1f - Interp.pow5In.apply(f));`
	# (RepairTurret.java:140), `Lines.stroke(strength *
	# pulseStroke);` (RepairTurret.java:141),
	# `Lines.circle(lastEnd.x, lastEnd.y, 1f + f *
	# pulseRadius);` (RepairTurret.java:142), inside the
	# strength guard (`if(strength > 0.01f){`,
	# RepairTurret.java:129). Interp.pow5In is PowIn(5)
	# (Interp.java:45), apply(a) = pow(a, 5)
	# (Interp.java:119-121), so alpha = 1 - f^5. Time.time is
	# the tick counter (Time.java:15, 60fps units). The proof
	# calls the pure function with explicit params (no live
	# tick: the frame carries no absolute tick or fourth Rand
	# draw yet, so there is no driver line). The oracle draws
	# below are the Python-model vectors, verified live in
	# Godot by the N2251 probe before that slice was built.

	# Time 0, fourth draw 0.350668 (seed-10 oracle r4),
	# strength 1, pulseStroke 2, pulseRadius 6: f = 0.350668,
	# alpha = 1 - 0.350668^5 = 0.994698, stroke = 2,
	# circle radius = 1 + 0.350668 * 6 = 3.104008.
	var base: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(1.0, 2.0, 6.0, 0.0, 0.350668)
	proof["pulse_f_matches_formula"] = is_equal_approx(float(base.get("f", -1.0)), 0.350668) and is_equal_approx(float(base.get("alpha", -1.0)), 0.994698) and is_equal_approx(float(base.get("stroke", -1.0)), 2.0) and is_equal_approx(float(base.get("circle_radius", -1.0)), 3.104008)

	# f wraps mod 1: at time 85 (one full 85-tick cycle) with
	# draw 0.5, f = (1 + 0.5) % 1 = 0.5, same as time 0.
	var wrapped: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(1.0, 2.0, 6.0, 85.0, 0.5)
	var half: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(1.0, 2.0, 6.0, 0.0, 0.5)
	proof["pulse_f_wraps_mod_1"] = is_equal_approx(float(wrapped.get("f", -1.0)), 0.5) and is_equal_approx(float(wrapped.get("f", -1.0)), float(half.get("f", -2.0))) and is_equal_approx(float(wrapped.get("alpha", -1.0)), float(half.get("alpha", -2.0)))

	# alpha is 1 - f^5: f = 0.5 gives alpha = 0.96875; at
	# time 42.5 with draw 0.350668, f = 0.850668 and alpha =
	# 1 - 0.850668^5 = 0.554548.
	var later: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(1.0, 2.0, 6.0, 42.5, 0.350668)
	proof["pulse_alpha_is_one_minus_f_pow5"] = is_equal_approx(float(half.get("alpha", -1.0)), 0.96875) and is_equal_approx(float(later.get("f", -1.0)), 0.850668) and is_equal_approx(float(later.get("alpha", -1.0)), 0.554548)

	# The stroke scales with strength: strength 0.5 gives
	# stroke 1, strength 0.25 gives stroke 0.5 (pulseStroke
	# 2).
	var weak: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(0.5, 2.0, 6.0, 0.0, 0.350668)
	var weaker: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(0.25, 2.0, 6.0, 0.0, 0.350668)
	proof["pulse_stroke_scales_with_strength"] = is_equal_approx(float(weak.get("stroke", -1.0)), 1.0) and is_equal_approx(float(weaker.get("stroke", -1.0)), 0.5) and is_equal_approx(float(base.get("stroke", -1.0)), 2.0)

	# The circle radius grows with f: draw 0 gives radius 1
	# (the circle's minimum), draw 0.5 gives 4, draw
	# 0.350668 gives 3.104008 (pulseRadius 6).
	var zero: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(1.0, 2.0, 6.0, 0.0, 0.0)
	proof["pulse_circle_radius_grows_with_f"] = is_equal_approx(float(zero.get("circle_radius", -1.0)), 1.0) and is_equal_approx(float(half.get("circle_radius", -1.0)), 4.0) and is_equal_approx(float(base.get("circle_radius", -1.0)), 3.104008)

	# The fourth draw is the seed-10 oracle r4: replay the
	# seeded sequence (building id 7 + target id 3) through
	# the N2251 xorshift helpers -- r1 257.980828, r2
	# 38.301969, r3 3.00842, r4 0.350668 -- and the pulse at
	# time 0 with that draw has f = 0.350668.
	var rand_state: Dictionary = repair_turret_build_state.source_arc_rand_xorshift_set_seed(7 + 3)
	var oracle_r1: float = repair_turret_build_state.source_arc_rand_xorshift_random_max(rand_state, 360.0)
	var oracle_r2: float = repair_turret_build_state.source_arc_rand_xorshift_random_max(rand_state, 200.0)
	var oracle_r3: float = repair_turret_build_state.source_arc_rand_xorshift_random_range(rand_state, 2.0, 4.5)
	var oracle_r4: float = repair_turret_build_state.source_arc_rand_xorshift_random_max(rand_state, 1.0)
	var seeded: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(1.0, 2.0, 6.0, 0.0, oracle_r4)
	proof["pulse_fourth_draw_matches_seed_10_oracle"] = is_equal_approx(oracle_r1, 257.980828) and is_equal_approx(oracle_r2, 38.301969) and is_equal_approx(oracle_r3, 3.00842) and is_equal_approx(oracle_r4, 0.350668) and is_equal_approx(float(seeded.get("f", -1.0)), 0.350668)

	# f advances with time: the same draw at time 0 and time
	# 42.5 differs by exactly half a cycle (42.5 / 85).
	proof["pulse_f_advances_with_time"] = is_equal_approx(float(later.get("f", -1.0)) - float(base.get("f", -1.0)), 0.5)

	# f stays in [0, 1): draw 0, draw 0.9 at time 60 (f =
	# 0.605882), draw 0.25 at time 170 (f = 0.25), draw 0.5
	# at time 85 (f = 0.5).
	var high: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(1.0, 2.0, 6.0, 60.0, 0.9)
	var cycled: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_pulse_state(1.0, 2.0, 6.0, 170.0, 0.25)
	proof["pulse_f_in_unit_range"] = float(zero.get("f", -1.0)) >= 0.0 and float(zero.get("f", 1.0)) < 1.0 and is_equal_approx(float(high.get("f", -1.0)), 0.605882) and float(high.get("f", -1.0)) >= 0.0 and float(high.get("f", 1.0)) < 1.0 and is_equal_approx(float(cycled.get("f", -1.0)), 0.25) and is_equal_approx(float(wrapped.get("f", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretDrawBeamPulseProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
