class_name SourceBlockGeometry
extends RefCounted

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_tile_set_block_source_text_state := preload("res://src/game/SourceTileSetBlockSourceTextState.gd")
const source_tile_set_floor_source_text_state := preload("res://src/game/SourceTileSetFloorSourceTextState.gd")
const source_tile_editor_source_text_state := preload("res://src/game/SourceTileEditorSourceTextState.gd")
const source_tile_floor_color_source_text_state := preload("res://src/game/SourceTileFloorColorSourceTextState.gd")
const source_tile_recache_source_text_state := preload("res://src/game/SourceTileRecacheSourceTextState.gd")
const source_tile_network_mutation_source_text_state := preload("res://src/game/SourceTileNetworkMutationSourceTextState.gd")
const source_tile_overlay_mutation_source_text_state := preload("res://src/game/SourceTileOverlayMutationSourceTextState.gd")
const source_tile_circle_source_text_state := preload("res://src/game/SourceTileCircleSourceTextState.gd")
const source_block_plan_geometry_state := preload("res://src/game/SourceBlockPlanGeometryState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_HIT_SIZE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_HIT_SIZE_JAVA_METHOD
const SOURCE_BUILDING_HIT_SIZE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_HIT_SIZE_GENERATED_OWNER
const SOURCE_BUILDING_HITBOX_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_HITBOX_JAVA_METHOD
const SOURCE_BUILDING_HITBOX_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_HITBOX_GENERATED_OWNER
const SOURCE_BUILDING_HITBOX_METHOD := source_building_source_text_state.SOURCE_BUILDING_HITBOX_METHOD
const SOURCE_BUILDING_HITBOX_SET_CENTERED_EXPR := source_building_source_text_state.SOURCE_BUILDING_HITBOX_SET_CENTERED_EXPR
const SOURCE_BUILDING_HITBOX_SIZE_EXPR := source_building_source_text_state.SOURCE_BUILDING_HITBOX_SIZE_EXPR

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func block_world_size(block_size: int, tile_size: int) -> float:
	return float(max(source_block_defaults.SIZE_DEFAULT, block_size)) * float(tile_size)


static func block_base_position(grid_world: Vector2, block_size: int, tile_size: int) -> Vector2:
	var safe_block_size: int = max(source_block_defaults.SIZE_DEFAULT, block_size)
	var offset := float(safe_block_size - 1) * float(tile_size) * 0.5
	return grid_world + Vector2(offset, offset)


static func tile_pos_state(x: int, y: int) -> int:
	var packed := ((x & 0xffff) << 16) | (y & 0xffff)
	return packed - 0x100000000 if packed >= 0x80000000 else packed


static func tile_array_state(x: int, y: int, world_width: int) -> int:
	return x + y * world_width


static func tile_relative_cardinal_state(x: int, y: int, cx: int, cy: int) -> int:
	if x == cx and y == cy - 1:
		return 1
	if x == cx and y == cy + 1:
		return 3
	if x == cx - 1 and y == cy:
		return 0
	if x == cx + 1 and y == cy:
		return 2
	return -1


static func tile_relative_float_state(x: float, y: float, cx: float, cy: float) -> int:
	if abs(x - cx) > abs(y - cy):
		if x <= cx - 1.0:
			return 0
		if x >= cx + 1.0:
			return 2
	else:
		if y <= cy - 1.0:
			return 1
		if y >= cy + 1.0:
			return 3
	return -1


static func tile_absolute_relative_state(x: int, y: int, cx: int, cy: int, block_size: int) -> int:
	if block_size % 2 == 1:
		if abs(x - cx) > abs(y - cy):
			if x <= cx - 1:
				return 0
			if x >= cx + 1:
				return 2
		else:
			if y <= cy - 1:
				return 1
			if y >= cy + 1:
				return 3
	else:
		if abs(x - cx + 0.5) > abs(y - cy + 0.5):
			if x + 0.5 <= cx - 1:
				return 0
			if x + 0.5 >= cx + 1:
				return 2
		else:
			if y + 0.5 <= cy - 1:
				return 1
			if y + 0.5 >= cy + 1:
				return 3
	return -1


static func tile_flammability_state(block_is_air: bool, floor_liquid_drop_present: bool, floor_liquid_flammability: float, build_present: bool, block_has_items: bool, build_items_total: float, item_flammability_sum: float, block_item_capacity: float, block_has_liquids: bool, liquid_flammability_sum: float, block_liquid_capacity: float) -> float:
	if block_is_air:
		return floor_liquid_flammability if floor_liquid_drop_present else 0.0
	if not build_present:
		return 0.0
	var result := 0.0
	if block_has_items and build_items_total > 0.0:
		result += item_flammability_sum / max(block_item_capacity, 1.0) * clamp(block_item_capacity / 2.4, 1.0, 3.0)
	if block_has_liquids:
		result += (liquid_flammability_sum / 1.6) / max(block_liquid_capacity, 1.0) * clamp(block_liquid_capacity / 30.0, 1.0, 2.0)
	return result


static func tile_in_map_area_state(x: int, y: int, limit_map_area: bool, limit_x: int, limit_y: int, limit_width: int, limit_height: int) -> bool:
	return not limit_map_area or (limit_x <= x and limit_x + limit_width >= x and limit_y <= y and limit_y + limit_height >= y)


static func tile_is_center_state(build_present: bool, build_tile_is_self: bool) -> bool:
	return not build_present or build_tile_is_self


static func tile_center_x_state(x: int, build_present: bool, build_tile_x: int) -> int:
	return build_tile_x if build_present else x


static func tile_center_y_state(y: int, build_present: bool, build_tile_y: int) -> int:
	return build_tile_y if build_present else y


static func tile_team_id_state(build_present: bool, build_team_id: int, derelict_team_id: int) -> int:
	return build_team_id if build_present else derelict_team_id


static func tile_reference_state(value: Variant) -> Variant:
	return value


static func tile_team_state(build_present: bool, build_team: Variant, derelict_team: Variant) -> Variant:
	return build_team if build_present else derelict_team


static func tile_is_darkened_state(block_is_darkened: bool) -> bool:
	return block_is_darkened


static func tile_set_team_state(build_present: bool, team: Variant) -> Dictionary:
	return {
		"build_present": build_present,
		"team": team,
		"team_call": {"call": "build.team(team);", "team": team} if build_present else null,
		"team_called": build_present,
	}


static func tile_set_block_delegate_state(overload: String, type_value: Variant, team_value: Variant, rotation_value: int, entityprov_value: Variant = null) -> Dictionary:
	var delegate := ""
	match overload:
		"type_team_rotation":
			delegate = source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_DEFAULT_DELEGATE_EXPR
		"type_team":
			delegate = source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_TEAM_DELEGATE_EXPR
		"type":
			delegate = source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_TYPE_DELEGATE_EXPR
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_SET_BLOCK_STATE,
		"source": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_SOURCE,
		"overload": overload,
		"delegate": delegate,
		"type": type_value,
		"team": team_value,
		"rotation": rotation_value,
		"entityprov": entityprov_value,
	}


