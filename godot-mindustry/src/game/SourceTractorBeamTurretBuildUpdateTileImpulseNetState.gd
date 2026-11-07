extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileImpulseNetState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)


static func impulse_net_state(shoot_within_guard: bool, target_after: Variant, x: float, y: float, range_value: float, edelta: float, force_value: float, scaled_force: float) -> Dictionary:
	var target_x_for_impulse: float = x
	var target_y_for_impulse: float = y
	if target_after is Dictionary:
		target_x_for_impulse = float(target_after.get("x", x))
		target_y_for_impulse = float(target_after.get("y", y))
	var impulse_vector_x: float = x - target_x_for_impulse
	var impulse_vector_y: float = y - target_y_for_impulse
	var target_dst_to_building: float = sqrt(pow(target_x_for_impulse - x, 2) + pow(target_y_for_impulse - y, 2))
	var impulse_limit: float = (force_value + (1.0 - target_dst_to_building / range_value) * scaled_force) * edelta
	var impulse_net_called: bool = shoot_within_guard
	if impulse_net_called:
		var impulse_len2: float = impulse_vector_x * impulse_vector_x + impulse_vector_y * impulse_vector_y
		var impulse_limit2: float = impulse_limit * impulse_limit
		if impulse_len2 > impulse_limit2:
			var impulse_scale: float = sqrt(impulse_limit2 / impulse_len2)
			impulse_vector_x *= impulse_scale
			impulse_vector_y *= impulse_scale
	var impulse_net_call: Dictionary = {}
	if impulse_net_called:
		impulse_net_call = {"call": "target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));", "target": target_after, "x": impulse_vector_x, "y": impulse_vector_y, "limit": impulse_limit, "target_dst_to_building": target_dst_to_building, "force": force_value, "scaled_force": scaled_force}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_IMPULSE_NET_STATE,
		"method": "public void updateTile(){",
		"force_expr": "public float force = 0.3f;",
		"scaled_force_expr": "public float scaledForce = 0f;",
		"impulse_net_expr": "target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));",
		"shoot_within_guard": shoot_within_guard,
		"target_after": target_after,
		"x": x,
		"y": y,
		"range_value": range_value,
		"edelta": edelta,
		"force_value": force_value,
		"scaled_force": scaled_force,
		"target_dst_to_building": target_dst_to_building,
		"impulse_limit": impulse_limit,
		"impulse_net_called": impulse_net_called,
		"impulse_net_call": impulse_net_call,
	}


static func generated_impulse_net_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float, status: Variant, status_duration: float, force_value: float, scaled_force: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage, status, status_duration, force_value, scaled_force])
	var impulse_net_result := {
		"shoot_within_guard": result.get("shoot_within_guard", false),
		"target_after": result.get("target_after", null),
		"x": result.get("x", 0.0),
		"y": result.get("y", 0.0),
		"range_value": result.get("range_value", 0.0),
		"edelta": result.get("edelta", 0.0),
		"impulse_net_called": result.get("impulse_net_called", false),
		"impulse_net_call": result.get("impulse_net_call", {}) if result.get("impulse_net_called", false) else {},
	}
	var canonical = impulse_net_state(result.get("shoot_within_guard", false), result.get("target_after", null), result.get("x", 0.0), result.get("y", 0.0), result.get("range_value", 0.0), result.get("edelta", 0.0), force_value, scaled_force)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_IMPULSE_NET_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.impulse_net",
		"result": impulse_net_result,
		"canonical": canonical,
		"matches": impulse_net_result.get("impulse_net_call", null) == canonical.get("impulse_net_call", null),
	}
