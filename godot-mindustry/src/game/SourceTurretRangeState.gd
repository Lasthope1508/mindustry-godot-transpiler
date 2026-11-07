extends RefCounted
class_name SourceTurretRangeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TURRET_GENERATED_CLASS
const SOURCE_POWER_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_POWER_TURRET_GENERATED_CLASS
const SOURCE_ITEM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_GENERATED_CLASS
const SOURCE_TURRET_LIMIT_RANGE_BULLET_METHOD := source_turret_source_text_state.SOURCE_TURRET_LIMIT_RANGE_BULLET_METHOD
const SOURCE_TURRET_LIMIT_RANGE_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_LIMIT_RANGE_JAVA_METHOD
const SOURCE_TURRET_LIMIT_RANGE_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_LIMIT_RANGE_GENERATED_OWNER
const SOURCE_TURRET_LIMIT_RANGE_REAL_RANGE_EXPR := source_turret_source_text_state.SOURCE_TURRET_LIMIT_RANGE_REAL_RANGE_EXPR
const SOURCE_TURRET_LIMIT_RANGE_DRAG_COMMENT := source_turret_source_text_state.SOURCE_TURRET_LIMIT_RANGE_DRAG_COMMENT
const SOURCE_TURRET_LIMIT_RANGE_LIFETIME_EXPR := source_turret_source_text_state.SOURCE_TURRET_LIMIT_RANGE_LIFETIME_EXPR
const SOURCE_TURRET_LIMIT_RANGE_MARGIN_METHOD := source_turret_source_text_state.SOURCE_TURRET_LIMIT_RANGE_MARGIN_METHOD
const SOURCE_POWER_TURRET_LIMIT_RANGE_JAVA_METHOD := source_turret_source_text_state.SOURCE_POWER_TURRET_LIMIT_RANGE_JAVA_METHOD
const SOURCE_POWER_TURRET_LIMIT_RANGE_GENERATED_OWNER := source_turret_source_text_state.SOURCE_POWER_TURRET_LIMIT_RANGE_GENERATED_OWNER
const SOURCE_POWER_TURRET_LIMIT_RANGE_DISPATCH_EXPR := source_turret_source_text_state.SOURCE_POWER_TURRET_LIMIT_RANGE_DISPATCH_EXPR
const SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_METHOD
const SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_JAVA_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_JAVA_METHOD
const SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_GENERATED_OWNER := source_turret_source_text_state.SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_GENERATED_OWNER
const SOURCE_ITEM_TURRET_LIMIT_RANGE_COMMENT := source_turret_source_text_state.SOURCE_ITEM_TURRET_LIMIT_RANGE_COMMENT
const SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_DISPATCH_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_DISPATCH_EXPR
const SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_JAVA_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_JAVA_METHOD
const SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_GENERATED_OWNER := source_turret_source_text_state.SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_GENERATED_OWNER
const SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_LOOP_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_LOOP_EXPR
const SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_DISPATCH_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_DISPATCH_EXPR

static func _turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _power_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_POWER_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _item_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_ITEM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func limit_range_state(bullet: Dictionary, margin: float, turret_range: float, bullet_range_change: float, bullet_extra_range_margin: float, bullet_speed: float) -> Dictionary:
	var real_range: float = bullet_range_change + turret_range
	var bullet_lifetime: float = (real_range + margin + bullet_extra_range_margin + 10.0) / bullet_speed
	bullet["lifetime"] = bullet_lifetime
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_LIMIT_RANGE_STATE,
		"method": SOURCE_TURRET_LIMIT_RANGE_BULLET_METHOD,
		"real_range_expr": SOURCE_TURRET_LIMIT_RANGE_REAL_RANGE_EXPR,
		"drag_comment": SOURCE_TURRET_LIMIT_RANGE_DRAG_COMMENT,
		"lifetime_expr": SOURCE_TURRET_LIMIT_RANGE_LIFETIME_EXPR,
		"bullet": bullet,
		"margin": margin,
		"turret_range": turret_range,
		"bullet_range_change": bullet_range_change,
		"real_range": real_range,
		"bullet_extra_range_margin": bullet_extra_range_margin,
		"bullet_speed": bullet_speed,
		"bullet_lifetime": bullet_lifetime,
		"updated_bullet": bullet,
	}

static func game_limit_range_state(game: Object, bullet: Dictionary, margin: float, turret_range: float) -> Dictionary:
	var bullet_range_change: float = float(game.call("source_bullet_range_change", bullet))
	var bullet_extra_range_margin: float = float(game.call("source_bullet_extra_range_margin", bullet))
	var bullet_speed: float = float(game.call("source_bullet_world_speed_per_tick", bullet))
	return limit_range_state(bullet, margin, turret_range, bullet_range_change, bullet_extra_range_margin, bullet_speed)


