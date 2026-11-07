extends RefCounted
class_name SourceBuildingLifecyclePickupState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_building_lifecycle_source_text_state := preload("res://src/game/SourceBuildingLifecycleSourceTextState.gd")
const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_PICKED_UP_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_PICKED_UP_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_PICKED_UP_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_PICKED_UP_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_GENERATED_OWNER

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func can_pickup_state(block_can_pickup: bool) -> bool:
	return block_can_pickup

static func picked_up_state(previous_state: Variant) -> Dictionary:
	return {
		"method": "public void pickedUp(){",
		"comment": "Called right before this building is picked up.",
		"no_op": true,
		"previous_state": previous_state,
	}

static func after_picked_up_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	if power_present and has_cons_power and not cons_power_buffered:
		return {
			"power_present": power_present,
			"new_power_graph": power_present,
			"clear_links": power_present,
			"status": 0.0,
		}
	return {
		"power_present": power_present,
		"new_power_graph": power_present,
		"clear_links": power_present,
		"status": current_status,
	}

static func generated_can_pickup_bridge_state(block_can_pickup: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_JAVA_METHOD, [block_can_pickup])
	var canonical = can_pickup_state(block_can_pickup)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CAN_PICKUP_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_picked_up_bridge_state(previous_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_PICKED_UP_JAVA_METHOD, [previous_state])
	var canonical = picked_up_state(previous_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PICKED_UP_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_PICKED_UP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_after_picked_up_bridge_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_JAVA_METHOD, [power_present, has_cons_power, cons_power_buffered, current_status])
	var canonical = after_picked_up_state(power_present, has_cons_power, cons_power_buffered, current_status)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_AFTER_PICKED_UP_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}
