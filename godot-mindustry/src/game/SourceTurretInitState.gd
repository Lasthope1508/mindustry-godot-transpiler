extends RefCounted
class_name SourceTurretInitState

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const SOURCE_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TURRET_GENERATED_CLASS
const SOURCE_BASE_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_BASE_TURRET_GENERATED_CLASS
const SOURCE_TURRET_INIT_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_INIT_JAVA_METHOD
const SOURCE_TURRET_INIT_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_INIT_GENERATED_OWNER
const SOURCE_BASE_TURRET_INIT_JAVA_METHOD := source_turret_source_text_state.SOURCE_BASE_TURRET_INIT_JAVA_METHOD
const SOURCE_BASE_TURRET_INIT_GENERATED_OWNER := source_turret_source_text_state.SOURCE_BASE_TURRET_INIT_GENERATED_OWNER
const SOURCE_BASE_TURRET_REINITIALIZE_CONSUMERS_JAVA_METHOD := source_turret_source_text_state.SOURCE_BASE_TURRET_REINITIALIZE_CONSUMERS_JAVA_METHOD
const SOURCE_BASE_TURRET_REINITIALIZE_CONSUMERS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_BASE_TURRET_REINITIALIZE_CONSUMERS_GENERATED_OWNER
const SOURCE_BASE_TURRET_CHECK_INIT_COOLANT_JAVA_METHOD := source_turret_source_text_state.SOURCE_BASE_TURRET_CHECK_INIT_COOLANT_JAVA_METHOD
const SOURCE_BASE_TURRET_CHECK_INIT_COOLANT_GENERATED_OWNER := source_turret_source_text_state.SOURCE_BASE_TURRET_CHECK_INIT_COOLANT_GENERATED_OWNER
const SOURCE_TURRET_SHOOT_Y_INIT_DEFAULT := source_turret_source_text_state.SOURCE_TURRET_SHOOT_Y_INIT_DEFAULT

static func _turret_init_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _base_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BASE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func turret_init_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float, tracking_range: float) -> Dictionary:
	var shoot_y_after: float = size * source_tilesize / 2.0 if shoot_y_is_negative_infinity else shoot_y
	var elevation_after: float = size / 2.0 if elevation < 0.0 else elevation
	var recoil_time_after: float = reload if recoil_time < 0.0 else recoil_time
	var cooldown_time_after: float = reload if cooldown_time < 0.0 else cooldown_time
	var new_target_interval_after: float = target_interval if new_target_interval <= 0.0 else new_target_interval
	var disable_overlap_check_after: bool = true if not target_ground else disable_overlap_check
	var tracking_range_after: float = max(range_value, tracking_range)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_INIT_STATE,
		"method": "public void init(){",
		"override_expr": "@Override",
		"shoot_y_guard_expr": SOURCE_TURRET_SHOOT_Y_INIT_DEFAULT,
		"shoot_y_expr": "shootY = size * tilesize / 2f",
		"elevation_guard_expr": "if(elevation < 0) elevation = size / 2f;",
		"elevation_expr": "elevation = size / 2f",
		"recoil_time_guard_expr": "if(recoilTime < 0f) recoilTime = reload;",
		"recoil_time_expr": "recoilTime = reload",
		"cooldown_time_guard_expr": "if(cooldownTime < 0f) cooldownTime = reload;",
		"cooldown_time_expr": "cooldownTime = reload",
		"new_target_interval_guard_expr": "if(newTargetInterval <= 0f) newTargetInterval = targetInterval;",
		"new_target_interval_expr": "newTargetInterval = targetInterval",
		"target_ground_guard_expr": "if(!targetGround){",
		"disable_overlap_check_expr": "disableOverlapCheck = true;",
		"super_init_expr": "super.init();",
		"tracking_range_expr": "trackingRange = Math.max(range, trackingRange);",
		"shoot_y": shoot_y,
		"shoot_y_is_negative_infinity": shoot_y_is_negative_infinity,
		"size": size,
		"source_tilesize": source_tilesize,
		"elevation": elevation,
		"recoil_time": recoil_time,
		"reload": reload,
		"cooldown_time": cooldown_time,
		"new_target_interval": new_target_interval,
		"target_interval": target_interval,
		"target_ground": target_ground,
		"disable_overlap_check": disable_overlap_check,
		"range": range_value,
		"tracking_range": tracking_range,
		"shoot_y_after": shoot_y_after,
		"elevation_after": elevation_after,
		"recoil_time_after": recoil_time_after,
		"cooldown_time_after": cooldown_time_after,
		"new_target_interval_after": new_target_interval_after,
		"disable_overlap_check_after": disable_overlap_check_after,
		"tracking_range_after": tracking_range_after,
	}

