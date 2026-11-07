extends "res://src/game/SourceWeaponsPortBridge.gd"

const source_building_lifecycle_port_bridge_state := preload("res://src/game/SourceBuildingLifecycleState.gd")
const source_building_lifecycle_pickup_state := preload("res://src/game/SourceBuildingLifecyclePickupState.gd")
const source_building_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_lifecycle_source_text_state := preload("res://src/game/SourceBuildingLifecycleSourceTextState.gd")

func generated_building_comp_init_bridge_state(initialized: bool, block_has_power: bool, should_add: bool, tile_state: Variant, team_state: Variant, rotation: int, draw_x: float, draw_y: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_init_bridge_state(initialized, block_has_power, should_add, tile_state, team_state, rotation, draw_x, draw_y)

func generated_building_comp_create_bridge_state(block_state: Variant, team_state: Variant, block_health: float, block_timers: int, has_items: bool, has_liquids: bool, has_power: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_create_bridge_state(block_state, team_state, block_health, block_timers, has_items, has_liquids, has_power)

func generated_building_comp_add_bridge_state(power_present: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_add_bridge_state(power_present)

func source_building_init_state(initialized: bool, block_has_power: bool, should_add: bool, tile_state: Variant, team_state: Variant, rotation: int, draw_x: float, draw_y: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.init_state(initialized, block_has_power, should_add, tile_state, team_state, rotation, draw_x, draw_y)

func source_building_create_state(block_state: Variant, team_state: Variant, block_health: float, block_timers: int, has_items: bool, has_liquids: bool, has_power: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.create_state(block_state, team_state, block_health, block_timers, has_items, has_liquids, has_power)

func source_building_add_state(power_present: bool) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.add_state(power_present)

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
	return source_building_lifecycle_pickup_state.generated_can_pickup_bridge_state(block_can_pickup)

func generated_building_comp_picked_up_bridge_state(previous_state: Variant) -> Dictionary:
	return source_building_lifecycle_pickup_state.generated_picked_up_bridge_state(previous_state)

func generated_building_comp_after_picked_up_bridge_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	return source_building_lifecycle_pickup_state.generated_after_picked_up_bridge_state(power_present, has_cons_power, cons_power_buffered, current_status)

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

func source_building_empty_lifecycle_callbacks_state(generated_method: String) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.empty_lifecycle_callback_state(generated_method)

func generated_building_comp_empty_lifecycle_callbacks_bridge_state(generated_method: String, args: Array) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_empty_lifecycle_callbacks_bridge_state(generated_method, args)

func source_building_heal_suppression_state(heal_suppression_time: float, source_time: float, amount: float, suppress_color: Variant = source_building_lifecycle_source_text_state.HEAL_SUPPRESSION_DEFAULT_COLOR) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.apply_heal_suppression_state(heal_suppression_time, source_time, amount, suppress_color)

func generated_building_comp_apply_heal_suppression_bridge_state(heal_suppression_time: float, source_time: float, amount: float, suppress_color: Variant = source_building_lifecycle_source_text_state.HEAL_SUPPRESSION_DEFAULT_COLOR, use_color_overload: bool = true) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_apply_heal_suppression_bridge_state(heal_suppression_time, source_time, amount, suppress_color, use_color_overload)

func generated_building_comp_is_heal_suppressed_bridge_state(block_suppressable: bool, source_time: float, heal_suppression_time: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_is_heal_suppressed_bridge_state(block_suppressable, source_time, heal_suppression_time)

func source_building_recently_healed_state(source_time: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.recently_healed_state(source_time)

func source_building_was_recently_healed_state(last_heal_time: float, duration: float, source_time: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.was_recently_healed_state(last_heal_time, duration, source_time)

func source_building_was_recently_damaged_state(last_damage_time: float, recent_damage_time: float, source_time: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.was_recently_damaged_state(last_damage_time, recent_damage_time, source_time)

func source_building_health_recent_state(source_time: float, last_heal_time: float, heal_duration: float, last_damage_time: float, recent_damage_time: float) -> Dictionary:
	return {
		"source_owner": source_building_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HEALTH_RECENT_STATE,
		"recently_healed": source_building_lifecycle_port_bridge_state.recently_healed_state(source_time),
		"was_recently_healed": source_building_lifecycle_port_bridge_state.was_recently_healed_state(last_heal_time, heal_duration, source_time),
		"was_recently_damaged": source_building_lifecycle_port_bridge_state.was_recently_damaged_state(last_damage_time, recent_damage_time, source_time),
	}

func generated_building_comp_recently_healed_bridge_state(source_time: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_recently_healed_bridge_state(source_time)

func generated_building_comp_was_recently_healed_bridge_state(last_heal_time: float, duration: float, source_time: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_was_recently_healed_bridge_state(last_heal_time, duration, source_time)

func generated_building_comp_was_recently_damaged_bridge_state(last_damage_time: float, recent_damage_time: float, source_time: float) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_was_recently_damaged_bridge_state(last_damage_time, recent_damage_time, source_time)

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
	return source_building_lifecycle_pickup_state.can_pickup_state(block_can_pickup)

func source_building_picked_up_state(previous_state: Variant) -> Dictionary:
	return source_building_lifecycle_pickup_state.picked_up_state(previous_state)

func source_building_after_picked_up_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	return source_building_lifecycle_pickup_state.after_picked_up_state(power_present, has_cons_power, cons_power_buffered, current_status)

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

func source_building_update_payload_state(update_state: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.update_payload_state(update_state, unit_holder, building_holder)

func generated_building_comp_update_payload_bridge_state(unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_update_payload_bridge_state(unit_holder, building_holder)

func source_building_update_tile_noop_state() -> Dictionary:
	return source_building_lifecycle_port_bridge_state.update_tile_noop_state()

func generated_building_comp_update_tile_noop_bridge_state() -> Dictionary:
	return source_building_lifecycle_port_bridge_state.generated_update_tile_noop_bridge_state()
