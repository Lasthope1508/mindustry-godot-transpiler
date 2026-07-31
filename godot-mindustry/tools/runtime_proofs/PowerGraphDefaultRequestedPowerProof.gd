extends Node

const source_power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var consumers: Array = [
		{
			"shouldConsumePower": true,
			"buffered": false,
			"usage": 4.0,
			"capacity": 0.0,
			"power_status": 0.0,
			"should_consume": true,
			"delta": 2.0,
		},
		{
			"shouldConsumePower": true,
			"buffered": true,
			"usage": 0.0,
			"capacity": 20.0,
			"power_status": 0.25,
			"should_consume": false,
			"delta": 1.0,
		},
		{
			"shouldConsumePower": false,
			"buffered": false,
			"usage": 100.0,
			"capacity": 0.0,
			"power_status": 0.0,
			"should_consume": true,
			"delta": 1.0,
		},
	]
	var producers: Array = [{"power_production": 10.0, "delta": 1.0}]
	var batteries: Array = [{"enabled": true, "power_status": 0.5, "capacity": 40.0}]
	var needed: Dictionary = source_power_graph_state.power_needed_state(consumers)
	var balance: Dictionary = source_power_graph_state.update_balance_state(consumers, producers, batteries, 3.0, 1.0, [])
	var registry: Dictionary = source_ssot_catalog.canonical_headquarter_registry_state()
	var proof: Dictionary = {
		"module": "SourcePowerGraphState",
		"default_power_needed": float(needed.get("power_needed", 0.0)),
		"default_active_consumers": int(needed.get("active_consumer_count", 0)),
		"balance_power_needed": float(balance.get("power_needed", 0.0)),
		"balance_power_produced": float(balance.get("power_produced", 0.0)),
		"balance_value": float(balance.get("power_balance_value", 0.0)),
		"default_callback_matches": float(needed.get("power_needed", 0.0)) == 23.0 and int(needed.get("active_consumer_count", 0)) == 2,
		"balance_uses_default_callback": float(balance.get("power_needed", 0.0)) == 23.0 and float(balance.get("power_produced", 0.0)) == 10.0 and float(balance.get("power_balance_value", 0.0)) == -10.0,
		"one_headquarter_per_ssot": bool(registry.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry.get("errors", []).is_empty()),
	}
	print("POWER_GRAPH_DEFAULT_REQUESTED_POWER_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
