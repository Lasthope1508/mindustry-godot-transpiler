class_name SourceBlockDisplayQueryState
extends RefCounted

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_display_query_source_text_state := preload("res://src/game/SourceBlockDisplayQuerySourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_DISPLAY_QUERY_SOURCE := source_block_display_query_source_text_state.SOURCE_BLOCK_DISPLAY_QUERY_SOURCE
const SOURCE_BLOCK_PERCENT_SOLID_METHOD := source_block_display_query_source_text_state.SOURCE_BLOCK_PERCENT_SOLID_METHOD
const SOURCE_BLOCK_PERCENT_SOLID_TILE_LOOKUP_EXPR := source_block_display_query_source_text_state.SOURCE_BLOCK_PERCENT_SOLID_TILE_LOOKUP_EXPR
const SOURCE_BLOCK_PERCENT_SOLID_NULL_GUARD_EXPR := source_block_display_query_source_text_state.SOURCE_BLOCK_PERCENT_SOLID_NULL_GUARD_EXPR
const SOURCE_BLOCK_PERCENT_SOLID_RETURN_EXPR := source_block_display_query_source_text_state.SOURCE_BLOCK_PERCENT_SOLID_RETURN_EXPR
const SOURCE_BLOCK_PERCENT_SOLID_JAVA_METHOD_PERCENT_SOLID_3 := source_block_display_query_source_text_state.SOURCE_BLOCK_PERCENT_SOLID_JAVA_METHOD_PERCENT_SOLID_3
const SOURCE_BLOCK_PERCENT_SOLID_GENERATED_OWNER := source_block_display_query_source_text_state.SOURCE_BLOCK_PERCENT_SOLID_GENERATED_OWNER
const SOURCE_BLOCK_GET_DISPLAY_ICON_METHOD := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_DISPLAY_ICON_METHOD
const SOURCE_BLOCK_GET_DISPLAY_ICON_RETURN_EXPR := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_DISPLAY_ICON_RETURN_EXPR
const SOURCE_BLOCK_GET_DISPLAY_ICON_JAVA_METHOD_GET_DISPLAY_ICON_13 := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_DISPLAY_ICON_JAVA_METHOD_GET_DISPLAY_ICON_13
const SOURCE_BLOCK_GET_DISPLAY_ICON_GENERATED_OWNER := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_DISPLAY_ICON_GENERATED_OWNER
const SOURCE_BLOCK_GET_DISPLAY_NAME_METHOD := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_DISPLAY_NAME_METHOD
const SOURCE_BLOCK_GET_DISPLAY_NAME_RETURN_EXPR := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_DISPLAY_NAME_RETURN_EXPR
const SOURCE_BLOCK_GET_DISPLAY_NAME_JAVA_METHOD_GET_DISPLAY_NAME_14 := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_DISPLAY_NAME_JAVA_METHOD_GET_DISPLAY_NAME_14
const SOURCE_BLOCK_GET_DISPLAY_NAME_GENERATED_OWNER := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_DISPLAY_NAME_GENERATED_OWNER
const SOURCE_BLOCK_MINIMAP_COLOR_COMMENT := source_block_display_query_source_text_state.SOURCE_BLOCK_MINIMAP_COLOR_COMMENT
const SOURCE_BLOCK_MINIMAP_COLOR_METHOD := source_block_display_query_source_text_state.SOURCE_BLOCK_MINIMAP_COLOR_METHOD
const SOURCE_BLOCK_MINIMAP_COLOR_RETURN_EXPR := source_block_display_query_source_text_state.SOURCE_BLOCK_MINIMAP_COLOR_RETURN_EXPR
const SOURCE_BLOCK_MINIMAP_COLOR_JAVA_METHOD_MINIMAP_COLOR_15 := source_block_display_query_source_text_state.SOURCE_BLOCK_MINIMAP_COLOR_JAVA_METHOD_MINIMAP_COLOR_15
const SOURCE_BLOCK_MINIMAP_COLOR_GENERATED_OWNER := source_block_display_query_source_text_state.SOURCE_BLOCK_MINIMAP_COLOR_GENERATED_OWNER
const SOURCE_BLOCK_GET_COLOR_METHOD := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_COLOR_METHOD
const SOURCE_BLOCK_GET_COLOR_MINIMAP_CALL_EXPR := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_COLOR_MINIMAP_CALL_EXPR
const SOURCE_BLOCK_GET_COLOR_RETURN_EXPR := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_COLOR_RETURN_EXPR
const SOURCE_BLOCK_GET_COLOR_JAVA_METHOD_GET_COLOR_16 := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_COLOR_JAVA_METHOD_GET_COLOR_16
const SOURCE_BLOCK_GET_COLOR_GENERATED_OWNER := source_block_display_query_source_text_state.SOURCE_BLOCK_GET_COLOR_GENERATED_OWNER

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func percent_solid_state(tile_exists: bool, x_value: int, y_value: int, linked_non_liquid_count: float, size_value: float) -> Dictionary:
	var percent_solid_value: float = 0.0 if ((not tile_exists) or size_value == 0.0) else linked_non_liquid_count / size_value / size_value
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PERCENT_SOLID_STATE, "source": SOURCE_BLOCK_DISPLAY_QUERY_SOURCE, "method": SOURCE_BLOCK_PERCENT_SOLID_METHOD, "tile_lookup_expr": SOURCE_BLOCK_PERCENT_SOLID_TILE_LOOKUP_EXPR, "null_guard_expr": SOURCE_BLOCK_PERCENT_SOLID_NULL_GUARD_EXPR, "return_expr": SOURCE_BLOCK_PERCENT_SOLID_RETURN_EXPR, "tile_exists": tile_exists, "x": x_value, "y": y_value, "linked_non_liquid_count": linked_non_liquid_count, "size": size_value, "percent_solid": percent_solid_value}

