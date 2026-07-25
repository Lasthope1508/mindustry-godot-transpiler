extends RefCounted
class_name SourceBuildingDrawState

const SourceBuildingDefaults := preload("res://src/game/SourceBuildingDefaults.gd")
const SOURCE_BUILDING_DRAW_SELECT_INACTIVE_UNIT_FACTORY_STATUS := SourceBuildingDefaults.DRAW_SELECT_INACTIVE_UNIT_FACTORY_STATUS
const SOURCE_BUILDING_DRAW_SELECT_BUNDLE_KEY := SourceBuildingDefaults.DRAW_SELECT_BUNDLE_KEY
const SOURCE_BUILDING_DRAW_SELECT_DELAY_MIN := SourceBuildingDefaults.DRAW_SELECT_DELAY_MIN
const SOURCE_BUILDING_DRAW_CRACK_HEALTH_FULL := SourceBuildingDefaults.DRAW_CRACK_HEALTH_FULL
const SOURCE_BUILDING_DRAW_CRACK_LIGHTNESS_BASE := SourceBuildingDefaults.DRAW_CRACK_LIGHTNESS_BASE
const SOURCE_BUILDING_DRAW_CRACK_LIGHTNESS_SCALE := SourceBuildingDefaults.DRAW_CRACK_LIGHTNESS_SCALE
const SOURCE_BUILDING_DRAW_CRACK_POSITION_MODULO := SourceBuildingDefaults.DRAW_CRACK_POSITION_MODULO
const SOURCE_BUILDING_DRAW_CRACK_ROTATION_STEP_DEGREES := SourceBuildingDefaults.DRAW_CRACK_ROTATION_STEP_DEGREES
const SOURCE_BUILDING_DRAW_CRACK_REGION_INDEX_OFFSET := SourceBuildingDefaults.DRAW_CRACK_REGION_INDEX_OFFSET
const SOURCE_BUILDING_DRAW_ROTATION_STEP_DEGREES := SourceBuildingDefaults.DRAW_ROTATION_STEP_DEGREES
const SOURCE_BUILDING_DRAW_ROTATION_DISABLED := SourceBuildingDefaults.DRAW_ROTATION_DISABLED
const SOURCE_BUILDING_DRAW_LIQUID_LIGHT_AMOUNT_MIN := SourceBuildingDefaults.DRAW_LIQUID_LIGHT_AMOUNT_MIN
const SOURCE_BUILDING_DRAW_LIQUID_LIGHT_FRACT := SourceBuildingDefaults.DRAW_LIQUID_LIGHT_FRACT
const SOURCE_BUILDING_DRAW_LIQUID_LIGHT_OPACITY_MIN := SourceBuildingDefaults.DRAW_LIQUID_LIGHT_OPACITY_MIN
const SOURCE_BUILDING_DRAW_LIQUID_LIGHT_RADIUS_SCALE := SourceBuildingDefaults.DRAW_LIQUID_LIGHT_RADIUS_SCALE
const SOURCE_BUILDING_DRAW_LIGHT_LERP_PROGRESS := SourceBuildingDefaults.DRAW_LIGHT_LERP_PROGRESS
const SOURCE_BUILDING_DRAW_LIGHT_TARGET_FULL := SourceBuildingDefaults.DRAW_LIGHT_TARGET_FULL
const SOURCE_BUILDING_DRAW_LIGHT_TARGET_EMPTY := SourceBuildingDefaults.DRAW_LIGHT_TARGET_EMPTY
const SOURCE_BUILDING_DRAW_TEAM_BORDER_REGION := SourceBuildingDefaults.DRAW_TEAM_BORDER_REGION
const SOURCE_BUILDING_DRAW_TEAM_BORDER_OFFSET := SourceBuildingDefaults.DRAW_TEAM_BORDER_OFFSET

static func _with_source_owner(source_exprs: Dictionary, state: Dictionary) -> Dictionary:
	var result := source_exprs.duplicate()
	result.merge(state)
	return result

static func _building_comp_instance():
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	return script.new()

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"random_seed_int": Callable(game, "source_arc_random_seed_int"),
		"lerp_delta": Callable(game, "source_arc_lerp_delta"),
	}

