# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/LiquidTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "LiquidTurret"
const JAVA_EXTENDS := "Turret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "ammoTypes", "type": "ObjectMap"}, {"modifiers": ["public"], "name": "extinguish", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LiquidTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "ammo", "parameters": [{"name": "objects", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_ammo_0(_args: Array = []) -> Variant:
	var objects: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	return {"source_owner": "PortGame.source_liquid_turret_ammo_state", "field": "public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();", "comment": "/** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */", "method": "public void ammo(Object... objects){", "assignment_expr": "ammoTypes = ObjectMap.of(objects);", "objects": objects, "ammo_types_after": objects}

func java_method_setStats_1(_args: Array = []) -> Variant:
	var ammo_types: Variant = _args[0] if _args.size() > 0 else null
	var name_value: String = str(_args[1] if _args.size() > 1 else "")
	var ammo_values_call: Dictionary = {"call": "StatValues.ammo(ammoTypes, name)", "ammo_types": ammo_types, "name": name_value}
	var stats_add_call: Dictionary = {"call": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));", "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {"source_owner": "PortGame.source_liquid_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "stats_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));", "ammo_types": ammo_types, "name_value": name_value, "super_set_stats_called": true, "stats_added": true, "ammo_values_call": ammo_values_call, "stats_add_call": stats_add_call}

func java_method_init_2(_args: Array = []) -> Variant:
	var ammo_entries: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var target_ground: bool = bool(_args[1] if _args.size() > 1 else false)
	var current_place_overlap_range: float = float(_args[2] if _args.size() > 2 else 0.0)
	var range_value: float = float(_args[3] if _args.size() > 3 else 0.0)
	var place_overlap_margin: float = float(_args[4] if _args.size() > 4 else 0.0)
	var consume_call: Dictionary = {"call": "consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){...});", "filter_expr": "i -> ammoTypes.containsKey(i)", "amount": 1.0, "update_override_noop": true, "display_override_noop": true}
	var overlap_updates: Array = []
	if target_ground:
		for entry in ammo_entries:
			var entry_dict: Dictionary = entry if entry is Dictionary else {}
			var type_state: Variant = entry_dict.get("type", {})
			var range_change: float = 0.0
			if type_state is Dictionary:
				range_change = float(type_state.get("rangeChange", 0.0))
			var before_range: float = current_place_overlap_range
			var candidate_range: float = range_value + range_change + place_overlap_margin
			current_place_overlap_range = max(current_place_overlap_range, candidate_range)
			overlap_updates.append({"item": entry_dict.get("item", null), "type": type_state, "range_change": range_change, "candidate_range": candidate_range, "before": before_range, "after": current_place_overlap_range})
	return {"source_owner": "PortGame.source_liquid_turret_init_state", "method": "public void init(){", "override_expr": "@Override", "consume_expr": "consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){", "filter_expr": "i -> ammoTypes.containsKey(i)", "consume_call": consume_call, "target_ground_expr": "if(targetGround){", "overlap_expr": "ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));", "super_init_expr": "super.init();", "ammo_entries": ammo_entries, "target_ground": target_ground, "place_overlap_range_before": float(_args[2] if _args.size() > 2 else 0.0), "range_value": range_value, "place_overlap_margin": place_overlap_margin, "overlap_updates": overlap_updates, "place_overlap_range_after": current_place_overlap_range, "super_init_called": true}

func java_inner_class_LiquidTurretBuild_method_shouldActiveSound_0(_args: Array = []) -> Variant:
	var was_shooting: bool = bool(_args[0] if _args.size() > 0 else false)
	var enabled: bool = bool(_args[1] if _args.size() > 1 else false)
	return {"source_owner": "PortGame.source_liquid_turret_build_should_active_sound_state", "inner_class": "public class LiquidTurretBuild extends TurretBuild{", "method": "public boolean shouldActiveSound(){", "override_expr": "@Override", "return_expr": "return wasShooting && enabled;", "was_shooting": was_shooting, "enabled": enabled, "should_active_sound": was_shooting and enabled}

func java_inner_class_LiquidTurretBuild_method_getAmmoContent_1(_args: Array = []) -> Variant:
	var liquids_null: bool = bool(_args[0] if _args.size() > 0 else true)
	var current_amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var current_liquid: Variant = _args[2] if _args.size() > 2 else null
	var ammo_content: Variant = current_liquid if not liquids_null and current_amount > 0.0 else null
	return {"source_owner": "PortGame.source_liquid_turret_build_get_ammo_content_state", "inner_class": "public class LiquidTurretBuild extends TurretBuild{", "method": "public UnlockableContent getAmmoContent(){", "override_expr": "@Override", "return_expr": "return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;", "liquids_null": liquids_null, "current_amount": current_amount, "current_liquid": current_liquid, "ammo_content": ammo_content}

func java_inner_class_LiquidTurretBuild_method_getAmmoFraction_2(_args: Array = []) -> Variant:
	var current_amount: float = float(_args[0] if _args.size() > 0 else 0.0)
	var liquid_capacity: float = float(_args[1] if _args.size() > 1 else 1.0)
	var ammo_fraction: float = current_amount / liquid_capacity
	return {"source_owner": "PortGame.source_liquid_turret_build_get_ammo_fraction_state", "inner_class": "public class LiquidTurretBuild extends TurretBuild{", "method": "public float getAmmoFraction(){", "override_expr": "@Override", "return_expr": "return liquids.currentAmount() / liquidCapacity;", "current_amount": current_amount, "liquid_capacity": liquid_capacity, "ammo_fraction": ammo_fraction}

