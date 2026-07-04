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
