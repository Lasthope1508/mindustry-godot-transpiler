extends "res://src/game/SourceBuildingSerializationPortBridge.gd"

const source_power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const source_power_graph_generated_state := preload("res://src/game/SourcePowerGraphGeneratedState.gd")

func source_power_graph_add_role_state(build_present: bool, power_present: bool, graph_matches: bool, power_init: bool, old_graph_present: bool, old_graph_is_self: bool, old_graph_has_entity: bool, outputs_power: bool, consumes_power: bool, has_cons_power: bool, cons_power_buffered: bool) -> Dictionary:
	return source_power_graph_state.add_role_state(build_present, power_present, graph_matches, power_init, old_graph_present, old_graph_is_self, old_graph_has_entity, outputs_power, consumes_power, has_cons_power, cons_power_buffered)

func source_power_graph_add_graph_state(graph_is_self: bool, graph_all_size: int, all_size: int, graph_has_entity: bool, graph_tiles: Array) -> Dictionary:
	return source_power_graph_state.add_graph_state(graph_is_self, graph_all_size, all_size, graph_has_entity, graph_tiles)

func source_power_graph_check_add_state(entity_present: bool) -> Dictionary:
	return source_power_graph_state.check_add_state(entity_present)

func source_power_graph_clear_state(all: Array, producers: Array, consumers: Array, batteries: Array, entity_present: bool) -> Dictionary:
	return source_power_graph_state.clear_state(all, producers, consumers, batteries, entity_present)

func source_power_graph_reflow_state(tile: Dictionary) -> Dictionary:
	return source_power_graph_state.reflow_state(tile)

func source_power_graph_remove_list_state(all: Array, producers: Array, consumers: Array, batteries: Array, build) -> Dictionary:
	return source_power_graph_state.remove_list_state(all, producers, consumers, batteries, build)

func source_power_graph_remove_branch_seed_state(tile: Dictionary) -> Dictionary:
	return source_power_graph_state.remove_branch_seed_state(tile)

func source_power_graph_remove_branch_bfs_state(tile: Dictionary) -> Dictionary:
	return source_power_graph_state.remove_branch_bfs_state(tile)

func source_power_graph_remove_branch_update_state(tile: Dictionary) -> Dictionary:
	return source_power_graph_state.remove_branch_update_state(tile)

func source_power_graph_remove_empty_entity_state(tile: Dictionary, entity_present: bool) -> Dictionary:
	return source_power_graph_state.remove_empty_entity_state(tile, entity_present)

func source_power_graph_remove_state(tile: Dictionary, entity_present: bool) -> Dictionary:
	return source_power_graph_state.remove_state(tile, entity_present)

func source_power_graph_get_id_state(graph_id: int) -> Dictionary:
	return source_power_graph_state.get_id_state(graph_id)

func generated_power_graph_get_id_bridge_state(graph_id: int) -> Dictionary:
	return source_power_graph_generated_state.generated_get_id_bridge_state(graph_id)

func generated_power_graph_getID_bridge_state(graph_id: int) -> Dictionary:
	return source_power_graph_generated_state.generated_getID_bridge_state(graph_id)

func source_power_graph_get_last_scaled_power_in_state(last_scaled_power_in: float) -> Dictionary:
	return source_power_graph_state.get_last_scaled_power_in_state(last_scaled_power_in)

func generated_power_graph_get_last_scaled_power_in_bridge_state(last_scaled_power_in: float) -> Dictionary:
	return source_power_graph_generated_state.generated_get_last_scaled_power_in_bridge_state(last_scaled_power_in)

func source_power_graph_get_last_scaled_power_out_state(last_scaled_power_out: float) -> Dictionary:
	return source_power_graph_state.get_last_scaled_power_out_state(last_scaled_power_out)

func generated_power_graph_get_last_scaled_power_out_bridge_state(last_scaled_power_out: float) -> Dictionary:
	return source_power_graph_generated_state.generated_get_last_scaled_power_out_bridge_state(last_scaled_power_out)

func source_power_graph_get_last_capacity_state(last_capacity: float) -> Dictionary:
	return source_power_graph_state.get_last_capacity_state(last_capacity)

func generated_power_graph_get_last_capacity_bridge_state(last_capacity: float) -> Dictionary:
	return source_power_graph_generated_state.generated_get_last_capacity_bridge_state(last_capacity)

func source_power_graph_get_power_balance_state(power_balance_raw_mean: float) -> Dictionary:
	return source_power_graph_state.get_power_balance_state(power_balance_raw_mean)

