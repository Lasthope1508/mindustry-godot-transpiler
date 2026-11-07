extends Node

const TileScript := preload("res://src/generated/classes/mindustry/world/Tile.gd")
const source_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

var world_tiles: Dictionary = {}
var linked_callback_tiles: Array = []
var circle_points: Array = []
var circle_tiles: Array = []

func _lookup_tile(x: int, y: int) -> Variant:
	return world_tiles.get("%d,%d" % [x, y], null)

func _append_linked_tile(tile: Variant) -> void:
	linked_callback_tiles.append(tile)

func _append_circle_point(x: int, y: int) -> void:
	circle_points.append({"x": x, "y": y})

func _append_circle_tile(tile: Variant) -> void:
	circle_tiles.append(tile)

func _ready() -> void:
	var tile := TileScript.new()
	var pos_value := int(tile.java_method_pos_0([3, 4]))
	var negative_pos_value := int(tile.java_method_pos_0([-1, -2]))
	var array_value := int(tile.java_method_array_1([3, 4, 16]))
	var left := int(tile.java_method_relativeTo_2([2, 4, 3, 4]))
	var up := int(tile.java_method_relativeTo_3([3, 3, 3, 4]))
	var float_right := int(tile.java_method_relativeTo_5([4.5, 4.0, 3.0, 4.0]))
	var odd_left := int(tile.java_method_absoluteRelativeTo_6([2, 4, 3, 4, 3]))
	var even_left := int(tile.java_method_absoluteRelativeTo_6([1, 4, 3, 4, 2]))
	var even_up := int(tile.java_method_absoluteRelativeTo_6([3, 2, 3, 4, 2]))
	var floor_flammability := float(tile.java_method_getFlammability_7([true, true, 0.8, false, false, 0.0, 0.0, 0.0, false, 0.0, 0.0]))
	var storage_flammability := float(tile.java_method_getFlammability_7([false, false, 0.0, true, true, 2.0, 3.0, 2.0, true, 4.8, 30.0]))
	var empty_flammability := float(tile.java_method_getFlammability_7([false, false, 0.0, false, false, 0.0, 0.0, 0.0, false, 0.0, 0.0]))
	var unrestricted_area := bool(tile.java_method_inMapArea_8([99, -99, false, 2, 3, 2, 2]))
	var limited_area_inside := bool(tile.java_method_inMapArea_8([4, 5, true, 2, 3, 2, 2]))
	var limited_area_outside := bool(tile.java_method_inMapArea_8([5, 5, true, 2, 3, 2, 2]))
	var center_without_build := bool(tile.java_method_isCenter_20([false, false]))
	var center_self_build := bool(tile.java_method_isCenter_20([true, true]))
	var off_center_build := bool(tile.java_method_isCenter_20([true, false]))
	var center_x_without_build := int(tile.java_method_centerX_21([9, false, 4]))
	var center_x_with_build := int(tile.java_method_centerX_21([9, true, 4]))
	var center_y_without_build := int(tile.java_method_centerY_22([11, false, 6]))
	var center_y_with_build := int(tile.java_method_centerY_22([11, true, 6]))
	var team_id_without_build := int(tile.java_method_getTeamID_23([false, 5, 6]))
	var team_id_with_build := int(tile.java_method_getTeamID_23([true, 5, 6]))
	var set_floor_same: Dictionary = tile.java_method_setFloor_28([{"id": "sand"}, {"id": "sand"}, false, false, false, true, true, false, {"id": "tile-floor"}, {"event": "floor-change"}, {"call": "floorChanged"}])
	var set_floor_full: Dictionary = tile.java_method_setFloor_28([{"id": "water"}, {"id": "sand"}, false, false, false, true, true, false, {"id": "tile-floor"}, {"event": "floor-change"}, {"call": "floorChanged"}])
	var set_floor_generating: Dictionary = tile.java_method_setFloor_28([{"id": "water"}, {"id": "sand"}, false, true, false, true, true, false, {"id": "tile-floor"}, {"event": "floor-change"}, {"call": "floorChanged"}])
	var set_air: Dictionary = tile.java_method_setAir_30([{"id": "air"}])
	var editor_tile: Dictionary = tile.java_method_isEditorTile_29([])
	var floor_color: Dictionary = tile.java_method_getFloorColor_33(["floor-color", {"id": "tile-floor"}])
	var recache_wall: Dictionary = tile.java_method_recacheWall_34([false, false, {"id": "tile-floor"}])
	var recache_wall_generating: Dictionary = tile.java_method_recacheWall_34([false, true, {"id": "tile-floor"}])
	var recache: Dictionary = tile.java_method_recache_35([false, false, {"id": "tile-floor"}, [{"id": "neighbor-a"}, null, {"id": "neighbor-b"}]])
	var recache_generating: Dictionary = tile.java_method_recache_35([false, true, {"id": "tile-floor"}, [{"id": "neighbor-a"}]])
	var remove_tile: Dictionary = tile.java_method_remove_36([{"id": "air"}])
	var remove_net: Dictionary = tile.java_method_removeNet_37([{"id": "tile-net"}])
	var set_net_default: Dictionary = tile.java_method_setNet_38([{"id": "tile-net"}, {"id": "block"}])
	var set_net: Dictionary = tile.java_method_setNet_39([{"id": "tile-net"}, {"id": "block"}, {"id": 5}, 3])
	var set_floor_net: Dictionary = tile.java_method_setFloorNet_40([{"id": "tile-net"}, {"id": "floor"}, {"id": "overlay"}])
	var set_floor_net_default: Dictionary = tile.java_method_setFloorNet_41([{"id": "tile-net"}, {"id": "floor"}])
	var set_overlay_net: Dictionary = tile.java_method_setOverlayNet_42([{"id": "tile-net"}, {"id": "overlay"}])
	var set_overlay: Dictionary = tile.java_method_setOverlay_46([{"id": "overlay-new"}, {"id": "overlay-old"}, false, true, {"event": "overlay-change"}])
	var set_overlay_same: Dictionary = tile.java_method_setOverlay_46([{"id": "overlay-old"}, {"id": "overlay-old"}, false, true, {"event": "overlay-change"}])
	var set_overlay_quiet: Dictionary = tile.java_method_setOverlayQuiet_47([{"id": "overlay-quiet"}])
	var clear_overlay: Dictionary = tile.java_method_clearOverlay_48([{"id": "air"}])
	var circle_int: Dictionary = tile.java_method_circle_31([2, 5, 5, 10, 10, Callable(self, "_append_circle_point")])
	var circle_tile: Dictionary = tile.java_method_circle_32([2, 5, 5, 10, 10, Callable(self, "_lookup_tile"), Callable(self, "_append_circle_tile")])
	var floor_value: Variant = tile.java_method_floor_14([{"id": "floor"}])
	var block_value: Variant = tile.java_method_block_15([{"id": "block"}])
	var overlay_value: Variant = tile.java_method_overlay_16([{"id": "overlay"}])
	var cblock_value: Variant = tile.java_method_cblock_17([{"id": "block"}])
	var team_without_build: Variant = tile.java_method_team_18([false, {"id": 5}, {"id": 6}])
	var team_with_build: Variant = tile.java_method_team_18([true, {"id": 5}, {"id": 6}])
	var darkened := bool(tile.java_method_isDarkened_13([true]))
	var not_darkened := bool(tile.java_method_isDarkened_13([false]))
	var set_team_without_build: Dictionary = tile.java_method_setTeam_19([false, {"id": 7}])
	var set_team_with_build: Dictionary = tile.java_method_setTeam_19([true, {"id": 7}])
	var overlay_id_state: Dictionary = tile.java_method_overlayID_43([{"id": 12}])
	var block_id_state: Dictionary = tile.java_method_blockID_44([{"id": 13}])
	var floor_id_state: Dictionary = tile.java_method_floorID_45([{"id": 14}])
	var passable_state := bool(tile.java_method_passable_49([false, true, false, false, false, false]))
	var blocked_by_floor_state := bool(tile.java_method_passable_49([true, true, false, false, false, false]))
	var synthetic_state := bool(tile.java_method_synthetic_50([true, false]))
	var solid_state := bool(tile.java_method_solid_51([false, false, true, true]))
	var breakable_state := bool(tile.java_method_breakable_52([false, true, false]))
	var dangerous_state := bool(tile.java_method_dangerous_53([false, true, false]))
	var self_tile := {"name": "self"}
	world_tiles = {
		"4,5": {"name": "northwest"},
		"4,6": {"name": "southwest"},
		"5,5": {"name": "northeast"},
	}
	tile.java_method_getLinkedTiles_54([true, 2, -1, 5, 6, Callable(self, "_lookup_tile"), self_tile, Callable(self, "_append_linked_tile")])
	var linked_sequence := [{"name": "stale"}]
	var linked_sequence_result: Array = tile.java_method_getLinkedTiles_55([true, 2, -1, 5, 6, Callable(self, "_lookup_tile"), self_tile, linked_sequence])
	var linked_as_sequence := [{"name": "stale"}]
	var linked_as_sequence_result: Array = tile.java_method_getLinkedTilesAs_56([true, 2, -1, 5, 6, Callable(self, "_lookup_tile"), self_tile, linked_as_sequence])
	var linked_as_callback: Array = []
	var append_as_tile := func(other: Variant) -> void:
		linked_as_callback.append(other)
	tile.java_method_getLinkedTilesAs_57([true, 2, -1, 5, 6, Callable(self, "_lookup_tile"), self_tile, append_as_tile])
	var single_tile_sequence: Array = tile.java_method_getLinkedTiles_55([false, 1, 0, 5, 6, Callable(self, "_lookup_tile"), self_tile, []])
	var hitbox_state: Dictionary = tile.java_method_getHitbox_58([3, 4, 2, 8.0, 1.5, {"name": "hitbox"}])
	var bounds_state: Dictionary = tile.java_method_getBounds_59([3, 4, 8.0, {"name": "bounds"}])
	var hitbox_delegate_state: Dictionary = tile.java_method_hitbox_60([3, 4, 2, 8.0, 1.5, {"name": "hitbox-delegate"}])
	var world_x := float(tile.java_method_worldx_9([3, 8.0]))
	var world_y := float(tile.java_method_worldy_10([4, 8.0]))
	var draw_x := float(tile.java_method_drawx_11([3, 8.0, 1.5]))
	var draw_y := float(tile.java_method_drawy_12([4, 8.0, 1.5]))
	var interactable_true := bool(tile.java_method_interactable_65([true]))
	var interactable_false := bool(tile.java_method_interactable_65([false]))
	var drop_floor: Variant = tile.java_method_drop_66([true, null, {"id": "floor-item"}])
	var drop_overlay: Variant = tile.java_method_drop_66([false, {"id": "overlay-item"}, {"id": "floor-item"}])
	var drop_overlay_without_item: Variant = tile.java_method_drop_66([false, null, {"id": "floor-item"}])
	var wall_block_item: Variant = tile.java_method_wallDrop_67([true, {"id": "block-item"}, true, false, {"id": "ore-item"}])
	var wall_ore: Variant = tile.java_method_wallDrop_67([true, null, true, false, {"id": "ore-item"}])
	var wall_synthetic_ore: Variant = tile.java_method_wallDrop_67([true, null, true, true, {"id": "ore-item"}])
	var wall_non_solid: Variant = tile.java_method_wallDrop_67([false, {"id": "block-item"}, true, false, {"id": "ore-item"}])
	var saves_floor := bool(tile.java_method_shouldSaveData_68([true, false, false]))
	var saves_overlay := bool(tile.java_method_shouldSaveData_68([false, true, false]))
	var saves_block := bool(tile.java_method_shouldSaveData_68([false, false, true]))
	var saves_none := bool(tile.java_method_shouldSaveData_68([false, false, false]))
	var static_darkness := int(tile.java_method_staticDarkness_69([true, true, false, 3]))
	var synthetic_darkness := int(tile.java_method_staticDarkness_69([true, true, true, 3]))
	var non_solid_darkness := int(tile.java_method_staticDarkness_69([false, true, false, 3]))
	var darkness_leg_solid := bool(tile.java_method_legSolid_70([2, false, false]))
	var floor_leg_solid := bool(tile.java_method_legSolid_70([0, true, true]))
	var open_leg_solid := bool(tile.java_method_legSolid_70([0, true, false]))
	var adjacent := bool(tile.java_method_adjacentTo_71([0]))
	var non_adjacent := bool(tile.java_method_adjacentTo_71([-1]))
	var packed_data := int(tile.java_method_getPackedData_77([0x12345678, -2, 3, 4]))
	var unpacked_data: Dictionary = tile.java_method_setPackedData_78([packed_data])
	var get_x_value := float(tile.java_method_getX_80([25.5]))
	var get_y_value := float(tile.java_method_getY_81([33.5]))
	var text_without_build := str(tile.java_method_toString_82(["stone", "wall", "ore", 3, 4, false, "", "derelict"]))
	var text_with_build := str(tile.java_method_toString_82(["stone", "wall", "ore", 3, 4, true, "TurretBuild", "sharded"]))
	var changed_during_generation: Dictionary = tile.java_method_fireChanged_75([true, {"event": "tile-change"}])
	var changed_after_generation: Dictionary = tile.java_method_fireChanged_75([false, {"event": "tile-change"}])
	var pre_changed_during_generation: Dictionary = tile.java_method_firePreChanged_76([true, {"event": "tile-pre-change"}])
	var pre_changed_after_generation: Dictionary = tile.java_method_firePreChanged_76([false, {"event": "tile-pre-change"}])
	var changed_with_build: Dictionary = tile.java_method_changed_74([false, true, [], true, {"event": "tile-change"}])
	var changed_without_build: Dictionary = tile.java_method_changed_74([false, false, [{"present": true, "changing": false}, {"present": true, "changing": true}, {"present": false, "changing": false}], true, {"event": "tile-change"}])
	var changed_method_during_generation: Dictionary = tile.java_method_changed_74([true, true, [{"present": true, "changing": false}], true, {"event": "tile-change"}])
	var pre_changed_no_build: Dictionary = tile.java_method_preChanged_72([false, false, false, [], {"name": "self"}, {"event": "tile-pre-change"}, {"event": "tile-change"}])
	var pre_changed_multiblock: Dictionary = tile.java_method_preChanged_72([false, true, true, [{"name": "self"}, {"name": "other"}, null, {"name": "third"}], {"name": "self"}, {"event": "tile-pre-change"}, {"event": "tile-change"}])
	var pre_changed_generating: Dictionary = tile.java_method_preChanged_72([true, true, true, [{"name": "self"}, {"name": "other"}], {"name": "self"}, {"event": "tile-pre-change"}, {"event": "tile-change"}])
	var change_build_with_old: Dictionary = tile.java_method_changeBuild_73([true, 3, {"call": "build.remove();"}, [{"name": "edge-a"}, {"name": "edge-b"}, {"name": "edge-a"}], true, {"id": 5}, 2, false, true, {"id": "new-build"}])
	var change_build_no_old: Dictionary = tile.java_method_changeBuild_73([false, 0, {"call": "build.remove();"}, [{"name": "edge-a"}], false, {"id": 6}, 1, true, true, {"id": "ignored"}])
	var display_block: Dictionary = tile.java_method_display_79([true, false, false, {"id": "block"}, {"id": "overlay"}, {"id": "floor"}, "block-icon", "Block Name"])
	var display_overlay: Dictionary = tile.java_method_display_79([false, true, false, {"id": "block"}, {"id": "overlay"}, {"id": "floor"}, "overlay-icon", "Overlay Name"])
	var display_wall: Dictionary = tile.java_method_display_79([false, false, true, {"id": "block"}, {"id": "overlay"}, {"id": "floor"}, "wall-icon", "Wall Ore"])
	var display_floor: Dictionary = tile.java_method_display_79([false, false, false, {"id": "block"}, {"id": "overlay"}, {"id": "floor"}, "floor-icon", "Floor Name"])
	var bulk_blocks: Dictionary = tile.java_method_setTileBlocks_83([{"id": "block"}, {"id": 5}, [101, 102, 103], true, {"101": {"id": "tile-a"}, "102": null, "103": {"id": "tile-b"}}])
	var bulk_floors: Dictionary = tile.java_method_setTileFloors_84([{"id": "floor"}, [101, 102], true, {"101": {"id": "tile-a"}, "102": null}])
	var bulk_overlays: Dictionary = tile.java_method_setTileOverlays_85([{"id": "overlay"}, [101], true, {"101": {"id": "tile-a"}}])
	var single_floor: Dictionary = tile.java_method_setFloor_86([{"id": "tile-a"}, {"id": "floor"}, {"id": "overlay"}])
	var single_overlay: Dictionary = tile.java_method_setOverlay_87([{"id": "tile-a"}, {"id": "overlay"}])
	var single_remove: Dictionary = tile.java_method_removeTile_88([{"id": "tile-a"}])
	var single_set_tile: Dictionary = tile.java_method_setTile_89([{"id": "tile-a"}, {"id": "block"}, {"id": 5}, 3])
	var single_set_tile_null: Dictionary = tile.java_method_setTile_89([null, {"id": "block"}, {"id": 5}, 3])
	var static_set_team: Dictionary = tile.java_method_setTeam_90([{"id": "build-a"}, {"id": 7}])
	var static_set_team_null: Dictionary = tile.java_method_setTeam_90([null, {"id": 7}])
	var static_set_teams: Dictionary = tile.java_method_setTeams_91([[101, 102], {"id": 8}, [{"position": 101, "build_present": true}], [{"position": 101, "reflow": true}]])
	var static_set_teams_null: Dictionary = tile.java_method_setTeams_91([null, {"id": 8}])
	var static_build_destroyed: Dictionary = tile.java_method_buildDestroyed_92([{"id": "build-b"}])
	var static_build_destroyed_null: Dictionary = tile.java_method_buildDestroyed_92([null])
	var static_health_update: Dictionary = tile.java_method_buildHealthUpdate_93([[{"position": 101, "build_present": true, "current_health": 10.0, "health": 8.0}, {"position": 102, "build_present": true, "current_health": 10.0, "health": 10.0}]])
	var set_block_default: Dictionary = tile.java_method_setBlock_24([{"id": "block"}, {"id": 5}, 3])
	var set_block_team: Dictionary = tile.java_method_setBlock_26([{"id": "block"}, {"id": 5}])
	var set_block_type: Dictionary = tile.java_method_setBlock_27([{"id": "block"}])
	var set_block_main: Dictionary = tile.java_method_setBlock_25([false, {"id": "block"}, {"id": 5}, 5, {"id": "provider"}, true, false, {"id": 9}, true, true, [{"name": "self"}, {"name": "old-other"}, null], {"name": "self"}, true, true, false, {"id": "new-build"}, true, 3, [{"name": "self"}, {"name": "new-other"}, null, {"name": "new-third"}], {"event": "block-changed"}])
	var proof := {
		"module": "TILE_MODULE_PROOF",
		"pos": pos_value,
		"negative_pos": negative_pos_value,
		"array": array_value,
		"left": left,
		"up": up,
		"float_right": float_right,
		"odd_left": odd_left,
		"even_left": even_left,
		"even_up": even_up,
		"floor_flammability": floor_flammability,
		"storage_flammability": storage_flammability,
		"empty_flammability": empty_flammability,
		"unrestricted_area": unrestricted_area,
		"limited_area_inside": limited_area_inside,
		"limited_area_outside": limited_area_outside,
		"center_without_build": center_without_build,
		"center_self_build": center_self_build,
		"off_center_build": off_center_build,
		"center_x_without_build": center_x_without_build,
		"center_x_with_build": center_x_with_build,
		"center_y_without_build": center_y_without_build,
		"center_y_with_build": center_y_with_build,
		"team_id_without_build": team_id_without_build,
		"team_id_with_build": team_id_with_build,
		"set_floor_same": set_floor_same,
		"set_floor_full": set_floor_full,
		"set_floor_generating": set_floor_generating,
		"set_air": set_air,
		"editor_tile": editor_tile,
		"floor_color": floor_color,
		"recache_wall": recache_wall,
		"recache_wall_generating": recache_wall_generating,
		"recache": recache,
		"recache_generating": recache_generating,
		"remove_tile": remove_tile,
		"remove_net": remove_net,
		"set_net_default": set_net_default,
		"set_net": set_net,
		"set_floor_net": set_floor_net,
		"set_floor_net_default": set_floor_net_default,
		"set_overlay_net": set_overlay_net,
		"set_overlay": set_overlay,
		"set_overlay_same": set_overlay_same,
		"set_overlay_quiet": set_overlay_quiet,
		"clear_overlay": clear_overlay,
		"circle_int": circle_int,
		"circle_tile": circle_tile,
		"floor_value": floor_value,
		"block_value": block_value,
		"overlay_value": overlay_value,
		"cblock_value": cblock_value,
		"team_without_build": team_without_build,
		"team_with_build": team_with_build,
		"darkened": darkened,
		"not_darkened": not_darkened,
		"set_team_without_build": set_team_without_build,
		"set_team_with_build": set_team_with_build,
		"overlay_id_state": overlay_id_state,
		"block_id_state": block_id_state,
		"floor_id_state": floor_id_state,
		"passable_state": passable_state,
		"blocked_by_floor_state": blocked_by_floor_state,
		"synthetic_state": synthetic_state,
		"solid_state": solid_state,
		"breakable_state": breakable_state,
		"dangerous_state": dangerous_state,
		"linked_callback_tiles": linked_callback_tiles,
		"linked_sequence": linked_sequence,
		"linked_sequence_result": linked_sequence_result,
		"linked_as_sequence": linked_as_sequence,
		"linked_as_sequence_result": linked_as_sequence_result,
		"linked_as_callback": linked_as_callback,
		"single_tile_sequence": single_tile_sequence,
		"hitbox_state": hitbox_state,
		"bounds_state": bounds_state,
		"hitbox_delegate_state": hitbox_delegate_state,
		"world_x": world_x,
		"world_y": world_y,
		"draw_x": draw_x,
		"draw_y": draw_y,
		"interactable_true": interactable_true,
		"interactable_false": interactable_false,
		"drop_floor": drop_floor,
		"drop_overlay": drop_overlay,
		"drop_overlay_without_item": drop_overlay_without_item,
		"wall_block_item": wall_block_item,
		"wall_ore": wall_ore,
		"wall_synthetic_ore": wall_synthetic_ore,
		"wall_non_solid": wall_non_solid,
		"saves_floor": saves_floor,
		"saves_overlay": saves_overlay,
		"saves_block": saves_block,
		"saves_none": saves_none,
		"static_darkness": static_darkness,
		"synthetic_darkness": synthetic_darkness,
		"non_solid_darkness": non_solid_darkness,
		"darkness_leg_solid": darkness_leg_solid,
		"floor_leg_solid": floor_leg_solid,
		"open_leg_solid": open_leg_solid,
		"adjacent": adjacent,
		"non_adjacent": non_adjacent,
		"get_x_value": get_x_value,
		"get_y_value": get_y_value,
		"text_without_build": text_without_build,
		"text_with_build": text_with_build,
		"changed_method_during_generation": changed_method_during_generation,
		"pre_changed_no_build": pre_changed_no_build,
		"pre_changed_multiblock": pre_changed_multiblock,
		"pre_changed_generating": pre_changed_generating,
		"change_build_with_old": change_build_with_old,
		"change_build_no_old": change_build_no_old,
		"display_block": display_block,
		"display_overlay": display_overlay,
		"display_wall": display_wall,
		"display_floor": display_floor,
		"bulk_blocks": bulk_blocks,
		"bulk_floors": bulk_floors,
		"bulk_overlays": bulk_overlays,
		"single_floor": single_floor,
		"single_overlay": single_overlay,
		"single_remove": single_remove,
		"single_set_tile": single_set_tile,
		"single_set_tile_null": single_set_tile_null,
		"static_set_team": static_set_team,
		"static_set_team_null": static_set_team_null,
		"static_set_teams": static_set_teams,
		"static_set_teams_null": static_set_teams_null,
		"static_build_destroyed": static_build_destroyed,
		"static_build_destroyed_null": static_build_destroyed_null,
		"static_health_update": static_health_update,
		"changed_after_generation": changed_after_generation,
		"pre_changed_during_generation": pre_changed_during_generation,
		"pre_changed_after_generation": pre_changed_after_generation,
		"changed_with_build": changed_with_build,
		"changed_without_build": changed_without_build,
		"changed_during_generation": changed_during_generation,
		"packed_data": packed_data,
		"unpacked_data": unpacked_data,
		"canonical_pos": source_geometry.tile_pos_state(3, 4),
		"canonical_absolute_relative_odd": source_geometry.tile_absolute_relative_state(2, 4, 3, 4, 3),
		"canonical_absolute_relative_even": source_geometry.tile_absolute_relative_state(1, 4, 3, 4, 2),
		"canonical_storage_flammability": source_geometry.tile_flammability_state(false, false, 0.0, true, true, 2.0, 3.0, 2.0, true, 4.8, 30.0),
		"canonical_limited_area_inside": source_geometry.tile_in_map_area_state(4, 5, true, 2, 3, 2, 2),
		"canonical_is_center_self_build": source_geometry.tile_is_center_state(true, true),
		"canonical_center_coordinates": {
			"x": source_geometry.tile_center_x_state(9, true, 4),
			"y": source_geometry.tile_center_y_state(11, true, 6),
		},
		"canonical_team_id": source_geometry.tile_team_id_state(true, 5, 6),
		"canonical_team": source_geometry.tile_team_state(true, {"id": 5}, {"id": 6}),
		"canonical_is_darkened": source_geometry.tile_is_darkened_state(true),
		"canonical_set_team_without_build": source_geometry.tile_set_team_state(false, {"id": 7}),
		"canonical_set_team_with_build": source_geometry.tile_set_team_state(true, {"id": 7}),
		"canonical_overlay_id_state": source_geometry.tile_id_state("overlay", {"id": 12}),
		"canonical_block_id_state": source_geometry.tile_id_state("block", {"id": 13}),
		"canonical_floor_id_state": source_geometry.tile_id_state("floor", {"id": 14}),
		"canonical_passable_state": source_geometry.tile_passable_state(false, true, false, false, false, false),
		"canonical_blocked_by_floor_state": source_geometry.tile_passable_state(true, true, false, false, false, false),
		"canonical_synthetic_state": source_geometry.tile_synthetic_state(true, false),
		"canonical_solid_state": source_geometry.tile_solid_state(false, false, true, true),
		"canonical_breakable_state": source_geometry.tile_breakable_state(false, true, false),
		"canonical_dangerous_state": source_geometry.tile_dangerous_state(false, true, false),
		"canonical_packed_data": source_geometry.tile_packed_data_state(0x12345678, -2, 3, 4),
		"canonical_unpacked_data": source_geometry.tile_unpack_data_state(packed_data),
		"matches": pos_value == 196612 and negative_pos_value == -2 and array_value == 67 and left == 0 and up == 1 and odd_left == 0 and even_left == 0 and even_up == 1 and is_equal_approx(floor_flammability, 0.8) and is_equal_approx(storage_flammability, 1.6) and is_zero_approx(empty_flammability) and darkened and not not_darkened and set_team_without_build == {"build_present": false, "team": {"id": 7}, "team_call": null, "team_called": false} and set_team_with_build == {"build_present": true, "team": {"id": 7}, "team_call": {"call": "build.team(team);", "team": {"id": 7}}, "team_called": true} and overlay_id_state == {"kind": "overlay", "value": {"id": 12}, "id": 12} and block_id_state == {"kind": "block", "value": {"id": 13}, "id": 13} and floor_id_state == {"kind": "floor", "value": {"id": 14}, "id": 14} and passable_state and not blocked_by_floor_state and synthetic_state and solid_state and breakable_state and dangerous_state and linked_callback_tiles == [{"name": "northwest"}, {"name": "southwest"}, {"name": "northeast"}] and linked_sequence == linked_callback_tiles and linked_sequence_result == linked_callback_tiles and linked_as_sequence == linked_callback_tiles and linked_as_sequence_result == linked_callback_tiles and linked_as_callback == linked_callback_tiles and single_tile_sequence == [self_tile] and hitbox_state.get("center") == Vector2(25.5, 33.5) and is_equal_approx(float(hitbox_state.get("size", 0.0)), 16.0) and bounds_state.get("position") == Vector2(20.0, 28.0) and bounds_state.get("size") == Vector2(8.0, 8.0) and hitbox_delegate_state.get("set_centered") == hitbox_state.get("set_centered") and floor_value == {"id": "floor"} and block_value == {"id": "block"} and overlay_value == {"id": "overlay"} and cblock_value == {"id": "block"} and team_without_build == {"id": 6} and team_with_build == {"id": 5} and unrestricted_area and limited_area_inside and not limited_area_outside and center_without_build and center_self_build and not off_center_build and center_x_without_build == 9 and center_x_with_build == 4 and center_y_without_build == 11 and center_y_with_build == 6 and team_id_without_build == 6 and team_id_with_build == 5 and is_equal_approx(world_x, 24.0) and is_equal_approx(world_y, 32.0) and is_equal_approx(draw_x, 25.5) and is_equal_approx(draw_y, 33.5) and interactable_true and not interactable_false and drop_floor == {"id": "floor-item"} and drop_overlay == {"id": "overlay-item"} and drop_overlay_without_item == {"id": "floor-item"} and wall_block_item == {"id": "block-item"} and wall_ore == {"id": "ore-item"} and wall_synthetic_ore == null and wall_non_solid == null and saves_floor and saves_overlay and saves_block and not saves_none and static_darkness == 3 and synthetic_darkness == 0 and non_solid_darkness == 0 and darkness_leg_solid and floor_leg_solid and not open_leg_solid and adjacent and not non_adjacent and packed_data == 0x000403fe12345678 and unpacked_data == {"extra_data": 0x12345678, "data": -2, "floor_data": 3, "overlay_data": 4},
	}
	proof["matches"] = proof["matches"] and is_equal_approx(get_x_value, 25.5) and is_equal_approx(get_y_value, 33.5) and text_without_build == "stone:wall:ore[3,4] entity=null:derelict" and text_with_build == "stone:wall:ore[3,4] entity=TurretBuild:sharded" and changed_during_generation == {"world_generating": true, "event_fired": false, "event_call": null} and changed_after_generation == {"world_generating": false, "event_fired": true, "event_call": {"event": "tile-change"}} and pre_changed_during_generation == {"world_generating": true, "event_fired": false, "event_call": null} and pre_changed_after_generation == {"world_generating": false, "event_fired": true, "event_call": {"event": "tile-pre-change"}} and changed_with_build.get("build_update_proximity_called", false) and changed_with_build.get("nearby_proximity_updates", []).is_empty() and changed_with_build.get("recache_called", false) and changed_without_build.get("nearby_proximity_updates", []).size() == 1 and changed_without_build.get("fire_changed", {}).get("event_fired", false) and changed_method_during_generation.get("nearby_proximity_updates", []).is_empty() and not changed_method_during_generation.get("fire_changed", {}).get("event_fired", false) and changed_method_during_generation.get("recache_called", false) and pre_changed_no_build.get("fire_pre_changed", {}).get("event_fired", false) and not pre_changed_no_build.get("build_on_removed_called", false) and pre_changed_multiblock.get("build_on_removed_called", false) and pre_changed_multiblock.get("build_remove_from_proximity_called", false) and pre_changed_multiblock.get("multiblock_reset_tiles", []).size() == 2 and pre_changed_multiblock.get("multiblock_pre_change_calls", []).size() == 2 and pre_changed_multiblock.get("multiblock_changed_calls", []).size() == 2 and not pre_changed_generating.get("fire_pre_changed", {}).get("event_fired", false) and pre_changed_generating.get("multiblock_pre_change_calls", []).size() == 1 and pre_changed_generating.get("multiblock_changed_calls", []).size() == 1
	proof["matches"] = proof["matches"] and set_floor_same.get("same_floor", false) and not set_floor_same.get("recache_called", true) and set_floor_full.get("remove_floor_index", false) and set_floor_full.get("recache_called", false) and set_floor_full.get("build_proximity_updated", false) and set_floor_full.get("pathfinder_updated", false) and set_floor_full.get("event_fired", false) and set_floor_full.get("floor_changed_called", false) and set_floor_full.get("calls", []).size() == 8 and not set_floor_generating.get("remove_floor_index", true) and not set_floor_generating.get("pathfinder_updated", true) and not set_floor_generating.get("event_fired", true) and set_floor_generating.get("build_proximity_updated", false)
	proof["matches"] = proof["matches"] and set_air.get("delegate") == "setBlock(Blocks.air);" and set_air.get("block") == {"id": "air"}
	proof["matches"] = proof["matches"] and editor_tile.get("value", true) == false and editor_tile.get("return") == "return false;"
	proof["matches"] = proof["matches"] and floor_color.get("value") == "floor-color" and floor_color.get("return") == "return floor.getColor(this);"
	proof["matches"] = proof["matches"] and recache_wall.get("guard_passes", false) and recache_wall.get("recache_wall_called", false) and not recache_wall_generating.get("guard_passes", true) and recache.get("self_calls", []).size() == 4 and recache.get("neighbors", []).size() == 2 and recache.get("neighbor_floor_calls", []).size() == 2 and not recache_generating.get("guard_passes", true)
	proof["matches"] = proof["matches"] and remove_tile.get("delegate") == "setBlock(Blocks.air);" and remove_tile.get("block") == {"id": "air"}
	proof["matches"] = proof["matches"] and remove_net.get("call") == "Call.removeTile(this);" and set_net_default.get("call") == "Call.setTile(this, block, Team.derelict, 0);" and set_net.get("call") == "Call.setTile(this, block, team, rotation);" and set_net.get("rotation") == 3 and set_floor_net.get("call") == "Call.setFloor(this, floor, overlay);" and set_floor_net_default.get("delegate") == "setFloorNet(floor, Blocks.air);" and set_overlay_net.get("call") == "Call.setOverlay(this, overlay);"
	proof["matches"] = proof["matches"] and set_overlay.get("operation") == "set_overlay" and set_overlay.get("event_fired", false) and set_overlay.get("proximity_updated", false) and set_overlay.get("calls", []).size() == 5 and set_overlay_same.get("same_overlay", false) and set_overlay_same.get("calls", []).size() == 1 and set_overlay_quiet.get("operation") == "set_overlay_quiet" and set_overlay_quiet.get("calls", []).size() == 1 and clear_overlay.get("operation") == "clear_overlay" and clear_overlay.get("overlay") == {"id": "air"}
	proof["matches"] = proof["matches"] and circle_int.get("operation") == "int" and circle_int.get("points", []).size() > 0 and circle_points == circle_int.get("points", []) and circle_tile.get("operation") == "tile" and circle_tile.get("tiles", []).size() == circle_tile.get("points", []).size() and circle_tiles == circle_tile.get("tiles", [])
	proof["matches"] = proof["matches"] and change_build_with_old.get("old_build_removed", false) and change_build_with_old.get("build_cleared", false) and change_build_with_old.get("edge_proximity_update_count", 2) == 2 and change_build_with_old.get("entity_init_called", false) and change_build_with_old.get("init_update", false) and change_build_with_old.get("entity_init_result") == {"id": "new-build"} and not change_build_no_old.get("old_build_removed", false) and change_build_no_old.get("edge_proximity_update_count", 0) == 0 and not change_build_no_old.get("entity_init_called", false)
	proof["matches"] = proof["matches"] and display_block.get("selected_kind") == "block" and display_overlay.get("selected_kind") == "overlay" and display_wall.get("selected_kind") == "overlay" and display_floor.get("selected_kind") == "floor" and display_block.get("display_icon") == "block-icon" and display_floor.get("display_name") == "Floor Name" and display_block.get("table_calls", []).size() == 5
	proof["matches"] = proof["matches"] and bulk_blocks.get("operation") == "set_block" and bulk_blocks.get("mutations", []).size() == 2 and bulk_blocks.get("mutations", [])[0].get("rotation", -1) == 0 and bulk_floors.get("operation") == "set_floor" and bulk_floors.get("mutations", []).size() == 1 and bulk_overlays.get("operation") == "set_overlay" and bulk_overlays.get("mutations", []).size() == 1
	proof["matches"] = proof["matches"] and single_floor.get("calls", []).size() == 2 and single_overlay.get("calls", []).size() == 1 and single_remove.get("calls", []).size() == 1 and single_set_tile.get("calls", []).size() == 1 and single_set_tile.get("calls", [])[0].get("rotation") == 3 and not single_set_tile_null.get("guard_passes", true)
	proof["matches"] = proof["matches"] and static_set_team.get("calls", []).size() == 1 and static_set_team.get("calls", [])[0].get("call") == "build.changeTeam(team);" and not static_set_team_null.get("guard_passes", true) and static_set_teams.get("calls", []).size() == 4 and static_set_teams.get("mutations", []).size() == 2 and not static_set_teams_null.get("guard_passes", true) and static_build_destroyed.get("calls", []).size() == 1 and static_build_destroyed.get("calls", [])[0].get("call") == "build.killed();" and not static_build_destroyed_null.get("guard_passes", true) and static_health_update.get("mutations", []).size() == 1
	proof["matches"] = proof["matches"] and set_block_default.get("delegate") == "setBlock(type, team, rotation, type::newBuilding);" and set_block_team.get("delegate") == "setBlock(type, team, 0);" and set_block_type.get("delegate") == "setBlock(type, Team.derelict, 0);" and set_block_main.get("normalized_rotation") == 1 and set_block_main.get("effective_team") == {"id": 9} and set_block_main.get("recache_required", false) and set_block_main.get("first_pass", []).size() == 2 and set_block_main.get("second_pass", []).size() == 2 and set_block_main.get("calls", []).size() == 11 and set_block_main.get("calls", [])[0].get("call") == "changing = true;" and set_block_main.get("calls", [])[1].get("recache_wall") == "recacheWall();" and set_block_main.get("calls", [])[2].get("call") == "if(type.forceTeam != null) team = type.forceTeam;" and set_block_main.get("calls", [])[5].get("rotation") == 1 and set_block_main.get("calls", [])[7].get("first_pass", []).size() == 2 and set_block_main.get("calls", [])[8].get("call") == "changed();" and set_block_main.get("calls", [])[9].get("call") == "changing = false;" and set_block_main.get("calls", [])[10].get("call") == "block.blockChanged(this);"
	runtime_proof_state.write_proof("TileModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