static func tile_set_air_state(air_block: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_SET_BLOCK_STATE,
		"source": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_SOURCE,
		"method": source_tile_set_block_source_text_state.SOURCE_TILE_SET_AIR_METHOD,
		"delegate": source_tile_set_block_source_text_state.SOURCE_TILE_SET_AIR_DELEGATE_EXPR,
		"block": air_block,
	}


static func tile_remove_state(air_block: Variant) -> Dictionary:
	var state := tile_set_air_state(air_block)
	state["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_SET_BLOCK_STATE
	state["method"] = source_tile_set_block_source_text_state.SOURCE_TILE_REMOVE_METHOD
	state["delegate"] = source_tile_set_block_source_text_state.SOURCE_TILE_REMOVE_DELEGATE_EXPR
	return state


static func tile_set_block_state(world_generating: bool, type_value: Variant, team_value: Variant, rotation_value: int, entityprov_value: Variant, type_static: bool, previous_block_static: bool, force_team_present: bool, force_team_value: Variant, build_present: bool, previous_build_multiblock: bool, previous_multiblock_tiles: Array, self_tile: Variant, new_build_present: bool, block_update: bool, editor_state: bool, entity_init_result: Variant, new_block_multiblock: bool, new_block_size: int, new_multiblock_tiles: Array, block_changed_call: Variant) -> Dictionary:
	var effective_team: Variant = force_team_value if force_team_present else team_value
	var normalized_rotation := posmod(rotation_value, 4)
	var recache_required := type_static or previous_block_static
	var pre_changed := tile_pre_changed_state(world_generating, build_present, previous_build_multiblock, previous_multiblock_tiles, self_tile, null, null)
	var change_build := tile_change_build_state(build_present, 0, null, [], new_build_present, effective_team, normalized_rotation, editor_state, block_update, entity_init_result)
	var first_pass: Array = []
	var second_pass: Array = []
	if new_block_multiblock:
		for other in new_multiblock_tiles:
			if other == null or other == self_tile:
				continue
			first_pass.append({"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_FIRST_PASS_EXPR, "tile": other})
			second_pass.append({"build_call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_SECOND_PASS_BUILD_EXPR, "block_call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_SECOND_PASS_BLOCK_EXPR, "tile": other})
	var calls: Array = [
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_CHANGING_EXPR},
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_RECACHE_EXPR, "recache_wall": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_RECACHE_WALL_EXPR} if recache_required else null,
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_FORCE_TEAM_EXPR, "team": effective_team} if force_team_present else null,
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_PRE_CHANGED_EXPR, "state": pre_changed},
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_ASSIGN_BLOCK_EXPR, "block": type_value},
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_CHANGE_BUILD_EXPR, "state": change_build, "rotation": normalized_rotation},
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_BUILD_TEAM_EXPR, "team": effective_team} if new_build_present else null,
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_MULTIBLOCK_GUARD_EXPR, "size": new_block_size, "first_pass": first_pass, "second_pass": second_pass} if new_block_multiblock else null,
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_CHANGED_EXPR},
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_RESET_CHANGING_EXPR},
		{"call": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_BLOCK_CHANGED_EXPR, "block": type_value, "callback": block_changed_call},
	]
	var filtered_calls: Array = []
	for call in calls:
		if call != null:
			filtered_calls.append(call)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_SET_BLOCK_STATE,
		"source": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_SOURCE,
		"method": source_tile_set_block_source_text_state.SOURCE_TILE_SET_BLOCK_METHOD,
		"world_generating": world_generating,
		"type": type_value,
		"team": team_value,
		"effective_team": effective_team,
		"rotation": rotation_value,
		"normalized_rotation": normalized_rotation,
		"entityprov": entityprov_value,
		"type_static": type_static,
		"previous_block_static": previous_block_static,
		"recache_required": recache_required,
		"force_team_present": force_team_present,
		"build_present": build_present,
		"new_build_present": new_build_present,
		"new_block_multiblock": new_block_multiblock,
		"new_block_size": new_block_size,
		"first_pass": first_pass,
		"second_pass": second_pass,
		"calls": filtered_calls,
		"pre_changed": pre_changed,
		"change_build": change_build,
		"block_changed_call": block_changed_call,
	}


static func tile_floor_assignment_state(type_value: Variant, previous_floor: Variant, build_present: bool) -> Dictionary:
	var same_floor: bool = type_value == previous_floor
	return {"same_floor": same_floor, "floor": previous_floor if same_floor else type_value, "build_proximity_updated": not same_floor and build_present}

