extends "res://src/game/SourceBuildingSetPropPortBridge.gd"

const source_building_power_state := preload("res://src/game/SourceBuildingPowerState.gd")

func power_graph_role_for_block(block) -> Dictionary:
	return source_building_power_state.block_power_role_state(block)

func source_building_on_proximity_removed_state(power_present: bool) -> Dictionary:
	return source_building_power_state.on_proximity_removed_state(power_present)

func source_building_on_proximity_added_state(power_present: bool) -> Dictionary:
	return source_building_power_state.on_proximity_added_state(power_present)

func source_building_on_proximity_update_state() -> Dictionary:
	return source_building_power_state.on_proximity_update_state()

func source_building_update_power_graph_state(other_power_present_by_index: Array) -> Dictionary:
	return source_building_power_state.update_power_graph_state(other_power_present_by_index)

func source_building_power_graph_removed_state(power_present: bool, linked_build_present_by_index: Array, linked_build_power_present_by_index: Array) -> Dictionary:
	return source_building_power_state.power_graph_removed_state(power_present, linked_build_present_by_index, linked_build_power_present_by_index)

func source_building_conducts_to_state(block_insulated: bool) -> Dictionary:
	return source_building_power_state.conducts_to_state(block_insulated)

func source_building_get_power_connections_empty_guard_state(power_present: bool, previous_out_count: int) -> Dictionary:
	return source_building_power_state.get_power_connections_empty_guard_state(power_present, previous_out_count)

func source_building_get_power_connections_proximity_guard_state(other_present_by_index: Array, other_power_present_by_index: Array, other_same_team_by_index: Array) -> Dictionary:
	return source_building_power_state.get_power_connections_proximity_guard_state(other_present_by_index, other_power_present_by_index, other_same_team_by_index)

func source_building_get_power_connections_power_compatibility_guard_state(block_consumes_power: bool, block_outputs_power: bool, block_conductive_power: bool, other_block_consumes_power_by_index: Array, other_block_outputs_power_by_index: Array, other_block_conductive_power_by_index: Array) -> Dictionary:
	return source_building_power_state.get_power_connections_power_compatibility_guard_state(block_consumes_power, block_outputs_power, block_conductive_power, other_block_consumes_power_by_index, other_block_outputs_power_by_index, other_block_conductive_power_by_index)

func source_building_get_power_connections_conducts_link_guard_state(conducts_to_other_by_index: Array, other_conducts_to_self_by_index: Array, power_link_contains_other_pos_by_index: Array) -> Dictionary:
	return source_building_power_state.get_power_connections_conducts_link_guard_state(conducts_to_other_by_index, other_conducts_to_self_by_index, power_link_contains_other_pos_by_index)

func source_building_get_power_connections_automatic_add_state(conducts_link_guard_pass_indices: Array, previous_out_count: int) -> Dictionary:
	return source_building_power_state.get_power_connections_automatic_add_state(conducts_link_guard_pass_indices, previous_out_count)

func source_building_get_power_connections_manual_links_loop_state(link_present_by_index: Array, link_build_present_by_index: Array, link_build_power_present_by_index: Array, link_build_same_team_by_index: Array, previous_out_count: int) -> Dictionary:
	return source_building_power_state.get_power_connections_manual_links_loop_state(link_present_by_index, link_build_present_by_index, link_build_power_present_by_index, link_build_same_team_by_index, previous_out_count)

func source_building_get_power_connections_state(
	power_present: bool,
	previous_out_count: int,
	other_present_by_index: Array,
	other_power_present_by_index: Array,
	other_same_team_by_index: Array,
	block_consumes_power: bool,
	block_outputs_power: bool,
	block_conductive_power: bool,
	other_block_consumes_power_by_index: Array,
	other_block_outputs_power_by_index: Array,
	other_block_conductive_power_by_index: Array,
	conducts_to_other_by_index: Array,
	other_conducts_to_self_by_index: Array,
	power_link_contains_other_pos_by_index: Array,
	link_present_by_index: Array,
	link_build_present_by_index: Array,
	link_build_power_present_by_index: Array,
	link_build_same_team_by_index: Array
) -> Dictionary:
	return source_building_power_state.get_power_connections_state(
		power_present,
		previous_out_count,
		other_present_by_index,
		other_power_present_by_index,
		other_same_team_by_index,
		block_consumes_power,
		block_outputs_power,
		block_conductive_power,
		other_block_consumes_power_by_index,
		other_block_outputs_power_by_index,
		other_block_conductive_power_by_index,
		conducts_to_other_by_index,
		other_conducts_to_self_by_index,
		power_link_contains_other_pos_by_index,
		link_present_by_index,
		link_build_present_by_index,
		link_build_power_present_by_index,
		link_build_same_team_by_index
	)
