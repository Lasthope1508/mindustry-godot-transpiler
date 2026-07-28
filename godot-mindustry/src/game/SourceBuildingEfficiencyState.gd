extends RefCounted
class_name SourceBuildingEfficiencyState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceBlockDefaults := preload("res://src/game/SourceBlockDefaults.gd")
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
	return {"potential_efficiency": potential_efficiency * efficiency_scale, "efficiency": efficiency * efficiency_scale, "optional_efficiency": efficiency * efficiency_scale, "should_consume_power": true, "returned": true}

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
		optional_efficiency = min(optional_efficiency, float(result.get("efficiency", result.get("result", 1.0))))
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
		"source_owner": "PortGame.source_building_update_consumption_second_pass_state",
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

static func generated_consume_bridge_state(consumers: Array, self_state: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_consume_188", [consumers, self_state], null)
	var canonical = consume_state(consumers, self_state)
	return {
		"source_owner": "PortGame.source_building_consume_state",
		"generated_owner": "BuildingComp.java_method_consume_188",
		"result": result,
		"canonical": canonical,
	}

static func generated_can_consume_bridge_state(potential_efficiency: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_canConsume_189", [potential_efficiency], null)
	var canonical = can_consume_state(potential_efficiency)
	return {
		"source_owner": "PortGame.source_building_can_consume_state",
		"generated_owner": "BuildingComp.java_method_canConsume_189",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_efficiency_multiplier_bridge_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateEfficiencyMultiplier_192", [efficiency, optional_efficiency, efficiency_scale], null)
	var canonical = update_efficiency_multiplier_state(efficiency, optional_efficiency, efficiency_scale)
	return {
		"source_owner": "PortGame.source_building_update_efficiency_multiplier_state",
		"generated_owner": "BuildingComp.java_method_updateEfficiencyMultiplier_192",
		"result": result,
		"canonical": canonical,
	}

static func generated_efficiency_scale_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_efficiencyScale_193", [], null)
	var canonical = efficiency_scale_state()
	return {
		"source_owner": "PortGame.source_building_efficiency_scale_state",
		"generated_owner": "BuildingComp.java_method_efficiencyScale_193",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_initial_bridge_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale], null)
	var canonical = update_consumption_initial_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)
	return {
		"source_owner": "PortGame.source_building_update_consumption_initial_state",
		"generated_owner": "BuildingComp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_disabled_bridge_state(enabled_state: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, enabled_state, true, true, 1.0], null)
	var canonical = update_consumption_disabled_state(enabled_state)
	return {
		"source_owner": "PortGame.source_building_update_consumption_disabled_state",
		"generated_owner": "BuildingComp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_setup_bridge_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, production_valid, should_consume_state, 1.0], null)
	var canonical = update_consumption_setup_state(should_consume_state, production_valid)
	return {
		"source_owner": "PortGame.source_building_update_consumption_setup_state",
		"generated_owner": "BuildingComp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_non_optional_bridge_state(non_optional_consumer_results: Array) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, true, true, 1.0, non_optional_consumer_results], null)
	var canonical = update_consumption_non_optional_pass_state(non_optional_consumer_results)
	return {
		"source_owner": "PortGame.source_building_update_consumption_non_optional_pass_state",
		"generated_owner": "BuildingComp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_optional_bridge_state(optional_consumer_results: Array) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, true, true, 1.0, [], optional_consumer_results], null)
	var canonical = update_consumption_optional_pass_state(optional_consumer_results)
	return {
		"source_owner": "PortGame.source_building_update_consumption_optional_pass_state",
		"generated_owner": "BuildingComp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_efficiency_bridge_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, true, update, 1.0, [{"result": min_efficiency, "is_power": true}], [optional_efficiency], true], null)
	var canonical = update_consumption_efficiency_state(min_efficiency, optional_efficiency, update)
	return {
		"source_owner": "PortGame.source_building_update_consumption_efficiency_state",
		"generated_owner": "BuildingComp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_consumption_second_pass_bridge_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_updateConsumption_194", [true, false, true, true, update, 1.0, [{"result": efficiency, "is_power": true}], [efficiency], true, update_consumers, self_state], null)
	var result_efficiency := float(result.get("efficiency", efficiency))
	var canonical = update_consumption_second_pass_state(update, result_efficiency, update_consumers, self_state)
	return {
		"source_owner": "PortGame.source_building_update_consumption_second_pass_state",
		"generated_owner": "BuildingComp.java_method_updateConsumption_194",
		"result": result,
		"canonical": canonical,
	}

static func ambient_volume(efficiency: float) -> float:
	return efficiency

static func generated_ambient_volume_bridge_state(efficiency: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_ambientVolume_197", [efficiency], null)
	var canonical = ambient_volume(efficiency)
	return {
		"source_owner": "PortGame.source_building_ambient_volume",
		"generated_owner": "BuildingComp.java_method_ambientVolume_197",
		"result": result,
		"canonical": canonical,
	}

static func update_consumption_call_state() -> Dictionary:
	return {"update_consumption_called": true}

static func generated_update_consumption_call_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_update_217", [SourceBlockDefaults.TIME_SCALE_DEFAULT, 0.0, 0.0], null)
	var canonical = update_consumption_call_state()
	return {
		"source_owner": "PortGame.source_building_update_consumption_call_state",
		"generated_owner": "BuildingComp.java_method_update_217",
		"result": result,
		"canonical": canonical,
	}
