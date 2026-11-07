extends RefCounted
class_name SourceFloorState

const source_text := preload("res://src/game/SourceFloorSourceTextState.gd")
const owner_registry := preload("res://src/game/SourceRuntimeOwnerBlockRegistry.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const generated_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const GENERATED_SCRIPT := source_text.GENERATED_SCRIPT

static func _base(owner: String, method: String) -> Dictionary:
	return {"source_owner": owner, "source": source_text.SOURCE, "method": method}

static func should_index_state(tile: Variant) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_SHOULD_INDEX_STATE, source_text.METHOD_SHOULD_INDEX)
	result["tile"] = tile
	result["return_expr"] = source_text.SHOULD_INDEX_RETURN
	result["should_index"] = true
	return result

static func get_display_icon_state(liquid_drop_present: bool, super_display_icon: Variant, liquid_drop_icon: Variant) -> Dictionary:
	var display_icon: Variant = liquid_drop_icon if liquid_drop_present else super_display_icon
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_GET_DISPLAY_ICON_STATE, source_text.METHOD_GET_DISPLAY_ICON)
	result["tile_liquid_drop_present"] = liquid_drop_present
	result["super_display_icon"] = super_display_icon
	result["liquid_drop_icon"] = liquid_drop_icon
	result["display_icon"] = display_icon
	result["return_expr"] = source_text.GET_DISPLAY_ICON_RETURN
	return result

static func get_display_name_state(liquid_drop_present: bool, super_display_name: String, liquid_drop_name: String) -> Dictionary:
	var display_name := liquid_drop_name if liquid_drop_present else super_display_name
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_GET_DISPLAY_NAME_STATE, source_text.METHOD_GET_DISPLAY_NAME)
	result["tile_liquid_drop_present"] = liquid_drop_present
	result["super_display_name"] = super_display_name
	result["liquid_drop_name"] = liquid_drop_name
	result["display_name"] = display_name
	result["return_expr"] = source_text.GET_DISPLAY_NAME_RETURN
	return result