static func tile_set_floor_state(type_value: Variant, previous_floor: Variant, headless: bool, world_generating: bool, editor_tile: bool, build_present: bool, pathfinder_present: bool, state_editor: bool, tile_value: Variant, floor_change_event: Variant, floor_changed_call: Variant) -> Dictionary:
	var assignment := tile_floor_assignment_state(type_value, previous_floor, build_present)
	var same_floor: bool = assignment["same_floor"]
	var remove_floor_index: bool = not same_floor and not headless and not world_generating and not editor_tile
	var update_pathfinder: bool = not same_floor and not world_generating and pathfinder_present and not state_editor
	var fire_event: bool = not same_floor and not world_generating
	var calls: Array = []
	if same_floor:
		calls.append({"call": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_SAME_GUARD_EXPR, "returned": true})
	else:
		calls = [
			{"call": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_PREVIOUS_FLOOR_EXPR, "previous_floor": previous_floor},
			{"call": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_ASSIGN_EXPR, "floor": type_value},
			{"call": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_REMOVE_INDEX_EXPR} if remove_floor_index else null,
			{"call": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_RECACHE_EXPR},
			{"call": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_BUILD_PROXIMITY_EXPR} if build_present else null,
			{"call": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_PATHFINDER_EXPR} if update_pathfinder else null,
			{"call": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_EVENT_EXPR, "event": floor_change_event} if fire_event else null,
			{"call": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_CHANGED_EXPR, "callback": floor_changed_call},
		]
		calls = calls.filter(func(call: Variant) -> bool: return call != null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_SET_FLOOR_STATE,
		"source": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_SOURCE,
		"method": source_tile_set_floor_source_text_state.SOURCE_TILE_SET_FLOOR_METHOD,
		"type": type_value,
		"previous_floor": previous_floor,
		"same_floor": same_floor,
		"floor": assignment["floor"],
		"remove_floor_index": remove_floor_index,
		"recache_called": not same_floor,
		"build_proximity_updated": assignment["build_proximity_updated"],
		"pathfinder_updated": update_pathfinder,
		"event_fired": fire_event,
		"floor_changed_called": not same_floor,
		"tile": tile_value,
		"calls": calls,
	}


static func tile_editor_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_EDITOR_STATE,
		"source": source_tile_editor_source_text_state.SOURCE_TILE_EDITOR_SOURCE,
		"method": source_tile_editor_source_text_state.SOURCE_TILE_EDITOR_METHOD,
		"value": false,
		"return": source_tile_editor_source_text_state.SOURCE_TILE_EDITOR_RETURN_EXPR,
	}


static func tile_floor_color_state(floor_color: Variant, tile_value: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_FLOOR_COLOR_STATE,
		"source": source_tile_floor_color_source_text_state.SOURCE_TILE_FLOOR_COLOR_SOURCE,
		"method": source_tile_floor_color_source_text_state.SOURCE_TILE_FLOOR_COLOR_METHOD,
		"floor": floor_color,
		"tile": tile_value,
		"return": source_tile_floor_color_source_text_state.SOURCE_TILE_FLOOR_COLOR_EXPR,
		"value": floor_color,
	}


static func tile_recache_wall_state(headless: bool, world_generating: bool, tile_value: Variant) -> Dictionary:
	var guard_passes: bool = not headless and not world_generating
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_RECACHE_WALL_STATE,
		"source": source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_SOURCE,
		"method": source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_WALL_METHOD,
		"guard_passes": guard_passes,
		"recache_wall_called": guard_passes,
		"tile": tile_value,
		"call": source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_WALL_EXPR if guard_passes else null,
	}


static func tile_recache_state(headless: bool, world_generating: bool, tile_value: Variant, neighbor_tiles: Array) -> Dictionary:
	var guard_passes: bool = not headless and not world_generating
	var neighbors: Array = []
	var neighbor_floor_calls: Array = []
	if guard_passes:
		for neighbor in neighbor_tiles:
			if neighbor != null:
				neighbors.append(neighbor)
				neighbor_floor_calls.append(source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_NEIGHBOR_FLOOR_EXPR)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_RECACHE_STATE,
		"source": source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_SOURCE,
		"method": source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_METHOD,
		"guard_passes": guard_passes,
		"recache_called": guard_passes,
		"tile": tile_value,
		"self_calls": [source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_FLOOR_EXPR, source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_MINIMAP_EXPR, source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_INVALIDATE_EXPR, source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_ADD_FLOOR_INDEX_EXPR] if guard_passes else [],
		"neighbor_loop": source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_NEIGHBOR_LOOP_EXPR if guard_passes else null,
		"neighbor_lookup": source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_NEIGHBOR_LOOKUP_EXPR if guard_passes else null,
		"neighbor_guard": source_tile_recache_source_text_state.SOURCE_TILE_RECACHE_NEIGHBOR_GUARD_EXPR if guard_passes else null,
		"neighbor_floor_calls": neighbor_floor_calls,
		"neighbors": neighbors,
	}


static func tile_network_mutation_state(operation: String, tile_value: Variant, block_value: Variant = null, team_value: Variant = null, rotation_value: int = 0, floor_value: Variant = null, overlay_value: Variant = null) -> Dictionary:
	var call_expr := ""
	var delegate_expr := ""
	match operation:
		"remove_net":
			call_expr = source_tile_network_mutation_source_text_state.SOURCE_TILE_REMOVE_NET_EXPR
		"set_net":
			call_expr = source_tile_network_mutation_source_text_state.SOURCE_TILE_SET_NET_ROTATED_EXPR
		"set_net_default":
			call_expr = source_tile_network_mutation_source_text_state.SOURCE_TILE_SET_NET_DEFAULT_EXPR
		"set_floor_net":
			call_expr = source_tile_network_mutation_source_text_state.SOURCE_TILE_SET_FLOOR_NET_EXPR
		"set_floor_net_default":
			delegate_expr = source_tile_network_mutation_source_text_state.SOURCE_TILE_SET_FLOOR_NET_DEFAULT_EXPR
		"set_overlay_net":
			call_expr = source_tile_network_mutation_source_text_state.SOURCE_TILE_SET_OVERLAY_NET_EXPR
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_NETWORK_MUTATION_STATE,
		"source": source_tile_network_mutation_source_text_state.SOURCE_TILE_NETWORK_MUTATION_SOURCE,
		"operation": operation,
		"tile": tile_value,
		"block": block_value,
		"team": team_value,
		"rotation": rotation_value,
		"floor": floor_value,
		"overlay": overlay_value,
		"call": call_expr if not call_expr.is_empty() else null,
		"delegate": delegate_expr if not delegate_expr.is_empty() else null,
	}


