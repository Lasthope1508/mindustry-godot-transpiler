extends RefCounted
class_name SourceConsumePowerState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE_CONSUME_POWER_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_POWER_GENERATED_CLASS
const SOURCE_CONSUME_POWER_CONDITION_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_POWER_CONDITION_GENERATED_CLASS
const SOURCE_CONSUME_POWER_DYNAMIC_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_GENERATED_CLASS
const SOURCE_CONSUME_POWER_SOURCE := source_consume_source_text_state.SOURCE_CONSUME_POWER_SOURCE
const SOURCE_CONSUME_POWER_CONDITION_SOURCE := source_consume_source_text_state.SOURCE_CONSUME_POWER_CONDITION_SOURCE
const SOURCE_CONSUME_POWER_DYNAMIC_SOURCE := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_SOURCE
const SOURCE_CONSUME_POWER_BLOCK_SOURCE := source_consume_source_text_state.SOURCE_CONSUME_POWER_BLOCK_SOURCE
const SOURCE_CONSUME_POWER_REQUESTED_POWER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_REQUESTED_POWER_METHOD
const SOURCE_CONSUME_POWER_REQUESTED_POWER_BUFFERED_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_REQUESTED_POWER_BUFFERED_EXPR
const SOURCE_CONSUME_POWER_REQUESTED_POWER_UNBUFFERED_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_REQUESTED_POWER_UNBUFFERED_EXPR
const SOURCE_CONSUME_POWER_APPLY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_APPLY_METHOD
const SOURCE_CONSUME_POWER_APPLY_HAS_POWER_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_APPLY_HAS_POWER_ASSIGNMENT_EXPR
const SOURCE_CONSUME_POWER_APPLY_CONS_POWER_ASSIGNMENT_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_APPLY_CONS_POWER_ASSIGNMENT_EXPR
const SOURCE_CONSUME_POWER_IGNORE_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_IGNORE_METHOD
const SOURCE_CONSUME_POWER_IGNORE_RETURN_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_IGNORE_RETURN_EXPR
const SOURCE_CONSUME_POWER_EFFICIENCY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_EFFICIENCY_METHOD
const SOURCE_CONSUME_POWER_EFFICIENCY_RETURN_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_EFFICIENCY_RETURN_EXPR
const SOURCE_CONSUME_POWER_DISPLAY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_DISPLAY_METHOD
const SOURCE_CONSUME_POWER_DISPLAY_BUFFERED_GUARD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_DISPLAY_BUFFERED_GUARD_EXPR
const SOURCE_CONSUME_POWER_DISPLAY_USAGE_GUARD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_DISPLAY_USAGE_GUARD_EXPR
const SOURCE_CONSUME_POWER_DISPLAY_CAPACITY_STATS_ADD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_DISPLAY_CAPACITY_STATS_ADD_EXPR
const SOURCE_CONSUME_POWER_DISPLAY_USAGE_STATS_ADD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_DISPLAY_USAGE_STATS_ADD_EXPR
const SOURCE_CONSUME_POWER_STAT_POWER_USE := source_consume_source_text_state.SOURCE_CONSUME_POWER_STAT_POWER_USE
const SOURCE_CONSUME_POWER_STAT_POWER_CAPACITY := source_consume_source_text_state.SOURCE_CONSUME_POWER_STAT_POWER_CAPACITY
const SOURCE_CONSUME_POWER_STAT_UNIT_POWER_SECOND := source_consume_source_text_state.SOURCE_CONSUME_POWER_STAT_UNIT_POWER_SECOND
const SOURCE_CONSUME_POWER_STAT_UNIT_NONE := source_consume_source_text_state.SOURCE_CONSUME_POWER_STAT_UNIT_NONE
const SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_METHOD
const SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_RETURN_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_RETURN_EXPR
const SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_METHOD
const SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_RETURN_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_RETURN_EXPR
const SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_METHOD
const SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_GUARD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_GUARD_EXPR
const SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_STATS_ADD_EXPR := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_STATS_ADD_EXPR
const SOURCE_CONSUME_POWER_REQUESTED_POWER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_REQUESTED_POWER_JAVA_METHOD
const SOURCE_CONSUME_POWER_APPLY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_APPLY_JAVA_METHOD
const SOURCE_CONSUME_POWER_IGNORE_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_IGNORE_JAVA_METHOD
const SOURCE_CONSUME_POWER_EFFICIENCY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_EFFICIENCY_JAVA_METHOD
const SOURCE_CONSUME_POWER_DISPLAY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_DISPLAY_JAVA_METHOD
const SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_JAVA_METHOD
const SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_JAVA_METHOD
const SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_JAVA_METHOD := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_JAVA_METHOD
const SOURCE_CONSUME_POWER_REQUESTED_POWER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_POWER_REQUESTED_POWER_GENERATED_OWNER
const SOURCE_CONSUME_POWER_APPLY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_POWER_APPLY_GENERATED_OWNER
const SOURCE_CONSUME_POWER_IGNORE_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_POWER_IGNORE_GENERATED_OWNER
const SOURCE_CONSUME_POWER_EFFICIENCY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_POWER_EFFICIENCY_GENERATED_OWNER
const SOURCE_CONSUME_POWER_DISPLAY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_POWER_DISPLAY_GENERATED_OWNER
const SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_GENERATED_OWNER
const SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_GENERATED_OWNER
const SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_GENERATED_OWNER