static func base_turret_init_state(coolant_present: bool, found_consume_coolant: bool, disable_overlap_check: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, source_tilesize: float, fog_radius_multiplier: float, fog_radius: int) -> Dictionary:
	@warning_ignore("unused_variable")
	var find_consumer_called: bool = not coolant_present
	@warning_ignore("unused_variable")
	var coolant_present_after: bool = coolant_present or found_consume_coolant
	var place_overlap_range_after: float = place_overlap_range
	if not disable_overlap_check:
		place_overlap_range_after = max(place_overlap_range, range_value + place_overlap_margin)
	var computed_fog_radius: int = int(round(range_value / source_tilesize * fog_radius_multiplier))
	var fog_radius_after: int = max(computed_fog_radius, fog_radius)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_INIT_STATE,
		"method": "public void init(){",
		"override_expr": "@Override",
		"coolant_null_guard_expr": "if(coolant == null){",
		"find_consumer_expr": "coolant = findConsumer(c -> c instanceof ConsumeCoolant);",
		"check_init_coolant_expr": "checkInitCoolant();",
		"overlap_guard_expr": "if(!disableOverlapCheck){",
		"place_overlap_range_expr": "placeOverlapRange = Math.max(placeOverlapRange, range + placeOverlapMargin);",
		"fog_radius_expr": "fogRadius = Math.max(Mathf.round(range / tilesize * fogRadiusMultiplier), fogRadius);",
		"super_init_expr": "super.init();",
		"coolant_present": coolant_present,
		"found_consume_coolant": found_consume_coolant,
		"find_consumer_called": not coolant_present,
		"coolant_present_after": coolant_present or found_consume_coolant,
		"check_init_coolant_called": true,
		"disable_overlap_check": disable_overlap_check,
		"place_overlap_range": place_overlap_range,
		"range": range_value,
		"place_overlap_margin": place_overlap_margin,
		"place_overlap_range_after": place_overlap_range_after,
		"tilesize": source_tilesize,
		"fog_radius_multiplier": fog_radius_multiplier,
		"fog_radius": fog_radius,
		"computed_fog_radius": computed_fog_radius,
		"fog_radius_after": fog_radius_after,
		"super_init_called": true,
	}

static func base_turret_reinitialize_consumers_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_REINITIALIZE_CONSUMERS_STATE,
		"method": "public void reinitializeConsumers(){",
		"override_expr": "@Override",
		"check_init_coolant_expr": "checkInitCoolant();",
		"super_reinitialize_consumers_expr": "super.reinitializeConsumers();",
		"check_init_coolant_called": true,
		"super_reinitialize_consumers_called": true,
	}