static func tile_overlay_mutation_state(operation: String, block_value: Variant, previous_overlay: Variant = null, headless: bool = false, world_generating: bool = false, build_present: bool = false, overlay_change_event: Variant = null, overlay_value: Variant = null) -> Dictionary:
	var same_overlay: bool = operation == "set_overlay" and block_value == previous_overlay
	var event_fired: bool = operation == "set_overlay" and not same_overlay and not world_generating
	var proximity_updated: bool = event_fired and build_present
	var calls: Array = []
	match operation:
		"set_overlay":
			if same_overlay:
				calls.append({"call": source_tile_overlay_mutation_source_text_state.SOURCE_TILE_SET_OVERLAY_SAME_GUARD_EXPR, "returned": true})
			else:
				calls = [
					{"call": source_tile_overlay_mutation_source_text_state.SOURCE_TILE_SET_OVERLAY_PREVIOUS_EXPR, "previous_overlay": previous_overlay},
					{"call": source_tile_overlay_mutation_source_text_state.SOURCE_TILE_SET_OVERLAY_ASSIGN_EXPR, "overlay": block_value},
					{"call": source_tile_overlay_mutation_source_text_state.SOURCE_TILE_SET_OVERLAY_RECACHE_EXPR},
					{"call": source_tile_overlay_mutation_source_text_state.SOURCE_TILE_SET_OVERLAY_EVENT_EXPR, "event": overlay_change_event} if event_fired else null,
					{"call": source_tile_overlay_mutation_source_text_state.SOURCE_TILE_SET_OVERLAY_PROXIMITY_EXPR} if proximity_updated else null,
				]
		"set_overlay_quiet":
			calls = [{"call": source_tile_overlay_mutation_source_text_state.SOURCE_TILE_SET_OVERLAY_QUIET_ASSIGN_EXPR, "overlay": block_value}]
		"clear_overlay":
			calls = [{"call": source_tile_overlay_mutation_source_text_state.SOURCE_TILE_CLEAR_OVERLAY_DELEGATE_EXPR, "block": overlay_value}]
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_OVERLAY_MUTATION_STATE,
		"source": source_tile_overlay_mutation_source_text_state.SOURCE_TILE_OVERLAY_MUTATION_SOURCE,
		"operation": operation,
		"block": block_value,
		"previous_overlay": previous_overlay,
		"overlay": block_value if operation != "clear_overlay" else overlay_value,
		"same_overlay": same_overlay,
		"headless": headless,
		"world_generating": world_generating,
		"build_present": build_present,
		"event_fired": event_fired,
		"proximity_updated": proximity_updated,
		"overlay_change_event": overlay_change_event,
		"calls": calls.filter(func(call: Variant) -> bool: return call != null),
	}


static func tile_circle_state(operation: String, x: int, y: int, radius: int, width: int, height: int, world_tile_lookup: Variant, consumer: Variant) -> Dictionary:
	var points: Array = []
	var tiles: Array = []
	var safe_radius: int = maxi(radius, 0)
	for px in range(max(x - safe_radius, 0), min(x + safe_radius, width - 1) + 1):
		for py in range(max(y - safe_radius, 0), min(y + safe_radius, height - 1) + 1):
			if Vector2(px - x, py - y).length() <= safe_radius:
				points.append({"x": px, "y": py})
				if operation == "int" and consumer is Callable:
					consumer.call(px, py)
				if operation == "tile":
					var tile_value: Variant = world_tile_lookup.call(px, py) if world_tile_lookup is Callable else null
					tiles.append(tile_value)
					if consumer is Callable:
						consumer.call(tile_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TILE_CIRCLE_STATE,
		"source": source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_SOURCE,
		"geometry_source": source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_GEOMETRY_SOURCE,
		"operation": operation,
		"method": source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_TILE_METHOD if operation == "tile" else source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_INT_METHOD,
		"geometry_loop_expr": source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_LOOP_EXPR,
		"geometry_inner_loop_expr": source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_INNER_LOOP_EXPR,
		"geometry_guard_expr": source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_GUARD_EXPR,
		"consume_expr": source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_CONSUME_EXPR,
		"delegate_expr": source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_TILE_EXPR if operation == "tile" else source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_INT_EXPR,
		"raw_tile_expr": source_tile_circle_source_text_state.SOURCE_TILE_CIRCLE_RAW_TILE_EXPR if operation == "tile" else null,
		"x": x, "y": y, "radius": radius, "width": width, "height": height,
		"points": points, "tiles": tiles, "consumer": consumer,
	}


static func tile_id_state(kind: String, value: Variant) -> Dictionary:
	var value_id: Variant = value.get("id", null) if value is Dictionary else null
	return {"kind": kind, "value": value, "id": value_id}


static func tile_passable_state(floor_solid: bool, block_is_air: bool, block_solidifies: bool, block_solid: bool, block_destructible: bool, block_update: bool) -> bool:
	return not ((floor_solid and (block_is_air or block_solidifies)) or (block_solid and (not block_destructible and not block_update)))


static func tile_synthetic_state(block_update: bool, block_destructible: bool) -> bool:
	return block_update or block_destructible


static func tile_solid_state(block_solid: bool, floor_solid: bool, build_present: bool, build_check_solid: bool) -> bool:
	return block_solid or floor_solid or (build_present and build_check_solid)


static func tile_breakable_state(block_destructible: bool, block_breakable: bool, block_update: bool) -> bool:
	return block_destructible or block_breakable or block_update


static func tile_dangerous_state(block_solid: bool, floor_is_deep: bool, floor_damages: bool) -> bool:
	return not block_solid and (floor_is_deep or floor_damages)


static func _tile_lookup_state(world_tile_lookup: Variant, x: int, y: int) -> Variant:
	if world_tile_lookup is Callable:
		return world_tile_lookup.call(x, y)
	return null


