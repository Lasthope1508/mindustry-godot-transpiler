extends "res://src/game/SourcePowerNodePortBridge.gd"

const source_building_configure_state := preload("res://src/game/SourceBuildingConfigureState.gd")

func source_building_configure_local_state(block_state: Dictionary, player_state: Variant, self_state: Variant, value: Variant, tile_config_callback: Variant) -> Dictionary:
	return source_building_configure_state.configure_state(block_state, player_state, self_state, value, tile_config_callback)

func source_building_configure_any_state(self_state: Variant, value: Variant, tile_config_callback: Variant) -> Dictionary:
	return source_building_configure_state.configure_any_state(self_state, value, tile_config_callback)

func source_building_deselect_state(headless: bool, selected_building: Variant, self_state: Variant, hide_config_callback: Variant) -> Dictionary:
	return source_building_configure_state.deselect_state(headless, selected_building, self_state, hide_config_callback)

func source_building_config_tapped_state() -> bool:
	return source_building_configure_state.config_tapped_state()

func source_building_build_configuration_state(table: Variant) -> Dictionary:
	return source_building_configure_state.build_configuration_state(table)

func generated_building_comp_build_configuration_bridge_state(table: Variant) -> Dictionary:
	return source_building_configure_state.generated_build_configuration_bridge_state(table)

func source_building_update_table_align_state(table: Variant, x: float, y: float, block_size: int, tilesize: float, mouse_screen_position: Variant) -> Dictionary:
	return source_building_configure_state.update_table_align_state(table, x, y, block_size, tilesize, mouse_screen_position)

func generated_building_comp_update_table_align_bridge_state(table: Variant, x: float, y: float, block_size: int, tilesize: float, mouse_screen_position: Variant) -> Dictionary:
	return source_building_configure_state.generated_update_table_align_bridge_state(table, x, y, block_size, tilesize, mouse_screen_position)

func generated_building_comp_configure_bridge_state(block_state: Dictionary, player_state: Variant, self_state: Variant, value: Variant) -> Dictionary:
	return source_building_configure_state.generated_configure_bridge_state(block_state, player_state, self_state, value)

func generated_building_comp_configure_any_bridge_state(self_state: Variant, value: Variant) -> Dictionary:
	return source_building_configure_state.generated_configure_any_bridge_state(self_state, value)

func generated_building_comp_deselect_bridge_state(headless: bool, selected_building: Variant, self_state: Variant) -> Dictionary:
	return source_building_configure_state.generated_deselect_bridge_state(headless, selected_building, self_state)

func generated_building_comp_config_tapped_bridge_state() -> Dictionary:
	return source_building_configure_state.generated_config_tapped_bridge_state()

func generated_building_comp_configured_type_bridge_state(value_state: Dictionary) -> Dictionary:
	return source_building_configure_state.generated_configured_type_bridge_state(value_state)

func generated_building_comp_update_last_access_bridge_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	return source_building_configure_state.generated_update_last_access_bridge_state(builder_state, current_last_accessed)

func generated_building_comp_on_configure_tapped_bridge_state(x: float, y: float) -> Dictionary:
	return source_building_configure_state.generated_on_configure_tapped_bridge_state(x, y)

func generated_building_comp_on_configure_closed_bridge_state() -> Dictionary:
	return source_building_configure_state.generated_on_configure_closed_bridge_state()

func generated_building_comp_should_show_configure_bridge_state(player: Variant) -> Dictionary:
	return source_building_configure_state.generated_should_show_configure_bridge_state(player)

func generated_building_comp_should_hide_configure_bridge_state(player: Variant) -> Dictionary:
	return source_building_configure_state.generated_should_hide_configure_bridge_state(player)

func source_building_configured_type_state(value_state: Dictionary) -> String:
	return source_building_configure_state.configured_type_state(value_state)

func source_building_configured_last_access_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	return source_building_configure_state.configured_last_access_state(builder_state, current_last_accessed)

func source_building_configured_direct_handler_state(has_configuration: bool, configured_type: String, value_state: Variant) -> Dictionary:
	return source_building_configure_state.configured_direct_handler_state(has_configuration, configured_type, value_state)

func source_building_configured_copy_config_state(value_is_building: bool, copied_config: Variant, copied_config_is_building: bool) -> Dictionary:
	return source_building_configure_state.configured_copy_config_state(value_is_building, copied_config, copied_config_is_building)

func source_building_on_configure_build_tapped_state(clear_on_double_tap: bool, same_building: bool) -> Dictionary:
	return source_building_configure_state.on_configure_build_tapped_state(clear_on_double_tap, same_building)

func generated_building_comp_on_configure_build_tapped_bridge_state(clear_on_double_tap: bool, same_building: bool) -> Dictionary:
	return source_building_configure_state.generated_on_configure_build_tapped_bridge_state(clear_on_double_tap, same_building)

func source_building_on_configure_tapped_state(x: float, y: float) -> Dictionary:
	return source_building_configure_state.on_configure_tapped_state(x, y)

func source_building_on_configure_closed_state() -> Dictionary:
	return source_building_configure_state.on_configure_closed_state()

func source_building_configure_menu_visibility_state(_player: Variant) -> Dictionary:
	return source_building_configure_state.configure_menu_visibility_state(_player)

func source_building_should_show_configure_state(_player: Variant) -> Dictionary:
	return source_building_configure_state.should_show_configure_state(_player)

func source_building_should_hide_configure_state(_player: Variant) -> Dictionary:
	return source_building_configure_state.should_hide_configure_state(_player)
