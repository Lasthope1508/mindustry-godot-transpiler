extends RefCounted
class_name SourceBlockRuntimeGeometryState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_runtime_geometry_source_text_state := preload("res://src/game/SourceBlockRuntimeGeometrySourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_RUNTIME_GEOMETRY_SOURCE := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_SOURCE

const SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_METHOD := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_METHOD
const SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_RETURN_EXPR := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_RETURN_EXPR
const SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_JAVA_METHOD := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_JAVA_METHOD
const SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_GENERATED_OWNER := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_GENERATED_OWNER

const SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_METHOD := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_METHOD
const SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_ASSIGNMENT_EXPR := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_ASSIGNMENT_EXPR
const SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_JAVA_METHOD := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_JAVA_METHOD
const SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_GENERATED_OWNER := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_GENERATED_OWNER

const SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_METHOD := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_METHOD
const SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_RETURN_EXPR := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_RETURN_EXPR
const SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_JAVA_METHOD := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_JAVA_METHOD
const SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_GENERATED_OWNER := source_block_runtime_geometry_source_text_state.SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_GENERATED_OWNER

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func new_building_state(build_type_value: Variant) -> Dictionary:
	var building_value: Variant = build_type_value
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_NEW_BUILDING_STATE, "source": SOURCE_BLOCK_RUNTIME_GEOMETRY_SOURCE, "method": SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_METHOD, "return_expr": SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_RETURN_EXPR, "buildType": build_type_value, "building": building_value}

static func update_clip_radius_state(clip_size_before: float, size_value: int, tilesize_value: float, radius_in_world_units: float) -> Dictionary:
	var clip_size_candidate: float = size_value * tilesize_value + radius_in_world_units * 2.0
	var clip_size_after: float = max(clip_size_before, clip_size_candidate)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UPDATE_CLIP_RADIUS_STATE, "source": SOURCE_BLOCK_RUNTIME_GEOMETRY_SOURCE, "method": SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_METHOD, "assignment_expr": SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_ASSIGNMENT_EXPR, "clipSize_before": clip_size_before, "size": size_value, "tilesize": tilesize_value, "radiusInWorldUnits": radius_in_world_units, "clip_size_candidate": clip_size_candidate, "clipSize": clip_size_after}

static func bounds_state(x_value: int, y_value: int, size_value: int, tilesize_value: float, offset_value: float, rect_value: Variant = null) -> Dictionary:
	var rect_size: float = size_value * tilesize_value
	var center_x: float = x_value * tilesize_value + offset_value
	var center_y: float = y_value * tilesize_value + offset_value
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_BOUNDS_STATE, "source": SOURCE_BLOCK_RUNTIME_GEOMETRY_SOURCE, "method": SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_METHOD, "return_expr": SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_RETURN_EXPR, "x": x_value, "y": y_value, "size": size_value, "tilesize": tilesize_value, "offset": offset_value, "rect": rect_value, "rect_size": rect_size, "center": {"x": center_x, "y": center_y}}

static func generated_block_new_building_bridge_state(build_type_value: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_JAVA_METHOD, [build_type_value])
	var canonical = new_building_state(build_type_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_NEW_BUILDING_STATE, "generated_owner": SOURCE_BLOCK_RUNTIME_GEOMETRY_NEW_BUILDING_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_update_clip_radius_bridge_state(clip_size_before: float, size_value: int, tilesize_value: float, radius_in_world_units: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_JAVA_METHOD, [clip_size_before, size_value, tilesize_value, radius_in_world_units])
	var canonical = update_clip_radius_state(clip_size_before, size_value, tilesize_value, radius_in_world_units)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_UPDATE_CLIP_RADIUS_STATE, "generated_owner": SOURCE_BLOCK_RUNTIME_GEOMETRY_UPDATE_CLIP_RADIUS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_bounds_bridge_state(x_value: int, y_value: int, size_value: int, tilesize_value: float, offset_value: float, rect_value: Variant = null) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_JAVA_METHOD, [x_value, y_value, size_value, tilesize_value, offset_value, rect_value])
	var canonical = bounds_state(x_value, y_value, size_value, tilesize_value, offset_value, rect_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_BOUNDS_STATE, "generated_owner": SOURCE_BLOCK_RUNTIME_GEOMETRY_BOUNDS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
