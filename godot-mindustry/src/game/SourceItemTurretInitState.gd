extends RefCounted
class_name SourceItemTurretInitState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_ITEM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_GENERATED_CLASS
const SOURCE_ITEM_TURRET_INIT_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_INIT_METHOD
const SOURCE_ITEM_TURRET_INIT_JAVA_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_INIT_JAVA_METHOD
const SOURCE_ITEM_TURRET_INIT_GENERATED_OWNER := source_turret_source_text_state.SOURCE_ITEM_TURRET_INIT_GENERATED_OWNER
const SOURCE_ITEM_TURRET_INIT_OVERRIDE_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_INIT_OVERRIDE_EXPR
const SOURCE_ITEM_TURRET_INIT_CONSUME_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_INIT_CONSUME_EXPR
const SOURCE_ITEM_TURRET_INIT_TARGET_GROUND_GUARD_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_INIT_TARGET_GROUND_GUARD_EXPR
const SOURCE_ITEM_TURRET_INIT_OVERLAP_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_INIT_OVERLAP_EXPR
const SOURCE_ITEM_TURRET_INIT_SUPER_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_INIT_SUPER_EXPR

static func _item_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_ITEM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func ground_overlap_state(target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, ammo_entries: Array) -> Dictionary:
	var place_overlap_range_after: float = place_overlap_range
	var place_overlap_updates: Array = []
	if target_ground:
		for entry in ammo_entries:
			var entry_value: Variant = entry.get("value", entry) if entry is Dictionary else entry
			var range_change: float = float(entry_value.get("range_change", entry_value.get("rangeChange", 0.0)) if entry_value is Dictionary else 0.0)
			var candidate_range: float = range_value + range_change + place_overlap_margin
			place_overlap_range_after = maxf(place_overlap_range_after, candidate_range)
			place_overlap_updates.append({"call": SOURCE_ITEM_TURRET_INIT_OVERLAP_EXPR, "range_change": range_change, "candidate_range": candidate_range, "place_overlap_range_after": place_overlap_range_after})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_INIT_GROUND_OVERLAP_STATE,
		"method": SOURCE_ITEM_TURRET_INIT_METHOD,
		"override_expr": SOURCE_ITEM_TURRET_INIT_OVERRIDE_EXPR,
		"consume_expr": SOURCE_ITEM_TURRET_INIT_CONSUME_EXPR,
		"consume_filter_deferred": true,
		"target_ground_guard_expr": SOURCE_ITEM_TURRET_INIT_TARGET_GROUND_GUARD_EXPR,
		"overlap_expr": SOURCE_ITEM_TURRET_INIT_OVERLAP_EXPR,
		"super_init_expr": SOURCE_ITEM_TURRET_INIT_SUPER_EXPR,
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
	var result = _item_turret_call(SOURCE_ITEM_TURRET_INIT_JAVA_METHOD, [target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries])
	var canonical = ground_overlap_state(target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_INIT_GROUND_OVERLAP_STATE,
		"generated_owner": SOURCE_ITEM_TURRET_INIT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null) and result.get("place_overlap_updates", null) == canonical.get("place_overlap_updates", null),
	}


static func generated_item_turret_init_ground_overlap_default_bridge_state() -> Dictionary:
	var result = _item_turret_call(SOURCE_ITEM_TURRET_INIT_JAVA_METHOD, [])
	var canonical = ground_overlap_state(source_turret_defaults.TARGET_GROUND_DEFAULT, 0.0, source_turret_defaults.RANGE_DEFAULT, source_turret_defaults.PLACE_OVERLAP_MARGIN_DEFAULT, [])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_INIT_GROUND_OVERLAP_STATE,
		"generated_owner": SOURCE_ITEM_TURRET_INIT_GENERATED_OWNER,
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