static func draw_main_state(tile_x: int, tile_y: int, tiling_variants: int, tiling_size: int, tiling_regions: Array, autotile: bool, autotile_variants: int, autotile_variant_regions: Array, autotile_regions: Array, autotile_mid_variants: int, autotile_mid_regions: Array, autotile_same: Array, tile_bitmask_values: Array, variant_regions: Array) -> Dictionary:
	var branch := "variant"
	var tiling_index := -1
	var autotile_variant_index := -1
	var autotile_bits := 0
	var autotile_bit := -1
	var region: Variant = null
	if tiling_variants > 0:
		branch = "tiling"
		var safe_tiling_size := maxi(1, tiling_size)
		tiling_index = source_math_state.random_seed_int((int(tile_x / safe_tiling_size) << 16) | (int(tile_y / safe_tiling_size) & 0xffff), 0, tiling_variants - 1)
		var tiling_group: Variant = tiling_regions[tiling_index] if tiling_index >= 0 and tiling_index < tiling_regions.size() else []
		var tx := posmod(tile_x, safe_tiling_size)
		var ty := safe_tiling_size - 1 - posmod(tile_y, safe_tiling_size)
		if tiling_group is Array and tx >= 0 and tx < tiling_group.size() and tiling_group[tx] is Array and ty >= 0 and ty < tiling_group[tx].size():
			region = tiling_group[tx][ty]
	elif autotile:
		branch = "autotile"
		for index in range(mini(8, autotile_same.size())):
			if bool(autotile_same[index]):
				autotile_bits |= (1 << index)
		if autotile_bits >= 0 and autotile_bits < tile_bitmask_values.size():
			autotile_bit = int(tile_bitmask_values[autotile_bits])
		var regions: Array = autotile_regions
		if autotile_variants > 1 and autotile_variant_regions.size() > 0:
			autotile_variant_index = variant_state(tile_x, tile_y, autotile_variant_regions.size(), (tile_x << 16) | (tile_y & 0xffff)).get("variant_index", 0)
			if autotile_variant_index >= 0 and autotile_variant_index < autotile_variant_regions.size() and autotile_variant_regions[autotile_variant_index] is Array:
				regions = autotile_variant_regions[autotile_variant_index]
		if autotile_bit == 13 and autotile_mid_variants > 1 and autotile_mid_regions.size() > 0:
			autotile_variant_index = variant_state(tile_x, tile_y, autotile_mid_regions.size(), (tile_x << 16) | (tile_y & 0xffff)).get("variant_index", 0)
			if autotile_variant_index >= 0 and autotile_variant_index < autotile_mid_regions.size():
				region = autotile_mid_regions[autotile_variant_index]
		elif autotile_bit >= 0 and autotile_bit < regions.size():
			region = regions[autotile_bit]
	else:
		var variant_result := variant_state(tile_x, tile_y, -1, (tile_x << 16) | (tile_y & 0xffff), variant_regions.size())
		var variant_index := int(variant_result.get("variant_index", 0))
		if variant_index >= 0 and variant_index < variant_regions.size():
			region = variant_regions[variant_index]
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_DRAW_MAIN_STATE, source_text.METHOD_DRAW_MAIN)
	result["tile_x"] = tile_x
	result["tile_y"] = tile_y
	result["branch"] = branch
	result["tiling_variants"] = tiling_variants
	result["tiling_size"] = tiling_size
	result["tiling_index"] = tiling_index
	result["autotile"] = autotile
	result["autotile_variants"] = autotile_variants
	result["autotile_same"] = autotile_same
	result["autotile_bits"] = autotile_bits
	result["autotile_bit"] = autotile_bit
	result["autotile_variant_index"] = autotile_variant_index
	result["region"] = region
	result["draw_call"] = "Draw.rect(region, tile.worldx(), tile.worldy());"
	result["alpha_reset"] = source_text.DRAW_MAIN_ALPHA_RESET
	result["alpha_reset_called"] = true
	result["tiling_guard"] = source_text.DRAW_MAIN_TILING_GUARD
	result["tiling_index_expr"] = source_text.DRAW_MAIN_TILING_INDEX
	result["tiling_region_expr"] = source_text.DRAW_MAIN_TILING_REGION
	result["tiling_call"] = source_text.DRAW_MAIN_TILING_CALL
	result["autotile_guard"] = source_text.DRAW_MAIN_AUTOTILE_GUARD
	result["bits_init"] = source_text.DRAW_MAIN_BITS_INIT
	result["autotile_regions_expr"] = source_text.DRAW_MAIN_AUTOTILE_REGIONS
	result["autotile_loop"] = source_text.DRAW_MAIN_AUTOTILE_LOOP
	result["autotile_bit_call"] = source_text.DRAW_MAIN_AUTOTILE_BIT
	result["autotile_index_expr"] = source_text.DRAW_MAIN_AUTOTILE_INDEX
	result["autotile_region_expr"] = source_text.DRAW_MAIN_AUTOTILE_REGION
	result["variant_region_call"] = source_text.DRAW_MAIN_VARIANT_REGION
	return result

static func update_render_state(tile: Variant) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_UPDATE_RENDER_STATE, source_text.METHOD_UPDATE_RENDER)
	result["tile"] = tile
	result["todo_expr"] = "//TODO currently broken for dynamically edited floor tiles"
	result["return_expr"] = source_text.UPDATE_RENDER_RETURN
	result["update_render"] = false
	return result

static func render_update_state(tile: Variant) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_RENDER_UPDATE_STATE, source_text.METHOD_RENDER_UPDATE)
	result["tile"] = tile
	result["no_op"] = true
	return result

static func has_surface_state(is_liquid: bool, solid: bool) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_HAS_SURFACE_STATE, source_text.METHOD_HAS_SURFACE)
	result["is_liquid"] = is_liquid
	result["solid"] = solid
	result["return_expr"] = source_text.HAS_SURFACE_RETURN
	result["has_surface"] = not is_liquid and not solid
	return result

static func is_deep_state(drown_time: float) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_IS_DEEP_STATE, source_text.METHOD_IS_DEEP)
	result["drown_time"] = drown_time
	result["return_expr"] = source_text.IS_DEEP_RETURN
	result["is_deep"] = drown_time > 0.0
	return result