static func tile_get_linked_tiles_state(block_is_multiblock: bool, block_size: int, size_offset: int, x: int, y: int, world_tile_lookup: Variant, self_tile: Variant, consumer: Variant) -> Variant:
	if block_is_multiblock:
		for dx in range(block_size):
			for dy in range(block_size):
				var other: Variant = _tile_lookup_state(world_tile_lookup, x + dx + size_offset, y + dy + size_offset)
				if other != null and consumer is Callable:
					consumer.call(other)
	elif consumer is Callable:
		consumer.call(self_tile)
	return null


static func tile_get_linked_tiles_array_state(block_is_multiblock: bool, block_size: int, size_offset: int, x: int, y: int, world_tile_lookup: Variant, self_tile: Variant, tmp_array: Array) -> Array:
	tmp_array.clear()
	var append_tile := func(other: Variant) -> void:
		tmp_array.append(other)
	tile_get_linked_tiles_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, append_tile)
	return tmp_array


static func tile_get_linked_tiles_as_array_state(block_is_multiblock: bool, block_size: int, size_offset: int, x: int, y: int, world_tile_lookup: Variant, self_tile: Variant, tmp_array: Array) -> Array:
	return tile_get_linked_tiles_array_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, tmp_array)


static func tile_get_linked_tiles_as_state(block_is_multiblock: bool, block_size: int, size_offset: int, x: int, y: int, world_tile_lookup: Variant, self_tile: Variant, consumer: Variant) -> Variant:
	return tile_get_linked_tiles_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, consumer)


static func tile_get_hitbox_state(x: int, y: int, block_size: int, tilesize: float, block_offset: float, rect_value: Variant = null) -> Dictionary:
	var size_in_world: float = float(block_size) * tilesize
	var center := Vector2(float(x) * tilesize + block_offset, float(y) * tilesize + block_offset)
	return {"rect": rect_value, "center": center, "size": size_in_world, "set_centered": {"x": center.x, "y": center.y, "width": size_in_world, "height": size_in_world}}


static func tile_get_bounds_state(x: int, y: int, tilesize: float, rect_value: Variant = null) -> Dictionary:
	var half_tile: float = tilesize / 2.0
	var position := Vector2(float(x) * tilesize - half_tile, float(y) * tilesize - half_tile)
	return {"rect": rect_value, "position": position, "size": Vector2(tilesize, tilesize), "set": {"x": position.x, "y": position.y, "width": tilesize, "height": tilesize}}


static func tile_hitbox_state(x: int, y: int, block_size: int, tilesize: float, block_offset: float, rect_value: Variant = null) -> Dictionary:
	return tile_get_hitbox_state(x, y, block_size, tilesize, block_offset, rect_value)


static func tile_nearby_relative_state(x: int, y: int, relative_x: int, relative_y: int, world_tile_lookup: Variant) -> Variant:
	return _tile_lookup_state(world_tile_lookup, x + relative_x, y + relative_y)


static func tile_nearby_delta_state(x: int, y: int, delta_x: int, delta_y: int, world_tile_lookup: Variant) -> Variant:
	return _tile_lookup_state(world_tile_lookup, x + delta_x, y + delta_y)


static func tile_nearby_rotation_state(x: int, y: int, rotation: int, world_tile_lookup: Variant) -> Variant:
	match rotation:
		0:
			return _tile_lookup_state(world_tile_lookup, x + 1, y)
		1:
			return _tile_lookup_state(world_tile_lookup, x, y + 1)
		2:
			return _tile_lookup_state(world_tile_lookup, x - 1, y)
		3:
			return _tile_lookup_state(world_tile_lookup, x, y - 1)
	return null


static func tile_nearby_build_rotation_state(x: int, y: int, rotation: int, world_build_lookup: Variant) -> Variant:
	match rotation:
		0:
			return _tile_lookup_state(world_build_lookup, x + 1, y)
		1:
			return _tile_lookup_state(world_build_lookup, x, y + 1)
		2:
			return _tile_lookup_state(world_build_lookup, x - 1, y)
		3:
			return _tile_lookup_state(world_build_lookup, x, y - 1)
	return null


static func tile_interactable_state(can_interact: bool) -> bool:
	return can_interact


static func tile_drop_state(overlay_is_air: bool, overlay_item_drop: Variant, floor_item_drop: Variant) -> Variant:
	return floor_item_drop if overlay_is_air or overlay_item_drop == null else overlay_item_drop


static func tile_wall_drop_state(block_solid: bool, block_item_drop: Variant, overlay_wall_ore: bool, block_synthetic: bool, overlay_item_drop: Variant) -> Variant:
	if not block_solid:
		return null
	if block_item_drop != null:
		return block_item_drop
	if overlay_wall_ore and not block_synthetic:
		return overlay_item_drop
	return null


static func tile_should_save_data_state(floor_save_data: bool, overlay_save_data: bool, block_save_data: bool) -> bool:
	return floor_save_data or overlay_save_data or block_save_data


static func tile_static_darkness_state(block_solid: bool, block_fills_tile: bool, block_synthetic: bool, data: int) -> int:
	return data if block_solid and block_fills_tile and not block_synthetic else 0


static func tile_leg_solid_state(static_darkness: int, floor_solid: bool, block_is_air: bool) -> bool:
	return static_darkness >= 2 or (floor_solid and block_is_air)


static func tile_adjacent_state(relative_result: int) -> bool:
	return relative_result != -1


static func tile_packed_data_state(extra_data: int, data: int, floor_data: int, overlay_data: int) -> int:
	return (int(extra_data) & 0xffffffff) | ((int(data) & 0xff) << 32) | ((int(floor_data) & 0xff) << 40) | ((int(overlay_data) & 0xff) << 48)


static func _tile_signed_byte(value: int) -> int:
	var normalized := value & 0xff
	return normalized - 256 if normalized >= 128 else normalized


static func tile_unpack_data_state(packed: int) -> Dictionary:
	return {
		"extra_data": int(packed & 0xffffffff),
		"data": _tile_signed_byte(int((packed >> 32) & 0xff)),
		"floor_data": _tile_signed_byte(int((packed >> 40) & 0xff)),
		"overlay_data": _tile_signed_byte(int((packed >> 48) & 0xff)),
	}


