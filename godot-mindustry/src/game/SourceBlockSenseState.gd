extends RefCounted
class_name SourceBlockSenseState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_sense_source_text_state := preload("res://src/game/SourceBlockSenseSourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_SENSE_SOURCE := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_SOURCE
const SOURCE_BLOCK_SENSE_LACCESS_METHOD := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_METHOD
const SOURCE_BLOCK_SENSE_LACCESS_JAVA_METHOD := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_JAVA_METHOD
const SOURCE_BLOCK_SENSE_LACCESS_GENERATED_OWNER := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_GENERATED_OWNER
const SOURCE_BLOCK_SENSE_LACCESS_SWITCH_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_SWITCH_EXPR
const SOURCE_BLOCK_SENSE_LACCESS_COLOR_CASE := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_COLOR_CASE
const SOURCE_BLOCK_SENSE_LACCESS_HEALTH_CASE := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_HEALTH_CASE
const SOURCE_BLOCK_SENSE_LACCESS_SOLID_CASE := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_SOLID_CASE
const SOURCE_BLOCK_SENSE_LACCESS_SIZE_CASE := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_SIZE_CASE
const SOURCE_BLOCK_SENSE_LACCESS_ITEM_CAPACITY_CASE := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_ITEM_CAPACITY_CASE
const SOURCE_BLOCK_SENSE_LACCESS_LIQUID_CAPACITY_CASE := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_LIQUID_CAPACITY_CASE
const SOURCE_BLOCK_SENSE_LACCESS_POWER_CAPACITY_CASE := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_POWER_CAPACITY_CASE
const SOURCE_BLOCK_SENSE_LACCESS_ID_CASE := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_ID_CASE
const SOURCE_BLOCK_SENSE_LACCESS_DEFAULT_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_LACCESS_DEFAULT_EXPR
const SOURCE_BLOCK_SENSE_CONTENT_METHOD := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_METHOD
const SOURCE_BLOCK_SENSE_CONTENT_JAVA_METHOD := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_JAVA_METHOD
const SOURCE_BLOCK_SENSE_CONTENT_GENERATED_OWNER := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_GENERATED_OWNER
const SOURCE_BLOCK_SENSE_CONTENT_ITEM_INSTANCEOF_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_ITEM_INSTANCEOF_EXPR
const SOURCE_BLOCK_SENSE_CONTENT_INFINITE_RESOURCES_RETURN_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_INFINITE_RESOURCES_RETURN_EXPR
const SOURCE_BLOCK_SENSE_CONTENT_REQUIREMENTS_LOOP_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_REQUIREMENTS_LOOP_EXPR
const SOURCE_BLOCK_SENSE_CONTENT_ITEM_MATCH_GUARD_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_ITEM_MATCH_GUARD_EXPR
const SOURCE_BLOCK_SENSE_CONTENT_AMOUNT_RETURN_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_AMOUNT_RETURN_EXPR
const SOURCE_BLOCK_SENSE_CONTENT_MISSING_ITEM_RETURN_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_MISSING_ITEM_RETURN_EXPR
const SOURCE_BLOCK_SENSE_CONTENT_INVALID_RETURN_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_CONTENT_INVALID_RETURN_EXPR
const SOURCE_BLOCK_SENSE_OBJECT_METHOD := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_OBJECT_METHOD
const SOURCE_BLOCK_SENSE_OBJECT_JAVA_METHOD := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_OBJECT_JAVA_METHOD
const SOURCE_BLOCK_SENSE_OBJECT_GENERATED_OWNER := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_OBJECT_GENERATED_OWNER
const SOURCE_BLOCK_SENSE_OBJECT_NAME_GUARD_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_OBJECT_NAME_GUARD_EXPR
const SOURCE_BLOCK_SENSE_OBJECT_DEFAULT_RETURN_EXPR := source_block_sense_source_text_state.SOURCE_BLOCK_SENSE_OBJECT_DEFAULT_RETURN_EXPR

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

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
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_LACCESS_STATE, "source": SOURCE_BLOCK_SENSE_SOURCE, "override_expr": "@Override", "method": SOURCE_BLOCK_SENSE_LACCESS_METHOD, "switch_expr": SOURCE_BLOCK_SENSE_LACCESS_SWITCH_EXPR, "color_case": SOURCE_BLOCK_SENSE_LACCESS_COLOR_CASE, "health_case": SOURCE_BLOCK_SENSE_LACCESS_HEALTH_CASE, "solid_case": SOURCE_BLOCK_SENSE_LACCESS_SOLID_CASE, "size_case": SOURCE_BLOCK_SENSE_LACCESS_SIZE_CASE, "item_capacity_case": SOURCE_BLOCK_SENSE_LACCESS_ITEM_CAPACITY_CASE, "liquid_capacity_case": SOURCE_BLOCK_SENSE_LACCESS_LIQUID_CAPACITY_CASE, "power_capacity_case": SOURCE_BLOCK_SENSE_LACCESS_POWER_CAPACITY_CASE, "id_case": SOURCE_BLOCK_SENSE_LACCESS_ID_CASE, "default_expr": SOURCE_BLOCK_SENSE_LACCESS_DEFAULT_EXPR, "sensor": sensor, "map_color_double_bits": map_color_double_bits, "health": health_value, "solid": solid_value, "size": size_value, "itemCapacity": item_capacity, "liquidCapacity": liquid_capacity, "has_cons_power": has_cons_power, "cons_power_buffered": cons_power_buffered, "cons_power_capacity": cons_power_capacity, "logic_id": logic_id, "sense_value": sense_value_wire, "sense_value_is_nan": is_nan(sense_value)}

