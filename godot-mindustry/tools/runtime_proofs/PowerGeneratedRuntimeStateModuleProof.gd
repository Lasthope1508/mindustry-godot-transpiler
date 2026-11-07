extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_power_generator_generated_state := preload("res://src/game/SourcePowerGeneratorGeneratedState.gd")
const source_power_graph_generated_state := preload("res://src/game/SourcePowerGraphGeneratedState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var power_production := 42.5
	var graph_id := 17
	var last_scaled_power_in := 3.25

	var generator_wrapper := game.generated_power_generator_displayed_power_production_bridge_state(power_production)
	var generator_module := source_power_generator_generated_state.generated_displayed_power_production_bridge_state(power_production)
	var graph_wrapper := game.generated_power_graph_get_id_bridge_state(graph_id)
	var graph_module := source_power_graph_generated_state.generated_get_id_bridge_state(graph_id)
	var graph_getID_wrapper := game.generated_power_graph_getID_bridge_state(graph_id)
	var graph_getID_module := source_power_graph_generated_state.generated_getID_bridge_state(graph_id)
	var graph_last_scaled_power_in_wrapper := game.generated_power_graph_get_last_scaled_power_in_bridge_state(last_scaled_power_in)
	var graph_last_scaled_power_in_module := source_power_graph_generated_state.generated_get_last_scaled_power_in_bridge_state(last_scaled_power_in)
	var last_scaled_power_out := 7.75
	var graph_last_scaled_power_out_wrapper := game.generated_power_graph_get_last_scaled_power_out_bridge_state(last_scaled_power_out)
	var graph_last_scaled_power_out_module := source_power_graph_generated_state.generated_get_last_scaled_power_out_bridge_state(last_scaled_power_out)
	var last_capacity := 99.0
	var graph_last_capacity_wrapper := game.generated_power_graph_get_last_capacity_bridge_state(last_capacity)
	var graph_last_capacity_module := source_power_graph_generated_state.generated_get_last_capacity_bridge_state(last_capacity)
	var power_balance_raw_mean := 12.5
	var graph_power_balance_wrapper := game.generated_power_graph_get_power_balance_bridge_state(power_balance_raw_mean)
	var graph_power_balance_module := source_power_graph_generated_state.generated_get_power_balance_bridge_state(power_balance_raw_mean)
	var has_power_balance_samples := true
	var graph_has_power_balance_samples_wrapper := game.generated_power_graph_has_power_balance_samples_bridge_state(has_power_balance_samples)
	var graph_has_power_balance_samples_module := source_power_graph_generated_state.generated_has_power_balance_samples_bridge_state(has_power_balance_samples)
	var last_power_needed := 8.5
	var graph_last_power_needed_wrapper := game.generated_power_graph_get_last_power_needed_bridge_state(last_power_needed)
	var graph_last_power_needed_module := source_power_graph_generated_state.generated_get_last_power_needed_bridge_state(last_power_needed)
	var last_power_produced := 21.25
	var graph_last_power_produced_wrapper := game.generated_power_graph_get_last_power_produced_bridge_state(last_power_produced)
	var graph_last_power_produced_module := source_power_graph_generated_state.generated_get_last_power_produced_bridge_state(last_power_produced)
	var last_power_stored := 55.0
	var graph_last_power_stored_wrapper := game.generated_power_graph_get_last_power_stored_bridge_state(last_power_stored)
	var graph_last_power_stored_module := source_power_graph_generated_state.generated_get_last_power_stored_bridge_state(last_power_stored)
	var transfer_amount := -4.5
	var transfer_energy_delta := 12.0
	var graph_transfer_power_wrapper := game.generated_power_graph_transfer_power_bridge_state(transfer_amount, transfer_energy_delta)
	var graph_transfer_power_module := source_power_graph_generated_state.generated_transfer_power_bridge_state(transfer_amount, transfer_energy_delta)
	var last_power_produced_satisfaction := 9.0
	var last_power_needed_satisfaction := 4.0
	var graph_satisfaction_wrapper := game.generated_power_graph_get_satisfaction_bridge_state(last_power_produced_satisfaction, last_power_needed_satisfaction)
	var graph_satisfaction_module := source_power_graph_generated_state.generated_get_satisfaction_bridge_state(last_power_produced_satisfaction, last_power_needed_satisfaction)
	var producer_entries := [
		{"power_production": 2.5, "delta": 4.0},
		{"power_production": 1.0, "delta": 3.0},
	]
	var graph_power_produced_wrapper := game.generated_power_graph_power_produced_bridge_state(producer_entries)
	var graph_power_produced_module := source_power_graph_generated_state.generated_power_produced_bridge_state(producer_entries)
	var consumer_entries := [
		{"shouldConsumePower": true, "buffered": false, "usage": 2.0, "capacity": 0.0, "power_status": 0.0, "should_consume": true, "delta": 3.0},
		{"shouldConsumePower": true, "buffered": true, "usage": 0.0, "capacity": 10.0, "power_status": 0.25, "should_consume": false, "delta": 2.0},
		{"shouldConsumePower": false, "buffered": false, "usage": 9.0, "capacity": 0.0, "power_status": 0.0, "should_consume": true, "delta": 5.0},
	]
	var graph_power_needed_wrapper := game.generated_power_graph_power_needed_bridge_state(consumer_entries)
	var graph_power_needed_module := source_power_graph_generated_state.generated_power_needed_bridge_state(consumer_entries)
	var battery_entries := [
		{"enabled": true, "power_status": 0.25, "capacity": 16.0},
		{"enabled": true, "power_status": 0.75, "capacity": 8.0},
		{"enabled": false, "power_status": 1.0, "capacity": 99.0},
	]
	var graph_battery_stored_wrapper := game.generated_power_graph_battery_stored_bridge_state(battery_entries)
	var graph_battery_stored_module := source_power_graph_generated_state.generated_battery_stored_bridge_state(battery_entries)
	var graph_battery_capacity_wrapper := game.generated_power_graph_battery_capacity_bridge_state(battery_entries)
	var graph_battery_capacity_module := source_power_graph_generated_state.generated_battery_capacity_bridge_state(battery_entries)
	var graph_total_battery_capacity_wrapper := game.generated_power_graph_total_battery_capacity_bridge_state(battery_entries)
	var graph_total_battery_capacity_module := source_power_graph_generated_state.generated_total_battery_capacity_bridge_state(battery_entries)
	var use_needed := 6.0
	var graph_use_batteries_wrapper := game.generated_power_graph_use_batteries_bridge_state(battery_entries, use_needed)
	var graph_use_batteries_module := source_power_graph_generated_state.generated_use_batteries_bridge_state(battery_entries, use_needed)
	var charge_excess := 4.0
	var graph_charge_batteries_wrapper := game.generated_power_graph_charge_batteries_bridge_state(battery_entries, charge_excess)
	var graph_charge_batteries_module := source_power_graph_generated_state.generated_charge_batteries_bridge_state(battery_entries, charge_excess)
	var distribute_consumers := [
		{"buffered": true, "capacity": 8.0, "requested_power": 2.0, "delta": 1.5, "power_status": 0.25, "shouldConsumePower": true, "usage": 0.0},
		{"buffered": false, "capacity": 0.0, "requested_power": 0.0, "delta": 2.0, "power_status": 0.5, "shouldConsumePower": true, "usage": 1.0},
	]
	var distribute_needed := 5.0
	var distribute_produced := 7.5
	var distribute_charged := true
	var distribute_last_power_stored := 1.0
	var graph_distribute_power_wrapper := game.generated_power_graph_distribute_power_bridge_state(distribute_consumers, distribute_needed, distribute_produced, distribute_charged, distribute_last_power_stored)
	var graph_distribute_power_module := source_power_graph_generated_state.generated_distribute_power_bridge_state(distribute_consumers, distribute_needed, distribute_produced, distribute_charged, distribute_last_power_stored)
	var update_energy_delta := 3.0
	var update_source_delta := 1.0
	var update_power_balance_samples := [0.25]
	var graph_update_wrapper := game.generated_power_graph_update_bridge_state(consumer_entries, producer_entries, battery_entries, update_energy_delta, update_source_delta, update_power_balance_samples)
	var graph_update_module := source_power_graph_generated_state.generated_update_bridge_state(consumer_entries, producer_entries, battery_entries, update_energy_delta, update_source_delta, update_power_balance_samples)
	var topology_tiles := [
		{"build_present": true, "power_present": true, "graph_matches": false, "power_init": false, "old_graph_present": true, "old_graph_is_self": false, "old_graph_has_entity": true, "outputs_power": true, "consumes_power": false, "has_cons_power": false, "cons_power_buffered": false},
		{"build_present": true, "power_present": true, "graph_matches": false, "power_init": false, "old_graph_present": false, "old_graph_is_self": false, "old_graph_has_entity": false, "outputs_power": true, "consumes_power": true, "has_cons_power": true, "cons_power_buffered": false},
	]
	var graph_add_graph_wrapper := game.generated_power_graph_add_graph_bridge_state(false, topology_tiles.size(), 5, true, topology_tiles)
	var graph_add_graph_module := source_power_graph_generated_state.generated_add_graph_bridge_state(false, topology_tiles.size(), 5, true, topology_tiles)
	var graph_add_role_wrapper := game.generated_power_graph_add_role_bridge_state(true, true, false, false, true, false, true, true, true, true, false)
	var graph_add_role_module := source_power_graph_generated_state.generated_add_role_bridge_state(true, true, false, false, true, false, true, true, true, true, false)
	var graph_check_add_wrapper := game.generated_power_graph_check_add_bridge_state(true)
	var graph_check_add_module := source_power_graph_generated_state.generated_check_add_bridge_state(true)
	var list_all := ["a", "b", "c"]
	var list_producers := ["b", "p"]
	var list_consumers := ["c", "b"]
	var list_batteries := ["x", "b"]
	var list_build := "b"
	var graph_clear_wrapper := game.generated_power_graph_clear_bridge_state(list_all, list_producers, list_consumers, list_batteries, true)
	var graph_clear_module := source_power_graph_generated_state.generated_clear_bridge_state(list_all, list_producers, list_consumers, list_batteries, true)
	var reflow_tile := {
		"pos": 1,
		"build_present": true,
		"power_present": true,
		"graph_matches": false,
		"power_init": false,
		"old_graph_present": true,
		"old_graph_is_self": false,
		"old_graph_has_entity": true,
		"outputs_power": true,
		"consumes_power": false,
		"has_cons_power": false,
		"cons_power_buffered": false,
		"connections": [
			{
				"pos": 2,
				"build_present": true,
				"power_present": true,
				"graph_matches": false,
				"power_init": false,
				"old_graph_present": false,
				"old_graph_is_self": false,
				"old_graph_has_entity": false,
				"outputs_power": false,
				"consumes_power": true,
				"has_cons_power": true,
				"cons_power_buffered": false,
				"connections": [],
			},
			{
				"pos": 3,
				"build_present": true,
				"power_present": true,
				"graph_matches": false,
				"power_init": false,
				"old_graph_present": false,
				"old_graph_is_self": false,
				"old_graph_has_entity": false,
				"outputs_power": true,
				"consumes_power": true,
				"has_cons_power": true,
				"cons_power_buffered": false,
				"connections": [],
			},
		],
	}
	var graph_reflow_wrapper := game.generated_power_graph_reflow_bridge_state(reflow_tile)
	var graph_reflow_module := source_power_graph_generated_state.generated_reflow_bridge_state(reflow_tile)
	var remove_tile := {
		"pos": 10,
		"connections": [
			{
				"pos": 11,
				"power_graph_is_self": true,
				"build_present": true,
				"power_present": true,
				"graph_matches": false,
				"power_init": false,
				"old_graph_present": false,
				"old_graph_is_self": false,
				"old_graph_has_entity": false,
				"outputs_power": true,
				"consumes_power": false,
				"has_cons_power": false,
				"cons_power_buffered": false,
				"connections": [],
			},
			{
				"pos": 12,
				"power_graph_is_self": false,
				"connections": [],
			},
		],
	}
	var graph_remove_wrapper := game.generated_power_graph_remove_bridge_state(remove_tile, true)
	var graph_remove_module := source_power_graph_generated_state.generated_remove_bridge_state(remove_tile, true)
	var graph_remove_list_wrapper := game.generated_power_graph_remove_list_bridge_state(list_all, list_producers, list_consumers, list_batteries, list_build)
	var graph_remove_list_module := source_power_graph_generated_state.generated_remove_list_bridge_state(list_all, list_producers, list_consumers, list_batteries, list_build)
	var graph_to_string_wrapper := game.generated_power_graph_to_string_bridge_state("[p]", "[c]", "[b]", "[a]", graph_id)
	var graph_to_string_module := source_power_graph_generated_state.generated_to_string_bridge_state("[p]", "[c]", "[b]", "[a]", graph_id)

	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourcePowerGeneratedRuntimeState",
		"generator_bridge_matches": generator_wrapper == generator_module and bool(generator_module.get("matches", false)),
		"graph_bridge_matches": graph_wrapper == graph_module and bool(graph_module.get("matches", false)),
		"graph_getID_bridge_matches": graph_getID_wrapper == graph_getID_module and bool(graph_getID_module.get("matches", false)),
		"graph_last_scaled_power_in_bridge_matches": graph_last_scaled_power_in_wrapper == graph_last_scaled_power_in_module and bool(graph_last_scaled_power_in_module.get("matches", false)),
		"graph_last_scaled_power_out_bridge_matches": graph_last_scaled_power_out_wrapper == graph_last_scaled_power_out_module and bool(graph_last_scaled_power_out_module.get("matches", false)),
		"graph_last_capacity_bridge_matches": graph_last_capacity_wrapper == graph_last_capacity_module and bool(graph_last_capacity_module.get("matches", false)),
		"graph_power_balance_bridge_matches": graph_power_balance_wrapper == graph_power_balance_module and bool(graph_power_balance_module.get("matches", false)),
		"graph_has_power_balance_samples_bridge_matches": graph_has_power_balance_samples_wrapper == graph_has_power_balance_samples_module and bool(graph_has_power_balance_samples_module.get("matches", false)),
		"graph_last_power_needed_bridge_matches": graph_last_power_needed_wrapper == graph_last_power_needed_module and bool(graph_last_power_needed_module.get("matches", false)),
		"graph_last_power_produced_bridge_matches": graph_last_power_produced_wrapper == graph_last_power_produced_module and bool(graph_last_power_produced_module.get("matches", false)),
		"graph_last_power_stored_bridge_matches": graph_last_power_stored_wrapper == graph_last_power_stored_module and bool(graph_last_power_stored_module.get("matches", false)),
		"graph_transfer_power_bridge_matches": graph_transfer_power_wrapper == graph_transfer_power_module and bool(graph_transfer_power_module.get("matches", false)),
		"graph_satisfaction_bridge_matches": graph_satisfaction_wrapper == graph_satisfaction_module and bool(graph_satisfaction_module.get("matches", false)),
		"graph_power_produced_bridge_matches": graph_power_produced_wrapper == graph_power_produced_module and bool(graph_power_produced_module.get("matches", false)),
		"graph_power_needed_bridge_matches": graph_power_needed_wrapper == graph_power_needed_module and bool(graph_power_needed_module.get("matches", false)),
		"graph_battery_stored_bridge_matches": graph_battery_stored_wrapper == graph_battery_stored_module and bool(graph_battery_stored_module.get("matches", false)),
		"graph_battery_capacity_bridge_matches": graph_battery_capacity_wrapper == graph_battery_capacity_module and bool(graph_battery_capacity_module.get("matches", false)),
		"graph_total_battery_capacity_bridge_matches": graph_total_battery_capacity_wrapper == graph_total_battery_capacity_module and bool(graph_total_battery_capacity_module.get("matches", false)),
		"graph_use_batteries_bridge_matches": graph_use_batteries_wrapper == graph_use_batteries_module and bool(graph_use_batteries_module.get("matches", false)),
		"graph_charge_batteries_bridge_matches": graph_charge_batteries_wrapper == graph_charge_batteries_module and bool(graph_charge_batteries_module.get("matches", false)),
		"graph_distribute_power_bridge_matches": graph_distribute_power_wrapper == graph_distribute_power_module and bool(graph_distribute_power_module.get("matches", false)),
		"graph_update_bridge_matches": graph_update_wrapper == graph_update_module and bool(graph_update_module.get("matches", false)),
		"graph_add_graph_bridge_matches": graph_add_graph_wrapper == graph_add_graph_module and bool(graph_add_graph_module.get("matches", false)),
		"graph_add_role_bridge_matches": graph_add_role_wrapper == graph_add_role_module and bool(graph_add_role_module.get("matches", false)),
		"graph_check_add_bridge_matches": graph_check_add_wrapper == graph_check_add_module and bool(graph_check_add_module.get("matches", false)),
		"graph_clear_bridge_matches": graph_clear_wrapper == graph_clear_module and bool(graph_clear_module.get("matches", false)),
		"graph_reflow_bridge_matches": graph_reflow_wrapper == graph_reflow_module and bool(graph_reflow_module.get("matches", false)),
		"graph_remove_bridge_matches": graph_remove_wrapper == graph_remove_module and bool(graph_remove_module.get("matches", false)),
		"graph_remove_list_bridge_matches": graph_remove_list_wrapper == graph_remove_list_module and bool(graph_remove_list_module.get("matches", false)),
		"graph_to_string_bridge_matches": graph_to_string_wrapper == graph_to_string_module and bool(graph_to_string_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["generator_bridge_matches"] and proof["graph_bridge_matches"] and proof["graph_getID_bridge_matches"] and proof["graph_last_scaled_power_in_bridge_matches"] and proof["graph_last_scaled_power_out_bridge_matches"] and proof["graph_last_capacity_bridge_matches"] and proof["graph_power_balance_bridge_matches"] and proof["graph_has_power_balance_samples_bridge_matches"] and proof["graph_last_power_needed_bridge_matches"] and proof["graph_last_power_produced_bridge_matches"] and proof["graph_last_power_stored_bridge_matches"] and proof["graph_transfer_power_bridge_matches"] and proof["graph_satisfaction_bridge_matches"] and proof["graph_power_produced_bridge_matches"] and proof["graph_power_needed_bridge_matches"] and proof["graph_battery_stored_bridge_matches"] and proof["graph_battery_capacity_bridge_matches"] and proof["graph_total_battery_capacity_bridge_matches"] and proof["graph_use_batteries_bridge_matches"] and proof["graph_charge_batteries_bridge_matches"] and proof["graph_distribute_power_bridge_matches"] and proof["graph_update_bridge_matches"] and proof["graph_add_graph_bridge_matches"] and proof["graph_add_role_bridge_matches"] and proof["graph_check_add_bridge_matches"] and proof["graph_clear_bridge_matches"] and proof["graph_reflow_bridge_matches"] and proof["graph_remove_bridge_matches"] and proof["graph_remove_list_bridge_matches"] and proof["graph_to_string_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("POWER_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PowerGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

