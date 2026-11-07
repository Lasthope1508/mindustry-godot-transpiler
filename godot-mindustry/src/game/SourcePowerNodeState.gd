extends RefCounted
class_name SourcePowerNodeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_power_node_source_text_state := preload("res://src/game/SourcePowerNodeSourceTextState.gd")

const SOURCE_POWER_NODE_SOURCE := source_power_node_source_text_state.SOURCE_POWER_NODE_SOURCE
const SOURCE_POWER_NODE_SET_STATS_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_SET_STATS_METHOD
const SOURCE_POWER_NODE_SET_STATS_SUPER_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_SET_STATS_SUPER_EXPR
const SOURCE_POWER_NODE_SET_STATS_RANGE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_SET_STATS_RANGE_EXPR
const SOURCE_POWER_NODE_SET_STATS_CONNECTIONS_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_SET_STATS_CONNECTIONS_EXPR
const SOURCE_POWER_NODE_INIT_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_INIT_METHOD
const SOURCE_POWER_NODE_INIT_SUPER_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_INIT_SUPER_EXPR
const SOURCE_POWER_NODE_INIT_CLIP_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_INIT_CLIP_EXPR
const SOURCE_POWER_NODE_PLAN_CONFIG_CLIP_SIZE_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_PLAN_CONFIG_CLIP_SIZE_METHOD
const SOURCE_POWER_NODE_PLAN_CONFIG_CLIP_SIZE_RETURN_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_PLAN_CONFIG_CLIP_SIZE_RETURN_EXPR
const SOURCE_POWER_NODE_LINK_VALID_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_LINK_VALID_METHOD
const SOURCE_POWER_NODE_LINK_VALID_OVERLOAD_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_LINK_VALID_OVERLOAD_METHOD
const SOURCE_POWER_NODE_LINK_VALID_GUARD_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_LINK_VALID_GUARD_EXPR
const SOURCE_POWER_NODE_LINK_VALID_OVERLAP_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_LINK_VALID_OVERLAP_EXPR
const SOURCE_POWER_NODE_LINK_VALID_MAX_NODES_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_LINK_VALID_MAX_NODES_EXPR
const SOURCE_POWER_NODE_LINK_VALID_RETURN_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_LINK_VALID_RETURN_EXPR
const SOURCE_POWER_NODE_LINK_VALID_TRUE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_LINK_VALID_TRUE_EXPR
const SOURCE_POWER_NODE_LINK_VALID_FALSE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_LINK_VALID_FALSE_EXPR
const SOURCE_POWER_NODE_INSULATED_TILE_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_INSULATED_TILE_METHOD
const SOURCE_POWER_NODE_INSULATED_BUILDING_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_INSULATED_BUILDING_METHOD
const SOURCE_POWER_NODE_INSULATED_COORDINATE_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_INSULATED_COORDINATE_METHOD
const SOURCE_POWER_NODE_INSULATED_RAYCAST_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_INSULATED_RAYCAST_EXPR
const SOURCE_POWER_NODE_INSULATED_BUILD_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_INSULATED_BUILD_EXPR
const SOURCE_POWER_NODE_OVERLAPS_BLOCK_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_BLOCK_METHOD
const SOURCE_POWER_NODE_OVERLAPS_BLOCK_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_BLOCK_EXPR
const SOURCE_POWER_NODE_OVERLAPS_TILE_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_TILE_METHOD
const SOURCE_POWER_NODE_OVERLAPS_TILE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_TILE_EXPR
const SOURCE_POWER_NODE_OVERLAPS_BUILDING_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_BUILDING_METHOD
const SOURCE_POWER_NODE_OVERLAPS_BUILDING_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_BUILDING_EXPR
const SOURCE_POWER_NODE_OVERLAPS_TILE_RANGE_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_TILE_RANGE_METHOD
const SOURCE_POWER_NODE_OVERLAPS_TILE_RANGE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_TILE_RANGE_EXPR
const SOURCE_POWER_NODE_OVERLAPS_NULLABLE_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_NULLABLE_METHOD
const SOURCE_POWER_NODE_OVERLAPS_NULLABLE_GUARD_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_NULLABLE_GUARD_EXPR
const SOURCE_POWER_NODE_OVERLAPS_NULLABLE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_OVERLAPS_NULLABLE_EXPR
const SOURCE_POWER_NODE_SETUP_COLOR_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_SETUP_COLOR_METHOD
const SOURCE_POWER_NODE_SETUP_COLOR_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_SETUP_COLOR_EXPR
const SOURCE_POWER_NODE_DRAW_LASER_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_LASER_METHOD
const SOURCE_POWER_NODE_DRAW_LASER_OVERLOAD_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_LASER_OVERLOAD_METHOD
const SOURCE_POWER_NODE_DRAW_LASER_DELEGATE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_LASER_DELEGATE_EXPR
const SOURCE_POWER_NODE_DRAW_LASER_ANGLE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_LASER_ANGLE_EXPR
const SOURCE_POWER_NODE_DRAW_LASER_VECTOR_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_LASER_VECTOR_EXPR
const SOURCE_POWER_NODE_DRAW_LASER_LENGTH_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_LASER_LENGTH_EXPR
const SOURCE_POWER_NODE_DRAW_LASER_CALL_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_LASER_CALL_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_METHOD
const SOURCE_POWER_NODE_DRAW_PLACE_TILE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_TILE_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_GUARD_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_GUARD_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_STROKE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_STROKE_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_COLOR_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_COLOR_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_CIRCLE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_CIRCLE_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_LINK_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_LINK_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_LASER_COLOR_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_LASER_COLOR_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_LASER_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_LASER_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_SQUARE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_SQUARE_EXPR
const SOURCE_POWER_NODE_DRAW_PLACE_RESET_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLACE_RESET_EXPR
const SOURCE_POWER_NODE_CHANGE_PLACEMENT_PATH_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_CHANGE_PLACEMENT_PATH_METHOD
const SOURCE_POWER_NODE_CHANGE_PLACEMENT_PATH_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_CHANGE_PLACEMENT_PATH_EXPR
const SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_METHOD
const SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_GUARD_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_GUARD_EXPR
const SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_VALID_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_VALID_EXPR
const SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_RANGE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_RANGE_EXPR
const SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_SORT_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_SORT_EXPR
const SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_DISTANCE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_DISTANCE_EXPR
const SOURCE_POWER_NODE_GET_NODE_LINKS_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_GET_NODE_LINKS_METHOD
const SOURCE_POWER_NODE_GET_NODE_LINKS_VALID_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_GET_NODE_LINKS_VALID_EXPR
const SOURCE_POWER_NODE_GET_NODE_LINKS_RANGE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_GET_NODE_LINKS_RANGE_EXPR
const SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_METHOD
const SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_GUARD_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_GUARD_EXPR
const SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_SETUP_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_SETUP_EXPR
const SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_FIND_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_FIND_EXPR
const SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_NULL_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_NULL_EXPR
const SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_DRAW_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_DRAW_EXPR
const SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_RESET_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_RESET_EXPR
const SOURCE_POWER_NODE_MAKE_POWER_BALANCE_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_MAKE_POWER_BALANCE_METHOD
const SOURCE_POWER_NODE_MAKE_POWER_BALANCE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_MAKE_POWER_BALANCE_EXPR
const SOURCE_POWER_NODE_MAKE_POWER_BALANCE_FILL_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_MAKE_POWER_BALANCE_FILL_EXPR
const SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_METHOD
const SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_EXPR
const SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_FILL_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_FILL_EXPR
const SOURCE_POWER_NODE_SET_BARS_METHOD := source_power_node_source_text_state.SOURCE_POWER_NODE_SET_BARS_METHOD
const SOURCE_POWER_NODE_SET_BARS_SUPER_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_SET_BARS_SUPER_EXPR
const SOURCE_POWER_NODE_SET_BARS_POWER_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_SET_BARS_POWER_EXPR
const SOURCE_POWER_NODE_SET_BARS_BATTERIES_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_SET_BARS_BATTERIES_EXPR
const SOURCE_POWER_NODE_SET_BARS_CONNECTIONS_EXPR := source_power_node_source_text_state.SOURCE_POWER_NODE_SET_BARS_CONNECTIONS_EXPR

