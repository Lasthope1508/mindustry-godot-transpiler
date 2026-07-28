extends RefCounted
class_name SourceConsumePowerState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func requested_power_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	var requested_power: float = (1.0 - power_status) * capacity if buffered else usage * (1.0 if should_consume else 0.0)
	return {"source_owner": "PortGame.source_consume_power_requested_power_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public float requestedPower(Building entity){", "buffered_expr": "(1f - entity.power.status) * capacity", "unbuffered_expr": "usage * (entity.shouldConsume() ? 1f : 0f)", "buffered": buffered, "usage": usage, "capacity": capacity, "power_status": power_status, "should_consume": should_consume, "requested_power": requested_power}

static func generated_requested_power_bridge_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/consumers/ConsumePower.gd", "java_method_requestedPower_4", [buffered, usage, capacity, power_status, should_consume], null)
	var canonical = requested_power_state(buffered, usage, capacity, power_status, should_consume)
	return {"source_owner": "SourceConsumePowerState.requested_power_state", "generated_owner": "ConsumePower.requestedPower", "result": result, "canonical": canonical, "matches": result.get("requested_power", null) == canonical.get("requested_power", null)}

static func apply_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_consume_power_apply_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "block_source": "core/src/mindustry/world/Block.java", "method": "public void apply(Block block){", "has_power_assignment_expr": "block.hasPower = true;", "cons_power_assignment_expr": "block.consPower = this;", "block_has_power_before": block_has_power_before, "block_cons_power_before": block_cons_power_before, "consume_power_state": consume_power_state, "block_has_power_after": true, "block_cons_power_after": consume_power_state}

static func generated_apply_bridge_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/consumers/ConsumePower.gd", "java_method_apply_0", [block_has_power_before, block_cons_power_before, consume_power_state], null)
	var canonical = apply_state(block_has_power_before, block_cons_power_before, consume_power_state)
	return {"source_owner": "SourceConsumePowerState.apply_state", "generated_owner": "ConsumePower.apply", "result": result, "canonical": canonical, "matches": result.get("block_has_power_after", null) == canonical.get("block_has_power_after", null) and result.get("block_cons_power_after", null) == canonical.get("block_cons_power_after", null)}

static func ignore_state(buffered: bool) -> Dictionary:
	return {"source_owner": "PortGame.source_consume_power_ignore_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public boolean ignore(){", "return_expr": "return buffered;", "buffered": buffered, "ignore": buffered}

