class_name SourceBuildPayloadDrawState
extends RefCounted

const source_payload_source_text_state := preload("res://src/game/SourcePayloadSourceTextState.gd")
const source_build_payload_state := preload("res://src/game/SourceBuildPayloadState.gd")
const source_build_payload_draw_source_text_state := preload("res://src/game/SourceBuildPayloadDrawSourceTextState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_METHOD := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_METHOD
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_EXPR
const SOURCE_BUILD_PAYLOAD_DRAW_METHOD := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_METHOD
const SOURCE_BUILD_PAYLOAD_DRAW_PREV_Z_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_PREV_Z_EXPR
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_EXPR
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_CALL_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_CALL_EXPR
const SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_EXPR
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RETURN_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RETURN_EXPR
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_OFFSET := source_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_OFFSET
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_OFFSET := source_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_OFFSET
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MIN := source_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MIN
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MAX := source_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MAX
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_DIVISOR := source_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_DIVISOR
const SOURCE_BUILD_PAYLOAD_DRAW_PAYLOAD_DRAW_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_PAYLOAD_DRAW_EXPR
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RESET_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RESET_EXPR
const SOURCE_BUILD_PAYLOAD_ICON_METHOD := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_ICON_METHOD
const SOURCE_BUILD_PAYLOAD_ICON_RETURN_EXPR := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_ICON_RETURN_EXPR
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_JAVA_METHOD := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_JAVA_METHOD
const SOURCE_BUILD_PAYLOAD_DRAW_JAVA_METHOD := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_JAVA_METHOD
const SOURCE_BUILD_PAYLOAD_ICON_JAVA_METHOD := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_ICON_JAVA_METHOD
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_GENERATED_OWNER := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_GENERATED_OWNER
const SOURCE_BUILD_PAYLOAD_DRAW_GENERATED_OWNER := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_DRAW_GENERATED_OWNER
const SOURCE_BUILD_PAYLOAD_ICON_GENERATED_OWNER := source_build_payload_draw_source_text_state.SOURCE_BUILD_PAYLOAD_ICON_GENERATED_OWNER

static func draw_shadow_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	var shadow_size: float = build_block_size * source_tilesize * 1.85
	var shadow_call: Dictionary = {"call": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_EXPR, "x": build_x, "y": build_y, "size": shadow_size, "alpha": alpha}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "import_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_IMPORT_STATIC_VARS_EXPR, "override_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_OVERRIDE_EXPR, "method": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_METHOD, "shadow_expr": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_EXPR, "build_x": build_x, "build_y": build_y, "build_block_size": build_block_size, "source_tilesize": source_tilesize, "alpha": alpha, "shadow_size": shadow_size, "shadow_call": shadow_call}

static func draw_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	var shadow_z: float = prev_z - SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_OFFSET
	var transform_threshold: float = layer_flying_unit_low + 1.0
	var transform_min_limit: float = layer_flying_unit_low - 1.0
	var transformed_z: float = transform_z
	if transform_z < transform_threshold:
		var transform_clamped: float = clampf((transform_z - prev_z) / SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_DIVISOR, SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MIN, SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MAX)
		transformed_z = SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_OFFSET + min(transform_clamped + prev_z, transform_min_limit)
	var draw_calls: Array = [{"call": SOURCE_BUILD_PAYLOAD_DRAW_PREV_Z_EXPR, "value": prev_z}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_EXPR, "z": shadow_z}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_CALL_EXPR, "alpha": 1.0}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR, "z": prev_z}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_EXPR, "input_z": transform_z, "result": transformed_z}, {"call": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_TILE_EMPTY_ASSIGN_EXPR, "tile": source_build_payload_state.SOURCE_BUILD_PAYLOAD_EMPTY_TILE_EXPR}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_PAYLOAD_DRAW_EXPR, "called": true}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RESET_EXPR, "called": true}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR, "z": prev_z}]
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DRAW_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "import_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_IMPORT_STATIC_VARS_EXPR, "override_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_OVERRIDE_EXPR, "method": SOURCE_BUILD_PAYLOAD_DRAW_METHOD, "prev_z_expr": SOURCE_BUILD_PAYLOAD_DRAW_PREV_Z_EXPR, "shadow_z_expr": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_EXPR, "draw_shadow_expr": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_CALL_EXPR, "z_restore_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR, "z_transform_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_EXPR, "z_transform_return_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RETURN_EXPR, "tile_assign_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_TILE_EMPTY_ASSIGN_EXPR, "payload_draw_expr": SOURCE_BUILD_PAYLOAD_DRAW_PAYLOAD_DRAW_EXPR, "z_transform_reset_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RESET_EXPR, "final_z_restore_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR, "prev_z": prev_z, "layer_flying_unit_low": layer_flying_unit_low, "transform_z": transform_z, "shadow_z": shadow_z, "transformed_z": transformed_z, "tile_after": source_build_payload_state.SOURCE_BUILD_PAYLOAD_EMPTY_TILE_EXPR, "payload_draw_called": true, "draw_calls": draw_calls}

static func icon_state(full_icon: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_ICON_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_OVERRIDE_EXPR, "method": SOURCE_BUILD_PAYLOAD_ICON_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_ICON_RETURN_EXPR, "full_icon": full_icon, "icon": full_icon}

static func generated_build_payload_draw_shadow_bridge_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_JAVA_METHOD, [build_x, build_y, build_block_size, source_tilesize, alpha], null)
	var canonical = draw_shadow_state(build_x, build_y, build_block_size, source_tilesize, alpha)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_STATE, "generated_owner": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_draw_bridge_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, SOURCE_BUILD_PAYLOAD_DRAW_JAVA_METHOD, [prev_z, layer_flying_unit_low, transform_z], null)
	var canonical = draw_state(prev_z, layer_flying_unit_low, transform_z)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DRAW_STATE, "generated_owner": SOURCE_BUILD_PAYLOAD_DRAW_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_icon_bridge_state(full_icon: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, SOURCE_BUILD_PAYLOAD_ICON_JAVA_METHOD, [full_icon], null)
	var canonical = icon_state(full_icon)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_ICON_STATE, "generated_owner": SOURCE_BUILD_PAYLOAD_ICON_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
