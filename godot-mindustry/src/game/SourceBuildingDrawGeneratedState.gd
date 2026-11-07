extends RefCounted
class_name SourceBuildingDrawGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_building_draw_state := preload("res://src/game/SourceBuildingDrawState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_DRAW_STATUS_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_STATUS_JAVA_METHOD
const SOURCE_BUILDING_DRAW_CRACKS_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_CRACKS_JAVA_METHOD
const SOURCE_BUILDING_DRAW_SELECT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_SELECT_JAVA_METHOD
const SOURCE_BUILDING_DRAW_ITEM_SELECTION_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_ITEM_SELECTION_JAVA_METHOD
const SOURCE_BUILDING_DRAW_DISABLED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_DISABLED_JAVA_METHOD
const SOURCE_BUILDING_FOG_RADIUS_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_FOG_RADIUS_JAVA_METHOD
const SOURCE_BUILDING_ROTDEG_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_ROTDEG_JAVA_METHOD
const SOURCE_BUILDING_DRAWROT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAWROT_JAVA_METHOD
const SOURCE_BUILDING_DRAW_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_JAVA_METHOD
const SOURCE_BUILDING_DRAW_CACHED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_CACHED_JAVA_METHOD
const SOURCE_BUILDING_RECACHE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_RECACHE_JAVA_METHOD
const SOURCE_BUILDING_PAYLOAD_DRAW_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_PAYLOAD_DRAW_JAVA_METHOD
const SOURCE_BUILDING_DRAW_TEAM_TOP_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_TEAM_TOP_JAVA_METHOD
const SOURCE_BUILDING_DRAW_LIGHT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_LIGHT_JAVA_METHOD
const SOURCE_BUILDING_DRAW_LIQUID_LIGHT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_LIQUID_LIGHT_JAVA_METHOD
const SOURCE_BUILDING_DRAW_TEAM_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_TEAM_JAVA_METHOD
const SOURCE_BUILDING_DRAW_CONFIGURE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DRAW_CONFIGURE_JAVA_METHOD
const SOURCE_BUILDING_DRAW_STATUS_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_STATUS_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_CRACKS_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_CRACKS_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_SELECT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_SELECT_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_ITEM_SELECTION_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_ITEM_SELECTION_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_DISABLED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_DISABLED_GENERATED_OWNER
const SOURCE_BUILDING_FOG_RADIUS_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_FOG_RADIUS_GENERATED_OWNER
const SOURCE_BUILDING_ROTDEG_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_ROTDEG_GENERATED_OWNER
const SOURCE_BUILDING_DRAWROT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAWROT_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_CACHED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_CACHED_GENERATED_OWNER
const SOURCE_BUILDING_RECACHE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_RECACHE_GENERATED_OWNER
const SOURCE_BUILDING_PAYLOAD_DRAW_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_PAYLOAD_DRAW_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_TEAM_TOP_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_TEAM_TOP_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_LIGHT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_LIGHT_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_LIQUID_LIGHT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_LIQUID_LIGHT_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_TEAM_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_TEAM_GENERATED_OWNER
const SOURCE_BUILDING_DRAW_CONFIGURE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DRAW_CONFIGURE_GENERATED_OWNER

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func generated_draw_status_bridge_state(enable_draw_status: bool, consumers_length: int, block_size_value: int, source_x: float, source_y: float, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_STATUS_JAVA_METHOD, [enable_draw_status, consumers_length, block_size_value, source_x, source_y, source_tilesize])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_STATUS_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_STATUS_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_cracks_bridge_state(draw_cracks: bool, damaged_state: bool, block_size_value: int, max_crack_size: int, health_fraction: float, crack_regions: int, position_id: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_CRACKS_JAVA_METHOD, [draw_cracks, damaged_state, block_size_value, max_crack_size, health_fraction, crack_regions, position_id])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_CRACKS_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_CRACKS_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_select_bridge_state(block_status: String, source_x: float, source_y: float, source_rotation: float, tile_x: int, tile_y: int, unit_activation_delay: float, state_tick: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_SELECT_JAVA_METHOD, [block_status, source_x, source_y, source_rotation, tile_x, tile_y, unit_activation_delay, state_tick])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_SELECT_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_SELECT_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_item_selection_bridge_state(has_selection: bool, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, icon_small: float, selection_icon_ratio: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_ITEM_SELECTION_JAVA_METHOD, [has_selection, source_x, source_y, block_size_value, source_tilesize, icon_small, selection_icon_ratio])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_ITEM_SELECTION_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_ITEM_SELECTION_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_disabled_bridge_state(source_x: float, source_y: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_DISABLED_JAVA_METHOD, [source_x, source_y])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_DISABLED_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_DISABLED_GENERATED_OWNER,
		"result": result,
	}