func generated_power_graph_get_power_balance_bridge_state(power_balance_raw_mean: float) -> Dictionary:
	return source_power_graph_generated_state.generated_get_power_balance_bridge_state(power_balance_raw_mean)

func source_power_graph_has_power_balance_samples_state(has_power_balance_samples: bool) -> Dictionary:
	return source_power_graph_state.has_power_balance_samples_state(has_power_balance_samples)

func generated_power_graph_has_power_balance_samples_bridge_state(has_power_balance_samples: bool) -> Dictionary:
	return source_power_graph_generated_state.generated_has_power_balance_samples_bridge_state(has_power_balance_samples)

func source_power_graph_get_last_power_needed_state(last_power_needed: float) -> Dictionary:
	return source_power_graph_state.get_last_power_needed_state(last_power_needed)

func generated_power_graph_get_last_power_needed_bridge_state(last_power_needed: float) -> Dictionary:
	return source_power_graph_generated_state.generated_get_last_power_needed_bridge_state(last_power_needed)

func source_power_graph_get_last_power_produced_state(last_power_produced: float) -> Dictionary:
	return source_power_graph_state.get_last_power_produced_state(last_power_produced)

func generated_power_graph_get_last_power_produced_bridge_state(last_power_produced: float) -> Dictionary:
	return source_power_graph_generated_state.generated_get_last_power_produced_bridge_state(last_power_produced)

func source_power_graph_get_last_power_stored_state(last_power_stored: float) -> Dictionary:
	return source_power_graph_state.get_last_power_stored_state(last_power_stored)

func generated_power_graph_get_last_power_stored_bridge_state(last_power_stored: float) -> Dictionary:
	return source_power_graph_generated_state.generated_get_last_power_stored_bridge_state(last_power_stored)

func source_power_graph_transfer_power_state(amount: float, energy_delta: float) -> Dictionary:
	return source_power_graph_state.transfer_power_state(amount, energy_delta)

func generated_power_graph_transfer_power_bridge_state(amount: float, energy_delta: float) -> Dictionary:
	return source_power_graph_generated_state.generated_transfer_power_bridge_state(amount, energy_delta)

func source_power_graph_get_satisfaction_state(last_power_produced: float, last_power_needed: float) -> Dictionary:
	return source_power_graph_state.get_satisfaction_state(last_power_produced, last_power_needed)

func generated_power_graph_get_satisfaction_bridge_state(last_power_produced: float, last_power_needed: float) -> Dictionary:
	return source_power_graph_generated_state.generated_get_satisfaction_bridge_state(last_power_produced, last_power_needed)

func generated_power_graph_power_produced_bridge_state(producers: Array) -> Dictionary:
	return source_power_graph_generated_state.generated_power_produced_bridge_state(producers)

func generated_power_graph_power_needed_bridge_state(consumers: Array) -> Dictionary:
	return source_power_graph_generated_state.generated_power_needed_bridge_state(consumers)

func generated_power_graph_battery_stored_bridge_state(batteries: Array) -> Dictionary:
	return source_power_graph_generated_state.generated_battery_stored_bridge_state(batteries)

func generated_power_graph_battery_capacity_bridge_state(batteries: Array) -> Dictionary:
	return source_power_graph_generated_state.generated_battery_capacity_bridge_state(batteries)

func generated_power_graph_total_battery_capacity_bridge_state(batteries: Array) -> Dictionary:
	return source_power_graph_generated_state.generated_total_battery_capacity_bridge_state(batteries)

func generated_power_graph_use_batteries_bridge_state(batteries: Array, needed: float) -> Dictionary:
	return source_power_graph_generated_state.generated_use_batteries_bridge_state(batteries, needed)

func generated_power_graph_charge_batteries_bridge_state(batteries: Array, excess: float) -> Dictionary:
	return source_power_graph_generated_state.generated_charge_batteries_bridge_state(batteries, excess)

func generated_power_graph_distribute_power_bridge_state(consumers: Array, needed: float, produced: float, charged: bool, last_power_stored: float) -> Dictionary:
	return source_power_graph_generated_state.generated_distribute_power_bridge_state(consumers, needed, produced, charged, last_power_stored)

func generated_power_graph_update_bridge_state(consumers: Array, producers: Array, batteries: Array, energy_delta: float, source_delta: float, power_balance_samples: Array = []) -> Dictionary:
	return source_power_graph_generated_state.generated_update_bridge_state(consumers, producers, batteries, energy_delta, source_delta, power_balance_samples)

