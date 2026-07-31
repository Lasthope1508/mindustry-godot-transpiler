extends RefCounted
class_name SourceBuildingVisibilityState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_COMMENT := "/** When a block is newly revealed outside of camera view range, it is updated on the minimap. */"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_METHOD := "public void updateFogVisibility(){"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_GATE := "if(!wasVisible && !inFogTo(player.team())){"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_FLAGS := "visibleFlags |= (1L << player.team().id);"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_WAS_VISIBLE := "wasVisible = true;"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_SHADOW := "renderer.blocks.updateShadow(self());"
const SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_MINIMAP := "renderer.minimap.update(tile);"

static func in_fog_initial_gate_state(same_team: bool, rules_fog: bool) -> Dictionary:
	if same_team or not rules_fog:
		return {"returned": true, "value": false}
	return {"returned": false, "value": null}

static func generated_in_fog_initial_gate_bridge_state(same_team: bool, rules_fog: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_inFogTo_214", [same_team, rules_fog], null)
	var canonical = in_fog_initial_gate_state(same_team, rules_fog)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IN_FOG_INITIAL_GATE_STATE,
		"generated_owner": "building_comp.java_method_inFogTo_214",
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
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_inFogTo_214", [false, true, block_size_value, block_size_offset, tile_x, tile_y, is_discovered], null)
	var canonical = in_fog_discovery_gate_state(block_size_value, block_size_offset, tile_x, tile_y, is_discovered)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IN_FOG_DISCOVERY_GATE_STATE,
		"generated_owner": "building_comp.java_method_inFogTo_214",
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
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_inFogTo_214", [false, true, block_size_value, block_size_offset, tile_x, tile_y, true, visible_tiles], null)
	var canonical = in_fog_visibility_loop_state(block_size_value, block_size_offset, tile_x, tile_y, visible_tiles)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IN_FOG_VISIBILITY_LOOP_STATE,
		"generated_owner": "building_comp.java_method_inFogTo_214",
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
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateFogVisibility_218", [was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state], null)
	var canonical = update_fog_visibility_state(was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_FOG_VISIBILITY_STATE,
		"generated_owner": "building_comp.java_method_updateFogVisibility_218",
		"result": result,
		"canonical": canonical,
	}