static func _consume_power_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_CONSUME_POWER_GENERATED_CLASS, generated_method, generated_args, null)

static func _consume_power_condition_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_CONSUME_POWER_CONDITION_GENERATED_CLASS, generated_method, generated_args, null)

static func _consume_power_dynamic_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_CONSUME_POWER_DYNAMIC_GENERATED_CLASS, generated_method, generated_args, null)

static func requested_power_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	var requested_power: float = (1.0 - power_status) * capacity if buffered else usage * (1.0 if should_consume else 0.0)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_REQUESTED_POWER_STATE, "source": SOURCE_CONSUME_POWER_SOURCE, "method": SOURCE_CONSUME_POWER_REQUESTED_POWER_METHOD, "buffered_expr": SOURCE_CONSUME_POWER_REQUESTED_POWER_BUFFERED_EXPR, "unbuffered_expr": SOURCE_CONSUME_POWER_REQUESTED_POWER_UNBUFFERED_EXPR, "buffered": buffered, "usage": usage, "capacity": capacity, "power_status": power_status, "should_consume": should_consume, "requested_power": requested_power}

static func generated_requested_power_bridge_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	var result = _consume_power_call(SOURCE_CONSUME_POWER_REQUESTED_POWER_JAVA_METHOD, [buffered, usage, capacity, power_status, should_consume])
	var canonical = requested_power_state(buffered, usage, capacity, power_status, should_consume)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_REQUESTED_POWER_STATE, "generated_owner": SOURCE_CONSUME_POWER_REQUESTED_POWER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("requested_power", null) == canonical.get("requested_power", null)}

static func apply_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_APPLY_STATE, "source": SOURCE_CONSUME_POWER_SOURCE, "block_source": SOURCE_CONSUME_POWER_BLOCK_SOURCE, "method": SOURCE_CONSUME_POWER_APPLY_METHOD, "has_power_assignment_expr": SOURCE_CONSUME_POWER_APPLY_HAS_POWER_ASSIGNMENT_EXPR, "cons_power_assignment_expr": SOURCE_CONSUME_POWER_APPLY_CONS_POWER_ASSIGNMENT_EXPR, "block_has_power_before": block_has_power_before, "block_cons_power_before": block_cons_power_before, "consume_power_state": consume_power_state, "block_has_power_after": true, "block_cons_power_after": consume_power_state}

static func generated_apply_bridge_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	var result = _consume_power_call(SOURCE_CONSUME_POWER_APPLY_JAVA_METHOD, [block_has_power_before, block_cons_power_before, consume_power_state])
	var canonical = apply_state(block_has_power_before, block_cons_power_before, consume_power_state)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_APPLY_STATE, "generated_owner": SOURCE_CONSUME_POWER_APPLY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("block_has_power_after", null) == canonical.get("block_has_power_after", null) and result.get("block_cons_power_after", null) == canonical.get("block_cons_power_after", null)}

static func ignore_state(buffered: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_IGNORE_STATE, "source": SOURCE_CONSUME_POWER_SOURCE, "method": SOURCE_CONSUME_POWER_IGNORE_METHOD, "return_expr": SOURCE_CONSUME_POWER_IGNORE_RETURN_EXPR, "buffered": buffered, "ignore": buffered}

static func generated_ignore_bridge_state(buffered: bool) -> Dictionary:
	var result = _consume_power_call(SOURCE_CONSUME_POWER_IGNORE_JAVA_METHOD, [buffered])
	var canonical = ignore_state(buffered)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_IGNORE_STATE, "generated_owner": SOURCE_CONSUME_POWER_IGNORE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("ignore", null) == canonical.get("ignore", null)}

static func efficiency_state(power_status: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_EFFICIENCY_STATE, "source": SOURCE_CONSUME_POWER_SOURCE, "method": SOURCE_CONSUME_POWER_EFFICIENCY_METHOD, "return_expr": SOURCE_CONSUME_POWER_EFFICIENCY_RETURN_EXPR, "power_status": power_status, "efficiency": power_status}

