extends RefCounted
class_name SourceBuildingEfficiencyState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_building_efficiency_source_text_state := preload("res://src/game/SourceBuildingEfficiencySourceTextState.gd")
const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_EFFICIENCY_CONSUME_JAVA_METHOD := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_CONSUME_JAVA_METHOD
const SOURCE_BUILDING_EFFICIENCY_CONSUME_GENERATED_OWNER := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_CONSUME_GENERATED_OWNER
const SOURCE_BUILDING_EFFICIENCY_CAN_CONSUME_JAVA_METHOD := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_CAN_CONSUME_JAVA_METHOD
const SOURCE_BUILDING_EFFICIENCY_CAN_CONSUME_GENERATED_OWNER := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_CAN_CONSUME_GENERATED_OWNER
const SOURCE_BUILDING_EFFICIENCY_UPDATE_MULTIPLIER_JAVA_METHOD := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_UPDATE_MULTIPLIER_JAVA_METHOD
const SOURCE_BUILDING_EFFICIENCY_UPDATE_MULTIPLIER_GENERATED_OWNER := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_UPDATE_MULTIPLIER_GENERATED_OWNER
const SOURCE_BUILDING_EFFICIENCY_SCALE_JAVA_METHOD := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_SCALE_JAVA_METHOD
const SOURCE_BUILDING_EFFICIENCY_SCALE_GENERATED_OWNER := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_SCALE_GENERATED_OWNER
const SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_JAVA_METHOD := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_JAVA_METHOD
const SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_GENERATED_OWNER := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_GENERATED_OWNER
const SOURCE_BUILDING_EFFICIENCY_AMBIENT_VOLUME_JAVA_METHOD := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_AMBIENT_VOLUME_JAVA_METHOD
const SOURCE_BUILDING_EFFICIENCY_AMBIENT_VOLUME_GENERATED_OWNER := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_AMBIENT_VOLUME_GENERATED_OWNER
const SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_CALL_JAVA_METHOD := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_CALL_JAVA_METHOD
const SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_CALL_GENERATED_OWNER := source_building_efficiency_source_text_state.SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_CALL_GENERATED_OWNER
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_COMMENT := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_COMMENT
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_METHOD := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_METHOD
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_SCALE := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_SCALE
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_EFFICIENCY := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_EFFICIENCY
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_OPTIONAL := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_OPTIONAL
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_METHOD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_COMMENT := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_COMMENT
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_GUARD := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_GUARD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_POTENTIAL := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_POTENTIAL
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_EFFICIENCY := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_EFFICIENCY
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_POWER := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_POWER
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_MULTIPLIER := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_MULTIPLIER
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_RETURN := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_RETURN
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_METHOD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_COMMENT := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_COMMENT
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_GUARD := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_GUARD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_EFFICIENCIES := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_EFFICIENCIES
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_POWER := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_POWER
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_RETURN := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_RETURN
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_METHOD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_UPDATE := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_UPDATE
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_MIN := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_MIN
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_COMMENT := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_COMMENT
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_EFFICIENCIES := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_EFFICIENCIES
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_POWER := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_POWER
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_METHOD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_COMMENT := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_COMMENT
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_LOOP := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_LOOP
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_RESULT := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_RESULT
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_POWER_GATE := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_POWER_GATE
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_POWER_STATE := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_POWER_STATE
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_MIN := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_MIN
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_METHOD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_COMMENT := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_COMMENT
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_LOOP := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_LOOP
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_MIN := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_MIN
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_METHOD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_COMMENT := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_COMMENT
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_ASSIGN := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_ASSIGN
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_OPTIONAL_MIN := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_OPTIONAL_MIN
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_POTENTIAL_ASSIGN := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_POTENTIAL_ASSIGN
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_NO_UPDATE_ZERO := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_NO_UPDATE_ZERO
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_METHOD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_MULTIPLIER := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_MULTIPLIER
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_COMMENT := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_COMMENT
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_GUARD := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_GUARD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_LOOP := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_LOOP
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_UPDATE := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_UPDATE
const SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL_METHOD := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL_METHOD
const SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL := source_building_efficiency_source_text_state.SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func consume_state(consumers: Array, self_state: Variant) -> Dictionary:
	var triggered := []
	for consumer in consumers:
		triggered.append({"consumer": consumer, "self": self_state})
	return {"triggered": triggered}

