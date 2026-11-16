extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
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

	# --- Draw rows (N2420): LaunchPadBuild.draw()
	# (LaunchPad.java:104-136) draws the bottom/liquid
	# branch when hasLiquids && drawLiquid != null
	# (color(bottomColor), Fill.square(x, y, size *
	# tilesize/2f - liquidPad), LiquidBlock.
	# drawTiledFrames(block.size, x, y, liquidPad x4,
	# drawLiquid, liquids.get(drawLiquid) /
	# liquidCapacity)), then super.draw(), then -- when
	# the @-light region loaded -- the 4 x lightSteps
	# light loop at progress = min(items.total() /
	# itemCapacity, launchCounter / launchTime) (alpha =
	# Mathf.curve(progress, j / lightSteps, (j+1) /
	# lightSteps), offset = -(j - 1) * lightStep, rect(
	# lightRegion, x + d8edge(i).x * offset, y +
	# d8edge(i).y * offset, i * 90) in the metalGrayDark
	# -> lightColor mix), then Drawf.shadow(x, y, size *
	# tilesize) and Draw.rect(podRegion, x, y). icons()
	# (LaunchPad.java:79-80) returns {previewRegion},
	# folded into the draw pure as icon_regions. The
	# def constants: lightColor eab678 / lightStep 1f /
	# lightSteps 3 / liquidPad 2f / bottomColor
	# Pal.darkerMetal ("565666"); drawLiquid is null by
	# default and oil only on the advanced def
	# (Blocks.java:6807, liquidCapacity 40f). Pure-only:
	# the tick never calls draw -- draw is called by
	# the renderer, icons by the atlas, and the call
	# sites wait for renderer/UI slices, so this proof
	# has no live-tick key.

	# --- The advanced pad at (100, 200), size 4: the
	# liquid branch is ON (hasLiquids, oil, 20 / 40)
	# and the light loop runs at progress 0.25 (25 /
	# 100 items, 300 / 1200 counter).
	var advanced: Dictionary = launch_pad_build_state.source_launch_pad_draw_state(100.0, 200.0, 4, true, "oil", 20.0, 40.0, "565666", 2.0, 25, 100, 300.0, 1200.0, true, 3, 1.0, "eab678")
	# --- The plain pad at (100, 200), size 3: the
	# liquid branch is OFF (no liquids, no draw
	# liquid) and the light loop runs at progress
	# 0.25 -- the counter side wins the min (100 /
	# 100 items, 300 / 1200 counter).
	var plain: Dictionary = launch_pad_build_state.source_launch_pad_draw_state(100.0, 200.0, 3, false, null, 0.0, 10.0, "565666", 2.0, 100, 100, 300.0, 1200.0, true, 3, 1.0, "eab678")
	# --- The half-gates: liquids without a draw
	# liquid, and a draw liquid without liquids --
	# both leave the liquid branch off, and with no
	# light region the light loop is empty.
	var no_liquid: Dictionary = launch_pad_build_state.source_launch_pad_draw_state(0.0, 0.0, 4, true, null, 20.0, 40.0, "565666", 2.0, 0, 100, 0.0, 1800.0, false, 3, 1.0, "eab678")
	var no_flag: Dictionary = launch_pad_build_state.source_launch_pad_draw_state(0.0, 0.0, 4, false, "oil", 20.0, 40.0, "565666", 2.0, 0, 100, 0.0, 1800.0, false, 3, 1.0, "eab678")
	# --- The items side wins the min (25 / 100
	# items, 1200 / 1200 counter) -- progress 0.25
	# again, from the other side.
	var items_side: Dictionary = launch_pad_build_state.source_launch_pad_draw_state(0.0, 0.0, 3, false, null, 0.0, 10.0, "565666", 2.0, 25, 100, 1200.0, 1200.0, true, 3, 1.0, "eab678")
	# --- Full progress (100 / 100 items, 1200 /
	# 1200 counter) -- every light alpha saturates
	# to 1.0.
	var full: Dictionary = launch_pad_build_state.source_launch_pad_draw_state(0.0, 0.0, 3, false, null, 0.0, 10.0, "565666", 2.0, 100, 100, 1200.0, 1200.0, true, 3, 1.0, "eab678")

	# --- Liquid branch: the advanced pad draws the
	# bottom square (half-size 4 * 8 / 2 - 2 = 14.0,
	# bottom color 565666) and the tiled frames (oil,
	# alpha 20 / 40 = 0.5, all four pads 2.0); the
	# plain pad and both half-gates draw no liquid.
	var advanced_liquid: Variant = advanced.get("liquid_call", null)
	var plain_liquid: Variant = plain.get("liquid_call", null)
	var no_liquid_call: Variant = no_liquid.get("liquid_call", null)
	var no_flag_call: Variant = no_flag.get("liquid_call", null)
	proof["draw_liquid_branch"] = advanced_liquid != null and is_equal_approx(float(advanced_liquid.get("square_half_size", -1.0)), 14.0) and str(advanced_liquid.get("bottom_color", "")) == "565666" and str(advanced_liquid.get("liquid", "")) == "oil" and is_equal_approx(float(advanced_liquid.get("alpha", -1.0)), 0.5) and is_equal_approx(float(advanced_liquid.get("pad_left", -1.0)), 2.0) and is_equal_approx(float(advanced_liquid.get("pad_right", -1.0)), 2.0) and is_equal_approx(float(advanced_liquid.get("pad_top", -1.0)), 2.0) and is_equal_approx(float(advanced_liquid.get("pad_bottom", -1.0)), 2.0) and int(advanced_liquid.get("size", -1)) == 4 and is_equal_approx(float(advanced_liquid.get("x", -1.0)), 100.0) and is_equal_approx(float(advanced_liquid.get("y", -1.0)), 200.0) and plain_liquid == null and no_liquid_call == null and no_flag_call == null

	# --- Light progress: the min of the items
	# fraction and the counter fraction -- 0.25 from
	# both sides (advanced), 0.25 from the counter
	# side (plain), 0.25 from the items side
	# (items_side), 1.0 at full (full), null with no
	# light region (no_liquid).
	var no_light_progress: Variant = no_liquid.get("light_progress", -1.0)
	proof["draw_light_progress"] = is_equal_approx(float(advanced.get("light_progress", -1.0)), 0.25) and is_equal_approx(float(plain.get("light_progress", -1.0)), 0.25) and is_equal_approx(float(items_side.get("light_progress", -1.0)), 0.25) and is_equal_approx(float(full.get("light_progress", -1.0)), 1.0) and no_light_progress == null and (no_liquid.get("light_calls", [{}]) as Array).is_empty()

	# --- Light loop: 4 x 3 = 12 calls at progress
	# 0.25 -- j = 0 reads alpha curve(0.25, 0, 1/3) =
	# 0.75 at offset -(0 - 1) * 1 = 1.0, j = 1 reads
	# alpha 0 at offset 0, j = 2 reads alpha 0 at
	# offset -1 -- along the d8edge diagonals ((1, 1)
	# / (-1, 1) / (-1, -1) / (1, -1)) at rotations
	# 0 / 90 / 180 / 270, in the 6e7080 -> eab678
	# mix; at full progress every alpha is 1.0.
	var calls: Array = advanced.get("light_calls", [])
	var full_calls: Array = full.get("light_calls", [])
	var call_0: Dictionary = calls[0]
	var call_1: Dictionary = calls[1]
	var call_2: Dictionary = calls[2]
	var call_3: Dictionary = calls[3]
	var call_6: Dictionary = calls[6]
	var call_9: Dictionary = calls[9]
	var call_11: Dictionary = calls[11]
	var full_call_2: Dictionary = full_calls[2]
	proof["draw_light_loop"] = calls.size() == 12 and is_equal_approx(float(call_0.get("alpha", -1.0)), 0.75) and is_equal_approx(float(call_0.get("offset", -9.0)), 1.0) and is_equal_approx(float(call_0.get("x", -1.0)), 101.0) and is_equal_approx(float(call_0.get("y", -1.0)), 201.0) and is_equal_approx(float(call_0.get("rotation", -1.0)), 0.0) and is_equal_approx(float(call_1.get("alpha", -1.0)), 0.0) and is_equal_approx(float(call_1.get("offset", -9.0)), 0.0) and is_equal_approx(float(call_1.get("x", -1.0)), 100.0) and is_equal_approx(float(call_1.get("y", -1.0)), 200.0) and is_equal_approx(float(call_2.get("alpha", -1.0)), 0.0) and is_equal_approx(float(call_2.get("offset", -9.0)), -1.0) and is_equal_approx(float(call_2.get("x", -1.0)), 99.0) and is_equal_approx(float(call_2.get("y", -1.0)), 199.0) and is_equal_approx(float(call_3.get("x", -1.0)), 99.0) and is_equal_approx(float(call_3.get("y", -1.0)), 201.0) and is_equal_approx(float(call_3.get("rotation", -1.0)), 90.0) and is_equal_approx(float(call_6.get("x", -1.0)), 99.0) and is_equal_approx(float(call_6.get("y", -1.0)), 199.0) and is_equal_approx(float(call_6.get("rotation", -1.0)), 180.0) and is_equal_approx(float(call_9.get("x", -1.0)), 101.0) and is_equal_approx(float(call_9.get("y", -1.0)), 199.0) and is_equal_approx(float(call_9.get("rotation", -1.0)), 270.0) and is_equal_approx(float(call_11.get("offset", -9.0)), -1.0) and is_equal_approx(float(call_11.get("x", -1.0)), 99.0) and is_equal_approx(float(call_11.get("y", -1.0)), 201.0) and is_equal_approx(float(call_11.get("rotation", -1.0)), 270.0) and str(call_0.get("color_from", "")) == "6e7080" and str(call_0.get("color_to", "")) == "eab678" and is_equal_approx(float(call_0.get("progress", -1.0)), 0.25) and is_equal_approx(float(full_call_2.get("alpha", -1.0)), 1.0)

	# --- Shadow + pod: the shadow radius is size *
	# tilesize (32.0 advanced, 24.0 plain) at (x, y);
	# the pod rect draws podRegion at (x, y).
	var advanced_shadow: Dictionary = advanced.get("shadow_call", {})
	var plain_shadow: Dictionary = plain.get("shadow_call", {})
	var advanced_pod: Dictionary = advanced.get("pod_call", {})
	var plain_pod: Dictionary = plain.get("pod_call", {})
	proof["draw_shadow_pod"] = is_equal_approx(float(advanced_shadow.get("radius", -1.0)), 32.0) and is_equal_approx(float(advanced_shadow.get("x", -1.0)), 100.0) and is_equal_approx(float(advanced_shadow.get("y", -1.0)), 200.0) and is_equal_approx(float(plain_shadow.get("radius", -1.0)), 24.0) and is_equal_approx(float(plain_shadow.get("x", -1.0)), 100.0) and is_equal_approx(float(plain_shadow.get("y", -1.0)), 200.0) and str(advanced_pod.get("region", "")) == "podRegion" and is_equal_approx(float(advanced_pod.get("x", -1.0)), 100.0) and is_equal_approx(float(advanced_pod.get("y", -1.0)), 200.0) and str(plain_pod.get("region", "")) == "podRegion" and is_equal_approx(float(plain_pod.get("x", -1.0)), 100.0) and is_equal_approx(float(plain_pod.get("y", -1.0)), 200.0)

	# --- Icons: icons() returns {previewRegion},
	# folded into the draw pure as icon_regions.
	var advanced_icons: Array = advanced.get("icon_regions", [])
	var plain_icons: Array = plain.get("icon_regions", [])
	proof["draw_icons"] = advanced_icons.size() == 1 and str(advanced_icons[0]) == "previewRegion" and plain_icons.size() == 1 and str(plain_icons[0]) == "previewRegion"

	# --- Super base: super.draw() is recorded as
	# the base call on every draw, liquid or not.
	var advanced_super: Dictionary = advanced.get("super_draw_call", {})
	var plain_super: Dictionary = plain.get("super_draw_call", {})
	proof["draw_super_base"] = str(advanced_super.get("call", "")) == "super.draw();" and str(plain_super.get("call", "")) == "super.draw();"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
