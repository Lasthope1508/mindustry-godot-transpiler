extends "res://src/game/SourceBuildingItemDumpPortBridge.gd"

const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")

func source_building_handle_liquid_amount(current_amount: float, amount: float) -> float:
	return source_building_liquid_state.handle_liquid_amount(current_amount, amount)

func source_building_accept_liquid_state(has_liquids: bool, consumes_liquid: bool) -> bool:
	return source_building_liquid_state.accept_liquid_state(has_liquids, consumes_liquid)

func source_building_dump_liquid_default_scaling_state(liquid: Variant, current_liquid_amount: float) -> Dictionary:
	return source_building_liquid_state.dump_liquid_default_scaling_state(liquid, current_liquid_amount)

func source_building_dump_liquid_campaign_unlock_state(liquid: Variant, current_liquid_amount: float, net_client: bool, state_is_campaign: bool, team_is_default_team: bool) -> Dictionary:
	return source_building_liquid_state.dump_liquid_campaign_unlock_state(liquid, current_liquid_amount, net_client, state_is_campaign, team_is_default_team)

func source_building_dump_liquid_routing_gate_state(liquid: Variant, proximity_size: int, dump_cursor: int, output_dir: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array) -> Dictionary:
	return source_building_liquid_state.game_dump_liquid_routing_gate_state(self, liquid, proximity_size, dump_cursor, output_dir, rotation_value, relative_to_by_index, destination_present_by_index, other_has_liquids_by_index, can_dump_liquid_by_index, other_liquids_present_by_index)

func source_building_dump_liquid_fraction_transfer_state(liquid: Variant, scaling: float, eligible_indices: Array, current_liquid_amount: float, block_liquid_capacity: float, other_liquid_amount_by_index: Array, other_block_liquid_capacity_by_index: Array) -> Dictionary:
	return source_building_liquid_state.dump_liquid_fraction_transfer_state(liquid, scaling, eligible_indices, current_liquid_amount, block_liquid_capacity, other_liquid_amount_by_index, other_block_liquid_capacity_by_index)

func source_building_dump_liquid_state(liquid: Variant, scaling: float, output_dir: int, current_liquid_amount: float, net_client: bool, state_is_campaign: bool, team_is_default_team: bool, proximity_size: int, dump_cursor: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array, other_liquid_amount_by_index: Array, other_block_liquid_capacity_by_index: Array, other_accepts_liquid_by_index: Array, block_liquid_capacity: float) -> Dictionary:
	return source_building_liquid_state.dump_liquid_state(liquid, scaling, output_dir, current_liquid_amount, net_client, state_is_campaign, team_is_default_team, proximity_size, dump_cursor, rotation_value, relative_to_by_index, destination_present_by_index, other_has_liquids_by_index, can_dump_liquid_by_index, other_liquids_present_by_index, other_liquid_amount_by_index, other_block_liquid_capacity_by_index, other_accepts_liquid_by_index, block_liquid_capacity, Callable(source_building_item_dump_state, "increment_dump_cursor_state"))

func source_building_transfer_liquid_state(liquid: Variant, amount: float, next_block_liquid_capacity: float, next_liquid_amount: float, next_accepts_liquid: bool, current_liquid_amount: float) -> Dictionary:
	return source_building_liquid_state.transfer_liquid_state(liquid, amount, next_block_liquid_capacity, next_liquid_amount, next_accepts_liquid, current_liquid_amount)

func source_building_can_dump_liquid_default_state(to_state: Variant, liquid: Variant) -> Dictionary:
	return source_building_liquid_state.can_dump_liquid_default_state(to_state, liquid)

func source_building_get_liquid_destination_default_state(from_state: Variant, liquid: Variant, self_state: Variant) -> Dictionary:
	return source_building_liquid_state.get_liquid_destination_default_state(from_state, liquid, self_state)

func source_building_move_liquid_forward_state(leaks: bool, liquid: Variant, next_tile_present: bool, next_build_present: bool, next_block_solid: bool, next_block_has_liquids: bool, current_liquid_amount: float, move_liquid_return: float) -> Dictionary:
	return source_building_liquid_state.move_liquid_forward_state(leaks, liquid, next_tile_present, next_build_present, next_block_solid, next_block_has_liquids, current_liquid_amount, move_liquid_return)

func source_building_move_liquid_state(liquid: Variant, next_present: bool, destination_team_matches: bool, destination_block_has_liquids: bool, current_liquid_amount: float, destination_liquid_amount: float, source_block_liquid_capacity: float, source_block_liquid_pressure: float, destination_block_liquid_capacity: float, destination_accepts_liquid: bool) -> Dictionary:
	return source_building_liquid_state.move_liquid_state(liquid, next_present, destination_team_matches, destination_block_has_liquids, current_liquid_amount, destination_liquid_amount, source_block_liquid_capacity, source_block_liquid_pressure, destination_block_liquid_capacity, destination_accepts_liquid)

func source_building_move_liquid_reaction_setup_state(main_guard_passed: bool, transfer_guard_passed: bool, destination_consumes_liquid: bool, destination_current_amount: float, destination_block_liquid_capacity: float, fract_value: float, source_x: float, source_y: float, destination_x: float, destination_y: float, destination_current_liquid: Variant, other_block_reactive: bool, liquid_block_reactive: bool) -> Dictionary:
	return source_building_liquid_state.move_liquid_reaction_setup_state(main_guard_passed, transfer_guard_passed, destination_consumes_liquid, destination_current_amount, destination_block_liquid_capacity, fract_value, source_x, source_y, destination_x, destination_y, destination_current_liquid, other_block_reactive, liquid_block_reactive)

func source_building_move_liquid_fire_reaction_state(block_reactive_guard_passed: bool, other_flammability: float, liquid_temperature: float, liquid_flammability: float, other_temperature: float, fire_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	return source_building_liquid_state.move_liquid_fire_reaction_state(block_reactive_guard_passed, other_flammability, liquid_temperature, liquid_flammability, other_temperature, fire_chance_delta_passed, fx, fy)

func source_building_move_liquid_steam_reaction_state(block_reactive_guard_passed: bool, fire_reaction_guard_passed: bool, liquid_temperature: float, other_temperature: float, current_liquid_amount: float, source_delta: float, steam_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	return source_building_liquid_state.move_liquid_steam_reaction_state(block_reactive_guard_passed, fire_reaction_guard_passed, liquid_temperature, other_temperature, current_liquid_amount, source_delta, steam_chance_delta_passed, fx, fy)

func source_building_move_liquid_return_zero_state(next_present: bool, transfer_guard_passed: bool) -> Dictionary:
	return source_building_liquid_state.move_liquid_return_zero_state(next_present, transfer_guard_passed)
