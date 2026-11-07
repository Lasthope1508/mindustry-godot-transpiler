extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const floor_state := preload("res://src/game/SourceFloorState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var tiling_regions := [[["tiling-north-west", "tiling-south-west"], ["tiling-north-east", "tiling-south-east"]]]
	var bitmask_mid: Array = []
	bitmask_mid.resize(256)
	bitmask_mid.fill(0)
	bitmask_mid[255] = 13
	var draw_main_tiling := game.source_floor_draw_main_state(4, 5, 1, 2, tiling_regions, false, 1, [], [], 1, [], [], [], [])
	var draw_main_autotile_mid := game.source_floor_draw_main_state(4, 5, 0, 1, [], true, 1, [], ["autotile-default"], 2, ["autotile-mid-a", "autotile-mid-b"], [true, true, true, true, true, true, true, true], bitmask_mid, [])
	var draw_main_variant := game.source_floor_draw_main_state(4, 5, 0, 1, [], false, 1, [], [], 1, [], [], [], ["variant-a", "variant-b", "variant-c"])
	var generated_draw_main := floor_state.generated_bridge("java_method_drawMain_6", [4, 5, 0, 1, [], false, 1, [], [], 1, [], [], [], ["variant-a", "variant-b", "variant-c"]], draw_main_variant)
	var should_index := game.source_floor_should_index_state(null)
	var update_render := game.source_floor_update_render_state(null)
	var render_update := game.source_floor_render_update_state(null)
	var surface := game.source_floor_has_surface_state(false, false)
	var deep := game.source_floor_is_deep_state(1.0)
	var damage := game.source_floor_damages_state(0.0, 2.0, true)
	var generated := floor_state.generated_bridge("java_method_damages_25", [0.0, 2.0, true], damage)
	var real_blend_id := game.source_floor_real_blend_id_state(true, false, false, 7, 3, 11)
	var real_blend_fallback := game.source_floor_real_blend_id_state(true, true, false, 7, 3, 11)
	var edges := game.source_floor_edges_state([["north", "middle", "south"]])
	var edge := game.source_floor_edge_state([["north", "middle", "south"]], 4, 5, 0, 0)
	var do_edge := game.source_floor_do_edge_state(2, 3, true)
	var missing_edges_do_edge := game.source_floor_do_edge_state(2, 3, false)
	var neighbors: Array = []
	for index in range(8):
		neighbors.append({"is_null": index != 0, "floor": {"id": 2, "draw_edge_out": true, "cache_layer": "ground", "edges_present": true}, "overlay_is_air": true, "tile_x": 4, "tile_y": 5, "point_x": 1, "point_y": 0, "floor_id": 2})
	var draw_non_layer := game.source_floor_draw_non_layer_state(neighbors, "ground", 4, 5)
	var draw_blended := game.source_floor_draw_blended_state([{"id": 2}], neighbors, draw_non_layer.get("dirs", []), true, false)
	var edge_neighbors: Array = []
	for index in range(8):
		edge_neighbors.append({"is_null": index != 0, "floor": {"id": 5, "draw_edge_out": true, "cache_layer": "ground", "edges_present": true, "real_blend_id": 4}, "overlay": {"id": 5, "draw_edge_out": true, "edges_present": true, "real_blend_id": 4}, "overlay_is_air": true, "ob_edges_present": true, "other_real_blend_id": 4, "tile_x": 4, "tile_y": 5, "point_x": 1, "point_y": 0})
	var draw_edges := game.source_floor_draw_edges_state(edge_neighbors, "ground", true, 4, 5, 3, true)
	var draw_base := game.source_floor_draw_base_state(true, true, true, false, 0.65, draw_edges)
	var draw_base_liquid := game.source_floor_draw_base_state(true, false, true, true, 0.65, draw_edges)
	var draw_base_no_edges := game.source_floor_draw_base_state(false, true, true, false, 0.65, {})
	var draw_overlay := game.source_floor_draw_overlay_state(false, false, draw_base)
	var draw_overlay_skipped := game.source_floor_draw_overlay_state(true, false, {})
	var generated_draw_overlay := floor_state.generated_bridge("java_method_drawOverlay_10", [false, false, draw_base], draw_overlay)
	var packed_position := (4 << 16) | 5
	var variant := game.source_floor_variant_state(4, 5, -1, packed_position, 3)
	var variant_max := game.source_floor_variant_state(4, 5, 5, packed_position)
	var generated_variant := floor_state.generated_bridge("java_method_variant_8", [4, 5, packed_position, 3], variant)
	var generated_variant_max := floor_state.generated_bridge("java_method_variant_9", [4, 5, 5, packed_position], variant_max)
	var icons_found := game.source_floor_icons_state("stone", true, "stone")
	var icons_fallback := game.source_floor_icons_state("stone", false, "stone1")
	var generated_icons := floor_state.generated_bridge("java_method_icons_11", ["stone", false, "stone1"], icons_fallback)
	var floor_changed := game.source_floor_floor_changed_state({"x": 4, "y": 5})
	var generated_floor_changed := floor_state.generated_bridge("java_method_floorChanged_12", [{"x": 4, "y": 5}], floor_changed)
	var display_icon_base := game.source_floor_get_display_icon_state(false, "base-icon", "liquid-icon")
	var display_icon_liquid := game.source_floor_get_display_icon_state(true, "base-icon", "liquid-icon")
	var display_name_base := game.source_floor_get_display_name_state(false, "Base floor", "Liquid floor")
	var display_name_liquid := game.source_floor_get_display_name_state(true, "Base floor", "Liquid floor")
	var generated_display_icon := floor_state.generated_bridge("java_method_getDisplayIcon_2", [true, "base-icon", "liquid-icon"], display_icon_liquid)
	var generated_display_name := floor_state.generated_bridge("java_method_getDisplayName_3", [true, "Base floor", "Liquid floor"], display_name_liquid)
	var autotile_same_floor := game.source_floor_check_autotile_same_state(true, true, true, false)
	var autotile_same_overlay := game.source_floor_check_autotile_same_state(true, false, false, true)
	var autotile_missing := game.source_floor_check_autotile_same_state(false, true, true, true)
	var generated_autotile_same := floor_state.generated_bridge("java_method_checkAutotileSame_7", [true, false, false, true], autotile_same_overlay)
	var generated_draw_base := floor_state.generated_bridge("java_method_drawBase_5", [true, true, true, false, 0.65, draw_edges], draw_base)
	var generated_real_blend := floor_state.generated_bridge("java_method_realBlendId_21", [true, false, false, 7, 3, 11], real_blend_id)
	var generated_edge := floor_state.generated_bridge("java_method_edge_23", [[["north", "middle", "south"]], 4, 5, 0, 0], edge)
	var generated_draw_non_layer := floor_state.generated_bridge("java_method_drawNonLayer_18", [neighbors, "ground", 4, 5], draw_non_layer)
	var generated_draw_blended := floor_state.generated_bridge("java_method_drawBlended_20", [[{"id": 2}], neighbors, draw_non_layer.get("dirs", []), true, false], draw_blended)
	var generated_draw_edges := floor_state.generated_bridge("java_method_drawEdges_19", [edge_neighbors, "ground", true, 4, 5, 3, true], draw_edges)
	var draw_main_checks := {"tiling": draw_main_tiling, "autotile_mid": draw_main_autotile_mid, "variant": draw_main_variant, "generated": generated_draw_main}
	var proof := {"module":"FLOOR_MODULE_PROOF", "should_index":should_index, "update_render":update_render, "render_update":render_update, "has_surface":surface, "is_deep":deep, "damages":damage, "generated":generated, "real_blend_id":real_blend_id, "real_blend_fallback":real_blend_fallback, "edges":edges, "edge":edge, "do_edge":do_edge, "missing_edges_do_edge":missing_edges_do_edge, "draw_non_layer":draw_non_layer, "draw_blended":draw_blended, "draw_edges":draw_edges, "draw_base":draw_base, "draw_base_liquid":draw_base_liquid, "draw_base_no_edges":draw_base_no_edges, "draw_overlay":draw_overlay, "draw_overlay_skipped":draw_overlay_skipped, "variant":variant, "variant_max":variant_max, "icons_found":icons_found, "icons_fallback":icons_fallback, "floor_changed":floor_changed, "display_icon_base":display_icon_base, "display_icon_liquid":display_icon_liquid, "display_name_base":display_name_base, "display_name_liquid":display_name_liquid, "autotile_same_floor":autotile_same_floor, "autotile_same_overlay":autotile_same_overlay, "autotile_missing":autotile_missing, "generated_real_blend":generated_real_blend, "generated_edge":generated_edge, "generated_draw_non_layer":generated_draw_non_layer, "generated_draw_blended":generated_draw_blended, "generated_draw_edges":generated_draw_edges, "generated_draw_base":generated_draw_base, "generated_draw_overlay":generated_draw_overlay, "generated_variant":generated_variant, "generated_variant_max":generated_variant_max, "generated_icons":generated_icons, "generated_floor_changed":generated_floor_changed, "generated_display_icon":generated_display_icon, "generated_display_name":generated_display_name, "generated_autotile_same":generated_autotile_same, "matches":should_index.get("should_index", false) and not update_render.get("update_render", true) and bool(render_update.get("no_op", false)) and surface.get("has_surface", false) and deep.get("is_deep", false) and damage.get("damages", false) and int(real_blend_id.get("real_blend_id", 0)) == -98311 and int(real_blend_fallback.get("real_blend_id", 0)) == 11 and edges.get("edges", null) == [["north", "middle", "south"]] and edge.get("edge", null) == "south" and not do_edge.get("do_edge", true) and missing_edges_do_edge.get("do_edge", false) and draw_non_layer.get("blenders", []).size() == 1 and draw_blended.get("draw_call_count", 0) == 1 and draw_edges.get("blenders", []).size() == 1 and draw_edges.get("draw_blended", {}).get("draw_call_count", 0) == 1 and draw_base.get("draw_main_call_count", 0) == 1 and draw_base.get("draw_edges_called", false) and draw_base.get("draw_overlay_called", false) and draw_base_liquid.get("draw_main_call_count", 0) == 2 and draw_base_liquid.get("draw_alpha", null) == 0.35 and draw_base_liquid.get("draw_color_called", false) and not draw_base_no_edges.get("draw_edges_called", true) and draw_overlay.get("draw_base_called", false) and not draw_overlay_skipped.get("draw_base_called", true) and int(variant.get("variant_index", -1)) >= 0 and int(variant.get("variant_index", -1)) < 3 and int(variant_max.get("variant_index", -1)) >= 0 and int(variant_max.get("variant_index", -1)) < 5 and icons_found.get("icon_name", "") == "stone" and icons_found.get("icons", []) == ["stone"] and icons_fallback.get("icon_name", "") == "stone1" and icons_fallback.get("icons", []) == ["stone1"] and floor_changed.get("no_op", false) and display_icon_base.get("display_icon", "") == "base-icon" and display_icon_liquid.get("display_icon", "") == "liquid-icon" and display_name_base.get("display_name", "") == "Base floor" and display_name_liquid.get("display_name", "") == "Liquid floor" and bool(generated.get("matches", false)) and bool(generated_real_blend.get("matches", false)) and bool(generated_edge.get("matches", false)) and bool(generated_draw_non_layer.get("matches", false)) and bool(generated_draw_blended.get("matches", false)) and bool(generated_draw_edges.get("matches", false)) and bool(generated_draw_base.get("matches", false)) and bool(generated_draw_overlay.get("matches", false)) and bool(generated_variant.get("matches", false)) and bool(generated_variant_max.get("matches", false)) and bool(generated_icons.get("matches", false)) and bool(generated_floor_changed.get("matches", false)) and bool(generated_display_icon.get("matches", false)) and bool(generated_display_name.get("matches", false)) and bool(generated_autotile_same.get("matches", false))}
	proof["draw_main"] = draw_main_checks
	proof["matches"] = proof["matches"] and draw_main_tiling.get("branch", "") == "tiling" and draw_main_tiling.get("region", null) == "tiling-north-west" and draw_main_tiling.get("alpha_reset_called", false) and draw_main_autotile_mid.get("branch", "") == "autotile" and int(draw_main_autotile_mid.get("autotile_bit", -1)) == 13 and ["autotile-mid-a", "autotile-mid-b"].has(draw_main_autotile_mid.get("region", null)) and draw_main_autotile_mid.get("alpha_reset_called", false) and draw_main_variant.get("branch", "") == "variant" and ["variant-a", "variant-b", "variant-c"].has(draw_main_variant.get("region", null)) and draw_main_variant.get("alpha_reset_called", false) and bool(generated_draw_main.get("matches", false))
	runtime_proof_state.write_proof("FloorModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
