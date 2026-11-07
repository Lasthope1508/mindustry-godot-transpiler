extends "res://src/game/SourceBuildingDisplayPortBridge.gd"

const source_building_meta_state := preload("res://src/game/SourceBuildingMetaState.gd")
const source_building_control_state := preload("res://src/game/SourceBuildingControlState.gd")
const source_building_visibility_state := preload("res://src/game/SourceBuildingVisibilityState.gd")
const source_building_plan_state := preload("res://src/game/SourceBuildingPlanState.gd")
const source_building_comp_state_port_bridge_math_defaults := preload("res://src/game/SourceMathDefaults.gd")

func generated_building_comp_get_cursor_bridge_state(block_configurable: bool, interactable_player_team: bool) -> Dictionary:
	return source_building_meta_state.generated_cursor_bridge_state(block_configurable, interactable_player_team)

func generated_building_comp_health_changed_bridge_state(net_server: bool, self_state := {}) -> Dictionary:
	return source_building_meta_state.generated_health_changed_bridge_state(net_server, self_state)

func source_building_cursor_state(block_configurable: bool, interactable_player_team: bool) -> String:
	return source_building_meta_state.cursor_state(block_configurable, interactable_player_team)

func source_building_health_changed_state(net_server: bool, self_state := {}) -> Dictionary:
	return source_building_meta_state.health_changed_state(net_server, self_state)

func source_building_control_enabled_state(current_enabled: bool, control_type: String, p1: float) -> Dictionary:
	return source_building_control_state.control_enabled_state(current_enabled, control_type, p1, source_building_comp_state_port_bridge_math_defaults.FLOAT_ROUNDING_ERROR)

func generated_building_comp_control_enabled_bridge_state(current_enabled: bool, control_type: String, p1: float) -> Dictionary:
	return source_building_control_state.generated_control_enabled_bridge_state(current_enabled, control_type, p1, source_building_comp_state_port_bridge_math_defaults.FLOAT_ROUNDING_ERROR)

func source_building_control_config_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	return source_building_control_state.control_config_state(control_type, block_logic_configurable, p1_is_logic_build, p1_value)

func generated_building_comp_control_config_bridge_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	return source_building_control_state.generated_control_config_bridge_state(control_type, block_logic_configurable, p1_is_logic_build, p1_value)

func source_building_can_control_select_state(player_state: Variant) -> Dictionary:
	return source_building_control_state.can_control_select_state(player_state)

func source_building_on_control_select_state(player_state: Variant) -> Dictionary:
	return source_building_control_state.on_control_select_state(player_state)

func source_building_on_command_state(target_state: Variant) -> Dictionary:
	return source_building_control_state.on_command_state(target_state)

func source_building_get_command_position_state() -> Dictionary:
	return source_building_control_state.get_command_position_state()

func generated_building_comp_can_control_select_bridge_state(player_state: Variant) -> Dictionary:
	return source_building_control_state.generated_can_control_select_bridge_state(player_state)

func generated_building_comp_on_control_select_bridge_state(player_state: Variant) -> Dictionary:
	return source_building_control_state.generated_on_control_select_bridge_state(player_state)

func generated_building_comp_on_command_bridge_state(target_state: Variant) -> Dictionary:
	return source_building_control_state.generated_on_command_bridge_state(target_state)

func generated_building_comp_get_command_position_bridge_state() -> Dictionary:
	return source_building_control_state.generated_get_command_position_bridge_state()

func source_building_is_discovered_state(limit_map_area: bool, darkness: float, viewer_present: bool, static_fog: bool, rules_fog: bool, block_size_value: int, tile_x: int, tile_y: int, fog_discovered_lookup: Callable) -> Dictionary:
	return source_building_visibility_state.is_discovered_state(limit_map_area, darkness, viewer_present, static_fog, rules_fog, block_size_value, tile_x, tile_y, fog_discovered_lookup)

func generated_building_comp_is_discovered_bridge_state(limit_map_area: bool, darkness: float, viewer_present: bool, static_fog: bool, rules_fog: bool, block_size_value: int, tile_x: int, tile_y: int, fog_discovered_lookup: Callable) -> Dictionary:
	return source_building_visibility_state.generated_is_discovered_bridge_state(limit_map_area, darkness, viewer_present, static_fog, rules_fog, block_size_value, tile_x, tile_y, fog_discovered_lookup)

