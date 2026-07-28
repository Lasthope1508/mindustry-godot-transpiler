extends RefCounted
class_name SourceLiquidTurretBuildState

const SourceTurretDefaults := preload("res://src/game/SourceTurretDefaults.gd")
const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func should_active_sound_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return {
		"source_owner": "PortGame.source_liquid_turret_build_should_active_sound_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "public boolean shouldActiveSound(){",
		"override_expr": "@Override",
		"return_expr": "return wasShooting && enabled;",
		"should_active_sound": was_shooting and enabled,
		"was_shooting": was_shooting,
		"enabled": enabled,
	}

static func get_ammo_content_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var ammo_content: Variant = current_liquid if not liquids_null and current_amount > 0.0 else null
	return {
		"source_owner": "PortGame.source_liquid_turret_build_get_ammo_content_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "public UnlockableContent getAmmoContent(){",
		"override_expr": "@Override",
		"return_expr": "return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;",
		"ammo_content": ammo_content,
		"liquids_null": liquids_null,
		"current_amount": current_amount,
		"current_liquid": current_liquid,
	}

static func get_ammo_fraction_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var ammo_fraction: float = current_amount / liquid_capacity if liquid_capacity != 0.0 else 0.0
	return {
		"source_owner": "PortGame.source_liquid_turret_build_get_ammo_fraction_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "public float getAmmoFraction(){",
		"override_expr": "@Override",
		"return_expr": "return liquids.currentAmount() / liquidCapacity;",
		"ammo_fraction": ammo_fraction,
		"current_amount": current_amount,
		"liquid_capacity": liquid_capacity,
	}

static func sense_object_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var sense_object_value: Variant = super_sense_object_value
	if sensor == "currentAmmoType":
		sense_object_value = current_liquid
	return {
		"source_owner": "PortGame.source_liquid_turret_build_sense_object_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "public Object senseObject(LAccess sensor){",
		"override_expr": "@Override",
		"switch_return_expr": "return switch(sensor){",
		"current_ammo_type_case": "case currentAmmoType -> liquids.current();",
		"default_case": "default -> super.senseObject(sensor);",
		"sense_object_value": sense_object_value,
		"sensor": sensor,
		"current_liquid": current_liquid,
		"super_sense_object_value": super_sense_object_value,
	}

static func find_target_extinguish_state(extinguish: bool, current_liquid_can_extinguish: bool, fire_result: Variant) -> Dictionary:
	var should_scan_fires: bool = extinguish and current_liquid_can_extinguish
	var target_after: Variant = null
	var target_assigned: bool = false
	var super_find_target_called: bool = true
	if should_scan_fires and fire_result != null:
		target_after = fire_result
		target_assigned = true
		super_find_target_called = false
	return {
		"source_owner": "PortGame.source_liquid_turret_build_find_target_extinguish_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "protected void findTarget(){",
		"override_expr": "@Override",
		"guard_expr": "if(extinguish && liquids.current().canExtinguish()){",
		"result_init_expr": "Fire result = null;",
		"assign_expr": "target = result;",
		"return_expr": "return;",
		"super_find_target_expr": "super.findTarget();",
		"extinguish": extinguish,
		"current_liquid_can_extinguish": current_liquid_can_extinguish,
		"fire_result": fire_result,
		"should_scan_fires": should_scan_fires,
		"target_after": target_after,
		"target_assigned": target_assigned,
		"super_find_target_called": super_find_target_called,
	}

static func use_ammo_state(cheating: bool, current_liquid: Variant, ammo_type: Variant, ammo_multiplier: float) -> Dictionary:
	var returned_ammo: Variant = ammo_type
	var liquid_remove_amount: float = 0.0
	var remove_liquid_call: Dictionary = {}
	if not cheating:
		liquid_remove_amount = 1.0 / ammo_multiplier
		remove_liquid_call = {"call": "liquids.remove(liquids.current(), 1f / type.ammoMultiplier);", "liquid": current_liquid, "amount": liquid_remove_amount}
	return {
		"source_owner": "PortGame.source_liquid_turret_build_use_ammo_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "public BulletType useAmmo(){",
		"override_expr": "@Override",
		"cheating_return_expr": "if(cheating()) return ammoTypes.get(liquids.current());",
		"type_lookup_expr": "BulletType type = ammoTypes.get(liquids.current());",
		"remove_expr": "liquids.remove(liquids.current(), 1f / type.ammoMultiplier);",
		"return_expr": "return type;",
		"returned_ammo": returned_ammo,
		"cheating": cheating,
		"current_liquid": current_liquid,
		"ammo_type": ammo_type,
		"ammo_multiplier": ammo_multiplier,
		"liquid_remove_amount": liquid_remove_amount,
		"remove_liquid_call": remove_liquid_call,
	}

static func peek_ammo_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return {
		"source_owner": "PortGame.source_liquid_turret_build_peek_ammo_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "public BulletType peekAmmo(){",
		"override_expr": "@Override",
		"return_expr": "return ammoTypes.get(liquids.current());",
		"peek_ammo": ammo_type,
		"current_liquid": current_liquid,
	}

static func has_ammo_state(current_liquid: Variant, ammo_type: Variant, current_amount: float, ammo_multiplier: float) -> Dictionary:
	var ammo_type_present: bool = ammo_type != null
	var required_amount: float = 1.0 / ammo_multiplier
	var has_ammo: bool = ammo_type_present and current_amount >= required_amount
	return {
		"source_owner": "PortGame.source_liquid_turret_build_has_ammo_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "public boolean hasAmmo(){",
		"override_expr": "@Override",
		"return_expr": "return ammoTypes.get(liquids.current()) != null && liquids.currentAmount() >= 1f / ammoTypes.get(liquids.current()).ammoMultiplier;",
		"has_ammo": has_ammo,
		"ammo_type_present": ammo_type_present,
		"current_liquid": current_liquid,
		"ammo_type": ammo_type,
		"current_amount": current_amount,
		"ammo_multiplier": ammo_multiplier,
		"required_amount": required_amount,
	}

static func accept_item_state(source_building: Variant, item: Variant) -> Dictionary:
	var accept_item: bool = false
	return {
		"source_owner": "PortGame.source_liquid_turret_build_accept_item_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "public boolean acceptItem(Building source, Item item){",
		"override_expr": "@Override",
		"return_expr": "return false;",
		"accept_item": accept_item,
		"source_building": source_building,
		"item": item,
	}

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
	return {
		"source_owner": "PortGame.source_liquid_turret_build_accept_liquid_state",
		"inner_class": "public class LiquidTurretBuild extends TurretBuild{",
		"method": "public boolean acceptLiquid(Building source, Liquid liquid){",
		"override_expr": "@Override",
		"return_expr": "return ammoTypes.get(liquid) != null && (liquids.current() == liquid || ((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));",
		"accept_liquid": accept_liquid,
		"source_building": source_building,
		"liquid": liquid,
		"ammo_type": ammo_type,
		"current_liquid": current_liquid,
		"current_liquid_ammo_type_present": current_liquid_ammo_type_present,
		"current_liquid_amount": current_liquid_amount,
		"current_ammo_multiplier": current_ammo_multiplier,
		"liquid_has_ammo_type": liquid_has_ammo_type,
		"same_liquid": same_liquid,
		"current_liquid_missing_ammo_type": current_liquid_missing_ammo_type,
		"current_required_with_epsilon": current_required_with_epsilon,
		"current_liquid_drained": current_liquid_drained,
		"replacement_allowed": replacement_allowed,
	}

static func generated_should_active_sound_bridge_state(was_shooting: bool, enabled: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_shouldActiveSound_0", [was_shooting, enabled], null)
	var canonical = should_active_sound_state(was_shooting, enabled)
	return {"source_owner": "PortGame.source_liquid_turret_build_should_active_sound_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.shouldActiveSound", "result": result, "canonical": canonical, "matches": result.get("should_active_sound", null) == canonical.get("should_active_sound", null) and result.get("was_shooting", null) == canonical.get("was_shooting", null) and result.get("enabled", null) == canonical.get("enabled", null)}

static func generated_get_ammo_content_bridge_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_getAmmoContent_1", [liquids_null, current_amount, current_liquid], null)
	var canonical = get_ammo_content_state(liquids_null, current_amount, current_liquid)
	return {"source_owner": "PortGame.source_liquid_turret_build_get_ammo_content_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.getAmmoContent", "result": result, "canonical": canonical, "matches": result.get("ammo_content", null) == canonical.get("ammo_content", null) and result.get("liquids_null", null) == canonical.get("liquids_null", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null)}

static func generated_get_ammo_fraction_bridge_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_getAmmoFraction_2", [current_amount, liquid_capacity], null)
	var canonical = get_ammo_fraction_state(current_amount, liquid_capacity)
	return {"source_owner": "PortGame.source_liquid_turret_build_get_ammo_fraction_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.getAmmoFraction", "result": result, "canonical": canonical, "matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null) and result.get("current_amount", null) == canonical.get("current_amount", null) and result.get("liquid_capacity", null) == canonical.get("liquid_capacity", null)}

static func generated_sense_object_bridge_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_senseObject_3", [sensor, current_liquid, super_sense_object_value], null)
	var canonical = sense_object_state(sensor, current_liquid, super_sense_object_value)
	return {"source_owner": "PortGame.source_liquid_turret_build_sense_object_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.senseObject", "result": result, "canonical": canonical, "matches": result.get("sense_object_value", null) == canonical.get("sense_object_value", null) and result.get("sensor", null) == canonical.get("sensor", null) and result.get("current_liquid", null) == canonical.get("current_liquid", null) and result.get("super_sense_object_value", null) == canonical.get("super_sense_object_value", null)}

static func generated_find_target_extinguish_bridge_state(extinguish: bool, current_liquid_can_extinguish: bool, fire_result: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_findTarget_4", [extinguish, current_liquid_can_extinguish, fire_result], null)
	var canonical = find_target_extinguish_state(extinguish, current_liquid_can_extinguish, fire_result)
	return {"source_owner": "PortGame.source_liquid_turret_build_find_target_extinguish_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.findTarget", "result": result, "canonical": canonical, "matches": result.get("target_after", null) == canonical.get("target_after", null) and result.get("target_assigned", null) == canonical.get("target_assigned", null) and result.get("super_find_target_called", null) == canonical.get("super_find_target_called", null) and result.get("should_scan_fires", null) == canonical.get("should_scan_fires", null)}

static func generated_use_ammo_bridge_state(cheating: bool, current_liquid: Variant, ammo_type: Variant, ammo_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_useAmmo_5", [cheating, current_liquid, ammo_type, ammo_multiplier], null)
	var canonical = use_ammo_state(cheating, current_liquid, ammo_type, ammo_multiplier)
	return {"source_owner": "PortGame.source_liquid_turret_build_use_ammo_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.useAmmo", "result": result, "canonical": canonical, "matches": result.get("returned_ammo", null) == canonical.get("returned_ammo", null) and result.get("liquid_remove_amount", null) == canonical.get("liquid_remove_amount", null) and result.get("remove_liquid_call", {}) == canonical.get("remove_liquid_call", {}) and result.get("cheating", null) == canonical.get("cheating", null)}

static func generated_peek_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_peekAmmo_6", [current_liquid, ammo_type], null)
	var canonical = peek_ammo_state(current_liquid, ammo_type)
	return {"source_owner": "PortGame.source_liquid_turret_build_peek_ammo_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.peekAmmo", "result": result, "canonical": canonical, "matches": result.get("peek_ammo", null) == canonical.get("peek_ammo", null)}

static func generated_has_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant, current_amount: float, ammo_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_hasAmmo_7", [current_liquid, ammo_type, current_amount, ammo_multiplier], null)
	var canonical = has_ammo_state(current_liquid, ammo_type, current_amount, ammo_multiplier)
	return {"source_owner": "PortGame.source_liquid_turret_build_has_ammo_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.hasAmmo", "result": result, "canonical": canonical, "matches": result.get("has_ammo", null) == canonical.get("has_ammo", null) and result.get("required_amount", null) == canonical.get("required_amount", null) and result.get("ammo_type_present", null) == canonical.get("ammo_type_present", null)}

static func generated_accept_item_bridge_state(source_building: Variant, item: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_acceptItem_8", [source_building, item], null)
	var canonical = accept_item_state(source_building, item)
	return {"source_owner": "PortGame.source_liquid_turret_build_accept_item_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.acceptItem", "result": result, "canonical": canonical, "matches": result.get("accept_item", null) == canonical.get("accept_item", null)}

static func generated_accept_liquid_bridge_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_acceptLiquid_9", [source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier], null)
	var canonical = accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
	return {"source_owner": "PortGame.source_liquid_turret_build_accept_liquid_state", "generated_owner": "LiquidTurret.LiquidTurretBuild.acceptLiquid", "result": result, "canonical": canonical, "matches": result.get("accept_liquid", null) == canonical.get("accept_liquid", null) and result.get("replacement_allowed", null) == canonical.get("replacement_allowed", null) and result.get("current_required_with_epsilon", null) == canonical.get("current_required_with_epsilon", null)}
