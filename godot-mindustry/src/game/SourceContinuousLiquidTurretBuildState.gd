extends RefCounted
class_name SourceContinuousLiquidTurretBuildState

const SourceTurretDefaults := preload("res://src/game/SourceTurretDefaults.gd")
const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func should_active_sound_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_should_active_sound_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "method": "public boolean shouldActiveSound(){", "return_expr": "return wasShooting && enabled;", "should_active_sound": was_shooting and enabled, "was_shooting": was_shooting, "enabled": enabled}

static func get_ammo_content_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var ammo_content: Variant = current_liquid if not liquids_null and current_amount > 0.0 else null
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_get_ammo_content_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "method": "public UnlockableContent getAmmoContent(){", "return_expr": "return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;", "ammo_content": ammo_content, "liquids_null": liquids_null, "current_amount": current_amount, "current_liquid": current_liquid}

static func get_ammo_fraction_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var ammo_fraction := current_amount / liquid_capacity if liquid_capacity != 0.0 else 0.0
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_get_ammo_fraction_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "method": "public float getAmmoFraction(){", "return_expr": "return liquids.currentAmount() / liquidCapacity;", "ammo_fraction": ammo_fraction, "current_amount": current_amount, "liquid_capacity": liquid_capacity}

static func update_tile_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	var activate_threshold := liquid_consumed * 4.0
	var activated_after := activated_before
	if current_amount >= activate_threshold:
		activated_after = true
	elif current_amount < liquid_consumed:
		activated_after = false
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_update_tile_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "method": "public void updateTile(){", "comment": "//only allow the turret to begin firing when it can fire for 4 continuous updates", "activate_guard_expr": "if(liquids.currentAmount() >= liquidConsumed * 4f){", "deactivate_guard_expr": "}else if(liquids.currentAmount() < liquidConsumed){", "activated_after": activated_after, "current_amount": current_amount, "liquid_consumed": liquid_consumed, "activated_before": activated_before, "super_update_tile_called": true}

static func sense_object_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var sense_object_value: Variant = super_sense_object_value
	if sensor == "currentAmmoType":
		sense_object_value = current_liquid
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_sense_object_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "field": "boolean activated;", "method": "public Object senseObject(LAccess sensor){", "switch_return_expr": "return switch(sensor){", "current_ammo_type_case": "case currentAmmoType -> liquids.current();", "default_case": "default -> super.senseObject(sensor);", "sense_object_value": sense_object_value, "sensor": sensor, "current_liquid": current_liquid, "super_sense_object_value": super_sense_object_value}

static func can_consume_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	var can_consume := has_correct_ammo and super_can_consume
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_can_consume_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "field": "boolean activated;", "method": "public boolean canConsume(){", "return_expr": "return hasCorrectAmmo() && super.canConsume();", "can_consume": can_consume, "has_correct_ammo": has_correct_ammo, "super_can_consume": super_can_consume}

static func should_consume_state(super_should_consume: bool, activated: bool) -> Dictionary:
	var should_consume := super_should_consume and activated
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_should_consume_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "field": "boolean activated;", "method": "public boolean shouldConsume(){", "return_expr": "return super.shouldConsume() && activated;", "should_consume": should_consume, "super_should_consume": super_should_consume, "activated": activated}

static func use_ammo_state(peek_ammo: Variant) -> Dictionary:
	var returned_ammo: Variant = peek_ammo
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_use_ammo_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "field": "boolean activated;", "method": "public BulletType useAmmo(){", "comment": "//does not consume ammo upon firing", "return_expr": "return peekAmmo();", "returned_ammo": returned_ammo, "peek_ammo": peek_ammo}

static func peek_ammo_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_peek_ammo_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "field": "boolean activated;", "method": "public BulletType peekAmmo(){", "return_expr": "return ammoTypes.get(liquids.current());", "peek_ammo": ammo_type, "current_liquid": current_liquid}

static func has_ammo_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	var ammo_type_present: bool = ammo_type != null
	var has_ammo := has_correct_ammo and ammo_type_present and current_amount > 0.0 and activated
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_has_ammo_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "field": "boolean activated;", "method": "public boolean hasAmmo(){", "return_expr": "return hasCorrectAmmo() && ammoTypes.get(liquids.current()) != null && liquids.currentAmount() > 0f && activated;", "has_ammo": has_ammo, "ammo_type_present": ammo_type_present, "has_correct_ammo": has_correct_ammo, "current_liquid": current_liquid, "ammo_type": ammo_type, "current_amount": current_amount, "activated": activated}

