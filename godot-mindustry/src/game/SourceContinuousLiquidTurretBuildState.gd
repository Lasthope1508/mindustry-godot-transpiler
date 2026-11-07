extends RefCounted
class_name SourceContinuousLiquidTurretBuildState

const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS
const SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS
const SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD
const SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_COMMENT := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_COMMENT
const SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_ACTIVATE_GUARD_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_ACTIVATE_GUARD_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_DEACTIVATE_GUARD_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_DEACTIVATE_GUARD_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_SWITCH_RETURN := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_SWITCH_RETURN
const SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE
const SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_DEFAULT_CASE := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_DEFAULT_CASE
const SOURCE_CONTINUOUS_LIQUID_TURRET_CURRENT_AMMO_TYPE_SENSOR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_CURRENT_AMMO_TYPE_SENSOR
const SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_COMMENT := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_COMMENT
const SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_RETURN_EXPR
const SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_METHOD := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_METHOD
const SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_RETURN_EXPR := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_RETURN_EXPR

static func _continuous_liquid_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func should_active_sound_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SHOULD_ACTIVE_SOUND_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_ACTIVE_SOUND_RETURN_EXPR, "should_active_sound": was_shooting and enabled, "was_shooting": was_shooting, "enabled": enabled}

static func get_ammo_content_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var ammo_content: Variant = current_liquid if not liquids_null and current_amount > 0.0 else null
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_GET_AMMO_CONTENT_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_CONTENT_RETURN_EXPR, "ammo_content": ammo_content, "liquids_null": liquids_null, "current_amount": current_amount, "current_liquid": current_liquid}

static func get_ammo_fraction_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var ammo_fraction := current_amount / liquid_capacity if liquid_capacity != 0.0 else 0.0
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_GET_AMMO_FRACTION_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_GET_AMMO_FRACTION_RETURN_EXPR, "ammo_fraction": ammo_fraction, "current_amount": current_amount, "liquid_capacity": liquid_capacity}

static func update_tile_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	var activate_threshold := liquid_consumed * 4.0
	var activated_after := activated_before
	if current_amount >= activate_threshold:
		activated_after = true
	elif current_amount < liquid_consumed:
		activated_after = false
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_UPDATE_TILE_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_METHOD, "comment": SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_COMMENT, "activate_guard_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_ACTIVATE_GUARD_EXPR, "deactivate_guard_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_UPDATE_TILE_DEACTIVATE_GUARD_EXPR, "activated_after": activated_after, "current_amount": current_amount, "liquid_consumed": liquid_consumed, "activated_before": activated_before, "super_update_tile_called": true}

static func sense_object_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var sense_object_value: Variant = super_sense_object_value
	if sensor == SOURCE_CONTINUOUS_LIQUID_TURRET_CURRENT_AMMO_TYPE_SENSOR:
		sense_object_value = current_liquid
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SENSE_OBJECT_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_METHOD, "switch_return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_SWITCH_RETURN, "current_ammo_type_case": SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE, "default_case": SOURCE_CONTINUOUS_LIQUID_TURRET_SENSE_OBJECT_DEFAULT_CASE, "sense_object_value": sense_object_value, "sensor": sensor, "current_liquid": current_liquid, "super_sense_object_value": super_sense_object_value}

static func can_consume_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	var can_consume := has_correct_ammo and super_can_consume
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_CAN_CONSUME_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_CAN_CONSUME_RETURN_EXPR, "can_consume": can_consume, "has_correct_ammo": has_correct_ammo, "super_can_consume": super_can_consume}

static func should_consume_state(super_should_consume: bool, activated: bool) -> Dictionary:
	var should_consume := super_should_consume and activated
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SHOULD_CONSUME_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_SHOULD_CONSUME_RETURN_EXPR, "should_consume": should_consume, "super_should_consume": super_should_consume, "activated": activated}

static func use_ammo_state(peek_ammo: Variant) -> Dictionary:
	var returned_ammo: Variant = peek_ammo
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_USE_AMMO_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_METHOD, "comment": SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_COMMENT, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_USE_AMMO_RETURN_EXPR, "returned_ammo": returned_ammo, "peek_ammo": peek_ammo}

static func peek_ammo_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_PEEK_AMMO_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_PEEK_AMMO_RETURN_EXPR, "peek_ammo": ammo_type, "current_liquid": current_liquid}

static func has_ammo_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	var ammo_type_present: bool = ammo_type != null
	var has_ammo := has_correct_ammo and ammo_type_present and current_amount > 0.0 and activated
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_HAS_AMMO_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_AMMO_RETURN_EXPR, "has_ammo": has_ammo, "ammo_type_present": ammo_type_present, "has_correct_ammo": has_correct_ammo, "current_liquid": current_liquid, "ammo_type": ammo_type, "current_amount": current_amount, "activated": activated}

