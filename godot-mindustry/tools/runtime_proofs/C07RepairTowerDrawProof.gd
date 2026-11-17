extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
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

	# --- RepairTower draw() / range() / warmup() state (N2232):
	# RepairTowerBuild.draw() draws every frame after updateTile
	# (RepairTower.java:94-109, inside `public void draw(){`,
	# RepairTower.java:94, after `super.draw();`,
	# RepairTower.java:95 -- the super call draws the block
	# itself, not the circle/square/glow, so it is out of
	# scope): the warmup gate (`if(warmup <= 0.001f) return;`,
	# RepairTower.java:97) becomes the `visible` key; `float mod
	# = totalProgress % 1f;` (RepairTower.java:100) is the circle
	# progress; `Lines.stroke(circleStroke * (1f - mod) *
	# warmup);` (RepairTower.java:102) fades the stroke as the
	# circle expands; `Lines.circle(x, y, range * mod);`
	# (RepairTower.java:103) is the circle; `Fill.square(x, y,
	# squareRad * warmup, Time.time / squareSpinScl);`
	# (RepairTower.java:105) is the spinning square (rotation is
	# the explicit `time` param over square_spin_scl);
	# `Drawf.additive(glow, glowColor, warmup * (1f - glowMag +
	# Mathf.absin(Time.time, glowScl, glowMag)), x, y, 0f,
	# Layer.blockAdditive);` (RepairTower.java:108) is the glow,
	# with the port helper `SourceMathState.source_absin(time,
	# glow_scl, glow_mag)` and the effective alpha glow_alpha *
	# 0.5 (Drawf.java:186, `Draw.color(color, alpha * color.a);`,
	# with glowColor.a = 0.5f, RepairTower.java:22). The z-layers
	# are Layer.effect = 110 (Layer.java:75, `effect = 110,`)
	# and Layer.blockAdditive = 31 (Layer.java:36,
	# `blockAdditive = 31,`). The accessors are one-line
	# returns: `range()` (`return range;`,
	# RepairTower.java:113, from the Ranged interface,
	# Ranged.java:5-6) and `warmup()` (`return warmup;`,
	# RepairTower.java:118, overriding the base that returns 0f,
	# BuildingComp.java:608-609). The proof calls the pure
	# functions with synthetic values (time passed explicitly)
	# at the sample position x=100, y=200 with the catalog
	# range 100f, plus through the driver tick.

	# Hidden at the warmup gate: warmup 0.001 -> visible false.
	var hidden: Dictionary = repair_tower_build_state.source_repair_tower_draw_state({"warmup": 0.001, "total_progress": 0.5}, 100.0, 200.0, 100.0, 0.0, 3.0, 3.0, 0.8, 0.5, 8.0, "unit-repair-tower-glow")
	proof["draw_hidden_at_warmup_gate"] = hidden.get("visible", true) == false

	# Visible above the gate: warmup 0.5 -> visible true, center
	# at the building position.
	var shown: Dictionary = repair_tower_build_state.source_repair_tower_draw_state({"warmup": 0.5, "total_progress": 2.75}, 100.0, 200.0, 100.0, 0.0, 3.0, 3.0, 0.8, 0.5, 8.0, "unit-repair-tower-glow")
	proof["draw_visible_above_gate"] = shown.get("visible", false) == true and (shown.get("center", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(100, 200))

	# Mod wraps: total_progress 2.75 -> mod 0.75.
	proof["draw_mod_wraps"] = is_equal_approx(float(shown.get("mod", -1.0)), 0.75)

	# Circle stroke scales: 3 * (1 - 0.75) * 0.5 = 0.375.
	proof["draw_circle_stroke_scales"] = is_equal_approx(float(shown.get("circle_stroke", -1.0)), 0.375)

	# Circle radius catalog 100: 100 * 0.75 = 75.0.
	proof["draw_circle_radius_catalog_100"] = is_equal_approx(float(shown.get("circle_radius", -1.0)), 75.0)

	# Square half size and rotation: 3 * 0.5 = 1.5; time 8.0 /
	# 0.8 = 10.0.
	var square: Dictionary = repair_tower_build_state.source_repair_tower_draw_state({"warmup": 0.5, "total_progress": 0.5}, 100.0, 200.0, 100.0, 8.0, 3.0, 3.0, 0.8, 0.5, 8.0, "unit-repair-tower-glow")
	proof["draw_square_half_size_and_rotation"] = is_equal_approx(float(square.get("square_half_size", -1.0)), 1.5) and is_equal_approx(float(square.get("square_rotation", -1.0)), 10.0)

	# Glow alpha at time zero: absin(0, 8, 0.5) = 0.25, so
	# 0.5 * (1 - 0.5 + 0.25) = 0.375; glow color alpha 0.5.
	proof["draw_glow_alpha_at_time_zero"] = is_equal_approx(float(shown.get("glow_alpha", -1.0)), 0.375) and is_equal_approx(float(shown.get("glow_color_alpha", -1.0)), 0.5) and str(shown.get("glow_region", "")) == "unit-repair-tower-glow" and is_equal_approx(float(shown.get("glow_rotation", -1.0)), 0.0)

	# Glow alpha at nonzero time pins the PORT formula:
	# source_absin(8, 8, 0.5) = (sin(1.0) * 0.5 + 0.5) * 0.5
	# ~ 0.4604, so glow_alpha ~ 0.5 * (0.5 + 0.4604) ~ 0.4802
	# -- the arc formula would give ~0.4349, far outside the
	# 0.001 tolerance, so this key distinguishes the two.
	proof["draw_glow_alpha_nonzero_time_pins_port_formula"] = absf(float(square.get("glow_alpha", -1.0)) - 0.4802) < 0.001

	# Layers: circle/square z 110.0 (Layer.effect), glow z 31.0
	# (Layer.blockAdditive).
	proof["draw_layers"] = is_equal_approx(float(shown.get("z_layer", -1.0)), 110.0) and is_equal_approx(float(shown.get("glow_z_layer", -1.0)), 31.0)

	# Range accessor: catalog 100f / class default 80f.
	var range_catalog: Dictionary = repair_tower_build_state.source_repair_tower_range_state(100.0)
	var range_default: Dictionary = repair_tower_build_state.source_repair_tower_range_state(80.0)
	proof["draw_range_accessor"] = is_equal_approx(float(range_catalog.get("range", -1.0)), 100.0) and is_equal_approx(float(range_default.get("range", -1.0)), 80.0)

	# Warmup accessor reads the frame: 0.5 stamped, 0.0 absent.
	var warmup_stamped: Dictionary = repair_tower_build_state.source_repair_tower_warmup_state({"warmup": 0.5})
	var warmup_absent: Dictionary = repair_tower_build_state.source_repair_tower_warmup_state({})
	proof["draw_warmup_accessor_reads_frame"] = is_equal_approx(float(warmup_stamped.get("warmup", -1.0)), 0.5) and is_equal_approx(float(warmup_absent.get("warmup", -1.0)), 0.0)

	# Has driver tick line: the proof reads the state script
	# source and greps the driver body -- a runtime check,
	# not a hardcoded true.
	var source_text: String = FileAccess.get_file_as_string("res://src/game/SourceRepairTowerBuildState.gd")
	var driver_start: int = source_text.find("static func source_repair_tower_tick_buildings_state")
	var driver_end: int = source_text.find("\nstatic func ", driver_start + 1)
	var driver_body: String = source_text.substr(driver_start, driver_end - driver_start) if driver_end != -1 else source_text.substr(driver_start)
	proof["has_driver_tick_line"] = driver_start != -1 and driver_body.contains("source_repair_tower_draw_state") and driver_body.contains("frame[\"game_time\"]") and not driver_body.contains("source_repair_tower_range_state") and not driver_body.contains("source_repair_tower_warmup_state")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerDrawProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