static func draw_status_state(enable_draw_status: bool, consumers_length: int, block_size_value: int, source_x: float, source_y: float, source_tilesize: float) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_status_state"}
	if not (enable_draw_status and consumers_length > 0):
		return _with_source_owner(source_exprs, {"visible": false})
	var multiplier := SourceBuildingDefaults.DRAW_STATUS_MULTIPLIER_LARGE if block_size_value > 1 else SourceBuildingDefaults.DRAW_STATUS_MULTIPLIER_SMALL
	var brcx := source_x + (float(block_size_value) * source_tilesize / 2.0) - (source_tilesize * multiplier / 2.0)
	var brcy := source_y - (float(block_size_value) * source_tilesize / 2.0) + (source_tilesize * multiplier / 2.0)
	return _with_source_owner(source_exprs, {"visible": true, "multiplier": multiplier, "brcx": brcx, "brcy": brcy, "gray_square_size": SourceBuildingDefaults.DRAW_STATUS_GRAY_SQUARE_SIZE * multiplier, "status_square_size": SourceBuildingDefaults.DRAW_STATUS_STATUS_SQUARE_SIZE * multiplier})

static func generated_draw_status_bridge_state(enable_draw_status: bool, consumers_length: int, block_size_value: int, source_x: float, source_y: float, source_tilesize: float) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawStatus_123([enable_draw_status, consumers_length, block_size_value, source_x, source_y, source_tilesize])
	return {
		"source_owner": "PortGame.source_building_draw_status_state",
		"generated_owner": "BuildingComp.java_method_drawStatus_123",
		"result": result,
	}

static func draw_cracks_state(draw_cracks: bool, damaged_state: bool, block_size_value: int, max_crack_size: int, health_fraction: float, crack_regions: int, position_id: int) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_cracks_state"}
	if not draw_cracks or not damaged_state or block_size_value > max_crack_size:
		return _with_source_owner(source_exprs, {"visible": false})
	var crack_index := clampi(int((SOURCE_BUILDING_DRAW_CRACK_HEALTH_FULL - health_fraction) * float(crack_regions)), 0, crack_regions - 1)
	var lightness := SOURCE_BUILDING_DRAW_CRACK_LIGHTNESS_BASE + (SOURCE_BUILDING_DRAW_CRACK_HEALTH_FULL - health_fraction) * SOURCE_BUILDING_DRAW_CRACK_LIGHTNESS_SCALE
	var crack_rotation_degrees := (position_id % SOURCE_BUILDING_DRAW_CRACK_POSITION_MODULO) * SOURCE_BUILDING_DRAW_CRACK_ROTATION_STEP_DEGREES
	return _with_source_owner(source_exprs, {"visible": true, "region_size_index": block_size_value - SOURCE_BUILDING_DRAW_CRACK_REGION_INDEX_OFFSET, "crack_index": crack_index, "lightness": lightness, "rotation_degrees": crack_rotation_degrees})

static func generated_draw_cracks_bridge_state(draw_cracks: bool, damaged_state: bool, block_size_value: int, max_crack_size: int, health_fraction: float, crack_regions: int, position_id: int) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawCracks_124([draw_cracks, damaged_state, block_size_value, max_crack_size, health_fraction, crack_regions, position_id])
	return {
		"source_owner": "PortGame.source_building_draw_cracks_state",
		"generated_owner": "BuildingComp.java_method_drawCracks_124",
		"result": result,
	}

static func generated_draw_select_bridge_state(block_status: String, source_x: float, source_y: float, source_rotation: float, tile_x: int, tile_y: int, unit_activation_delay: float, state_tick: float) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawSelect_125([block_status, source_x, source_y, source_rotation, tile_x, tile_y, unit_activation_delay, state_tick])
	return {
		"source_owner": "PortGame.source_building_draw_select_state",
		"generated_owner": "BuildingComp.java_method_drawSelect_125",
		"result": result,
	}

static func generated_draw_item_selection_bridge_state(has_selection: bool, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, icon_small: float, selection_icon_ratio: float) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawItemSelection_126([has_selection, source_x, source_y, block_size_value, source_tilesize, icon_small, selection_icon_ratio])
	return {
		"source_owner": "PortGame.source_building_draw_item_selection_state",
		"generated_owner": "BuildingComp.java_method_drawItemSelection_126",
		"result": result,
	}

static func generated_draw_disabled_bridge_state(source_x: float, source_y: float) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawDisabled_127([source_x, source_y])
	return {
		"source_owner": "PortGame.source_building_draw_disabled_state",
		"generated_owner": "BuildingComp.java_method_drawDisabled_127",
		"result": result,
	}

static func generated_draw_bridge_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_draw_128([variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants])
	return {
		"source_owner": "PortGame.source_building_draw_state",
		"generated_owner": "BuildingComp.java_method_draw_128",
		"result": result,
	}

