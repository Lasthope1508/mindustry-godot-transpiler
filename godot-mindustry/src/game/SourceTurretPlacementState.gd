extends RefCounted
class_name SourceTurretPlacementState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SOURCE_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd"

static func _turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func draw_place_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float, block_offset: float, min_range: float) -> Dictionary:
	var dash_circle_x: float = float(tile_x) * source_tilesize + block_offset
	var dash_circle_y: float = float(tile_y) * source_tilesize + block_offset
	var dash_circle_called: bool = draw_min_range
	var dash_circle_call: Dictionary = {}
	if dash_circle_called:
		dash_circle_call = {"call": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);", "x": dash_circle_x, "y": dash_circle_y, "radius": min_range, "color": "Pal.placing"}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLACE_STATE,
		"method": "public void drawPlace(int x, int y, int rotation, boolean valid){",
		"override_expr": "@Override",
		"super_draw_place_expr": "super.drawPlace(x, y, rotation, valid);",
		"draw_min_range_gate": "if(drawMinRange){",
		"dash_circle_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);",
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
	var result = _turret_call("java_method_drawPlace_9", [tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range])
	var canonical = draw_place_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLACE_STATE,
		"generated_owner": "turret.java_method_drawPlace_9",
		"result": result,
		"canonical": canonical,
		"matches": result.get("dash_circle_called", null) == canonical.get("dash_circle_called", null) and result.get("dash_circle_call", null) == canonical.get("dash_circle_call", null),
	}

static func generated_draw_place_source_tilesize_default_bridge_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float) -> Dictionary:
	var result = _turret_call("java_method_drawPlace_9", [tile_x, tile_y, rotation, valid, draw_min_range])
	var canonical = draw_place_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, 0.0, 0.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLACE_STATE,
		"generated_owner": "turret.java_method_drawPlace_9",
		"defaulted_arg": "source_tilesize",
		"result": result,
		"canonical": canonical,
		"source_tilesize": result.get("source_tilesize", null),
		"matches": result.get("dash_circle_called", null) == canonical.get("dash_circle_called", null),
	}

static func rotated_output_state(tile_x: int, tile_y: int) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_ROTATED_OUTPUT_STATE,
		"method": "public boolean rotatedOutput(int x, int y){",
		"override_expr": "@Override",
		"return_expr": "return false;",
		"tile_x": tile_x,
		"tile_y": tile_y,
		"rotated_output": false,
	}

static func generated_rotated_output_bridge_state(tile_x: int, tile_y: int) -> Dictionary:
	var result = _turret_call("java_method_rotatedOutput_10", [tile_x, tile_y])
	var canonical = rotated_output_state(tile_x, tile_y)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_ROTATED_OUTPUT_STATE,
		"generated_owner": "turret.java_method_rotatedOutput_10",
		"result": result,
		"canonical": canonical,
		"matches": result.get("rotated_output", null) == canonical.get("rotated_output", null),
	}

static func place_ended_state(tile: Variant, builder: Variant, rotation: int, config: Variant, rotate: bool, tile_build_is_turret_build: bool, turret_rotation: float, tile_build_rotdeg: float) -> Dictionary:
	var rotation_assigned: bool = rotate and tile_build_is_turret_build
	var turret_rotation_after: float = tile_build_rotdeg if rotation_assigned else turret_rotation
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_PLACE_ENDED_STATE,
		"method": "public void placeEnded(Tile tile, @Nullable Unit builder, int rotation, @Nullable Object config){",
		"override_expr": "@Override",
		"super_place_ended_expr": "super.placeEnded(tile, builder, rotation, config);",
		"place_ended_gate": "if(rotate && tile.build instanceof TurretBuild turret){",
		"rotation_assign_expr": "turret.rotation = tile.build.rotdeg();",
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
	var result = _turret_call("java_method_placeEnded_11", [tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg])
	var canonical = place_ended_state(tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_PLACE_ENDED_STATE,
		"generated_owner": "turret.java_method_placeEnded_11",
		"result": result,
		"canonical": canonical,
		"matches": result.get("rotation_assigned", null) == canonical.get("rotation_assigned", null) and result.get("turret_rotation_after", null) == canonical.get("turret_rotation_after", null),
	}