static func generated_rotdeg_bridge_state(rotation_quadrants: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_ROTDEG_JAVA_METHOD, [rotation_quadrants])
	var canonical = source_building_draw_state.rotdeg_state(rotation_quadrants)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ROTDEG_STATE,
		"generated_owner": SOURCE_BUILDING_ROTDEG_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_fog_radius_bridge_state(fog_radius_value: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_FOG_RADIUS_JAVA_METHOD, [fog_radius_value])
	var canonical = source_building_draw_state.fog_radius_state(fog_radius_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_FOG_RADIUS_STATE,
		"generated_owner": SOURCE_BUILDING_FOG_RADIUS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_drawrot_bridge_state(block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAWROT_JAVA_METHOD, [block_rotate, block_rotate_draw, rotation_quadrants])
	var canonical = source_building_draw_state.drawrot_state(block_rotate, block_rotate_draw, rotation_quadrants)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAWROT_STATE,
		"generated_owner": SOURCE_BUILDING_DRAWROT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_draw_bridge_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_JAVA_METHOD, [variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_cached_bridge_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_CACHED_JAVA_METHOD, [variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_CACHED_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_CACHED_GENERATED_OWNER,
		"result": result,
	}

static func generated_recache_bridge_state(headless: bool, building_cache_layer: Variant, tile_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_RECACHE_JAVA_METHOD, [headless, building_cache_layer, tile_state])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_RECACHE_STATE,
		"generated_owner": SOURCE_BUILDING_RECACHE_GENERATED_OWNER,
		"result": result,
	}

static func generated_payload_draw_bridge_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_PAYLOAD_DRAW_JAVA_METHOD, [draw_cached, draw_dynamic, current_z, building_cache_layer_z, variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PAYLOAD_DRAW_STATE,
		"generated_owner": SOURCE_BUILDING_PAYLOAD_DRAW_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_team_top_bridge_state(team_region_found: bool, team_region_matches_team: bool, team_color: String, source_x: float, source_y: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_TEAM_TOP_JAVA_METHOD, [team_region_found, team_region_matches_team, team_color, source_x, source_y])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_TEAM_TOP_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_TEAM_TOP_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_light_bridge_state(has_liquids: bool, draw_liquid_light: bool, light_liquid_is_null: bool, current_liquid_color: String, current_liquid_alpha: float, light_liquid_color: String, light_liquid_alpha: float, selected_liquid_amount: float, visual_liquid: float, source_delta: float, source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_LIGHT_JAVA_METHOD, [has_liquids, draw_liquid_light, light_liquid_is_null, current_liquid_color, current_liquid_alpha, light_liquid_color, light_liquid_alpha, selected_liquid_amount, visual_liquid, source_delta, source_x, source_y, block_size_value])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_LIGHT_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_LIGHT_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_liquid_light_bridge_state(source_x: float, source_y: float, block_size_value: int, light_color: String, light_alpha: float, amount: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_LIQUID_LIGHT_JAVA_METHOD, [source_x, source_y, block_size_value, light_color, light_alpha, amount])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_LIQUID_LIGHT_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_LIQUID_LIGHT_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_team_bridge_state(team_color: String, source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_TEAM_JAVA_METHOD, [team_color, source_x, source_y, block_size_value, source_tilesize])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_TEAM_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_TEAM_GENERATED_OWNER,
		"result": result,
	}

static func generated_draw_configure_bridge_state(source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_CONFIGURE_JAVA_METHOD, [source_x, source_y, block_size_value, source_tilesize])
	var canonical = source_building_draw_state.draw_configure_state(source_x, source_y, block_size_value, source_tilesize)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_CONFIGURE_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_CONFIGURE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_draw_configure_source_tilesize_default_bridge_state(source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DRAW_CONFIGURE_JAVA_METHOD, [source_x, source_y, block_size_value])
	var canonical = source_building_draw_state.draw_configure_state(source_x, source_y, block_size_value, source_world_defaults.TILESIZE)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DRAW_CONFIGURE_STATE,
		"generated_owner": SOURCE_BUILDING_DRAW_CONFIGURE_GENERATED_OWNER,
		"defaulted_arg": "source_tilesize",
		"source_tilesize": result.get("source_tilesize", null),
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
