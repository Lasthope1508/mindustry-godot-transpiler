extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileFlowState

const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_tractor_beam_turret_build_update_tile_coolant_state := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileCoolantState.gd")
const source_tractor_beam_turret_build_update_tile_any_reset_state := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileAnyResetState.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)


static func activation_state(activation_timer: float, time_delta: float) -> Dictionary:
	var activation_guard: bool = activation_timer > 0.0
	var activation_timer_after: float = activation_timer - time_delta if activation_guard else activation_timer
	var returned_early: bool = activation_guard
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ACTIVATION_STATE,
		"method": "public void updateTile(){",
		"activation_guard_expr": "if(activationTimer > 0){",
		"activation_decrement_expr": "activationTimer -= Time.delta;",
		"next_expr": "float eff = efficiency * coolantMultiplier, edelta = eff * delta();",
		"activation_timer": activation_timer,
		"time_delta": time_delta,
		"activation_guard": activation_guard,
		"activation_timer_after": activation_timer_after,
		"returned_early": returned_early,
	}


static func generated_activation_bridge_state(activation_timer: float, time_delta: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta])
	var activation_result := {
		"activation_timer_after": result.get("activation_timer_after", activation_timer),
		"returned_early": result.get("returned_early", false),
	}
	var canonical = activation_state(activation_timer, time_delta)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ACTIVATION_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.activation",
		"result": activation_result,
		"canonical": canonical,
		"matches": activation_result.get("activation_timer_after", null) == canonical.get("activation_timer_after", null) and activation_result.get("returned_early", null) == canonical.get("returned_early", null),
	}


static func eff_state(activation_returned_early: bool, efficiency: float, coolant_multiplier: float, delta_value: float) -> Dictionary:
	var eff_calculated: bool = not activation_returned_early
	var eff: float = efficiency * coolant_multiplier if eff_calculated else 0.0
	var edelta: float = eff * delta_value if eff_calculated else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_EFF_STATE,
		"method": "public void updateTile(){",
		"eff_expr": "float eff = efficiency * coolantMultiplier, edelta = eff * delta();",
		"retarget_comment_expr": "//retarget",
		"retarget_guard_expr": "if(timer(timerTarget, retargetTime)){",
		"activation_returned_early": activation_returned_early,
		"eff_calculated": eff_calculated,
		"efficiency": efficiency,
		"coolant_multiplier": coolant_multiplier,
		"delta_value": delta_value,
		"eff": eff,
		"edelta": edelta,
	}


static func generated_eff_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value])
	var eff_result := {
		"returned_early": result.get("returned_early", false),
		"eff_calculated": result.get("eff_calculated", false),
		"efficiency": result.get("efficiency", efficiency),
		"coolant_multiplier": result.get("coolant_multiplier", coolant_multiplier),
		"delta_value": result.get("delta_value", delta_value),
		"eff": result.get("eff", 0.0),
		"edelta": result.get("edelta", 0.0),
	}
	var canonical = eff_state(result.get("returned_early", false), efficiency, coolant_multiplier, delta_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_EFF_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.eff",
		"result": eff_result,
		"canonical": canonical,
		"matches": eff_result.get("eff", null) == canonical.get("eff", null) and eff_result.get("edelta", null) == canonical.get("edelta", null)
			and eff_result.get("eff_calculated", null) == canonical.get("eff_calculated", null)
			and eff_result.get("efficiency", null) == canonical.get("efficiency", null)
			and eff_result.get("coolant_multiplier", null) == canonical.get("coolant_multiplier", null)
			and eff_result.get("delta_value", null) == canonical.get("delta_value", null),
	}


static func retarget_state(activation_returned_early: bool, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	var retarget_evaluated: bool = not activation_returned_early
	var retarget_called: bool = retarget_evaluated and timer_target_ready
	var target_after: Variant = closest_enemy_result if retarget_called else existing_target
	var closest_enemy_call: Dictionary = {}
	if retarget_called:
		closest_enemy_call = {"call": "Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));", "team": team, "x": x, "y": y, "range": range_value, "target_air": target_air, "target_ground": target_ground, "result": closest_enemy_result}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_RETARGET_STATE,
		"method": "public void updateTile(){",
		"retarget_comment_expr": "//retarget",
		"retarget_guard_expr": "if(timer(timerTarget, retargetTime)){",
		"retarget_assign_expr": "target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));",
		"target_check_filter_expr": "u -> u.checkTarget(targetAir, targetGround)",
		"activation_returned_early": activation_returned_early,
		"timer_target_ready": timer_target_ready,
		"existing_target": existing_target,
		"closest_enemy_result": closest_enemy_result,
		"team": team,
		"x": x,
		"y": y,
		"range_value": range_value,
		"target_air": target_air,
		"target_ground": target_ground,
		"retarget_evaluated": retarget_evaluated,
		"retarget_called": retarget_called,
		"target_after": target_after,
		"closest_enemy_call": closest_enemy_call,
	}


static func generated_retarget_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground])
	var retarget_result := {
		"returned_early": result.get("returned_early", false),
		"retarget_called": result.get("retarget_called", false),
		"target_after": result.get("target_after", null),
		"closest_enemy_call": result.get("closest_enemy_call", {}),
	}
	var canonical = retarget_state(result.get("returned_early", false), timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_RETARGET_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.retarget",
		"result": retarget_result,
		"canonical": canonical,
		"matches": retarget_result.get("retarget_called", null) == canonical.get("retarget_called", null) and retarget_result.get("target_after", null) == canonical.get("target_after", null),
	}


static func coolant_guard_state(activation_returned_early: bool, target_after: Variant, coolant_present: bool, coolant_amount: float, current_liquid: Variant) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.coolant_guard_state(activation_returned_early, target_after, coolant_present, coolant_amount, current_liquid)


static func generated_coolant_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.generated_coolant_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid)


static func coolant_used_state(coolant_guard: bool, liquid_amount: float, max_used: float, time_delta: float, coolant_multiplier: float, liquid_heat_capacity: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.coolant_used_state(coolant_guard, liquid_amount, max_used, time_delta, coolant_multiplier, liquid_heat_capacity)


static func generated_coolant_used_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.generated_coolant_used_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)


static func coolant_remove_state(coolant_guard: bool, liquid: Variant, used: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.coolant_remove_state(coolant_guard, liquid, used)


static func generated_coolant_remove_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.generated_coolant_remove_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)


static func coolant_effect_state(coolant_guard: bool, used: float, chance_result: bool, x: float, y: float, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.coolant_effect_state(coolant_guard, used, chance_result, x, y, size, source_tilesize, range_x, range_y)


static func generated_coolant_effect_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.generated_coolant_effect_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)


static func coolant_multiplier_state(coolant_guard: bool, used: float, liquid_heat_capacity: float, coolant_multiplier: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.coolant_multiplier_state(coolant_guard, used, liquid_heat_capacity, coolant_multiplier)


static func generated_coolant_multiplier_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_coolant_state.generated_coolant_multiplier_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)


static func any_reset_state(activation_returned_early: bool, any_before: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_any_reset_state.any_reset_state(activation_returned_early, any_before)


static func generated_any_reset_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_any_reset_state.generated_any_reset_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before)
