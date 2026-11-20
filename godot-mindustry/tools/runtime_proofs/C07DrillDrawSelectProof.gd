extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- DrillBuild.drawSelect() (N2283):
	# DrillBuild.drawSelect() (Drill.java:262-264,
	# `public void drawSelect(){`) calls
	# `drawItemSelection(dominantItem);` (:263) -- the
	# dominant item's icon is drawn above the building
	# through BuildingComp.drawItemSelection
	# (BuildingComp.java:1249-1257): `if(selection !=
	# null){` (:1250), then `float dx = x - block.size *
	# tilesize/2f, dy = y + block.size * tilesize/2f, s =
	# iconSmall / 4f * selection.fullIcon.ratio(), h =
	# iconSmall / 4f;` (:1251), `Draw.mixcol(
	# Color.darkGray, 1f);` (:1252), `Draw.rect(
	# selection.fullIcon, dx, dy - 1, s, h);` (:1253),
	# `Draw.reset();` (:1254), `Draw.rect(
	# selection.fullIcon, dx, dy, s, h);` (:1255). The
	# helper is ALREADY LIVE as PortGame N570
	# (SourceBuildingDrawState.draw_item_selection_state),
	# so the pure function delegates to it and does NOT
	# re-port the helper. There is NO driver tick line:
	# drawSelect is selection UI, not per-tick state (the
	# N2220 / N2333 lifecycle precedent).

	# Per-def inputs (Blocks.java): impact-drill
	# `size = 4;` (:3073), eruption-drill `size = 5;`
	# (:3096). tilesize is 8 (`public static final int
	# tilesize = 8;`, Vars.java:135) and iconSmall is 24
	# (`iconSmall = 8*3f;`, Vars.java:139).

	# Hidden when there is no dominant item: the helper
	# returns only {visible: false}.
	var hidden: Dictionary = burst_drill_build_state.source_drill_draw_select_state(100.0, 200.0, 4, 8.0, 24.0, false, 1.0)
	proof["draw_select_hidden_no_dominant"] = bool(hidden.get("visible", true)) == false

	# Visible with a dominant item.
	var impact: Dictionary = burst_drill_build_state.source_drill_draw_select_state(100.0, 200.0, 4, 8.0, 24.0, true, 1.0)
	proof["draw_select_visible_with_dominant"] = bool(impact.get("visible", false)) == true

	# Impact dx/dy at (100, 200), size 4, tilesize 8:
	# dx = 100 - 4*8/2 = 84, dy = 200 + 4*8/2 = 216.
	proof["draw_select_dx_impact"] = is_equal_approx(float(impact.get("dx", -1.0)), 84.0)
	proof["draw_select_dy_impact"] = is_equal_approx(float(impact.get("dy", -1.0)), 216.0)

	# Eruption (size 5) at the same position: dx 80,
	# dy 220.
	var eruption: Dictionary = burst_drill_build_state.source_drill_draw_select_state(100.0, 200.0, 5, 8.0, 24.0, true, 1.0)
	proof["draw_select_position_eruption"] = is_equal_approx(float(eruption.get("dx", -1.0)), 80.0) and is_equal_approx(float(eruption.get("dy", -1.0)), 220.0)

	# Selection size from iconSmall 24: s = 24/4 *
	# ratio, h = 24/4 -- 6 wide, 6 high at ratio 1.0.
	proof["draw_select_selection_size_ratio_one"] = is_equal_approx(float(impact.get("selection_width", -1.0)), 6.0) and is_equal_approx(float(impact.get("selection_height", -1.0)), 6.0)

	# Ratio 2.0: 12 wide, still 6 high.
	var ratio_two: Dictionary = burst_drill_build_state.source_drill_draw_select_state(100.0, 200.0, 4, 8.0, 24.0, true, 2.0)
	proof["draw_select_selection_size_ratio_two"] = is_equal_approx(float(ratio_two.get("selection_width", -1.0)), 12.0) and is_equal_approx(float(ratio_two.get("selection_height", -1.0)), 6.0)

	# Shadow: darkGray at dy - 1 (215.0), foreground at
	# dy (216.0), alpha 1.0.
	proof["draw_select_shadow"] = String(impact.get("shadow_color", "")) == "darkGray" and is_equal_approx(float(impact.get("shadow_alpha", -1.0)), 1.0) and is_equal_approx(float(impact.get("shadow_y", -1.0)), 215.0) and is_equal_approx(float(impact.get("foreground_y", -1.0)), 216.0)

	# tilesize 1.0 reads the raw offsets: dx = 100 -
	# 4*1/2 = 98, dy = 200 + 4*1/2 = 202.
	var tilesize_one: Dictionary = burst_drill_build_state.source_drill_draw_select_state(100.0, 200.0, 4, 1.0, 24.0, true, 1.0)
	proof["draw_select_tilesize_one"] = is_equal_approx(float(tilesize_one.get("dx", -1.0)), 98.0) and is_equal_approx(float(tilesize_one.get("dy", -1.0)), 202.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillDrawSelectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