static func base_turret_check_init_coolant_state(coolant_present: bool, has_consumer: bool) -> Dictionary:
	var update_after: Variant = null
	var booster_after: Variant = null
	var optional_after: Variant = null
	if coolant_present:
		update_after = false
		booster_after = true
		optional_after = true
	@warning_ignore("unused_variable")
	var consume_called: bool = coolant_present and not has_consumer
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_CHECK_INIT_COOLANT_STATE,
		"method": "void checkInitCoolant(){",
		"coolant_guard_expr": "if(coolant != null){",
		"update_assign_expr": "coolant.update = false;",
		"booster_assign_expr": "coolant.booster = true;",
		"optional_assign_expr": "coolant.optional = true;",
		"json_comment": "//json parsing does not add to consumes",
		"consume_guard_expr": "if(!hasConsumer(coolant)) consume(coolant);",
		"coolant_present": coolant_present,
		"has_consumer": has_consumer,
		"update_after": update_after,
		"booster_after": booster_after,
		"optional_after": optional_after,
		"consume_called": coolant_present and not has_consumer,
	}

static func generated_turret_init_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float, tracking_range: float) -> Dictionary:
	var result = _turret_init_call(SOURCE_TURRET_INIT_JAVA_METHOD, [shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range])
	var canonical = turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_INIT_STATE,
		"generated_owner": SOURCE_TURRET_INIT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null) and result.get("elevation_after", null) == canonical.get("elevation_after", null) and result.get("tracking_range_after", null) == canonical.get("tracking_range_after", null) and result.get("disable_overlap_check_after", null) == canonical.get("disable_overlap_check_after", null),
	}

static func generated_turret_init_source_tilesize_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float) -> Dictionary:
	var result = _turret_init_call(SOURCE_TURRET_INIT_JAVA_METHOD, [shoot_y, shoot_y_is_negative_infinity, size])
	var canonical = turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_world_defaults.TILESIZE, source_turret_defaults.ELEVATION_DEFAULT, source_turret_defaults.RECOIL_TIME_DEFAULT, source_turret_defaults.RELOAD_DEFAULT, source_turret_defaults.COOLDOWN_TIME_DEFAULT, source_turret_defaults.NEW_TARGET_INTERVAL_DEFAULT, source_turret_defaults.TARGET_INTERVAL_DEFAULT, source_turret_defaults.TARGET_GROUND_DEFAULT, source_turret_defaults.DISABLE_OVERLAP_CHECK_DEFAULT, 0.0, 0.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_INIT_STATE,
		"generated_owner": SOURCE_TURRET_INIT_GENERATED_OWNER,
		"defaulted_arg": "source_tilesize",
		"source_tilesize": result.get("source_tilesize", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("source_tilesize", null) == canonical.get("source_tilesize", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null) and result.get("elevation_after", null) == canonical.get("elevation_after", null),
	}

static func generated_turret_init_size_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool) -> Dictionary:
	var result = _turret_init_call(SOURCE_TURRET_INIT_JAVA_METHOD, [shoot_y, shoot_y_is_negative_infinity])
	var canonical = turret_init_state(shoot_y, shoot_y_is_negative_infinity, source_block_defaults.SIZE_DEFAULT, source_world_defaults.TILESIZE, source_turret_defaults.ELEVATION_DEFAULT, source_turret_defaults.RECOIL_TIME_DEFAULT, source_turret_defaults.RELOAD_DEFAULT, source_turret_defaults.COOLDOWN_TIME_DEFAULT, source_turret_defaults.NEW_TARGET_INTERVAL_DEFAULT, source_turret_defaults.TARGET_INTERVAL_DEFAULT, source_turret_defaults.TARGET_GROUND_DEFAULT, source_turret_defaults.DISABLE_OVERLAP_CHECK_DEFAULT, 0.0, 0.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_INIT_STATE,
		"generated_owner": SOURCE_TURRET_INIT_GENERATED_OWNER,
		"defaulted_arg": "size",
		"size": result.get("size", null),
		"source_tilesize": result.get("source_tilesize", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("size", null) == canonical.get("size", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null) and result.get("elevation_after", null) == canonical.get("elevation_after", null),
	}

static func generated_turret_init_disable_overlap_check_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool) -> Dictionary:
	var result = _turret_init_call(SOURCE_TURRET_INIT_JAVA_METHOD, [shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground])
	var canonical = turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, source_turret_defaults.DISABLE_OVERLAP_CHECK_DEFAULT, 0.0, 0.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_INIT_STATE,
		"generated_owner": SOURCE_TURRET_INIT_GENERATED_OWNER,
		"defaulted_arg": "disable_overlap_check",
		"disable_overlap_check": result.get("disable_overlap_check", null),
		"disable_overlap_check_after": result.get("disable_overlap_check_after", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("disable_overlap_check", null) == canonical.get("disable_overlap_check", null) and result.get("disable_overlap_check_after", null) == canonical.get("disable_overlap_check_after", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null),
	}