static func set_stats_state(laser_range: float, max_nodes: int, super_set_stats_state: Dictionary) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_SET_STATS_STATE,
		"method": SOURCE_POWER_NODE_SET_STATS_METHOD,
		"super_set_stats_expr": SOURCE_POWER_NODE_SET_STATS_SUPER_EXPR,
		"power_range_stat_expr": SOURCE_POWER_NODE_SET_STATS_RANGE_EXPR,
		"power_connections_stat_expr": SOURCE_POWER_NODE_SET_STATS_CONNECTIONS_EXPR,
		"laser_range": laser_range,
		"max_nodes": max_nodes,
		"range_stat_unit": "StatUnit.blocks",
		"connections_stat_unit": "StatUnit.none",
		"super_set_stats_state": super_set_stats_state,
		"stats": [
			{"stat": "Stat.powerRange", "value": laser_range, "unit": "StatUnit.blocks"},
			{"stat": "Stat.powerConnections", "value": max_nodes, "unit": "StatUnit.none"},
		],
	}

static func init_state(clip_size: float, laser_range: float, tilesize: float, super_init_state: Dictionary) -> Dictionary:
	var clip_size_after: float = maxf(clip_size, laser_range * tilesize)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_INIT_STATE,
		"method": SOURCE_POWER_NODE_INIT_METHOD,
		"super_init_expr": SOURCE_POWER_NODE_INIT_SUPER_EXPR,
		"clip_size_expr": SOURCE_POWER_NODE_INIT_CLIP_EXPR,
		"clip_size": clip_size,
		"laser_range": laser_range,
		"tilesize": tilesize,
		"clip_size_after": clip_size_after,
		"super_init_state": super_init_state,
		"super_init_called": true,
	}

