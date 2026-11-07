extends "res://src/game/SourceBuildingCompStatePortBridge.gd"

const source_building_item_payload_port_bridge_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const source_building_item_payload_port_bridge_payload_state := preload("res://src/game/SourceBuildingPayloadState.gd")

func source_building_handle_item_count(current_count: int) -> int:
	return source_building_item_payload_port_bridge_item_state.handle_item_count(current_count)

func source_building_accept_item_state(consumes_item: bool, item_count: int, maximum_accepted: int) -> bool:
	return source_building_item_payload_port_bridge_item_state.accept_item_state(consumes_item, item_count, maximum_accepted)

func source_building_maximum_accepted(block_item_capacity: int) -> int:
	return source_building_item_payload_port_bridge_item_state.maximum_accepted(block_item_capacity)

func source_building_handle_stack_count(current_count: int, amount: int) -> int:
	return source_building_item_payload_port_bridge_item_state.handle_stack_count(current_count, amount)

func source_building_accept_stack_state(accepts_item: bool, has_items: bool, same_team_or_null_source: bool, maximum_accepted: int, item_count: int, amount: int) -> int:
	return source_building_item_payload_port_bridge_item_state.accept_stack_state(accepts_item, has_items, same_team_or_null_source, maximum_accepted, item_count, amount)

func source_building_remove_stack_state(has_items_module: bool, item_count: int, amount: int) -> Dictionary:
	return source_building_item_payload_port_bridge_item_state.remove_stack_state(has_items_module, item_count, amount)

func source_building_accept_payload_state() -> bool:
	return source_building_item_payload_port_bridge_payload_state.accept_payload_state()

func source_building_handle_payload_state(payload_state: Variant) -> Variant:
	return source_building_item_payload_port_bridge_payload_state.handle_payload_state(payload_state)

func source_building_handle_unit_payload_state(unit: Variant, grabber: Variant, dependencies: Dictionary = {}) -> Dictionary:
	return source_building_item_payload_port_bridge_payload_state.handle_unit_payload_state(unit, grabber, dependencies)

func generated_building_comp_handle_unit_payload_bridge_state(unit: Variant, grabber: Variant, dependencies: Dictionary = {}) -> Dictionary:
	return source_building_item_payload_port_bridge_payload_state.generated_handle_unit_payload_bridge_state(unit, grabber, dependencies)

func source_payload_forward_offset(payload_block_size: int) -> int:
	return source_building_item_payload_port_bridge_payload_state.payload_forward_offset(payload_block_size)

func source_move_payload_state(has_next_tile: bool, has_next_build: bool, same_team: bool, accepts_payload: bool) -> bool:
	return source_building_item_payload_port_bridge_payload_state.move_payload_state(has_next_tile, has_next_build, same_team, accepts_payload)

func source_dump_payload_index(loop_index: int, dump_cursor: int, proximity_size: int) -> int:
	return source_building_item_payload_port_bridge_payload_state.dump_payload_index(loop_index, dump_cursor, proximity_size)

func source_dump_payload_state(proximity_size: int, dump_cursor: int, accepts_payload_by_index: Array) -> Dictionary:
	return source_building_item_payload_port_bridge_payload_state.game_dump_payload_state(self, proximity_size, dump_cursor, accepts_payload_by_index)

func source_building_get_payload_default_state() -> Dictionary:
	return source_building_item_payload_port_bridge_payload_state.get_payload_default_state()

func source_building_take_payload_default_state() -> Dictionary:
	return source_building_item_payload_port_bridge_payload_state.take_payload_default_state()

func source_building_get_payloads_default_state() -> Dictionary:
	return source_building_item_payload_port_bridge_payload_state.get_payloads_default_state()

func source_move_forward_accept_state(has_front: bool, same_team: bool, front_accepts: bool) -> bool:
	return source_building_item_payload_port_bridge_item_state.move_forward_accept_state(has_front, same_team, front_accepts)

func source_move_forward_to_core(item_id: String, has_front := true, same_team := true) -> bool:
	return source_building_item_payload_port_bridge_item_state.move_forward_to_core_runtime_state(self, item_id, has_front, same_team)