static func generated_turret_init_range_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool) -> Dictionary:
	var result = _turret_init_call(SOURCE_TURRET_INIT_JAVA_METHOD, [shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check])
	var canonical = turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, source_turret_defaults.RANGE_DEFAULT, 0.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_INIT_STATE,
		"generated_owner": SOURCE_TURRET_INIT_GENERATED_OWNER,
		"defaulted_arg": "range",
		"range": result.get("range", null),
		"tracking_range_after": result.get("tracking_range_after", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("range", null) == canonical.get("range", null) and result.get("tracking_range_after", null) == canonical.get("tracking_range_after", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null),
	}

static func generated_turret_init_tracking_range_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float) -> Dictionary:
	var result = _turret_init_call(SOURCE_TURRET_INIT_JAVA_METHOD, [shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value])
	var canonical = turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, source_turret_defaults.TRACKING_RANGE_DEFAULT)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_INIT_STATE,
		"generated_owner": SOURCE_TURRET_INIT_GENERATED_OWNER,
		"defaulted_arg": "tracking_range",
		"tracking_range": result.get("tracking_range", null),
		"tracking_range_after": result.get("tracking_range_after", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("tracking_range", null) == canonical.get("tracking_range", null) and result.get("tracking_range_after", null) == canonical.get("tracking_range_after", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null),
	}

static func generated_base_turret_init_bridge_state(coolant_present: bool, found_consume_coolant: bool, disable_overlap_check: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, source_tilesize: float, fog_radius_multiplier: float, fog_radius: int) -> Dictionary:
	var result = _base_turret_call(SOURCE_BASE_TURRET_INIT_JAVA_METHOD, [coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius])
	var canonical = base_turret_init_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_INIT_STATE,
		"generated_owner": SOURCE_BASE_TURRET_INIT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("coolant_present_after", null) == canonical.get("coolant_present_after", null) and result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null) and result.get("fog_radius_after", null) == canonical.get("fog_radius_after", null),
	}

static func generated_base_turret_reinitialize_consumers_bridge_state() -> Dictionary:
	var result = _base_turret_call(SOURCE_BASE_TURRET_REINITIALIZE_CONSUMERS_JAVA_METHOD, [])
	var canonical = base_turret_reinitialize_consumers_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_REINITIALIZE_CONSUMERS_STATE,
		"generated_owner": SOURCE_BASE_TURRET_REINITIALIZE_CONSUMERS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("check_init_coolant_called", null) == canonical.get("check_init_coolant_called", null) and result.get("super_reinitialize_consumers_called", null) == canonical.get("super_reinitialize_consumers_called", null),
	}

static func generated_base_turret_check_init_coolant_bridge_state(coolant_present: bool, has_consumer: bool) -> Dictionary:
	var result = _base_turret_call(SOURCE_BASE_TURRET_CHECK_INIT_COOLANT_JAVA_METHOD, [coolant_present, has_consumer])
	var canonical = base_turret_check_init_coolant_state(coolant_present, has_consumer)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BASE_TURRET_CHECK_INIT_COOLANT_STATE,
		"generated_owner": SOURCE_BASE_TURRET_CHECK_INIT_COOLANT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("consume_called", null) == canonical.get("consume_called", null) and result.get("update_after", null) == canonical.get("update_after", null) and result.get("booster_after", null) == canonical.get("booster_after", null) and result.get("optional_after", null) == canonical.get("optional_after", null),
	}
