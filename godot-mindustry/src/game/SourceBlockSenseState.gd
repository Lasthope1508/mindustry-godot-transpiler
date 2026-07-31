extends RefCounted
class_name SourceBlockSenseState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func laccess_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	var sense_value: float = NAN
	match sensor:
		"color":
			sense_value = map_color_double_bits
		"health", "maxHealth":
			sense_value = health_value
		"solid":
			sense_value = 1.0 if solid_value else 0.0
		"size":
			sense_value = float(size_value)
		"itemCapacity":
			sense_value = float(item_capacity)
		"liquidCapacity":
			sense_value = liquid_capacity
		"powerCapacity":
			sense_value = cons_power_capacity if has_cons_power and cons_power_buffered else 0.0
		"id":
			sense_value = float(logic_id)
		_:
			sense_value = NAN
	var sense_value_wire: Variant = sense_value
	if is_nan(sense_value):
		sense_value_wire = null
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_LACCESS_STATE, "source": "core/src/mindustry/world/Block.java", "override_expr": "@Override", "method": "public double sense(LAccess sensor){", "switch_expr": "return switch(sensor){", "color_case": "case color -> mapColor.toDoubleBits();", "health_case": "case health, maxHealth -> health;", "solid_case": "case solid -> solid ? 1 : 0;", "size_case": "case size -> size;", "item_capacity_case": "case itemCapacity -> itemCapacity;", "liquid_capacity_case": "case liquidCapacity -> liquidCapacity;", "power_capacity_case": "case powerCapacity -> consPower != null && consPower.buffered ? consPower.capacity : 0f;", "id_case": "case id -> getLogicId();", "default_expr": "default -> Double.NaN;", "sensor": sensor, "map_color_double_bits": map_color_double_bits, "health": health_value, "solid": solid_value, "size": size_value, "itemCapacity": item_capacity, "liquidCapacity": liquid_capacity, "has_cons_power": has_cons_power, "cons_power_buffered": cons_power_buffered, "cons_power_capacity": cons_power_capacity, "logic_id": logic_id, "sense_value": sense_value_wire, "sense_value_is_nan": is_nan(sense_value)}

static func content_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	var sense_value: float = NAN
	var matched_requirement_index: int = -1
	var matched_requirement: Variant = null
	var matched_amount: int = 0
	if content_type == "Item":
		sense_value = 0.0
		if state_rules_infinite_resources:
			sense_value = 0.0
		else:
			for index in range(requirements.size()):
				var requirement: Dictionary = {}
				if requirements[index] is Dictionary:
					requirement = requirements[index]
				if requirement.get("item") == content_item:
					matched_requirement_index = index
					matched_requirement = requirement
					matched_amount = int(floor(float(requirement.get("amount", 0.0)) * build_cost_multiplier + 0.5))
					sense_value = float(matched_amount)
					break
	var sense_value_wire: Variant = sense_value
	if is_nan(sense_value):
		sense_value_wire = null
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_CONTENT_STATE, "source": "core/src/mindustry/world/Block.java", "override_expr": "@Override", "method": "public double sense(Content content){", "item_instanceof_expr": "if(content instanceof Item item){", "infinite_resources_return_expr": "if(state.rules.infiniteResources) return 0;", "requirements_loop_expr": "for(ItemStack r : requirements){", "item_match_guard_expr": "if(r.item == item){", "amount_return_expr": "return Math.round(r.amount * state.rules.buildCostMultiplier);", "missing_item_return_expr": "return 0f;", "invalid_return_expr": "return Double.NaN;", "content_type": content_type, "content_item": content_item, "state_rules_infinite_resources": state_rules_infinite_resources, "requirements": requirements, "build_cost_multiplier": build_cost_multiplier, "matched_requirement_index": matched_requirement_index, "matched_requirement": matched_requirement, "matched_amount": matched_amount, "sense_value": sense_value_wire, "sense_value_is_nan": is_nan(sense_value)}

static func object_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	var sense_object_value: Variant = no_sensed
	if sensor == "name":
		sense_object_value = block_name
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_OBJECT_STATE, "source": "core/src/mindustry/world/Block.java", "override_expr": "@Override", "method": "public Object senseObject(LAccess sensor){", "name_guard_expr": "if(sensor == LAccess.name) return name;", "default_return_expr": "return noSensed;", "sensor": sensor, "block_name": block_name, "no_sensed": no_sensed, "sense_object_value": sense_object_value}

static func generated_block_sense_laccess_bridge_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_sense_132", [sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id], null)
	var canonical = laccess_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset_or_nan(result, canonical, "sense_value_is_nan", "sensor")
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_LACCESS_STATE, "generated_owner": "block.java_method_sense_132", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_sense_content_bridge_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_sense_133", [content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier], null)
	var canonical = content_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset_or_nan(result, canonical, "sense_value_is_nan", "content_type")
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_CONTENT_STATE, "generated_owner": "block.java_method_sense_133", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_sense_object_bridge_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_senseObject_134", [sensor, block_name, no_sensed], null)
	var canonical = object_state(sensor, block_name, no_sensed)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_OBJECT_STATE, "generated_owner": "block.java_method_senseObject_134", "result": result, "canonical": canonical, "matches": matches}