static func generated_ignore_bridge_state(buffered: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/consumers/ConsumePower.gd", "java_method_ignore_1", [buffered], null)
	var canonical = ignore_state(buffered)
	return {"source_owner": "SourceConsumePowerState.ignore_state", "generated_owner": "ConsumePower.ignore", "result": result, "canonical": canonical, "matches": result.get("ignore", null) == canonical.get("ignore", null)}

static func efficiency_state(power_status: float) -> Dictionary:
	return {"source_owner": "PortGame.source_consume_power_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public float efficiency(Building build){", "return_expr": "return build.power.status;", "power_status": power_status, "efficiency": power_status}

static func generated_efficiency_bridge_state(power_status: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/consumers/ConsumePower.gd", "java_method_efficiency_2", [power_status], null)
	var canonical = efficiency_state(power_status)
	return {"source_owner": "SourceConsumePowerState.efficiency_state", "generated_owner": "ConsumePower.efficiency", "result": result, "canonical": canonical, "matches": result.get("efficiency", null) == canonical.get("efficiency", null)}

static func display_state(buffered: bool, usage: float, capacity: float, source_tick_rate: float) -> Dictionary:
	var power_use_value: float = usage * source_tick_rate
	var stats_add_call: Dictionary = {"stat": "Stat.powerUse", "value": power_use_value, "unit": "StatUnit.powerSecond"} if (not buffered and usage > 0.0) else {"stat": "Stat.powerCapacity", "value": capacity, "unit": "StatUnit.none"} if buffered else {}
	return {"source_owner": "PortGame.source_consume_power_display_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public void display(Stats stats){", "buffered_guard_expr": "if(buffered){", "usage_guard_expr": "}else if(usage > 0f){", "capacity_stats_add_expr": "stats.add(Stat.powerCapacity, capacity, StatUnit.none);", "usage_stats_add_expr": "stats.add(Stat.powerUse, usage * 60f, StatUnit.powerSecond);", "buffered": buffered, "usage": usage, "capacity": capacity, "power_use_value": power_use_value, "stats_add_call": stats_add_call}

static func generated_display_bridge_state(buffered: bool, usage: float, capacity: float, source_tick_rate: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/consumers/ConsumePower.gd", "java_method_display_3", [buffered, usage, capacity, source_tick_rate], null)
	var canonical = display_state(buffered, usage, capacity, source_tick_rate)
	return {"source_owner": "SourceConsumePowerState.display_state", "generated_owner": "ConsumePower.display", "result": result, "canonical": canonical, "matches": result.get("stats_add_call", null) == canonical.get("stats_add_call", null)}

static func condition_requested_power_state(usage: float, consume_get: bool) -> Dictionary:
	return {"source_owner": "PortGame.source_consume_power_condition_requested_power_state", "source": "core/src/mindustry/world/consumers/ConsumePowerCondition.java", "method": "public float requestedPower(Building entity){", "return_expr": "return consume.get(entity) ? usage : 0f;", "usage": usage, "consume_get": consume_get, "requested_power": usage if consume_get else 0.0}

static func generated_condition_requested_power_bridge_state(usage: float, consume_get: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/consumers/ConsumePowerCondition.gd", "java_method_requestedPower_0", [usage, consume_get], null)
	var canonical = condition_requested_power_state(usage, consume_get)
	return {"source_owner": "SourceConsumePowerState.condition_requested_power_state", "generated_owner": "ConsumePowerCondition.requestedPower", "result": result, "canonical": canonical, "matches": result.get("requested_power", null) == canonical.get("requested_power", null)}

static func dynamic_requested_power_state(usage_get: float) -> Dictionary:
	return {"source_owner": "PortGame.source_consume_power_dynamic_requested_power_state", "source": "core/src/mindustry/world/consumers/ConsumePowerDynamic.java", "method": "public float requestedPower(Building entity){", "return_expr": "return usage.get(entity);", "usage_get": usage_get, "requested_power": usage_get}

static func generated_dynamic_requested_power_bridge_state(usage_get: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/consumers/ConsumePowerDynamic.gd", "java_method_requestedPower_0", [usage_get], null)
	var canonical = dynamic_requested_power_state(usage_get)
	return {"source_owner": "SourceConsumePowerState.dynamic_requested_power_state", "generated_owner": "ConsumePowerDynamic.requestedPower", "result": result, "canonical": canonical, "matches": result.get("requested_power", null) == canonical.get("requested_power", null)}

static func dynamic_display_state(displayed_power_usage: float, source_tick_rate: float) -> Dictionary:
	var power_use_value: float = displayed_power_usage * source_tick_rate
	var stats_add_call: Dictionary = {"stat": "Stat.powerUse", "value": power_use_value, "unit": "StatUnit.powerSecond"} if displayed_power_usage != 0.0 else {}
	return {"source_owner": "PortGame.source_consume_power_dynamic_display_state", "source": "core/src/mindustry/world/consumers/ConsumePowerDynamic.java", "method": "public void display(Stats stats){", "guard_expr": "if(displayedPowerUsage != 0f){", "stats_add_expr": "stats.add(Stat.powerUse, displayedPowerUsage * 60f, StatUnit.powerSecond);", "displayed_power_usage": displayed_power_usage, "power_use_value": power_use_value, "stats_add_call": stats_add_call}

static func generated_dynamic_display_bridge_state(displayed_power_usage: float, source_tick_rate: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/consumers/ConsumePowerDynamic.gd", "java_method_display_1", [displayed_power_usage, source_tick_rate], null)
	var canonical = dynamic_display_state(displayed_power_usage, source_tick_rate)
	return {"source_owner": "SourceConsumePowerState.dynamic_display_state", "generated_owner": "ConsumePowerDynamic.display", "result": result, "canonical": canonical, "matches": result.get("stats_add_call", null) == canonical.get("stats_add_call", null)}
