extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_deconstructor_build_state := preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")
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

	# --- Draw / icons rows (N2418): PayloadDeconstructorBuild.draw()
	# (PayloadDeconstructor.java:58-89) rects the base region, then
	# the 4 input regions where blends(i) holds (rotation (i * 90)
	# - 180), then drawPayload() on Layer.blockOver, then -- only
	# while a payload is being deconstructed -- the shadow
	# (drawShadow(1f - progress) at the set() position) + the
	# Drawf.construct effect (icon deconstructing.icon(), color
	# Pal.remove, rotation 0f for a BuildPayload else payRotation
	# - 90f, progress + alpha 1f - progress, time = the frame
	# time) + the scan line (center x + sin(time / 20f) *
	# (tilesize / 2f * size - 3f), angle 90f, length size *
	# tilesize - 6f), then the top region. icons()
	# (PayloadDeconstructor.java:40-42) returns [region,
	# topRegion] and rides the pure as icon_regions (the N2396
	# precedent -- a zero-arg pure cannot register). The sin is
	# the arc 3-arg form (Mathf.java:90-92, arc), NOT absin.
	# Pure-only: the tick never calls draw -- draw is called by
	# the renderer, and the renderer call site waits for a
	# renderer slice, so this proof has no live-tick key.

	# --- Base + inputs: the base rect always draws at (x, y)
	# with region region, the top rect always draws at (x, y)
	# with region topRegion, and the input regions draw only
	# where blends holds -- blends [true, false, true, false]
	# draws i = 0 (rotation -180) and i = 2 (rotation 0).
	var idle: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_draw_state(100.0, 200.0, [true, false, true, false], false, null, 0.0, 0.0, 5)
	var idle_base: Dictionary = idle.get("base_call", {})
	var idle_inputs: Array = idle.get("input_calls", [])
	var idle_top: Dictionary = idle.get("top_call", {})
	var idle_first: Dictionary = idle_inputs[0] if idle_inputs.size() > 0 else {}
	var idle_second: Dictionary = idle_inputs[1] if idle_inputs.size() > 1 else {}
	proof["draw_base_inputs"] = is_equal_approx(float(idle_base.get("x", -1.0)), 100.0) and is_equal_approx(float(idle_base.get("y", -1.0)), 200.0) and str(idle_base.get("region", "")) == "region" and is_equal_approx(float(idle_top.get("x", -1.0)), 100.0) and is_equal_approx(float(idle_top.get("y", -1.0)), 200.0) and str(idle_top.get("region", "")) == "topRegion" and idle_inputs.size() == 2 and int(idle_first.get("index", -1)) == 0 and is_equal_approx(float(idle_first.get("rotation", -999.0)), -180.0) and int(idle_second.get("index", -1)) == 2 and is_equal_approx(float(idle_second.get("rotation", -999.0)), 0.0) and str(idle_first.get("region", "")) == "inRegion" and str(idle_second.get("region", "")) == "inRegion"

	# --- No deconstructing: with no payload being
	# deconstructed the shadow, construct and scan line are
	# all empty, while the base / inputs / top still draw;
	# a HELD payload still draws through drawPayload()
	# (payload.draw() on Layer.blockOver after
	# updatePayload()) even with no deconstructing.
	var held: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_draw_state(100.0, 200.0, [false, false, false, false], true, null, 0.0, 0.0, 5)
	var held_payload: Dictionary = held.get("payload_call", {})
	proof["draw_no_deconstructing"] = Dictionary(idle.get("shadow_call", {})).is_empty() and Dictionary(idle.get("construct_call", {})).is_empty() and Dictionary(idle.get("scan_line", {})).is_empty() and not bool(idle.get("has_deconstructing", true)) and Dictionary(idle.get("payload_call", {})).is_empty() and not held_payload.is_empty() and str(held_payload.get("call", "")) == "payload.draw();" and str(held_payload.get("update_payload_call", "")) == "updatePayload();" and str(held_payload.get("z", "")) == "Layer.blockOver" and Dictionary(held.get("shadow_call", {})).is_empty() and Array(held.get("input_calls", [{}])).is_empty()

	# --- Deconstructing shadow + construct: at progress
	# 0.25 the shadow alpha is 0.75 at the set() position
	# (x + payVector.x, y + payVector.y) = (104, 194) with
	# rotation payRotation 120, and the construct call
	# carries icon conveyor-fullIcon, color Pal.remove,
	# progress 0.75, alpha 0.75, time 40.0, shader time
	# -40 / 20 = -2.0, z Layer.blockOver.
	var deconstructing: Dictionary = {"icon": "conveyor-fullIcon", "is_build_payload": true, "pay_vector": {"x": 4.0, "y": -6.0}, "pay_rotation": 120.0}
	var working: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_draw_state(100.0, 200.0, [true, true, true, true], false, deconstructing, 0.25, 40.0, 5)
	var working_shadow: Dictionary = working.get("shadow_call", {})
	var working_construct: Dictionary = working.get("construct_call", {})
	proof["draw_deconstructing_shadow_construct"] = bool(working.get("has_deconstructing", false)) and is_equal_approx(float(working_shadow.get("alpha", -1.0)), 0.75) and is_equal_approx(float(working_shadow.get("x", -1.0)), 104.0) and is_equal_approx(float(working_shadow.get("y", -1.0)), 194.0) and is_equal_approx(float(working_shadow.get("rotation", -1.0)), 120.0) and bool(working_shadow.get("is_build_payload", false)) and str(working_shadow.get("z", "")) == "Layer.blockOver" and str(working_construct.get("icon", "")) == "conveyor-fullIcon" and str(working_construct.get("color", "")) == "Pal.remove" and is_equal_approx(float(working_construct.get("progress", -1.0)), 0.75) and is_equal_approx(float(working_construct.get("alpha", -1.0)), 0.75) and is_equal_approx(float(working_construct.get("time", -1.0)), 40.0) and is_equal_approx(float(working_construct.get("shader_time", -1.0)), -2.0) and str(working_construct.get("z", "")) == "Layer.blockOver" and is_equal_approx(float(working_construct.get("x", -1.0)), 100.0) and is_equal_approx(float(working_construct.get("y", -1.0)), 200.0)

	# --- Scan line math: the line sits at the building
	# center when time is 0 (sin(0) = 0), angle 90, length
	# size * tilesize - 6f = 34 for size 5, color
	# Pal.remove, alpha 1f; at time 20 * PI / 2 the sin
	# peaks at 1 and the line sits 17 (tilesize / 2f *
	# size - 3f) right of center; size 3 gives magnitude
	# 9 and length 18.
	var fresh: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_draw_state(100.0, 200.0, [false, false, false, false], false, deconstructing, 0.0, 0.0, 5)
	var fresh_line: Dictionary = fresh.get("scan_line", {})
	var peaked: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_draw_state(100.0, 200.0, [false, false, false, false], false, deconstructing, 0.0, 20.0 * PI / 2.0, 5)
	var peaked_line: Dictionary = peaked.get("scan_line", {})
	var small: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_draw_state(0.0, 0.0, [false, false, false, false], false, deconstructing, 0.0, 20.0 * PI / 2.0, 3)
	var small_line: Dictionary = small.get("scan_line", {})
	proof["draw_scan_line"] = is_equal_approx(float(fresh_line.get("x", -1.0)), 100.0) and is_equal_approx(float(fresh_line.get("y", -1.0)), 200.0) and is_equal_approx(float(fresh_line.get("angle", -1.0)), 90.0) and is_equal_approx(float(fresh_line.get("length", -1.0)), 34.0) and str(fresh_line.get("color", "")) == "Pal.remove" and is_equal_approx(float(fresh_line.get("alpha", -1.0)), 1.0) and is_equal_approx(float(peaked_line.get("x", -1.0)), 117.0) and is_equal_approx(float(peaked.get("scan_magnitude", -1.0)), 17.0) and is_equal_approx(float(peaked.get("scan_length", -1.0)), 34.0) and is_equal_approx(float(small_line.get("x", -1.0)), 9.0) and is_equal_approx(float(small_line.get("length", -1.0)), 18.0) and is_equal_approx(float(small.get("scan_magnitude", -1.0)), 9.0)

	# --- Icons merged: icons() returns [region, topRegion]
	# and rides the draw pure as icon_regions, whether or
	# not a payload is being deconstructed.
	var idle_icons: Array = idle.get("icon_regions", [])
	var working_icons: Array = working.get("icon_regions", [])
	proof["draw_icons_merged"] = idle_icons.size() == 2 and str(idle_icons[0]) == "region" and str(idle_icons[1]) == "topRegion" and working_icons.size() == 2 and str(working_icons[0]) == "region" and str(working_icons[1]) == "topRegion"

	# --- Construct rotation: a BuildPayload constructs
	# at rotation 0f, a UnitPayload at payRotation - 90f
	# (payRotation 200 gives 110).
	var unit_payload: Dictionary = {"icon": "dagger-fullIcon", "is_build_payload": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 200.0}
	var unit_working: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_draw_state(0.0, 0.0, [false, false, false, false], false, unit_payload, 0.5, 0.0, 5)
	var unit_construct: Dictionary = unit_working.get("construct_call", {})
	proof["draw_construct_rotation"] = is_equal_approx(float(working_construct.get("rotation", -1.0)), 0.0) and is_equal_approx(float(working.get("construct_rotation", -1.0)), 0.0) and is_equal_approx(float(unit_construct.get("rotation", -1.0)), 110.0) and is_equal_approx(float(unit_working.get("construct_rotation", -1.0)), 110.0) and str(unit_construct.get("icon", "")) == "dagger-fullIcon"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