static func plan_config_clip_size_state(laser_range: float, tilesize: float, size: float) -> Dictionary:
	var clip_size: float = laser_range * tilesize * 2.0 + size * tilesize
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_PLAN_CONFIG_CLIP_SIZE_STATE,
		"method": SOURCE_POWER_NODE_PLAN_CONFIG_CLIP_SIZE_METHOD,
		"return_expr": SOURCE_POWER_NODE_PLAN_CONFIG_CLIP_SIZE_RETURN_EXPR,
		"laser_range": laser_range,
		"tilesize": tilesize,
		"size": size,
		"clip_size": clip_size,
	}

static func link_valid_state(link_state: Dictionary, check_max_nodes: bool = true) -> Dictionary:
	var tile_is_link: bool = bool(link_state.get("tile_is_link", false))
	var link_present: bool = bool(link_state.get("link_present", false))
	var link_has_power: bool = bool(link_state.get("link_has_power", false))
	var link_connected_power: bool = bool(link_state.get("link_connected_power", false))
	var same_team: bool = bool(link_state.get("same_team", false))
	var same_block_connection: bool = bool(link_state.get("same_block_connection", false))
	var same_block_type: bool = bool(link_state.get("same_block_type", false))
	var source_overlaps: bool = bool(link_state.get("source_overlaps", false))
	var link_is_power_node: bool = bool(link_state.get("link_is_power_node", false))
	var reverse_overlaps: bool = bool(link_state.get("reverse_overlaps", false))
	var link_links_size: int = int(link_state.get("link_links_size", 0))
	var link_max_nodes: int = int(link_state.get("link_max_nodes", 0))
	var link_contains_tile: bool = bool(link_state.get("link_contains_tile", false))
	var guard_failed := tile_is_link or not link_present or not link_has_power or not link_connected_power or not same_team or (same_block_connection and not same_block_type)
	var overlaps_match := source_overlaps or (link_is_power_node and reverse_overlaps)
	var max_nodes_match := link_links_size < link_max_nodes or link_contains_tile
	var link_valid := not guard_failed and overlaps_match and (not check_max_nodes or not link_is_power_node or max_nodes_match)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_LINK_VALID_STATE,
		"method": SOURCE_POWER_NODE_LINK_VALID_METHOD,
		"overload_method": SOURCE_POWER_NODE_LINK_VALID_OVERLOAD_METHOD,
		"guard_expr": SOURCE_POWER_NODE_LINK_VALID_GUARD_EXPR,
		"overlap_expr": SOURCE_POWER_NODE_LINK_VALID_OVERLAP_EXPR,
		"max_nodes_expr": SOURCE_POWER_NODE_LINK_VALID_MAX_NODES_EXPR,
		"return_expr": SOURCE_POWER_NODE_LINK_VALID_RETURN_EXPR,
		"true_expr": SOURCE_POWER_NODE_LINK_VALID_TRUE_EXPR,
		"false_expr": SOURCE_POWER_NODE_LINK_VALID_FALSE_EXPR,
		"link_state": link_state.duplicate(true),
		"check_max_nodes": check_max_nodes,
		"guard_failed": guard_failed,
		"overlaps_match": overlaps_match,
		"max_nodes_match": max_nodes_match,
		"link_valid": link_valid,
	}

