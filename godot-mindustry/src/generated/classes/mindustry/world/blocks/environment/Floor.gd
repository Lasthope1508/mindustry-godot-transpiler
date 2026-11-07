# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/environment/Floor.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.environment"
const JAVA_KIND := "class"
const JAVA_NAME := "Floor"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "edge", "type": "String"}, {"modifiers": ["public"], "name": "speedMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "dragMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "damageTaken", "type": "float"}, {"modifiers": ["public"], "name": "drownTime", "type": "float"}, {"modifiers": ["public"], "name": "walkEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "walkSound", "type": "Sound"}, {"modifiers": ["public"], "name": "walkSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "walkSoundPitchMin", "type": "float"}, {"modifiers": ["public"], "name": "walkSoundPitchMax", "type": "float"}, {"modifiers": ["public"], "name": "drownUpdateEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "status", "type": "StatusEffect"}, {"modifiers": ["public"], "name": "statusDuration", "type": "float"}, {"modifiers": ["public"], "name": "liquidDrop", "type": "Liquid"}, {"modifiers": ["public"], "name": "liquidMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "isLiquid", "type": "boolean"}, {"modifiers": ["public"], "name": "overlayAlpha", "type": "float"}, {"modifiers": ["public"], "name": "supportsOverlay", "type": "boolean"}, {"modifiers": ["public"], "name": "shallow", "type": "boolean"}, {"modifiers": ["public"], "name": "blendGroup", "type": "Block"}, {"modifiers": ["public"], "name": "oreDefault", "type": "boolean"}, {"modifiers": ["public"], "name": "oreScale", "type": "float"}, {"modifiers": ["public"], "name": "oreThreshold", "type": "float"}, {"modifiers": ["public"], "name": "wall", "type": "Block"}, {"modifiers": ["public"], "name": "decoration", "type": "Block"}, {"modifiers": ["public"], "name": "canShadow", "type": "boolean"}, {"modifiers": ["public"], "name": "forceDrawLight", "type": "boolean"}, {"modifiers": ["public"], "name": "needsSurface", "type": "boolean"}, {"modifiers": ["public"], "name": "allowCorePlacement", "type": "boolean"}, {"modifiers": ["public"], "name": "wallOre", "type": "boolean"}, {"modifiers": ["public"], "name": "blendId", "type": "int"}, {"modifiers": ["public"], "name": "tilingVariants", "type": "int"}, {"modifiers": ["public"], "name": "autotile", "type": "boolean"}, {"modifiers": ["public"], "name": "autotileMidVariants", "type": "int"}, {"modifiers": ["public"], "name": "autotileVariants", "type": "int"}, {"modifiers": ["public"], "name": "drawEdgeIn", "type": "boolean"}, {"modifiers": ["public"], "name": "drawEdgeOut", "type": "boolean"}, {"modifiers": ["protected"], "name": "tilingRegions", "type": "TextureRegion"}, {"modifiers": ["protected"], "name": "autotileRegions", "type": "TextureRegion"}, {"modifiers": ["protected"], "name": "autotileMidRegions", "type": "TextureRegion"}, {"modifiers": ["protected"], "name": "autotileVariantRegions", "type": "TextureRegion"}, {"modifiers": ["protected"], "name": "tilingSize", "type": "int"}, {"modifiers": ["protected"], "name": "edges", "type": "TextureRegion"}, {"modifiers": ["protected"], "name": "blenders", "type": "Seq"}, {"modifiers": ["protected"], "name": "blended", "type": "Bits"}, {"modifiers": ["protected"], "name": "dirs", "type": "int"}, {"modifiers": ["protected"], "name": "edgeRegion", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Floor", "parameters": [{"name": "name", "type": "String", "varargs": false}]}, {"modifiers": ["public"], "name": "Floor", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "variants", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getDisplayIcon", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "getDisplayName", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "String"}, {"modifiers": ["public"], "name": "createIcons", "parameters": [{"name": "packer", "type": "MultiPacker", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBase", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawMain", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkAutotileSame", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "variant", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "variant", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "max", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "drawOverlay", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "floorChanged", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "shouldIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "updateRender", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "renderUpdate", "parameters": [{"name": "tile", "type": "UpdateRenderState", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hasSurface", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isDeep", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drawNonLayer", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "layer", "type": "CacheLayer", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawEdges", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawBlended", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "checkId", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "realBlendId", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "int"}, {"modifiers": ["protected"], "name": "edges", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["protected"], "name": "edge", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rx", "type": "int", "varargs": false}, {"name": "ry", "type": "int", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["protected"], "name": "doEdge", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "otherTile", "type": "Tile", "varargs": false}, {"name": "other", "type": "Floor", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "damages", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
const source_floor_state := preload("res://src/game/SourceFloorState.gd")

func java_method_load_0(_args: Array = []) -> Variant:
	return null

func java_method_init_1(_args: Array = []) -> Variant:
	return null

func java_method_getDisplayIcon_2(_args: Array = []) -> Variant:
	var liquid_drop_present := bool(_args[0] if _args.size() > 0 else false)
	var super_display_icon: Variant = _args[1] if _args.size() > 1 else null
	var liquid_drop_icon: Variant = _args[2] if _args.size() > 2 else null
	return source_floor_state.get_display_icon_state(liquid_drop_present, super_display_icon, liquid_drop_icon)

func java_method_getDisplayName_3(_args: Array = []) -> Variant:
	var liquid_drop_present := bool(_args[0] if _args.size() > 0 else false)
	var super_display_name := str(_args[1] if _args.size() > 1 else "")
	var liquid_drop_name := str(_args[2] if _args.size() > 2 else "")
	return source_floor_state.get_display_name_state(liquid_drop_present, super_display_name, liquid_drop_name)

func java_method_createIcons_4(_args: Array = []) -> Variant:
	return null

func java_method_drawBase_5(_args: Array = []) -> Variant:
	var draw_edge_in := bool(_args[0] if _args.size() > 0 else true)
	var tile_overlay_is_air := bool(_args[1] if _args.size() > 1 else true)
	var tile_floor_is_this := bool(_args[2] if _args.size() > 2 else true)
	var is_liquid := bool(_args[3] if _args.size() > 3 else false)
	var overlay_alpha := float(_args[4] if _args.size() > 4 else 0.65)
	var draw_edges_result: Dictionary = _args[5] if _args.size() > 5 and _args[5] is Dictionary else {}
	return source_floor_state.draw_base_state(draw_edge_in, tile_overlay_is_air, tile_floor_is_this, is_liquid, overlay_alpha, draw_edges_result)

func java_method_drawMain_6(_args: Array = []) -> Variant:
	var tile_x := int(_args[0] if _args.size() > 0 else 0)
	var tile_y := int(_args[1] if _args.size() > 1 else 0)
	var tiling_variants := int(_args[2] if _args.size() > 2 else 0)
	var tiling_size := int(_args[3] if _args.size() > 3 else 1)
	var tiling_regions: Array = _args[4] if _args.size() > 4 and _args[4] is Array else []
	var autotile := bool(_args[5] if _args.size() > 5 else false)
	var autotile_variants := int(_args[6] if _args.size() > 6 else 1)
	var autotile_variant_regions: Array = _args[7] if _args.size() > 7 and _args[7] is Array else []
	var autotile_regions: Array = _args[8] if _args.size() > 8 and _args[8] is Array else []
	var autotile_mid_variants := int(_args[9] if _args.size() > 9 else 1)
	var autotile_mid_regions: Array = _args[10] if _args.size() > 10 and _args[10] is Array else []
	var autotile_same: Array = _args[11] if _args.size() > 11 and _args[11] is Array else []
	var tile_bitmask_values: Array = _args[12] if _args.size() > 12 and _args[12] is Array else []
	var variant_regions: Array = _args[13] if _args.size() > 13 and _args[13] is Array else []
	return source_floor_state.draw_main_state(tile_x, tile_y, tiling_variants, tiling_size, tiling_regions, autotile, autotile_variants, autotile_variant_regions, autotile_regions, autotile_mid_variants, autotile_mid_regions, autotile_same, tile_bitmask_values, variant_regions)

func java_method_checkAutotileSame_7(_args: Array = []) -> Variant:
	var other_present := bool(_args[0] if _args.size() > 0 else false)
	var tile_floor_is_this := bool(_args[1] if _args.size() > 1 else true)
	var other_floor_matches := bool(_args[2] if _args.size() > 2 else false)
	var other_overlay_matches := bool(_args[3] if _args.size() > 3 else false)
	return source_floor_state.check_autotile_same_state(other_present, tile_floor_is_this, other_floor_matches, other_overlay_matches)

func java_method_variant_8(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var packed_position := int(_args[2] if _args.size() > 2 else 0)
	var variant_region_count := int(_args[3] if _args.size() > 3 else 0)
	return source_floor_state.variant_state(x, y, -1, packed_position, variant_region_count)

func java_method_variant_9(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var max_value := int(_args[2] if _args.size() > 2 else 0)
	var packed_position := int(_args[3] if _args.size() > 3 else 0)
	return source_floor_state.variant_state(x, y, max_value, packed_position)

func java_method_drawOverlay_10(_args: Array = []) -> Variant:
	var overlay_is_air := bool(_args[0] if _args.size() > 0 else true)
	var overlay_is_this := bool(_args[1] if _args.size() > 1 else false)
	var overlay_draw_base_result: Dictionary = _args[2] if _args.size() > 2 and _args[2] is Dictionary else {}
	return source_floor_state.draw_overlay_state(overlay_is_air, overlay_is_this, overlay_draw_base_result)

func java_method_icons_11(_args: Array = []) -> Variant:
	var name_value := str(_args[0] if _args.size() > 0 else "")
	var atlas_has_name := bool(_args[1] if _args.size() > 1 else false)
	var icon_region: Variant = _args[2] if _args.size() > 2 else null
	return source_floor_state.icons_state(name_value, atlas_has_name, icon_region)

func java_method_floorChanged_12(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_floor_state.floor_changed_state(tile)

func java_method_shouldIndex_13(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_floor_state.should_index_state(tile)

func java_method_updateRender_14(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_floor_state.update_render_state(tile)

func java_method_renderUpdate_15(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_floor_state.render_update_state(tile)

func java_method_hasSurface_16(_args: Array = []) -> Variant:
	var is_liquid := bool(_args[0] if _args.size() > 0 else false)
	var solid := bool(_args[1] if _args.size() > 1 else false)
	return source_floor_state.has_surface_state(is_liquid, solid)

func java_method_isDeep_17(_args: Array = []) -> Variant:
	var drown_time := float(_args[0] if _args.size() > 0 else 0.0)
	return source_floor_state.is_deep_state(drown_time)

func java_method_drawNonLayer_18(_args: Array = []) -> Variant:
	var neighbors: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var layer: Variant = _args[1] if _args.size() > 1 else null
	var tile_x := int(_args[2] if _args.size() > 2 else 0)
	var tile_y := int(_args[3] if _args.size() > 3 else 0)
	return source_floor_state.draw_non_layer_state(neighbors, layer, tile_x, tile_y)

func java_method_drawEdges_19(_args: Array = []) -> Variant:
	var neighbors: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var real_cache_layer: Variant = _args[1] if _args.size() > 1 else null
	var tile_floor_is_this := bool(_args[2] if _args.size() > 2 else true)
	var tile_x := int(_args[3] if _args.size() > 3 else 0)
	var tile_y := int(_args[4] if _args.size() > 4 else 0)
	var self_real_blend_id := int(_args[5] if _args.size() > 5 else 0)
	var self_edges_present := bool(_args[6] if _args.size() > 6 else false)
	return source_floor_state.draw_edges_state(neighbors, real_cache_layer, tile_floor_is_this, tile_x, tile_y, self_real_blend_id, self_edges_present)

func java_method_drawBlended_20(_args: Array = []) -> Variant:
	var blenders: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var neighbors: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	var dirs: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []
	var tile_floor_is_this := bool(_args[3] if _args.size() > 3 else true)
	var check_id := bool(_args[4] if _args.size() > 4 else false)
	return source_floor_state.draw_blended_state(blenders, neighbors, dirs, tile_floor_is_this, check_id)

func java_method_realBlendId_21(_args: Array = []) -> Variant:
	var tile_floor_is_liquid := bool(_args[0] if _args.size() > 0 else false)
	var tile_overlay_is_air := bool(_args[1] if _args.size() > 1 else true)
	var tile_overlay_is_ore := bool(_args[2] if _args.size() > 2 else false)
	var tile_overlay_blend_id := int(_args[3] if _args.size() > 3 else 0)
	var tile_floor_blend_id := int(_args[4] if _args.size() > 4 else 0)
	var blend_id := int(_args[5] if _args.size() > 5 else -1)
	return source_floor_state.real_blend_id_state(tile_floor_is_liquid, tile_overlay_is_air, tile_overlay_is_ore, tile_overlay_blend_id, tile_floor_blend_id, blend_id)

func java_method_edges_22(_args: Array = []) -> Variant:
	var blend_group_edges: Variant = _args[0] if _args.size() > 0 else null
	return source_floor_state.edges_state(blend_group_edges)

func java_method_edge_23(_args: Array = []) -> Variant:
	var edges_grid: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var x := int(_args[1] if _args.size() > 1 else 0)
	var y := int(_args[2] if _args.size() > 2 else 0)
	var rx := int(_args[3] if _args.size() > 3 else 0)
	var ry := int(_args[4] if _args.size() > 4 else 0)
	return source_floor_state.edge_state(edges_grid, x, y, rx, ry)

func java_method_doEdge_24(_args: Array = []) -> Variant:
	var other_real_blend_id := int(_args[0] if _args.size() > 0 else 0)
	var self_real_blend_id := int(_args[1] if _args.size() > 1 else 0)
	var edges_present := bool(_args[2] if _args.size() > 2 else false)
	return source_floor_state.do_edge_state(other_real_blend_id, self_real_blend_id, edges_present)

func java_method_damages_25(_args: Array = []) -> Variant:
	var damage_taken := float(_args[0] if _args.size() > 0 else 0.0)
	var status_damage := float(_args[1] if _args.size() > 1 else 0.0)
	var status_present := bool(_args[2] if _args.size() > 2 else false)
	return source_floor_state.damages_state(damage_taken, status_damage, status_present)
