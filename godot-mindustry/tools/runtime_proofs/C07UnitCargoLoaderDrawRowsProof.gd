extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_cargo_loader_build_state := preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")
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

	# --- Draw rows (N2415): UnitTransportSourceBuild.draw()
	# (UnitCargoLoader.java:146-162) rects the base region,
	# then EITHER the Drawf.construct call on Layer.blockOver
	# while no unit is held (icon unitType.fullIcon,
	# rotation 0f, progress buildProgress, alpha warmup,
	# time totalProgress) OR the poly ring once a unit
	# waits (sides 6, radius 8f, rotation Time.time *
	# polyRotateSpeed = Time.time * 1f, stroke polyStroke *
	# readyness = 1.8f * readyness, color Pal.accent, z
	# Layer.bullet - 0.01f). Drawf.construct delegates
	# (Drawf.java:574-579) to the sized overload with
	# color Pal.accent and size t.block.size * tilesize -
	# 4f = 3 * 8 - 4 = 20f, drawing the build-shader rect
	# (progress buildProgress, alpha warmup, shader time
	# -totalProgress / 20f) plus the scan line (center x +
	# sin(totalProgress / 20f) * 10f, angle 90, length
	# 20f). The icon rides the draw pure as the
	# construct_icon result key (UnitCargoLoader has NO
	# icons() override, and a zero-arg pure cannot
	# register). Pure-only: the tick never calls draw --
	# draw is called by the renderer, and the renderer
	# call site waits for a renderer slice, so this proof
	# has no live-tick key.

	# --- Base rect: the base rect always draws at (x, y)
	# with region block.region -- whether a unit is held
	# or not.
	var building: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_state(100.0, 200.0, null, 0.5, 0.25, 40.0, 0.0, 0.0, 3)
	var building_base: Dictionary = building.get("base_call", {})
	var waiting: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_state(100.0, 200.0, {"type": "manifold"}, 0.0, 1.0, 40.0, 0.5, 30.0, 3)
	var waiting_base: Dictionary = waiting.get("base_call", {})
	proof["draw_base_rect"] = is_equal_approx(float(building_base.get("x", -1.0)), 100.0) and is_equal_approx(float(building_base.get("y", -1.0)), 200.0) and str(building_base.get("region", "")) == "region" and is_equal_approx(float(waiting_base.get("x", -1.0)), 100.0) and is_equal_approx(float(waiting_base.get("y", -1.0)), 200.0) and str(waiting_base.get("region", "")) == "region"

	# --- Construct branch: while no unit is held the
	# construct call draws and the poly call is empty;
	# once a unit waits the construct call is empty and
	# the poly call draws.
	var building_construct: Dictionary = building.get("construct_call", {})
	var building_poly: Dictionary = building.get("poly_call", {})
	var waiting_construct: Dictionary = waiting.get("construct_call", {})
	var waiting_poly: Dictionary = waiting.get("poly_call", {})
	proof["draw_construct_branch"] = not building_construct.is_empty() and building_poly.is_empty() and waiting_construct.is_empty() and not waiting_poly.is_empty() and not bool(building.get("has_unit", true)) and bool(waiting.get("has_unit", false))

	# --- Construct progress values: the construct call
	# carries the frame values -- icon unitType.fullIcon,
	# rotation 0f, progress 0.5, alpha 0.25, time 40.0,
	# color Pal.accent, size 20f, shader time -40 / 20 =
	# -2.0 -- and the scan line sits at the building
	# center when totalProgress is 0 (sin(0) = 0), angle
	# 90, length 20.
	var fresh: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_state(100.0, 200.0, null, 0.0, 0.0, 0.0, 0.0, 0.0, 3)
	var fresh_construct: Dictionary = fresh.get("construct_call", {})
	var fresh_line: Dictionary = fresh_construct.get("line", {})
	proof["draw_construct_progress"] = str(building_construct.get("icon", "")) == "unitType.fullIcon" and str(building.get("construct_icon", "")) == "unitType.fullIcon" and is_equal_approx(float(building_construct.get("rotation", -1.0)), 0.0) and is_equal_approx(float(building_construct.get("progress", -1.0)), 0.5) and is_equal_approx(float(building_construct.get("alpha", -1.0)), 0.25) and is_equal_approx(float(building_construct.get("time", -1.0)), 40.0) and str(building_construct.get("color", "")) == "Pal.accent" and is_equal_approx(float(building_construct.get("size", -1.0)), 20.0) and is_equal_approx(float(building_construct.get("shader_time", -1.0)), -2.0) and str(building_construct.get("z", "")) == "Layer.blockOver" and is_equal_approx(float(fresh_line.get("x", -1.0)), 100.0) and is_equal_approx(float(fresh_line.get("y", -1.0)), 200.0) and is_equal_approx(float(fresh_line.get("angle", -1.0)), 90.0) and is_equal_approx(float(fresh_line.get("length", -1.0)), 20.0)

	# --- Poly branch: once a unit waits the poly ring
	# draws at (x, y) with sides 6, radius 8f, color
	# Pal.accent, z Layer.bullet - 0.01f.
	proof["draw_poly_branch"] = is_equal_approx(float(waiting_poly.get("x", -1.0)), 100.0) and is_equal_approx(float(waiting_poly.get("y", -1.0)), 200.0) and int(waiting_poly.get("sides", -1)) == 6 and is_equal_approx(float(waiting_poly.get("radius", -1.0)), 8.0) and str(waiting_poly.get("color", "")) == "Pal.accent" and str(waiting_poly.get("z", "")) == "Layer.bullet - 0.01f"

	# --- Poly rotation: the ring rotates with Time.time
	# at polyRotateSpeed 1f -- time 30 gives rotation
	# 30, time 90 gives 90, time 0 gives 0.
	var spun: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_state(0.0, 0.0, {"type": "manifold"}, 0.0, 1.0, 0.0, 1.0, 90.0, 3)
	var still: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_state(0.0, 0.0, {"type": "manifold"}, 0.0, 1.0, 0.0, 1.0, 0.0, 3)
	proof["draw_poly_rotation"] = is_equal_approx(float(waiting.get("poly_rotation", -1.0)), 30.0) and is_equal_approx(float(waiting_poly.get("rotation", -1.0)), 30.0) and is_equal_approx(float(spun.get("poly_rotation", -1.0)), 90.0) and is_equal_approx(float(still.get("poly_rotation", -1.0)), 0.0)

	# --- Poly stroke: the ring stroke is polyStroke *
	# readyness = 1.8f * readyness -- 0.9 at readyness
	# 0.5, 1.8 at full readyness, 0 at readyness 0.
	var unready: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_draw_state(0.0, 0.0, {"type": "manifold"}, 0.0, 1.0, 0.0, 0.0, 0.0, 3)
	proof["draw_poly_stroke"] = is_equal_approx(float(waiting.get("poly_stroke", -1.0)), 0.9) and is_equal_approx(float(waiting_poly.get("stroke", -1.0)), 0.9) and is_equal_approx(float(spun.get("poly_stroke", -1.0)), 1.8) and is_equal_approx(float(unready.get("poly_stroke", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitCargoLoaderDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