static func insulated_state(raycast_insulated: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_INSULATED_STATE,
		"tile_method": SOURCE_POWER_NODE_INSULATED_TILE_METHOD,
		"building_method": SOURCE_POWER_NODE_INSULATED_BUILDING_METHOD,
		"coordinate_method": SOURCE_POWER_NODE_INSULATED_COORDINATE_METHOD,
		"raycast_expr": SOURCE_POWER_NODE_INSULATED_RAYCAST_EXPR,
		"build_expr": SOURCE_POWER_NODE_INSULATED_BUILD_EXPR,
		"raycast_insulated": raycast_insulated,
		"insulated": raycast_insulated,
	}

static func overlaps_state(overlap_result: bool, method: String, expression: String) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_OVERLAPS_STATE,
		"method": method,
		"expression": expression,
		"overlap_result": overlap_result,
		"overlaps": overlap_result,
	}

static func overlaps_nullable_state(src_present: bool, other_present: bool, overlap_result: bool) -> Dictionary:
	var overlaps := true if not src_present or not other_present else overlap_result
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_OVERLAPS_NULLABLE_STATE,
		"method": SOURCE_POWER_NODE_OVERLAPS_NULLABLE_METHOD,
		"guard_expr": SOURCE_POWER_NODE_OVERLAPS_NULLABLE_GUARD_EXPR,
		"expression": SOURCE_POWER_NODE_OVERLAPS_NULLABLE_EXPR,
		"src_present": src_present,
		"other_present": other_present,
		"overlap_result": overlap_result,
		"overlaps": overlaps,
	}

static func setup_color_state(satisfaction: float, laser_opacity: float, lod_alpha2: float, absin_value: float) -> Dictionary:
	var lerp_factor: float = (1.0 - satisfaction) * 0.86 + absin_value
	var alpha: float = laser_opacity * lod_alpha2
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_SETUP_COLOR_STATE,
		"method": SOURCE_POWER_NODE_SETUP_COLOR_METHOD,
		"expression": SOURCE_POWER_NODE_SETUP_COLOR_EXPR,
		"satisfaction": satisfaction,
		"laser_opacity": laser_opacity,
		"lod_alpha2": lod_alpha2,
		"absin_value": absin_value,
		"lerp_factor": lerp_factor,
		"alpha": alpha,
	}

static func draw_laser_state(laser_state: Dictionary, light: bool = true) -> Dictionary:
	var x1: float = float(laser_state.get("x1", 0.0))
	var y1: float = float(laser_state.get("y1", 0.0))
	var x2: float = float(laser_state.get("x2", 0.0))
	var y2: float = float(laser_state.get("y2", 0.0))
	var size1: float = float(laser_state.get("size1", 0.0))
	var size2: float = float(laser_state.get("size2", 0.0))
	var tilesize: float = float(laser_state.get("tilesize", 0.0))
	var angle1: float = float(laser_state.get("angle1", 0.0))
	var vx: float = float(laser_state.get("vx", 0.0))
	var vy: float = float(laser_state.get("vy", 0.0))
	var len1: float = size1 * tilesize / 2.0 - 1.5
	var len2: float = size2 * tilesize / 2.0 - 1.5
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_DRAW_LASER_STATE,
		"method": SOURCE_POWER_NODE_DRAW_LASER_METHOD,
		"overload_method": SOURCE_POWER_NODE_DRAW_LASER_OVERLOAD_METHOD,
		"delegate_expr": SOURCE_POWER_NODE_DRAW_LASER_DELEGATE_EXPR,
		"angle_expr": SOURCE_POWER_NODE_DRAW_LASER_ANGLE_EXPR,
		"vector_expr": SOURCE_POWER_NODE_DRAW_LASER_VECTOR_EXPR,
		"length_expr": SOURCE_POWER_NODE_DRAW_LASER_LENGTH_EXPR,
		"draw_expr": SOURCE_POWER_NODE_DRAW_LASER_CALL_EXPR,
		"laser_state": laser_state.duplicate(true),
		"angle1": angle1,
		"vx": vx,
		"vy": vy,
		"len1": len1,
		"len2": len2,
		"start": Vector2(x1 + vx * len1, y1 + vy * len1),
		"end": Vector2(x2 - vx * len2, y2 - vy * len2),
		"light": light,
	}

