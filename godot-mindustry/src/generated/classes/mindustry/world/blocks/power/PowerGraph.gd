# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/power/PowerGraph.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.power"
const JAVA_KIND := "class"
const JAVA_NAME := "PowerGraph"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "queue", "type": "Queue"}, {"modifiers": ["final", "private", "static"], "name": "outArray1", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "outArray2", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "closedSet", "type": "IntSet"}, {"modifiers": ["final", "public"], "name": "producers", "type": "Seq"}, {"modifiers": ["final", "public"], "name": "consumers", "type": "Seq"}, {"modifiers": ["final", "public"], "name": "batteries", "type": "Seq"}, {"modifiers": ["final", "public"], "name": "all", "type": "Seq"}, {"modifiers": ["final", "private"], "name": "entity", "type": "PowerGraphUpdater"}, {"modifiers": ["final", "private"], "name": "powerBalance", "type": "WindowedMean"}, {"modifiers": ["private"], "name": "lastPowerProduced", "type": "float"}, {"modifiers": ["private"], "name": "lastPowerNeeded", "type": "float"}, {"modifiers": ["private"], "name": "lastPowerStored", "type": "float"}, {"modifiers": ["private"], "name": "lastScaledPowerIn", "type": "float"}, {"modifiers": ["private"], "name": "lastScaledPowerOut", "type": "float"}, {"modifiers": ["private"], "name": "lastCapacity", "type": "float"}, {"modifiers": ["private"], "name": "energyDelta", "type": "float"}, {"modifiers": ["final", "private"], "name": "graphID", "type": "int"}, {"modifiers": ["private", "static"], "name": "lastGraphID", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PowerGraph", "parameters": []}, {"modifiers": ["public"], "name": "PowerGraph", "parameters": [{"name": "noEntity", "type": "boolean", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getID", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "getLastScaledPowerIn", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getLastScaledPowerOut", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getLastCapacity", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getPowerBalance", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "hasPowerBalanceSamples", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getLastPowerNeeded", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getLastPowerProduced", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getLastPowerStored", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "transferPower", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getSatisfaction", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getPowerProduced", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getPowerNeeded", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getBatteryStored", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getBatteryCapacity", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getTotalBatteryCapacity", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "useBatteries", "parameters": [{"name": "needed", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "chargeBatteries", "parameters": [{"name": "excess", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "distributePower", "parameters": [{"name": "needed", "type": "float", "varargs": false}, {"name": "produced", "type": "float", "varargs": false}, {"name": "charged", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "addGraph", "parameters": [{"name": "graph", "type": "PowerGraph", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkAdd", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reflow", "parameters": [{"name": "tile", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeList", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "tile", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getId", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getID_0(_args: Array = []) -> Variant:
	var graph_id: int = int(_args[0] if _args.size() > 0 else 0)
	return {"source_owner": "port_game.source_power_graph_get_id_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public int getID(){", "return_graph_id": "return graphID;", "graph_id": graph_id}

func java_method_getLastScaledPowerIn_1(_args: Array = []) -> Variant:
	var last_scaled_power_in: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_power_graph_get_last_scaled_power_in_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private float lastScaledPowerIn, lastScaledPowerOut, lastCapacity;", "method": "public float getLastScaledPowerIn(){", "return_last_scaled_power_in": "return lastScaledPowerIn;", "last_scaled_power_in": last_scaled_power_in}

func java_method_getLastScaledPowerOut_2(_args: Array = []) -> Variant:
	var last_scaled_power_out: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_power_graph_get_last_scaled_power_out_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private float lastScaledPowerIn, lastScaledPowerOut, lastCapacity;", "method": "public float getLastScaledPowerOut(){", "return_last_scaled_power_out": "return lastScaledPowerOut;", "last_scaled_power_out": last_scaled_power_out}

func java_method_getLastCapacity_3(_args: Array = []) -> Variant:
	var last_capacity: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_power_graph_get_last_capacity_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private float lastScaledPowerIn, lastScaledPowerOut, lastCapacity;", "method": "public float getLastCapacity(){", "return_last_capacity": "return lastCapacity;", "last_capacity": last_capacity}

func java_method_getPowerBalance_4(_args: Array = []) -> Variant:
	var power_balance_raw_mean: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_power_graph_get_power_balance_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private final WindowedMean powerBalance = new WindowedMean(60);", "method": "public float getPowerBalance(){", "return_power_balance_raw_mean": "return powerBalance.rawMean();", "power_balance_raw_mean": power_balance_raw_mean}

func java_method_hasPowerBalanceSamples_5(_args: Array = []) -> Variant:
	var has_power_balance_samples: bool = bool(_args[0] if _args.size() > 0 else false)
	return {"source_owner": "port_game.source_power_graph_has_power_balance_samples_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private final WindowedMean powerBalance = new WindowedMean(60);", "method": "public boolean hasPowerBalanceSamples(){", "return_has_power_balance_samples": "return powerBalance.hasEnoughData();", "has_power_balance_samples": has_power_balance_samples}

func java_method_getLastPowerNeeded_6(_args: Array = []) -> Variant:
	var last_power_needed: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_power_graph_get_last_power_needed_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private float lastPowerProduced, lastPowerNeeded, lastPowerStored;", "method": "public float getLastPowerNeeded(){", "return_last_power_needed": "return lastPowerNeeded;", "last_power_needed": last_power_needed}

func java_method_getLastPowerProduced_7(_args: Array = []) -> Variant:
	var last_power_produced: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_power_graph_get_last_power_produced_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private float lastPowerProduced, lastPowerNeeded, lastPowerStored;", "method": "public float getLastPowerProduced(){", "return_last_power_produced": "return lastPowerProduced;", "last_power_produced": last_power_produced}

func java_method_getLastPowerStored_8(_args: Array = []) -> Variant:
	var last_power_stored: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_power_graph_get_last_power_stored_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private float lastPowerProduced, lastPowerNeeded, lastPowerStored;", "method": "public float getLastPowerStored(){", "return_last_power_stored": "return lastPowerStored;", "last_power_stored": last_power_stored}

func java_method_transferPower_9(_args: Array = []) -> Variant:
	var amount: float = float(_args[0] if _args.size() > 0 else 0.0)
	var energy_delta: float = float(_args[1] if _args.size() > 1 else 0.0)
	var energy_delta_after: float = energy_delta + amount
	return {"source_owner": "port_game.source_power_graph_transfer_power_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private float energyDelta = 0f;", "method": "public void transferPower(float amount){", "positive_guard": "if(amount > 0){", "charge_call": "chargeBatteries(amount);", "else_branch": "}else{", "use_call": "useBatteries(-amount);", "energy_delta_add": "energyDelta += amount;", "amount": amount, "energy_delta": energy_delta, "energy_delta_after": energy_delta_after}

func java_method_getSatisfaction_10(_args: Array = []) -> Variant:
	var last_power_produced: float = float(_args[0] if _args.size() > 0 else 0.0)
	var last_power_needed: float = float(_args[1] if _args.size() > 1 else 0.0)
	var satisfaction: float = 0.0
	if absf(last_power_produced) <= 0.000001:
		satisfaction = 0.0
	elif absf(last_power_needed) <= 0.000001:
		satisfaction = 1.0
	else:
		satisfaction = clamp(last_power_produced / last_power_needed, 0.0, 1.0)
	return {"source_owner": "port_game.source_power_graph_get_satisfaction_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "field": "private float lastPowerProduced, lastPowerNeeded, lastPowerStored;", "method": "public float getSatisfaction(){", "produced_zero_guard": "if(Mathf.zero(lastPowerProduced)){", "return_zero": "return 0f;", "needed_zero_guard": "}else if(Mathf.zero(lastPowerNeeded)){", "return_one": "return 1f;", "return_clamp": "return Mathf.clamp(lastPowerProduced / lastPowerNeeded);", "last_power_produced": last_power_produced, "last_power_needed": last_power_needed, "satisfaction": satisfaction}

func java_method_getPowerProduced_11(_args: Array = []) -> Variant:
	var producers: Array = _args[0] if _args.size() > 0 else []
	var power_produced := 0.0
	var _producer_count := 0
	for producer in producers:
		if typeof(producer) != TYPE_DICTIONARY:
			continue
		_producer_count += 1
		power_produced += float(producer.get("power_production", 0.0)) * float(producer.get("delta", 0.0))
	return {"source_owner": "port_game.source_power_graph_power_produced_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public float getPowerProduced(){", "initial": "float powerProduced = 0f;", "items": "var items = producers.items;", "loop": "for(int i = 0; i < producers.size; i++){", "producer": "var producer = items[i];", "add_expr": "powerProduced += producer.getPowerProduction() * producer.delta();", "return_expr": "return powerProduced;", "power_produced": power_produced, "producer_count": _producer_count}

func java_method_getPowerNeeded_12(_args: Array = []) -> Variant:
	var consumers: Array = _args[0] if _args.size() > 0 else []
	var power_needed := 0.0
	var counted_consumers := 0
	var active_consumers := 0
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		counted_consumers += 1
		if bool(consumer.get("shouldConsumePower", false)):
			var buffered: bool = bool(consumer.get("buffered", false))
			var usage: float = float(consumer.get("usage", 0.0))
			var capacity: float = float(consumer.get("capacity", 0.0))
			var power_status: float = float(consumer.get("power_status", 0.0))
			var should_consume: bool = bool(consumer.get("should_consume", false))
			var requested_power: float = (1.0 - power_status) * capacity if buffered else usage * (1.0 if should_consume else 0.0)
			power_needed += requested_power * float(consumer.get("delta", 0.0))
			active_consumers += 1
	return {"source_owner": "port_game.source_power_graph_power_needed_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public float getPowerNeeded(){", "initial": "float powerNeeded = 0f;", "items": "var items = consumers.items;", "loop": "for(int i = 0; i < consumers.size; i++){", "consume_power": "var consumePower = consumer.block.consPower;", "guard": "if(consumer.shouldConsumePower){", "add_expr": "powerNeeded += consumePower.requestedPower(consumer) * consumer.delta();", "return_expr": "return powerNeeded;", "power_needed": power_needed, "consumer_count": counted_consumers, "active_consumer_count": active_consumers}

func java_method_getBatteryStored_13(_args: Array = []) -> Variant:
	var batteries: Array = _args[0] if _args.size() > 0 else []
	var stored := 0.0
	var capacity := 0.0
	var total_capacity := 0.0
	var battery_count := 0
	var enabled_count := 0
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		battery_count += 1
		if bool(battery.get("enabled", false)):
			var power_status := float(battery.get("power_status", 0.0))
			var source_capacity := float(battery.get("capacity", 0.0))
			stored += power_status * source_capacity
			capacity += (1.0 - power_status) * source_capacity
			total_capacity += source_capacity
			enabled_count += 1
	return {"source_owner": "port_game.source_power_graph_battery_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "stored_method": "public float getBatteryStored(){", "stored_initial": "float totalAccumulator = 0f;", "capacity_method": "public float getBatteryCapacity(){", "capacity_initial": "float totalCapacity = 0f;", "total_capacity_method": "public float getTotalBatteryCapacity(){", "items": "var items = batteries.items;", "loop": "for(int i = 0; i < batteries.size; i++){", "battery": "var battery = items[i];", "guard": "if(battery.enabled){", "stored_add": "totalAccumulator += battery.power.status * battery.block.consPower.capacity;", "capacity_add": "totalCapacity += (1f - battery.power.status) * battery.block.consPower.capacity;", "total_capacity_add": "totalCapacity += battery.block.consPower.capacity;", "stored_return": "return totalAccumulator;", "capacity_return": "return totalCapacity;", "return_expr": "return totalAccumulator;", "stored": stored, "capacity": capacity, "total_capacity": total_capacity, "battery_count": battery_count, "enabled_count": enabled_count}

func java_method_getBatteryCapacity_14(_args: Array = []) -> Variant:
	var batteries: Array = _args[0] if _args.size() > 0 else []
	var stored := 0.0
	var capacity := 0.0
	var total_capacity := 0.0
	var battery_count := 0
	var enabled_count := 0
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		battery_count += 1
		if bool(battery.get("enabled", false)):
			var power_status := float(battery.get("power_status", 0.0))
			var source_capacity := float(battery.get("capacity", 0.0))
			stored += power_status * source_capacity
			capacity += (1.0 - power_status) * source_capacity
			total_capacity += source_capacity
			enabled_count += 1
	return {"source_owner": "port_game.source_power_graph_battery_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "stored_method": "public float getBatteryStored(){", "stored_initial": "float totalAccumulator = 0f;", "capacity_method": "public float getBatteryCapacity(){", "capacity_initial": "float totalCapacity = 0f;", "total_capacity_method": "public float getTotalBatteryCapacity(){", "items": "var items = batteries.items;", "loop": "for(int i = 0; i < batteries.size; i++){", "battery": "var battery = items[i];", "guard": "if(battery.enabled){", "stored_add": "totalAccumulator += battery.power.status * battery.block.consPower.capacity;", "capacity_add": "totalCapacity += (1f - battery.power.status) * battery.block.consPower.capacity;", "total_capacity_add": "totalCapacity += battery.block.consPower.capacity;", "stored_return": "return totalAccumulator;", "capacity_return": "return totalCapacity;", "return_expr": "return totalCapacity;", "stored": stored, "capacity": capacity, "total_capacity": total_capacity, "battery_count": battery_count, "enabled_count": enabled_count}

func java_method_getTotalBatteryCapacity_15(_args: Array = []) -> Variant:
	var batteries: Array = _args[0] if _args.size() > 0 else []
	var stored := 0.0
	var capacity := 0.0
	var total_capacity := 0.0
	var battery_count := 0
	var enabled_count := 0
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		battery_count += 1
		if bool(battery.get("enabled", false)):
			var power_status := float(battery.get("power_status", 0.0))
			var source_capacity := float(battery.get("capacity", 0.0))
			stored += power_status * source_capacity
			capacity += (1.0 - power_status) * source_capacity
			total_capacity += source_capacity
			enabled_count += 1
	return {"source_owner": "port_game.source_power_graph_battery_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "stored_method": "public float getBatteryStored(){", "stored_initial": "float totalAccumulator = 0f;", "capacity_method": "public float getBatteryCapacity(){", "capacity_initial": "float totalCapacity = 0f;", "total_capacity_method": "public float getTotalBatteryCapacity(){", "items": "var items = batteries.items;", "loop": "for(int i = 0; i < batteries.size; i++){", "battery": "var battery = items[i];", "guard": "if(battery.enabled){", "stored_add": "totalAccumulator += battery.power.status * battery.block.consPower.capacity;", "capacity_add": "totalCapacity += (1f - battery.power.status) * battery.block.consPower.capacity;", "total_capacity_add": "totalCapacity += battery.block.consPower.capacity;", "stored_return": "return totalAccumulator;", "capacity_return": "return totalCapacity;", "return_expr": "return totalCapacity;", "stored": stored, "capacity": capacity, "total_capacity": total_capacity, "battery_count": battery_count, "enabled_count": enabled_count}

func java_method_useBatteries_16(_args: Array = []) -> Variant:
	var batteries: Array = _args[0] if _args.size() > 0 else []
	var needed: float = float(_args[1] if _args.size() > 1 else 0.0)
	var source_batteries: Array = []
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		source_batteries.append(battery.duplicate(true))
	var stored := 0.0
	for source_battery_state in source_batteries:
		if bool(source_battery_state.get("enabled", false)):
			stored += float(source_battery_state.get("power_status", 0.0)) * float(source_battery_state.get("capacity", 0.0))
	var used := 0.0
	var consumed_power_percentage := 0.0
	var zero_guard_returned: bool = absf(stored - 0.0) <= 0.000001
	if not zero_guard_returned:
		used = min(stored, needed)
		consumed_power_percentage = min(1.0, needed / stored)
		for source_battery_state in source_batteries:
			if bool(source_battery_state.get("enabled", false)):
				var power_status := float(source_battery_state.get("power_status", 0.0))
				source_battery_state["power_status"] = power_status * (1.0 - consumed_power_percentage)
	return {"source_owner": "port_game.source_power_graph_use_batteries_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public float useBatteries(float needed){", "stored_expr": "float stored = getBatteryStored();", "zero_guard": "if(Mathf.equal(stored, 0f)) return 0f;", "used_expr": "float used = Math.min(stored, needed);", "consumed_percent_expr": "float consumedPowerPercentage = Math.min(1.0f, needed / stored);", "items": "var items = batteries.items;", "loop": "for(int i = 0; i < batteries.size; i++){", "battery": "var battery = items[i];", "status_mul": "battery.power.status *= (1f-consumedPowerPercentage);", "return_expr": "return used;", "mathf_equal": "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;", "needed": needed, "stored": stored, "used": used, "consumed_power_percentage": consumed_power_percentage, "zero_guard_returned": zero_guard_returned, "batteries": source_batteries}

func java_method_chargeBatteries_17(_args: Array = []) -> Variant:
	var batteries: Array = _args[0] if _args.size() > 0 else []
	var excess: float = float(_args[1] if _args.size() > 1 else 0.0)
	var source_batteries: Array = []
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		source_batteries.append(battery.duplicate(true))
	var capacity := 0.0
	for source_battery_state in source_batteries:
		if bool(source_battery_state.get("enabled", false)):
			var power_status := float(source_battery_state.get("power_status", 0.0))
			var source_capacity := float(source_battery_state.get("capacity", 0.0))
			capacity += (1.0 - power_status) * source_capacity
	var charged_percent := 0.0
	var charged := 0.0
	var zero_guard_returned: bool = absf(capacity - 0.0) <= 0.000001
	if not zero_guard_returned:
		charged_percent = min(excess / capacity, 1.0)
		charged = min(excess, capacity)
		for source_battery_state in source_batteries:
			var source_capacity := float(source_battery_state.get("capacity", 0.0))
			if bool(source_battery_state.get("enabled", false)) and source_capacity > 0.0:
				var power_status := float(source_battery_state.get("power_status", 0.0))
				source_battery_state["power_status"] = power_status + (1.0 - power_status) * charged_percent
	return {"source_owner": "port_game.source_power_graph_charge_batteries_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public float chargeBatteries(float excess){", "capacity_expr": "float capacity = getBatteryCapacity();", "charged_percent_comment": "//how much of the missing in each battery % is charged", "charged_percent_expr": "float chargedPercent = Math.min(excess/capacity, 1f);", "zero_guard": "if(Mathf.equal(capacity, 0f)) return 0f;", "items": "var items = batteries.items;", "loop": "for(int i = 0; i < batteries.size; i++){", "battery": "var battery = items[i];", "todo": "//TODO why would it be 0", "guard": "if(battery.enabled && battery.block.consPower.capacity > 0f){", "status_add": "battery.power.status += (1f - battery.power.status) * chargedPercent;", "return_expr": "return Math.min(excess, capacity);", "mathf_equal": "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;", "excess": excess, "capacity": capacity, "charged_percent": charged_percent, "charged": charged, "zero_guard_returned": zero_guard_returned, "batteries": source_batteries}

func java_method_distributePower_18(_args: Array = []) -> Variant:
	var consumers: Array = _args[0] if _args.size() > 0 else []
	var needed: float = float(_args[1] if _args.size() > 1 else 0.0)
	var produced: float = float(_args[2] if _args.size() > 2 else 0.0)
	var charged: bool = bool(_args[3] if _args.size() > 3 else false)
	var last_power_stored: float = float(_args[4] if _args.size() > 4 else 0.0)
	var source_consumers: Array = []
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		source_consumers.append(consumer.duplicate(true))
	var needed_zero: bool = absf(needed) <= 0.000001
	var produced_zero: bool = absf(produced) <= 0.000001
	var last_power_stored_zero: bool = absf(last_power_stored) <= 0.000001
	var coverage := 0.0
	if needed_zero and produced_zero and not charged and last_power_stored_zero:
		coverage = 0.0
	elif needed_zero:
		coverage = 1.0
	else:
		coverage = min(1.0, produced / needed)
	var buffered_count := 0
	var unbuffered_count := 0
	var nan_guard_count := 0
	for consumer_state in source_consumers:
		var buffered := bool(consumer_state.get("buffered", false))
		var capacity := float(consumer_state.get("capacity", 0.0))
		var delta := float(consumer_state.get("delta", 0.0))
		var power_status := float(consumer_state.get("power_status", 0.0))
		if buffered:
			buffered_count += 1
			if absf(capacity) > 0.000001:
				var requested_power := float(consumer_state.get("requested_power", 0.0))
				var maximum_rate := requested_power * coverage * delta
				consumer_state["maximum_rate"] = maximum_rate
				consumer_state["power_status"] = clamp(power_status + maximum_rate / capacity, 0.0, 1.0)
			continue
		unbuffered_count += 1
		if bool(consumer_state.get("shouldConsumePower", false)):
			consumer_state["power_status"] = coverage
		else:
			var usage := float(consumer_state.get("usage", 0.0))
			var denominator := needed + usage * delta
			var estimated_status := 0.0
			var estimate_nan := false
			if absf(denominator) <= 0.000001:
				if absf(produced) <= 0.000001:
					estimate_nan = true
				elif produced > 0.0:
					estimated_status = 1.0
				else:
					estimated_status = -INF
			else:
				estimated_status = min(1.0, produced / denominator)
			if estimate_nan or is_nan(estimated_status):
				estimated_status = 0.0
				nan_guard_count += 1
			consumer_state["power_status"] = estimated_status
	return {"source_owner": "port_game.source_power_graph_distribute_power_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public void distributePower(float needed, float produced, boolean charged){", "coverage_expr": "float coverage = Mathf.zero(needed) && Mathf.zero(produced) && !charged && Mathf.zero(lastPowerStored) ? 0f : Mathf.zero(needed) ? 1f : Math.min(1, produced / needed);", "items": "var items = consumers.items;", "loop": "for(int i = 0; i < consumers.size; i++){", "consumer": "var consumer = items[i];", "cons": "var cons = consumer.block.consPower;", "buffered_gate": "if(cons.buffered){", "capacity_zero_guard": "if(!Mathf.zero(cons.capacity)){", "maximum_rate_expr": "float maximumRate = cons.requestedPower(consumer) * coverage * consumer.delta();", "buffered_status_clamp": "consumer.power.status = Mathf.clamp(consumer.power.status + maximumRate / cons.capacity);", "unbuffered_gate": "if(consumer.shouldConsumePower){", "unbuffered_coverage_status": "consumer.power.status = coverage;", "unbuffered_estimate_status": "consumer.power.status = Math.min(1, produced / (needed + cons.usage * consumer.delta()));", "nan_guard": "if(Float.isNaN(consumer.power.status)){", "nan_status_zero": "consumer.power.status = 0f;", "mathf_zero": "return Math.abs(value) <= FLOAT_ROUNDING_ERROR;", "mathf_clamp": "return Math.max(Math.min(value, 1f), 0f);", "needed": needed, "produced": produced, "charged": charged, "last_power_stored": last_power_stored, "coverage": coverage, "consumers": source_consumers, "buffered_count": buffered_count, "unbuffered_count": unbuffered_count, "nan_guard_count": nan_guard_count}

func java_method_update_19(_args: Array = []) -> Variant:
	var consumers: Array = _args[0] if _args.size() > 0 else []
	var producers: Array = _args[1] if _args.size() > 1 else []
	var batteries: Array = _args[2] if _args.size() > 2 else []
	var energy_delta: float = float(_args[3] if _args.size() > 3 else 0.0)
	var source_delta: float = float(_args[4] if _args.size() > 4 else 1.0)
	var power_balance_samples: Array = _args[5] if _args.size() > 5 else []
	var cheat_state: Dictionary = SourcePowerGraphState.update_cheat_state(consumers)
	var balance_state: Dictionary = SourcePowerGraphState.update_balance_state(consumers, producers, batteries, energy_delta, source_delta, power_balance_samples)
	var power_needed: float = float(balance_state.get("power_needed", 0.0))
	var power_produced: float = float(balance_state.get("power_produced", 0.0))
	var last_power_needed: float = float(balance_state.get("last_power_needed", power_needed))
	var last_power_produced: float = float(balance_state.get("last_power_produced", power_produced))
	var last_power_stored: float = float(balance_state.get("last_power_stored", 0.0))
	var battery_distribute_state: Dictionary = SourcePowerGraphState.update_battery_distribute_state(consumers, producers, batteries, power_needed, power_produced, last_power_produced, last_power_stored)
	return {"source_owner": "port_game.source_power_graph_update_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public void update(){", "nonempty_guard": "if(!(consumers.size == 0 && producers.size == 0 && batteries.size == 0)){", "charged_init": "boolean charged = false;", "unequal_guard_expr": "if(!Mathf.equal(powerNeeded, powerProduced)){", "deficit_gate": "if(powerNeeded > powerProduced){", "power_battery_used_expr": "float powerBatteryUsed = useBatteries(powerNeeded - powerProduced);", "power_produced_battery_add_expr": "powerProduced += powerBatteryUsed;", "last_power_produced_battery_add_expr": "lastPowerProduced += powerBatteryUsed;", "surplus_gate": "}else if(powerProduced > powerNeeded){", "charged_true_expr": "charged = true;", "power_produced_charge_sub_expr": "powerProduced -= chargeBatteries(powerProduced - powerNeeded);", "distribute_power_expr": "distributePower(powerNeeded, powerProduced, charged);", "mathf_equal": "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;", "cheat_state": cheat_state, "balance_state": balance_state, "battery_distribute_state": battery_distribute_state, "power_needed": power_needed, "power_produced": power_produced, "last_power_needed": last_power_needed, "last_power_produced": last_power_produced, "last_power_stored": last_power_stored, "consumers": consumers, "producers": producers, "batteries": batteries, "energy_delta": energy_delta, "source_delta": source_delta, "power_balance_samples": power_balance_samples}

func java_method_addGraph_20(_args: Array = []) -> Variant:
	var graph_is_self: bool = bool(_args[0] if _args.size() > 0 else false)
	var graph_all_size: int = int(_args[1] if _args.size() > 1 else 0)
	var all_size: int = int(_args[2] if _args.size() > 2 else 0)
	var graph_has_entity: bool = bool(_args[3] if _args.size() > 3 else false)
	var graph_tiles: Array = _args[4] if _args.size() > 4 else []
	var returned := false
	var delegate_to_other_graph := false
	var remove_graph_entity := false
	var check_add := false
	var add_call_count := 0
	if graph_is_self:
		returned = true
	elif graph_all_size > all_size:
		returned = true
		delegate_to_other_graph = true
	else:
		remove_graph_entity = graph_has_entity
		for tile in graph_tiles:
			if typeof(tile) != TYPE_DICTIONARY:
				continue
			add_call_count += 1
		check_add = true
	return {"source_owner": "port_game.source_power_graph_add_graph_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public void addGraph(PowerGraph graph){", "self_guard": "if(graph == this) return;", "merge_comment": "//merge into other graph instead.", "delegate_guard_expr": "if(graph.all.size > all.size){", "delegate_call_expr": "graph.addGraph(this);", "delegate_return_expr": "return;", "remove_comment": "//other entity should be removed as the graph was merged", "remove_graph_entity_expr": "if(graph.entity != null) graph.entity.remove();", "graph_all_loop_expr": "for(Building tile : graph.all){", "add_tile_expr": "add(tile);", "check_add_expr": "checkAdd();", "graph_is_self": graph_is_self, "graph_all_size": graph_all_size, "all_size": all_size, "graph_has_entity": graph_has_entity, "graph_tiles": graph_tiles.duplicate(true), "returned": returned, "delegate_to_other_graph": delegate_to_other_graph, "remove_graph_entity": remove_graph_entity, "add_call_count": add_call_count, "tile_add_states": [], "check_add": check_add}

func java_method_add_21(_args: Array = []) -> Variant:
	var build: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var build_present: bool = bool(build.get("build_present", true))
	var power_present: bool = bool(build.get("power_present", true))
	var graph_matches: bool = bool(build.get("graph_matches", false))
	var power_init: bool = bool(build.get("power_init", false))
	var old_graph_present: bool = bool(build.get("old_graph_present", false))
	var old_graph_is_self: bool = bool(build.get("old_graph_is_self", false))
	var old_graph_has_entity: bool = bool(build.get("old_graph_has_entity", false))
	var outputs_power: bool = bool(build.get("outputs_power", false))
	var consumes_power: bool = bool(build.get("consumes_power", false))
	var has_cons_power: bool = bool(build.get("has_cons_power", false))
	var cons_power_buffered: bool = bool(build.get("cons_power_buffered", false))
	var result := {"source_owner": "port_game.source_power_graph_add_role_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "returned": false, "remove_old_graph_entity": false, "assign_graph": false, "init_power": false, "add_all": false, "role": "none", "add_producer": false, "add_consumer": false, "add_battery": false, "has_cons_power": has_cons_power, "power_guard": "if(build == null || build.power == null) return;", "add_gate": "if(build.power.graph != this || !build.power.init){", "graph_assign": "build.power.graph = this;", "init_assign": "build.power.init = true;", "all_add": "all.add(build);", "producer_consumer_branch": "if(build.block.outputsPower && build.block.consumesPower && !build.block.consPower.buffered){", "battery_branch": "}else if(build.block.outputsPower && build.block.consumesPower){", "producer_branch": "}else if(build.block.outputsPower){", "consumer_branch": "}else if(build.block.consumesPower && build.block.consPower != null){"}
	if not build_present or not power_present:
		result["returned"] = true
		return result
	if not graph_matches or not power_init:
		result["remove_old_graph_entity"] = old_graph_present and not old_graph_is_self and old_graph_has_entity
		result["assign_graph"] = true
		result["init_power"] = true
		result["add_all"] = true
		if outputs_power and consumes_power and has_cons_power and not cons_power_buffered:
			result["role"] = "producer_consumer"
			result["add_producer"] = true
			result["add_consumer"] = true
		elif outputs_power and consumes_power:
			result["role"] = "battery"
			result["add_battery"] = true
		elif outputs_power:
			result["role"] = "producer"
			result["add_producer"] = true
		elif consumes_power and has_cons_power:
			result["role"] = "consumer"
			result["add_consumer"] = true
	return result

func java_method_checkAdd_22(_args: Array = []) -> Variant:
	var entity_present: bool = bool(_args[0] if _args.size() > 0 else false)
	return {"source_owner": "port_game.source_power_graph_check_add_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public void checkAdd(){", "entity_add_guard": "if(entity != null) entity.add();", "entity_add_called": entity_present}

func java_method_clear_23(_args: Array = []) -> Variant:
	var all: Array = (_args[0] as Array).duplicate(true) if _args.size() > 0 and _args[0] is Array else []
	var producers: Array = (_args[1] as Array).duplicate(true) if _args.size() > 1 and _args[1] is Array else []
	var consumers: Array = (_args[2] as Array).duplicate(true) if _args.size() > 2 and _args[2] is Array else []
	var batteries: Array = (_args[3] as Array).duplicate(true) if _args.size() > 3 and _args[3] is Array else []
	var entity_present: bool = bool(_args[4] if _args.size() > 4 else false)
	all.clear()
	producers.clear()
	consumers.clear()
	batteries.clear()
	return {"source_owner": "port_game.source_power_graph_clear_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public void clear(){", "all_clear": "all.clear();", "producers_clear": "producers.clear();", "consumers_clear": "consumers.clear();", "batteries_clear": "batteries.clear();", "nothing_left_comment": "//nothing left", "entity_remove_guard": "if(entity != null) entity.remove();", "all": all, "producers": producers, "consumers": consumers, "batteries": batteries, "entity_removed": entity_present}

func java_method_reflow_24(_args: Array = []) -> Variant:
	var tile: Dictionary = (_args[0] as Dictionary).duplicate(true) if _args.size() > 0 and _args[0] is Dictionary else {}
	var queue: Array = []
	var closed_lookup: Dictionary = {}
	var closed_positions: Array = []
	var queued_positions: Array = []
	var visited_positions: Array = []
	var tile_add_states: Array = []
	var check_add_count := 0
	queue.clear()
	queue.append(tile.duplicate(true))
	closed_lookup.clear()
	while queue.size() > 0:
		var child_variant = queue.pop_front()
		if typeof(child_variant) != TYPE_DICTIONARY:
			continue
		var child: Dictionary = child_variant
		visited_positions.append(child.get("pos", null))
		var add_state: Dictionary = java_method_add_21([child])
		tile_add_states.append(add_state)
		check_add_count += 1
		var connections: Array = child.get("connections", [])
		for next in connections:
			if typeof(next) != TYPE_DICTIONARY:
				continue
			var next_pos = next.get("pos", null)
			var next_pos_key := var_to_str(next_pos)
			if not closed_lookup.has(next_pos_key):
				closed_lookup[next_pos_key] = true
				closed_positions.append(next_pos)
				queued_positions.append(next_pos)
				queue.append(next.duplicate(true))
	return {"source_owner": "port_game.source_power_graph_reflow_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public void reflow(Building tile){", "queue_clear": "queue.clear();", "queue_add_tile": "queue.addLast(tile);", "closed_set_clear": "closedSet.clear();", "while_queue": "while(queue.size > 0){", "remove_first": "Building child = queue.removeFirst();", "add_child": "add(child);", "check_add": "checkAdd();", "connections_loop": "for(Building next : child.getPowerConnections(outArray2)){", "closed_set_add": "if(closedSet.add(next.pos())){", "queue_add_next": "queue.addLast(next);", "tile": tile.duplicate(true), "visited_positions": visited_positions, "queued_positions": queued_positions, "closed_positions": closed_positions, "tile_add_states": tile_add_states, "check_add_count": check_add_count}

func java_method_removeList_25(_args: Array = []) -> Variant:
	var all: Array = (_args[0] as Array).duplicate(true) if _args.size() > 0 and _args[0] is Array else []
	var producers: Array = (_args[1] as Array).duplicate(true) if _args.size() > 1 and _args[1] is Array else []
	var consumers: Array = (_args[2] as Array).duplicate(true) if _args.size() > 2 and _args[2] is Array else []
	var batteries: Array = (_args[3] as Array).duplicate(true) if _args.size() > 3 and _args[3] is Array else []
	var build: Variant = _args[4] if _args.size() > 4 else null
	all.erase(build)
	producers.erase(build)
	consumers.erase(build)
	batteries.erase(build)
	return {"source_owner": "port_game.source_power_graph_remove_list_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "comment": "Used for unit tests only.", "method": "public void removeList(Building build){", "all_remove": "all.remove(build);", "producers_remove": "producers.remove(build);", "consumers_remove": "consumers.remove(build);", "batteries_remove": "batteries.remove(build);", "build": build, "all": all, "producers": producers, "consumers": consumers, "batteries": batteries}

func java_method_remove_26(_args: Array = []) -> Variant:
	var tile: Dictionary = (_args[0] as Dictionary).duplicate(true) if _args.size() > 0 and _args[0] is Dictionary else {}
	var entity_present: bool = bool(_args[1] if _args.size() > 1 else false)
	var seed_state: Dictionary = SourcePowerGraphState.remove_branch_seed_state(tile)
	var bfs_state: Dictionary = SourcePowerGraphState.remove_branch_bfs_state(tile)
	var update_state: Dictionary = SourcePowerGraphState.remove_branch_update_state(tile)
	var empty_entity_state: Dictionary = SourcePowerGraphState.remove_empty_entity_state(tile, entity_present)
	return {"source_owner": "port_game.source_power_graph_remove_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public void remove(Building tile){", "remove_comment": seed_state.get("remove_comment", ""), "seed_state": seed_state, "bfs_state": bfs_state, "update_state": update_state, "empty_entity_state": empty_entity_state, "tile": tile.duplicate(true), "entity_present": entity_present}

func java_method_getId_27(_args: Array = []) -> Variant:
	var graph_id: int = int(_args[0] if _args.size() > 0 else 0)
	return {"source_owner": "port_game.source_power_graph_get_id_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public int getId(){", "return_graph_id": "return graphID;", "graph_id": graph_id}

func java_method_toString_28(_args: Array = []) -> Variant:
	var producers: String = str(_args[0] if _args.size() > 0 else "")
	var consumers: String = str(_args[1] if _args.size() > 1 else "")
	var batteries: String = str(_args[2] if _args.size() > 2 else "")
	var all: String = str(_args[3] if _args.size() > 3 else "")
	var graph_id: int = int(_args[4] if _args.size() > 4 else 0)
	return "PowerGraph{producers=" + producers + ", consumers=" + consumers + ", batteries=" + batteries + ", all=" + all + ", graphID=" + str(graph_id) + "}"