static func has_correct_ammo_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	var has_correct_ammo: bool = (not bullets_any) or first_bullet_type == peek_ammo
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_has_correct_ammo_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "field": "boolean activated;", "method": "public boolean hasCorrectAmmo(){", "return_expr": "return !bullets.any() || bullets.first().bullet.type == peekAmmo();", "has_correct_ammo": has_correct_ammo, "bullets_any": bullets_any, "first_bullet_type": first_bullet_type, "peek_ammo": peek_ammo}

static func accept_item_state(source_building: Variant, item: Variant) -> Dictionary:
	var accept_item: bool = false
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_accept_item_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "field": "boolean activated;", "method": "public boolean acceptItem(Building source, Item item){", "override_expr": "@Override", "return_expr": "return false;", "accept_item": accept_item, "source_building": source_building, "item": item}

static func accept_liquid_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	var liquid_has_ammo_type: bool = ammo_type != null
	var same_liquid: bool = current_liquid == liquid
	var current_liquid_missing_ammo_type: bool = not current_liquid_ammo_type_present
	var current_required_with_epsilon: Variant = null
	var current_liquid_drained: bool = false
	if liquid_has_ammo_type and not same_liquid and current_liquid_ammo_type_present:
		current_required_with_epsilon = 1.0 / current_ammo_multiplier + SourceTurretDefaults.LIQUID_AMMO_EPSILON
		current_liquid_drained = current_liquid_amount <= current_required_with_epsilon
	var replacement_allowed: bool = false
	if liquid_has_ammo_type and not same_liquid:
		replacement_allowed = current_liquid_missing_ammo_type or current_liquid_drained
	var accept_liquid: bool = liquid_has_ammo_type and (same_liquid or replacement_allowed)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_accept_liquid_state", "inner_class": "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "field": "boolean activated;", "method": "public boolean acceptLiquid(Building source, Liquid liquid){", "override_expr": "@Override", "return_expr": "return ammoTypes.get(liquid) != null && (liquids.current() == liquid || ((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));", "accept_liquid": accept_liquid, "source_building": source_building, "liquid": liquid, "ammo_type": ammo_type, "current_liquid": current_liquid, "current_liquid_ammo_type_present": current_liquid_ammo_type_present, "current_liquid_amount": current_liquid_amount, "current_ammo_multiplier": current_ammo_multiplier, "liquid_has_ammo_type": liquid_has_ammo_type, "same_liquid": same_liquid, "current_liquid_missing_ammo_type": current_liquid_missing_ammo_type, "current_required_with_epsilon": current_required_with_epsilon, "current_liquid_drained": current_liquid_drained, "replacement_allowed": replacement_allowed}

static func generated_should_active_sound_bridge_state(was_shooting: bool, enabled: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_shouldActiveSound_0", [was_shooting, enabled], null)
	var canonical = should_active_sound_state(was_shooting, enabled)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_should_active_sound_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.shouldActiveSound", "result": result, "canonical": canonical, "matches": result.get("should_active_sound", null) == canonical.get("should_active_sound", null) and result.get("was_shooting", null) == canonical.get("was_shooting", null) and result.get("enabled", null) == canonical.get("enabled", null)}

static func generated_get_ammo_content_bridge_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoContent_1", [liquids_null, current_amount, current_liquid], null)
	var canonical = get_ammo_content_state(liquids_null, current_amount, current_liquid)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_get_ammo_content_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.getAmmoContent", "result": result, "canonical": canonical, "matches": result.get("ammo_content", null) == canonical.get("ammo_content", null) and result.get("liquids_null", null) == canonical.get("liquids_null", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null)}

static func generated_get_ammo_fraction_bridge_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoFraction_2", [current_amount, liquid_capacity], null)
	var canonical = get_ammo_fraction_state(current_amount, liquid_capacity)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_get_ammo_fraction_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.getAmmoFraction", "result": result, "canonical": canonical, "matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("liquid_capacity", null) == canonical.get("liquid_capacity", null)}

static func generated_update_tile_bridge_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_updateTile_3", [current_amount, liquid_consumed, activated_before], null)
	var canonical = update_tile_state(current_amount, liquid_consumed, activated_before)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_update_tile_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.updateTile", "result": result, "canonical": canonical, "matches": result.get("activated_after", null) == canonical.get("activated_after", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("liquid_consumed", null) == canonical.get("liquid_consumed", null) and result.get("activated_before", null) == canonical.get("activated_before", null) and result.get("super_update_tile_called", false) == canonical.get("super_update_tile_called", false)}