static func generated_draw_cached_bridge_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawCached_129([variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants])
	return {
		"source_owner": "PortGame.source_building_draw_cached_state",
		"generated_owner": "BuildingComp.java_method_drawCached_129",
		"result": result,
	}

static func generated_recache_bridge_state(headless: bool, building_cache_layer: Variant, tile_state: Variant) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_recache_130([headless, building_cache_layer, tile_state])
	return {
		"source_owner": "PortGame.source_building_recache_state",
		"generated_owner": "BuildingComp.java_method_recache_130",
		"result": result,
	}

static func generated_payload_draw_bridge_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_payloadDraw_131([draw_cached, draw_dynamic, current_z, building_cache_layer_z, variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants])
	return {
		"source_owner": "PortGame.source_building_payload_draw_state",
		"generated_owner": "BuildingComp.java_method_payloadDraw_131",
		"result": result,
	}

static func generated_draw_team_top_bridge_state(team_region_found: bool, team_region_matches_team: bool, team_color: String, source_x: float, source_y: float) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawTeamTop_132([team_region_found, team_region_matches_team, team_color, source_x, source_y])
	return {
		"source_owner": "PortGame.source_building_draw_team_top_state",
		"generated_owner": "BuildingComp.java_method_drawTeamTop_132",
		"result": result,
	}

static func generated_draw_light_bridge_state(has_liquids: bool, draw_liquid_light: bool, light_liquid_is_null: bool, current_liquid_color: String, current_liquid_alpha: float, light_liquid_color: String, light_liquid_alpha: float, selected_liquid_amount: float, visual_liquid: float, source_delta: float, source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawLight_133([has_liquids, draw_liquid_light, light_liquid_is_null, current_liquid_color, current_liquid_alpha, light_liquid_color, light_liquid_alpha, selected_liquid_amount, visual_liquid, source_delta, source_x, source_y, block_size_value])
	return {
		"source_owner": "PortGame.source_building_draw_light_state",
		"generated_owner": "BuildingComp.java_method_drawLight_133",
		"result": result,
	}

static func generated_draw_liquid_light_bridge_state(source_x: float, source_y: float, block_size_value: int, light_color: String, light_alpha: float, amount: float) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawLiquidLight_134([source_x, source_y, block_size_value, light_color, light_alpha, amount])
	return {
		"source_owner": "PortGame.source_building_draw_liquid_light_state",
		"generated_owner": "BuildingComp.java_method_drawLiquidLight_134",
		"result": result,
	}

static func generated_draw_team_bridge_state(team_color: String, source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_drawTeam_135([team_color, source_x, source_y, block_size_value, source_tilesize])
	return {
		"source_owner": "PortGame.source_building_draw_team_state",
		"generated_owner": "BuildingComp.java_method_drawTeam_135",
		"result": result,
	}

static func draw_select_state(block_status: String, source_x: float, source_y: float, source_rotation: float, tile_x: int, tile_y: int, unit_activation_delay: float, state_tick: float) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_select_state"}
	var inactive_unit_factory := block_status == SOURCE_BUILDING_DRAW_SELECT_INACTIVE_UNIT_FACTORY_STATUS
	var remaining_activation_delay := maxf(SOURCE_BUILDING_DRAW_SELECT_DELAY_MIN, unit_activation_delay - state_tick)
	return _with_source_owner(source_exprs, {"overlay_visible": true, "overlay_x": source_x, "overlay_y": source_y, "overlay_rotation": source_rotation, "place_text_visible": inactive_unit_factory, "place_text_bundle_key": SOURCE_BUILDING_DRAW_SELECT_BUNDLE_KEY, "place_text_time": remaining_activation_delay, "place_text_tile_x": tile_x, "place_text_tile_y": tile_y})

static func draw_item_selection_state(has_selection: bool, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, icon_small: float, selection_icon_ratio: float) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_item_selection_state"}
	if not has_selection:
		return _with_source_owner(source_exprs, {"visible": false})
	var dx := source_x - float(block_size_value) * source_tilesize / 2.0
	var dy := source_y + float(block_size_value) * source_tilesize / 2.0
	var selection_width := icon_small / SourceBuildingDefaults.DRAW_ITEM_SELECTION_ICON_DIVISOR * selection_icon_ratio
	var selection_height := icon_small / SourceBuildingDefaults.DRAW_ITEM_SELECTION_ICON_DIVISOR
	return _with_source_owner(source_exprs, {"visible": true, "dx": dx, "dy": dy, "shadow_color": SourceBuildingDefaults.DRAW_ITEM_SELECTION_SHADOW_COLOR, "shadow_alpha": SourceBuildingDefaults.DRAW_ITEM_SELECTION_SHADOW_ALPHA, "shadow_y": dy - SourceBuildingDefaults.DRAW_ITEM_SELECTION_SHADOW_Y_OFFSET, "foreground_y": dy + SourceBuildingDefaults.DRAW_ITEM_SELECTION_FOREGROUND_Y_OFFSET, "selection_width": selection_width, "selection_height": selection_height})

static func draw_disabled_state(source_x: float, source_y: float) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_disabled_state"}
	var disabled_icon_size := SourceBuildingDefaults.DRAW_DISABLED_ICON_SIZE
	return _with_source_owner(source_exprs, {"visible": true, "icon": SourceBuildingDefaults.DRAW_DISABLED_ICON, "color": SourceBuildingDefaults.DRAW_DISABLED_COLOR, "alpha": SourceBuildingDefaults.DRAW_DISABLED_ALPHA, "x": source_x, "y": source_y, "width": disabled_icon_size, "height": disabled_icon_size})

static func drawrot_state(block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> float:
	return float(rotation_quadrants * SOURCE_BUILDING_DRAW_ROTATION_STEP_DEGREES) if block_rotate and block_rotate_draw else SOURCE_BUILDING_DRAW_ROTATION_DISABLED

static func draw_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int, random_seed_int: Callable) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_state"}
	var draw_rotation := drawrot_state(block_rotate, block_rotate_draw, rotation_quadrants)
	if variants == 0 or not has_variant_regions:
		return _with_source_owner(source_exprs, {"visible": true, "region_kind": "region", "variant_index": -1, "x": source_x, "y": source_y, "rotation_degrees": draw_rotation, "draw_team_top": true})
	var max_variant_index: int = max(0, variant_region_count - 1)
	var variant_index: int = int(random_seed_int.call(tile_pos, 0, max_variant_index))
	return _with_source_owner(source_exprs, {"visible": true, "region_kind": "variant_region", "variant_index": variant_index, "x": source_x, "y": source_y, "rotation_degrees": draw_rotation, "draw_team_top": true})

static func draw_cached_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int, random_seed_int: Callable) -> Dictionary:
	var result := draw_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants, random_seed_int)
	result.merge({"source_owner": "PortGame.source_building_draw_cached_state"}, true)
	return result

