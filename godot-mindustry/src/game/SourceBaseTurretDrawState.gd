extends RefCounted
class_name SourceBaseTurretDrawState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

static func draw_place_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool, source_tilesize: float, block_offset: float, range_value: float, fog_radius_multiplier: float, rules_fog: bool) -> Dictionary:
	var dash_circle_x: float = float(tile_x) * source_tilesize + block_offset
	var dash_circle_y: float = float(tile_y) * source_tilesize + block_offset
	var dash_circle_call: Dictionary = {
		"call": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);",
		"x": dash_circle_x,
		"y": dash_circle_y,
		"radius": range_value,
		"color": "Pal.placing",
	}
	var fog_dash_circle_called := fog_radius_multiplier < 0.99 and rules_fog
	var fog_dash_circle_call: Dictionary = {}
	if fog_dash_circle_called:
		fog_dash_circle_call = {
			"call": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range * fogRadiusMultiplier, Pal.lightishGray);",
			"x": dash_circle_x,
			"y": dash_circle_y,
			"radius": range_value * fog_radius_multiplier,
			"color": "Pal.lightishGray",
		}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_DRAW_PLACE_STATE,
		"method": "public void drawPlace(int x, int y, int rotation, boolean valid){",
		"override_expr": "@Override",
		"super_draw_place_expr": "super.drawPlace(x, y, rotation, valid);",
		"dash_circle_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);",
		"fog_guard_expr": "if(fogRadiusMultiplier < 0.99f && state.rules.fog){",
		"fog_dash_circle_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range * fogRadiusMultiplier, Pal.lightishGray);",
		"tile_x": tile_x,
		"tile_y": tile_y,
		"rotation": rotation_value,
		"valid": valid,
		"source_tilesize": source_tilesize,
		"block_offset": block_offset,
		"range": range_value,
		"fog_radius_multiplier": fog_radius_multiplier,
		"rules_fog": rules_fog,
		"dash_circle_x": dash_circle_x,
		"dash_circle_y": dash_circle_y,
		"super_draw_place_called": true,
		"dash_circle_call": dash_circle_call,
		"fog_dash_circle_called": fog_dash_circle_called,
		"fog_dash_circle_call": fog_dash_circle_call,
	}

static func generated_base_turret_draw_place_bridge_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool, source_tilesize: float, block_offset: float, range_value: float, fog_radius_multiplier: float, rules_fog: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/BaseTurret.gd", "java_method_drawPlace_3", [tile_x, tile_y, rotation_value, valid, source_tilesize, block_offset, range_value, fog_radius_multiplier, rules_fog], null)
	var canonical = draw_place_state(tile_x, tile_y, rotation_value, valid, source_tilesize, block_offset, range_value, fog_radius_multiplier, rules_fog)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_DRAW_PLACE_STATE,
		"generated_owner": "base_turret.java_method_drawPlace_3",
		"result": result,
		"canonical": canonical,
		"matches": result.get("dash_circle_call", null) == canonical.get("dash_circle_call", null) and result.get("fog_dash_circle_call", null) == canonical.get("fog_dash_circle_call", null) and result.get("super_draw_place_called", null) == canonical.get("super_draw_place_called", null),
	}

static func generated_base_turret_draw_place_source_tilesize_default_bridge_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/BaseTurret.gd", "java_method_drawPlace_3", [tile_x, tile_y, rotation_value, valid], null)
	var canonical = draw_place_state(tile_x, tile_y, rotation_value, valid, source_world_defaults.TILESIZE, 0.0, source_turret_defaults.RANGE_DEFAULT, source_turret_defaults.FOG_RADIUS_MULTIPLIER_DEFAULT, false)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_DRAW_PLACE_STATE,
		"generated_owner": "base_turret.java_method_drawPlace_3",
		"defaulted_arg": "source_tilesize",
		"source_tilesize": result.get("source_tilesize", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("dash_circle_call", null) == canonical.get("dash_circle_call", null) and result.get("fog_dash_circle_call", null) == canonical.get("fog_dash_circle_call", null) and result.get("super_draw_place_called", null) == canonical.get("super_draw_place_called", null),
	}