static func tile_coordinate_display_state(draw_coordinate: float) -> float:
	return draw_coordinate


static func tile_to_string_state(floor_name: String, block_name: String, overlay_text: String, x: int, y: int, build_present: bool, build_class_name: String, team_text: String) -> String:
	var entity_text := build_class_name if build_present else "null"
	return floor_name + ":" + block_name + ":" + overlay_text + "[" + str(x) + "," + str(y) + "] entity=" + entity_text + ":" + team_text


static func tile_fire_change_state(world_generating: bool, event_call: Variant) -> Dictionary:
	var event_fired := not world_generating
	return {
		"world_generating": world_generating,
		"event_fired": event_fired,
		"event_call": event_call if event_fired else null,
	}


static func tile_changed_state(world_generating: bool, build_present: bool, nearby_buildings: Array, block_static: bool, event_call: Variant) -> Dictionary:
	var build_update_proximity_called := not world_generating and build_present
	var nearby_proximity_updates: Array = []
	if not world_generating and not build_present:
		for building in nearby_buildings:
			if building is Dictionary and bool(building.get("present", false)) and not bool(building.get("changing", false)):
				nearby_proximity_updates.append(building)
	return {
		"build_update_proximity_called": build_update_proximity_called,
		"nearby_proximity_updates": nearby_proximity_updates,
		"fire_changed": tile_fire_change_state(world_generating, event_call),
		"recache_called": block_static,
	}


static func tile_pre_changed_state(world_generating: bool, build_present: bool, block_is_multiblock: bool, multiblock_tiles: Array, self_tile: Variant, pre_event_call: Variant, changed_event_call: Variant) -> Dictionary:
	var reset_tiles: Array = []
	var pre_change_calls: Array = []
	var changed_calls: Array = []
	if build_present and block_is_multiblock:
		for tile in multiblock_tiles:
			if tile == null or tile == self_tile:
				continue
			pre_change_calls.append({"tile": tile, "event_call": pre_event_call if not world_generating else null})
			reset_tiles.append({"tile": tile, "build": null, "block": "Blocks.air"})
			changed_calls.append({"tile": tile, "event_call": changed_event_call if not world_generating else null})
	return {
		"fire_pre_changed": tile_fire_change_state(world_generating, pre_event_call),
		"build_on_removed_called": build_present,
		"build_remove_from_proximity_called": build_present,
		"multiblock_reset_tiles": reset_tiles,
		"multiblock_pre_change_calls": pre_change_calls,
		"multiblock_changed_calls": changed_calls,
	}


static func tile_change_build_state(build_present: bool, existing_build_size: int, old_build_remove_call: Variant, edge_buildings: Array, block_has_building: bool, team: Variant, rotation: int, editor_state: bool, block_update: bool, entity_init_result: Variant) -> Dictionary:
	var edge_proximity_updates: Array = []
	for building in edge_buildings:
		if building == null:
			continue
		if building is Dictionary and not bool(building.get("present", true)):
			continue
		if not edge_proximity_updates.has(building):
			edge_proximity_updates.append(building)
	var should_init := block_has_building
	var init_update := block_update and not editor_state
	return {
		"build_present": build_present,
		"existing_build_size": existing_build_size,
		"old_build_remove_call": old_build_remove_call if build_present else null,
		"old_build_removed": build_present,
		"build_cleared": build_present,
		"edge_buildings": edge_proximity_updates if build_present else [],
		"edge_proximity_updates": edge_proximity_updates if build_present else [],
		"edge_proximity_update_count": edge_proximity_updates.size() if build_present else 0,
		"block_has_building": block_has_building,
		"team": team,
		"rotation": rotation,
		"editor_state": editor_state,
		"block_update": block_update,
		"init_update": init_update,
		"entity_init_called": should_init,
		"entity_init_result": entity_init_result if should_init else null,
		"build_result": entity_init_result if should_init else null,
	}


static func tile_display_state(block_item_drop_present: bool, overlay_item_drop_present: bool, wall_drop_present: bool, block_value: Variant, overlay_value: Variant, floor_value: Variant, display_icon: Variant, display_name: String) -> Dictionary:
	var selected_kind := "block" if block_item_drop_present else "overlay" if overlay_item_drop_present or wall_drop_present else "floor"
	var selected_value: Variant = block_value if selected_kind == "block" else overlay_value if selected_kind == "overlay" else floor_value
	return {
		"selected_kind": selected_kind,
		"selected_value": selected_value,
		"display_icon": display_icon,
		"display_name": display_name,
		"table_calls": [
			{"call": "table.table(...)"},
			{"call": "t.left()"},
			{"call": "t.add(new Image(toDisplay.getDisplayIcon(this))).scaling(Scaling.fit).size(8 * 4)", "display_icon": display_icon},
			{"call": "t.labelWrap(toDisplay.getDisplayName(this)).left().width(190f).padLeft(5)", "display_name": display_name},
			{"call": "}).growX().left()"},
		],
	}


static func tile_bulk_mutation_state(operation: String, block: Variant, team: Variant, positions: Array, block_valid: bool, world_tiles: Dictionary) -> Dictionary:
	var guard_passes := not positions.is_empty() and block_valid
	var mutations: Array = []
	if guard_passes:
		for position in positions:
			var tile: Variant = world_tiles.get(str(position), null)
			if tile == null:
				continue
			var call := {"position": position, "tile": tile, "operation": operation}
			if operation == "set_block":
				call["block"] = block
				call["team"] = team
				call["rotation"] = 0
			elif operation == "set_floor":
				call["floor"] = block
			else:
				call["overlay"] = block
			mutations.append(call)
	return {"operation": operation, "block": block, "team": team, "positions": positions, "block_valid": block_valid, "guard_passes": guard_passes, "mutations": mutations}


