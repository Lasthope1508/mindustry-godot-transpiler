extends Node

const main_scene := preload("res://scenes/Main.tscn")
const build_turret_build_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
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

	# --- Draw rows (N2431): BuildTurretBuild.draw()
	# (BuildTurret.java:234-251). draw() rects the
	# baseRegion, then the turret-layer shadow +
	# region rect at rotation - 90 -- the shadow
	# shifts by the FIELD elevation, lifted by
	# init() to size / 2f, so the size-3 build-tower
	# shifts by 1.5 (NOT the RepairTurret literal
	# size / 2f -- here the field is the shift and
	# the init lift is what sets it). The glow is
	# the Drawf.additive overload at Layer.turretHeat
	# with alpha warmup when the glow region is
	# found -- the additive body multiplies by the
	# color alpha, and heatColor carries a 0.9f
	# alpha, so the effective glow alpha is warmup
	# * 0.9. unit.drawBuilding() runs when
	# efficiency > 0 -- a STRICT gate, efficiency
	# exactly 0 draws nothing -- and the pure
	# RECORDS the call, it does not model unit draw.
	# Pure-only: the tick never calls draw.

	# --- Base / shadow / region: a build-tower at
	# (100, 200), rotation 90, elevation 1.5 -- base
	# rect, shadow and region all at (100, 200)
	# except the shadow, which shifts by the
	# elevation 1.5 to (98.5, 198.5), rotation 0.
	# The base call carries no z key (it draws
	# before the Draw.z call, at the default z);
	# the shadow and region carry Layer.turret.
	var tower_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 1.5, 0.5, 1.0, true, "heatColor", true)
	var tower_base: Dictionary = tower_draw.get("base_call", {})
	var tower_shadow: Dictionary = tower_draw.get("shadow_call", {})
	var tower_region: Dictionary = tower_draw.get("region_call", {})
	proof["draw_base_shadow_region"] = is_equal_approx(float(tower_base.get("x", -1.0)), 100.0) and is_equal_approx(float(tower_base.get("y", -1.0)), 200.0) and str(tower_base.get("region", "")) == "baseRegion" and not tower_base.has("z") and is_equal_approx(float(tower_shadow.get("x", -1.0)), 98.5) and is_equal_approx(float(tower_shadow.get("y", -1.0)), 198.5) and is_equal_approx(float(tower_shadow.get("rotation", -1.0)), 0.0) and str(tower_shadow.get("z", "")) == "Layer.turret" and is_equal_approx(float(tower_region.get("x", -1.0)), 100.0) and is_equal_approx(float(tower_region.get("y", -1.0)), 200.0) and is_equal_approx(float(tower_region.get("rotation", -1.0)), 0.0) and str(tower_region.get("z", "")) == "Layer.turret" and is_equal_approx(float(tower_draw.get("draw_rotation", -1.0)), 0.0) and is_equal_approx(float(tower_draw.get("elevation", -1.0)), 1.5)

	# --- Glow found: at warmup 0.5 the glow draws
	# with alpha 0.5 and effective alpha 0.5 * 0.9
	# = 0.45, color heatColor, region glowRegion,
	# rotation 0 (rotation 90 - 90), layer
	# Layer.turretHeat. At warmup 1.0 the effective
	# alpha is 0.9. At warmup 0.0 the glow STILL
	# draws when found (Java gates on found() only,
	# not on warmup) with alpha 0.0.
	var glow: Dictionary = tower_draw.get("glow_call", {})
	var hot_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 1.5, 1.0, 1.0, true, "heatColor", true)
	var hot_glow: Dictionary = hot_draw.get("glow_call", {})
	var cold_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 1.5, 0.0, 1.0, true, "heatColor", true)
	var cold_glow: Dictionary = cold_draw.get("glow_call", {})
	proof["draw_glow_found"] = str(glow.get("region", "")) == "glowRegion" and str(glow.get("color", "")) == "heatColor" and is_equal_approx(float(glow.get("alpha", -1.0)), 0.5) and is_equal_approx(float(glow.get("effective_alpha", -1.0)), 0.45) and is_equal_approx(float(tower_draw.get("effective_alpha", -1.0)), 0.45) and is_equal_approx(float(glow.get("x", -1.0)), 100.0) and is_equal_approx(float(glow.get("y", -1.0)), 200.0) and is_equal_approx(float(glow.get("rotation", -1.0)), 0.0) and str(glow.get("layer", "")) == "Layer.turretHeat" and is_equal_approx(float(hot_glow.get("alpha", -1.0)), 1.0) and is_equal_approx(float(hot_glow.get("effective_alpha", -1.0)), 0.9) and is_equal_approx(float(cold_glow.get("alpha", -1.0)), 0.0) and is_equal_approx(float(cold_glow.get("effective_alpha", -1.0)), 0.0)

	# --- Glow not found: the glow call is null
	# even at warmup 1.0 and efficiency 1.0 -- but
	# the base / shadow / region calls still draw.
	var dark_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 1.5, 1.0, 1.0, false, "heatColor", true)
	var dark_base: Dictionary = dark_draw.get("base_call", {})
	var dark_shadow: Dictionary = dark_draw.get("shadow_call", {})
	var dark_region: Dictionary = dark_draw.get("region_call", {})
	proof["draw_glow_not_found"] = dark_draw.get("glow_call", {}) == null and not bool(dark_draw.get("glow_found", true)) and is_equal_approx(float(dark_base.get("x", -1.0)), 100.0) and is_equal_approx(float(dark_shadow.get("x", -1.0)), 98.5) and is_equal_approx(float(dark_region.get("x", -1.0)), 100.0)

	# --- Build call: at efficiency 1.0 with a unit
	# present the build call is recorded
	# (unit.drawBuilding()). At efficiency 0.5 it
	# still draws -- the gate is a STRICT > 0. With
	# no unit present the call is null even at
	# efficiency 1.0 (the defensive port flag -- Java
	# creates the unit at construction and never
	# nulls it, but the port has no live Unit object
	# behind the frame).
	var build: Dictionary = tower_draw.get("build_call", {})
	var half_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 1.5, 0.5, 0.5, true, "heatColor", true)
	var half_build: Dictionary = half_draw.get("build_call", {})
	var nounit_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 1.5, 0.5, 1.0, true, "heatColor", false)
	proof["draw_build_call"] = str(build.get("call", "")) == "unit.drawBuilding();" and str(half_build.get("call", "")) == "unit.drawBuilding();" and nounit_draw.get("build_call", {}) == null

	# --- No build call: at efficiency exactly 0.0
	# the build call is null (the STRICT > 0 gate),
	# and at a negative efficiency it is null too --
	# even with a unit present and the glow found.
	var idle_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 1.5, 0.5, 0.0, true, "heatColor", true)
	var negative_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 1.5, 0.5, -1.0, true, "heatColor", true)
	proof["draw_build_no_call"] = idle_draw.get("build_call", {}) == null and negative_draw.get("build_call", {}) == null and is_equal_approx(float(idle_draw.get("efficiency", -1.0)), 0.0)

	# --- Rotation / elevation: rotation 0 draws the
	# region at -90, rotation 180 at 90, rotation 270
	# at 180 -- the shadow follows the same rotation.
	# Elevation 0.0 leaves the shadow at (x, y);
	# elevation 2.5 shifts it to (97.5, 197.5).
	var flat_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 0.0, 1.5, 0.5, 1.0, true, "heatColor", true)
	var flat_region: Dictionary = flat_draw.get("region_call", {})
	var flat_shadow: Dictionary = flat_draw.get("shadow_call", {})
	var back_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 180.0, 1.5, 0.5, 1.0, true, "heatColor", true)
	var back_region: Dictionary = back_draw.get("region_call", {})
	var down_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 270.0, 1.5, 0.5, 1.0, true, "heatColor", true)
	var down_region: Dictionary = down_draw.get("region_call", {})
	var no_lift_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 0.0, 0.5, 1.0, true, "heatColor", true)
	var no_lift_shadow: Dictionary = no_lift_draw.get("shadow_call", {})
	var high_draw: Dictionary = build_turret_build_state.source_build_turret_draw_state(100.0, 200.0, 90.0, 2.5, 0.5, 1.0, true, "heatColor", true)
	var high_shadow: Dictionary = high_draw.get("shadow_call", {})
	proof["draw_rotation_elevation"] = is_equal_approx(float(flat_region.get("rotation", -1.0)), -90.0) and is_equal_approx(float(flat_shadow.get("rotation", -1.0)), -90.0) and is_equal_approx(float(back_region.get("rotation", -1.0)), 90.0) and is_equal_approx(float(down_region.get("rotation", -1.0)), 180.0) and is_equal_approx(float(no_lift_shadow.get("x", -1.0)), 100.0) and is_equal_approx(float(no_lift_shadow.get("y", -1.0)), 200.0) and is_equal_approx(float(high_shadow.get("x", -1.0)), 97.5) and is_equal_approx(float(high_shadow.get("y", -1.0)), 197.5) and is_equal_approx(float(high_draw.get("elevation", -1.0)), 2.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
