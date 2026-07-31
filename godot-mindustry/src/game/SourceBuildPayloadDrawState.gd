class_name SourceBuildPayloadDrawState
extends RefCounted

const source_build_payload_state := preload("res://src/game/SourceBuildPayloadState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_METHOD := "public void drawShadow(float alpha){"
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_EXPR := "Drawf.squareShadow(build.x, build.y, build.block.size * tilesize * 1.85f, alpha);"
const SOURCE_BUILD_PAYLOAD_DRAW_METHOD := "public void draw(){"
const SOURCE_BUILD_PAYLOAD_DRAW_PREV_Z_EXPR := "float prevZ = Draw.z();"
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_EXPR := "Draw.z(prevZ - 0.001f);"
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_CALL_EXPR := "drawShadow(1f);"
const SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR := "Draw.z(prevZ);"
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_EXPR := "Draw.zTransform(z ->"
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RETURN_EXPR := "z >= Layer.flyingUnitLow + 1f ? z : 0.0011f + Math.min(Mathf.clamp((z - prevZ)/100f, -0.0009f, 0.9f) + prevZ, Layer.flyingUnitLow - 1f)"
const SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_OFFSET := 0.001
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_OFFSET := 0.0011
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MIN := -0.0009
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MAX := 0.9
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_DIVISOR := 100.0
const SOURCE_BUILD_PAYLOAD_DRAW_PAYLOAD_DRAW_EXPR := "build.payloadDraw();"
const SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RESET_EXPR := "Draw.zTransform();"
const SOURCE_BUILD_PAYLOAD_ICON_METHOD := "public TextureRegion icon(){"
const SOURCE_BUILD_PAYLOAD_ICON_RETURN_EXPR := "return block().fullIcon;"

static func draw_shadow_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	var shadow_size: float = build_block_size * source_tilesize * 1.85
	var shadow_call: Dictionary = {"call": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_EXPR, "x": build_x, "y": build_y, "size": shadow_size, "alpha": alpha}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "import_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_IMPORT_STATIC_VARS_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_METHOD, "shadow_expr": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_EXPR, "build_x": build_x, "build_y": build_y, "build_block_size": build_block_size, "source_tilesize": source_tilesize, "alpha": alpha, "shadow_size": shadow_size, "shadow_call": shadow_call}

static func draw_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	var shadow_z: float = prev_z - SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_OFFSET
	var transform_threshold: float = layer_flying_unit_low + 1.0
	var transform_min_limit: float = layer_flying_unit_low - 1.0
	var transformed_z: float = transform_z
	if transform_z < transform_threshold:
		var transform_clamped: float = clampf((transform_z - prev_z) / SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_DIVISOR, SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MIN, SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_CLAMP_MAX)
		transformed_z = SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_OFFSET + min(transform_clamped + prev_z, transform_min_limit)
	var draw_calls: Array = [{"call": SOURCE_BUILD_PAYLOAD_DRAW_PREV_Z_EXPR, "value": prev_z}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_EXPR, "z": shadow_z}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_CALL_EXPR, "alpha": 1.0}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR, "z": prev_z}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_EXPR, "input_z": transform_z, "result": transformed_z}, {"call": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_TILE_EMPTY_ASSIGN_EXPR, "tile": source_build_payload_state.SOURCE_BUILD_PAYLOAD_EMPTY_TILE_EXPR}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_PAYLOAD_DRAW_EXPR, "called": true}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RESET_EXPR, "called": true}, {"call": SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR, "z": prev_z}]
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DRAW_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "import_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_IMPORT_STATIC_VARS_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_DRAW_METHOD, "prev_z_expr": SOURCE_BUILD_PAYLOAD_DRAW_PREV_Z_EXPR, "shadow_z_expr": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_Z_EXPR, "draw_shadow_expr": SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_CALL_EXPR, "z_restore_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR, "z_transform_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_EXPR, "z_transform_return_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RETURN_EXPR, "tile_assign_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_TILE_EMPTY_ASSIGN_EXPR, "payload_draw_expr": SOURCE_BUILD_PAYLOAD_DRAW_PAYLOAD_DRAW_EXPR, "z_transform_reset_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_TRANSFORM_RESET_EXPR, "final_z_restore_expr": SOURCE_BUILD_PAYLOAD_DRAW_Z_RESTORE_EXPR, "prev_z": prev_z, "layer_flying_unit_low": layer_flying_unit_low, "transform_z": transform_z, "shadow_z": shadow_z, "transformed_z": transformed_z, "tile_after": source_build_payload_state.SOURCE_BUILD_PAYLOAD_EMPTY_TILE_EXPR, "payload_draw_called": true, "draw_calls": draw_calls}

static func icon_state(full_icon: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_ICON_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": "@Override", "method": SOURCE_BUILD_PAYLOAD_ICON_METHOD, "return_expr": SOURCE_BUILD_PAYLOAD_ICON_RETURN_EXPR, "full_icon": full_icon, "icon": full_icon}

static func generated_build_payload_draw_shadow_bridge_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, "java_method_drawShadow_15", [build_x, build_y, build_block_size, source_tilesize, alpha], null)
	var canonical = draw_shadow_state(build_x, build_y, build_block_size, source_tilesize, alpha)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DRAW_SHADOW_STATE, "generated_owner": "build_payload.java_method_drawShadow_15", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_draw_bridge_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, "java_method_draw_16", [prev_z, layer_flying_unit_low, transform_z], null)
	var canonical = draw_state(prev_z, layer_flying_unit_low, transform_z)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DRAW_STATE, "generated_owner": "build_payload.java_method_draw_16", "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_icon_bridge_state(full_icon: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, "java_method_icon_17", [full_icon], null)
	var canonical = icon_state(full_icon)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_ICON_STATE, "generated_owner": "build_payload.java_method_icon_17", "result": result, "canonical": canonical, "matches": matches}