static func tile_single_mutation_state(operation: String, tile: Variant, block: Variant, team: Variant, rotation: int, tile_present: bool) -> Dictionary:
	var guard_passes := operation != "set_tile" or tile_present
	var calls: Array = []
	if guard_passes:
		match operation:
			"set_floor":
				calls = [{"call": "tile.setFloor(floor.asFloor());", "tile": tile, "floor": block}, {"call": "tile.setOverlay(overlay);", "tile": tile, "overlay": team}]
			"set_overlay":
				calls = [{"call": "tile.setOverlay(overlay);", "tile": tile, "block": block}]
			"remove_tile":
				calls = [{"call": "tile.remove();", "tile": tile}]
			"set_tile":
				calls = [{"call": "tile.setBlock(block, team, rotation);", "tile": tile, "block": block, "team": team, "rotation": rotation}]
	return {"operation": operation, "tile": tile, "block": block, "team": team, "rotation": rotation, "tile_present": tile_present, "guard_passes": guard_passes, "calls": calls}


static func tile_static_callback_state(operation: String, build_present: bool, build: Variant, team: Variant, positions: Array, first_pass: Array, second_pass: Array, stale_graphs: Array, health_updates: Array, positions_present: bool = true) -> Dictionary:
	var guard_passes := true
	var calls: Array = []
	var mutations: Array = []
	match operation:
		"set_team":
			guard_passes = build_present
			if guard_passes:
				calls.append({"call": "build.changeTeam(team);", "build": build, "team": team})
		"set_teams":
			guard_passes = positions_present
			if guard_passes:
				mutations = first_pass + second_pass
				calls = [{"call": "staleGraphs.clear();"}, {"call": "build.changeTeam(team, false);", "first_pass": first_pass}, {"call": "new PowerGraph().reflow(build);", "second_pass": second_pass}, {"call": "build.updatePowerGraph();"}]
		"build_destroyed":
			guard_passes = build_present
			if guard_passes:
				calls.append({"call": "build.killed();", "build": build})
		"build_health_update":
			for update in health_updates:
				if update is Dictionary and bool(update.get("build_present", false)) and update.get("current_health") != update.get("health"):
					mutations.append(update)
					calls.append({"call": "indexer.notifyHealthChanged(build);", "position": update.get("position", null), "health": update.get("health", null)})
	return {"operation": operation, "build_present": build_present, "build": build, "team": team, "positions": positions, "first_pass": first_pass, "second_pass": second_pass, "stale_graphs": stale_graphs, "health_updates": health_updates, "guard_passes": guard_passes, "mutations": mutations, "calls": calls}


static func tile_worldx_state(x: int, source_tilesize: float) -> float:
	return float(x) * source_tilesize


static func tile_worldy_state(y: int, source_tilesize: float) -> float:
	return float(y) * source_tilesize


static func tile_drawx_state(x: int, source_tilesize: float, block_offset: float) -> float:
	return block_offset + tile_worldx_state(x, source_tilesize)


static func tile_drawy_state(y: int, source_tilesize: float, block_offset: float) -> float:
	return block_offset + tile_worldy_state(y, source_tilesize)


static func block_sprite_scale(texture_size: Vector2, block_size: int, tile_size: int) -> Vector2:
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Vector2.ONE
	var world_size := block_world_size(block_size, tile_size)
	return Vector2(world_size / texture_size.x, world_size / texture_size.y)


static func building_hit_size(block_size_value: int, source_tilesize: float) -> float:
	return float(block_size_value) * source_tilesize

static func generated_building_hit_size_bridge_state(block_size_value: int, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_HIT_SIZE_JAVA_METHOD, [block_size_value, source_tilesize])
	var canonical = building_hit_size(block_size_value, source_tilesize)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HIT_SIZE,
		"generated_owner": SOURCE_BUILDING_HIT_SIZE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}


static func building_hitbox_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var hitbox_size: float = building_hit_size(block_size_value, source_tilesize)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HITBOX_STATE, "method": SOURCE_BUILDING_HITBOX_METHOD, "set_centered_expr": SOURCE_BUILDING_HITBOX_SET_CENTERED_EXPR, "hitbox_size_expr": SOURCE_BUILDING_HITBOX_SIZE_EXPR, "world_x": world_x, "world_y": world_y, "block_size_value": block_size_value, "source_tilesize": source_tilesize, "hitbox_size": hitbox_size, "set_centered": {"x": world_x, "y": world_y, "width": hitbox_size, "height": hitbox_size}}

static func generated_building_hitbox_bridge_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_HITBOX_JAVA_METHOD, [world_x, world_y, block_size_value, source_tilesize])
	var canonical = building_hitbox_state(world_x, world_y, block_size_value, source_tilesize)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HITBOX_STATE,
		"generated_owner": SOURCE_BUILDING_HITBOX_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}


static func block_unit_tile_hit_size(block_size: float, tile_size: float) -> float:
	return float(block_size) * tile_size * source_block_defaults.BLOCK_UNIT_TILE_HIT_SIZE_SCALE_DEFAULT

# Execute the existing pre-change plan on actual Tile references. The old Building
# stays on the mutation Tile until changeBuild; all other old footprint cells reset.
static func source_apply_tile_pre_changed(self_tile: Dictionary, build: Object, block_is_multiblock: bool, block_size: int, size_offset: int, old_build_center: Vector2i, world_tile_lookup: Callable, air_block: Object, world_generating: bool, on_removed: Callable, remove_from_proximity: Callable, fire_pre_changed: Callable, fire_changed: Callable) -> void:
	if tile_fire_change_state(world_generating, fire_pre_changed)["event_fired"]:
		fire_pre_changed.call(self_tile)
	if build == null:
		return
	on_removed.call(build)
	remove_from_proximity.call(build)
	if not block_is_multiblock:
		return
	var reset_proxy := func(other: Variant) -> void:
		var plan := tile_pre_changed_state(world_generating, build != null, block_is_multiblock, [other], self_tile, fire_pre_changed, fire_changed)
		for index in range(plan["multiblock_reset_tiles"].size()):
			var reset: Dictionary = plan["multiblock_reset_tiles"][index]
			var tile: Dictionary = reset["tile"]
			var pre_call: Variant = plan["multiblock_pre_change_calls"][index]["event_call"]
			if pre_call != null:
				pre_call.call(tile)
			tile["build"] = reset["build"]
			tile["block"] = air_block
			var changed_call: Variant = plan["multiblock_changed_calls"][index]["event_call"]
			if changed_call != null:
				changed_call.call(tile)
	# Stream lookup and assignment in source dx/dy order; events may change a later Tile.
	tile_get_linked_tiles_state(block_is_multiblock, block_size, size_offset, old_build_center.x, old_build_center.y, world_tile_lookup, self_tile, reset_proxy)