static func generated_sense_object_bridge_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_senseObject_4", [sensor, current_liquid, super_sense_object_value], null)
	var canonical = sense_object_state(sensor, current_liquid, super_sense_object_value)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_sense_object_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.senseObject", "result": result, "canonical": canonical, "matches": result.get("sense_object_value", null) == canonical.get("sense_object_value", null) and result.get("sensor", null) == canonical.get("sensor", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null) and result.get("super_sense_object_value", null) == canonical.get("super_sense_object_value", null)}

static func generated_can_consume_bridge_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_canConsume_5", [has_correct_ammo, super_can_consume], null)
	var canonical = can_consume_state(has_correct_ammo, super_can_consume)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_can_consume_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.canConsume", "result": result, "canonical": canonical, "matches": result.get("can_consume", null) == canonical.get("can_consume", null) and result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null) and result.get("super_can_consume", null) == canonical.get("super_can_consume", null)}

static func generated_should_consume_bridge_state(super_should_consume: bool, activated: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_shouldConsume_6", [super_should_consume, activated], null)
	var canonical = should_consume_state(super_should_consume, activated)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_should_consume_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.shouldConsume", "result": result, "canonical": canonical, "matches": result.get("should_consume", null) == canonical.get("should_consume", null) and result.get("super_should_consume", null) == canonical.get("super_should_consume", null) and result.get("activated", null) == canonical.get("activated", null)}

static func generated_use_ammo_bridge_state(peek_ammo: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_useAmmo_7", [peek_ammo], null)
	var canonical = use_ammo_state(peek_ammo)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_use_ammo_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.useAmmo", "result": result, "canonical": canonical, "matches": result.get("returned_ammo", null) == canonical.get("returned_ammo", null) and result.get("peek_ammo", null) == canonical.get("peek_ammo", null)}

static func generated_peek_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_peekAmmo_8", [current_liquid, ammo_type], null)
	var canonical = peek_ammo_state(current_liquid, ammo_type)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_peek_ammo_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.peekAmmo", "result": result, "canonical": canonical, "matches": result.get("peek_ammo", null) == canonical.get("peek_ammo", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null)}

static func generated_has_ammo_bridge_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_hasAmmo_9", [has_correct_ammo, current_liquid, ammo_type, current_amount, activated], null)
	var canonical = has_ammo_state(has_correct_ammo, current_liquid, ammo_type, current_amount, activated)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_has_ammo_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.hasAmmo", "result": result, "canonical": canonical, "matches": result.get("has_ammo", null) == canonical.get("has_ammo", null) and result.get("ammo_type_present", null) == canonical.get("ammo_type_present", null) and result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null) and result.get("activated", null) == canonical.get("activated", null)}

static func generated_has_correct_ammo_bridge_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_hasCorrectAmmo_10", [bullets_any, first_bullet_type, peek_ammo], null)
	var canonical = has_correct_ammo_state(bullets_any, first_bullet_type, peek_ammo)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_has_correct_ammo_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.hasCorrectAmmo", "result": result, "canonical": canonical, "matches": result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null) and result.get("bullets_any", null) == canonical.get("bullets_any", null) and result.get("first_bullet_type", null) == canonical.get("first_bullet_type", null) and result.get("peek_ammo", null) == canonical.get("peek_ammo", null)}

static func generated_accept_item_bridge_state(source_building: Variant, item: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_acceptItem_11", [source_building, item], null)
	var canonical = accept_item_state(source_building, item)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_accept_item_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.acceptItem", "result": result, "canonical": canonical, "matches": result.get("accept_item", null) == canonical.get("accept_item", null) and result.get("source_building", null) == canonical.get("source_building", null) and result.get("item", null) == canonical.get("item", null)}

static func generated_accept_liquid_bridge_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_acceptLiquid_12", [source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier], null)
	var canonical = accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
	return {"source_owner": "PortGame.source_continuous_liquid_turret_build_accept_liquid_state", "generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.acceptLiquid", "result": result, "canonical": canonical, "matches": result.get("accept_liquid", null) == canonical.get("accept_liquid", null) and result.get("replacement_allowed", null) == canonical.get("replacement_allowed", null) and result.get("current_required_with_epsilon", null) == canonical.get("current_required_with_epsilon", null)}