static func can_consume_state(potential_efficiency: float) -> bool:
	return potential_efficiency > 0.0

static func efficiency_scale_state() -> float:
	return 1.0

static func update_efficiency_multiplier_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	return {"efficiency": efficiency * efficiency_scale, "optional_efficiency": optional_efficiency * efficiency_scale, "efficiency_scale": efficiency_scale}

static func update_consumption_initial_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:
	if has_consumers and not cheating:
		return {"returned": false}
	var potential_efficiency := 1.0 if enabled_state and production_valid else 0.0
	var efficiency := potential_efficiency if should_consume_state else 0.0
	var multiplied := update_efficiency_multiplier_state(efficiency, efficiency, efficiency_scale)
	return {"potential_efficiency": potential_efficiency, "efficiency": multiplied["efficiency"], "optional_efficiency": multiplied["optional_efficiency"], "should_consume_power": true, "returned": true}

static func update_consumption_disabled_state(enabled_state: bool) -> Dictionary:
	if enabled_state:
		return {"returned": false}
	return {"potential_efficiency": 0.0, "efficiency": 0.0, "optional_efficiency": 0.0, "should_consume_power": false, "returned": true}

static func update_consumption_setup_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	return {"update": should_consume_state and production_valid, "min_efficiency": 1.0, "efficiency": 1.0, "optional_efficiency": 1.0, "should_consume_power": true}

static func update_consumption_non_optional_pass_state(non_optional_consumer_results: Array) -> Dictionary:
	var min_efficiency := 1.0
	var should_consume_power := true
	for consumer in non_optional_consumer_results:
		var result := float(consumer.get("result", consumer.get("efficiency", 1.0)))
		if not bool(consumer.get("is_power", false)) and result <= 0.0000001:
			should_consume_power = false
		min_efficiency = min(min_efficiency, result)
	return {"non_optional_consumer_results": non_optional_consumer_results.duplicate(true), "min_efficiency": min_efficiency, "should_consume_power": should_consume_power}

static func update_consumption_optional_pass_state(optional_consumer_results: Array) -> Dictionary:
	var optional_efficiency := 1.0
	for result in optional_consumer_results:
		# Dictionary rows are canonical. Numeric rows remain a registered legacy adapter input.
		var efficiency := float(result.get("result", result.get("efficiency", 1.0))) if result is Dictionary else float(result)
		optional_efficiency = min(optional_efficiency, efficiency)
	return {"optional_consumer_results": optional_consumer_results.duplicate(true), "optional_efficiency": optional_efficiency}

static func update_consumption_efficiency_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:
	var efficiency := min_efficiency
	optional_efficiency = min(optional_efficiency, min_efficiency)
	var potential_efficiency := efficiency
	if not update:
		efficiency = 0.0
		optional_efficiency = 0.0
	return {"min_efficiency": min_efficiency, "optional_efficiency": optional_efficiency, "update": update, "efficiency": efficiency, "potential_efficiency": potential_efficiency}

static func update_consumption_second_pass_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:
	var updated_consumers := []
	if update and efficiency > 0.0:
		for consumer in update_consumers:
			updated_consumers.append({"consumer": consumer, "self": self_state})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_PASS_STATE,
		"method": SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_METHOD,
		"multiplier_call": SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_MULTIPLIER,
		"comment": SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_COMMENT,
		"guard": SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_GUARD,
		"loop": SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_LOOP,
		"update_call": SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_UPDATE,
		"update": update,
		"efficiency": efficiency,
		"updated_consumers": updated_consumers,
		"update_count": updated_consumers.size(),
	}

# Full method state; stage helpers remain the only owners of arithmetic and consumer loops.
static func update_consumption_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale: float, non_optional_consumer_results: Array, optional_consumer_results: Array, update_consumers: Array, self_state: Dictionary) -> Dictionary:
	var initial := update_consumption_initial_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)
	if initial["returned"]:
		initial.merge({"updated_consumers": [], "update_count": 0})
		return initial
	var disabled := update_consumption_disabled_state(enabled_state)
	if disabled["returned"]:
		disabled.merge({"updated_consumers": [], "update_count": 0})
		return disabled
	var setup := update_consumption_setup_state(should_consume_state, production_valid)
	var non_optional := update_consumption_non_optional_pass_state(non_optional_consumer_results)
	var optional := update_consumption_optional_pass_state(optional_consumer_results)
	var state := update_consumption_efficiency_state(non_optional["min_efficiency"], optional["optional_efficiency"], setup["update"])
	var multiplied := update_efficiency_multiplier_state(state["efficiency"], state["optional_efficiency"], efficiency_scale)
	state.merge({"efficiency": multiplied["efficiency"], "optional_efficiency": multiplied["optional_efficiency"], "should_consume_power": non_optional["should_consume_power"]}, true)
	var second_pass := update_consumption_second_pass_state(setup["update"], state["efficiency"], update_consumers, self_state)
	state.merge({"updated_consumers": second_pass["updated_consumers"], "update_count": second_pass["update_count"]})
	return state

