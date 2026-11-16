extends Node

const main_scene := preload("res://scenes/Main.tscn")
const stack_conveyor_build_state := preload("res://src/game/SourceStackConveyorBuildState.gd")
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

	# --- Draw rows (N2434): StackConveyorBuild.drawCached()
	# (StackConveyor.java:124-149) rects regions[state] at
	# rotdeg(), the edge rects where the blendprox bit is
	# clear, the sliced bottom inputs while stateLoad and
	# the sliced top front rect while stateUnload; draw()
	# (StackConveyor.java:151-192) glows additively by
	# power.status when the glow region is found (region
	# edgeGlowRegion while stateLoad else glowRegion),
	# returns early when link == -1 or from == null or
	# lastItem == null, then interpolates the stack
	# position from the link tile with Interp.linear at
	# 1 - cooldown and lerps its angle with Interp.smooth
	# at 1 - clamp(cooldown * 2, 0, 1) (3->0 rewrites a
	# to -90, 0->3 rewrites a to 360), and draws the last
	# item at itemSize * lerp(min(items.total() /
	# itemCapacity, 1), 1, 0.4). Pure-only: the tick
	# never calls draw -- draw is called by the renderer,
	# and the renderer call site waits for a renderer
	# slice, so this proof has no live-tick key.

	# --- Cached load branch: stateLoad with blendprox
	# 0b1011 (bit 2 clear) draws the base regions[1] at
	# rotation 0, exactly one edge rect (side 2, rotation
	# -180) and two bottom-slice inputs -- side 1 at dir
	# 3 (100, 194, rotation 270) and side 3 at dir 1
	# (100, 206, rotation 90), each offset 8 * 0.75 = 6
	# along d4. A square-sprite neighbour (near_square
	# true) or a missing neighbour (null) suppresses its
	# own input slice only.
	var load: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 1, 11, [null, false, null, false], null, -1, null, true, null, -1.0, false, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var load_cached: Dictionary = load.get("cached_call", {})
	var load_base: Dictionary = load_cached.get("base", {})
	var load_edges: Array = load_cached.get("edge_calls", [])
	var load_inputs: Array = load_cached.get("input_calls", [])
	var load_square: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 1, 11, [null, true, null, false], null, -1, null, true, null, -1.0, false, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var load_square_inputs: Array = (load_square.get("cached_call", {}) as Dictionary).get("input_calls", [])
	var load_null: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 1, 11, [null, false, null, null], null, -1, null, true, null, -1.0, false, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var load_null_inputs: Array = (load_null.get("cached_call", {}) as Dictionary).get("input_calls", [])
	var load_first: Dictionary = load_inputs[0] if load_inputs.size() > 0 else {}
	var load_second: Dictionary = load_inputs[1] if load_inputs.size() > 1 else {}
	var load_edge: Dictionary = load_edges[0] if load_edges.size() > 0 else {}
	proof["draw_cached_load"] = str(load_base.get("region", "")) == "regions[1]" and is_equal_approx(float(load_base.get("rotation", -1.0)), 0.0) and load_edges.size() == 1 and int(load_edge.get("side", -1)) == 2 and is_equal_approx(float(load_edge.get("rotation", -1.0)), -180.0) and load_inputs.size() == 2 and is_equal_approx(float(load_first.get("x", -1.0)), 100.0) and is_equal_approx(float(load_first.get("y", -1.0)), 194.0) and is_equal_approx(float(load_first.get("rotation", -1.0)), 270.0) and str(load_first.get("region", "")) == "sliced(regions[0], bottom)" and is_equal_approx(float(load_second.get("x", -1.0)), 100.0) and is_equal_approx(float(load_second.get("y", -1.0)), 206.0) and is_equal_approx(float(load_second.get("rotation", -1.0)), 90.0) and load_square_inputs.size() == 1 and load_null_inputs.size() == 1

	# --- Cached unload branch: stateUnload with
	# blendprox bit 0 set and a non-square front
	# building draws the base regions[2], three edge
	# rects (sides 1-3) and one top-slice front rect at
	# (106, 200), rotation 0. A square front, a missing
	# front, or a clear bit 0 draws no front rect.
	var unload: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 2, 1, [null, null, null, null], false, -1, null, true, null, -1.0, false, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var unload_cached: Dictionary = unload.get("cached_call", {})
	var unload_base: Dictionary = unload_cached.get("base", {})
	var unload_edges: Array = unload_cached.get("edge_calls", [])
	var unload_inputs: Array = unload_cached.get("input_calls", [])
	var unload_front: Dictionary = unload_inputs[0] if unload_inputs.size() > 0 else {}
	var unload_square: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 2, 1, [null, null, null, null], true, -1, null, true, null, -1.0, false, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var unload_square_inputs: Array = (unload_square.get("cached_call", {}) as Dictionary).get("input_calls", [])
	var unload_null: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 2, 1, [null, null, null, null], null, -1, null, true, null, -1.0, false, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var unload_null_inputs: Array = (unload_null.get("cached_call", {}) as Dictionary).get("input_calls", [])
	var unload_nobit: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 2, 0, [null, null, null, null], false, -1, null, true, null, -1.0, false, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var unload_nobit_inputs: Array = (unload_nobit.get("cached_call", {}) as Dictionary).get("input_calls", [])
	proof["draw_cached_unload"] = str(unload_base.get("region", "")) == "regions[2]" and unload_edges.size() == 3 and unload_inputs.size() == 1 and str(unload_front.get("region", "")) == "sliced(regions[0], top)" and is_equal_approx(float(unload_front.get("x", -1.0)), 106.0) and is_equal_approx(float(unload_front.get("y", -1.0)), 200.0) and is_equal_approx(float(unload_front.get("rotation", -1.0)), 0.0) and unload_square_inputs.is_empty() and unload_null_inputs.is_empty() and unload_nobit_inputs.is_empty()

	# --- Glow gate + region select: the glow draws at
	# power.status 0.5 with alpha glowAlpha * 0.5 = 0.5
	# on Layer.blockAdditive -- edgeGlowRegion while
	# stateLoad, glowRegion otherwise -- and it draws
	# even when link == -1 (the glow is before the
	# early return). The gate fails when power.status
	# is 0, when power is null (-1 sentinel), or when
	# the glow region is not found.
	var glow_load: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 1, 0, [null, null, null, null], null, -1, null, true, null, 0.5, true, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var glow_load_call: Dictionary = glow_load.get("glow_call", {})
	var glow_move: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 0, 0, [null, null, null, null], null, -1, null, true, null, 0.5, true, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var glow_move_call: Dictionary = glow_move.get("glow_call", {})
	var glow_zero: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 1, 0, [null, null, null, null], null, -1, null, true, null, 0.0, true, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var glow_null_power: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 1, 0, [null, null, null, null], null, -1, null, true, null, -1.0, true, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	var glow_not_found: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 1, 0, [null, null, null, null], null, -1, null, true, null, 0.5, false, "Pal.redLight", 1.0, 0.0, 0, 10, 5.0)
	proof["draw_glow"] = str(glow_load_call.get("region", "")) == "edgeGlowRegion" and is_equal_approx(float(glow_load_call.get("alpha", -1.0)), 0.5) and str(glow_load_call.get("color", "")) == "Pal.redLight" and str(glow_load_call.get("z", "")) == "Layer.blockAdditive" and is_equal_approx(float(glow_load_call.get("rotation", -1.0)), 0.0) and glow_load.get("stack_call", {}) == null and str(glow_move_call.get("region", "")) == "glowRegion" and glow_zero.get("glow_call", {}) == null and glow_null_power.get("glow_call", {}) == null and glow_not_found.get("glow_call", {}) == null

	# --- Stack interpolate + angle wraparound: from
	# (92, 200) at cooldown 0.25 the stack sits at
	# lerp(92, 100, 0.75) = 98, and fromRot 3 to
	# rotation 0 rewrites a to -90, so the angle is
	# lerp(-90, 0, smooth(0.5)) = lerp(-90, 0, 0.5) =
	# -45, at z Layer.blockAdditive + 0.01f (glow
	# found). The other wraparound -- fromRot 0 to
	# rotation 3 at cooldown 0 -- rewrites a to 360
	# and lands at angle 270, at z Layer.block - 0.1f
	# (glow not found). A null from build falls back
	# to this rotation, so the angle is 0.
	var stack: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 0, 0, [null, null, null, null], null, 5, {"x": 92.0, "y": 200.0, "rotation": 3}, false, {"icon": "copper"}, -1.0, true, "Pal.redLight", 1.0, 0.25, 5, 10, 5.0)
	var stack_call: Dictionary = stack.get("stack_call", {})
	var stack_wrap: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 3, 0, 0, [null, null, null, null], null, 5, {"x": 100.0, "y": 192.0, "rotation": 0}, false, {"icon": "copper"}, -1.0, false, "Pal.redLight", 1.0, 0.0, 5, 10, 5.0)
	var stack_wrap_call: Dictionary = stack_wrap.get("stack_call", {})
	var stack_nobuild: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 0, 0, [null, null, null, null], null, 5, {"x": 92.0, "y": 200.0, "rotation": 3}, true, {"icon": "copper"}, -1.0, false, "Pal.redLight", 1.0, 0.25, 5, 10, 5.0)
	proof["draw_stack"] = is_equal_approx(float(stack.get("stack_x", -1.0)), 98.0) and is_equal_approx(float(stack.get("stack_y", -1.0)), 200.0) and is_equal_approx(float(stack.get("stack_angle", -1.0)), -45.0) and str(stack_call.get("region", "")) == "stackRegion" and is_equal_approx(float(stack_call.get("rotation", -1.0)), -45.0) and str(stack_call.get("z", "")) == "Layer.blockAdditive + 0.01f" and is_equal_approx(float(stack_wrap.get("stack_x", -1.0)), 100.0) and is_equal_approx(float(stack_wrap.get("stack_y", -1.0)), 200.0) and is_equal_approx(float(stack_wrap.get("stack_angle", -1.0)), 270.0) and str(stack_wrap_call.get("z", "")) == "Layer.block - 0.1f" and is_equal_approx(float(stack_nobuild.get("stack_angle", -1.0)), 0.0)

	# --- Item size lerp: at 5/10 items the size is
	# 5 * lerp(0.5, 1, 0.4) = 3.5, at 10/10 it is 5,
	# over capacity it stays 5 (min clamps the fill
	# to 1), and empty it is 5 * lerp(0, 1, 0.4) = 2.
	# The item rect carries the lastItem icon at the
	# interpolated position, rotation 0.
	var item_call: Dictionary = stack.get("item_call", {})
	var item_full: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 0, 0, [null, null, null, null], null, 5, {"x": 92.0, "y": 200.0, "rotation": 3}, false, {"icon": "copper"}, -1.0, true, "Pal.redLight", 1.0, 0.25, 10, 10, 5.0)
	var item_over: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 0, 0, [null, null, null, null], null, 5, {"x": 92.0, "y": 200.0, "rotation": 3}, false, {"icon": "copper"}, -1.0, true, "Pal.redLight", 1.0, 0.25, 15, 10, 5.0)
	var item_empty: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 0, 0, [null, null, null, null], null, 5, {"x": 92.0, "y": 200.0, "rotation": 3}, false, {"icon": "copper"}, -1.0, true, "Pal.redLight", 1.0, 0.25, 0, 10, 5.0)
	proof["draw_item_size"] = is_equal_approx(float(stack.get("item_size", -1.0)), 3.5) and is_equal_approx(float(item_call.get("size", -1.0)), 3.5) and str(item_call.get("icon", "")) == "copper" and is_equal_approx(float(item_call.get("x", -1.0)), 98.0) and is_equal_approx(float(item_call.get("y", -1.0)), 200.0) and is_equal_approx(float(item_call.get("rotation", -1.0)), 0.0) and is_equal_approx(float(item_full.get("item_size", -1.0)), 5.0) and is_equal_approx(float(item_over.get("item_size", -1.0)), 5.0) and is_equal_approx(float(item_empty.get("item_size", -1.0)), 2.0)

	# --- Early return: link -1, a null from tile, or
	# a null lastItem all null the stack + item calls
	# and zero the stack position / angle / item size
	# -- while the cached call still draws and the
	# glow still draws when its own gate passes.
	var early_link: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 0, 0, [null, null, null, null], null, -1, {"x": 92.0, "y": 200.0, "rotation": 3}, false, {"icon": "copper"}, 0.5, true, "Pal.redLight", 1.0, 0.25, 5, 10, 5.0)
	var early_from: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 0, 0, [null, null, null, null], null, 5, null, false, {"icon": "copper"}, -1.0, false, "Pal.redLight", 1.0, 0.25, 5, 10, 5.0)
	var early_item: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_state(100.0, 200.0, 0, 0, 0, [null, null, null, null], null, 5, {"x": 92.0, "y": 200.0, "rotation": 3}, false, null, -1.0, false, "Pal.redLight", 1.0, 0.25, 5, 10, 5.0)
	var early_cached: Dictionary = early_link.get("cached_call", {})
	proof["draw_early_return"] = early_link.get("stack_call", {}) == null and early_link.get("item_call", {}) == null and is_equal_approx(float(early_link.get("stack_x", -1.0)), 0.0) and is_equal_approx(float(early_link.get("stack_angle", -1.0)), 0.0) and is_equal_approx(float(early_link.get("item_size", -1.0)), 0.0) and early_from.get("stack_call", {}) == null and early_from.get("item_call", {}) == null and early_item.get("stack_call", {}) == null and early_item.get("item_call", {}) == null and not early_cached.is_empty() and early_link.get("glow_call", {}) != null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackConveyorDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