static func change_placement_path_state(points: Variant, rotation: int, placement_result: Dictionary = {}) -> Dictionary:
	var calculated_points: Variant = placement_result.get("points", points)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_CHANGE_PLACEMENT_PATH_STATE,
		"method": SOURCE_POWER_NODE_CHANGE_PLACEMENT_PATH_METHOD,
		"calculate_nodes_expr": SOURCE_POWER_NODE_CHANGE_PLACEMENT_PATH_EXPR,
		"points": points,
		"rotation": rotation,
		"placement_result": placement_result.duplicate(true),
		"calculated_points": calculated_points,
		"world_overlap_dependency": true,
	}

static func draw_place_state(x: int, y: int, rotation: int, valid: bool, draw_input: Dictionary) -> Dictionary:
	var resolved_input := draw_input.duplicate(true)
	resolved_input["x"] = x
	resolved_input["y"] = y
	resolved_input["rotation"] = rotation
	resolved_input["valid"] = valid
	var tile_present: bool = bool(resolved_input.get("tile_present", false))
	var autolink: bool = bool(resolved_input.get("autolink", false))
	var skipped: bool = not tile_present or not autolink
	var commands: Array = []
	if not skipped:
		var x_value: float = float(resolved_input.get("x", 0.0))
		var y_value: float = float(resolved_input.get("y", 0.0))
		var tilesize: float = float(resolved_input.get("tilesize", 0.0))
		var offset: float = float(resolved_input.get("offset", 0.0))
		var laser_range: float = float(resolved_input.get("laser_range", 0.0))
		var size: float = float(resolved_input.get("size", 0.0))
		commands.append({"op": "stroke", "value": 1.0})
		commands.append({"op": "color", "value": "Pal.placing"})
		commands.append({"op": "circles", "center": Vector2(x_value * tilesize + offset, y_value * tilesize + offset), "radius": laser_range * tilesize})
		for link in resolved_input.get("potential_links", []):
			if not link is Dictionary:
				continue
			var other_x: float = float(link.get("x", 0.0))
			var other_y: float = float(link.get("y", 0.0))
			var other_size: float = float(link.get("size", 0.0))
			commands.append({"op": "color", "value": "laserColor1", "opacity": "Renderer.laserOpacity * 0.5f"})
			commands.append({"op": "laser", "from": Vector2(x_value * tilesize + offset, y_value * tilesize + offset), "to": Vector2(other_x, other_y), "size1": size, "size2": other_size})
			commands.append({"op": "square", "center": Vector2(other_x, other_y), "size": other_size * tilesize / 2.0 + 2.0, "color": "Pal.place"})
		commands.append({"op": "reset"})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_DRAW_PLACE_STATE,
		"method": SOURCE_POWER_NODE_DRAW_PLACE_METHOD,
		"tile_expr": SOURCE_POWER_NODE_DRAW_PLACE_TILE_EXPR,
		"guard_expr": SOURCE_POWER_NODE_DRAW_PLACE_GUARD_EXPR,
		"stroke_expr": SOURCE_POWER_NODE_DRAW_PLACE_STROKE_EXPR,
		"color_expr": SOURCE_POWER_NODE_DRAW_PLACE_COLOR_EXPR,
		"circle_expr": SOURCE_POWER_NODE_DRAW_PLACE_CIRCLE_EXPR,
		"link_expr": SOURCE_POWER_NODE_DRAW_PLACE_LINK_EXPR,
		"laser_color_expr": SOURCE_POWER_NODE_DRAW_PLACE_LASER_COLOR_EXPR,
		"laser_expr": SOURCE_POWER_NODE_DRAW_PLACE_LASER_EXPR,
		"square_expr": SOURCE_POWER_NODE_DRAW_PLACE_SQUARE_EXPR,
		"reset_expr": SOURCE_POWER_NODE_DRAW_PLACE_RESET_EXPR,
		"draw_input": resolved_input,
		"skipped": skipped,
		"commands": commands,
		"potential_links_dependency": true,
	}

static func _candidate_graph_id(candidate: Dictionary) -> String:
	return str(candidate.get("graph_id", ""))

