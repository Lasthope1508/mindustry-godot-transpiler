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

	# --- Draw rows (N2429): ItemBridgeBuild.draw()
	# (ItemBridge.java:371-420), drawSelect()
	# (:223-231), drawInput() (:233-266),
	# drawConfigure() (:269-281). draw() rects the
	# endRegion pair at i * 90 + 90 / + 270, strokes
	# the bridgeRegion line 4px short of each end,
	# and draws the Lod.l1 moving arrows; the draw
	# warmup is `float warmup = hasPower ? this.
	# warmup : 1f;` (:387) with the fadeIn 0.25f
	# alpha floor, and the pulse color is LIVE for
	# the phase-conveyor (`pulse = true;`,
	# Blocks.java:2124). The warmup APPROACH (:345)
	# is updateTile logic, already live since N2225
	# -- NOT ported here. drawSelect draws the link
	# input + one drawInput per incoming pos.
	# drawInput pulses its alpha by |(linked ? 100
	# : 0) - (Time.time * 2) % 100| / 100 and lerps
	# its arrow from the other tile to this one at
	# rel * 90. drawConfigure selects this tile +
	# one select per linkValid candidate (linked ?
	# Pal.place : Pal.breakInvalid, the unlinked
	# radius pulsing by absin(Time.time, 4f, 1f)).
	# ItemBridge has NO icons() override and
	# moveArrows is a dead field. Pure-only: the
	# tick never calls draw.
	#
	# Fixture: the bridge sits on tile (10, 20) --
	# world pos (80, 160) -- linked east to tile
	# (13, 20), draw pos (104, 160), so the link
	# direction i is 0 and dist is 2. The packed
	# link pos is (13 << 16) | 20. The incoming
	# tile is (10, 17), draw pos (80, 136), packed
	# (10 << 16) | 17. Phase-conveyor def values:
	# bridgeWidth 6.5, arrowSpacing 4, arrowOffset
	# 2, arrowPeriod 0.9, arrowTimeScl 2.75, size 1.

	var link_pos: int = (13 << 16) | 20
	var incoming_pos: int = (10 << 16) | 17
	var no_incoming: Array = []
	var no_candidates: Array = []

	# --- Draw warmup: hasPower true reads the
	# frame warmup (0.5) and the fadeIn alpha is
	# max(0.5, 0.25) * 1 = 0.5; hasPower false
	# always draws warmup 1f (frame 0.3 ignored)
	# and the alpha is 1.0; a frame warmup of 0.1
	# hits the 0.25f floor when fadeIn is true
	# (alpha 0.25) but draws full alpha 1.0 when
	# fadeIn is false.
	var warm: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	var warm_draw: Dictionary = warm.get("draw_call", {})
	var unpowered: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, false, 0.3, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	var unpowered_draw: Dictionary = unpowered.get("draw_call", {})
	var cold: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.1, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	var cold_draw: Dictionary = cold.get("draw_call", {})
	var no_fade: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.1, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 1.0, false, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	var no_fade_draw: Dictionary = no_fade.get("draw_call", {})
	proof["draw_warmup"] = is_equal_approx(float(warm.get("warmup_value", -1.0)), 0.5) and is_equal_approx(float(warm_draw.get("alpha", -1.0)), 0.5) and is_equal_approx(float(unpowered.get("warmup_value", -1.0)), 1.0) and is_equal_approx(float(unpowered_draw.get("alpha", -1.0)), 1.0) and is_equal_approx(float(cold_draw.get("alpha", -1.0)), 0.25) and is_equal_approx(float(no_fade_draw.get("alpha", -1.0)), 1.0)

	# --- Linked draw: direction 0 (east), dist 2,
	# the endRegion rects at (80, 160) rot 90 and
	# (104, 160) rot 270, the bridgeRegion line
	# from (84, 160) to (100, 160) -- 4px short of
	# each end -- stroke 6.5, Layer.power, the
	# recorded super.draw(). The pulse color is
	# white/black at t = absin(0, 6, 0.07) = 0.035.
	# The Lod.l1 arrows number (int)(2 * 8 / 4) = 4
	# at (86 / 90 / 94 / 98, 160), rot 0, alphas
	# absin(a, 0.9, 1) * 0.5: 0.25, 0.3818538464,
	# 0.4740480503, 0.4988519894. With Lod.l1 false
	# there are no arrows. A north link (other tile
	# (10, 23), draw (80, 184)) has direction 1,
	# the near end at rot 180, the line from
	# (80, 164) to (80, 180), and the first arrow
	# at (80, 166).
	var linked_draw: Dictionary = warm_draw
	var end_a: Dictionary = linked_draw.get("end_a", {})
	var end_b: Dictionary = linked_draw.get("end_b", {})
	var bridge_line: Dictionary = linked_draw.get("line", {})
	var pulse_call: Dictionary = warm.get("pulse_call", {})
	var arrow_calls: Array = warm.get("arrow_calls", [])
	var no_lod: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, false, 1.0, 1, link_pos, no_incoming, no_candidates)
	var north: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, true, 10, 23, 80.0, 184.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	var north_draw: Dictionary = north.get("draw_call", {})
	var north_end_a: Dictionary = north_draw.get("end_a", {})
	var north_line: Dictionary = north_draw.get("line", {})
	var north_arrows: Array = north.get("arrow_calls", [])
	proof["draw_linked"] = int(linked_draw.get("direction", -9)) == 0 and int(linked_draw.get("dist", -9)) == 2 and str(linked_draw.get("z", "")) == "Layer.power" and str(linked_draw.get("base", "")) == "super.draw();" and str(end_a.get("region", "")) == "endRegion" and is_equal_approx(float(end_a.get("x", -1.0)), 80.0) and is_equal_approx(float(end_a.get("y", -1.0)), 160.0) and is_equal_approx(float(end_a.get("rotation", -1.0)), 90.0) and str(end_b.get("region", "")) == "endRegion" and is_equal_approx(float(end_b.get("x", -1.0)), 104.0) and is_equal_approx(float(end_b.get("y", -1.0)), 160.0) and is_equal_approx(float(end_b.get("rotation", -1.0)), 270.0) and str(bridge_line.get("region", "")) == "bridgeRegion" and is_equal_approx(float(bridge_line.get("stroke", -1.0)), 6.5) and is_equal_approx(float(bridge_line.get("x1", -1.0)), 84.0) and is_equal_approx(float(bridge_line.get("y1", -1.0)), 160.0) and is_equal_approx(float(bridge_line.get("x2", -1.0)), 100.0) and is_equal_approx(float(bridge_line.get("y2", -1.0)), 160.0) and str(pulse_call.get("from", "")) == "Color.white" and str(pulse_call.get("to", "")) == "Color.black" and is_equal_approx(float(pulse_call.get("t", -1.0)), 0.035) and arrow_calls.size() == 4 and is_equal_approx(float(arrow_calls[0].get("x", -1.0)), 86.0) and is_equal_approx(float(arrow_calls[0].get("y", -1.0)), 160.0) and is_equal_approx(float(arrow_calls[0].get("rotation", -1.0)), 0.0) and is_equal_approx(float(arrow_calls[0].get("alpha", -1.0)), 0.25) and is_equal_approx(float(arrow_calls[1].get("x", -1.0)), 90.0) and is_equal_approx(float(arrow_calls[1].get("alpha", -1.0)), 0.3818538464) and is_equal_approx(float(arrow_calls[2].get("x", -1.0)), 94.0) and is_equal_approx(float(arrow_calls[2].get("alpha", -1.0)), 0.4740480503) and is_equal_approx(float(arrow_calls[3].get("x", -1.0)), 98.0) and is_equal_approx(float(arrow_calls[3].get("alpha", -1.0)), 0.4988519894) and (no_lod.get("arrow_calls", []) as Array).is_empty() and int(north_draw.get("direction", -9)) == 1 and is_equal_approx(float(north_end_a.get("rotation", -1.0)), 180.0) and is_equal_approx(float(north_line.get("y1", -1.0)), 164.0) and is_equal_approx(float(north_line.get("y2", -1.0)), 180.0) and north_arrows.size() == 4 and is_equal_approx(float(north_arrows[0].get("x", -1.0)), 80.0) and is_equal_approx(float(north_arrows[0].get("y", -1.0)), 166.0)

	# --- Unlinked / zero opacity: no link means no
	# draw call, no pulse, no arrows, reason
	# "unlinked" (the warmup value is still
	# reported -- the gate rides the null draw
	# call). Zero bridge opacity means no draw
	# either, reason "zero_opacity" -- and the
	# Mathf.zero epsilon applies: 0.0000005 (<=
	# 1e-6) is zero, but 0.000002 (> 1e-6) draws.
	var unlinked: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, false, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	var faded: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 0.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	var epsilon_zero: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 0.0000005, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	var epsilon_draws: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 0.000002, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	proof["draw_unlinked"] = unlinked.get("draw_call", {}) == null and str(unlinked.get("draw_skipped_reason", "")) == "unlinked" and unlinked.get("pulse_call", {}) == null and (unlinked.get("arrow_calls", []) as Array).is_empty() and is_equal_approx(float(unlinked.get("warmup_value", -1.0)), 0.5) and faded.get("draw_call", {}) == null and str(faded.get("draw_skipped_reason", "")) == "zero_opacity" and epsilon_zero.get("draw_call", {}) == null and str(epsilon_zero.get("draw_skipped_reason", "")) == "zero_opacity" and epsilon_draws.get("draw_call", {}) != null and str(epsilon_draws.get("draw_skipped_reason", "x")) == ""

	# --- DrawSelect: with a valid link the link
	# input draws, plus one input per VALID
	# incoming tile -- the invalid incoming entry
	# and the non-Dictionary entry are skipped --
	# then Draw.reset(). Unlinked with no incoming
	# draws nothing.
	var incoming_tiles: Array = [{"tile_x": 10, "tile_y": 17, "drawx": 80.0, "drawy": 136.0, "pos": incoming_pos, "valid": true}, {"tile_x": 10, "tile_y": 23, "drawx": 80.0, "drawy": 184.0, "pos": (10 << 16) | 23, "valid": false}, 42]
	var selected: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, incoming_tiles, no_candidates)
	var select_call: Dictionary = selected.get("select_call", {})
	var select_inputs: Array = selected.get("input_call", [])
	var unselected: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, false, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, no_candidates)
	var unselected_call: Dictionary = unselected.get("select_call", {})
	proof["draw_select"] = bool(select_call.get("link_input_drawn", false)) and int(select_call.get("incoming_drawn", -1)) == 1 and str(select_call.get("reset_call", "")) == "Draw.reset();" and select_inputs.size() == 2 and not bool(unselected_call.get("link_input_drawn", true)) and int(unselected_call.get("incoming_drawn", -1)) == 0 and (unselected.get("input_call", []) as Array).is_empty()

	# --- DrawConfigure: the self select is the
	# Pal.accent circle at (80, 160), radius
	# 1 * 8 / 2 + 2 = 6. The linked candidate
	# (104, 160) sits still at radius 6, Pal.place;
	# the unlinked candidate (80, 136) pulses to
	# 6 + absin(0, 4, 1) = 6.5, Pal.breakInvalid --
	# and at Time.time 4 * PI the pulse peaks at
	# 7.0. A size-2 candidate pulses around its own
	# radius: 2 * 8 / 2 + 2 + 0.5 = 10.5.
	var configure_candidates: Array = [{"drawx": 104.0, "drawy": 160.0, "size": 1, "pos": link_pos}, {"drawx": 80.0, "drawy": 136.0, "size": 1, "pos": incoming_pos}, {"drawx": 112.0, "drawy": 160.0, "size": 2, "pos": (14 << 16) | 20}]
	var configured: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, configure_candidates)
	var configure_call: Dictionary = configured.get("configure_call", {})
	var self_select: Dictionary = configure_call.get("self_select", {})
	var candidate_selects: Array = configure_call.get("candidates", [])
	var peaked: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 4.0 * PI, true, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, no_incoming, configure_candidates)
	var peaked_call: Dictionary = peaked.get("configure_call", {})
	var peaked_selects: Array = peaked_call.get("candidates", [])
	proof["draw_configure"] = is_equal_approx(float(self_select.get("x", -1.0)), 80.0) and is_equal_approx(float(self_select.get("y", -1.0)), 160.0) and is_equal_approx(float(self_select.get("radius", -1.0)), 6.0) and str(self_select.get("color", "")) == "Pal.accent" and candidate_selects.size() == 3 and is_equal_approx(float(candidate_selects[0].get("radius", -1.0)), 6.0) and str(candidate_selects[0].get("color", "")) == "Pal.place" and bool(candidate_selects[0].get("linked", false)) and is_equal_approx(float(candidate_selects[1].get("radius", -1.0)), 6.5) and str(candidate_selects[1].get("color", "")) == "Pal.breakInvalid" and not bool(candidate_selects[1].get("linked", true)) and is_equal_approx(float(candidate_selects[2].get("radius", -1.0)), 10.5) and is_equal_approx(float(peaked_selects[1].get("radius", -1.0)), 7.0)

	# --- DrawInput geometry: at Time.time 0 the
	# linked input arrow sits ON this tile -- alpha
	# |100 - 0| / 100 = 1, lerp(104, 80, 1) = 80 --
	# rotation 0 (rel 0, east), Pal.place, the line
	# from (82, 160) to (102, 160) (the trns(0, 2)
	# offset), the 2f/45f square at (104, 160), the
	# gray 2.5f background + place 1f foreground.
	# At Time.time 25 the linked alpha is
	# |100 - 50| / 100 = 0.5, so the arrow is
	# halfway at (92, 160). The unlinked incoming
	# tile (10, 17) at Time.time 25 has alpha
	# |0 - 50| / 100 = 0.5, so its arrow is halfway
	# at (80, 148), rotation 90 (rel 1), Pal.accent,
	# the line from (80, 158) to (80, 138) (the
	# trns(270, 2) offset), the square at (80, 136).
	var input_zero: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 0.0, true, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, incoming_tiles, no_candidates)
	var inputs_zero: Array = input_zero.get("input_call", [])
	var input_mid: Dictionary = item_bridge_build_state.source_item_bridge_draw_state(80.0, 160.0, 10, 20, true, 0.5, 0.0, 25.0, true, 13, 20, 104.0, 160.0, 1.0, true, true, 6.5, 4.0, 2.0, 0.9, 2.75, true, 1.0, 1, link_pos, incoming_tiles, no_candidates)
	var inputs_mid: Array = input_mid.get("input_call", [])
	var link_input: Dictionary = inputs_zero[0]
	var link_line: Dictionary = link_input.get("line", {})
	var link_square: Dictionary = link_input.get("square", {})
	var link_background: Dictionary = link_input.get("background", {})
	var link_foreground: Dictionary = link_input.get("foreground", {})
	var link_input_mid: Dictionary = inputs_mid[0]
	var incoming_input: Dictionary = inputs_mid[1]
	var incoming_line: Dictionary = incoming_input.get("line", {})
	var incoming_square: Dictionary = incoming_input.get("square", {})
	proof["draw_input"] = inputs_zero.size() == 2 and bool(link_input.get("linked", false)) and is_equal_approx(float(link_input.get("alpha", -1.0)), 1.0) and is_equal_approx(float(link_input.get("arrow_x", -1.0)), 80.0) and is_equal_approx(float(link_input.get("arrow_y", -1.0)), 160.0) and is_equal_approx(float(link_input.get("arrow_rotation", -1.0)), 0.0) and str(link_input.get("color", "")) == "Pal.place" and is_equal_approx(float(link_line.get("x1", -1.0)), 82.0) and is_equal_approx(float(link_line.get("y1", -1.0)), 160.0) and is_equal_approx(float(link_line.get("x2", -1.0)), 102.0) and is_equal_approx(float(link_line.get("y2", -1.0)), 160.0) and is_equal_approx(float(link_square.get("x", -1.0)), 104.0) and is_equal_approx(float(link_square.get("y", -1.0)), 160.0) and is_equal_approx(float(link_square.get("radius", -1.0)), 2.0) and is_equal_approx(float(link_square.get("rotation", -1.0)), 45.0) and str(link_background.get("color", "")) == "Pal.gray" and is_equal_approx(float(link_background.get("stroke", -1.0)), 2.5) and str(link_foreground.get("color", "")) == "Pal.place" and is_equal_approx(float(link_foreground.get("stroke", -1.0)), 1.0) and str(link_input.get("mixcol_color", "")) == "Pal.place" and is_equal_approx(float(link_input_mid.get("alpha", -1.0)), 0.5) and is_equal_approx(float(link_input_mid.get("arrow_x", -1.0)), 92.0) and is_equal_approx(float(link_input_mid.get("arrow_y", -1.0)), 160.0) and not bool(incoming_input.get("linked", true)) and int(incoming_input.get("tile_x", -1)) == 10 and int(incoming_input.get("tile_y", -1)) == 17 and is_equal_approx(float(incoming_input.get("alpha", -1.0)), 0.5) and is_equal_approx(float(incoming_input.get("arrow_x", -1.0)), 80.0) and is_equal_approx(float(incoming_input.get("arrow_y", -1.0)), 148.0) and is_equal_approx(float(incoming_input.get("arrow_rotation", -1.0)), 90.0) and str(incoming_input.get("color", "")) == "Pal.accent" and is_equal_approx(float(incoming_line.get("x1", -1.0)), 80.0) and is_equal_approx(float(incoming_line.get("y1", -1.0)), 158.0) and is_equal_approx(float(incoming_line.get("x2", -1.0)), 80.0) and is_equal_approx(float(incoming_line.get("y2", -1.0)), 138.0) and is_equal_approx(float(incoming_square.get("x", -1.0)), 80.0) and is_equal_approx(float(incoming_square.get("y", -1.0)), 136.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
