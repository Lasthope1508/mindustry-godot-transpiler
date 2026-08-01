extends "res://src/game/SourceBlockConsumePortBridge.gd"

const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")

func generated_building_comp_consume_bridge_state(consumers: Array, self_state: Variant) -> Dictionary:
	return source_building_efficiency_state.generated_consume_bridge_state(consumers, self_state)

func generated_building_comp_can_consume_bridge_state(potential_efficiency: float) -> Dictionary:
	return source_building_efficiency_state.generated_can_consume_bridge_state(potential_efficiency)

func generated_building_comp_update_efficiency_multiplier_bridge_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	return source_building_efficiency_state.generated_update_efficiency_multiplier_bridge_state(efficiency, optional_efficiency, efficiency_scale)

func generated_building_comp_efficiency_scale_bridge_state() -> Dictionary:
	return source_building_efficiency_state.generated_efficiency_scale_bridge_state()

func generated_building_comp_update_consumption_initial_bridge_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:
	return source_building_efficiency_state.generated_update_consumption_initial_bridge_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)

func generated_building_comp_update_consumption_disabled_bridge_state(enabled_state: bool) -> Dictionary:
	return source_building_efficiency_state.generated_update_consumption_disabled_bridge_state(enabled_state)

func generated_building_comp_update_consumption_setup_bridge_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	return source_building_efficiency_state.generated_update_consumption_setup_bridge_state(should_consume_state, production_valid)

func generated_building_comp_update_consumption_non_optional_bridge_state(non_optional_consumer_results: Array) -> Dictionary:
	return source_building_efficiency_state.generated_update_consumption_non_optional_bridge_state(non_optional_consumer_results)

func generated_building_comp_update_consumption_optional_bridge_state(optional_consumer_results: Array) -> Dictionary:
	return source_building_efficiency_state.generated_update_consumption_optional_bridge_state(optional_consumer_results)

func generated_building_comp_update_consumption_efficiency_bridge_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:
	return source_building_efficiency_state.generated_update_consumption_efficiency_bridge_state(min_efficiency, optional_efficiency, update)

func generated_building_comp_update_consumption_second_pass_bridge_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:
	return source_building_efficiency_state.generated_update_consumption_second_pass_bridge_state(update, efficiency, update_consumers, self_state)

func generated_building_comp_ambient_volume_bridge_state(efficiency: float) -> Dictionary:
	return source_building_efficiency_state.generated_ambient_volume_bridge_state(efficiency)

func source_building_consume_state(consumers: Array, self_state: Variant) -> Dictionary:
	return source_building_efficiency_state.consume_state(consumers, self_state)

func source_building_can_consume_state(potential_efficiency: float) -> bool:
	return source_building_efficiency_state.can_consume_state(potential_efficiency)

func source_building_efficiency_scale_state() -> float:
	return source_building_efficiency_state.efficiency_scale_state()

func source_building_update_efficiency_multiplier_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	return source_building_efficiency_state.update_efficiency_multiplier_state(efficiency, optional_efficiency, efficiency_scale)

func source_building_update_consumption_initial_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:
	return source_building_efficiency_state.update_consumption_initial_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)

func source_building_update_consumption_disabled_state(enabled_state: bool) -> Dictionary:
	return source_building_efficiency_state.update_consumption_disabled_state(enabled_state)

func source_building_update_consumption_setup_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	return source_building_efficiency_state.update_consumption_setup_state(should_consume_state, production_valid)

func source_building_update_consumption_non_optional_pass_state(non_optional_consumer_results: Array) -> Dictionary:
	return source_building_efficiency_state.update_consumption_non_optional_pass_state(non_optional_consumer_results)

func source_building_update_consumption_optional_pass_state(optional_consumer_results: Array) -> Dictionary:
	return source_building_efficiency_state.update_consumption_optional_pass_state(optional_consumer_results)

func source_building_update_consumption_efficiency_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:
	return source_building_efficiency_state.update_consumption_efficiency_state(min_efficiency, optional_efficiency, update)

func source_building_update_consumption_second_pass_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:
	return source_building_efficiency_state.update_consumption_second_pass_state(update, efficiency, update_consumers, self_state)

func source_building_ambient_volume(efficiency: float) -> float:
	return source_building_efficiency_state.ambient_volume(efficiency)

func source_building_update_consumption_call_state() -> Dictionary:
	return source_building_efficiency_state.update_consumption_call_state()

func generated_building_comp_update_consumption_call_bridge_state() -> Dictionary:
	return source_building_efficiency_state.generated_update_consumption_call_bridge_state()
