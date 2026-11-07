extends RefCounted
class_name SourceBuildingVisibilityState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_IS_DISCOVERED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_JAVA_METHOD
const SOURCE_BUILDING_IN_FOG_TO_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_IN_FOG_TO_JAVA_METHOD
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_JAVA_METHOD
const SOURCE_BUILDING_IN_FOG_TO_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_IN_FOG_TO_GENERATED_OWNER
const SOURCE_BUILDING_IS_DISCOVERED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_GENERATED_OWNER
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_GENERATED_OWNER
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_COMMENT := source_building_source_text_state.SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_COMMENT
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_METHOD
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_GATE := source_building_source_text_state.SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_GATE
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_FLAGS := source_building_source_text_state.SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_FLAGS
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_WAS_VISIBLE := source_building_source_text_state.SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_WAS_VISIBLE
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_SHADOW := source_building_source_text_state.SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_SHADOW
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_MINIMAP := source_building_source_text_state.SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_MINIMAP
const SOURCE_BUILDING_IS_DISCOVERED_METHOD := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_METHOD
const SOURCE_BUILDING_IS_DISCOVERED_MAP_DARKNESS_GUARD := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_MAP_DARKNESS_GUARD
const SOURCE_BUILDING_IS_DISCOVERED_MAP_DARKNESS_RETURN := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_MAP_DARKNESS_RETURN
const SOURCE_BUILDING_IS_DISCOVERED_EARLY_VISIBLE_GUARD := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_EARLY_VISIBLE_GUARD
const SOURCE_BUILDING_IS_DISCOVERED_EARLY_VISIBLE_RETURN := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_EARLY_VISIBLE_RETURN
const SOURCE_BUILDING_IS_DISCOVERED_SMALL_BLOCK_GUARD := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_SMALL_BLOCK_GUARD
const SOURCE_BUILDING_IS_DISCOVERED_CENTER_PROBE := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_CENTER_PROBE
const SOURCE_BUILDING_IS_DISCOVERED_LARGE_BLOCK_HALF_SIZE := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_LARGE_BLOCK_HALF_SIZE
const SOURCE_BUILDING_IS_DISCOVERED_LARGE_BLOCK_PROBES := source_building_source_text_state.SOURCE_BUILDING_IS_DISCOVERED_LARGE_BLOCK_PROBES

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func is_discovered_state(limit_map_area: bool, darkness: float, viewer_present: bool, static_fog: bool, rules_fog: bool, block_size_value: int, tile_x: int, tile_y: int, fog_discovered_lookup: Callable) -> Dictionary:
	var common := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_DISCOVERED_STATE,
		"method": SOURCE_BUILDING_IS_DISCOVERED_METHOD,
		"map_darkness_guard": SOURCE_BUILDING_IS_DISCOVERED_MAP_DARKNESS_GUARD,
		"early_visible_guard": SOURCE_BUILDING_IS_DISCOVERED_EARLY_VISIBLE_GUARD,
		"block_size": block_size_value,
		"tile_x": tile_x,
		"tile_y": tile_y,
	}
	if limit_map_area and darkness >= 3.0:
		common.merge({"is_discovered": false, "return_expr": SOURCE_BUILDING_IS_DISCOVERED_MAP_DARKNESS_RETURN, "path": "map_darkness", "probes": []})
		return common
	if not viewer_present or not static_fog or not rules_fog:
		common.merge({"is_discovered": true, "return_expr": SOURCE_BUILDING_IS_DISCOVERED_EARLY_VISIBLE_RETURN, "path": "early_visible", "probes": []})
		return common
	var half_size := block_size_value / 2
	var probes: Array[Vector2i] = [Vector2i(tile_x, tile_y)]
	if block_size_value > 2:
		probes.append_array([Vector2i(tile_x - half_size, tile_y - half_size), Vector2i(tile_x - half_size, tile_y + half_size), Vector2i(tile_x + half_size, tile_y + half_size), Vector2i(tile_x + half_size, tile_y - half_size)])
	for point in probes:
		if fog_discovered_lookup.is_valid() and bool(fog_discovered_lookup.call(point.x, point.y)):
			common.merge({"is_discovered": true, "return_expr": SOURCE_BUILDING_IS_DISCOVERED_CENTER_PROBE if block_size_value <= 2 else SOURCE_BUILDING_IS_DISCOVERED_LARGE_BLOCK_PROBES, "path": "fog_probe", "probes": probes, "discovered_point": point})
			return common
	common.merge({"is_discovered": false, "return_expr": SOURCE_BUILDING_IS_DISCOVERED_CENTER_PROBE if block_size_value <= 2 else SOURCE_BUILDING_IS_DISCOVERED_LARGE_BLOCK_PROBES, "path": "fog_probe", "probes": probes, "discovered_point": null})
	return common

