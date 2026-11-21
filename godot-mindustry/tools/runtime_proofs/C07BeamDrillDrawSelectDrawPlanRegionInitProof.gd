extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _select_case(last_item: Variant, draw_item_selection: Callable) -> Dictionary:
	return state.source_beam_drill_draw_select_state({}, last_item, draw_item_selection)


func _plan_case(plan_drawx: float, plan_drawy: float, plan_rotation: int, top_region: Variant, draw_rect: Callable) -> Dictionary:
	return state.source_beam_drill_draw_plan_region_state({}, plan_drawx, plan_drawy, plan_rotation, top_region, draw_rect)


func _init_case(range_value: int, tilesize: float, update_clip_radius: Callable) -> Dictionary:
	return state.source_beam_drill_init_state({}, range_value, tilesize, update_clip_radius)


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

	# --- BeamDrillBuild.drawSelect() + BeamDrill.drawPlanRegion()
	# + BeamDrill.init() (N2394):
	# BeamDrillBuild.drawSelect() (BeamDrill.java:231-234) is
	# one line: `drawItemSelection(lastItem);` -- the
	# BuildingComp selection icon for the last mined item.
	# BeamDrill.drawPlanRegion() (BeamDrill.java:113-117)
	# draws the block region (N1411, NOT this slice) and the
	# top region rotated by the plan rotation
	# (`Draw.rect(topRegion, plan.drawx(), plan.drawy(),
	# plan.rotation * 90);`). BeamDrill.init()
	# (BeamDrill.java:81-89) widens the clip radius
	# (`updateClipRadius((range + 2) * tilesize);`) and then
	# runs the generic `super.init();` plus the blockedItems
	# fill (N2012 / N2302, NOT this slice). The proof drives
	# the pure functions with synthetic frames (no live
	# tick): plasma-bore defaults (tier 3, size 2, range 5,
	# Blocks.java:3038-3051) and large-plasma-bore range 6
	# (Blocks.java:3052-3065); tilesize 8 (Vars.java:135).
	# NO driver tick line: drawSelect / drawPlanRegion are
	# selection / placement UI, init is load-time clip setup.

	# The selection delegate receives the last item.
	var select_seen: Array = []
	var select_delegate: Callable = func(item: Variant) -> void:
		select_seen.append(item)
	var selected: Dictionary = _select_case("copper", select_delegate)
	proof["select_calls_delegate_with_last_item"] = bool(selected.get("draw_item_selection_called", false)) and select_seen == ["copper"]

	# The last item reads through the result.
	proof["select_returns_last_item"] = selected.get("last_item", null) == "copper"

	# An invalid delegate is not called, but the last item
	# still reads through.
	var invalid_select: Dictionary = _select_case("lead", Callable())
	proof["select_invalid_delegate_not_called"] = not bool(invalid_select.get("draw_item_selection_called", true)) and invalid_select.get("last_item", null) == "lead"

	# Rotation 2 draws the top region at 180 degrees.
	var plan: Dictionary = _plan_case(80.0, 96.0, 2, "top_region", Callable())
	proof["plan_region_top_rotation"] = is_equal_approx(float(plan.get("top_region_rotation", -1.0)), 180.0)

	# The draw rect delegate receives the top region at the
	# plan position with the rotated angle.
	var rect_seen: Array = []
	var rect_delegate: Callable = func(region: Variant, x: float, y: float, rotation: float) -> void:
		rect_seen.append([region, x, y, rotation])
	var drawn: Dictionary = _plan_case(80.0, 96.0, 1, "top_region", rect_delegate)
	proof["plan_region_calls_draw_rect"] = bool(drawn.get("draw_rect_called", false)) and rect_seen == [["top_region", 80.0, 96.0, 90.0]]

	# The plan position reads through.
	proof["plan_region_position"] = drawn.get("plan_position", Vector2.ZERO) == Vector2(80.0, 96.0)

	# The clip radius is (range + 2) * tilesize: (5 + 2) * 8
	# = 56.0 for the plasma-bore defaults.
	var init: Dictionary = _init_case(5, 8.0, Callable())
	proof["init_clip_radius"] = is_equal_approx(float(init.get("clip_radius", -1.0)), 56.0)

	# The clip delegate receives the computed radius.
	var clip_seen: Array = []
	var clip_delegate: Callable = func(radius: float) -> void:
		clip_seen.append(radius)
	var clipped: Dictionary = _init_case(5, 8.0, clip_delegate)
	proof["init_calls_update_clip_radius"] = bool(clipped.get("update_clip_radius_called", false)) and clip_seen == [56.0]

	# The large-plasma-bore range 6 gives (6 + 2) * 8 = 64.0.
	var large: Dictionary = _init_case(6, 8.0, Callable())
	proof["init_large_bore_clip_radius"] = is_equal_approx(float(large.get("clip_radius", -1.0)), 64.0)

	# Each result carries ONLY its own keys.
	proof["returns_only_expected_keys"] = selected.size() == 2 and drawn.size() == 3 and clipped.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillDrawSelectDrawPlanRegionInitProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
