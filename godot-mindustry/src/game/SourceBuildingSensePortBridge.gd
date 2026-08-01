extends "res://src/game/SourceBuildingInteractionPortBridge.gd"

const source_building_sense_state := preload("res://src/game/SourceBuildingSenseState.gd")
const source_building_sense_port_bridge_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

func generated_building_comp_sense_position_bridge_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_position_bridge_state(world_x, world_y, source_tilesize)

func generated_building_comp_sense_health_process_bridge_state(world_x: float, world_y: float, health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_health_process_bridge_state(world_x, world_y, health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value)

func generated_building_comp_sense_totals_bridge_state(world_x: float, world_y: float, total_items: float, total_liquids: float, total_power: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_totals_bridge_state(world_x, world_y, total_items, total_liquids, total_power, source_tilesize)

func generated_building_comp_sense_capacity_power_net_bridge_state(world_x: float, world_y: float, block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_capacity_power_net_bridge_state(world_x, world_y, block_has_items, block_item_capacity, block_has_liquids, block_liquid_capacity, has_cons_power, cons_power_capacity, has_power_module, last_scaled_power_in, last_scaled_power_out, last_power_stored, last_power_capacity, source_tilesize)

func generated_building_comp_sense_enabled_controlled_bridge_state(world_x: float, world_y: float, enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_enabled_controlled_bridge_state(world_x, world_y, enabled_state, is_control_block, is_controlled, ctrl_player_value, source_tilesize)

func generated_building_comp_sense_payload_size_bridge_state(world_x: float, world_y: float, has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_payload_size_bridge_state(world_x, world_y, has_payload_seq, payload_seq_total, has_single_payload, block_size_value, source_tilesize)

func generated_building_comp_sense_camera_default_bridge_state(world_x: float, world_y: float, is_control_block: bool, unit_camera_x: float, unit_camera_y: float, unit_camera_width: float, unit_camera_height: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_camera_default_bridge_state(world_x, world_y, is_control_block, unit_camera_x, unit_camera_y, unit_camera_width, unit_camera_height, source_tilesize)

func generated_building_comp_sense_object_bridge_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_object_bridge_state(sensor, block_value, has_items_module, first_item_value, config_senseable, config_value, single_payload_kind, single_payload_content)

func generated_building_comp_sense_content_bridge_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_content_bridge_state(content_type, has_items_module, item_amount, has_liquids_module, liquid_amount, has_payloads, payload_amount)

func source_building_sense_position_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.sense_position_state(world_x, world_y, source_tilesize)

func source_building_sense_health_process_state(health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	return source_building_sense_state.sense_health_process_state(health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value)

func source_building_sense_totals_state(total_items: float, total_liquids: float, total_power: float) -> Dictionary:
	return source_building_sense_state.sense_totals_state(total_items, total_liquids, total_power)

func source_building_sense_capacity_power_net_state(block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float) -> Dictionary:
	return source_building_sense_state.sense_capacity_power_net_state(block_has_items, block_item_capacity, block_has_liquids, block_liquid_capacity, has_cons_power, cons_power_capacity, has_power_module, last_scaled_power_in, last_scaled_power_out, last_power_stored, last_power_capacity, source_building_sense_port_bridge_time_defaults.TICK_RATE)

func source_building_sense_enabled_controlled_state(enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float) -> Dictionary:
	return source_building_sense_state.sense_enabled_controlled_state(enabled_state, is_control_block, is_controlled, ctrl_player_value)

func source_building_sense_payload_size_state(has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float) -> Dictionary:
	return source_building_sense_state.sense_payload_size_state(has_payload_seq, payload_seq_total, has_single_payload, block_size_value)

func source_building_sense_object_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	return source_building_sense_state.sense_object_state(sensor, block_value, has_items_module, first_item_value, config_senseable, config_value, single_payload_kind, single_payload_content)

func source_building_sense_content_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	return source_building_sense_state.sense_content_state(content_type, has_items_module, item_amount, has_liquids_module, liquid_amount, has_payloads, payload_amount)

func source_building_sense_camera_default_state(is_control_block: bool, unit_camera_x: float, unit_camera_y: float, unit_camera_width: float, unit_camera_height: float) -> Dictionary:
	return source_building_sense_state.sense_camera_default_state(is_control_block, unit_camera_x, unit_camera_y, unit_camera_width, unit_camera_height)
