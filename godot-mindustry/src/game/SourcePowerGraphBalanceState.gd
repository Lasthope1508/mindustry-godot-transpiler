extends RefCounted
class_name SourcePowerGraphBalanceState

const source_consume_power_state := preload("res://src/game/SourceConsumePowerState.gd")
const source_power_graph_battery_distribution_state := preload("res://src/game/SourcePowerGraphBatteryDistributionState.gd")

static func power_needed_state(consumers: Array, requested_power_state: Callable = Callable(source_consume_power_state, "requested_power_state")) -> Dictionary:
	var power_needed := 0.0
	var counted_consumers := 0
	var active_consumers := 0
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		counted_consumers += 1
		if bool(consumer.get("shouldConsumePower", false)):
			var requested_state: Dictionary = requested_power_state.call(
				bool(consumer.get("buffered", false)),
				float(consumer.get("usage", 0.0)),
				float(consumer.get("capacity", 0.0)),
				float(consumer.get("power_status", 0.0)),
				bool(consumer.get("should_consume", false))
			)
			power_needed += float(requested_state.get("requested_power", 0.0)) * float(consumer.get("delta", 0.0))
			active_consumers += 1
	return {
		"method": "public float getPowerNeeded(){",
		"initial": "float powerNeeded = 0f;",
		"items": "var items = consumers.items;",
		"loop": "for(int i = 0; i < consumers.size; i++){",
		"consume_power": "var consumePower = consumer.block.consPower;",
		"guard": "if(consumer.shouldConsumePower){",
		"add_expr": "powerNeeded += consumePower.requestedPower(consumer) * consumer.delta();",
		"return_expr": "return powerNeeded;",
		"power_needed": power_needed,
		"consumer_count": counted_consumers,
		"active_consumer_count": active_consumers,
	}

static func power_produced_state(producers: Array) -> Dictionary:
	var power_produced := 0.0
	var counted_producers := 0
	for producer in producers:
		if typeof(producer) != TYPE_DICTIONARY:
			continue
		counted_producers += 1
		power_produced += float(producer.get("power_production", 0.0)) * float(producer.get("delta", 0.0))
	return {
		"method": "public float getPowerProduced(){",
		"initial": "float powerProduced = 0f;",
		"items": "var items = producers.items;",
		"loop": "for(int i = 0; i < producers.size; i++){",
		"producer": "var producer = items[i];",
		"add_expr": "powerProduced += producer.getPowerProduction() * producer.delta();",
		"return_expr": "return powerProduced;",
		"power_produced": power_produced,
		"producer_count": counted_producers,
	}

static func battery_state(batteries: Array) -> Dictionary:
	return source_power_graph_battery_distribution_state.battery_state(batteries)

static func use_batteries_state(batteries: Array, needed: float) -> Dictionary:
	return source_power_graph_battery_distribution_state.use_batteries_state(batteries, needed)

static func charge_batteries_state(batteries: Array, excess: float) -> Dictionary:
	return source_power_graph_battery_distribution_state.charge_batteries_state(batteries, excess)

static func distribute_power_state(consumers: Array, needed: float, produced: float, charged: bool, last_power_stored: float) -> Dictionary:
	return source_power_graph_battery_distribution_state.distribute_power_state(consumers, needed, produced, charged, last_power_stored)

static func update_cheat_state(consumers: Array) -> Dictionary:
	var source_consumers: Array = []
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		source_consumers.append(consumer.duplicate(true))
	var consumers_empty := source_consumers.is_empty()
	var first_cheating := false
	if not consumers_empty:
		first_cheating = bool(source_consumers[0].get("cheating", false))
	var returned := false
	var last_power_needed := 0.0
	var last_power_produced := 0.0
	if not consumers_empty and first_cheating:
		for consumer_state in source_consumers:
			consumer_state["power_status"] = 1.0
		last_power_needed = 1.0
		last_power_produced = 1.0
		returned = true
	return {
		"method": "public void update(){",
		"cheat_gate": "if(!consumers.isEmpty() && consumers.first().cheating()){",
		"cheat_comment": "//when cheating, just set status to 1",
		"loop": "for(Building tile : consumers){",
		"status_assign": "tile.power.status = 1f;",
		"last_power_assign": "lastPowerNeeded = lastPowerProduced = 1f;",
		"return_expr": "return;",
		"consumers_empty": consumers_empty,
		"first_cheating": first_cheating,
		"consumers": source_consumers,
		"returned": returned,
		"last_power_needed": last_power_needed,
		"last_power_produced": last_power_produced,
	}

static func update_balance_state(consumers: Array, producers: Array, batteries: Array, energy_delta: float, source_delta: float, power_balance_samples: Array = [], requested_power_state: Callable = Callable(source_consume_power_state, "requested_power_state")) -> Dictionary:
	var source_power_needed_state: Dictionary = {}
	if requested_power_state.is_valid():
		source_power_needed_state = power_needed_state(consumers, requested_power_state)
	var source_power_produced_state := power_produced_state(producers)
	var source_battery_state := battery_state(batteries)
	var power_needed := float(source_power_needed_state.get("power_needed", 0.0))
	var power_produced := float(source_power_produced_state.get("power_produced", 0.0))
	var last_power_needed := power_needed
	var last_power_produced := power_produced
	var last_scaled_power_in := (power_produced + energy_delta) / source_delta
	var last_scaled_power_out := power_needed / source_delta
	var last_capacity := float(source_battery_state.get("total_capacity", 0.0))
	var last_power_stored := float(source_battery_state.get("stored", 0.0))
	var power_balance_value := (last_power_produced - last_power_needed + energy_delta) / source_delta
	var source_power_balance_samples: Array = power_balance_samples.duplicate(true)
	source_power_balance_samples.append(power_balance_value)
	var next_energy_delta := 0.0
	return {
		"method": "public void update(){",
		"power_needed_expr": "float powerNeeded = getPowerNeeded();",
		"power_produced_expr": "float powerProduced = getPowerProduced();",
		"last_power_needed_expr": "lastPowerNeeded = powerNeeded;",
		"last_power_produced_expr": "lastPowerProduced = powerProduced;",
		"last_scaled_power_in_expr": "lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;",
		"last_scaled_power_out_expr": "lastScaledPowerOut = powerNeeded / Time.delta;",
		"last_capacity_expr": "lastCapacity = getTotalBatteryCapacity();",
		"last_power_stored_expr": "lastPowerStored = getBatteryStored();",
		"power_balance_expr": "powerBalance.add((lastPowerProduced - lastPowerNeeded + energyDelta) / Time.delta);",
		"energy_delta_zero_expr": "energyDelta = 0f;",
		"power_needed": power_needed,
		"power_produced": power_produced,
		"last_power_needed": last_power_needed,
		"last_power_produced": last_power_produced,
		"last_scaled_power_in": last_scaled_power_in,
		"last_scaled_power_out": last_scaled_power_out,
		"last_capacity": last_capacity,
		"last_power_stored": last_power_stored,
		"power_balance_value": power_balance_value,
		"power_balance_samples": source_power_balance_samples,
		"energy_delta": next_energy_delta,
		"source_delta": source_delta,
	}

static func update_battery_distribute_state(consumers: Array, producers: Array, batteries: Array, power_needed: float, power_produced: float, last_power_produced: float, last_power_stored: float) -> Dictionary:
	return source_power_graph_battery_distribution_state.update_battery_distribute_state(consumers, producers, batteries, power_needed, power_produced, last_power_produced, last_power_stored)
