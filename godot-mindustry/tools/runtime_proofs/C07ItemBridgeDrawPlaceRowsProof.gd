extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
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

	# --- Draw-place rows (N2456): ItemBridge.
	# drawPlace() (ItemBridge.java:118-142),
	# drawPlanConfigTop() (:82-96), drawBridge()
	# (:98-115). drawPlace records super.
	# drawPlace + takes the findLink output
	# caller-supplied (findLink is already live
	# since N2199) + dashes the four Pal.placing
	# range lines in Geometry.d4 order (0 east, 1
	# north, 2 west, 3 south) from tilesize/2f + 2
	# out to range * tilesize + rects the span and
	# arrows the link tile when the Manhattan
	# distance is STRICTLY greater than 1.
	# drawPlanConfigTop gates on the relative
	# Point2 config (|p| <= range on both axes,
	# axis-aligned) + the caller-supplied findPlan
	# result, then drawBridge strokes the
	# bridgeRegion line 4px short of each end and
	# arrows the midpoint at Angles.angle + flip 0
	# unless Renderer.bridgeOpacity is Mathf.zero.
	#
	# Fixture: the placement tile is (10, 20) --
	# world pos (80, 160) -- with the
	# phase-conveyor range 12 (Blocks.java:2118)
	# and bridgeWidth 6.5. rot is
	# link.absoluteRelativeTo(x, y), called ON the
	# link tile: an EAST link has rot 2 (the
	# placement tile is west of it), north 3,
	# west 0, south 1.

	# --- Dash calls: the 4 dashes run in d4
	# order from tilesize/2f + 2 = 6 out to range
	# * tilesize = 96 along each axis, all
	# Pal.placing, segments (int)(90 / 8 * 2) =
	# 22. East (86, 160) -> (176, 160); north
	# (80, 166) -> (80, 256); west (74, 160) ->
	# (-16, 160); south (80, 154) -> (80, 64).
	# With range 4 the east dash ends at 112 and
	# its segments are (int)(26 / 8 * 2) = 6. The
	# super call is recorded, not modeled.
	var placed: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 12, null)
	var dashes: Array = placed.get("dash_calls", [])
	var dash_east: Dictionary = dashes[0]
	var dash_north: Dictionary = dashes[1]
	var dash_west: Dictionary = dashes[2]
	var dash_south: Dictionary = dashes[3]
	var super_place_call: Dictionary = placed.get("super_place_call", {})
	var short_range: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 4, null)
	var short_dashes: Array = short_range.get("dash_calls", [])
	var short_east: Dictionary = short_dashes[0]
	proof["dash_calls"] = dashes.size() == 4 and str(super_place_call.get("call", "")) == "super.drawPlace(x, y, rotation, valid);" and int(super_place_call.get("tile_x", -1)) == 10 and int(super_place_call.get("tile_y", -1)) == 20 and int(dash_east.get("direction", -1)) == 0 and str(dash_east.get("color", "")) == "Pal.placing" and is_equal_approx(float(dash_east.get("x1", -1.0)), 86.0) and is_equal_approx(float(dash_east.get("y1", -1.0)), 160.0) and is_equal_approx(float(dash_east.get("x2", -1.0)), 176.0) and is_equal_approx(float(dash_east.get("y2", -1.0)), 160.0) and int(dash_east.get("segments", -1)) == 22 and int(dash_north.get("direction", -1)) == 1 and is_equal_approx(float(dash_north.get("x1", -1.0)), 80.0) and is_equal_approx(float(dash_north.get("y1", -1.0)), 166.0) and is_equal_approx(float(dash_north.get("x2", -1.0)), 80.0) and is_equal_approx(float(dash_north.get("y2", -1.0)), 256.0) and int(dash_north.get("segments", -1)) == 22 and int(dash_west.get("direction", -1)) == 2 and is_equal_approx(float(dash_west.get("x1", -1.0)), 74.0) and is_equal_approx(float(dash_west.get("y1", -1.0)), 160.0) and is_equal_approx(float(dash_west.get("x2", -1.0)), -16.0) and is_equal_approx(float(dash_west.get("y2", -1.0)), 160.0) and int(dash_west.get("segments", -1)) == 22 and int(dash_south.get("direction", -1)) == 3 and is_equal_approx(float(dash_south.get("x1", -1.0)), 80.0) and is_equal_approx(float(dash_south.get("y1", -1.0)), 154.0) and is_equal_approx(float(dash_south.get("x2", -1.0)), 80.0) and is_equal_approx(float(dash_south.get("y2", -1.0)), 64.0) and int(dash_south.get("segments", -1)) == 22 and is_equal_approx(float(short_east.get("x2", -1.0)), 112.0) and int(short_east.get("segments", -1)) == 6

	# --- Link rect gate: no link, the same tile,
	# or an adjacent link (Manhattan 1) draws no
	# rect and no arrow; a link 3 tiles east
	# draws both. The gate is STRICTLY > 1.
	var no_link: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 12, null)
	var same_tile: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 12, {"x": 10, "y": 20})
	var adjacent: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 12, {"x": 11, "y": 20})
	var linked_east: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 12, {"x": 13, "y": 20})
	proof["link_rect_gate"] = no_link.get("link_rect", {}) == null and no_link.get("arrow_call", {}) == null and same_tile.get("link_rect", {}) == null and same_tile.get("arrow_call", {}) == null and adjacent.get("link_rect", {}) == null and adjacent.get("arrow_call", {}) == null and linked_east.get("link_rect", {}) != null and linked_east.get("arrow_call", {}) != null

	# --- Link rect values: the east link (13, 20)
	# has rot 2, w = 3 * 8 - 8 = 16, h = 8 (same
	# row), rect (84, 156, 16, 8) -- (10+13)/2 *
	# 8 - 8 = 84, (20+20)/2 * 8 - 4 = 156. The
	# north link (10, 23) has rot 3, w = 8, h =
	# 16, rect (76, 164, 8, 16). The west link
	# (7, 20) has rot 0, rect (60, 156, 16, 8).
	# The south link (10, 17) has rot 1, rect
	# (76, 140, 8, 16). The diagonal link (11, 21)
	# passes the gate (Manhattan 2) with rot 3
	# and the degenerate zero-size rect Java draws
	# (w = h = 1 * 8 - 8 = 0) at (84, 164).
	var east_rect: Dictionary = linked_east.get("link_rect", {})
	var linked_north: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 12, {"x": 10, "y": 23})
	var north_rect: Dictionary = linked_north.get("link_rect", {})
	var linked_west: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 12, {"x": 7, "y": 20})
	var west_rect: Dictionary = linked_west.get("link_rect", {})
	var linked_south: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 12, {"x": 10, "y": 17})
	var south_rect: Dictionary = linked_south.get("link_rect", {})
	var linked_diagonal: Dictionary = item_bridge_build_state.source_item_bridge_draw_place_state(10, 20, 12, {"x": 11, "y": 21})
	var diagonal_rect: Dictionary = linked_diagonal.get("link_rect", {})
	proof["link_rect_values"] = int(east_rect.get("rotation", -1)) == 2 and is_equal_approx(float(east_rect.get("x", -1.0)), 84.0) and is_equal_approx(float(east_rect.get("y", -1.0)), 156.0) and is_equal_approx(float(east_rect.get("w", -1.0)), 16.0) and is_equal_approx(float(east_rect.get("h", -1.0)), 8.0) and is_equal_approx(float(east_rect.get("stroke", -1.0)), 1.0) and str(east_rect.get("color", "")) == "Pal.placing" and int(north_rect.get("rotation", -1)) == 3 and is_equal_approx(float(north_rect.get("x", -1.0)), 76.0) and is_equal_approx(float(north_rect.get("y", -1.0)), 164.0) and is_equal_approx(float(north_rect.get("w", -1.0)), 8.0) and is_equal_approx(float(north_rect.get("h", -1.0)), 16.0) and int(west_rect.get("rotation", -1)) == 0 and is_equal_approx(float(west_rect.get("x", -1.0)), 60.0) and is_equal_approx(float(west_rect.get("y", -1.0)), 156.0) and is_equal_approx(float(west_rect.get("w", -1.0)), 16.0) and is_equal_approx(float(west_rect.get("h", -1.0)), 8.0) and int(south_rect.get("rotation", -1)) == 1 and is_equal_approx(float(south_rect.get("x", -1.0)), 76.0) and is_equal_approx(float(south_rect.get("y", -1.0)), 140.0) and is_equal_approx(float(south_rect.get("w", -1.0)), 8.0) and is_equal_approx(float(south_rect.get("h", -1.0)), 16.0) and int(diagonal_rect.get("rotation", -1)) == 3 and is_equal_approx(float(diagonal_rect.get("x", -1.0)), 84.0) and is_equal_approx(float(diagonal_rect.get("y", -1.0)), 164.0) and is_equal_approx(float(diagonal_rect.get("w", -1.0)), 0.0) and is_equal_approx(float(diagonal_rect.get("h", -1.0)), 0.0)

	# --- Arrow call: the "bridge-arrow" rect sits
	# on the link tile offset by d4(rot) toward
	# the placement tile, rotation rot * 90. East
	# link: (96, 160), 180. North link: (80, 176),
	# 270. West link: (64, 160), 0. South link:
	# (80, 144), 90.
	var east_arrow: Dictionary = linked_east.get("arrow_call", {})
	var north_arrow: Dictionary = linked_north.get("arrow_call", {})
	var west_arrow: Dictionary = linked_west.get("arrow_call", {})
	var south_arrow: Dictionary = linked_south.get("arrow_call", {})
	proof["arrow_call"] = str(east_arrow.get("region", "")) == "bridge-arrow" and is_equal_approx(float(east_arrow.get("x", -1.0)), 96.0) and is_equal_approx(float(east_arrow.get("y", -1.0)), 160.0) and is_equal_approx(float(east_arrow.get("rotation_degrees", -1.0)), 180.0) and str(north_arrow.get("region", "")) == "bridge-arrow" and is_equal_approx(float(north_arrow.get("x", -1.0)), 80.0) and is_equal_approx(float(north_arrow.get("y", -1.0)), 176.0) and is_equal_approx(float(north_arrow.get("rotation_degrees", -1.0)), 270.0) and is_equal_approx(float(west_arrow.get("x", -1.0)), 64.0) and is_equal_approx(float(west_arrow.get("y", -1.0)), 160.0) and is_equal_approx(float(west_arrow.get("rotation_degrees", -1.0)), 0.0) and is_equal_approx(float(south_arrow.get("x", -1.0)), 80.0) and is_equal_approx(float(south_arrow.get("y", -1.0)), 144.0) and is_equal_approx(float(south_arrow.get("rotation_degrees", -1.0)), 90.0)

	# --- Valid plan bridge: the east plan (config
	# (3, 0), partner draw pos (104, 160)) finds
	# (13, 20); the v1 offset is (4, 0), so the
	# bridgeRegion line runs (84, 160) -> (100,
	# 160), stroke 6.5, alpha 1.0, and the
	# arrowRegion arrow sits at the midpoint
	# (92, 160) at Angles.angle 0. The north plan
	# (config (0, 3), partner (80, 184)) lines
	# (80, 164) -> (80, 180) with the arrow at
	# (80, 172), angle 90. The west plan (config
	# (-3, 0), partner (56, 160)) lines (76, 160)
	# -> (60, 160) with the arrow at (68, 160),
	# angle 180. The range-boundary plan (config
	# (0, 12), partner (80, 256)) draws: |12| <=
	# 12. The (0, 0) config PASSES the gate and
	# finds the plan's own tile -- with a
	# same-tile partner the zero-length v1 STAYS
	# zero, so the line runs (80, 160) ->
	# (80, 160) with the arrow at (80, 160),
	# angle 0.
	var plan_east: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 3, "y": 0}, 12, {"draw_x": 104.0, "draw_y": 160.0}, 1.0, 6.5)
	var east_bridge: Dictionary = plan_east.get("bridge_call", {})
	var east_line: Dictionary = east_bridge.get("line", {})
	var east_plan_arrow: Dictionary = east_bridge.get("arrow", {})
	var plan_north: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 0, "y": 3}, 12, {"draw_x": 80.0, "draw_y": 184.0}, 1.0, 6.5)
	var north_bridge: Dictionary = plan_north.get("bridge_call", {})
	var north_line: Dictionary = north_bridge.get("line", {})
	var north_plan_arrow: Dictionary = north_bridge.get("arrow", {})
	var plan_west: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": -3, "y": 0}, 12, {"draw_x": 56.0, "draw_y": 160.0}, 1.0, 6.5)
	var west_bridge: Dictionary = plan_west.get("bridge_call", {})
	var west_line: Dictionary = west_bridge.get("line", {})
	var west_plan_arrow: Dictionary = west_bridge.get("arrow", {})
	var plan_edge: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 0, "y": 12}, 12, {"draw_x": 80.0, "draw_y": 256.0}, 1.0, 6.5)
	var edge_bridge: Dictionary = plan_edge.get("bridge_call", {})
	var edge_line: Dictionary = edge_bridge.get("line", {})
	var plan_zero: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 0, "y": 0}, 12, {"draw_x": 80.0, "draw_y": 160.0}, 1.0, 6.5)
	var zero_bridge: Dictionary = plan_zero.get("bridge_call", {})
	var zero_line: Dictionary = zero_bridge.get("line", {})
	var zero_plan_arrow: Dictionary = zero_bridge.get("arrow", {})
	proof["plan_bridge_valid"] = bool(plan_east.get("config_valid", false)) and int(plan_east.get("find_x", -1)) == 13 and int(plan_east.get("find_y", -1)) == 20 and str(plan_east.get("skipped_reason", "x")) == "" and str(east_line.get("region", "")) == "bridgeRegion" and is_equal_approx(float(east_line.get("stroke", -1.0)), 6.5) and is_equal_approx(float(east_line.get("x1", -1.0)), 84.0) and is_equal_approx(float(east_line.get("y1", -1.0)), 160.0) and is_equal_approx(float(east_line.get("x2", -1.0)), 100.0) and is_equal_approx(float(east_line.get("y2", -1.0)), 160.0) and str(east_plan_arrow.get("region", "")) == "arrowRegion" and is_equal_approx(float(east_plan_arrow.get("x", -1.0)), 92.0) and is_equal_approx(float(east_plan_arrow.get("y", -1.0)), 160.0) and is_equal_approx(float(east_plan_arrow.get("angle_degrees", -1.0)), 0.0) and is_equal_approx(float(east_bridge.get("alpha", -1.0)), 1.0) and is_equal_approx(float(east_bridge.get("flip", -1.0)), 0.0) and is_equal_approx(float(north_line.get("x1", -1.0)), 80.0) and is_equal_approx(float(north_line.get("y1", -1.0)), 164.0) and is_equal_approx(float(north_line.get("x2", -1.0)), 80.0) and is_equal_approx(float(north_line.get("y2", -1.0)), 180.0) and is_equal_approx(float(north_plan_arrow.get("x", -1.0)), 80.0) and is_equal_approx(float(north_plan_arrow.get("y", -1.0)), 172.0) and is_equal_approx(float(north_plan_arrow.get("angle_degrees", -1.0)), 90.0) and is_equal_approx(float(west_line.get("x1", -1.0)), 76.0) and is_equal_approx(float(west_line.get("y1", -1.0)), 160.0) and is_equal_approx(float(west_line.get("x2", -1.0)), 60.0) and is_equal_approx(float(west_line.get("y2", -1.0)), 160.0) and is_equal_approx(float(west_plan_arrow.get("x", -1.0)), 68.0) and is_equal_approx(float(west_plan_arrow.get("y", -1.0)), 160.0) and is_equal_approx(float(west_plan_arrow.get("angle_degrees", -1.0)), 180.0) and bool(plan_edge.get("config_valid", false)) and is_equal_approx(float(edge_line.get("y1", -1.0)), 164.0) and is_equal_approx(float(edge_line.get("y2", -1.0)), 252.0) and bool(plan_zero.get("config_valid", false)) and int(plan_zero.get("find_x", -1)) == 10 and int(plan_zero.get("find_y", -1)) == 20 and is_equal_approx(float(zero_line.get("x1", -1.0)), 80.0) and is_equal_approx(float(zero_line.get("y1", -1.0)), 160.0) and is_equal_approx(float(zero_line.get("x2", -1.0)), 80.0) and is_equal_approx(float(zero_line.get("y2", -1.0)), 160.0) and is_equal_approx(float(zero_plan_arrow.get("angle_degrees", -1.0)), 0.0)

	# --- Invalid plan bridge: a null config, an
	# Integer config, a diagonal config (3, 3),
	# and an out-of-range config (13, 0) all fail
	# the config gate (reason "invalid_config",
	# no find coords). A valid config with no
	# findPlan result fails with "no_other_req"
	# (the config IS valid, find (13, 20) is
	# still reported). A valid config + partner
	# with zero opacity fails with "zero_opacity"
	# -- and the Mathf.zero epsilon applies:
	# 0.0000005 (<= 1e-6) is zero, but 0.000002
	# (> 1e-6) draws.
	var plan_null: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, null, 12, {"draw_x": 104.0, "draw_y": 160.0}, 1.0, 6.5)
	var plan_int: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, 5, 12, {"draw_x": 104.0, "draw_y": 160.0}, 1.0, 6.5)
	var plan_diagonal: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 3, "y": 3}, 12, {"draw_x": 104.0, "draw_y": 184.0}, 1.0, 6.5)
	var plan_far: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 13, "y": 0}, 12, {"draw_x": 184.0, "draw_y": 160.0}, 1.0, 6.5)
	var plan_no_other: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 3, "y": 0}, 12, null, 1.0, 6.5)
	var plan_faded: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 3, "y": 0}, 12, {"draw_x": 104.0, "draw_y": 160.0}, 0.0, 6.5)
	var plan_epsilon_zero: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 3, "y": 0}, 12, {"draw_x": 104.0, "draw_y": 160.0}, 0.0000005, 6.5)
	var plan_epsilon_draws: Dictionary = item_bridge_build_state.source_item_bridge_draw_plan_config_top_state(10, 20, {"x": 3, "y": 0}, 12, {"draw_x": 104.0, "draw_y": 160.0}, 0.000002, 6.5)
	proof["plan_bridge_invalid"] = plan_null.get("bridge_call", {}) == null and not bool(plan_null.get("config_valid", true)) and str(plan_null.get("skipped_reason", "")) == "invalid_config" and plan_null.get("find_x", -1) == null and plan_null.get("find_y", -1) == null and plan_int.get("bridge_call", {}) == null and str(plan_int.get("skipped_reason", "")) == "invalid_config" and plan_diagonal.get("bridge_call", {}) == null and str(plan_diagonal.get("skipped_reason", "")) == "invalid_config" and plan_far.get("bridge_call", {}) == null and str(plan_far.get("skipped_reason", "")) == "invalid_config" and plan_no_other.get("bridge_call", {}) == null and bool(plan_no_other.get("config_valid", false)) and str(plan_no_other.get("skipped_reason", "")) == "no_other_req" and int(plan_no_other.get("find_x", -1)) == 13 and int(plan_no_other.get("find_y", -1)) == 20 and plan_faded.get("bridge_call", {}) == null and str(plan_faded.get("skipped_reason", "")) == "zero_opacity" and plan_epsilon_zero.get("bridge_call", {}) == null and str(plan_epsilon_zero.get("skipped_reason", "")) == "zero_opacity" and plan_epsilon_draws.get("bridge_call", {}) != null and str(plan_epsilon_draws.get("skipped_reason", "x")) == ""

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeDrawPlaceRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
