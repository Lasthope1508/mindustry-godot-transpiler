extends "res://src/game/SourceBuildingNavigationPortBridge.gd"

const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

func source_building_tile_x_state(tile_x: int) -> int:
	return source_building_access_state.tile_x_state(tile_x)

func source_building_tile_y_state(tile_y: int) -> int:
	return source_building_access_state.tile_y_state(tile_y)

func source_building_pos_state(tile_pos: int) -> int:
	return source_building_access_state.pos_state(tile_pos)

func source_building_floor_state(floor_value: Variant) -> Variant:
	return source_building_access_state.floor_state(floor_value)

func source_building_interactable_state(can_interact: bool) -> bool:
	return source_building_access_state.interactable_state(can_interact)

func source_building_allow_update_state(team_is_derelict: bool, block_supports_env: bool, editor_tile: bool, block_privileged: bool, limit_map_area: bool, disable_outside_area: bool, tile_x: int, tile_y: int, limit_x: int, limit_y: int, limit_width: int, limit_height: int) -> bool:
	return source_building_access_state.allow_update_state(team_is_derelict, block_supports_env, editor_tile, block_privileged, limit_map_area, disable_outside_area, tile_x, tile_y, limit_x, limit_y, limit_width, limit_height)

func source_building_in_map_area_state(limit_map_area: bool, limit_x: float, limit_y: float, limit_width: float, limit_height: float, source_x: float, source_y: float, tile_size: float) -> bool:
	return source_building_access_state.in_map_area_state(limit_map_area, limit_x, limit_y, limit_width, limit_height, source_x, source_y, tile_size)

func source_building_status_state(enabled: bool, should_consume: bool, efficiency: float, production_valid: bool, state_tick: float) -> String:
	return source_building_access_state.status_state(enabled, should_consume, efficiency, production_valid, state_tick)

func source_building_sleep_state(sleep_time: float, time_delta: float, sleeping: bool, sleeping_entities: int, time_to_sleep: float = source_building_access_state.SOURCE_BUILDING_SLEEP_TIME_TO_SLEEP) -> Dictionary:
	return source_building_access_state.sleep_state(sleep_time, time_delta, sleeping, sleeping_entities, time_to_sleep)

func source_building_no_sleep_state(sleeping: bool, sleeping_entities: int) -> Dictionary:
	return source_building_access_state.no_sleep_state(sleeping, sleeping_entities)

func source_building_can_withdraw_state() -> bool:
	return source_building_access_state.can_withdraw_state()

func source_building_can_unload_state(block_unloadable: bool) -> bool:
	return source_building_access_state.can_unload_state(block_unloadable)

func source_building_can_resupply_state(block_allow_resupply: bool) -> bool:
	return source_building_access_state.can_resupply_state(block_allow_resupply)

func source_building_payload_check_state(block_rotate: bool, rotation: int, conveyor_rotation: int) -> bool:
	return source_building_access_state.payload_check_state(block_rotate, rotation, conveyor_rotation)

func source_building_allow_deposit_state(block_always_allow_deposit: bool, only_deposit_core: bool) -> bool:
	return source_building_access_state.allow_deposit_state(block_always_allow_deposit, only_deposit_core)

func source_building_should_consume_state(enabled: bool) -> bool:
	return source_building_access_state.should_consume_state(enabled)

func source_building_production_valid_state() -> bool:
	return source_building_access_state.production_valid_state()

func source_building_consume_trigger_valid_state() -> bool:
	return source_building_access_state.consume_trigger_valid_state()

func generated_building_comp_tile_x_bridge_state(tile_x: int) -> Dictionary:
	return source_building_access_state.generated_tile_x_bridge_state(tile_x)

func generated_building_comp_tile_y_bridge_state(tile_y: int) -> Dictionary:
	return source_building_access_state.generated_tile_y_bridge_state(tile_y)

func generated_building_comp_pos_bridge_state(tile_pos: int) -> Dictionary:
	return source_building_access_state.generated_pos_bridge_state(tile_pos)

func generated_building_comp_floor_bridge_state(floor_value: Variant) -> Dictionary:
	return source_building_access_state.generated_floor_bridge_state(floor_value)

func generated_building_comp_interactable_bridge_state(can_interact: bool) -> Dictionary:
	return source_building_access_state.generated_interactable_bridge_state(can_interact)

func generated_building_comp_allow_update_bridge_state(team_is_derelict: bool, block_supports_env: bool, editor_tile: bool, block_privileged: bool, limit_map_area: bool, disable_outside_area: bool, tile_x: int, tile_y: int, limit_x: int, limit_y: int, limit_width: int, limit_height: int) -> Dictionary:
	return source_building_access_state.generated_allow_update_bridge_state(team_is_derelict, block_supports_env, editor_tile, block_privileged, limit_map_area, disable_outside_area, tile_x, tile_y, limit_x, limit_y, limit_width, limit_height)

func generated_building_comp_in_map_area_bridge_state(limit_map_area: bool, limit_x: float, limit_y: float, limit_width: float, limit_height: float, source_x: float, source_y: float, tile_size: float) -> Dictionary:
	return source_building_access_state.generated_in_map_area_bridge_state(limit_map_area, limit_x, limit_y, limit_width, limit_height, source_x, source_y, tile_size)

func generated_building_comp_status_bridge_state(enabled: bool, should_consume: bool, efficiency: float, production_valid: bool, state_tick: float) -> Dictionary:
	return source_building_access_state.generated_status_bridge_state(enabled, should_consume, efficiency, production_valid, state_tick)

func generated_building_comp_sleep_bridge_state(sleep_time: float, time_delta: float, sleeping: bool, sleeping_entities: int, time_to_sleep: float = source_building_access_state.SOURCE_BUILDING_SLEEP_TIME_TO_SLEEP) -> Dictionary:
	return source_building_access_state.generated_sleep_bridge_state(sleep_time, time_delta, sleeping, sleeping_entities, time_to_sleep)

func generated_building_comp_no_sleep_bridge_state(sleeping: bool, sleeping_entities: int) -> Dictionary:
	return source_building_access_state.generated_no_sleep_bridge_state(sleeping, sleeping_entities)

func generated_building_comp_can_withdraw_bridge_state() -> Dictionary:
	return source_building_access_state.generated_can_withdraw_bridge_state()

func generated_building_comp_can_unload_bridge_state(block_unloadable: bool) -> Dictionary:
	return source_building_access_state.generated_can_unload_bridge_state(block_unloadable)

func generated_building_comp_can_resupply_bridge_state(block_allow_resupply: bool) -> Dictionary:
	return source_building_access_state.generated_can_resupply_bridge_state(block_allow_resupply)

func generated_building_comp_payload_check_bridge_state(block_rotate: bool, rotation: int, conveyor_rotation: int) -> Dictionary:
	return source_building_access_state.generated_payload_check_bridge_state(block_rotate, rotation, conveyor_rotation)

func generated_building_comp_allow_deposit_bridge_state(block_always_allow_deposit: bool, only_deposit_core: bool) -> Dictionary:
	return source_building_access_state.generated_allow_deposit_bridge_state(block_always_allow_deposit, only_deposit_core)

func generated_building_comp_should_consume_bridge_state(enabled: bool) -> Dictionary:
	return source_building_access_state.generated_should_consume_bridge_state(enabled)

func generated_building_comp_production_valid_bridge_state() -> Dictionary:
	return source_building_access_state.generated_production_valid_bridge_state()

func generated_building_comp_consume_trigger_valid_bridge_state() -> Dictionary:
	return source_building_access_state.generated_consume_trigger_valid_bridge_state()
