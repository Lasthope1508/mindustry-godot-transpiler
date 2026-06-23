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

func java_method_pos_0(_args: Array = []) -> Variant:
	return null

func java_method_array_1(_args: Array = []) -> Variant:
	return null

func java_method_relativeTo_2(_args: Array = []) -> Variant:
	return null

func java_method_relativeTo_3(_args: Array = []) -> Variant:
	return null

func java_method_relativeTo_4(_args: Array = []) -> Variant:
	return null

func java_method_relativeTo_5(_args: Array = []) -> Variant:
	return null

func java_method_absoluteRelativeTo_6(_args: Array = []) -> Variant:
	return null

func java_method_getFlammability_7(_args: Array = []) -> Variant:
	return null

func java_method_inMapArea_8(_args: Array = []) -> Variant:
	return null

func java_method_worldx_9(_args: Array = []) -> Variant:
	return null

func java_method_worldy_10(_args: Array = []) -> Variant:
	return null

func java_method_drawx_11(_args: Array = []) -> Variant:
	return null

func java_method_drawy_12(_args: Array = []) -> Variant:
	return null

func java_method_isDarkened_13(_args: Array = []) -> Variant:
	return null

func java_method_floor_14(_args: Array = []) -> Variant:
	return null

func java_method_block_15(_args: Array = []) -> Variant:
	return null

func java_method_overlay_16(_args: Array = []) -> Variant:
	return null

func java_method_cblock_17(_args: Array = []) -> Variant:
	return null

func java_method_team_18(_args: Array = []) -> Variant:
	return null

func java_method_setTeam_19(_args: Array = []) -> Variant:
	return null

func java_method_isCenter_20(_args: Array = []) -> Variant:
	return null

func java_method_centerX_21(_args: Array = []) -> Variant:
	return null

func java_method_centerY_22(_args: Array = []) -> Variant:
	return null

func java_method_getTeamID_23(_args: Array = []) -> Variant:
	return null

func java_method_setBlock_24(_args: Array = []) -> Variant:
	return null

func java_method_setBlock_25(_args: Array = []) -> Variant:
	return null

func java_method_setBlock_26(_args: Array = []) -> Variant:
	return null

func java_method_setBlock_27(_args: Array = []) -> Variant:
	return null

func java_method_setFloor_28(_args: Array = []) -> Variant:
	return null

func java_method_isEditorTile_29(_args: Array = []) -> Variant:
	return null

func java_method_setAir_30(_args: Array = []) -> Variant:
	return null

func java_method_circle_31(_args: Array = []) -> Variant:
	return null

func java_method_circle_32(_args: Array = []) -> Variant:
	return null

func java_method_getFloorColor_33(_args: Array = []) -> Variant:
	return null

func java_method_recacheWall_34(_args: Array = []) -> Variant:
	return null

func java_method_recache_35(_args: Array = []) -> Variant:
	return null

func java_method_remove_36(_args: Array = []) -> Variant:
	return null

func java_method_removeNet_37(_args: Array = []) -> Variant:
	return null

func java_method_setNet_38(_args: Array = []) -> Variant:
	return null

func java_method_setNet_39(_args: Array = []) -> Variant:
	return null

func java_method_setFloorNet_40(_args: Array = []) -> Variant:
	return null

func java_method_setFloorNet_41(_args: Array = []) -> Variant:
	return null

func java_method_setOverlayNet_42(_args: Array = []) -> Variant:
	return null

func java_method_overlayID_43(_args: Array = []) -> Variant:
	return null

func java_method_blockID_44(_args: Array = []) -> Variant:
	return null

func java_method_floorID_45(_args: Array = []) -> Variant:
	return null

func java_method_setOverlay_46(_args: Array = []) -> Variant:
	return null

func java_method_setOverlayQuiet_47(_args: Array = []) -> Variant:
	return null

func java_method_clearOverlay_48(_args: Array = []) -> Variant:
	return null

func java_method_passable_49(_args: Array = []) -> Variant:
	return null

func java_method_synthetic_50(_args: Array = []) -> Variant:
	return null

func java_method_solid_51(_args: Array = []) -> Variant:
	return null

func java_method_breakable_52(_args: Array = []) -> Variant:
	return null

func java_method_dangerous_53(_args: Array = []) -> Variant:
	return null

func java_method_getLinkedTiles_54(_args: Array = []) -> Variant:
	return null

func java_method_getLinkedTiles_55(_args: Array = []) -> Variant:
	return null

func java_method_getLinkedTilesAs_56(_args: Array = []) -> Variant:
	return null

func java_method_getLinkedTilesAs_57(_args: Array = []) -> Variant:
	return null

func java_method_getHitbox_58(_args: Array = []) -> Variant:
	return null

func java_method_getBounds_59(_args: Array = []) -> Variant:
	return null

func java_method_hitbox_60(_args: Array = []) -> Variant:
	return null

func java_method_nearby_61(_args: Array = []) -> Variant:
	return null

func java_method_nearby_62(_args: Array = []) -> Variant:
	return null

func java_method_nearby_63(_args: Array = []) -> Variant:
	return null

func java_method_nearbyBuild_64(_args: Array = []) -> Variant:
	return null

func java_method_interactable_65(_args: Array = []) -> Variant:
	return null

func java_method_drop_66(_args: Array = []) -> Variant:
	return null

func java_method_wallDrop_67(_args: Array = []) -> Variant:
	return null

func java_method_shouldSaveData_68(_args: Array = []) -> Variant:
	return null

func java_method_staticDarkness_69(_args: Array = []) -> Variant:
	return null

func java_method_legSolid_70(_args: Array = []) -> Variant:
	return null

func java_method_adjacentTo_71(_args: Array = []) -> Variant:
	return null

func java_method_preChanged_72(_args: Array = []) -> Variant:
	return null

func java_method_changeBuild_73(_args: Array = []) -> Variant:
	return null

func java_method_changed_74(_args: Array = []) -> Variant:
	return null

func java_method_fireChanged_75(_args: Array = []) -> Variant:
	return null

func java_method_firePreChanged_76(_args: Array = []) -> Variant:
	return null

func java_method_getPackedData_77(_args: Array = []) -> Variant:
	return null

func java_method_setPackedData_78(_args: Array = []) -> Variant:
	return null

func java_method_display_79(_args: Array = []) -> Variant:
	return null

func java_method_getX_80(_args: Array = []) -> Variant:
	return null

func java_method_getY_81(_args: Array = []) -> Variant:
	return null

func java_method_toString_82(_args: Array = []) -> Variant:
	return null

func java_method_setTileBlocks_83(_args: Array = []) -> Variant:
	return null

func java_method_setTileFloors_84(_args: Array = []) -> Variant:
	return null

func java_method_setTileOverlays_85(_args: Array = []) -> Variant:
	return null

func java_method_setFloor_86(_args: Array = []) -> Variant:
	return null

func java_method_setOverlay_87(_args: Array = []) -> Variant:
	return null

func java_method_removeTile_88(_args: Array = []) -> Variant:
	return null

func java_method_setTile_89(_args: Array = []) -> Variant:
	return null

func java_method_setTeam_90(_args: Array = []) -> Variant:
	return null

func java_method_setTeams_91(_args: Array = []) -> Variant:
	return null

func java_method_buildDestroyed_92(_args: Array = []) -> Variant:
	return null

func java_method_buildHealthUpdate_93(_args: Array = []) -> Variant:
	return null
