# Generated from Mindustry upstream.
# Source: mindustry/world/Tile.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world"
const JAVA_KIND := "class"
const JAVA_NAME := "Tile"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Position", "QuadTreeObject", "Displayable"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "tileChange", "type": "TileChangeEvent"}, {"modifiers": ["final", "private", "static"], "name": "preChange", "type": "TilePreChangeEvent"}, {"modifiers": ["final", "private", "static"], "name": "floorChange", "type": "TileFloorChangeEvent"}, {"modifiers": ["final", "private", "static"], "name": "overlayChange", "type": "TileOverlayChangeEvent"}, {"modifiers": ["final", "private", "static"], "name": "tileSet", "type": "ObjectSet"}, {"modifiers": ["final", "private", "static"], "name": "staleGraphs", "type": "IntSet"}, {"modifiers": ["public"], "name": "data", "type": "byte"}, {"modifiers": ["public"], "name": "floorData", "type": "byte"}, {"modifiers": ["public"], "name": "overlayData", "type": "byte"}, {"modifiers": ["public"], "name": "extraData", "type": "int"}, {"modifiers": ["public"], "name": "build", "type": "Building"}, {"modifiers": ["public"], "name": "x", "type": "short"}, {"modifiers": ["public"], "name": "y", "type": "short"}, {"modifiers": ["protected"], "name": "block", "type": "Block"}, {"modifiers": ["protected"], "name": "floor", "type": "Floor"}, {"modifiers": ["protected"], "name": "overlay", "type": "Floor"}, {"modifiers": ["protected"], "name": "changing", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Tile", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}]}, {"modifiers": ["public"], "name": "Tile", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "floor", "type": "Block", "varargs": false}, {"name": "overlay", "type": "Block", "varargs": false}, {"name": "wall", "type": "Block", "varargs": false}]}, {"modifiers": ["public"], "name": "Tile", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "floor", "type": "int", "varargs": false}, {"name": "overlay", "type": "int", "varargs": false}, {"name": "wall", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "pos", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "array", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "relativeTo", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public"], "name": "relativeTo", "parameters": [{"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public", "static"], "name": "relativeTo", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public", "static"], "name": "relativeTo", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "cx", "type": "float", "varargs": false}, {"name": "cy", "type": "float", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "absoluteRelativeTo", "parameters": [{"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public"], "name": "getFlammability", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "inMapArea", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "worldx", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "worldy", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "drawx", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "drawy", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "isDarkened", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "floor", "parameters": [], "return_type": "Floor"}, {"modifiers": ["public"], "name": "block", "parameters": [], "return_type": "Block"}, {"modifiers": ["public"], "name": "overlay", "parameters": [], "return_type": "Floor"}, {"modifiers": ["public"], "name": "cblock", "parameters": [], "return_type": "T"}, {"modifiers": ["public"], "name": "team", "parameters": [], "return_type": "Team"}, {"modifiers": ["public"], "name": "setTeam", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isCenter", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "centerX", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "centerY", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "getTeamID", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "setBlock", "parameters": [{"name": "type", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBlock", "parameters": [{"name": "type", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "entityprov", "type": "Prov", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBlock", "parameters": [{"name": "type", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBlock", "parameters": [{"name": "type", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setFloor", "parameters": [{"name": "type", "type": "Floor", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isEditorTile", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setAir", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "circle", "parameters": [{"name": "radius", "type": "int", "varargs": false}, {"name": "cons", "type": "Intc2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "circle", "parameters": [{"name": "radius", "type": "int", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getFloorColor", "parameters": [], "return_type": "Color"}, {"modifiers": ["public"], "name": "recacheWall", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "recache", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "removeNet", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setNet", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setNet", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setFloorNet", "parameters": [{"name": "floor", "type": "Block", "varargs": false}, {"name": "overlay", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setFloorNet", "parameters": [{"name": "floor", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setOverlayNet", "parameters": [{"name": "overlay", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "overlayID", "parameters": [], "return_type": "short"}, {"modifiers": ["public"], "name": "blockID", "parameters": [], "return_type": "short"}, {"modifiers": ["public"], "name": "floorID", "parameters": [], "return_type": "short"}, {"modifiers": ["public"], "name": "setOverlay", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setOverlayQuiet", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "clearOverlay", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "passable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "synthetic", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "solid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "breakable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "dangerous", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getLinkedTiles", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getLinkedTiles", "parameters": [{"name": "tmpArray", "type": "Seq", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getLinkedTilesAs", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "tmpArray", "type": "Seq", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getLinkedTilesAs", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "tmpArray", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getHitbox", "parameters": [{"name": "rect", "type": "Rect", "varargs": false}], "return_type": "Rect"}, {"modifiers": ["public"], "name": "getBounds", "parameters": [{"name": "rect", "type": "Rect", "varargs": false}], "return_type": "Rect"}, {"modifiers": ["public"], "name": "hitbox", "parameters": [{"name": "rect", "type": "Rect", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "nearby", "parameters": [{"name": "relative", "type": "Point2", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "nearby", "parameters": [{"name": "dx", "type": "int", "varargs": false}, {"name": "dy", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "nearby", "parameters": [{"name": "rotation", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "nearbyBuild", "parameters": [{"name": "rotation", "type": "int", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "interactable", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drop", "parameters": [], "return_type": "Item"}, {"modifiers": ["public"], "name": "wallDrop", "parameters": [], "return_type": "Item"}, {"modifiers": ["public"], "name": "shouldSaveData", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "staticDarkness", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "legSolid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "adjacentTo", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "preChanged", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "changeBuild", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "entityprov", "type": "Prov", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "changed", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "fireChanged", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "firePreChanged", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getPackedData", "parameters": [], "return_type": "long"}, {"modifiers": ["public"], "name": "setPackedData", "parameters": [{"name": "packed", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getX", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getY", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "setTileBlocks", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "positions", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setTileFloors", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "positions", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setTileOverlays", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "positions", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setFloor", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "floor", "type": "Block", "varargs": false}, {"name": "overlay", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setOverlay", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "overlay", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "removeTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setTeam", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setTeams", "parameters": [{"name": "positions", "type": "int", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "buildDestroyed", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "buildHealthUpdate", "parameters": [{"name": "buildings", "type": "IntSeq", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const SOURCE_TILESIZE := source_world_defaults.TILESIZE

func java_method_pos_0(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	return source_block_geometry.tile_pos_state(x, y)

func java_method_array_1(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var world_width := int(_args[2] if _args.size() > 2 else 0)
	return source_block_geometry.tile_array_state(x, y, world_width)

func java_method_relativeTo_2(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var cx := int(_args[2] if _args.size() > 2 else 0)
	var cy := int(_args[3] if _args.size() > 3 else 0)
	return source_block_geometry.tile_relative_cardinal_state(x, y, cx, cy)

func java_method_relativeTo_3(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var cx := int(_args[2] if _args.size() > 2 else 0)
	var cy := int(_args[3] if _args.size() > 3 else 0)
	return source_block_geometry.tile_relative_cardinal_state(x, y, cx, cy)

func java_method_relativeTo_4(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var cx := int(_args[2] if _args.size() > 2 else 0)
	var cy := int(_args[3] if _args.size() > 3 else 0)
	return source_block_geometry.tile_relative_cardinal_state(x, y, cx, cy)

func java_method_relativeTo_5(_args: Array = []) -> Variant:
	var x := float(_args[0] if _args.size() > 0 else 0.0)
	var y := float(_args[1] if _args.size() > 1 else 0.0)
	var cx := float(_args[2] if _args.size() > 2 else 0.0)
	var cy := float(_args[3] if _args.size() > 3 else 0.0)
	return source_block_geometry.tile_relative_float_state(x, y, cx, cy)

func java_method_absoluteRelativeTo_6(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var cx := int(_args[2] if _args.size() > 2 else 0)
	var cy := int(_args[3] if _args.size() > 3 else 0)
	var block_size := int(_args[4] if _args.size() > 4 else 1)
	return source_block_geometry.tile_absolute_relative_state(x, y, cx, cy, block_size)

func java_method_getFlammability_7(_args: Array = []) -> Variant:
	var block_is_air := bool(_args[0] if _args.size() > 0 else true)
	var floor_liquid_drop_present := bool(_args[1] if _args.size() > 1 else false)
	var floor_liquid_flammability := float(_args[2] if _args.size() > 2 else 0.0)
	var build_present := bool(_args[3] if _args.size() > 3 else false)
	var block_has_items := bool(_args[4] if _args.size() > 4 else false)
	var build_items_total := float(_args[5] if _args.size() > 5 else 0.0)
	var item_flammability_sum := float(_args[6] if _args.size() > 6 else 0.0)
	var block_item_capacity := float(_args[7] if _args.size() > 7 else 0.0)
	var block_has_liquids := bool(_args[8] if _args.size() > 8 else false)
	var liquid_flammability_sum := float(_args[9] if _args.size() > 9 else 0.0)
	var block_liquid_capacity := float(_args[10] if _args.size() > 10 else 0.0)
	return source_block_geometry.tile_flammability_state(block_is_air, floor_liquid_drop_present, floor_liquid_flammability, build_present, block_has_items, build_items_total, item_flammability_sum, block_item_capacity, block_has_liquids, liquid_flammability_sum, block_liquid_capacity)

func java_method_inMapArea_8(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var limit_map_area := bool(_args[2] if _args.size() > 2 else false)
	var limit_x := int(_args[3] if _args.size() > 3 else 0)
	var limit_y := int(_args[4] if _args.size() > 4 else 0)
	var limit_width := int(_args[5] if _args.size() > 5 else 1)
	var limit_height := int(_args[6] if _args.size() > 6 else 1)
	return source_block_geometry.tile_in_map_area_state(x, y, limit_map_area, limit_x, limit_y, limit_width, limit_height)

func java_method_worldx_9(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var source_tilesize := float(_args[1] if _args.size() > 1 else SOURCE_TILESIZE)
	return source_block_geometry.tile_worldx_state(x, source_tilesize)

func java_method_worldy_10(_args: Array = []) -> Variant:
	var y := int(_args[0] if _args.size() > 0 else 0)
	var source_tilesize := float(_args[1] if _args.size() > 1 else SOURCE_TILESIZE)
	return source_block_geometry.tile_worldy_state(y, source_tilesize)

func java_method_drawx_11(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var source_tilesize := float(_args[1] if _args.size() > 1 else SOURCE_TILESIZE)
	var block_offset := float(_args[2] if _args.size() > 2 else 0.0)
	return source_block_geometry.tile_drawx_state(x, source_tilesize, block_offset)

func java_method_drawy_12(_args: Array = []) -> Variant:
	var y := int(_args[0] if _args.size() > 0 else 0)
	var source_tilesize := float(_args[1] if _args.size() > 1 else SOURCE_TILESIZE)
	var block_offset := float(_args[2] if _args.size() > 2 else 0.0)
	return source_block_geometry.tile_drawy_state(y, source_tilesize, block_offset)

func java_method_isDarkened_13(_args: Array = []) -> Variant:
	var block_is_darkened := bool(_args[0] if _args.size() > 0 else false)
	return source_block_geometry.tile_is_darkened_state(block_is_darkened)

func java_method_floor_14(_args: Array = []) -> Variant:
	var value: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_reference_state(value)

func java_method_block_15(_args: Array = []) -> Variant:
	var value: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_reference_state(value)

func java_method_overlay_16(_args: Array = []) -> Variant:
	var value: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_reference_state(value)

func java_method_cblock_17(_args: Array = []) -> Variant:
	var value: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_reference_state(value)

func java_method_team_18(_args: Array = []) -> Variant:
	var build_present := bool(_args[0] if _args.size() > 0 else false)
	var build_team: Variant = _args[1] if _args.size() > 1 else null
	var derelict_team: Variant = _args[2] if _args.size() > 2 else null
	return source_block_geometry.tile_team_state(build_present, build_team, derelict_team)

func java_method_setTeam_19(_args: Array = []) -> Variant:
	var build_present := bool(_args[0] if _args.size() > 0 else false)
	var team: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_set_team_state(build_present, team)

func java_method_isCenter_20(_args: Array = []) -> Variant:
	var build_present := bool(_args[0] if _args.size() > 0 else false)
	var build_tile_is_self := bool(_args[1] if _args.size() > 1 else false)
	return source_block_geometry.tile_is_center_state(build_present, build_tile_is_self)

func java_method_centerX_21(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var build_present := bool(_args[1] if _args.size() > 1 else false)
	var build_tile_x := int(_args[2] if _args.size() > 2 else x)
	return source_block_geometry.tile_center_x_state(x, build_present, build_tile_x)

func java_method_centerY_22(_args: Array = []) -> Variant:
	var y := int(_args[0] if _args.size() > 0 else 0)
	var build_present := bool(_args[1] if _args.size() > 1 else false)
	var build_tile_y := int(_args[2] if _args.size() > 2 else y)
	return source_block_geometry.tile_center_y_state(y, build_present, build_tile_y)

func java_method_getTeamID_23(_args: Array = []) -> Variant:
	var build_present := bool(_args[0] if _args.size() > 0 else false)
	var build_team_id := int(_args[1] if _args.size() > 1 else 0)
	var derelict_team_id := int(_args[2] if _args.size() > 2 else 0)
	return source_block_geometry.tile_team_id_state(build_present, build_team_id, derelict_team_id)

func java_method_setBlock_24(_args: Array = []) -> Variant:
	var type_value: Variant = _args[0] if _args.size() > 0 else null
	var team_value: Variant = _args[1] if _args.size() > 1 else null
	var rotation_value := int(_args[2] if _args.size() > 2 else 0)
	return source_block_geometry.tile_set_block_delegate_state("type_team_rotation", type_value, team_value, rotation_value)

func java_method_setBlock_25(_args: Array = []) -> Variant:
	var world_generating := bool(_args[0] if _args.size() > 0 else false)
	var type_value: Variant = _args[1] if _args.size() > 1 else null
	var team_value: Variant = _args[2] if _args.size() > 2 else null
	var rotation_value := int(_args[3] if _args.size() > 3 else 0)
	var entityprov_value: Variant = _args[4] if _args.size() > 4 else null
	var type_static := bool(_args[5] if _args.size() > 5 else false)
	var previous_block_static := bool(_args[6] if _args.size() > 6 else false)
	var force_team_present := _args.size() > 7 and _args[7] != null
	var force_team_value: Variant = _args[7] if force_team_present else null
	var build_present := bool(_args[8] if _args.size() > 8 else false)
	var previous_build_multiblock := bool(_args[9] if _args.size() > 9 else false)
	var previous_multiblock_tiles: Array = _args[10] if _args.size() > 10 and _args[10] is Array else []
	var self_tile: Variant = _args[11] if _args.size() > 11 else null
	var new_build_present := bool(_args[12] if _args.size() > 12 else false)
	var block_update := bool(_args[13] if _args.size() > 13 else false)
	var editor_state := bool(_args[14] if _args.size() > 14 else false)
	var entity_init_result: Variant = _args[15] if _args.size() > 15 else null
	var new_block_multiblock := bool(_args[16] if _args.size() > 16 else false)
	var new_block_size := int(_args[17] if _args.size() > 17 else 1)
	var new_multiblock_tiles: Array = _args[18] if _args.size() > 18 and _args[18] is Array else []
	var block_changed_call: Variant = _args[19] if _args.size() > 19 else null
	return source_block_geometry.tile_set_block_state(world_generating, type_value, team_value, rotation_value, entityprov_value, type_static, previous_block_static, force_team_present, force_team_value, build_present, previous_build_multiblock, previous_multiblock_tiles, self_tile, new_build_present, block_update, editor_state, entity_init_result, new_block_multiblock, new_block_size, new_multiblock_tiles, block_changed_call)

func java_method_setBlock_26(_args: Array = []) -> Variant:
	var type_value: Variant = _args[0] if _args.size() > 0 else null
	var team_value: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_set_block_delegate_state("type_team", type_value, team_value, 0)

func java_method_setBlock_27(_args: Array = []) -> Variant:
	var type_value: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_set_block_delegate_state("type", type_value, "Team.derelict", 0)

func java_method_setFloor_28(_args: Array = []) -> Variant:
	var type_value: Variant = _args[0] if _args.size() > 0 else null
	var previous_floor: Variant = _args[1] if _args.size() > 1 else null
	var headless := bool(_args[2] if _args.size() > 2 else false)
	var world_generating := bool(_args[3] if _args.size() > 3 else false)
	var editor_tile := bool(_args[4] if _args.size() > 4 else false)
	var build_present := bool(_args[5] if _args.size() > 5 else false)
	var pathfinder_present := bool(_args[6] if _args.size() > 6 else false)
	var state_editor := bool(_args[7] if _args.size() > 7 else false)
	var tile_value: Variant = _args[8] if _args.size() > 8 else null
	var floor_change_event: Variant = _args[9] if _args.size() > 9 else null
	var floor_changed_call: Variant = _args[10] if _args.size() > 10 else null
	return source_block_geometry.tile_set_floor_state(type_value, previous_floor, headless, world_generating, editor_tile, build_present, pathfinder_present, state_editor, tile_value, floor_change_event, floor_changed_call)

func java_method_isEditorTile_29(_args: Array = []) -> Variant:
	return source_block_geometry.tile_editor_state()

func java_method_setAir_30(_args: Array = []) -> Variant:
	var air_block: Variant = _args[0] if _args.size() > 0 else "Blocks.air"
	return source_block_geometry.tile_set_air_state(air_block)

func java_method_circle_31(_args: Array = []) -> Variant:
	var radius := int(_args[0] if _args.size() > 0 else 0)
	var x := int(_args[1] if _args.size() > 1 else 0)
	var y := int(_args[2] if _args.size() > 2 else 0)
	var width := int(_args[3] if _args.size() > 3 else 0)
	var height := int(_args[4] if _args.size() > 4 else 0)
	var consumer: Variant = _args[5] if _args.size() > 5 else null
	return source_block_geometry.tile_circle_state("int", x, y, radius, width, height, null, consumer)

func java_method_circle_32(_args: Array = []) -> Variant:
	var radius := int(_args[0] if _args.size() > 0 else 0)
	var x := int(_args[1] if _args.size() > 1 else 0)
	var y := int(_args[2] if _args.size() > 2 else 0)
	var width := int(_args[3] if _args.size() > 3 else 0)
	var height := int(_args[4] if _args.size() > 4 else 0)
	var world_tile_lookup: Variant = _args[5] if _args.size() > 5 else null
	var consumer: Variant = _args[6] if _args.size() > 6 else null
	return source_block_geometry.tile_circle_state("tile", x, y, radius, width, height, world_tile_lookup, consumer)

func java_method_getFloorColor_33(_args: Array = []) -> Variant:
	var floor_color: Variant = _args[0] if _args.size() > 0 else null
	var tile_value: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_floor_color_state(floor_color, tile_value)

func java_method_recacheWall_34(_args: Array = []) -> Variant:
	var headless := bool(_args[0] if _args.size() > 0 else false)
	var world_generating := bool(_args[1] if _args.size() > 1 else false)
	var tile_value: Variant = _args[2] if _args.size() > 2 else null
	return source_block_geometry.tile_recache_wall_state(headless, world_generating, tile_value)

func java_method_recache_35(_args: Array = []) -> Variant:
	var headless := bool(_args[0] if _args.size() > 0 else false)
	var world_generating := bool(_args[1] if _args.size() > 1 else false)
	var tile_value: Variant = _args[2] if _args.size() > 2 else null
	var neighbor_tiles: Array = _args[3] if _args.size() > 3 and _args[3] is Array else []
	return source_block_geometry.tile_recache_state(headless, world_generating, tile_value, neighbor_tiles)

func java_method_remove_36(_args: Array = []) -> Variant:
	var air_block: Variant = _args[0] if _args.size() > 0 else "Blocks.air"
	return source_block_geometry.tile_remove_state(air_block)

func java_method_removeNet_37(_args: Array = []) -> Variant:
	var tile_value: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_network_mutation_state("remove_net", tile_value)

func java_method_setNet_38(_args: Array = []) -> Variant:
	var tile_value: Variant = _args[0] if _args.size() > 0 else null
	var block_value: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_network_mutation_state("set_net_default", tile_value, block_value, "Team.derelict", 0)

func java_method_setNet_39(_args: Array = []) -> Variant:
	var tile_value: Variant = _args[0] if _args.size() > 0 else null
	var block_value: Variant = _args[1] if _args.size() > 1 else null
	var team_value: Variant = _args[2] if _args.size() > 2 else null
	var rotation_value := int(_args[3] if _args.size() > 3 else 0)
	return source_block_geometry.tile_network_mutation_state("set_net", tile_value, block_value, team_value, rotation_value)

func java_method_setFloorNet_40(_args: Array = []) -> Variant:
	var tile_value: Variant = _args[0] if _args.size() > 0 else null
	var floor_value: Variant = _args[1] if _args.size() > 1 else null
	var overlay_value: Variant = _args[2] if _args.size() > 2 else null
	return source_block_geometry.tile_network_mutation_state("set_floor_net", tile_value, null, null, 0, floor_value, overlay_value)

func java_method_setFloorNet_41(_args: Array = []) -> Variant:
	var tile_value: Variant = _args[0] if _args.size() > 0 else null
	var floor_value: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_network_mutation_state("set_floor_net_default", tile_value, null, null, 0, floor_value, "Blocks.air")

func java_method_setOverlayNet_42(_args: Array = []) -> Variant:
	var tile_value: Variant = _args[0] if _args.size() > 0 else null
	var overlay_value: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_network_mutation_state("set_overlay_net", tile_value, null, null, 0, null, overlay_value)

func java_method_overlayID_43(_args: Array = []) -> Variant:
	var overlay: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_id_state("overlay", overlay)

func java_method_blockID_44(_args: Array = []) -> Variant:
	var block: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_id_state("block", block)

func java_method_floorID_45(_args: Array = []) -> Variant:
	var floor: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_id_state("floor", floor)

func java_method_setOverlay_46(_args: Array = []) -> Variant:
	var block_value: Variant = _args[0] if _args.size() > 0 else null
	var previous_overlay: Variant = _args[1] if _args.size() > 1 else null
	var world_generating := bool(_args[2] if _args.size() > 2 else false)
	var build_present := bool(_args[3] if _args.size() > 3 else false)
	var overlay_change_event: Variant = _args[4] if _args.size() > 4 else null
	return source_block_geometry.tile_overlay_mutation_state("set_overlay", block_value, previous_overlay, false, world_generating, build_present, overlay_change_event)

func java_method_setOverlayQuiet_47(_args: Array = []) -> Variant:
	var block_value: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_overlay_mutation_state("set_overlay_quiet", block_value)

func java_method_clearOverlay_48(_args: Array = []) -> Variant:
	var air_block: Variant = _args[0] if _args.size() > 0 else "Blocks.air"
	return source_block_geometry.tile_overlay_mutation_state("clear_overlay", null, null, false, false, false, null, air_block)

func java_method_passable_49(_args: Array = []) -> Variant:
	var floor_solid := bool(_args[0] if _args.size() > 0 else false)
	var block_is_air := bool(_args[1] if _args.size() > 1 else true)
	var block_solidifies := bool(_args[2] if _args.size() > 2 else false)
	var block_solid := bool(_args[3] if _args.size() > 3 else false)
	var block_destructible := bool(_args[4] if _args.size() > 4 else false)
	var block_update := bool(_args[5] if _args.size() > 5 else false)
	return source_block_geometry.tile_passable_state(floor_solid, block_is_air, block_solidifies, block_solid, block_destructible, block_update)

func java_method_synthetic_50(_args: Array = []) -> Variant:
	var block_update := bool(_args[0] if _args.size() > 0 else false)
	var block_destructible := bool(_args[1] if _args.size() > 1 else false)
	return source_block_geometry.tile_synthetic_state(block_update, block_destructible)

func java_method_solid_51(_args: Array = []) -> Variant:
	var block_solid := bool(_args[0] if _args.size() > 0 else false)
	var floor_solid := bool(_args[1] if _args.size() > 1 else false)
	var build_present := bool(_args[2] if _args.size() > 2 else false)
	var build_check_solid := bool(_args[3] if _args.size() > 3 else false)
	return source_block_geometry.tile_solid_state(block_solid, floor_solid, build_present, build_check_solid)

func java_method_breakable_52(_args: Array = []) -> Variant:
	var block_destructible := bool(_args[0] if _args.size() > 0 else false)
	var block_breakable := bool(_args[1] if _args.size() > 1 else false)
	var block_update := bool(_args[2] if _args.size() > 2 else false)
	return source_block_geometry.tile_breakable_state(block_destructible, block_breakable, block_update)

func java_method_dangerous_53(_args: Array = []) -> Variant:
	var block_solid := bool(_args[0] if _args.size() > 0 else false)
	var floor_is_deep := bool(_args[1] if _args.size() > 1 else false)
	var floor_damages := bool(_args[2] if _args.size() > 2 else false)
	return source_block_geometry.tile_dangerous_state(block_solid, floor_is_deep, floor_damages)

func java_method_getLinkedTiles_54(_args: Array = []) -> Variant:
	var block_is_multiblock := bool(_args[0] if _args.size() > 0 else false)
	var block_size := int(_args[1] if _args.size() > 1 else 1)
	var size_offset := int(_args[2] if _args.size() > 2 else 0)
	var x := int(_args[3] if _args.size() > 3 else 0)
	var y := int(_args[4] if _args.size() > 4 else 0)
	var world_tile_lookup: Variant = _args[5] if _args.size() > 5 else null
	var self_tile: Variant = _args[6] if _args.size() > 6 else null
	var consumer: Variant = _args[7] if _args.size() > 7 else null
	return source_block_geometry.tile_get_linked_tiles_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, consumer)

func java_method_getLinkedTiles_55(_args: Array = []) -> Variant:
	var block_is_multiblock := bool(_args[0] if _args.size() > 0 else false)
	var block_size := int(_args[1] if _args.size() > 1 else 1)
	var size_offset := int(_args[2] if _args.size() > 2 else 0)
	var x := int(_args[3] if _args.size() > 3 else 0)
	var y := int(_args[4] if _args.size() > 4 else 0)
	var world_tile_lookup: Variant = _args[5] if _args.size() > 5 else null
	var self_tile: Variant = _args[6] if _args.size() > 6 else null
	var tmp_array: Array = _args[7] if _args.size() > 7 and _args[7] is Array else []
	return source_block_geometry.tile_get_linked_tiles_array_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, tmp_array)

func java_method_getLinkedTilesAs_56(_args: Array = []) -> Variant:
	var block_is_multiblock := bool(_args[0] if _args.size() > 0 else false)
	var block_size := int(_args[1] if _args.size() > 1 else 1)
	var size_offset := int(_args[2] if _args.size() > 2 else 0)
	var x := int(_args[3] if _args.size() > 3 else 0)
	var y := int(_args[4] if _args.size() > 4 else 0)
	var world_tile_lookup: Variant = _args[5] if _args.size() > 5 else null
	var self_tile: Variant = _args[6] if _args.size() > 6 else null
	var tmp_array: Array = _args[7] if _args.size() > 7 and _args[7] is Array else []
	return source_block_geometry.tile_get_linked_tiles_as_array_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, tmp_array)

func java_method_getLinkedTilesAs_57(_args: Array = []) -> Variant:
	var block_is_multiblock := bool(_args[0] if _args.size() > 0 else false)
	var block_size := int(_args[1] if _args.size() > 1 else 1)
	var size_offset := int(_args[2] if _args.size() > 2 else 0)
	var x := int(_args[3] if _args.size() > 3 else 0)
	var y := int(_args[4] if _args.size() > 4 else 0)
	var world_tile_lookup: Variant = _args[5] if _args.size() > 5 else null
	var self_tile: Variant = _args[6] if _args.size() > 6 else null
	var consumer: Variant = _args[7] if _args.size() > 7 else null
	return source_block_geometry.tile_get_linked_tiles_as_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, consumer)

func java_method_getHitbox_58(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var block_size := int(_args[2] if _args.size() > 2 else 1)
	var source_tilesize := float(_args[3] if _args.size() > 3 else SOURCE_TILESIZE)
	var block_offset := float(_args[4] if _args.size() > 4 else 0.0)
	var rect_value: Variant = _args[5] if _args.size() > 5 else null
	return source_block_geometry.tile_get_hitbox_state(x, y, block_size, source_tilesize, block_offset, rect_value)

func java_method_getBounds_59(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var source_tilesize := float(_args[2] if _args.size() > 2 else SOURCE_TILESIZE)
	var rect_value: Variant = _args[3] if _args.size() > 3 else null
	return source_block_geometry.tile_get_bounds_state(x, y, source_tilesize, rect_value)

func java_method_hitbox_60(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var block_size := int(_args[2] if _args.size() > 2 else 1)
	var source_tilesize := float(_args[3] if _args.size() > 3 else SOURCE_TILESIZE)
	var block_offset := float(_args[4] if _args.size() > 4 else 0.0)
	var rect_value: Variant = _args[5] if _args.size() > 5 else null
	return source_block_geometry.tile_hitbox_state(x, y, block_size, source_tilesize, block_offset, rect_value)

func java_method_nearby_61(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var relative_x := int(_args[2] if _args.size() > 2 else 0)
	var relative_y := int(_args[3] if _args.size() > 3 else 0)
	var world_tile_lookup: Variant = _args[4] if _args.size() > 4 else null
	return source_block_geometry.tile_nearby_relative_state(x, y, relative_x, relative_y, world_tile_lookup)

func java_method_nearby_62(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var delta_x := int(_args[2] if _args.size() > 2 else 0)
	var delta_y := int(_args[3] if _args.size() > 3 else 0)
	var world_tile_lookup: Variant = _args[4] if _args.size() > 4 else null
	return source_block_geometry.tile_nearby_delta_state(x, y, delta_x, delta_y, world_tile_lookup)

func java_method_nearby_63(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var rotation := int(_args[2] if _args.size() > 2 else 0)
	var world_tile_lookup: Variant = _args[3] if _args.size() > 3 else null
	return source_block_geometry.tile_nearby_rotation_state(x, y, rotation, world_tile_lookup)

func java_method_nearbyBuild_64(_args: Array = []) -> Variant:
	var x := int(_args[0] if _args.size() > 0 else 0)
	var y := int(_args[1] if _args.size() > 1 else 0)
	var rotation := int(_args[2] if _args.size() > 2 else 0)
	var world_build_lookup: Variant = _args[3] if _args.size() > 3 else null
	return source_block_geometry.tile_nearby_build_rotation_state(x, y, rotation, world_build_lookup)

func java_method_interactable_65(_args: Array = []) -> Variant:
	var can_interact := bool(_args[0] if _args.size() > 0 else false)
	return source_block_geometry.tile_interactable_state(can_interact)

func java_method_drop_66(_args: Array = []) -> Variant:
	var overlay_is_air := bool(_args[0] if _args.size() > 0 else true)
	var overlay_item_drop: Variant = _args[1] if _args.size() > 1 else null
	var floor_item_drop: Variant = _args[2] if _args.size() > 2 else null
	return source_block_geometry.tile_drop_state(overlay_is_air, overlay_item_drop, floor_item_drop)

func java_method_wallDrop_67(_args: Array = []) -> Variant:
	var block_solid := bool(_args[0] if _args.size() > 0 else false)
	var block_item_drop: Variant = _args[1] if _args.size() > 1 else null
	var overlay_wall_ore := bool(_args[2] if _args.size() > 2 else false)
	var block_synthetic := bool(_args[3] if _args.size() > 3 else false)
	var overlay_item_drop: Variant = _args[4] if _args.size() > 4 else null
	return source_block_geometry.tile_wall_drop_state(block_solid, block_item_drop, overlay_wall_ore, block_synthetic, overlay_item_drop)

func java_method_shouldSaveData_68(_args: Array = []) -> Variant:
	var floor_save_data := bool(_args[0] if _args.size() > 0 else false)
	var overlay_save_data := bool(_args[1] if _args.size() > 1 else false)
	var block_save_data := bool(_args[2] if _args.size() > 2 else false)
	return source_block_geometry.tile_should_save_data_state(floor_save_data, overlay_save_data, block_save_data)

func java_method_staticDarkness_69(_args: Array = []) -> Variant:
	var block_solid := bool(_args[0] if _args.size() > 0 else false)
	var block_fills_tile := bool(_args[1] if _args.size() > 1 else false)
	var block_synthetic := bool(_args[2] if _args.size() > 2 else false)
	var data := int(_args[3] if _args.size() > 3 else 0)
	return source_block_geometry.tile_static_darkness_state(block_solid, block_fills_tile, block_synthetic, data)

func java_method_legSolid_70(_args: Array = []) -> Variant:
	var static_darkness := int(_args[0] if _args.size() > 0 else 0)
	var floor_solid := bool(_args[1] if _args.size() > 1 else false)
	var block_is_air := bool(_args[2] if _args.size() > 2 else true)
	return source_block_geometry.tile_leg_solid_state(static_darkness, floor_solid, block_is_air)

func java_method_adjacentTo_71(_args: Array = []) -> Variant:
	var relative_result := int(_args[0] if _args.size() > 0 else -1)
	return source_block_geometry.tile_adjacent_state(relative_result)

func java_method_preChanged_72(_args: Array = []) -> Variant:
	var world_generating := bool(_args[0] if _args.size() > 0 else false)
	var build_present := bool(_args[1] if _args.size() > 1 else false)
	var block_is_multiblock := bool(_args[2] if _args.size() > 2 else false)
	var multiblock_tiles: Array = _args[3] if _args.size() > 3 and _args[3] is Array else []
	var self_tile: Variant = _args[4] if _args.size() > 4 else null
	var pre_event_call: Variant = _args[5] if _args.size() > 5 else null
	var changed_event_call: Variant = _args[6] if _args.size() > 6 else null
	return source_block_geometry.tile_pre_changed_state(world_generating, build_present, block_is_multiblock, multiblock_tiles, self_tile, pre_event_call, changed_event_call)

func java_method_changeBuild_73(_args: Array = []) -> Variant:
	var build_present := bool(_args[0] if _args.size() > 0 else false)
	var existing_build_size := int(_args[1] if _args.size() > 1 else 0)
	var old_build_remove_call: Variant = _args[2] if _args.size() > 2 else null
	var edge_buildings: Array = _args[3] if _args.size() > 3 and _args[3] is Array else []
	var block_has_building := bool(_args[4] if _args.size() > 4 else false)
	var team: Variant = _args[5] if _args.size() > 5 else null
	var rotation := int(_args[6] if _args.size() > 6 else 0)
	var editor_state := bool(_args[7] if _args.size() > 7 else false)
	var block_update := bool(_args[8] if _args.size() > 8 else false)
	var entity_init_result: Variant = _args[9] if _args.size() > 9 else null
	return source_block_geometry.tile_change_build_state(build_present, existing_build_size, old_build_remove_call, edge_buildings, block_has_building, team, rotation, editor_state, block_update, entity_init_result)

func java_method_changed_74(_args: Array = []) -> Variant:
	var world_generating := bool(_args[0] if _args.size() > 0 else false)
	var build_present := bool(_args[1] if _args.size() > 1 else false)
	var nearby_buildings: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []
	var block_static := bool(_args[3] if _args.size() > 3 else false)
	var event_call: Variant = _args[4] if _args.size() > 4 else null
	return source_block_geometry.tile_changed_state(world_generating, build_present, nearby_buildings, block_static, event_call)

func java_method_fireChanged_75(_args: Array = []) -> Variant:
	var world_generating := bool(_args[0] if _args.size() > 0 else false)
	var event_call: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_fire_change_state(world_generating, event_call)

func java_method_firePreChanged_76(_args: Array = []) -> Variant:
	var world_generating := bool(_args[0] if _args.size() > 0 else false)
	var event_call: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_fire_change_state(world_generating, event_call)

func java_method_getPackedData_77(_args: Array = []) -> Variant:
	var extra_data := int(_args[0] if _args.size() > 0 else 0)
	var data := int(_args[1] if _args.size() > 1 else 0)
	var floor_data := int(_args[2] if _args.size() > 2 else 0)
	var overlay_data := int(_args[3] if _args.size() > 3 else 0)
	return source_block_geometry.tile_packed_data_state(extra_data, data, floor_data, overlay_data)

func java_method_setPackedData_78(_args: Array = []) -> Variant:
	var packed := int(_args[0] if _args.size() > 0 else 0)
	return source_block_geometry.tile_unpack_data_state(packed)

func java_method_display_79(_args: Array = []) -> Variant:
	var block_item_drop_present := bool(_args[0] if _args.size() > 0 else false)
	var overlay_item_drop_present := bool(_args[1] if _args.size() > 1 else false)
	var wall_drop_present := bool(_args[2] if _args.size() > 2 else false)
	var block_value: Variant = _args[3] if _args.size() > 3 else null
	var overlay_value: Variant = _args[4] if _args.size() > 4 else null
	var floor_value: Variant = _args[5] if _args.size() > 5 else null
	var display_icon: Variant = _args[6] if _args.size() > 6 else null
	var display_name := str(_args[7] if _args.size() > 7 else "")
	return source_block_geometry.tile_display_state(block_item_drop_present, overlay_item_drop_present, wall_drop_present, block_value, overlay_value, floor_value, display_icon, display_name)

func java_method_getX_80(_args: Array = []) -> Variant:
	var draw_x := float(_args[0] if _args.size() > 0 else 0.0)
	return source_block_geometry.tile_coordinate_display_state(draw_x)

func java_method_getY_81(_args: Array = []) -> Variant:
	var draw_y := float(_args[0] if _args.size() > 0 else 0.0)
	return source_block_geometry.tile_coordinate_display_state(draw_y)

func java_method_toString_82(_args: Array = []) -> Variant:
	var floor_name := str(_args[0] if _args.size() > 0 else "")
	var block_name := str(_args[1] if _args.size() > 1 else "")
	var overlay_text := str(_args[2] if _args.size() > 2 else "")
	var x := int(_args[3] if _args.size() > 3 else 0)
	var y := int(_args[4] if _args.size() > 4 else 0)
	var build_present := bool(_args[5] if _args.size() > 5 else false)
	var build_class_name := str(_args[6] if _args.size() > 6 else "")
	var team_text := str(_args[7] if _args.size() > 7 else "")
	return source_block_geometry.tile_to_string_state(floor_name, block_name, overlay_text, x, y, build_present, build_class_name, team_text)

func java_method_setTileBlocks_83(_args: Array = []) -> Variant:
	var block: Variant = _args[0] if _args.size() > 0 else null
	var team: Variant = _args[1] if _args.size() > 1 else null
	var positions: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []
	var block_valid := bool(_args[3] if _args.size() > 3 else block != null)
	var world_tiles: Dictionary = _args[4] if _args.size() > 4 and _args[4] is Dictionary else {}
	return source_block_geometry.tile_bulk_mutation_state("set_block", block, team, positions, block_valid, world_tiles)

func java_method_setTileFloors_84(_args: Array = []) -> Variant:
	var block: Variant = _args[0] if _args.size() > 0 else null
	var positions: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	var floor_valid := bool(_args[2] if _args.size() > 2 else false)
	var world_tiles: Dictionary = _args[3] if _args.size() > 3 and _args[3] is Dictionary else {}
	return source_block_geometry.tile_bulk_mutation_state("set_floor", block, null, positions, floor_valid, world_tiles)

func java_method_setTileOverlays_85(_args: Array = []) -> Variant:
	var block: Variant = _args[0] if _args.size() > 0 else null
	var positions: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	var overlay_valid := bool(_args[2] if _args.size() > 2 else false)
	var world_tiles: Dictionary = _args[3] if _args.size() > 3 and _args[3] is Dictionary else {}
	return source_block_geometry.tile_bulk_mutation_state("set_overlay", block, null, positions, overlay_valid, world_tiles)

func java_method_setFloor_86(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var floor: Variant = _args[1] if _args.size() > 1 else null
	var overlay: Variant = _args[2] if _args.size() > 2 else null
	return source_block_geometry.tile_single_mutation_state("set_floor", tile, floor, overlay, 0, tile != null)

func java_method_setOverlay_87(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var overlay: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_single_mutation_state("set_overlay", tile, overlay, null, 0, tile != null)

func java_method_removeTile_88(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_single_mutation_state("remove_tile", tile, null, null, 0, tile != null)

func java_method_setTile_89(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var block: Variant = _args[1] if _args.size() > 1 else null
	var team: Variant = _args[2] if _args.size() > 2 else null
	var rotation := int(_args[3] if _args.size() > 3 else 0)
	return source_block_geometry.tile_single_mutation_state("set_tile", tile, block, team, rotation, tile != null)

func java_method_setTeam_90(_args: Array = []) -> Variant:
	var build: Variant = _args[0] if _args.size() > 0 else null
	var team: Variant = _args[1] if _args.size() > 1 else null
	return source_block_geometry.tile_static_callback_state("set_team", build != null, build, team, [], [], [], [], [])

func java_method_setTeams_91(_args: Array = []) -> Variant:
	var positions_present := _args.size() > 0 and _args[0] != null
	var positions: Array = _args[0] if positions_present and _args[0] is Array else []
	var team: Variant = _args[1] if _args.size() > 1 else null
	var first_pass: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []
	var second_pass: Array = _args[3] if _args.size() > 3 and _args[3] is Array else []
	return source_block_geometry.tile_static_callback_state("set_teams", false, null, team, positions, first_pass, second_pass, [], [], positions_present)

func java_method_buildDestroyed_92(_args: Array = []) -> Variant:
	var build: Variant = _args[0] if _args.size() > 0 else null
	return source_block_geometry.tile_static_callback_state("build_destroyed", build != null, build, null, [], [], [], [], [])

func java_method_buildHealthUpdate_93(_args: Array = []) -> Variant:
	var health_updates: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	return source_block_geometry.tile_static_callback_state("build_health_update", false, null, null, [], [], [], [], health_updates)