# Execute Tile.changeBuild on an actual Tile dictionary. The old Building is
# removed first; edge Buildings are collected through the canonical edge owner
# in source order and deduplicated by identity (upstream tileSet is an
# ObjectSet, so no order between distinct neighbours is claimed), and each
# unique edge Building updates proximity once. A new Building is created only
# when the new Block has one, with init_update = block.update && !isEditor().
static func source_apply_tile_change_build(self_tile: Dictionary, old_build: Variant, old_block_size: int, new_block_has_building: bool, new_block_update: bool, team: Variant, rotation: int, editor_state: bool, world_build: Callable, remove_build: Callable, update_proximity: Callable, entity_provider: Callable, entity_init: Callable) -> void:
	if old_build != null:
		remove_build.call(old_build)
		self_tile["build"] = null
		var tile_set: Array = []
		for point in source_block_plan_geometry_state.edge_points_state(old_block_size):
			var other: Variant = world_build.call(int(self_tile["x"]) + point.x, int(self_tile["y"]) + point.y)
			if other != null and not tile_set.has(other):
				tile_set.append(other)
		for other in tile_set:
			update_proximity.call(other)
	if new_block_has_building:
		var created: Variant = entity_provider.call()
		var init_update: bool = new_block_update and not editor_state
		self_tile["build"] = entity_init.call(created, self_tile, team, init_update, rotation)


# Execute Tile.changed on an actual Tile dictionary. While generating, no
# proximity work happens; the change event still passes through the
# generation gate in tile_fire_change_state, and a static Block still recaches.
static func source_apply_tile_changed(self_tile: Dictionary, world_generating: bool, block_static: bool, world_build: Callable, d4_offsets: Array, neighbor_changing: Callable, update_proximity: Callable, on_proximity_update: Callable, fire_changed: Callable, recache: Callable) -> void:
	if not world_generating:
		if self_tile.get("build") != null:
			update_proximity.call(self_tile["build"])
		else:
			for point in d4_offsets:
				var other: Variant = world_build.call(int(self_tile["x"]) + int(point.x), int(self_tile["y"]) + int(point.y))
				if other != null and not neighbor_changing.call(other):
					on_proximity_update.call(other)
	if tile_fire_change_state(world_generating, fire_changed)["event_fired"]:
		fire_changed.call(self_tile)
	if block_static:
		recache.call(self_tile)


# Execute the full Tile.setBlock on an actual Tile dictionary, composing the
# registered preChanged / changeBuild / changed primitives in source order.
# Multiblock proxies are looked up fresh in each pass in source dx/dy order;
# pass 0 clears each proxy through the supplied setBlock(air) hook and pass 1
# assigns the new entity and Block. The mutation Tile keeps its old Building
# through preChanged and regains its entity only through changeBuild.
static func source_apply_tile_set_block(self_tile: Dictionary, type_value: Variant, team_value: Variant, rotation_value: int, type_static: bool, previous_block_static: bool, force_team_present: bool, force_team_value: Variant, world_generating: bool, previous_build: Variant, previous_build_multiblock: bool, previous_block_size: int, size_offset: int, old_build_center: Vector2i, world_tile_lookup: Callable, world_build: Callable, air_block: Object, on_removed: Callable, remove_from_proximity: Callable, remove_build: Callable, fire_pre_changed: Callable, fire_changed: Callable, new_block_has_building: bool, new_block_update: bool, editor_state: bool, update_proximity: Callable, on_proximity_update: Callable, entity_provider: Callable, entity_init: Callable, build_team: Callable, d4_offsets: Array, neighbor_changing: Callable, recache: Callable, recache_wall: Callable, set_block_air: Callable, new_block_multiblock: bool, new_block_size: int, block_changed: Callable) -> void:
	self_tile["changing"] = true
	if type_static or previous_block_static:
		recache.call(self_tile)
		recache_wall.call(self_tile)
	var effective_team: Variant = force_team_value if force_team_present else team_value
	source_apply_tile_pre_changed(self_tile, previous_build, previous_build_multiblock, previous_block_size, size_offset, old_build_center, world_tile_lookup, air_block, world_generating, on_removed, remove_from_proximity, fire_pre_changed, fire_changed)
	self_tile["block"] = type_value
	var normalized_rotation: int = posmod(rotation_value, 4)
	source_apply_tile_change_build(self_tile, previous_build, previous_block_size, new_block_has_building, new_block_update, effective_team, normalized_rotation, editor_state, world_build, remove_build, update_proximity, entity_provider, entity_init)
	if self_tile.get("build") != null:
		build_team.call(self_tile["build"], effective_team)
	if new_block_multiblock:
		var offset: int = -(new_block_size - 1) / 2
		var entity: Variant = self_tile.get("build")
		for pass_index in range(2):
			for dx in range(new_block_size):
				for dy in range(new_block_size):
					var world_x: int = dx + offset + int(self_tile["x"])
					var world_y: int = dy + offset + int(self_tile["y"])
					if world_x == int(self_tile["x"]) and world_y == int(self_tile["y"]):
						continue
					var other: Variant = world_tile_lookup.call(world_x, world_y)
					if other == null:
						continue
					if pass_index == 0:
						set_block_air.call(other)
					else:
						other["build"] = entity
						other["block"] = type_value
		self_tile["build"] = entity
		self_tile["block"] = type_value
	source_apply_tile_changed(self_tile, world_generating, type_static, world_build, d4_offsets, neighbor_changing, update_proximity, on_proximity_update, fire_changed, recache)
	self_tile["changing"] = false
	block_changed.call(type_value, self_tile)