static func damages_state(damage_taken: float, status_damage: float, status_present: bool) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_DAMAGES_STATE, source_text.METHOD_DAMAGES)
	result["damage_taken"] = damage_taken
	result["status_damage"] = status_damage
	result["status_present"] = status_present
	result["return_expr"] = source_text.DAMAGES_RETURN
	result["damages"] = damage_taken > 0.0 or (status_present and status_damage > 0.0)
	return result

static func draw_base_state(draw_edge_in: bool, tile_overlay_is_air: bool, tile_floor_is_this: bool, is_liquid: bool, overlay_alpha: float, draw_edges_result: Dictionary = {}) -> Dictionary:
	var liquid_overlay_gate := not tile_overlay_is_air and tile_floor_is_this and is_liquid
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_DRAW_BASE_STATE, source_text.METHOD_DRAW_BASE)
	result["draw_edge_in"] = draw_edge_in
	result["tile_overlay_is_air"] = tile_overlay_is_air
	result["tile_floor_is_this"] = tile_floor_is_this
	result["is_liquid"] = is_liquid
	result["overlay_alpha"] = overlay_alpha
	result["draw_main_call_count"] = 2 if liquid_overlay_gate else 1
	result["draw_main_called"] = true
	result["draw_edges_called"] = draw_edge_in
	result["draw_overlay_called"] = true
	result["liquid_overlay_gate"] = liquid_overlay_gate
	result["draw_alpha"] = 1.0 - overlay_alpha if liquid_overlay_gate else null
	result["draw_alpha_called"] = liquid_overlay_gate
	result["draw_color_called"] = liquid_overlay_gate
	result["draw_edges"] = draw_edges_result if draw_edge_in else {}
	result["main_call"] = source_text.DRAW_BASE_MAIN_CALL
	result["edge_guard"] = source_text.DRAW_BASE_EDGE_GUARD
	result["edges_call"] = source_text.DRAW_BASE_EDGES_CALL
	result["overlay_call"] = source_text.DRAW_BASE_OVERLAY_CALL
	result["liquid_overlay_guard"] = source_text.DRAW_BASE_LIQUID_OVERLAY_GUARD
	result["alpha_call"] = source_text.DRAW_BASE_ALPHA_CALL
	result["color_call"] = source_text.DRAW_BASE_COLOR_CALL
	return result

static func draw_overlay_state(overlay_is_air: bool, overlay_is_this: bool, overlay_draw_base_result: Dictionary = {}) -> Dictionary:
	var draw_base_called := not overlay_is_air and not overlay_is_this
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_DRAW_OVERLAY_STATE, source_text.METHOD_DRAW_OVERLAY)
	result["overlay_is_air"] = overlay_is_air
	result["overlay_is_this"] = overlay_is_this
	result["draw_base_called"] = draw_base_called
	result["draw_base_result"] = overlay_draw_base_result if draw_base_called else {}
	result["guard_expr"] = source_text.DRAW_OVERLAY_GUARD
	result["draw_base_call"] = source_text.DRAW_OVERLAY_CALL
	return result

static func variant_state(x: int, y: int, max_value: int, packed_position: int, variant_region_count: int = -1) -> Dictionary:
	var effective_max := variant_region_count if max_value < 0 else max_value
	var bounded_max := maxi(0, effective_max - 1)
	var variant_index := source_math_state.random_seed_int(packed_position, 0, bounded_max)
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_VARIANT_STATE, source_text.METHOD_VARIANT_MAX if max_value >= 0 else source_text.METHOD_VARIANT)
	result["x"] = x
	result["y"] = y
	result["max"] = max_value
	result["variant_region_count"] = variant_region_count
	result["packed_position"] = packed_position
	result["effective_max"] = effective_max
	result["bounded_max"] = bounded_max
	result["variant_index"] = variant_index
	result["delegate_expr"] = source_text.VARIANT_DELEGATE if max_value < 0 else null
	result["return_expr"] = source_text.VARIANT_RETURN
	return result

