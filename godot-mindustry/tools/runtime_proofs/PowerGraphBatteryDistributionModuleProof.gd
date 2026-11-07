extends Node

const source_power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const source_power_graph_balance_state := preload("res://src/game/SourcePowerGraphBalanceState.gd")
const source_power_graph_battery_distribution_state := preload("res://src/game/SourcePowerGraphBatteryDistributionState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var consumers: Array = [
		{
			"shouldConsumePower": true,
			"buffered": false,
			"usage": 4.0,
			"capacity": 0.0,
			"power_status": 0.0,
			"requested_power": 4.0,
			"delta": 1.0,
		},
		{
			"shouldConsumePower": true,
			"buffered": true,
			"usage": 0.0,
			"capacity": 20.0,
			"power_status": 0.25,
			"requested_power": 8.0,
			"delta": 1.0,
		},
		{
			"shouldConsumePower": false,
			"buffered": false,
			"usage": 0.0,
			"capacity": 0.0,
			"power_status": 0.0,
			"requested_power": 0.0,
			"delta": 1.0,
		},
	]
	var producers: Array = [{"power_production": 5.0, "delta": 1.0}]
	var batteries: Array = [
		{"enabled": true, "power_status": 0.5, "capacity": 10.0},
		{"enabled": true, "power_status": 0.25, "capacity": 20.0},
		{"enabled": false, "power_status": 1.0, "capacity": 100.0},
	]

	var module_battery := source_power_graph_battery_distribution_state.battery_state(batteries)
	var balance_battery := source_power_graph_balance_state.battery_state(batteries)
	var state_battery := source_power_graph_state.battery_state(batteries)

	var module_use := source_power_graph_battery_distribution_state.use_batteries_state(batteries, 6.0)
	var balance_use := source_power_graph_balance_state.use_batteries_state(batteries, 6.0)
	var state_use := source_power_graph_state.use_batteries_state(batteries, 6.0)

	var module_charge := source_power_graph_battery_distribution_state.charge_batteries_state(batteries, 8.0)
	var balance_charge := source_power_graph_balance_state.charge_batteries_state(batteries, 8.0)
	var state_charge := source_power_graph_state.charge_batteries_state(batteries, 8.0)

	var module_distribution := source_power_graph_battery_distribution_state.distribute_power_state(consumers, 12.0, 8.0, false, 10.0)
	var balance_distribution := source_power_graph_balance_state.distribute_power_state(consumers, 12.0, 8.0, false, 10.0)
	var state_distribution := source_power_graph_state.distribute_power_state(consumers, 12.0, 8.0, false, 10.0)

	var module_update := source_power_graph_battery_distribution_state.update_battery_distribute_state(consumers, producers, batteries, 12.0, 5.0, 5.0, 10.0)
	var balance_update := source_power_graph_balance_state.update_battery_distribute_state(consumers, producers, batteries, 12.0, 5.0, 5.0, 10.0)
	var state_update := source_power_graph_state.update_battery_distribute_state(consumers, producers, batteries, 12.0, 5.0, 5.0, 10.0)
	var registry := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()

	var module_matches := float(module_battery.get("stored", 0.0)) == 10.0 \
		and float(module_battery.get("capacity", 0.0)) == 20.0 \
		and int(module_battery.get("enabled_count", 0)) == 2 \
		and float(module_use.get("used", 0.0)) == 6.0 \
		and float(module_charge.get("charged", 0.0)) == 8.0 \
		and float(module_distribution.get("coverage", 0.0)) > 0.66 \
		and float(module_distribution.get("coverage", 0.0)) < 0.67 \
		and float(module_update.get("power_battery_used", 0.0)) == 7.0 \
		and float(module_update.get("coverage", 0.0)) == 1.0
	var balance_facade_matches := balance_battery == module_battery \
		and balance_use == module_use \
		and balance_charge == module_charge \
		and balance_distribution == module_distribution \
		and balance_update == module_update
	var state_facade_matches := state_battery == module_battery \
		and state_use == module_use \
		and state_charge == module_charge \
		and state_distribution == module_distribution \
		and state_update == module_update
	var proof := {
		"module": "SourcePowerGraphBatteryDistributionState",
		"module_matches": module_matches,
		"balance_facade_matches": balance_facade_matches,
		"state_facade_matches": state_facade_matches,
		"battery_stored": float(module_battery.get("stored", 0.0)),
		"battery_capacity": float(module_battery.get("capacity", 0.0)),
		"battery_total_capacity": float(module_battery.get("total_capacity", 0.0)),
		"used": float(module_use.get("used", 0.0)),
		"charged": float(module_charge.get("charged", 0.0)),
		"coverage": float(module_update.get("coverage", 0.0)),
		"power_battery_used": float(module_update.get("power_battery_used", 0.0)),
		"one_headquarter_per_ssot": bool(registry.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["module_matches"] and proof["balance_facade_matches"] and proof["state_facade_matches"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("POWER_GRAPH_BATTERY_DISTRIBUTION_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PowerGraphBatteryDistributionModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