static func get_potential_links_state(link_input: Dictionary) -> Dictionary:
	var autolink: bool = bool(link_input.get("autolink", false))
	var graphs: Array = link_input.get("initial_graph_ids", []).duplicate()
	var candidates: Array = []
	if bool(link_input.get("tile_graph_present", false)):
		graphs.append(str(link_input.get("tile_graph_id", "")))
	for candidate_value in link_input.get("candidates", []):
		if not candidate_value is Dictionary:
			continue
		var candidate: Dictionary = candidate_value.duplicate(true)
		var candidate_graph := _candidate_graph_id(candidate)
		var is_power_node: bool = bool(candidate.get("is_power_node", false))
		var valid: bool = bool(candidate.get("present", false)) and not bool(candidate.get("same_tile", false)) \
			and bool(candidate.get("connected_power", false)) and bool(candidate.get("power_present", false)) \
			and (bool(candidate.get("outputs_power", false)) or bool(candidate.get("consumes_power", false)) or is_power_node) \
			and bool(candidate.get("overlaps", false)) and bool(candidate.get("same_team", false)) \
			and not graphs.has(candidate_graph) and not bool(candidate.get("insulated", false)) \
			and not bool(candidate.get("max_nodes_reached", false)) and not bool(candidate.get("adjacent", false))
		candidate["valid"] = valid
		if valid and not autolink:
			candidate["valid"] = false
		if candidate["valid"]:
			candidates.append(candidate)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if bool(a.get("is_power_node", false)) != bool(b.get("is_power_node", false)):
			return bool(a.get("is_power_node", false))
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	var selected: Array = []
	var max_nodes: int = int(link_input.get("max_nodes", 0))
	for candidate in candidates:
		if selected.size() >= max_nodes:
			break
		var graph_id := _candidate_graph_id(candidate)
		if graphs.has(graph_id):
			continue
		selected.append(candidate)
		graphs.append(graph_id)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_STATE,
		"method": SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_METHOD,
		"guard_expr": SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_GUARD_EXPR,
		"valid_expr": SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_VALID_EXPR,
		"range_expr": SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_RANGE_EXPR,
		"sort_expr": SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_SORT_EXPR,
		"distance_expr": SOURCE_POWER_NODE_GET_POTENTIAL_LINKS_DISTANCE_EXPR,
		"link_input": link_input.duplicate(true),
		"autolink": autolink,
		"graphs": graphs,
		"valid_candidates": candidates,
		"selected_links": selected,
		"returned_count": selected.size(),
	}

static func get_node_links_state(link_input: Dictionary) -> Dictionary:
	var graphs: Array = link_input.get("initial_graph_ids", []).duplicate()
	var candidates: Array = []
	for candidate_value in link_input.get("candidates", []):
		if not candidate_value is Dictionary:
			continue
		var candidate: Dictionary = candidate_value.duplicate(true)
		var graph_id := _candidate_graph_id(candidate)
		var valid: bool = bool(candidate.get("present", false)) and not bool(candidate.get("same_tile", false)) \
			and bool(candidate.get("is_power_node", false)) and bool(candidate.get("autolink", false)) \
			and bool(candidate.get("capacity_available", false)) and bool(candidate.get("overlaps", false)) \
			and bool(candidate.get("same_team", false)) and not graphs.has(graph_id) \
			and not bool(candidate.get("insulated", false)) and not bool(candidate.get("adjacent", false))
		candidate["valid"] = valid
		if valid:
			candidates.append(candidate)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if bool(a.get("is_power_node", false)) != bool(b.get("is_power_node", false)):
			return bool(a.get("is_power_node", false))
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	var selected: Array = []
	for candidate in candidates:
		var graph_id := _candidate_graph_id(candidate)
		if graphs.has(graph_id):
			continue
		graphs.append(graph_id)
		selected.append(candidate)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_GET_NODE_LINKS_STATE,
		"method": SOURCE_POWER_NODE_GET_NODE_LINKS_METHOD,
		"valid_expr": SOURCE_POWER_NODE_GET_NODE_LINKS_VALID_EXPR,
		"range_expr": SOURCE_POWER_NODE_GET_NODE_LINKS_RANGE_EXPR,
		"link_input": link_input.duplicate(true),
		"graphs": graphs,
		"valid_candidates": candidates,
		"selected_links": selected,
		"returned_count": selected.size(),
	}