func source_building_add_plan_state(check_previous: bool, ignore_conditions: bool, rebuildable: bool, is_default_team: bool, is_campaign: bool, block_visible: bool, is_construct_build: bool, construct_current_synthetic: bool, construct_was_constructing: bool, construct_current: Variant, construct_last_config: Variant, block_value: Variant, current_config: Variant, tile_x: int, tile_y: int, rotation: int, plans: Array) -> Dictionary:
	return source_building_plan_state.add_plan_state(check_previous, ignore_conditions, rebuildable, is_default_team, is_campaign, block_visible, is_construct_build, construct_current_synthetic, construct_was_constructing, construct_current, construct_last_config, block_value, current_config, tile_x, tile_y, rotation, plans)

func generated_building_comp_add_plan_default_bridge_state(check_previous: bool, rebuildable: bool, is_default_team: bool, is_campaign: bool, block_visible: bool, is_construct_build: bool, construct_current_synthetic: bool, construct_was_constructing: bool, construct_current: Variant, construct_last_config: Variant, block_value: Variant, current_config: Variant, tile_x: int, tile_y: int, rotation: int, plans: Array) -> Dictionary:
	return source_building_plan_state.generated_add_plan_default_bridge_state(check_previous, rebuildable, is_default_team, is_campaign, block_visible, is_construct_build, construct_current_synthetic, construct_was_constructing, construct_current, construct_last_config, block_value, current_config, tile_x, tile_y, rotation, plans)

func generated_building_comp_add_plan_bridge_state(check_previous: bool, ignore_conditions: bool, rebuildable: bool, is_default_team: bool, is_campaign: bool, block_visible: bool, is_construct_build: bool, construct_current_synthetic: bool, construct_was_constructing: bool, construct_current: Variant, construct_last_config: Variant, block_value: Variant, current_config: Variant, tile_x: int, tile_y: int, rotation: int, plans: Array) -> Dictionary:
	return source_building_plan_state.generated_add_plan_bridge_state(check_previous, ignore_conditions, rebuildable, is_default_team, is_campaign, block_visible, is_construct_build, construct_current_synthetic, construct_was_constructing, construct_current, construct_last_config, block_value, current_config, tile_x, tile_y, rotation, plans)

func generated_building_comp_in_fog_initial_gate_bridge_state(same_team: bool, rules_fog: bool) -> Dictionary:
	return source_building_visibility_state.generated_in_fog_initial_gate_bridge_state(same_team, rules_fog)

func generated_building_comp_in_fog_discovery_gate_bridge_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:
	return source_building_visibility_state.generated_in_fog_discovery_gate_bridge_state(block_size_value, block_size_offset, tile_x, tile_y, is_discovered)

func generated_building_comp_in_fog_visibility_loop_bridge_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:
	return source_building_visibility_state.generated_in_fog_visibility_loop_bridge_state(block_size_value, block_size_offset, tile_x, tile_y, visible_tiles)

func source_building_in_fog_initial_gate_state(same_team: bool, rules_fog: bool) -> Dictionary:
	return source_building_visibility_state.in_fog_initial_gate_state(same_team, rules_fog)

func source_building_in_fog_discovery_gate_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:
	return source_building_visibility_state.in_fog_discovery_gate_state(block_size_value, block_size_offset, tile_x, tile_y, is_discovered)

func source_building_in_fog_visibility_loop_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:
	return source_building_visibility_state.in_fog_visibility_loop_state(block_size_value, block_size_offset, tile_x, tile_y, visible_tiles)

func source_building_update_fog_visibility_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state := {}, tile_state := {}) -> Dictionary:
	return source_building_visibility_state.update_fog_visibility_state(was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state)

func generated_building_comp_update_fog_visibility_bridge_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state: Variant, tile_state: Variant) -> Dictionary:
	return source_building_visibility_state.generated_update_fog_visibility_bridge_state(was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state)

func source_building_to_string_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> String:
	return source_building_meta_state.to_string_state(id_value, tile_x_value, tile_y_value, block_value)

func generated_building_comp_to_string_bridge_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> Dictionary:
	return source_building_meta_state.generated_to_string_bridge_state(id_value, tile_x_value, tile_y_value, block_value)
