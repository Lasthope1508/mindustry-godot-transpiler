extends RefCounted
class_name SourceItemTurretInitState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")


static func ground_overlap_state(target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, ammo_entries: Array) -> Dictionary:
	var place_overlap_range_after: float = place_overlap_range
	var place_overlap_updates: Array = []
	if target_ground:
		for entry in ammo_entries:
			var entry_value: Variant = entry.get("value", entry) if entry is Dictionary else entry
			var range_change: float = float(entry_value.get("range_change", entry_value.get("rangeChange", 0.0)) if entry_value is Dictionary else 0.0)
			var candidate_range: float = range_value + range_change + place_overlap_margin
			place_overlap_range_after = maxf(place_overlap_range_after, candidate_range)
			place_overlap_updates.append({"call": "placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin)", "range_change": range_change, "candidate_range": candidate_range, "place_overlap_range_after": place_overlap_range_after})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_INIT_GROUND_OVERLAP_STATE,
		"method": "public void init(){",
		"override_expr": "@Override",
		"consume_expr": "consume(new ConsumeItemFilter(i -> ammoTypes.containsKey(i)))",
		"consume_filter_deferred": true,
		"target_ground_guard_expr": "if(targetGround){",
		"overlap_expr": "placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin)",
		"super_init_expr": "super.init();",
		"target_ground": target_ground,
		"place_overlap_range": place_overlap_range,
		"range_value": range_value,
		"place_overlap_margin": place_overlap_margin,
		"ammo_entries": ammo_entries,
		"place_overlap_range_after": place_overlap_range_after,
		"place_overlap_updates": place_overlap_updates,
		"place_overlap_update_count": place_overlap_updates.size(),
		"super_init_called": true,
	}


static func generated_item_turret_init_ground_overlap_bridge_state(target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, ammo_entries: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_method_init_5", [target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries], null)
	var canonical = ground_overlap_state(target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_INIT_GROUND_OVERLAP_STATE,
		"generated_owner": "item_turret.java_method_init_5",
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null) and result.get("place_overlap_updates", null) == canonical.get("place_overlap_updates", null),
	}


static func generated_item_turret_init_ground_overlap_default_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_method_init_5", [], null)
	var canonical = ground_overlap_state(source_turret_defaults.TARGET_GROUND_DEFAULT, 0.0, source_turret_defaults.RANGE_DEFAULT, source_turret_defaults.PLACE_OVERLAP_MARGIN_DEFAULT, [])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_INIT_GROUND_OVERLAP_STATE,
		"generated_owner": "item_turret.java_method_init_5",
		"defaulted_args": ["target_ground", "range", "place_overlap_margin"],
		"target_ground": result.get("target_ground", null),
		"range_value": result.get("range_value", null),
		"place_overlap_margin": result.get("place_overlap_margin", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null)
			and result.get("target_ground", null) == canonical.get("target_ground", null)
			and result.get("range_value", null) == canonical.get("range_value", null)
			and result.get("place_overlap_margin", null) == canonical.get("place_overlap_margin", null),
	}