static func generated_laccess_result_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	return laccess_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)

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
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_CONTENT_STATE, "source": SOURCE_BLOCK_SENSE_SOURCE, "override_expr": "@Override", "method": SOURCE_BLOCK_SENSE_CONTENT_METHOD, "item_instanceof_expr": SOURCE_BLOCK_SENSE_CONTENT_ITEM_INSTANCEOF_EXPR, "infinite_resources_return_expr": SOURCE_BLOCK_SENSE_CONTENT_INFINITE_RESOURCES_RETURN_EXPR, "requirements_loop_expr": SOURCE_BLOCK_SENSE_CONTENT_REQUIREMENTS_LOOP_EXPR, "item_match_guard_expr": SOURCE_BLOCK_SENSE_CONTENT_ITEM_MATCH_GUARD_EXPR, "amount_return_expr": SOURCE_BLOCK_SENSE_CONTENT_AMOUNT_RETURN_EXPR, "missing_item_return_expr": SOURCE_BLOCK_SENSE_CONTENT_MISSING_ITEM_RETURN_EXPR, "invalid_return_expr": SOURCE_BLOCK_SENSE_CONTENT_INVALID_RETURN_EXPR, "content_type": content_type, "content_item": content_item, "state_rules_infinite_resources": state_rules_infinite_resources, "requirements": requirements, "build_cost_multiplier": build_cost_multiplier, "matched_requirement_index": matched_requirement_index, "matched_requirement": matched_requirement, "matched_amount": matched_amount, "sense_value": sense_value_wire, "sense_value_is_nan": is_nan(sense_value)}

static func generated_content_result_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	return content_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)

static func object_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	var sense_object_value: Variant = no_sensed
	if sensor == "name":
		sense_object_value = block_name
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_OBJECT_STATE, "source": SOURCE_BLOCK_SENSE_SOURCE, "override_expr": "@Override", "method": SOURCE_BLOCK_SENSE_OBJECT_METHOD, "name_guard_expr": SOURCE_BLOCK_SENSE_OBJECT_NAME_GUARD_EXPR, "default_return_expr": SOURCE_BLOCK_SENSE_OBJECT_DEFAULT_RETURN_EXPR, "sensor": sensor, "block_name": block_name, "no_sensed": no_sensed, "sense_object_value": sense_object_value}

static func generated_object_result_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	return object_state(sensor, block_name, no_sensed)

static func generated_block_sense_laccess_bridge_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_SENSE_LACCESS_JAVA_METHOD, [sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id])
	var canonical = laccess_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset_or_nan(result, canonical, "sense_value_is_nan", "sensor")
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_LACCESS_STATE, "generated_owner": SOURCE_BLOCK_SENSE_LACCESS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_sense_content_bridge_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_SENSE_CONTENT_JAVA_METHOD, [content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier])
	var canonical = content_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset_or_nan(result, canonical, "sense_value_is_nan", "content_type")
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_CONTENT_STATE, "generated_owner": SOURCE_BLOCK_SENSE_CONTENT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_sense_object_bridge_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_SENSE_OBJECT_JAVA_METHOD, [sensor, block_name, no_sensed])
	var canonical = object_state(sensor, block_name, no_sensed)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SENSE_OBJECT_STATE, "generated_owner": SOURCE_BLOCK_SENSE_OBJECT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