static func get_display_icon_state(tile_build_present: bool, ui_icon: Variant, build_display_icon: Variant) -> Dictionary:
	var display_icon: Variant = build_display_icon if tile_build_present else ui_icon
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DISPLAY_ICON_STATE, "source": SOURCE_BLOCK_DISPLAY_QUERY_SOURCE, "method": SOURCE_BLOCK_GET_DISPLAY_ICON_METHOD, "return_expr": SOURCE_BLOCK_GET_DISPLAY_ICON_RETURN_EXPR, "tile_build_present": tile_build_present, "uiIcon": ui_icon, "build_display_icon": build_display_icon, "display_icon": display_icon}

static func get_display_name_state(tile_build_present: bool, localized_name: String, build_display_name: String) -> Dictionary:
	var display_name: String = build_display_name if tile_build_present else localized_name
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DISPLAY_NAME_STATE, "source": SOURCE_BLOCK_DISPLAY_QUERY_SOURCE, "method": SOURCE_BLOCK_GET_DISPLAY_NAME_METHOD, "return_expr": SOURCE_BLOCK_GET_DISPLAY_NAME_RETURN_EXPR, "tile_build_present": tile_build_present, "localizedName": localized_name, "build_display_name": build_display_name, "display_name": display_name}

static func minimap_color_state(tile: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_MINIMAP_COLOR_STATE, "source": SOURCE_BLOCK_DISPLAY_QUERY_SOURCE, "comment": SOURCE_BLOCK_MINIMAP_COLOR_COMMENT, "method": SOURCE_BLOCK_MINIMAP_COLOR_METHOD, "return_expr": SOURCE_BLOCK_MINIMAP_COLOR_RETURN_EXPR, "tile": tile, "minimap_color": 0}

static func get_color_state(minimap_color: int, map_color: Variant, tmp_c3_set_color: Variant) -> Dictionary:
	var color_value: Variant = map_color if minimap_color == 0 else tmp_c3_set_color
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_COLOR_STATE, "source": SOURCE_BLOCK_DISPLAY_QUERY_SOURCE, "method": SOURCE_BLOCK_GET_COLOR_METHOD, "minimap_call_expr": SOURCE_BLOCK_GET_COLOR_MINIMAP_CALL_EXPR, "return_expr": SOURCE_BLOCK_GET_COLOR_RETURN_EXPR, "minimap_color": minimap_color, "mapColor": map_color, "tmp_c3_set_color": tmp_c3_set_color, "color": color_value}

static func generated_block_percent_solid_result_state(tile_exists: bool, x_value: int, y_value: int, linked_non_liquid_count: float, size_value: float) -> Dictionary:
	return percent_solid_state(tile_exists, x_value, y_value, linked_non_liquid_count, size_value)

static func generated_block_get_display_icon_result_state(tile_build_present: bool, ui_icon: Variant, build_display_icon: Variant) -> Dictionary:
	return get_display_icon_state(tile_build_present, ui_icon, build_display_icon)

static func generated_block_get_display_name_result_state(tile_build_present: bool, localized_name: String, build_display_name: String) -> Dictionary:
	return get_display_name_state(tile_build_present, localized_name, build_display_name)

static func generated_block_minimap_color_result_state(tile: Variant) -> Dictionary:
	return minimap_color_state(tile)

static func generated_block_get_color_result_state(minimap_color: int, map_color: Variant, tmp_c3_set_color: Variant) -> Dictionary:
	return get_color_state(minimap_color, map_color, tmp_c3_set_color)

static func generated_block_percent_solid_bridge_state(tile_exists: bool, x_value: int, y_value: int, linked_non_liquid_count: float, size_value: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_PERCENT_SOLID_JAVA_METHOD_PERCENT_SOLID_3, [tile_exists, x_value, y_value, linked_non_liquid_count, size_value])
	var canonical = percent_solid_state(tile_exists, x_value, y_value, linked_non_liquid_count, size_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PERCENT_SOLID_STATE, "generated_owner": SOURCE_BLOCK_PERCENT_SOLID_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_get_display_icon_bridge_state(tile_build_present: bool, ui_icon: Variant, build_display_icon: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_GET_DISPLAY_ICON_JAVA_METHOD_GET_DISPLAY_ICON_13, [tile_build_present, ui_icon, build_display_icon])
	var canonical = get_display_icon_state(tile_build_present, ui_icon, build_display_icon)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DISPLAY_ICON_STATE, "generated_owner": SOURCE_BLOCK_GET_DISPLAY_ICON_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_get_display_name_bridge_state(tile_build_present: bool, localized_name: String, build_display_name: String) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_GET_DISPLAY_NAME_JAVA_METHOD_GET_DISPLAY_NAME_14, [tile_build_present, localized_name, build_display_name])
	var canonical = get_display_name_state(tile_build_present, localized_name, build_display_name)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_DISPLAY_NAME_STATE, "generated_owner": SOURCE_BLOCK_GET_DISPLAY_NAME_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_minimap_color_bridge_state(tile: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_MINIMAP_COLOR_JAVA_METHOD_MINIMAP_COLOR_15, [tile])
	var canonical = minimap_color_state(tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_MINIMAP_COLOR_STATE, "generated_owner": SOURCE_BLOCK_MINIMAP_COLOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_get_color_bridge_state(minimap_color: int, map_color: Variant, tmp_c3_set_color: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_GET_COLOR_JAVA_METHOD_GET_COLOR_16, [minimap_color, map_color, tmp_c3_set_color])
	var canonical = get_color_state(minimap_color, map_color, tmp_c3_set_color)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_COLOR_STATE, "generated_owner": SOURCE_BLOCK_GET_COLOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