func generated_power_graph_add_graph_bridge_state(graph_is_self: bool, graph_all_size: int, all_size: int, graph_has_entity: bool, graph_tiles: Array) -> Dictionary:
	return source_power_graph_generated_state.generated_add_graph_bridge_state(graph_is_self, graph_all_size, all_size, graph_has_entity, graph_tiles)

func generated_power_graph_add_role_bridge_state(build_present: bool, power_present: bool, graph_matches: bool, power_init: bool, old_graph_present: bool, old_graph_is_self: bool, old_graph_has_entity: bool, outputs_power: bool, consumes_power: bool, has_cons_power: bool, cons_power_buffered: bool) -> Dictionary:
	return source_power_graph_generated_state.generated_add_role_bridge_state(build_present, power_present, graph_matches, power_init, old_graph_present, old_graph_is_self, old_graph_has_entity, outputs_power, consumes_power, has_cons_power, cons_power_buffered)

func generated_power_graph_check_add_bridge_state(entity_present: bool) -> Dictionary:
	return source_power_graph_generated_state.generated_check_add_bridge_state(entity_present)

func generated_power_graph_clear_bridge_state(all: Array, producers: Array, consumers: Array, batteries: Array, entity_present: bool) -> Dictionary:
	return source_power_graph_generated_state.generated_clear_bridge_state(all, producers, consumers, batteries, entity_present)

func generated_power_graph_reflow_bridge_state(tile: Dictionary) -> Dictionary:
	return source_power_graph_generated_state.generated_reflow_bridge_state(tile)

func generated_power_graph_remove_bridge_state(tile: Dictionary, entity_present: bool) -> Dictionary:
	return source_power_graph_generated_state.generated_remove_bridge_state(tile, entity_present)

func generated_power_graph_remove_list_bridge_state(all: Array, producers: Array, consumers: Array, batteries: Array, build) -> Dictionary:
	return source_power_graph_generated_state.generated_remove_list_bridge_state(all, producers, consumers, batteries, build)

func generated_power_graph_to_string_bridge_state(producers: String, consumers: String, batteries: String, all: String, graph_id: int) -> Dictionary:
	return source_power_graph_generated_state.generated_to_string_bridge_state(producers, consumers, batteries, all, graph_id)

func source_power_graph_to_string_state(producers: String, consumers: String, batteries: String, all: String, graph_id: int) -> String:
	return source_power_graph_state.to_string_state(producers, consumers, batteries, all, graph_id)

func source_power_graph_power_needed_state(consumers: Array) -> Dictionary:
	return source_power_graph_state.power_needed_state(consumers)

func source_power_graph_power_produced_state(producers: Array) -> Dictionary:
	return source_power_graph_state.power_produced_state(producers)

func source_power_graph_battery_state(batteries: Array) -> Dictionary:
	return source_power_graph_state.battery_state(batteries)

func source_power_graph_use_batteries_state(batteries: Array, needed: float) -> Dictionary:
	return source_power_graph_state.use_batteries_state(batteries, needed)

func source_power_graph_charge_batteries_state(batteries: Array, excess: float) -> Dictionary:
	return source_power_graph_state.charge_batteries_state(batteries, excess)

func source_power_graph_distribute_power_state(consumers: Array, needed: float, produced: float, charged: bool, last_power_stored: float) -> Dictionary:
	return source_power_graph_state.distribute_power_state(consumers, needed, produced, charged, last_power_stored)

func source_power_graph_update_cheat_state(consumers: Array) -> Dictionary:
	return source_power_graph_state.update_cheat_state(consumers)

func source_power_graph_update_balance_state(consumers: Array, producers: Array, batteries: Array, energy_delta: float, source_delta: float, power_balance_samples: Array = []) -> Dictionary:
	return source_power_graph_state.update_balance_state(consumers, producers, batteries, energy_delta, source_delta, power_balance_samples)

func source_power_graph_update_battery_distribute_state(consumers: Array, producers: Array, batteries: Array, power_needed: float, power_produced: float, last_power_produced: float, last_power_stored: float) -> Dictionary:
	return source_power_graph_state.update_battery_distribute_state(consumers, producers, batteries, power_needed, power_produced, last_power_produced, last_power_stored)

func source_power_graph_update_state(consumers: Array, producers: Array, batteries: Array, energy_delta: float, source_delta: float, power_balance_samples: Array = []) -> Dictionary:
	return source_power_graph_state.update_state(consumers, producers, batteries, energy_delta, source_delta, power_balance_samples)