static func recache_state(headless: bool, building_cache_layer: Variant, tile_state: Variant) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_recache_state"}
	if headless:
		return _with_source_owner(source_exprs, {
			"method": "public void recache(){",
			"headless_gate": "if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);",
			"recache_call": "",
			"recache": false,
			"building_cache_layer": building_cache_layer,
			"tile": tile_state,
		})
	return _with_source_owner(source_exprs, {
		"method": "public void recache(){",
		"headless_gate": "if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);",
		"recache_call": "renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);",
		"recache": true,
		"building_cache_layer": building_cache_layer,
		"tile": tile_state,
	})

static func payload_draw_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int, random_seed_int: Callable) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_payload_draw_state"}
	var cached_draw := {}
	var dynamic_draw := {}
	if draw_cached:
		cached_draw = draw_cached_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants, random_seed_int)
	if draw_dynamic:
		dynamic_draw = draw_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants, random_seed_int)
	return _with_source_owner(source_exprs, {"method": "public void payloadDraw(){", "saved_z_call": "float z = Draw.z();", "cached_gate": "if(block.drawCached){" if draw_cached else "", "cached_z_call": "Draw.z(block.buildingCacheLayer.layer);" if draw_cached else "", "cached_draw_call": "drawCached();" if draw_cached else "", "dynamic_gate": "if(block.drawDynamic){" if draw_dynamic else "", "restore_z_call": "Draw.z(z);" if draw_dynamic else "", "dynamic_draw_call": "draw();" if draw_dynamic else "", "saved_z": current_z, "cached_visible": draw_cached, "cached_z": building_cache_layer_z, "cached_draw": cached_draw, "dynamic_visible": draw_dynamic, "dynamic_z": current_z, "dynamic_draw": dynamic_draw})

static func draw_team_top_state(team_region_found: bool, team_region_matches_team: bool, team_color: String, source_x: float, source_y: float) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_team_top_state"}
	if not team_region_found:
		return _with_source_owner(source_exprs, {"visible": false})
	return _with_source_owner(source_exprs, {"visible": true, "tint_color": team_color if team_region_matches_team else "", "x": source_x, "y": source_y, "color_reset": true})

