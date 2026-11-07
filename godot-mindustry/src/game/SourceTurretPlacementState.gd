extends RefCounted
class_name SourceTurretPlacementState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TURRET_GENERATED_CLASS
const SOURCE_TURRET_OVERRIDE_EXPR := source_turret_source_text_state.SOURCE_TURRET_OVERRIDE_EXPR
const SOURCE_TURRET_DRAW_PLACE_METHOD := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLACE_METHOD
const SOURCE_TURRET_DRAW_PLACE_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLACE_JAVA_METHOD
const SOURCE_TURRET_DRAW_PLACE_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLACE_GENERATED_OWNER
const SOURCE_TURRET_DRAW_PLACE_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLACE_SUPER_EXPR
const SOURCE_TURRET_DRAW_PLACE_MIN_RANGE_GATE := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLACE_MIN_RANGE_GATE
const SOURCE_TURRET_DRAW_PLACE_DASH_CIRCLE_EXPR := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLACE_DASH_CIRCLE_EXPR
const SOURCE_TURRET_ROTATED_OUTPUT_METHOD := source_turret_source_text_state.SOURCE_TURRET_ROTATED_OUTPUT_METHOD
const SOURCE_TURRET_ROTATED_OUTPUT_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_ROTATED_OUTPUT_JAVA_METHOD
const SOURCE_TURRET_ROTATED_OUTPUT_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_ROTATED_OUTPUT_GENERATED_OWNER
const SOURCE_TURRET_ROTATED_OUTPUT_RETURN_EXPR := source_turret_source_text_state.SOURCE_TURRET_ROTATED_OUTPUT_RETURN_EXPR
const SOURCE_TURRET_PLACE_ENDED_METHOD := source_turret_source_text_state.SOURCE_TURRET_PLACE_ENDED_METHOD
const SOURCE_TURRET_PLACE_ENDED_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_PLACE_ENDED_JAVA_METHOD
const SOURCE_TURRET_PLACE_ENDED_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_PLACE_ENDED_GENERATED_OWNER
const SOURCE_TURRET_PLACE_ENDED_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_PLACE_ENDED_SUPER_EXPR
const SOURCE_TURRET_PLACE_ENDED_GATE_EXPR := source_turret_source_text_state.SOURCE_TURRET_PLACE_ENDED_GATE_EXPR
const SOURCE_TURRET_PLACE_ENDED_ROTATION_ASSIGN_EXPR := source_turret_source_text_state.SOURCE_TURRET_PLACE_ENDED_ROTATION_ASSIGN_EXPR

static func _turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func draw_place_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float, block_offset: float, min_range: float) -> Dictionary:
	var dash_circle_x: float = float(tile_x) * source_tilesize + block_offset
	var dash_circle_y: float = float(tile_y) * source_tilesize + block_offset
	var dash_circle_called: bool = draw_min_range
	var dash_circle_call: Dictionary = {}
	if dash_circle_called:
		dash_circle_call = {"call": SOURCE_TURRET_DRAW_PLACE_DASH_CIRCLE_EXPR, "x": dash_circle_x, "y": dash_circle_y, "radius": min_range, "color": "Pal.placing"}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLACE_STATE,
		"method": SOURCE_TURRET_DRAW_PLACE_METHOD,
		"override_expr": SOURCE_TURRET_OVERRIDE_EXPR,
		"super_draw_place_expr": SOURCE_TURRET_DRAW_PLACE_SUPER_EXPR,
		"draw_min_range_gate": SOURCE_TURRET_DRAW_PLACE_MIN_RANGE_GATE,
		"dash_circle_expr": SOURCE_TURRET_DRAW_PLACE_DASH_CIRCLE_EXPR,
		"tile_x": tile_x,
		"tile_y": tile_y,
		"rotation": rotation,
		"valid": valid,
		"draw_min_range": draw_min_range,
		"source_tilesize": source_tilesize,
		"block_offset": block_offset,
		"min_range": min_range,
		"dash_circle_x": dash_circle_x,
		"dash_circle_y": dash_circle_y,
		"dash_circle_called": dash_circle_called,
		"dash_circle_call": dash_circle_call,
	}