static func generated_efficiency_bridge_state(power_status: float) -> Dictionary:
	var result = _consume_power_call(SOURCE_CONSUME_POWER_EFFICIENCY_JAVA_METHOD, [power_status])
	var canonical = efficiency_state(power_status)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_EFFICIENCY_STATE, "generated_owner": SOURCE_CONSUME_POWER_EFFICIENCY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("efficiency", null) == canonical.get("efficiency", null)}

static func display_state(buffered: bool, usage: float, capacity: float, source_tick_rate: float) -> Dictionary:
	var power_use_value: float = usage * source_tick_rate
	var stats_add_call: Dictionary = {"stat": SOURCE_CONSUME_POWER_STAT_POWER_USE, "value": power_use_value, "unit": SOURCE_CONSUME_POWER_STAT_UNIT_POWER_SECOND} if (not buffered and usage > 0.0) else {"stat": SOURCE_CONSUME_POWER_STAT_POWER_CAPACITY, "value": capacity, "unit": SOURCE_CONSUME_POWER_STAT_UNIT_NONE} if buffered else {}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_DISPLAY_STATE, "source": SOURCE_CONSUME_POWER_SOURCE, "method": SOURCE_CONSUME_POWER_DISPLAY_METHOD, "buffered_guard_expr": SOURCE_CONSUME_POWER_DISPLAY_BUFFERED_GUARD_EXPR, "usage_guard_expr": SOURCE_CONSUME_POWER_DISPLAY_USAGE_GUARD_EXPR, "capacity_stats_add_expr": SOURCE_CONSUME_POWER_DISPLAY_CAPACITY_STATS_ADD_EXPR, "usage_stats_add_expr": SOURCE_CONSUME_POWER_DISPLAY_USAGE_STATS_ADD_EXPR, "buffered": buffered, "usage": usage, "capacity": capacity, "power_use_value": power_use_value, "stats_add_call": stats_add_call}

static func generated_display_bridge_state(buffered: bool, usage: float, capacity: float, source_tick_rate: float) -> Dictionary:
	var result = _consume_power_call(SOURCE_CONSUME_POWER_DISPLAY_JAVA_METHOD, [buffered, usage, capacity, source_tick_rate])
	var canonical = display_state(buffered, usage, capacity, source_tick_rate)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_DISPLAY_STATE, "generated_owner": SOURCE_CONSUME_POWER_DISPLAY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("stats_add_call", null) == canonical.get("stats_add_call", null)}

static func condition_requested_power_state(usage: float, consume_get: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_STATE, "source": SOURCE_CONSUME_POWER_CONDITION_SOURCE, "method": SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_METHOD, "return_expr": SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_RETURN_EXPR, "usage": usage, "consume_get": consume_get, "requested_power": usage if consume_get else 0.0}

static func generated_condition_requested_power_bridge_state(usage: float, consume_get: bool) -> Dictionary:
	var result = _consume_power_condition_call(SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_JAVA_METHOD, [usage, consume_get])
	var canonical = condition_requested_power_state(usage, consume_get)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_STATE, "generated_owner": SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("requested_power", null) == canonical.get("requested_power", null)}

static func dynamic_requested_power_state(usage_get: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_STATE, "source": SOURCE_CONSUME_POWER_DYNAMIC_SOURCE, "method": SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_METHOD, "return_expr": SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_RETURN_EXPR, "usage_get": usage_get, "requested_power": usage_get}

static func generated_dynamic_requested_power_bridge_state(usage_get: float) -> Dictionary:
	var result = _consume_power_dynamic_call(SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_JAVA_METHOD, [usage_get])
	var canonical = dynamic_requested_power_state(usage_get)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_STATE, "generated_owner": SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("requested_power", null) == canonical.get("requested_power", null)}

static func dynamic_display_state(displayed_power_usage: float, source_tick_rate: float) -> Dictionary:
	var power_use_value: float = displayed_power_usage * source_tick_rate
	var stats_add_call: Dictionary = {"stat": SOURCE_CONSUME_POWER_STAT_POWER_USE, "value": power_use_value, "unit": SOURCE_CONSUME_POWER_STAT_UNIT_POWER_SECOND} if displayed_power_usage != 0.0 else {}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_STATE, "source": SOURCE_CONSUME_POWER_DYNAMIC_SOURCE, "method": SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_METHOD, "guard_expr": SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_GUARD_EXPR, "stats_add_expr": SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_STATS_ADD_EXPR, "displayed_power_usage": displayed_power_usage, "power_use_value": power_use_value, "stats_add_call": stats_add_call}

static func generated_dynamic_display_bridge_state(displayed_power_usage: float, source_tick_rate: float) -> Dictionary:
	var result = _consume_power_dynamic_call(SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_JAVA_METHOD, [displayed_power_usage, source_tick_rate])
	var canonical = dynamic_display_state(displayed_power_usage, source_tick_rate)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_STATE, "generated_owner": SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("stats_add_call", null) == canonical.get("stats_add_call", null)}
