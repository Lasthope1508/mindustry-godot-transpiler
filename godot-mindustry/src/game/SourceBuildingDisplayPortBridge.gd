extends "res://src/game/SourceConstructBuildPortBridge.gd"

const source_building_display_state := preload("res://src/game/SourceBuildingDisplayState.gd")

func generated_building_comp_get_display_name_bridge_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> Dictionary:
	return source_building_display_state.generated_building_comp_get_display_name_bridge_state(localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label)

func generated_building_comp_get_display_icon_bridge_state(block_ui_icon: Variant) -> Dictionary:
	return source_building_display_state.generated_building_comp_get_display_icon_bridge_state(block_ui_icon)

func generated_building_comp_flow_items_bridge_state(items_module: Variant) -> Dictionary:
	return source_building_display_state.generated_building_comp_flow_items_bridge_state(items_module)

func generated_building_comp_display_consumption_bridge_state(consumers: Array, self_state: Variant) -> Dictionary:
	return source_building_display_state.generated_building_comp_display_consumption_bridge_state(consumers, self_state)

func generated_building_comp_display_bars_bridge_state(bar_results: Array) -> Dictionary:
	return source_building_display_state.generated_building_comp_display_bars_bridge_state(bar_results)

func generated_building_comp_display_bridge_state(block_ui_icon: Variant, localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String, block_category: String, block_display_flow: bool, net_active: bool, has_last_accessed: bool) -> Dictionary:
	return source_building_display_state.generated_building_comp_display_bridge_state(block_ui_icon, localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label, block_category, block_display_flow, net_active, has_last_accessed)

func source_building_display_name_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> String:
	return source_building_display_state.display_name_state(localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label)

func source_building_display_icon_state(block_ui_icon: Variant) -> Variant:
	return source_building_display_state.display_icon_state(block_ui_icon)

func source_building_flow_items_state(items_module: Variant) -> Variant:
	return source_building_display_state.flow_items_state(items_module)

func source_building_display_consumption_state(consumers: Array, self_state: Variant) -> Dictionary:
	return source_building_display_state.display_consumption_state(consumers, self_state)

func source_building_display_bars_state(bar_results: Array) -> Dictionary:
	return source_building_display_state.display_bars_state(bar_results)

func source_building_display_ui_gates_state(team_is_player: bool, block_category: String, block_display_flow: bool, net_active: bool, has_last_accessed: bool) -> Dictionary:
	return source_building_display_state.display_ui_gates_state(team_is_player, block_category, block_display_flow, net_active, has_last_accessed)

func source_arc_strings_fixed_one_decimal(value: float) -> String:
	return source_building_display_state.fixed_one_decimal(value)

func source_building_display_flow_rate_label(flow_rate: float, per_second_label: String) -> String:
	return source_building_display_state.game_display_flow_rate_label(self, flow_rate, per_second_label)
