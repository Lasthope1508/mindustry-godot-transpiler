extends Node

const main_scene := preload("res://scenes/Main.tscn")
const stack_router_build_state := preload("res://src/game/SourceStackRouterBuildState.gd")
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

	# --- Draw rows (N2433): StackRouterBuild.
	# drawCached() (StackRouter.java:73-75) +
	# draw() (:78-87) + the parent DuctRouterBuild.
	# draw() (DuctRouter.java:83-92) + drawSelect()
	# (:93-99). drawCached() calls super.draw() --
	# the DuctRouter draw, base rect + sort center
	# when sortItem != null else the top rect at
	# rotdeg() -- and draw() glows additive when
	# the glow region is found AND power != null
	# AND power.status > 0, with alpha glowAlpha *
	# power.status at Layer.blockAdditive, the rect
	# at rotation * 90. drawSelect() records
	# super.drawSelect() + drawItemSelection(
	# sortItem), which draws the item icon only
	# when the selection is non-null
	# (BuildingComp.java:1249-1250). The icons rows
	# (DuctRouter.java:55-57) return {region,
	# topRegion} and ride the draw pure. rotdeg()
	# is rotation * 90 (BuildingComp.java:582-584).
	# Pure-only: the tick never calls draw.

	# --- Cached sort-item branch: a surge-router
	# at (100, 200), rotation 1, sort item
	# surge-alloy -- the base rect draws region at
	# (100, 200), the sort call draws the "center"
	# rect at (100, 200) in the sort item color,
	# and the top call is null (the sort branch
	# replaces the else branch).
	var sort_item: Dictionary = {"name": "surge-alloy", "color": "surgeAlloyColor"}
	var sorted_draw: Dictionary = stack_router_build_state.source_stack_router_draw_state(100.0, 200.0, 1, sort_item, 0.5, true, "glowColor", 1.0)
	var sorted_base: Dictionary = sorted_draw.get("cached_base_call", {})
	var sorted_sort: Dictionary = sorted_draw.get("cached_sort_call", {})
	proof["draw_cached_sort_item"] = is_equal_approx(float(sorted_base.get("x", -1.0)), 100.0) and is_equal_approx(float(sorted_base.get("y", -1.0)), 200.0) and str(sorted_base.get("region", "")) == "region" and str(sorted_base.get("call", "")) == "Draw.rect(region, x, y);" and is_equal_approx(float(sorted_sort.get("x", -1.0)), 100.0) and is_equal_approx(float(sorted_sort.get("y", -1.0)), 200.0) and str(sorted_sort.get("region", "")) == "center" and str(sorted_sort.get("color", "")) == "surgeAlloyColor" and str(sorted_sort.get("sort_item", "")) == "surge-alloy" and sorted_draw.get("cached_top_call", {}) == null

	# --- Cached top branch: no sort item -- the
	# base rect still draws, the sort call is null,
	# and the top call draws topRegion at rotdeg()
	# (rotation 1 -> 90, rotation 3 -> 270,
	# rotation 0 -> 0).
	var top_draw: Dictionary = stack_router_build_state.source_stack_router_draw_state(100.0, 200.0, 1, null, 0.5, true, "glowColor", 1.0)
	var top_base: Dictionary = top_draw.get("cached_base_call", {})
	var top_top: Dictionary = top_draw.get("cached_top_call", {})
	var back_draw: Dictionary = stack_router_build_state.source_stack_router_draw_state(100.0, 200.0, 3, null, 0.5, true, "glowColor", 1.0)
	var back_top: Dictionary = back_draw.get("cached_top_call", {})
	var flat_draw: Dictionary = stack_router_build_state.source_stack_router_draw_state(100.0, 200.0, 0, null, 0.5, true, "glowColor", 1.0)
	var flat_top: Dictionary = flat_draw.get("cached_top_call", {})
	proof["draw_cached_top"] = is_equal_approx(float(top_base.get("x", -1.0)), 100.0) and is_equal_approx(float(top_base.get("y", -1.0)), 200.0) and str(top_base.get("region", "")) == "region" and top_draw.get("cached_sort_call", {}) == null and str(top_top.get("region", "")) == "topRegion" and is_equal_approx(float(top_top.get("rotation", -1.0)), 90.0) and is_equal_approx(float(top_draw.get("rotdeg", -1.0)), 90.0) and is_equal_approx(float(back_top.get("rotation", -1.0)), 270.0) and is_equal_approx(float(flat_top.get("rotation", -1.0)), 0.0)

	# --- Glow gate: the glow draws when the region
	# is found AND power.status > 0. It does NOT
	# draw when the region is not found (even at
	# status 1.0), when power is null (the -1
	# sentinel), or when power.status is exactly
	# 0.0 (the STRICT > 0 gate) -- but the cached
	# base / top calls still draw in every off
	# case.
	var lit_draw: Dictionary = stack_router_build_state.source_stack_router_draw_state(100.0, 200.0, 1, null, 0.5, true, "glowColor", 1.0)
	var lit_glow: Dictionary = lit_draw.get("glow_call", {})
	var dark_draw: Dictionary = stack_router_build_state.source_stack_router_draw_state(100.0, 200.0, 1, null, 1.0, false, "glowColor", 1.0)
	var dark_base: Dictionary = dark_draw.get("cached_base_call", {})
	var dark_top: Dictionary = dark_draw.get("cached_top_call", {})
	var nopower_draw: Dictionary = stack_router_build_state.source_stack_router_draw_state(100.0, 200.0, 1, null, -1.0, true, "glowColor", 1.0)
	var idle_draw: Dictionary = stack_router_build_state.source_stack_router_draw_state(100.0, 200.0, 1, null, 0.0, true, "glowColor", 1.0)
	proof["draw_glow_gate"] = str(lit_glow.get("region", "")) == "glowRegion" and dark_draw.get("glow_call", {}) == null and nopower_draw.get("glow_call", {}) == null and idle_draw.get("glow_call", {}) == null and is_equal_approx(float(dark_base.get("x", -1.0)), 100.0) and str(dark_top.get("region", "")) == "topRegion"

	# --- Glow alpha math: alpha is glowAlpha *
	# power.status -- 1.0 * 0.5 = 0.5 at the class
	# defaults, 0.5 * 0.8 = 0.4 at a halved alpha.
	# The glow rect sits at rotation * 90
	# (rotation 2 -> 180), z Layer.blockAdditive,
	# blend additive, color glowColor.
	var half_draw: Dictionary = stack_router_build_state.source_stack_router_draw_state(100.0, 200.0, 2, null, 0.8, true, "glowColor", 0.5)
	var half_glow: Dictionary = half_draw.get("glow_call", {})
	proof["draw_glow_alpha"] = is_equal_approx(float(lit_glow.get("alpha", -1.0)), 0.5) and is_equal_approx(float(lit_draw.get("glow_alpha_value", -1.0)), 0.5) and is_equal_approx(float(half_glow.get("alpha", -1.0)), 0.4) and is_equal_approx(float(half_draw.get("glow_alpha_value", -1.0)), 0.4) and is_equal_approx(float(half_glow.get("rotation", -1.0)), 180.0) and str(half_glow.get("z", "")) == "Layer.blockAdditive" and str(half_glow.get("blend", "")) == "additive" and str(half_glow.get("color", "")) == "glowColor" and is_equal_approx(float(half_glow.get("x", -1.0)), 100.0) and is_equal_approx(float(half_glow.get("y", -1.0)), 200.0)

	# --- Select call: super.drawSelect() is always
	# recorded, and drawItemSelection(sortItem) is
	# recorded with draws_icon true when a sort
	# item is set. With no sort item the super call
	# is still recorded but draws_icon is false
	# (drawItemSelection no-ops on a null
	# selection, BuildingComp.java:1250).
	var sorted_select: Dictionary = sorted_draw.get("select_call", {})
	var top_select: Dictionary = top_draw.get("select_call", {})
	proof["draw_select_call"] = str(sorted_select.get("super_call", "")) == "super.drawSelect();" and str(sorted_select.get("item_selection_call", "")) == "drawItemSelection(sortItem);" and str(sorted_select.get("sort_item", "")) == "surge-alloy" and bool(sorted_select.get("draws_icon", false)) and str(top_select.get("super_call", "")) == "super.drawSelect();" and str(top_select.get("item_selection_call", "")) == "drawItemSelection(sortItem);" and top_select.get("sort_item", "") == null and not bool(top_select.get("draws_icon", true))

	# --- Icons: the parent icons() override
	# returns {region, topRegion}, in draw order,
	# inherited by the surge-router (StackRouter
	# does not override icons()).
	var icon_regions: Array = sorted_draw.get("icon_regions", [])
	proof["draw_icons"] = icon_regions.size() == 2 and str(icon_regions[0]) == "region" and str(icon_regions[1]) == "topRegion"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackRouterDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
