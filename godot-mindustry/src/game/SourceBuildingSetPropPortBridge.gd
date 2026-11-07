extends "res://src/game/SourceBuildingCorePortBridge.gd"

const source_building_set_prop_state := preload("res://src/game/SourceBuildingSetPropState.gd")

func source_building_set_prop_health_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:
	return source_building_set_prop_state.health_state(prop, current_health, max_health_value, value, dead_state, self_state)

func generated_building_comp_set_prop_health_bridge_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:
	return source_building_set_prop_state.generated_health_bridge_state(prop, current_health, max_health_value, value, dead_state, self_state)

func source_building_set_prop_team_double_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	return source_building_set_prop_state.team_double_state(prop, current_team_id, value)

func generated_building_comp_set_prop_team_double_bridge_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	return source_building_set_prop_state.generated_team_double_bridge_state(prop, current_team_id, value)

func source_building_set_prop_total_power_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	return source_building_set_prop_state.total_power_state(prop, current_power_status, has_power, has_cons_power, cons_power_buffered, cons_power_capacity, value)

func generated_building_comp_set_prop_total_power_bridge_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	return source_building_set_prop_state.generated_total_power_bridge_state(prop, current_power_status, has_power, has_cons_power, cons_power_buffered, cons_power_capacity, value)

func source_building_set_prop_team_object_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	return source_building_set_prop_state.team_object_state(prop, current_team_value, value_is_team, team_value)

func generated_building_comp_set_prop_team_object_bridge_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	return source_building_set_prop_state.generated_team_object_bridge_state(prop, current_team_value, value_is_team, team_value)

func generated_building_comp_set_prop_item_content_bridge_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	return source_building_set_prop_state.generated_item_content_bridge_state(content_type, has_items_module, item_value, current_amount, value, accepted_stack)

func generated_building_comp_set_prop_liquid_content_bridge_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, current_liquid_amount: float, block_consumes_liquid: bool) -> Dictionary:
	return source_building_set_prop_state.generated_liquid_content_bridge_state(content_type, has_liquids_module, liquid_value, current_amount, value, block_liquid_capacity, accept_liquid_result, current_liquid_matches, current_liquid_amount, block_consumes_liquid)

func source_building_set_prop_item_content_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	return source_building_set_prop_state.item_content_state(content_type, has_items_module, item_value, current_amount, value, accepted_stack)

func source_building_set_prop_liquid_content_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, current_liquid_amount: float, block_consumes_liquid: bool) -> Dictionary:
	return source_building_set_prop_state.liquid_content_state(content_type, has_liquids_module, liquid_value, current_amount, value, block_liquid_capacity, accept_liquid_result, current_liquid_matches, current_liquid_amount, block_consumes_liquid)
