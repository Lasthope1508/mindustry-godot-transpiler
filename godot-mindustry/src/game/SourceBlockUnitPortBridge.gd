extends "res://src/game/SourceSyncPortBridge.gd"

const source_block_unit_state := preload("res://src/game/SourceBlockUnitState.gd")

func source_block_unit_ammof_state(ammo: float) -> Dictionary:
	return source_block_unit_state.ammof_state(ammo)

func generated_block_unit_comp_ammof_bridge_state(ammo: float) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_ammof_bridge_state(ammo)

func source_block_unit_icon_state(tile_block_ui_icon: Variant) -> Dictionary:
	return source_block_unit_state.icon_state(tile_block_ui_icon)

func generated_block_unit_comp_icon_bridge_state(tile_block_ui_icon: Variant) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_icon_bridge_state(tile_block_ui_icon)

func source_block_unit_tile_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float, tilesize: float) -> Dictionary:
	return source_block_unit_state.tile_state(tile, tile_block_health, tile_health, tile_block_size, tilesize)

func generated_block_unit_comp_tile_bridge_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float, tilesize: float) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_tile_bridge_state(tile, tile_block_health, tile_health, tile_block_size, tilesize)

func generated_block_unit_comp_tile_source_tilesize_default_bridge_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_tile_source_tilesize_default_bridge_state(tile, tile_block_health, tile_health, tile_block_size)

func source_block_unit_add_state(tile_null: bool) -> Dictionary:
	return source_block_unit_state.add_state(tile_null)

func generated_block_unit_comp_add_bridge_state(tile_null: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_add_bridge_state(tile_null)

func source_block_unit_update_state(tile_exists: bool, team: Variant, tile_team: Variant) -> Dictionary:
	return source_block_unit_state.update_state(tile_exists, team, tile_team)

func generated_block_unit_comp_update_bridge_state(tile_exists: bool, team: Variant, tile_team: Variant) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_update_bridge_state(tile_exists, team, tile_team)

func source_block_unit_killed_state() -> Dictionary:
	return source_block_unit_state.killed_state()

func generated_block_unit_comp_killed_bridge_state() -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_killed_bridge_state()

func source_block_unit_damage_state(v: float, b: bool) -> Dictionary:
	return source_block_unit_state.damage_state(v, b)

func generated_block_unit_comp_damage_bridge_state(v: float, b: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_damage_bridge_state(v, b)

func source_block_unit_team_state(tile_exists: bool, this_team: Variant, team: Variant, tile_team: Variant) -> Dictionary:
	return source_block_unit_state.team_state(tile_exists, this_team, team, tile_team)

func generated_block_unit_comp_team_bridge_state(tile_exists: bool, this_team: Variant, team: Variant, tile_team: Variant) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_team_bridge_state(tile_exists, this_team, team, tile_team)

func source_block_unit_dead_state(tile_null: bool, tile_dead: bool) -> Dictionary:
	return source_block_unit_state.dead_state(tile_null, tile_dead)

func generated_block_unit_comp_dead_bridge_state(tile_null: bool, tile_dead: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_dead_bridge_state(tile_null, tile_dead)

func source_block_unit_is_valid_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return source_block_unit_state.is_valid_state(tile_exists, tile_is_valid)

func generated_block_unit_comp_is_valid_bridge_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_is_valid_bridge_state(tile_exists, tile_is_valid)

func source_block_unit_is_added_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return source_block_unit_state.is_added_state(tile_exists, tile_is_valid)

func generated_block_unit_comp_is_added_bridge_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_is_added_bridge_state(tile_exists, tile_is_valid)
