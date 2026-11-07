extends RefCounted
class_name SourceLiquidTurretInitState

const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_LIQUID_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_LIQUID_TURRET_GENERATED_CLASS
const SOURCE_LIQUID_TURRET_INIT_JAVA_METHOD := source_turret_source_text_state.SOURCE_LIQUID_TURRET_INIT_JAVA_METHOD
const SOURCE_LIQUID_TURRET_INIT_GENERATED_OWNER := source_turret_source_text_state.SOURCE_LIQUID_TURRET_INIT_GENERATED_OWNER

static func _liquid_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_LIQUID_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func init_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float) -> Dictionary:
	var current_place_overlap_range: float = place_overlap_range
	var consume_call: Dictionary = {
		"call": "consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){...});",
		"filter_expr": "i -> ammoTypes.containsKey(i)",
		"amount": 1.0,
		"update_override_noop": true,
		"display_override_noop": true,
	}
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
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_LIQUID_TURRET_INIT_STATE,
		"method": "public void init(){",
		"override_expr": "@Override",
		"consume_expr": "consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), 1f){",
		"filter_expr": "i -> ammoTypes.containsKey(i)",
		"consume_call": consume_call,
		"target_ground_expr": "if(targetGround){",
		"overlap_expr": "ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));",
		"super_init_expr": "super.init();",
		"ammo_entries": ammo_entries,
		"target_ground": target_ground,
		"place_overlap_range_before": place_overlap_range,
		"range_value": range_value,
		"place_overlap_margin": place_overlap_margin,
		"overlap_updates": overlap_updates,
		"place_overlap_range_after": current_place_overlap_range,
		"super_init_called": true,
	}

static func generated_init_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float) -> Dictionary:
	var result = _liquid_turret_call(SOURCE_LIQUID_TURRET_INIT_JAVA_METHOD, [ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin])
	var canonical = init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_LIQUID_TURRET_INIT_STATE,
		"generated_owner": SOURCE_LIQUID_TURRET_INIT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null)
			and result.get("overlap_updates", []) == canonical.get("overlap_updates", [])
			and result.get("consume_call", {}) == canonical.get("consume_call", {})
			and result.get("super_init_called", false) == canonical.get("super_init_called", false),
	}

static func generated_init_range_margin_default_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float) -> Dictionary:
	var result = _liquid_turret_call(SOURCE_LIQUID_TURRET_INIT_JAVA_METHOD, [ammo_entries, target_ground, place_overlap_range])
	var canonical = init_state(ammo_entries, target_ground, place_overlap_range, source_turret_defaults.RANGE_DEFAULT, source_turret_defaults.PLACE_OVERLAP_MARGIN_DEFAULT)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_LIQUID_TURRET_INIT_STATE,
		"generated_owner": SOURCE_LIQUID_TURRET_INIT_GENERATED_OWNER,
		"defaulted_args": ["range", "place_overlap_margin"],
		"range_value": source_turret_defaults.RANGE_DEFAULT,
		"place_overlap_margin": source_turret_defaults.PLACE_OVERLAP_MARGIN_DEFAULT,
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null)
			and result.get("overlap_updates", []) == canonical.get("overlap_updates", []),
	}