static func has_correct_ammo_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	var has_correct_ammo: bool = (not bullets_any) or first_bullet_type == peek_ammo
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_HAS_CORRECT_AMMO_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_METHOD, "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_HAS_CORRECT_AMMO_RETURN_EXPR, "has_correct_ammo": has_correct_ammo, "bullets_any": bullets_any, "first_bullet_type": first_bullet_type, "peek_ammo": peek_ammo}

static func accept_item_state(source_building: Variant, item: Variant) -> Dictionary:
	var accept_item: bool = false
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACCEPT_ITEM_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_METHOD, "override_expr": "@Override", "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_ITEM_RETURN_EXPR, "accept_item": accept_item, "source_building": source_building, "item": item}

static func accept_liquid_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	var liquid_has_ammo_type: bool = ammo_type != null
	var same_liquid: bool = current_liquid == liquid
	var current_liquid_missing_ammo_type: bool = not current_liquid_ammo_type_present
	var current_required_with_epsilon: Variant = null
	var current_liquid_drained: bool = false
	if liquid_has_ammo_type and not same_liquid and current_liquid_ammo_type_present:
		current_required_with_epsilon = 1.0 / current_ammo_multiplier + source_turret_defaults.LIQUID_AMMO_EPSILON
		current_liquid_drained = current_liquid_amount <= current_required_with_epsilon
	var replacement_allowed: bool = false
	if liquid_has_ammo_type and not same_liquid:
		replacement_allowed = current_liquid_missing_ammo_type or current_liquid_drained
	var accept_liquid: bool = liquid_has_ammo_type and (same_liquid or replacement_allowed)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACCEPT_LIQUID_STATE, "inner_class": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_INNER_CLASS, "field": SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACTIVATED_FIELD, "method": SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_METHOD, "override_expr": "@Override", "return_expr": SOURCE_CONTINUOUS_LIQUID_TURRET_ACCEPT_LIQUID_RETURN_EXPR, "accept_liquid": accept_liquid, "source_building": source_building, "liquid": liquid, "ammo_type": ammo_type, "current_liquid": current_liquid, "current_liquid_ammo_type_present": current_liquid_ammo_type_present, "current_liquid_amount": current_liquid_amount, "current_ammo_multiplier": current_ammo_multiplier, "liquid_has_ammo_type": liquid_has_ammo_type, "same_liquid": same_liquid, "current_liquid_missing_ammo_type": current_liquid_missing_ammo_type, "current_required_with_epsilon": current_required_with_epsilon, "current_liquid_drained": current_liquid_drained, "replacement_allowed": replacement_allowed}

static func generated_should_active_sound_bridge_state(was_shooting: bool, enabled: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_shouldActiveSound_0", [was_shooting, enabled])
	var canonical = should_active_sound_state(was_shooting, enabled)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SHOULD_ACTIVE_SOUND_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.shouldActiveSound", "result": result, "canonical": canonical, "matches": result.get("should_active_sound", null) == canonical.get("should_active_sound", null) and result.get("was_shooting", null) == canonical.get("was_shooting", null) and result.get("enabled", null) == canonical.get("enabled", null)}

static func generated_get_ammo_content_bridge_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoContent_1", [liquids_null, current_amount, current_liquid])
	var canonical = get_ammo_content_state(liquids_null, current_amount, current_liquid)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_GET_AMMO_CONTENT_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.getAmmoContent", "result": result, "canonical": canonical, "matches": result.get("ammo_content", null) == canonical.get("ammo_content", null) and result.get("liquids_null", null) == canonical.get("liquids_null", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null)}

static func generated_get_ammo_fraction_bridge_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoFraction_2", [current_amount, liquid_capacity])
	var canonical = get_ammo_fraction_state(current_amount, liquid_capacity)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_GET_AMMO_FRACTION_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.getAmmoFraction", "result": result, "canonical": canonical, "matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("liquid_capacity", null) == canonical.get("liquid_capacity", null)}

static func generated_update_tile_bridge_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_updateTile_3", [current_amount, liquid_consumed, activated_before])
	var canonical = update_tile_state(current_amount, liquid_consumed, activated_before)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_UPDATE_TILE_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.updateTile", "result": result, "canonical": canonical, "matches": result.get("activated_after", null) == canonical.get("activated_after", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("liquid_consumed", null) == canonical.get("liquid_consumed", null) and result.get("activated_before", null) == canonical.get("activated_before", null) and result.get("super_update_tile_called", false) == canonical.get("super_update_tile_called", false)}