static func check_autotile_same_state(other_present: bool, tile_floor_is_this: bool, other_floor_matches: bool, other_overlay_matches: bool) -> Dictionary:
	var selected_matches := other_floor_matches if tile_floor_is_this else other_overlay_matches
	var same := other_present and selected_matches
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_CHECK_AUTOTILE_SAME_STATE, source_text.METHOD_CHECK_AUTOTILE_SAME)
	result["other_present"] = other_present
	result["tile_floor_is_this"] = tile_floor_is_this
	result["other_floor_matches"] = other_floor_matches
	result["other_overlay_matches"] = other_overlay_matches
	result["selected_matches"] = selected_matches
	result["return_expr"] = source_text.CHECK_AUTOTILE_SAME_RETURN
	result["same"] = same
	return result

static func icons_state(name_value: String, atlas_has_name: bool, icon_region: Variant) -> Dictionary:
	var icon_name := name_value if atlas_has_name else name_value + "1"
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_ICONS_STATE, source_text.METHOD_ICONS)
	result["name"] = name_value
	result["atlas_has_name"] = atlas_has_name
	result["icon_name"] = icon_name
	result["icon_region"] = icon_region
	result["icons"] = [icon_region]
	result["return_expr"] = source_text.ICONS_RETURN
	return result

static func floor_changed_state(tile: Variant) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_FLOOR_CHANGED_STATE, source_text.METHOD_FLOOR_CHANGED)
	result["tile"] = tile
	result["no_op"] = true
	return result

static func real_blend_id_state(tile_floor_is_liquid: bool, tile_overlay_is_air: bool, tile_overlay_is_ore: bool, tile_overlay_blend_id: int, tile_floor_blend_id: int, blend_id: int) -> Dictionary:
	var liquid_overlay_gate := tile_floor_is_liquid and not tile_overlay_is_air and not tile_overlay_is_ore
	var combined := int(tile_overlay_blend_id) | (int(tile_floor_blend_id) << 15)
	var real_blend_id := -combined if liquid_overlay_gate else blend_id
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_REAL_BLEND_ID_STATE, source_text.METHOD_REAL_BLEND_ID)
	result["tile_floor_is_liquid"] = tile_floor_is_liquid
	result["tile_overlay_is_air"] = tile_overlay_is_air
	result["tile_overlay_is_ore"] = tile_overlay_is_ore
	result["tile_overlay_blend_id"] = tile_overlay_blend_id
	result["tile_floor_blend_id"] = tile_floor_blend_id
	result["blend_id"] = blend_id
	result["liquid_overlay_gate"] = liquid_overlay_gate
	result["combined_blend_id"] = combined
	result["guard_expr"] = source_text.REAL_BLEND_ID_GUARD
	result["return_expr"] = source_text.REAL_BLEND_ID_RETURN
	result["fallback_expr"] = source_text.REAL_BLEND_ID_FALLBACK
	result["real_blend_id"] = real_blend_id
	return result

static func edges_state(blend_group_edges: Variant) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_EDGES_STATE, source_text.METHOD_EDGES)
	result["blend_group_edges"] = blend_group_edges
	result["return_expr"] = source_text.EDGES_RETURN
	result["edges"] = blend_group_edges
	return result

static func edge_state(edges_grid: Array, x: int, y: int, rx: int, ry: int) -> Dictionary:
	var row: Array = edges_grid[rx] if rx >= 0 and rx < edges_grid.size() and edges_grid[rx] is Array else []
	var edge_value: Variant = row[2 - ry] if 2 - ry >= 0 and 2 - ry < row.size() else null
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_EDGE_STATE, source_text.METHOD_EDGE)
	result["edges"] = edges_grid
	result["x"] = x
	result["y"] = y
	result["rx"] = rx
	result["ry"] = ry
	result["index_y"] = 2 - ry
	result["return_expr"] = source_text.EDGE_RETURN
	result["edge"] = edge_value
	return result

static func do_edge_state(other_real_blend_id: int, self_real_blend_id: int, edges_present: bool) -> Dictionary:
	var do_edge := other_real_blend_id > self_real_blend_id or not edges_present
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_DO_EDGE_STATE, source_text.METHOD_DO_EDGE)
	result["other_real_blend_id"] = other_real_blend_id
	result["self_real_blend_id"] = self_real_blend_id
	result["edges_present"] = edges_present
	result["return_expr"] = source_text.DO_EDGE_RETURN
	result["do_edge"] = do_edge
	return result

