extends Node

const main_scene := preload("res://scenes/Main.tscn")
const impact_reactor_build_state := preload("res://src/game/SourceImpactReactorBuildState.gd")
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

	# --- Draw rows (N2430): GeneratorBuild.draw()
	# (PowerGenerator.java:99-100, drawer.draw(this))
	# through the DrawMulti class-default drawer
	# (ImpactReactor.java:34) -- the single def does
	# NOT override it (Blocks.java:2632-2645). The
	# DrawMulti draws, in order: the -bottom region
	# rect at rotation 0, the four additive plasma
	# rects (r from the atlas size, alpha scaled by
	# warmup, rotation totalProgress * (12 + 6i)),
	# and the base region rect at drawrot() = 0.
	# The light (GeneratorBuild.drawLight(),
	# PowerGenerator.java:145-148) is super + drawer:
	# the DrawPlasma light AND the super liquid
	# light (cryofluid, radius size * 30). NO RNG in
	# the pure: DrawPlasma.draw rolls nothing (the
	# parent DrawFlame.draw uses Mathf.random, but
	# DrawPlasma overrides draw fully). The absin
	# calls land Java-exact through the shared helper
	# at the DOUBLED scale. Pure-only: the tick never
	# calls draw.

	var plasma_sizes: Array = [20.0, 22.0, 24.0, 26.0]

	# --- Bottom: a reactor at (100, 200) draws the
	# -bottom region rect at (100, 200), rotation 0
	# (rotateSpeed 0, rotation 0, buildingRotate
	# false). The region is impact-reactor-bottom.
	var drawn: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_state(100.0, 200.0, 1.0, 10.0, 0.0, plasma_sizes, 10.0, 0.2, "0097f5", 0.0, 1.0, 4)
	var bottom_call: Dictionary = drawn.get("bottom_call", {})
	proof["draw_bottom"] = str(bottom_call.get("region", "")) == "impact-reactor-bottom" and is_equal_approx(float(bottom_call.get("x", -1.0)), 100.0) and is_equal_approx(float(bottom_call.get("y", -1.0)), 200.0) and is_equal_approx(float(bottom_call.get("rotation", -1.0)), 0.0)

	# --- Plasma at warmup / time 0: at Time.time 0
	# every absin reads mag / 2 (sin(0) = 0), so with
	# atlas sizes 20 / 22 / 24 / 26 the radii are
	# 19.5 / 21.25 / 23.0 / 24.75 (size - 3 +
	# mag / 2, mags 5 / 4.5 / 4 / 3.5) and the
	# alphas at warmup 1 are 0.45 / 0.475 / 0.5 /
	# 0.525 (0.3 + mag / 2, mags 0.3 / 0.35 / 0.4 /
	# 0.45). At totalProgress 10 the rotations are
	# 120 / 180 / 240 / 300 (10 * (12 + 6i)) and the
	# color lerps run plasma1 -> plasma2 at t 0 /
	# 0.25 / 0.5 / 0.75. The blend is additive and
	# there are 4 plasma rects.
	var plasma_call: Dictionary = drawn.get("plasma_call", {})
	var plasma_rects: Array = plasma_call.get("rects", [])
	proof["draw_plasma_warmup_time"] = str(plasma_call.get("blend", "")) == "Blending.additive" and int(plasma_call.get("plasma_count", -1)) == 4 and plasma_rects.size() == 4 and str(plasma_rects[0].get("region", "")) == "impact-reactor-plasma-0" and str(plasma_rects[3].get("region", "")) == "impact-reactor-plasma-3" and is_equal_approx(float(plasma_rects[0].get("size", -1.0)), 19.5) and is_equal_approx(float(plasma_rects[1].get("size", -1.0)), 21.25) and is_equal_approx(float(plasma_rects[2].get("size", -1.0)), 23.0) and is_equal_approx(float(plasma_rects[3].get("size", -1.0)), 24.75) and is_equal_approx(float(plasma_rects[0].get("alpha", -1.0)), 0.45) and is_equal_approx(float(plasma_rects[1].get("alpha", -1.0)), 0.475) and is_equal_approx(float(plasma_rects[2].get("alpha", -1.0)), 0.5) and is_equal_approx(float(plasma_rects[3].get("alpha", -1.0)), 0.525) and is_equal_approx(float(plasma_rects[0].get("rotation", -1.0)), 120.0) and is_equal_approx(float(plasma_rects[1].get("rotation", -1.0)), 180.0) and is_equal_approx(float(plasma_rects[2].get("rotation", -1.0)), 240.0) and is_equal_approx(float(plasma_rects[3].get("rotation", -1.0)), 300.0) and is_equal_approx(float(plasma_rects[0].get("color", {}).get("t", -1.0)), 0.0) and is_equal_approx(float(plasma_rects[1].get("color", {}).get("t", -1.0)), 0.25) and is_equal_approx(float(plasma_rects[2].get("color", {}).get("t", -1.0)), 0.5) and is_equal_approx(float(plasma_rects[3].get("color", {}).get("t", -1.0)), 0.75) and str(plasma_rects[0].get("color", {}).get("from", "")) == "ffd06b" and str(plasma_rects[0].get("color", {}).get("to", "")) == "ff361b" and is_equal_approx(float(plasma_rects[0].get("x", -1.0)), 100.0) and is_equal_approx(float(plasma_rects[0].get("y", -1.0)), 200.0)

	# --- Base: the base region rect is
	# impact-reactor at (100, 200), rotation 0
	# (drawrot() folds to 0 -- the block sets no
	# rotate). The icons are [impact-reactor-bottom,
	# impact-reactor] in drawer order -- DrawPlasma
	# contributes nothing.
	var base_call: Dictionary = drawn.get("base_call", {})
	proof["draw_base"] = str(base_call.get("region", "")) == "impact-reactor" and is_equal_approx(float(base_call.get("x", -1.0)), 100.0) and is_equal_approx(float(base_call.get("y", -1.0)), 200.0) and is_equal_approx(float(base_call.get("rotation", -1.0)), 0.0) and (drawn.get("icon_regions", []) as Array) == ["impact-reactor-bottom", "impact-reactor"]

	# --- Light: at warmup 0.5, Time.time 0, the
	# plasma light radius is (110 + 2.5) * 0.5 =
	# 56.25 (absin(5, 5) reads 2.5 at time 0), the
	# color lerps plasma2 -> plasma1 at t 0.1
	# (absin(7, 0.2) reads 0.1 at time 0 -- NOTE the
	# reversed order vs the draw rects), alpha
	# 0.8 * 0.5 = 0.4. The super liquid light: the
	# tank holds 10 cryofluid (>= 0.01), so
	# visualLiquid lerps from 0 toward 1 by
	# clamp(0.06 * 1) = 0.06 -- radius 4 * 30 = 120,
	# opacity 0.2 * 0.06 = 0.012, drawn. With an
	# empty tank (0 cryofluid) the visual stays 0
	# and the liquid light is empty.
	var half_warm: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_state(100.0, 200.0, 0.5, 10.0, 0.0, plasma_sizes, 10.0, 0.2, "0097f5", 0.0, 1.0, 4)
	var half_light: Dictionary = half_warm.get("light_call", {})
	var half_plasma_light: Dictionary = half_light.get("plasma_light", {})
	var half_liquid_light: Dictionary = half_light.get("liquid_light", {})
	var dry: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_state(100.0, 200.0, 0.5, 10.0, 0.0, plasma_sizes, 0.0, 0.2, "0097f5", 0.0, 1.0, 4)
	var dry_light: Dictionary = dry.get("light_call", {})
	proof["draw_plasma_light"] = is_equal_approx(float(half_plasma_light.get("radius", -1.0)), 56.25) and is_equal_approx(float(half_plasma_light.get("color", {}).get("t", -1.0)), 0.1) and str(half_plasma_light.get("color", {}).get("from", "")) == "ff361b" and str(half_plasma_light.get("color", {}).get("to", "")) == "ffd06b" and is_equal_approx(float(half_plasma_light.get("alpha", -1.0)), 0.4) and is_equal_approx(float(half_plasma_light.get("x", -1.0)), 100.0) and is_equal_approx(float(half_plasma_light.get("y", -1.0)), 200.0) and bool(half_light.get("liquid_drawn", false)) and is_equal_approx(float(half_light.get("visual_liquid_after", -1.0)), 0.06) and is_equal_approx(float(half_liquid_light.get("radius", -1.0)), 120.0) and str(half_liquid_light.get("color", "")) == "0097f5" and is_equal_approx(float(half_liquid_light.get("opacity", -1.0)), 0.012) and not bool(dry_light.get("liquid_drawn", true)) and (dry_light.get("liquid_light", {}) as Dictionary).is_empty() and is_equal_approx(float(dry_light.get("visual_liquid_after", -1.0)), 0.0)

	# --- Cold: at warmup 0 the plasma alphas are
	# all 0 and the plasma light dies (radius 0,
	# alpha 0) -- but the radii are unchanged (the
	# r formula never reads warmup) and the liquid
	# light still draws (it depends on the tank,
	# not the warmup).
	var cold: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_state(100.0, 200.0, 0.0, 10.0, 0.0, plasma_sizes, 10.0, 0.2, "0097f5", 0.0, 1.0, 4)
	var cold_plasma: Dictionary = cold.get("plasma_call", {})
	var cold_rects: Array = cold_plasma.get("rects", [])
	var cold_light: Dictionary = cold.get("light_call", {})
	var cold_plasma_light: Dictionary = cold_light.get("plasma_light", {})
	proof["draw_plasma_cold"] = is_equal_approx(float(cold_rects[0].get("alpha", -1.0)), 0.0) and is_equal_approx(float(cold_rects[3].get("alpha", -1.0)), 0.0) and is_equal_approx(float(cold_plasma_light.get("radius", -1.0)), 0.0) and is_equal_approx(float(cold_plasma_light.get("alpha", -1.0)), 0.0) and is_equal_approx(float(cold_rects[0].get("size", -1.0)), 19.5) and is_equal_approx(float(cold_rects[0].get("rotation", -1.0)), 120.0) and bool(cold_light.get("liquid_drawn", false)) and is_equal_approx(float(cold_light.get("visual_liquid_after", -1.0)), 0.06)

	# --- Time peak: at Time.time 2 * PI the i = 0
	# absins peak -- helper(2 * PI, 4, 5) = 5
	# (sin(PI / 2) = 1) and helper(2 * PI, 4, 0.3) =
	# 0.3 -- so r_0 is 20 - 3 + 5 = 22 (up from 19.5
	# at time 0) and alpha_0 is (0.3 + 0.3) * 1 = 0.6
	# (up from 0.45). The doubled scale is what
	# makes the peak land at 2 * PI: Java absin(v,
	# 2, mag) peaks when v / (2 * 2) = PI / 2.
	var peak: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_state(100.0, 200.0, 1.0, 10.0, 2.0 * PI, plasma_sizes, 10.0, 0.2, "0097f5", 0.0, 1.0, 4)
	var peak_plasma: Dictionary = peak.get("plasma_call", {})
	var peak_rects: Array = peak_plasma.get("rects", [])
	proof["draw_plasma_time_peak"] = is_equal_approx(float(peak_rects[0].get("size", -1.0)), 22.0) and is_equal_approx(float(peak_rects[0].get("alpha", -1.0)), 0.6) and is_equal_approx(float(peak_rects[0].get("radius_absin", -1.0)), 5.0) and is_equal_approx(float(peak_rects[0].get("alpha_absin", -1.0)), 0.3) and peak_rects.size() == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
