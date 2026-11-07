extends "res://src/game/SourceComponentPortBridge.gd"

const source_base_turret_draw_state := preload("res://src/game/SourceBaseTurretDrawState.gd")

func source_base_turret_draw_place_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool, source_tilesize: float, block_offset: float, range_value: float, fog_radius_multiplier: float, rules_fog: bool) -> Dictionary:
	return source_base_turret_draw_state.draw_place_state(tile_x, tile_y, rotation_value, valid, source_tilesize, block_offset, range_value, fog_radius_multiplier, rules_fog)

func generated_base_turret_draw_place_bridge_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool, source_tilesize: float, block_offset: float, range_value: float, fog_radius_multiplier: float, rules_fog: bool) -> Dictionary:
	return source_base_turret_draw_state.generated_base_turret_draw_place_bridge_state(tile_x, tile_y, rotation_value, valid, source_tilesize, block_offset, range_value, fog_radius_multiplier, rules_fog)

func generated_base_turret_draw_place_source_tilesize_default_bridge_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool) -> Dictionary:
	return source_base_turret_draw_state.generated_base_turret_draw_place_source_tilesize_default_bridge_state(tile_x, tile_y, rotation_value, valid)
