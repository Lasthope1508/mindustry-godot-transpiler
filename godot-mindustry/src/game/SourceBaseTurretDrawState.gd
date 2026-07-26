extends RefCounted
class_name SourceBaseTurretDrawState

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
		"source_owner": "PortGame.source_base_turret_draw_place_state",
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
