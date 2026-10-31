extends RefCounted
class_name SourceBuildingEfficiencyState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_COMMENT := "/** Called after efficiency is updated but before consumers are updated. Use to apply your own multiplier. */"
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_METHOD := "public void updateEfficiencyMultiplier(){"
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_SCALE := "float scale = efficiencyScale();"
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_EFFICIENCY := "efficiency *= scale;"
const SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_OPTIONAL := "optionalEfficiency *= scale;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_COMMENT := "//everything is valid when cheating"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_GUARD := "if(!block.hasConsumers || cheating()){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_POTENTIAL := "potentialEfficiency = enabled && productionValid() ? 1f : 0f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_EFFICIENCY := "efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_POWER := "shouldConsumePower = true;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_MULTIPLIER := "updateEfficiencyMultiplier();"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_RETURN := "return;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_COMMENT := "//disabled -> nothing works"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_GUARD := "if(!enabled){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_EFFICIENCIES := "potentialEfficiency = efficiency = optionalEfficiency = 0f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_POWER := "shouldConsumePower = false;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_RETURN := "return;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_UPDATE := "boolean update = shouldConsume() && productionValid();"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_MIN := "float minEfficiency = 1f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_COMMENT := "//assume efficiency is 1 for the calculations below"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_EFFICIENCIES := "efficiency = optionalEfficiency = 1f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_POWER := "shouldConsumePower = true;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_COMMENT := "//first pass: get the minimum efficiency of any consumer"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_LOOP := "for(var cons : block.nonOptionalConsumers){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_RESULT := "float result = cons.efficiency(self());"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_POWER_GATE := "if(cons != block.consPower && result <= 0.0000001f){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_POWER_STATE := "shouldConsumePower = false;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_MIN := "minEfficiency = Math.min(minEfficiency, result);"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_COMMENT := "//same for optionals"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_LOOP := "for(var cons : block.optionalConsumers){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_MIN := "optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_COMMENT := "//efficiency is now this minimum value"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_ASSIGN := "efficiency = minEfficiency;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_OPTIONAL_MIN := "optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_POTENTIAL_ASSIGN := "potentialEfficiency = efficiency;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_NO_UPDATE_ZERO := "efficiency = optionalEfficiency = 0f;"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_METHOD := "public void updateConsumption(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_MULTIPLIER := "updateEfficiencyMultiplier();"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_COMMENT := "//second pass: update every consumer based on efficiency"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_GUARD := "if(update && efficiency > 0){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_LOOP := "for(var cons : block.updateConsumers){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_UPDATE := "cons.update(self());"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL_METHOD := "public void update(){"
const SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL := "updateConsumption();"

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
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_consume_188", [consumers, self_state], null)
	var canonical = consume_state(consumers, self_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONSUME_STATE,
		"generated_owner": "building_comp.java_method_consume_188",
		"result": result,
		"canonical": canonical,
	}

static func generated_can_consume_bridge_state(potential_efficiency: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_canConsume_189", [potential_efficiency], null)
	var canonical = can_consume_state(potential_efficiency)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CAN_CONSUME_STATE,
		"generated_owner": "building_comp.java_method_canConsume_189",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_efficiency_multiplier_bridge_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateEfficiencyMultiplier_192", [efficiency, optional_efficiency, efficiency_scale], null)
	var canonical = update_efficiency_multiplier_state(efficiency, optional_efficiency, efficiency_scale)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_EFFICIENCY_MULTIPLIER_STATE,
		"generated_owner": "building_comp.java_method_updateEfficiencyMultiplier_192",
		"result": result,
		"canonical": canonical,
	}

static func generated_efficiency_scale_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_efficiencyScale_193", [], null)
	var canonical = efficiency_scale_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_EFFICIENCY_SCALE_STATE,
		"generated_owner": "building_comp.java_method_efficiencyScale_193",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_initial_bridge_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale], null)
	var canonical = update_consumption_initial_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_INITIAL_STATE,
		"generated_owner": "building_comp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_disabled_bridge_state(enabled_state: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, enabled_state, true, true, 1.0], null)
	var canonical = update_consumption_disabled_state(enabled_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_DISABLED_STATE,
		"generated_owner": "building_comp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_setup_bridge_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, production_valid, should_consume_state, 1.0], null)
	var canonical = update_consumption_setup_state(should_consume_state, production_valid)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_SETUP_STATE,
		"generated_owner": "building_comp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_non_optional_bridge_state(non_optional_consumer_results: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, true, true, 1.0, non_optional_consumer_results], null)
	var canonical = update_consumption_non_optional_pass_state(non_optional_consumer_results)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_NON_OPTIONAL_PASS_STATE,
		"generated_owner": "building_comp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_optional_bridge_state(optional_consumer_results: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, true, true, 1.0, [], optional_consumer_results], null)
	var canonical = update_consumption_optional_pass_state(optional_consumer_results)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_OPTIONAL_PASS_STATE,
		"generated_owner": "building_comp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_efficiency_bridge_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, true, update, 1.0, [{"result": min_efficiency, "is_power": true}], [{"result": optional_efficiency}], true], null)
	var canonical = update_consumption_efficiency_state(min_efficiency, optional_efficiency, update)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_EFFICIENCY_STATE,
		"generated_owner": "building_comp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_second_pass_bridge_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, true, update, 1.0, [{"result": efficiency, "is_power": true}], [{"result": efficiency}], true, update_consumers, self_state], null)
	var canonical = update_consumption_state(true, false, true, true, update, 1.0, [{"result": efficiency, "is_power": true}], [{"result": efficiency}], update_consumers, self_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_SECOND_PASS_STATE,
		"generated_owner": "building_comp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func ambient_volume(efficiency: float) -> float:
	return efficiency

static func generated_ambient_volume_bridge_state(efficiency: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_ambientVolume_197", [efficiency], null)
	var canonical = ambient_volume(efficiency)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_AMBIENT_VOLUME,
		"generated_owner": "building_comp.java_method_ambientVolume_197",
		"result": result,
		"canonical": canonical,
	}

static func update_consumption_call_state() -> Dictionary:
	return {"update_consumption_called": true}

static func generated_update_consumption_call_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_update_217", [source_block_defaults.TIME_SCALE_DEFAULT, 0.0, 0.0], null)
	var canonical = update_consumption_call_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_CONSUMPTION_CALL_STATE,
		"generated_owner": "building_comp.java_method_update_217",
		"result": result,
		"canonical": canonical,
	}
