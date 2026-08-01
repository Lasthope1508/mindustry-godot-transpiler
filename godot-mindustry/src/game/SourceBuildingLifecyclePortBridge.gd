extends "res://src/game/SourceWeaponsPortBridge.gd"

const source_building_lifecycle_port_bridge_state := preload("res://src/game/SourceBuildingLifecycleState.gd")

func generated_building_comp_check_suppression_bridge_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_check_suppression_bridge_state(block_suppressable, source_time, heal_suppression_time, source_delta, source_x, source_y, block_size_value, source_tilesize, suppress_color)

func generated_building_comp_player_placed_bridge_state(config_state: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_player_placed_bridge_state(config_state)

func generated_building_comp_placed_bridge_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_placed_bridge_state(net_client, consumes_power, outputs_power, has_power, connected_power, linked_to_self, source_pos)

func generated_building_comp_on_repaired_bridge_state(has_fog_radius: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_on_repaired_bridge_state(has_fog_radius)

func generated_building_comp_change_team_delegate_bridge_state(next_team: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_change_team_delegate_bridge_state(next_team)

func generated_building_comp_change_team_initial_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_change_team_initial_bridge_state(current_team, next_team, force_team, was_valid)

func generated_building_comp_change_team_power_proximity_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_change_team_power_proximity_bridge_state(current_team, next_team, force_team, was_valid, power_present, update_power, old_graph)

func generated_building_comp_change_team_power_links_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant, link_count: int) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_change_team_power_links_bridge_state(current_team, next_team, force_team, was_valid, power_present, update_power, old_graph, link_count)

func generated_building_comp_change_team_final_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant, link_count: int) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_change_team_final_bridge_state(current_team, next_team, force_team, was_valid, power_present, update_power, old_graph, link_count)

func generated_building_comp_can_pickup_bridge_state(block_can_pickup: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_can_pickup_bridge_state(block_can_pickup)

func generated_building_comp_picked_up_bridge_state(previous_state: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_picked_up_bridge_state(previous_state)

func generated_building_comp_after_picked_up_bridge_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_after_picked_up_bridge_state(power_present, has_cons_power, cons_power_buffered, current_status)

func generated_building_comp_remove_from_proximity_bridge_state(nearby_count: int, removable_count: int) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_remove_from_proximity_bridge_state(nearby_count, removable_count)

func generated_building_comp_update_proximity_bridge_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_update_proximity_bridge_state(nearby_count, same_team_count, headless, draw_cached)

func generated_building_comp_on_nearby_build_added_bridge_state(other_state: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_on_nearby_build_added_bridge_state(other_state)

func generated_building_comp_config_default_bridge_state() -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_config_default_bridge_state()

func generated_building_comp_is_valid_bridge_state(tile_build_matches_self: bool, dead_state: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_is_valid_bridge_state(tile_build_matches_self, dead_state)

func generated_building_comp_heal_bridge_state(amount: Variant = null) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_heal_bridge_state(amount)

func generated_building_comp_kill_bridge_state(self_state := {}) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_kill_bridge_state(self_state)

func source_building_is_heal_suppressed_state(block_suppressable: bool, source_time: float, heal_suppression_time: float) -> bool:
	return source_building_lifecycle_port_bridge_state.is_heal_suppressed_state(block_suppressable, source_time, heal_suppression_time)

func source_building_check_suppression_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.game_check_suppression_state(self, block_suppressable, source_time, heal_suppression_time, source_delta, source_x, source_y, block_size_value, source_tilesize, suppress_color)

func source_building_player_placed_state(config_state: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.player_placed_state(config_state)

func source_building_placed_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.placed_state(net_client, consumes_power, outputs_power, has_power, connected_power, linked_to_self, source_pos)

func source_building_on_repaired_state(has_fog_radius: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.on_repaired_state(has_fog_radius)

func source_building_change_team_delegate_state(next_team: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.change_team_delegate_state(next_team)

func source_building_change_team_initial_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.change_team_initial_state(current_team, next_team, force_team, was_valid)

func source_building_change_team_power_proximity_state(power_present: bool, update_power: bool, old_graph: Variant, team: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.change_team_power_proximity_state(power_present, update_power, old_graph, team)

func source_building_change_team_power_links_state(link_count: int, team: Variant, old_graph: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.change_team_power_links_state(link_count, team, old_graph)

func source_building_change_team_final_state(was: bool, last_team: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.change_team_final_state(was, last_team)

func source_building_can_pickup_state(block_can_pickup: bool) -> bool:
	return source_building_lifecycle_port_bridge_state.can_pickup_state(block_can_pickup)

func source_building_picked_up_state(previous_state: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.picked_up_state(previous_state)

func source_building_after_picked_up_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.after_picked_up_state(power_present, has_cons_power, cons_power_buffered, current_status)

func source_building_remove_from_proximity_state(nearby_count: int, removable_count: int) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.remove_from_proximity_state(nearby_count, removable_count)

func source_building_update_proximity_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.update_proximity_state(nearby_count, same_team_count, headless, draw_cached)

func source_building_on_nearby_build_added_state(other_state: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.on_nearby_build_added_state(other_state)

func source_building_config_default() -> Variant:
	return source_building_lifecycle_port_bridge_state.config_default()

func source_building_is_valid(tile_build_matches_self: bool, dead_state: bool) -> bool:
	return source_building_lifecycle_port_bridge_state.is_valid(tile_build_matches_self, dead_state)

func source_building_heal_state(_amount: Variant = null) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.heal_state(_amount)

func source_building_kill_state(self_state := {}) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.kill_state(self_state)

func generated_building_comp_killed_initial_side_effects_bridge_state(tile_value: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_killed_initial_side_effects_bridge_state(tile_value)

func generated_building_comp_killed_removal_side_effects_bridge_state(tile_value: Variant, tile_not_empty_tile: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_killed_removal_side_effects_bridge_state(tile_value, tile_not_empty_tile)

func source_building_killed_initial_side_effects_state(tile_value: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.killed_initial_side_effects_state(tile_value)

func source_building_killed_removal_side_effects_state(tile_not_empty_tile: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.killed_removal_side_effects_state(tile_not_empty_tile)

func generated_building_comp_check_allow_update_bridge_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_check_allow_update_bridge_state(current_enabled, allow_update_result)

func source_building_check_allow_update_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.check_allow_update_state(current_enabled, allow_update_result)

func source_building_update_tile_gate_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.update_tile_gate_state(enabled_state, block_no_update_disabled)

func generated_building_comp_update_tile_gate_bridge_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_update_tile_gate_bridge_state(enabled_state, block_no_update_disabled)