static func draw_plan_config_top_state(plan_input: Dictionary) -> Dictionary:
	var config_present: bool = bool(plan_input.get("config_present", false))
	var commands: Array = []
	if config_present:
		commands.append({"op": "setup_color", "satisfaction": 1.0})
		for link in plan_input.get("resolved_links", []):
			if not link is Dictionary or not bool(link.get("other_present", false)):
				continue
			commands.append({
				"op": "laser",
				"from": link.get("plan_position", Vector2.ZERO),
				"to": link.get("other_position", Vector2.ZERO),
				"size1": float(plan_input.get("size", 0.0)),
				"size2": float(link.get("other_size", 0.0)),
				"light": false,
			})
		commands.append({"op": "reset_color"})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_STATE,
		"method": SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_METHOD,
		"guard_expr": SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_GUARD_EXPR,
		"setup_expr": SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_SETUP_EXPR,
		"find_expr": SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_FIND_EXPR,
		"null_expr": SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_NULL_EXPR,
		"draw_expr": SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_DRAW_EXPR,
		"reset_expr": SOURCE_POWER_NODE_DRAW_PLAN_CONFIG_TOP_RESET_EXPR,
		"plan_input": plan_input.duplicate(true),
		"config_present": config_present,
		"commands": commands,
	}

static func _clamped_ratio(numerator: float, denominator: float) -> float:
	if is_zero_approx(denominator):
		return 0.0
	return clampf(numerator / denominator, 0.0, 1.0)

static func make_power_balance_state(graph_input: Dictionary) -> Dictionary:
	var balance: float = float(graph_input.get("power_balance", 0.0))
	var produced: float = float(graph_input.get("last_power_produced", 0.0))
	var needed: float = float(graph_input.get("last_power_needed", 0.0))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_MAKE_POWER_BALANCE_STATE,
		"method": SOURCE_POWER_NODE_MAKE_POWER_BALANCE_METHOD,
		"label_expr": SOURCE_POWER_NODE_MAKE_POWER_BALANCE_EXPR,
		"fill_expr": SOURCE_POWER_NODE_MAKE_POWER_BALANCE_FILL_EXPR,
		"graph_input": graph_input.duplicate(true),
		"balance_per_second": balance * 60.0,
		"balance_sign": "+" if balance >= 0.0 else "",
		"formatted_label": str(graph_input.get("formatted_label", "")),
		"fill": _clamped_ratio(produced, needed),
	}

static func make_battery_balance_state(graph_input: Dictionary) -> Dictionary:
	var stored: float = float(graph_input.get("last_power_stored", 0.0))
	var capacity: float = float(graph_input.get("last_capacity", 0.0))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_STATE,
		"method": SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_METHOD,
		"label_expr": SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_EXPR,
		"fill_expr": SOURCE_POWER_NODE_MAKE_BATTERY_BALANCE_FILL_EXPR,
		"graph_input": graph_input.duplicate(true),
		"formatted_label": str(graph_input.get("formatted_label", "")),
		"fill": _clamped_ratio(stored, capacity),
	}

static func set_bars_state(bars_input: Dictionary) -> Dictionary:
	var graph_input: Dictionary = bars_input.get("graph_input", {})
	var power_balance := make_power_balance_state(graph_input)
	var battery_balance := make_battery_balance_state(graph_input)
	var links: float = float(bars_input.get("links", 0.0))
	var max_nodes: float = float(bars_input.get("max_nodes", 0.0))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_NODE_SET_BARS_STATE,
		"method": SOURCE_POWER_NODE_SET_BARS_METHOD,
		"super_expr": SOURCE_POWER_NODE_SET_BARS_SUPER_EXPR,
		"power_expr": SOURCE_POWER_NODE_SET_BARS_POWER_EXPR,
		"batteries_expr": SOURCE_POWER_NODE_SET_BARS_BATTERIES_EXPR,
		"connections_expr": SOURCE_POWER_NODE_SET_BARS_CONNECTIONS_EXPR,
		"bars_input": bars_input.duplicate(true),
		"super_set_bars_state": bars_input.get("super_set_bars_state", {}),
		"power_balance": power_balance,
		"battery_balance": battery_balance,
		"connections": {
			"links": links,
			"max_nodes": max_nodes,
			"fill": _clamped_ratio(links, max_nodes),
		},
	}