static func draw_liquid_light_state(source_x: float, source_y: float, block_size_value: int, light_color: String, light_alpha: float, amount: float) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_liquid_light_state"}
	if amount <= SOURCE_BUILDING_DRAW_LIQUID_LIGHT_AMOUNT_MIN:
		return _with_source_owner(source_exprs, {"visible": false})
	var fract: float = SOURCE_BUILDING_DRAW_LIQUID_LIGHT_FRACT
	var opacity := light_alpha * fract
	if opacity <= SOURCE_BUILDING_DRAW_LIQUID_LIGHT_OPACITY_MIN:
		return _with_source_owner(source_exprs, {"visible": false})
	return _with_source_owner(source_exprs, {"visible": true, "x": source_x, "y": source_y, "radius": block_size_value * SOURCE_BUILDING_DRAW_LIQUID_LIGHT_RADIUS_SCALE * fract, "color": light_color, "opacity": opacity, "alpha": opacity * amount, "fract": fract})

static func draw_light_state(has_liquids: bool, draw_liquid_light: bool, light_liquid_is_null: bool, current_liquid_color: String, current_liquid_alpha: float, light_liquid_color: String, light_liquid_alpha: float, selected_liquid_amount: float, visual_liquid: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, lerp_delta: Callable) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_light_state"}
	var selected_color := current_liquid_color if light_liquid_is_null else light_liquid_color
	var selected_alpha := current_liquid_alpha if light_liquid_is_null else light_liquid_alpha
	if not has_liquids or not draw_liquid_light or selected_alpha <= SOURCE_BUILDING_DRAW_LIQUID_LIGHT_OPACITY_MIN:
		return _with_source_owner(source_exprs, {"visible": false, "visual_liquid": visual_liquid})
	var target := SOURCE_BUILDING_DRAW_LIGHT_TARGET_FULL if selected_liquid_amount >= SOURCE_BUILDING_DRAW_LIQUID_LIGHT_AMOUNT_MIN else SOURCE_BUILDING_DRAW_LIGHT_TARGET_EMPTY
	var next_visual_liquid := float(lerp_delta.call(visual_liquid, target, SOURCE_BUILDING_DRAW_LIGHT_LERP_PROGRESS, source_delta))
	var light_state := draw_liquid_light_state(source_x, source_y, block_size_value, selected_color, selected_alpha, next_visual_liquid)
	light_state["source_owner"] = "PortGame.source_building_draw_light_state"
	light_state["visual_liquid"] = next_visual_liquid
	light_state["drawLiquidLightCall"] = "drawLiquidLight(liq, visualLiquid);"
	return light_state

static func draw_team_state(team_color: String, source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_team_state"}
	return _with_source_owner(source_exprs, {"visible": true, "region": SOURCE_BUILDING_DRAW_TEAM_BORDER_REGION, "color": team_color, "x": source_x - block_size_value * source_tilesize / 2.0 + SOURCE_BUILDING_DRAW_TEAM_BORDER_OFFSET, "y": source_y - block_size_value * source_tilesize / 2.0 + SOURCE_BUILDING_DRAW_TEAM_BORDER_OFFSET, "color_reset": true})

static func block_half_extent(block_size_value: int, source_tilesize: float) -> float:
	return float(block_size_value) * source_tilesize / 2.0

static func draw_configure_state(source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_draw_configure_state"}
	var half_extent := block_half_extent(block_size_value, source_tilesize)
	return _with_source_owner(source_exprs, {
		"method": "public void drawConfigure(){",
		"color": SourceBuildingDefaults.DRAW_CONFIGURE_COLOR,
		"stroke": SourceBuildingDefaults.DRAW_CONFIGURE_STROKE_DEFAULT,
		"shape": SourceBuildingDefaults.DRAW_CONFIGURE_SHAPE,
		"square": SourceBuildingDefaults.DRAW_CONFIGURE_SQUARE_EXPR,
		"x": source_x,
		"y": source_y,
		"halfExtent": half_extent,
		"radiusOffset": SourceBuildingDefaults.DRAW_CONFIGURE_RADIUS_OFFSET_DEFAULT,
		"radius": half_extent + SourceBuildingDefaults.DRAW_CONFIGURE_RADIUS_OFFSET_DEFAULT,
		"reset": true,
		"source_x": source_x,
		"source_y": source_y,
		"block_size_value": block_size_value,
		"source_tilesize": source_tilesize,
	})