static func generated_is_discovered_bridge_state(limit_map_area: bool, darkness: float, viewer_present: bool, static_fog: bool, rules_fog: bool, block_size_value: int, tile_x: int, tile_y: int, fog_discovered_lookup: Callable) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_IS_DISCOVERED_JAVA_METHOD, [limit_map_area, darkness, viewer_present, static_fog, rules_fog, block_size_value, tile_x, tile_y, fog_discovered_lookup])
	var canonical = is_discovered_state(limit_map_area, darkness, viewer_present, static_fog, rules_fog, block_size_value, tile_x, tile_y, fog_discovered_lookup)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_DISCOVERED_STATE, "generated_owner": SOURCE_BUILDING_IS_DISCOVERED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func in_fog_initial_gate_state(same_team: bool, rules_fog: bool) -> Dictionary:
	if same_team or not rules_fog:
		return {"returned": true, "value": false}
	return {"returned": false, "value": null}

static func generated_in_fog_initial_gate_bridge_state(same_team: bool, rules_fog: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_IN_FOG_TO_JAVA_METHOD, [same_team, rules_fog])
	var canonical = in_fog_initial_gate_state(same_team, rules_fog)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IN_FOG_INITIAL_GATE_STATE,
		"generated_owner": SOURCE_BUILDING_IN_FOG_TO_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func in_fog_discovery_gate_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:
	var grid := {
		"size": block_size_value,
		"offset": block_size_offset,
		"tile_x": tile_x,
		"tile_y": tile_y,
	}
	if not is_discovered:
		return {"returned": true, "value": true, "grid": grid}
	return {"returned": false, "value": null, "grid": grid}

static func generated_in_fog_discovery_gate_bridge_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_IN_FOG_TO_JAVA_METHOD, [false, true, block_size_value, block_size_offset, tile_x, tile_y, is_discovered])
	var canonical = in_fog_discovery_gate_state(block_size_value, block_size_offset, tile_x, tile_y, is_discovered)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IN_FOG_DISCOVERY_GATE_STATE,
		"generated_owner": SOURCE_BUILDING_IN_FOG_TO_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func in_fog_visibility_loop_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:
	var checked_tiles := []
	for x in range(block_size_value):
		for y in range(block_size_value):
			var check_x := tile_x + x + block_size_offset
			var check_y := tile_y + y + block_size_offset
			checked_tiles.append({"x": check_x, "y": check_y})
			for visible_tile in visible_tiles:
				if int(visible_tile.get("x", -2147483648)) == check_x and int(visible_tile.get("y", -2147483648)) == check_y:
					return {"in_fog": false, "checked_tiles": checked_tiles, "visible_tile": {"x": check_x, "y": check_y}}
	return {"in_fog": true, "checked_tiles": checked_tiles, "visible_tile": null}

static func generated_in_fog_visibility_loop_bridge_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_IN_FOG_TO_JAVA_METHOD, [false, true, block_size_value, block_size_offset, tile_x, tile_y, true, visible_tiles])
	var canonical = in_fog_visibility_loop_state(block_size_value, block_size_offset, tile_x, tile_y, visible_tiles)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IN_FOG_VISIBILITY_LOOP_STATE,
		"generated_owner": SOURCE_BUILDING_IN_FOG_TO_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func update_fog_visibility_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state := {}, tile_state := {}) -> Dictionary:
	var should_update: bool = not was_visible and not in_fog_to_player_team
	var updated_flags: int = visible_flags | (1 << player_team_id)
	if should_update:
		return {
			"comment": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_COMMENT,
			"method": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_METHOD,
			"gate": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_GATE,
			"flags_expr": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_FLAGS,
			"was_visible_expr": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_WAS_VISIBLE,
			"shadow_expr": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_SHADOW,
			"minimap_expr": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_MINIMAP,
			"was_visible": true,
			"visible_flags": updated_flags,
			"update_shadow": self_state,
			"minimap_update": tile_state,
		}
	return {
		"comment": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_COMMENT,
		"method": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_METHOD,
		"gate": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_GATE,
		"was_visible": was_visible,
		"visible_flags": visible_flags,
		"update_shadow": null,
		"minimap_update": null,
	}

static func generated_update_fog_visibility_bridge_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state: Variant, tile_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_JAVA_METHOD, [was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state])
	var canonical = update_fog_visibility_state(was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_STATE,
		"generated_owner": SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}