static func generated_draw_place_bridge_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float, block_offset: float, min_range: float) -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_DRAW_PLACE_JAVA_METHOD, [tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range])
	var canonical = draw_place_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLACE_STATE,
		"generated_owner": SOURCE_TURRET_DRAW_PLACE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("dash_circle_called", null) == canonical.get("dash_circle_called", null) and result.get("dash_circle_call", null) == canonical.get("dash_circle_call", null),
	}

static func generated_draw_place_source_tilesize_default_bridge_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float) -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_DRAW_PLACE_JAVA_METHOD, [tile_x, tile_y, rotation, valid, draw_min_range])
	var canonical = draw_place_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, 0.0, 0.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLACE_STATE,
		"generated_owner": SOURCE_TURRET_DRAW_PLACE_GENERATED_OWNER,
		"defaulted_arg": "source_tilesize",
		"result": result,
		"canonical": canonical,
		"source_tilesize": result.get("source_tilesize", null),
		"matches": result.get("dash_circle_called", null) == canonical.get("dash_circle_called", null),
	}

static func rotated_output_state(tile_x: int, tile_y: int) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_ROTATED_OUTPUT_STATE,
		"method": SOURCE_TURRET_ROTATED_OUTPUT_METHOD,
		"override_expr": SOURCE_TURRET_OVERRIDE_EXPR,
		"return_expr": SOURCE_TURRET_ROTATED_OUTPUT_RETURN_EXPR,
		"tile_x": tile_x,
		"tile_y": tile_y,
		"rotated_output": false,
	}

static func generated_rotated_output_bridge_state(tile_x: int, tile_y: int) -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_ROTATED_OUTPUT_JAVA_METHOD, [tile_x, tile_y])
	var canonical = rotated_output_state(tile_x, tile_y)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_ROTATED_OUTPUT_STATE,
		"generated_owner": SOURCE_TURRET_ROTATED_OUTPUT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("rotated_output", null) == canonical.get("rotated_output", null),
	}

static func place_ended_state(tile: Variant, builder: Variant, rotation: int, config: Variant, rotate: bool, tile_build_is_turret_build: bool, turret_rotation: float, tile_build_rotdeg: float) -> Dictionary:
	var rotation_assigned: bool = rotate and tile_build_is_turret_build
	var turret_rotation_after: float = tile_build_rotdeg if rotation_assigned else turret_rotation
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_PLACE_ENDED_STATE,
		"method": SOURCE_TURRET_PLACE_ENDED_METHOD,
		"override_expr": SOURCE_TURRET_OVERRIDE_EXPR,
		"super_place_ended_expr": SOURCE_TURRET_PLACE_ENDED_SUPER_EXPR,
		"place_ended_gate": SOURCE_TURRET_PLACE_ENDED_GATE_EXPR,
		"rotation_assign_expr": SOURCE_TURRET_PLACE_ENDED_ROTATION_ASSIGN_EXPR,
		"tile": tile,
		"builder": builder,
		"rotation": rotation,
		"config": config,
		"rotate": rotate,
		"tile_build_is_turret_build": tile_build_is_turret_build,
		"turret_rotation": turret_rotation,
		"tile_build_rotdeg": tile_build_rotdeg,
		"super_place_ended_called": true,
		"rotation_assigned": rotation_assigned,
		"turret_rotation_after": turret_rotation_after,
	}

static func generated_place_ended_bridge_state(tile: Variant, builder: Variant, rotation: int, config: Variant, rotate: bool, tile_build_is_turret_build: bool, turret_rotation: float, tile_build_rotdeg: float) -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_PLACE_ENDED_JAVA_METHOD, [tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg])
	var canonical = place_ended_state(tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_PLACE_ENDED_STATE,
		"generated_owner": SOURCE_TURRET_PLACE_ENDED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("rotation_assigned", null) == canonical.get("rotation_assigned", null) and result.get("turret_rotation_after", null) == canonical.get("turret_rotation_after", null),
	}