func java_inner_class_LiquidTurretBuild_method_senseObject_3(_args: Array = []) -> Variant:
	var sensor: String = str(_args[0] if _args.size() > 0 else "")
	var current_liquid: Variant = _args[1] if _args.size() > 1 else null
	var super_sense_object_value: Variant = _args[2] if _args.size() > 2 else null
	var sense_object_value: Variant = null
	if sensor == "currentAmmoType":
		sense_object_value = current_liquid
	else:
		sense_object_value = super_sense_object_value
	return {"source_owner": "PortGame.source_liquid_turret_build_sense_object_state", "inner_class": "public class LiquidTurretBuild extends TurretBuild{", "method": "public Object senseObject(LAccess sensor){", "override_expr": "@Override", "switch_return_expr": "return switch(sensor){", "current_ammo_type_case": "case currentAmmoType -> liquids.current();", "default_case": "default -> super.senseObject(sensor);", "sensor": sensor, "current_liquid": current_liquid, "super_sense_object_value": super_sense_object_value, "sense_object_value": sense_object_value}

func java_inner_class_LiquidTurretBuild_method_findTarget_4(_args: Array = []) -> Variant:
	var extinguish: bool = bool(_args[0] if _args.size() > 0 else false)
	var current_liquid_can_extinguish: bool = bool(_args[1] if _args.size() > 1 else false)
	var fire_result: Variant = _args[2] if _args.size() > 2 else null
	var should_scan_fires: bool = extinguish and current_liquid_can_extinguish
	var target_after: Variant = null
	var target_assigned: bool = false
	var super_find_target_called: bool = true
	if should_scan_fires and fire_result != null:
		target_after = fire_result
		target_assigned = true
		super_find_target_called = false
	return {"source_owner": "PortGame.source_liquid_turret_build_find_target_extinguish_state", "inner_class": "public class LiquidTurretBuild extends TurretBuild{", "method": "protected void findTarget(){", "override_expr": "@Override", "guard_expr": "if(extinguish && liquids.current().canExtinguish()){", "result_init_expr": "Fire result = null;", "assign_expr": "target = result;", "return_expr": "return;", "super_find_target_expr": "super.findTarget();", "extinguish": extinguish, "current_liquid_can_extinguish": current_liquid_can_extinguish, "fire_result": fire_result, "should_scan_fires": should_scan_fires, "target_after": target_after, "target_assigned": target_assigned, "super_find_target_called": super_find_target_called}

func java_inner_class_LiquidTurretBuild_method_useAmmo_5(_args: Array = []) -> Variant:
	var cheating: bool = bool(_args[0] if _args.size() > 0 else false)
	var current_liquid: Variant = _args[1] if _args.size() > 1 else null
	var ammo_type: Variant = _args[2] if _args.size() > 2 else null
	var ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)
	var returned_ammo: Variant = ammo_type
	var liquid_remove_amount: float = 0.0
	var remove_liquid_call: Dictionary = {}
	if not cheating:
		liquid_remove_amount = 1.0 / ammo_multiplier
		remove_liquid_call = {"call": "liquids.remove(liquids.current(), 1f / type.ammoMultiplier);", "liquid": current_liquid, "amount": liquid_remove_amount}
	return {"source_owner": "PortGame.source_liquid_turret_build_use_ammo_state", "inner_class": "public class LiquidTurretBuild extends TurretBuild{", "method": "public BulletType useAmmo(){", "override_expr": "@Override", "cheating_return_expr": "if(cheating()) return ammoTypes.get(liquids.current());", "type_lookup_expr": "BulletType type = ammoTypes.get(liquids.current());", "remove_expr": "liquids.remove(liquids.current(), 1f / type.ammoMultiplier);", "return_expr": "return type;", "cheating": cheating, "current_liquid": current_liquid, "ammo_type": ammo_type, "ammo_multiplier": ammo_multiplier, "liquid_remove_amount": liquid_remove_amount, "remove_liquid_call": remove_liquid_call, "returned_ammo": returned_ammo}

func java_inner_class_LiquidTurretBuild_method_peekAmmo_6(_args: Array = []) -> Variant:
	var current_liquid: Variant = _args[0] if _args.size() > 0 else null
	var ammo_type: Variant = _args[1] if _args.size() > 1 else null
	return {"source_owner": "PortGame.source_liquid_turret_build_peek_ammo_state", "inner_class": "public class LiquidTurretBuild extends TurretBuild{", "method": "public BulletType peekAmmo(){", "override_expr": "@Override", "return_expr": "return ammoTypes.get(liquids.current());", "current_liquid": current_liquid, "peek_ammo": ammo_type}

func java_inner_class_LiquidTurretBuild_method_hasAmmo_7(_args: Array = []) -> Variant:
	var current_liquid: Variant = _args[0] if _args.size() > 0 else null
	var ammo_type: Variant = _args[1] if _args.size() > 1 else null
	var current_amount: float = float(_args[2] if _args.size() > 2 else 0.0)
	var ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)
	var ammo_type_present: bool = ammo_type != null
	var required_amount: float = 1.0 / ammo_multiplier
	var has_ammo: bool = ammo_type_present and current_amount >= required_amount
	return {"source_owner": "PortGame.source_liquid_turret_build_has_ammo_state", "inner_class": "public class LiquidTurretBuild extends TurretBuild{", "method": "public boolean hasAmmo(){", "override_expr": "@Override", "return_expr": "return ammoTypes.get(liquids.current()) != null && liquids.currentAmount() >= 1f / ammoTypes.get(liquids.current()).ammoMultiplier;", "current_liquid": current_liquid, "ammo_type": ammo_type, "current_amount": current_amount, "ammo_multiplier": ammo_multiplier, "ammo_type_present": ammo_type_present, "required_amount": required_amount, "has_ammo": has_ammo}