static func _floor_id(value: Variant) -> int:
	return int(value.get("id", 0)) if value is Dictionary else 0

static func _selected_neighbor(tile_floor_is_this: bool, neighbor: Dictionary) -> Dictionary:
	if tile_floor_is_this or bool(neighbor.get("overlay_is_air", true)):
		return neighbor.get("floor", {}) if neighbor.get("floor", {}) is Dictionary else {}
	return neighbor.get("overlay", {}) if neighbor.get("overlay", {}) is Dictionary else {}

static func draw_blended_state(blenders: Array, neighbors: Array, dirs: Array, tile_floor_is_this: bool, check_id: bool) -> Dictionary:
	var sorted_blenders := blenders.duplicate()
	sorted_blenders.sort_custom(func(a: Variant, b: Variant) -> bool:
		var a_priority := _floor_id(a) + (99999 if not tile_floor_is_this and bool(a.get("is_tile_floor", false)) else 0)
		var b_priority := _floor_id(b) + (99999 if not tile_floor_is_this and bool(b.get("is_tile_floor", false)) else 0)
		return a_priority < b_priority
	)
	var draw_calls: Array = []
	for block in sorted_blenders:
		if not block is Dictionary:
			continue
		for index in range(mini(8, neighbors.size())):
			var neighbor: Variant = neighbors[index]
			if not neighbor is Dictionary or bool(neighbor.get("is_null", false)):
				continue
			var selected := _selected_neighbor(tile_floor_is_this, neighbor)
			var selected_id := _floor_id(selected)
			var block_id := _floor_id(block)
			var direction_matches := not check_id or (index < dirs.size() and int(dirs[index]) == block_id)
			if selected_id == block_id and direction_matches:
				draw_calls.append({"block": block, "neighbor_index": index, "edge_args": {"x": int(neighbor.get("tile_x", 0)), "y": int(neighbor.get("tile_y", 0)), "rx": 1 - int(neighbor.get("point_x", 0)), "ry": 1 - int(neighbor.get("point_y", 0))}, "draw_call": source_text.DRAW_BLENDED_CALL})
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_DRAW_BLENDED_STATE, source_text.METHOD_DRAW_BLENDED)
	result["blenders"] = blenders
	result["sorted_blenders"] = sorted_blenders
	result["neighbors"] = neighbors
	result["dirs"] = dirs
	result["tile_floor_is_this"] = tile_floor_is_this
	result["check_id"] = check_id
	result["sort_expr"] = source_text.DRAW_BLENDED_SORT
	result["resolve_expr"] = source_text.DRAW_BLENDED_RESOLVE
	result["guard_expr"] = source_text.DRAW_BLENDED_GUARD
	result["draw_calls"] = draw_calls
	result["draw_call_count"] = draw_calls.size()
	return result

static func draw_non_layer_state(neighbors: Array, layer: Variant, tile_x: int, tile_y: int) -> Dictionary:
	var dirs: Array = []
	dirs.resize(8)
	for index in range(dirs.size()):
		dirs[index] = 0
	var blenders: Array = []
	var blended_ids: Array = []
	for index in range(mini(8, neighbors.size())):
		var neighbor: Variant = neighbors[index]
		if not neighbor is Dictionary or bool(neighbor.get("is_null", false)):
			continue
		var floor: Variant = neighbor.get("floor", {})
		if not floor is Dictionary:
			continue
		var valid := bool(floor.get("draw_edge_out", false)) and str(floor.get("cache_layer", "")) == str(layer) and bool(floor.get("edges_present", false))
		if valid:
			var floor_id := _floor_id(floor)
			if not blended_ids.has(floor_id):
				blended_ids.append(floor_id)
				blenders.append(floor)
				dirs[index] = int(neighbor.get("floor_id", floor_id))
	var blended := draw_blended_state(blenders, neighbors, dirs, true, false)
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_DRAW_NON_LAYER_STATE, source_text.METHOD_DRAW_NON_LAYER)
	result["neighbors"] = neighbors
	result["layer"] = layer
	result["tile_x"] = tile_x
	result["tile_y"] = tile_y
	result["dirs"] = dirs
	result["blenders"] = blenders
	result["blended_ids"] = blended_ids
	result["clear_dirs_expr"] = source_text.DRAW_NON_LAYER_CLEAR_DIRS
	result["clear_blenders_expr"] = source_text.DRAW_NON_LAYER_CLEAR_BLENDERS
	result["clear_blended_expr"] = source_text.DRAW_NON_LAYER_CLEAR_BLENDED
	result["neighbor_guard_expr"] = source_text.DRAW_NON_LAYER_GUARD
	result["draw_blended_call"] = source_text.DRAW_NON_LAYER_CALL
	result["draw_blended"] = blended
	return result

