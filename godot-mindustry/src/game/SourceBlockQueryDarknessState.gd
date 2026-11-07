class_name SourceBlockQueryDarknessState
extends RefCounted

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_query_darkness_source_text_state := preload("res://src/game/SourceBlockQueryDarknessSourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_SYNTHETIC_METHOD := source_block_source_text_state.SOURCE_BLOCK_SYNTHETIC_METHOD
const SOURCE_BLOCK_CHECK_FORCE_DARK_METHOD := source_block_source_text_state.SOURCE_BLOCK_CHECK_FORCE_DARK_METHOD
const SOURCE_BLOCK_IS_DARKENED_METHOD := source_block_source_text_state.SOURCE_BLOCK_IS_DARKENED_METHOD
const SOURCE_BLOCK_QUERY_DARKNESS_SOURCE := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_SOURCE
const SOURCE_BLOCK_QUERY_DARKNESS_SYNTHETIC_RETURN_EXPR := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_SYNTHETIC_RETURN_EXPR
const SOURCE_BLOCK_QUERY_DARKNESS_SYNTHETIC_JAVA_METHOD_SYNTHETIC_22 := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_SYNTHETIC_JAVA_METHOD_SYNTHETIC_22
const SOURCE_BLOCK_QUERY_DARKNESS_SYNTHETIC_GENERATED_OWNER := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_SYNTHETIC_GENERATED_OWNER
const SOURCE_BLOCK_QUERY_DARKNESS_CHECK_FORCE_DARK_RETURN_EXPR := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_CHECK_FORCE_DARK_RETURN_EXPR
const SOURCE_BLOCK_QUERY_DARKNESS_CHECK_FORCE_DARK_JAVA_METHOD_CHECK_FORCE_DARK_23 := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_CHECK_FORCE_DARK_JAVA_METHOD_CHECK_FORCE_DARK_23
const SOURCE_BLOCK_QUERY_DARKNESS_CHECK_FORCE_DARK_GENERATED_OWNER := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_CHECK_FORCE_DARK_GENERATED_OWNER
const SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_COMMENT := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_COMMENT
const SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_RETURN_EXPR := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_RETURN_EXPR
const SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_JAVA_METHOD_IS_DARKENED_24 := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_JAVA_METHOD_IS_DARKENED_24
const SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_GENERATED_OWNER := source_block_query_darkness_source_text_state.SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_GENERATED_OWNER

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func synthetic_state(update_value: bool, destructible_value: bool) -> Dictionary:
	var synthetic_value: bool = update_value or destructible_value
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SYNTHETIC_STATE, "source": SOURCE_BLOCK_QUERY_DARKNESS_SOURCE, "method": SOURCE_BLOCK_SYNTHETIC_METHOD, "return_expr": SOURCE_BLOCK_QUERY_DARKNESS_SYNTHETIC_RETURN_EXPR, "update": update_value, "destructible": destructible_value, "synthetic": synthetic_value}

static func generated_synthetic_result_state(update_value: bool, destructible_value: bool) -> Dictionary:
	return synthetic_state(update_value, destructible_value)

static func check_force_dark_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHECK_FORCE_DARK_STATE, "source": SOURCE_BLOCK_QUERY_DARKNESS_SOURCE, "method": SOURCE_BLOCK_CHECK_FORCE_DARK_METHOD, "return_expr": SOURCE_BLOCK_QUERY_DARKNESS_CHECK_FORCE_DARK_RETURN_EXPR, "force_dark": force_dark_value, "tile": tile, "check_force_dark": force_dark_value}

static func generated_check_force_dark_result_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return check_force_dark_state(force_dark_value, tile)

static func is_darkened_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	var synthetic_state_result := synthetic_state(update_value, destructible_value)
	var check_force_dark_state_result := check_force_dark_state(force_dark_value, tile)
	var is_darkened_value: bool = solid_value and ((not bool(synthetic_state_result["synthetic"]) and fills_tile_value) or bool(check_force_dark_state_result["check_force_dark"]))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_DARKENED_STATE, "source": SOURCE_BLOCK_QUERY_DARKNESS_SOURCE, "comment": SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_COMMENT, "method": SOURCE_BLOCK_IS_DARKENED_METHOD, "return_expr": SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_RETURN_EXPR, "solid": solid_value, "fillsTile": fills_tile_value, "synthetic_state": synthetic_state_result, "check_force_dark_state": check_force_dark_state_result, "tile": tile, "is_darkened": is_darkened_value}

static func generated_is_darkened_result_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	return is_darkened_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)

static func generated_block_synthetic_bridge_state(update_value: bool, destructible_value: bool) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_QUERY_DARKNESS_SYNTHETIC_JAVA_METHOD_SYNTHETIC_22, [update_value, destructible_value])
	var canonical = synthetic_state(update_value, destructible_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SYNTHETIC_STATE, "generated_owner": SOURCE_BLOCK_QUERY_DARKNESS_SYNTHETIC_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_check_force_dark_bridge_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_QUERY_DARKNESS_CHECK_FORCE_DARK_JAVA_METHOD_CHECK_FORCE_DARK_23, [force_dark_value, tile])
	var canonical = check_force_dark_state(force_dark_value, tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHECK_FORCE_DARK_STATE, "generated_owner": SOURCE_BLOCK_QUERY_DARKNESS_CHECK_FORCE_DARK_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_is_darkened_bridge_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_JAVA_METHOD_IS_DARKENED_24, [solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile])
	var canonical = is_darkened_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_DARKENED_STATE, "generated_owner": SOURCE_BLOCK_QUERY_DARKNESS_IS_DARKENED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
