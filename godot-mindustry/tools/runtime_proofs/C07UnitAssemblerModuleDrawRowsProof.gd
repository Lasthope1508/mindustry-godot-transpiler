extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_assembler_module_build_state := preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")
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

	# --- Draw / drawPlace / drawPlanRegion / icons rows (N2425):
	# UnitAssemblerModuleBuild.draw() (UnitAssemblerModule.java:90-108)
	# rects the base region, then the input side regions where blends(i)
	# holds AND i != rotation (rotation i - 2), then the always-drawn side
	# region (sideRegion2 when rotation >= 2, else sideRegion1), then
	# drawPayload() on Layer.blockOver (payRotation = rotdeg() first),
	# then the top region on Layer.blockOver + 0.1f. drawPlace (:38-45)
	# is the super call plus the link delegation (link.block.drawPlace at
	# the link tile + rotation, always valid) -- the link is
	# caller-supplied, the pure never calls getLink. drawPlanRegion
	# (:54-58) rects base + side + top at the plan position with the plan
	# rotation driving the side select. icons() (:59-63) returns [region,
	# topRegion] and rides the pure as icon_regions (the N2396 precedent
	# -- a zero-arg pure cannot register). The module has NO drawer field
	# -- draw() is a direct override. Pure-only: the tick never calls
	# draw -- draw is called by the renderer, drawPlace / drawPlanRegion
	# by the placement UI, icons by the atlas, so this proof has no
	# live-tick key.

	# --- Base + inputs: the base rect always draws at (x, y) with region
	# region, the top rect always draws at (x, y) with region topRegion,
	# and the input side regions draw only where blends holds AND the
	# direction is not the module facing -- blends [true, false, true,
	# false] at rotation 1 draws i = 0 (rotation -2, draw rotation -180)
	# and i = 2 (rotation 0, draw rotation 0). The side region at
	# rotation 1 is sideRegion1 (rotation < 2), rotation 1, draw
	# rotation 90.
	var idle: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_draw_state(100.0, 200.0, 1, [true, false, true, false], null, null, null)
	var idle_base: Dictionary = idle.get("base_call", {})
	var idle_inputs: Array = idle.get("input_calls", [])
	var idle_side: Dictionary = idle.get("side_call", {})
	var idle_top: Dictionary = idle.get("top_call", {})
	var idle_first: Dictionary = idle_inputs[0] if idle_inputs.size() > 0 else {}
	var idle_second: Dictionary = idle_inputs[1] if idle_inputs.size() > 1 else {}
	# --- Facing exclusion: blends [true, true, true, true] at rotation 2
	# draws i = 0, 1, 3 only -- i = 2 IS the rotation and is excluded.
	# The side region at rotation 2 is sideRegion2 (rotation >= 2),
	# rotation 2, draw rotation 180.
	var excluded: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_draw_state(0.0, 0.0, 2, [true, true, true, true], null, null, null)
	var excluded_inputs: Array = excluded.get("input_calls", [])
	var excluded_side: Dictionary = excluded.get("side_call", {})
	proof["draw_base_inputs"] = is_equal_approx(float(idle_base.get("x", -1.0)), 100.0) and is_equal_approx(float(idle_base.get("y", -1.0)), 200.0) and str(idle_base.get("region", "")) == "region" and is_equal_approx(float(idle_top.get("x", -1.0)), 100.0) and is_equal_approx(float(idle_top.get("y", -1.0)), 200.0) and str(idle_top.get("region", "")) == "topRegion" and idle_inputs.size() == 2 and int(idle_first.get("index", -1)) == 0 and int(idle_first.get("rotation", -99)) == -2 and is_equal_approx(float(idle_first.get("draw_rotation", -999.0)), -180.0) and int(idle_second.get("index", -1)) == 2 and int(idle_second.get("rotation", -99)) == 0 and is_equal_approx(float(idle_second.get("draw_rotation", -999.0)), 0.0) and str(idle_first.get("region", "")) == "inRegion" and str(idle_second.get("region", "")) == "inRegion" and str(idle_side.get("region", "")) == "sideRegion1" and int(idle_side.get("rotation", -1)) == 1 and is_equal_approx(float(idle_side.get("draw_rotation", -999.0)), 90.0) and excluded_inputs.size() == 3 and int((excluded_inputs[0] as Dictionary).get("index", -1)) == 0 and int((excluded_inputs[1] as Dictionary).get("index", -1)) == 1 and int((excluded_inputs[2] as Dictionary).get("index", -1)) == 3 and str(excluded_side.get("region", "")) == "sideRegion2" and int(excluded_side.get("rotation", -1)) == 2 and is_equal_approx(float(excluded_side.get("draw_rotation", -999.0)), 180.0)

	# --- Payload branch: with no payload held the payload call is empty
	# but payRotation is still rotation * 90 (rotation 1 gives 90 -- the
	# assignment runs unconditionally before drawPayload()); with a held
	# payload at rotation 3 the payload call carries payload.draw() on
	# Layer.blockOver after updatePayload(), with pay_rotation 270.
	var held: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_draw_state(100.0, 200.0, 3, [false, false, false, false], {"kind": "build"}, null, null)
	var held_payload: Dictionary = held.get("payload_call", {})
	proof["draw_payload_branch"] = Dictionary(idle.get("payload_call", {})).is_empty() and not bool(idle.get("has_payload", true)) and is_equal_approx(float(idle.get("pay_rotation", -1.0)), 90.0) and bool(held.get("has_payload", false)) and not held_payload.is_empty() and str(held_payload.get("call", "")) == "payload.draw();" and str(held_payload.get("update_payload_call", "")) == "updatePayload();" and str(held_payload.get("z", "")) == "Layer.blockOver" and is_equal_approx(float(held_payload.get("pay_rotation", -1.0)), 270.0) and is_equal_approx(float(held.get("pay_rotation", -1.0)), 270.0)

	# --- Top region: the top rect always draws at (x, y) with region
	# topRegion on Layer.blockOver + 0.1f -- above the payload z -- with
	# or without a held payload.
	var held_top: Dictionary = held.get("top_call", {})
	proof["draw_top_region"] = str(idle_top.get("region", "")) == "topRegion" and is_equal_approx(float(idle_top.get("x", -1.0)), 100.0) and is_equal_approx(float(idle_top.get("y", -1.0)), 200.0) and str(idle_top.get("z", "")) == "Layer.blockOver + 0.1f" and str(held_top.get("region", "")) == "topRegion" and is_equal_approx(float(held_top.get("x", -1.0)), 100.0) and is_equal_approx(float(held_top.get("y", -1.0)), 200.0) and str(held_top.get("z", "")) == "Layer.blockOver + 0.1f"

	# --- drawPlace link / no-link: with no link the place call is null
	# (the super call is recorded, not modeled -- place_super_expr); with
	# a link the place call delegates to the linked assembler block
	# drawPlace at the link tile (10, 20) + rotation 2, always valid.
	var linked: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_draw_state(100.0, 200.0, 0, [false, false, false, false], null, {"block": "tank-assembler", "tile": {"x": 10, "y": 20}, "rotation": 2}, null)
	var linked_place: Dictionary = linked.get("place_call", {})
	proof["draw_place_link"] = idle.get("place_call", {}) == null and not bool(idle.get("has_link", true)) and str(idle.get("place_super_expr", "")) == "super.drawPlace(x, y, rotation, valid);" and bool(linked.get("has_link", false)) and not linked_place.is_empty() and str(linked_place.get("call", "")) == "link.block.drawPlace(link.tile.x, link.tile.y, link.rotation, true);" and str(linked_place.get("block", "")) == "tank-assembler" and int(linked_place.get("tile_x", -1)) == 10 and int(linked_place.get("tile_y", -1)) == 20 and int(linked_place.get("rotation", -1)) == 2 and bool(linked_place.get("valid", false))

	# --- drawPlanRegion: with no plan the plan call is null; with a plan
	# at (300, 400) rotation 3 the plan call rects the base (region) +
	# the side (sideRegion2 -- plan rotation 3 >= 2, draw rotation 270) +
	# the top (topRegion) at the plan position; a plan at rotation 0
	# takes sideRegion1.
	var planned: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_draw_state(100.0, 200.0, 0, [false, false, false, false], null, null, {"drawx": 300.0, "drawy": 400.0, "rotation": 3})
	var planned_call: Dictionary = planned.get("plan_call", {})
	var planned_base: Dictionary = planned_call.get("base_call", {})
	var planned_side: Dictionary = planned_call.get("side_call", {})
	var planned_top: Dictionary = planned_call.get("top_call", {})
	var planned_flat: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_draw_state(0.0, 0.0, 0, [false, false, false, false], null, null, {"drawx": 0.0, "drawy": 0.0, "rotation": 0})
	var planned_flat_call: Dictionary = planned_flat.get("plan_call", {})
	var planned_flat_side: Dictionary = planned_flat_call.get("side_call", {})
	proof["draw_plan_region"] = idle.get("plan_call", {}) == null and not bool(idle.get("has_plan", true)) and bool(planned.get("has_plan", false)) and not planned_call.is_empty() and str(planned_base.get("region", "")) == "region" and is_equal_approx(float(planned_base.get("x", -1.0)), 300.0) and is_equal_approx(float(planned_base.get("y", -1.0)), 400.0) and str(planned_side.get("region", "")) == "sideRegion2" and int(planned_side.get("rotation", -1)) == 3 and is_equal_approx(float(planned_side.get("draw_rotation", -999.0)), 270.0) and is_equal_approx(float(planned_side.get("x", -1.0)), 300.0) and is_equal_approx(float(planned_side.get("y", -1.0)), 400.0) and str(planned_top.get("region", "")) == "topRegion" and is_equal_approx(float(planned_top.get("x", -1.0)), 300.0) and is_equal_approx(float(planned_top.get("y", -1.0)), 400.0) and str(planned_flat_side.get("region", "")) == "sideRegion1"

	# --- Icons merged: icons() returns [region, topRegion] and rides the
	# draw pure as icon_regions, with or without a plan.
	var idle_icons: Array = idle.get("icon_regions", [])
	var planned_icons: Array = planned.get("icon_regions", [])
	proof["draw_icons_merged"] = idle_icons.size() == 2 and str(idle_icons[0]) == "region" and str(idle_icons[1]) == "topRegion" and planned_icons.size() == 2 and str(planned_icons[0]) == "region" and str(planned_icons[1]) == "topRegion"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