static func generated_limit_range_bridge_state(bullet: Dictionary, margin: float, turret_range: float, bullet_range_change: float, bullet_extra_range_margin: float, bullet_speed: float) -> Dictionary:
	var generated_bullet := bullet.duplicate(true)
	var canonical_bullet := bullet.duplicate(true)
	canonical_bullet["rangeChange"] = bullet_range_change
	canonical_bullet["extraRangeMargin"] = bullet_extra_range_margin
	canonical_bullet["speed"] = bullet_speed
	var result = _turret_call(SOURCE_TURRET_LIMIT_RANGE_JAVA_METHOD, [generated_bullet, margin, turret_range])
	var canonical = limit_range_state(canonical_bullet, margin, turret_range, bullet_range_change, bullet_extra_range_margin, bullet_speed)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_LIMIT_RANGE_STATE,
		"generated_owner": SOURCE_TURRET_LIMIT_RANGE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("bullet_lifetime", null) == canonical.get("bullet_lifetime", null) and result.get("updated_bullet", null) == canonical.get("updated_bullet", null),
	}

static func game_generated_limit_range_bridge_state(game: Object, bullet: Dictionary, margin: float, turret_range: float) -> Dictionary:
	var canonical_bullet := bullet.duplicate(true)
	var bullet_range_change: float = float(game.call("source_bullet_range_change", canonical_bullet))
	var bullet_extra_range_margin: float = float(game.call("source_bullet_extra_range_margin", canonical_bullet))
	var bullet_speed: float = float(game.call("source_bullet_world_speed_per_tick", canonical_bullet))
	return generated_limit_range_bridge_state(bullet, margin, turret_range, bullet_range_change, bullet_extra_range_margin, bullet_speed)


static func power_turret_limit_range_state(shoot_type: Variant, margin: float) -> Dictionary:
	var limit_range_call: Dictionary = {"call": SOURCE_POWER_TURRET_LIMIT_RANGE_DISPATCH_EXPR, "shoot_type": shoot_type, "margin": margin}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_LIMIT_RANGE_STATE,
		"method": SOURCE_TURRET_LIMIT_RANGE_MARGIN_METHOD,
		"dispatch_expr": SOURCE_POWER_TURRET_LIMIT_RANGE_DISPATCH_EXPR,
		"shoot_type": shoot_type,
		"margin": margin,
		"limit_range_called": true,
		"limit_range_call": limit_range_call,
	}


static func generated_power_turret_limit_range_bridge_state(shoot_type: Variant, margin: float) -> Dictionary:
	var result = _power_turret_call(SOURCE_POWER_TURRET_LIMIT_RANGE_JAVA_METHOD, [shoot_type, margin])
	var canonical = power_turret_limit_range_state(shoot_type, margin)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_LIMIT_RANGE_STATE,
		"generated_owner": SOURCE_POWER_TURRET_LIMIT_RANGE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("limit_range_call", null) == canonical.get("limit_range_call", null) and result.get("margin", null) == canonical.get("margin", null),
	}


static func item_turret_limit_range_default_state() -> Dictionary:
	var margin: float = 9.0
	var limit_range_call: Dictionary = {"call": SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_DISPATCH_EXPR, "margin": margin}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_STATE,
		"method": SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_METHOD,
		"comment": SOURCE_ITEM_TURRET_LIMIT_RANGE_COMMENT,
		"dispatch_expr": SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_DISPATCH_EXPR,
		"margin": margin,
		"limit_range_called": true,
		"limit_range_call": limit_range_call,
	}


static func generated_item_turret_limit_range_default_bridge_state() -> Dictionary:
	var result = _item_turret_call(SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_JAVA_METHOD, [])
	var canonical = item_turret_limit_range_default_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_STATE,
		"generated_owner": SOURCE_ITEM_TURRET_LIMIT_RANGE_DEFAULT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("margin", null) == canonical.get("margin", null) and result.get("limit_range_called", null) == canonical.get("limit_range_called", null),
	}


static func item_turret_limit_range_entries_state(margin: float, ammo_entries: Array) -> Dictionary:
	var limit_range_calls: Array = []
	for entry in ammo_entries:
		var entry_value: Variant = entry.get("value", null) if entry is Dictionary else entry
		limit_range_calls.append({"call": SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_DISPATCH_EXPR, "entry_value": entry_value, "margin": margin})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_STATE,
		"method": SOURCE_TURRET_LIMIT_RANGE_MARGIN_METHOD,
		"comment": SOURCE_ITEM_TURRET_LIMIT_RANGE_COMMENT,
		"loop_expr": SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_LOOP_EXPR,
		"dispatch_expr": SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_DISPATCH_EXPR,
		"margin": margin,
		"ammo_entries": ammo_entries,
		"limit_range_calls": limit_range_calls,
		"limit_range_call_count": limit_range_calls.size(),
	}


static func generated_item_turret_limit_range_entries_bridge_state(margin: float, ammo_entries: Array) -> Dictionary:
	var result = _item_turret_call(SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_JAVA_METHOD, [margin, ammo_entries])
	var canonical = item_turret_limit_range_entries_state(margin, ammo_entries)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_STATE,
		"generated_owner": SOURCE_ITEM_TURRET_LIMIT_RANGE_ENTRIES_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("limit_range_calls", null) == canonical.get("limit_range_calls", null) and result.get("limit_range_call_count", null) == canonical.get("limit_range_call_count", null) and result.get("margin", null) == canonical.get("margin", null),
	}