static func draw_edges_state(neighbors: Array, real_cache_layer: Variant, tile_floor_is_this: bool, tile_x: int, tile_y: int, self_real_blend_id: int, self_edges_present: bool) -> Dictionary:
	var dirs: Array = []
	dirs.resize(8)
	for index in range(dirs.size()):
		dirs[index] = 0
	var blenders: Array = []
	var blended_ids: Array = []
	var do_edge_calls: Array = []
	for index in range(mini(8, neighbors.size())):
		var neighbor: Variant = neighbors[index]
		if not neighbor is Dictionary or bool(neighbor.get("is_null", false)):
			continue
		var selected := _selected_neighbor(tile_floor_is_this, neighbor)
		var floor: Variant = neighbor.get("floor", {})
		if selected.is_empty() or not floor is Dictionary:
			continue
		var edge_decision := do_edge_state(int(neighbor.get("other_real_blend_id", selected.get("real_blend_id", 0))), self_real_blend_id, self_edges_present)
		do_edge_calls.append(edge_decision)
		var valid := bool(selected.get("draw_edge_out", false)) and bool(edge_decision.get("do_edge", false)) and str(floor.get("cache_layer", "")) == str(real_cache_layer) and bool(neighbor.get("ob_edges_present", selected.get("edges_present", false)))
		if valid:
			var selected_id := _floor_id(selected)
			if not blended_ids.has(selected_id):
				blended_ids.append(selected_id)
				blenders.append(selected)
				dirs[index] = selected_id
	var blended := draw_blended_state(blenders, neighbors, dirs, tile_floor_is_this, true)
	var result := _base(owner_registry.PORT_GAME_SOURCE_FLOOR_DRAW_EDGES_STATE, source_text.METHOD_DRAW_EDGES)
	result["neighbors"] = neighbors
	result["real_cache_layer"] = real_cache_layer
	result["tile_floor_is_this"] = tile_floor_is_this
	result["tile_x"] = tile_x
	result["tile_y"] = tile_y
	result["self_real_blend_id"] = self_real_blend_id
	result["self_edges_present"] = self_edges_present
	result["dirs"] = dirs
	result["blenders"] = blenders
	result["blended_ids"] = blended_ids
	result["do_edge_calls"] = do_edge_calls
	result["clear_blenders_expr"] = source_text.DRAW_EDGES_CLEAR_BLENDERS
	result["clear_blended_expr"] = source_text.DRAW_EDGES_CLEAR_BLENDED
	result["clear_dirs_expr"] = source_text.DRAW_EDGES_CLEAR_DIRS
	result["cache_layer_expr"] = source_text.DRAW_EDGES_CACHE_LAYER
	result["resolve_expr"] = source_text.DRAW_EDGES_RESOLVE
	result["neighbor_guard_expr"] = source_text.DRAW_EDGES_GUARD
	result["draw_blended_call"] = source_text.DRAW_EDGES_CALL
	result["draw_blended"] = blended
	return result

static func generated_bridge(method: String, args: Array, canonical: Dictionary) -> Dictionary:
	var result = generated_runtime.call_java_method(GENERATED_SCRIPT, method, args)
	return {"result": result, "canonical": canonical, "matches": generated_runtime.generated_state_matches_canonical_subset(result, canonical)}