# Runtime adapter: assign all Java fields before executing the planned consumer updates.
# The caller supplies concrete consumers implementing update(self_state); pure state APIs do not dispatch.
static func apply_update_consumption_state(consumption_state: Dictionary, self_state: Dictionary) -> Dictionary:
	self_state["potential_efficiency"] = consumption_state["potential_efficiency"]
	self_state["efficiency"] = consumption_state["efficiency"]
	self_state["optional_efficiency"] = consumption_state["optional_efficiency"]
	self_state["should_consume_power"] = consumption_state["should_consume_power"]
	for consumer in consumption_state["updated_consumers"]:
		consumer["consumer"].update(self_state)
	return consumption_state

static func generated_consume_bridge_state(consumers: Array, self_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_CONSUME_JAVA_METHOD, [consumers, self_state])
	var canonical = consume_state(consumers, self_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONSUME_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_CONSUME_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_can_consume_bridge_state(potential_efficiency: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_CAN_CONSUME_JAVA_METHOD, [potential_efficiency])
	var canonical = can_consume_state(potential_efficiency)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CAN_CONSUME_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_CAN_CONSUME_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_efficiency_multiplier_bridge_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_UPDATE_MULTIPLIER_JAVA_METHOD, [efficiency, optional_efficiency, efficiency_scale])
	var canonical = update_efficiency_multiplier_state(efficiency, optional_efficiency, efficiency_scale)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_UPDATE_MULTIPLIER_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_efficiency_scale_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_SCALE_JAVA_METHOD, [])
	var canonical = efficiency_scale_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_EFFICIENCY_SCALE_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_SCALE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_initial_bridge_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_JAVA_METHOD, [has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale])
	var canonical = update_consumption_initial_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_disabled_bridge_state(enabled_state: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_JAVA_METHOD, [true, false, enabled_state, true, true, 1.0])
	var canonical = update_consumption_disabled_state(enabled_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_setup_bridge_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_JAVA_METHOD, [true, false, true, production_valid, should_consume_state, 1.0])
	var canonical = update_consumption_setup_state(should_consume_state, production_valid)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_non_optional_bridge_state(non_optional_consumer_results: Array) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_JAVA_METHOD, [true, false, true, true, true, 1.0, non_optional_consumer_results])
	var canonical = update_consumption_non_optional_pass_state(non_optional_consumer_results)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_PASS_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_optional_bridge_state(optional_consumer_results: Array) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_JAVA_METHOD, [true, false, true, true, true, 1.0, [], optional_consumer_results])
	var canonical = update_consumption_optional_pass_state(optional_consumer_results)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_PASS_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_efficiency_bridge_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_JAVA_METHOD, [true, false, true, true, update, 1.0, [{"result": min_efficiency, "is_power": true}], [{"result": optional_efficiency}], true])
	var canonical = update_consumption_efficiency_state(min_efficiency, optional_efficiency, update)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_second_pass_bridge_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_JAVA_METHOD, [true, false, true, true, update, 1.0, [{"result": efficiency, "is_power": true}], [{"result": efficiency}], true, update_consumers, self_state])
	var canonical = update_consumption_state(true, false, true, true, update, 1.0, [{"result": efficiency, "is_power": true}], [{"result": efficiency}], update_consumers, self_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_PASS_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func ambient_volume(efficiency: float) -> float:
	return efficiency

static func generated_ambient_volume_bridge_state(efficiency: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_AMBIENT_VOLUME_JAVA_METHOD, [efficiency])
	var canonical = ambient_volume(efficiency)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_AMBIENT_VOLUME,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_AMBIENT_VOLUME_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func update_consumption_call_state() -> Dictionary:
	return {"update_consumption_called": true}

static func generated_update_consumption_call_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_CALL_JAVA_METHOD, [source_block_defaults.TIME_SCALE_DEFAULT, 0.0, 0.0])
	var canonical = update_consumption_call_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL_STATE,
		"generated_owner": SOURCE_BUILDING_EFFICIENCY_UPDATE_CONSUMPTION_CALL_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}
