extends RefCounted
class_name SourceContinuousLiquidTurretInitState

const SourceTurretDefaults := preload("res://src/game/SourceTurretDefaults.gd")
const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func init_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, liquid_consumed: float, current_liquid: Variant, current_ammo_multiplier: Variant) -> Dictionary:
	var current_place_overlap_range: float = place_overlap_range
	var multiplier_result: float = 1.0 if current_ammo_multiplier == null else 1.0 / float(current_ammo_multiplier)
	var consume_call: Dictionary = {
		"call": "consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){...});",
		"filter_expr": "i -> ammoTypes.containsKey(i)",
		"amount": liquid_consumed,
		"multiplier_expr": "multiplier = b -> {",
		"ammo_lookup_expr": "var ammo = ammoTypes.get(b.liquids.current());",
		"current_liquid": current_liquid,
		"current_ammo_multiplier": current_ammo_multiplier,
		"multiplier_return_expr": "return ammo == null ? 1f : 1f / ammo.ammoMultiplier;",
		"multiplier_result": multiplier_result,
		"display_override_noop": true,
	}
	var overlap_updates: Array = []
	if target_ground:
		for entry in ammo_entries:
			var entry_dict: Dictionary = entry if entry is Dictionary else {}
			var type_state: Variant = entry_dict.get("type", entry_dict.get("bullet", {}))
			var range_change: float = 0.0
			if type_state is Dictionary:
				range_change = float(type_state.get("rangeChange", 0.0))
			var before_range: float = current_place_overlap_range
			var candidate_range: float = range_value + range_change + place_overlap_margin
			current_place_overlap_range = max(current_place_overlap_range, candidate_range)
			overlap_updates.append({"liquid": entry_dict.get("liquid", entry_dict.get("item", null)), "type": type_state, "range_change": range_change, "candidate_range": candidate_range, "before": before_range, "after": current_place_overlap_range})
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_init_state",
		"method": "public void init(){",
		"override_expr": "@Override",
		"consume_expr": "consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){",
		"filter_expr": "i -> ammoTypes.containsKey(i)",
		"consume_call": consume_call,
		"multiplier_expr": "multiplier = b -> {",
		"ammo_lookup_expr": "var ammo = ammoTypes.get(b.liquids.current());",
		"multiplier_return_expr": "return ammo == null ? 1f : 1f / ammo.ammoMultiplier;",
		"multiplier_result": multiplier_result,
		"display_override_noop": true,
		"target_ground_expr": "if(targetGround){",
		"overlap_expr": "ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));",
		"super_init_expr": "super.init();",
		"ammo_entries": ammo_entries,
		"target_ground": target_ground,
		"place_overlap_range_before": place_overlap_range,
		"range_value": range_value,
		"place_overlap_margin": place_overlap_margin,
		"liquid_consumed": liquid_consumed,
		"current_liquid": current_liquid,
		"current_ammo_multiplier": current_ammo_multiplier,
		"overlap_updates": overlap_updates,
		"place_overlap_range_after": current_place_overlap_range,
		"super_init_called": true,
	}

static func generated_init_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, liquid_consumed: float, current_liquid: Variant, current_ammo_multiplier: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_method_init_2", [ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin, liquid_consumed, current_liquid, current_ammo_multiplier], null)
	var canonical = init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin, liquid_consumed, current_liquid, current_ammo_multiplier)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_init_state",
		"generated_owner": "ContinuousLiquidTurret.init",
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null)
			and result.get("multiplier_result", null) == canonical.get("multiplier_result", null)
			and result.get("consume_call", {}) == canonical.get("consume_call", {})
			and result.get("super_init_called", false) == canonical.get("super_init_called", false),
	}

static func generated_init_range_margin_default_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_method_init_2", [ammo_entries, target_ground, place_overlap_range], null)
	var canonical = init_state(ammo_entries, target_ground, place_overlap_range, SourceTurretDefaults.RANGE_DEFAULT, SourceTurretDefaults.PLACE_OVERLAP_MARGIN_DEFAULT, 0.0, null, null)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_init_state",
		"generated_owner": "ContinuousLiquidTurret.init",
		"defaulted_args": ["range", "place_overlap_margin"],
		"range_value": SourceTurretDefaults.RANGE_DEFAULT,
		"place_overlap_margin": SourceTurretDefaults.PLACE_OVERLAP_MARGIN_DEFAULT,
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null)
			and result.get("overlap_updates", []) == canonical.get("overlap_updates", []),
	}