static func generated_sense_object_bridge_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_senseObject_4", [sensor, current_liquid, super_sense_object_value])
	var canonical = sense_object_state(sensor, current_liquid, super_sense_object_value)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SENSE_OBJECT_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.senseObject", "result": result, "canonical": canonical, "matches": result.get("sense_object_value", null) == canonical.get("sense_object_value", null) and result.get("sensor", null) == canonical.get("sensor", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null) and result.get("super_sense_object_value", null) == canonical.get("super_sense_object_value", null)}

static func generated_can_consume_bridge_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_canConsume_5", [has_correct_ammo, super_can_consume])
	var canonical = can_consume_state(has_correct_ammo, super_can_consume)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_CAN_CONSUME_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.canConsume", "result": result, "canonical": canonical, "matches": result.get("can_consume", null) == canonical.get("can_consume", null) and result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null) and result.get("super_can_consume", null) == canonical.get("super_can_consume", null)}

static func generated_should_consume_bridge_state(super_should_consume: bool, activated: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_shouldConsume_6", [super_should_consume, activated])
	var canonical = should_consume_state(super_should_consume, activated)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_SHOULD_CONSUME_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.shouldConsume", "result": result, "canonical": canonical, "matches": result.get("should_consume", null) == canonical.get("should_consume", null) and result.get("super_should_consume", null) == canonical.get("super_should_consume", null) and result.get("activated", null) == canonical.get("activated", null)}

static func generated_use_ammo_bridge_state(peek_ammo: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_useAmmo_7", [peek_ammo])
	var canonical = use_ammo_state(peek_ammo)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_USE_AMMO_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.useAmmo", "result": result, "canonical": canonical, "matches": result.get("returned_ammo", null) == canonical.get("returned_ammo", null) and result.get("peek_ammo", null) == canonical.get("peek_ammo", null)}

static func generated_peek_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_peekAmmo_8", [current_liquid, ammo_type])
	var canonical = peek_ammo_state(current_liquid, ammo_type)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_PEEK_AMMO_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.peekAmmo", "result": result, "canonical": canonical, "matches": result.get("peek_ammo", null) == canonical.get("peek_ammo", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null)}

static func generated_has_ammo_bridge_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_hasAmmo_9", [has_correct_ammo, current_liquid, ammo_type, current_amount, activated])
	var canonical = has_ammo_state(has_correct_ammo, current_liquid, ammo_type, current_amount, activated)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_HAS_AMMO_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.hasAmmo", "result": result, "canonical": canonical, "matches": result.get("has_ammo", null) == canonical.get("has_ammo", null) and result.get("ammo_type_present", null) == canonical.get("ammo_type_present", null) and result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null) and result.get("activated", null) == canonical.get("activated", null)}

static func generated_has_correct_ammo_bridge_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_hasCorrectAmmo_10", [bullets_any, first_bullet_type, peek_ammo])
	var canonical = has_correct_ammo_state(bullets_any, first_bullet_type, peek_ammo)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_HAS_CORRECT_AMMO_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.hasCorrectAmmo", "result": result, "canonical": canonical, "matches": result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null) and result.get("bullets_any", null) == canonical.get("bullets_any", null) and result.get("first_bullet_type", null) == canonical.get("first_bullet_type", null) and result.get("peek_ammo", null) == canonical.get("peek_ammo", null)}

static func generated_accept_item_bridge_state(source_building: Variant, item: Variant) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_acceptItem_11", [source_building, item])
	var canonical = accept_item_state(source_building, item)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACCEPT_ITEM_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.acceptItem", "result": result, "canonical": canonical, "matches": result.get("accept_item", null) == canonical.get("accept_item", null) and result.get("source_building", null) == canonical.get("source_building", null) and result.get("item", null) == canonical.get("item", null)}

static func generated_accept_liquid_bridge_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	var result = _continuous_liquid_turret_call("java_inner_class_ContinuousLiquidTurretBuild_method_acceptLiquid_12", [source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier])
	var canonical = accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_BUILD_ACCEPT_LIQUID_STATE, "generated_owner": "continuous_liquid_turret.ContinuousLiquidTurretBuild.acceptLiquid", "result": result, "canonical": canonical, "matches": result.get("accept_liquid", null) == canonical.get("accept_liquid", null) and result.get("replacement_allowed", null) == canonical.get("replacement_allowed", null) and result.get("current_required_with_epsilon", null) == canonical.get("current_required_with_epsilon", null)}
