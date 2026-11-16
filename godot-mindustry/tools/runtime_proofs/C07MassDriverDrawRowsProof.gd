extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mass_driver_build_state := preload("res://src/game/SourceMassDriverBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Draw rows (N2396): MassDriverBuild.draw()
	# (MassDriver.java:230-242), drawConfigure()
	# (:244-264), drawPlace() (:80-102), icons()
	# (:75-77). draw() rects the baseRegion, then the
	# turret-layer shadow + region rect recoiling
	# reloadCounter * knockback (4f) along rotation +
	# 180f -- the shadow shifts by the INT-divided
	# (size / 2), so a size-3 driver shifts by 1, NOT
	# 1.5. drawConfigure() pulses on absin(Time.time,
	# 6f, 1f) -- Java-exact through the shared helper
	# at the DOUBLED scale 12f (the N2372 lesson) --
	# and draws the accent self circle, per-shooter
	# place circles/arrows, the linked-target
	# circle/arrow behind linkValid(), and the range
	# dash circle. drawPlace() always draws the accent
	# range dash circle at x * tilesize (NO offset),
	# then the dotted link line toward a selected
	# in-range mass driver (segs = dst / tilesize, gray
	# stroke 4f then placing stroke 2f). icons() returns
	# [baseRegion, region]. Pure-only: the tick never
	# calls draw -- draw is called by the renderer,
	# drawConfigure/drawPlace by the UI, icons by the
	# atlas.

	# --- Base / shadow: a ready driver (reloadCounter
	# 0.0) sits centered -- base rect, shadow and rect
	# all at (100, 200) except the shadow, which shifts
	# by the int-divided size / 2 = 1 to (99, 199). A
	# just-fired driver (reloadCounter 1.0, rotation 90)
	# recoils 4.0 along rotation + 180f = 270 degrees,
	# i.e. straight down in world coords: rect (100,
	# 196), shadow (99, 195). Rotation 0 with
	# reloadCounter 1.0 recoils along 180 degrees, i.e.
	# straight left: rect (96, 200), rotation -90.
	var ready: Dictionary = mass_driver_build_state.source_mass_driver_draw_rows_state(100.0, 200.0, 90.0, 0.0, 3)
	var ready_base: Dictionary = ready.get("base_call", {})
	var ready_shadow: Dictionary = ready.get("shadow_call", {})
	var ready_rect: Dictionary = ready.get("rect_call", {})
	var fired: Dictionary = mass_driver_build_state.source_mass_driver_draw_rows_state(100.0, 200.0, 90.0, 1.0, 3)
	var fired_shadow: Dictionary = fired.get("shadow_call", {})
	var fired_rect: Dictionary = fired.get("rect_call", {})
	var left: Dictionary = mass_driver_build_state.source_mass_driver_draw_rows_state(100.0, 200.0, 0.0, 1.0, 3)
	var left_rect: Dictionary = left.get("rect_call", {})
	proof["draw_base_shadow"] = is_equal_approx(float(ready_base.get("x", -1.0)), 100.0) and is_equal_approx(float(ready_base.get("y", -1.0)), 200.0) and str(ready_base.get("region", "")) == "baseRegion" and is_equal_approx(float(ready_shadow.get("x", -1.0)), 99.0) and is_equal_approx(float(ready_shadow.get("y", -1.0)), 199.0) and is_equal_approx(float(ready_rect.get("x", -1.0)), 100.0) and is_equal_approx(float(ready_rect.get("y", -1.0)), 200.0) and is_equal_approx(float(ready_rect.get("rotation", -1.0)), 0.0) and is_equal_approx(float(fired.get("kick", -1.0)), 4.0) and is_equal_approx(float(fired_rect.get("x", -1.0)), 100.0) and is_equal_approx(float(fired_rect.get("y", -1.0)), 196.0) and is_equal_approx(float(fired_shadow.get("x", -1.0)), 99.0) and is_equal_approx(float(fired_shadow.get("y", -1.0)), 195.0) and is_equal_approx(float(left_rect.get("x", -1.0)), 96.0) and is_equal_approx(float(left_rect.get("y", -1.0)), 200.0) and is_equal_approx(float(left_rect.get("rotation", -1.0)), -90.0)

	# --- DrawConfigure link: at time 0 the pulse sin is
	# absin(0, 6f, 1f) = 0.5, so the self radius is
	# (3 / 2f + 1) * 8 + 0.5 - 2 = 18.5, the arrow
	# length is 3 * 8 + 0.5 = 24.5 and the arrow width
	# is 4 + 0.5 = 4.5. One shooter at (80, 0) adds a
	# place circle + a place arrow toward self; a valid
	# link to (0, 80) adds a place target circle + an
	# accent link arrow (the link arrow has NO color
	# arg -- it inherits the current Draw.color,
	# Pal.accent). The range dash circle is always
	# drawn at radius 440. Unlinked with no shooters,
	# only the self circle + the dash circle remain.
	var shooters: Array = [{"x": 80.0, "y": 0.0}]
	var linked: Dictionary = {"x": 0.0, "y": 80.0, "block_size": 3}
	var configured: Dictionary = mass_driver_build_state.source_mass_driver_draw_configure_state(0.0, 0.0, 3, 440.0, 0.0, shooters, true, linked)
	var configured_circles: Array = configured.get("circle_calls", [])
	var configured_arrows: Array = configured.get("arrow_calls", [])
	var configured_dash: Dictionary = configured.get("dash_circle_call", {})
	var unlinked_configured: Dictionary = mass_driver_build_state.source_mass_driver_draw_configure_state(0.0, 0.0, 3, 440.0, 0.0, [], false, {})
	proof["draw_configure_link"] = is_equal_approx(float(configured.get("sin_value", -1.0)), 0.5) and is_equal_approx(float(configured.get("self_radius", -1.0)), 18.5) and is_equal_approx(float(configured.get("arrow_length", -1.0)), 24.5) and is_equal_approx(float(configured.get("arrow_width", -1.0)), 4.5) and int(configured.get("shooter_count", -1)) == 1 and configured_circles.size() == 3 and str(configured_circles[0].get("color", "")) == "Pal.accent" and is_equal_approx(float(configured_circles[1].get("x", -1.0)), 80.0) and str(configured_circles[1].get("color", "")) == "Pal.place" and is_equal_approx(float(configured_circles[2].get("y", -1.0)), 80.0) and str(configured_circles[2].get("color", "")) == "Pal.place" and configured_arrows.size() == 2 and str(configured_arrows[0].get("color", "")) == "Pal.place" and str(configured_arrows[1].get("color", "")) == "Pal.accent" and is_equal_approx(float(configured_dash.get("radius", -1.0)), 440.0) and str(configured_dash.get("color", "")) == "Pal.accent" and (unlinked_configured.get("circle_calls", []) as Array).size() == 1 and (unlinked_configured.get("arrow_calls", []) as Array).is_empty()

	# --- DrawPlace range: placing at tile (10, 20)
	# draws the accent dash circle at (80, 160) --
	# x * tilesize with NO offset -- at the def range
	# 440, even with the config panel hidden (the dash
	# circle is drawn before the config early returns)
	# and no link line. The Block offset is 0.0 for the
	# odd size-3 driver and 4.0 for an even size-2
	# block (`offset = ((size + 1) % 2) * tilesize / 2f;`,
	# Block.java:761).
	var placing: Dictionary = mass_driver_build_state.source_mass_driver_draw_place_state(10, 20, 3, 440.0, 0.0, false, {})
	var placing_dash: Dictionary = placing.get("dash_circle_call", {})
	var placing_even: Dictionary = mass_driver_build_state.source_mass_driver_draw_place_state(0, 0, 2, 440.0, 0.0, false, {})
	proof["draw_place_range"] = is_equal_approx(float(placing_dash.get("x", -1.0)), 80.0) and is_equal_approx(float(placing_dash.get("y", -1.0)), 160.0) and is_equal_approx(float(placing_dash.get("radius", -1.0)), 440.0) and str(placing_dash.get("color", "")) == "Pal.accent" and not bool(placing.get("link_line_shown", true)) and (placing.get("link_line_calls", []) as Array).is_empty() and is_equal_approx(float(placing.get("offset", -1.0)), 0.0) and is_equal_approx(float(placing_even.get("offset", -1.0)), 4.0)

	# --- DrawPlace link line: with the config panel
	# shown and a mass driver selected at (80, 240) in
	# range of the (80, 160) placement point, the
	# dotted line runs from (80, 219) to (80, 181) --
	# the (0, -80) vector limited to (3 / 2f + 1) * 8
	# + 0.5 + 0.5 = 21.0 -- with segs = 80 / 8 = 10,
	# drawn twice (gray stroke 4f, then placing stroke
	# 2f). A selected non-driver, an out-of-range
	# driver, or a hidden config panel draws no line.
	var selected: Dictionary = {"x": 80.0, "y": 240.0, "is_mass_driver": true, "within_range": true}
	var placing_linked: Dictionary = mass_driver_build_state.source_mass_driver_draw_place_state(10, 20, 3, 440.0, 0.0, true, selected)
	var placing_linked_calls: Array = placing_linked.get("link_line_calls", [])
	var wrong_block: Dictionary = {"x": 80.0, "y": 240.0, "is_mass_driver": false, "within_range": true}
	var placing_wrong: Dictionary = mass_driver_build_state.source_mass_driver_draw_place_state(10, 20, 3, 440.0, 0.0, true, wrong_block)
	var out_of_range: Dictionary = {"x": 80.0, "y": 240.0, "is_mass_driver": true, "within_range": false}
	var placing_far: Dictionary = mass_driver_build_state.source_mass_driver_draw_place_state(10, 20, 3, 440.0, 0.0, true, out_of_range)
	var placing_hidden: Dictionary = mass_driver_build_state.source_mass_driver_draw_place_state(10, 20, 3, 440.0, 0.0, false, selected)
	proof["draw_place_link_line"] = bool(placing_linked.get("link_line_shown", false)) and int(placing_linked.get("segs", -1)) == 10 and is_equal_approx(float(placing_linked.get("line_x1", -1.0)), 80.0) and is_equal_approx(float(placing_linked.get("line_y1", -1.0)), 219.0) and is_equal_approx(float(placing_linked.get("line_x2", -1.0)), 80.0) and is_equal_approx(float(placing_linked.get("line_y2", -1.0)), 181.0) and placing_linked_calls.size() == 2 and is_equal_approx(float(placing_linked_calls[0].get("stroke", -1.0)), 4.0) and str(placing_linked_calls[0].get("color", "")) == "Pal.gray" and is_equal_approx(float(placing_linked_calls[1].get("stroke", -1.0)), 2.0) and str(placing_linked_calls[1].get("color", "")) == "Pal.placing" and not bool(placing_wrong.get("link_line_shown", true)) and not bool(placing_far.get("link_line_shown", true)) and not bool(placing_hidden.get("link_line_shown", true))

	# --- Icons: [baseRegion, region], in Java order --
	# folded into the draw pure (icons() takes no args
	# and the SSOT schema validator requires non-empty
	# input keys), the two regions draw() draws.
	var icons: Dictionary = mass_driver_build_state.source_mass_driver_draw_rows_state(0.0, 0.0, 90.0, 0.0, 3)
	proof["draw_icons"] = (icons.get("icon_regions", []) as Array) == ["baseRegion", "region"]

	# --- Live frame values: a placed mass driver's
	# frame rotation / reloadCounter / link feed the
	# draw pures. The frame starts at rotation 90.0
	# with reload_counter 1.0 (just shot) and link -1;
	# one N2237 advance tick (delta 1.0, timeScale 1.0,
	# reload 200f) drains edelta / reload = 1.0 / 200 =
	# 0.005, so the live reload_counter is 0.995 and
	# the draw recoil is 0.995 * 4.0 = 3.98: at the
	# cell (28, 21) world position (224, 168) the rect
	# sits at y 164.02 and the shadow at y 163.02 (the
	# int-divided size / 2 = 1 shift). The unlinked
	# frame draws no link circle or arrow.
	var mass_driver_cell := Vector2i(28, 21)
	var mass_driver := Sprite2D.new()
	game.add_child(mass_driver)
	game.call("record_placed_block", mass_driver, blocks_by_id["mass-driver"], mass_driver_cell)
	mass_driver_build_state.source_mass_driver_bind_frame_state(mass_driver, blocks_by_id["mass-driver"])
	var mass_driver_frame: Dictionary = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	mass_driver_frame["efficiency"] = 1.0
	mass_driver_frame["reload_counter"] = 1.0
	var this_pos: int = (28 << 16) | 21
	var item_order: Array = ["copper", "lead"]
	var unlinked: Dictionary = {"exists": false, "pos": -1, "is_mass_driver": false, "same_block": false, "same_team": false, "within_range": false, "item_capacity": 120, "items_total": 0, "state": "idle", "rotation": 90.0, "waiting_shooters": [], "x": 0.0, "y": 0.0}
	var advanced: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(mass_driver_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, unlinked, {}, item_order)
	mass_driver_frame["reload_counter"] = advanced.get("reload_counter", mass_driver_frame.get("reload_counter", -1.0))
	var live_draw: Dictionary = mass_driver_build_state.source_mass_driver_draw_rows_state(224.0, 168.0, float(mass_driver_frame.get("rotation", -1.0)), float(mass_driver_frame.get("reload_counter", -1.0)), 3)
	var live_rect: Dictionary = live_draw.get("rect_call", {})
	var live_shadow: Dictionary = live_draw.get("shadow_call", {})
	var live_configure: Dictionary = mass_driver_build_state.source_mass_driver_draw_configure_state(224.0, 168.0, 3, 440.0, 0.0, [], int(mass_driver_frame.get("link", -1)) != -1, unlinked)
	proof["draw_live_frame_values"] = is_equal_approx(float(mass_driver_frame.get("reload_counter", -1.0)), 0.995) and int(mass_driver_frame.get("link", 0)) == -1 and is_equal_approx(float(live_rect.get("y", -1.0)), 164.02) and is_equal_approx(float(live_shadow.get("y", -1.0)), 163.02) and (live_configure.get("circle_calls", []) as Array).size() == 1 and (live_configure.get("arrow_calls", []) as Array).is_empty()

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MassDriverDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
