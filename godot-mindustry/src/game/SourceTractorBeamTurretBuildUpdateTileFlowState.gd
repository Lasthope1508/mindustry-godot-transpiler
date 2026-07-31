extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileFlowState

const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd"

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
	var coolant_evaluated: bool = not activation_returned_early
	var coolant_guard: bool = coolant_evaluated and target_after != null and coolant_present
	var max_used: float = coolant_amount if coolant_guard else 0.0
	var liquid: Variant = current_liquid if coolant_guard else null
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_GUARD_STATE,
		"method": "public void updateTile(){",
		"coolant_comment_expr": "//consume coolant",
		"coolant_guard_expr": "if(target != null && coolant != null){",
		"max_used_expr": "float maxUsed = coolant.amount;",
		"current_liquid_expr": "Liquid liquid = liquids.current();",
		"used_next_expr": "float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));",
		"activation_returned_early": activation_returned_early,
		"target_after": target_after,
		"coolant_present": coolant_present,
		"coolant_amount": coolant_amount,
		"current_liquid": current_liquid,
		"coolant_evaluated": coolant_evaluated,
		"coolant_guard": coolant_guard,
		"max_used": max_used,
		"liquid": liquid,
	}


static func generated_coolant_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid])
	var coolant_guard_result := {
		"returned_early": result.get("returned_early", false),
		"target_after": result.get("target_after", null),
		"coolant_guard": result.get("coolant_guard", false),
		"max_used": result.get("max_used", 0.0),
		"liquid": result.get("liquid", null),
	}
	var canonical = coolant_guard_state(result.get("returned_early", false), result.get("target_after", null), coolant_present, coolant_amount, current_liquid)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_GUARD_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.coolant_guard",
		"result": coolant_guard_result,
		"canonical": canonical,
		"matches": coolant_guard_result.get("coolant_guard", null) == canonical.get("coolant_guard", null) and coolant_guard_result.get("max_used", null) == canonical.get("max_used", null),
	}


static func coolant_used_state(coolant_guard: bool, liquid_amount: float, max_used: float, time_delta: float, coolant_multiplier: float, liquid_heat_capacity: float) -> Dictionary:
	var max_used_time_delta: float = max_used * time_delta if coolant_guard else 0.0
	var heat_capacity_limit: float = (1.0 / coolant_multiplier) / liquid_heat_capacity if coolant_guard else 0.0
	var nonnegative_heat_capacity_limit: float = max(0.0, heat_capacity_limit) if coolant_guard else 0.0
	var used: float = min(min(liquid_amount, max_used_time_delta), nonnegative_heat_capacity_limit) if coolant_guard else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_USED_STATE,
		"method": "public void updateTile(){",
		"used_expr": "float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));",
		"remove_next_expr": "liquids.remove(liquid, used);",
		"coolant_guard": coolant_guard,
		"liquid_amount": liquid_amount,
		"max_used": max_used,
		"time_delta": time_delta,
		"coolant_multiplier": coolant_multiplier,
		"liquid_heat_capacity": liquid_heat_capacity,
		"max_used_time_delta": max_used_time_delta,
		"heat_capacity_limit": heat_capacity_limit,
		"nonnegative_heat_capacity_limit": nonnegative_heat_capacity_limit,
		"used": used,
	}


static func generated_coolant_used_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity])
	var coolant_used_result := {
		"coolant_guard": result.get("coolant_guard", false),
		"max_used": result.get("max_used", 0.0),
		"max_used_time_delta": result.get("max_used_time_delta", 0.0),
		"used": result.get("used", 0.0),
	}
	var canonical = coolant_used_state(result.get("coolant_guard", false), liquid_amount, result.get("max_used", 0.0), time_delta, coolant_multiplier, liquid_heat_capacity)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_USED_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.coolant_used",
		"result": coolant_used_result,
		"canonical": canonical,
		"matches": coolant_used_result.get("used", null) == canonical.get("used", null) and coolant_used_result.get("max_used_time_delta", null) == canonical.get("max_used_time_delta", null),
	}


static func coolant_remove_state(coolant_guard: bool, liquid: Variant, used: float) -> Dictionary:
	var remove_called: bool = coolant_guard
	var remove_call: Dictionary = {}
	if remove_called:
		remove_call = {"call": "liquids.remove(liquid, used);", "liquid": liquid, "amount": used}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_REMOVE_STATE,
		"method": "public void updateTile(){",
		"remove_expr": "liquids.remove(liquid, used);",
		"coolant_guard": coolant_guard,
		"liquid": liquid,
		"used": used,
		"remove_called": remove_called,
		"remove_call": remove_call,
	}


static func generated_coolant_remove_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity])
	var coolant_remove_result := {
		"coolant_guard": result.get("coolant_guard", false),
		"liquid": result.get("liquid", null),
		"used": result.get("used", 0.0),
		"remove_called": result.get("remove_called", false),
		"remove_call": result.get("remove_call", {}),
	}
	var canonical = coolant_remove_state(result.get("coolant_guard", false), result.get("liquid", null), result.get("used", 0.0))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_REMOVE_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.coolant_remove",
		"result": coolant_remove_result,
		"canonical": canonical,
		"matches": coolant_remove_result.get("remove_called", null) == canonical.get("remove_called", null) and coolant_remove_result.get("remove_call", null) == canonical.get("remove_call", null),
	}


static func coolant_effect_state(coolant_guard: bool, used: float, chance_result: bool, x: float, y: float, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	var chance_threshold: float = source_turret_defaults.TRACTOR_BEAM_COOLANT_EFFECT_CHANCE * used if coolant_guard else 0.0
	var particle_range: float = size * source_tilesize / 2.0 if coolant_guard else 0.0
	var chance_called: bool = coolant_guard
	var cool_effect_called: bool = coolant_guard and chance_result
	var cool_effect_call: Dictionary = {}
	if cool_effect_called:
		cool_effect_call = {"call": "coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));", "x": x + range_x, "y": y + range_y, "range": particle_range}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_EFFECT_STATE,
		"method": "public void updateTile(){",
		"chance_expr": "Mathf.chance(0.06 * used)",
		"cool_effect_expr": "coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));",
		"coolant_guard": coolant_guard,
		"used": used,
		"chance_result": chance_result,
		"x": x,
		"y": y,
		"size": size,
		"source_tilesize": source_tilesize,
		"range_x": range_x,
		"range_y": range_y,
		"chance_threshold": chance_threshold,
		"particle_range": particle_range,
		"chance_called": chance_called,
		"cool_effect_called": cool_effect_called,
		"cool_effect_call": cool_effect_call,
	}


static func generated_coolant_effect_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y])
	var coolant_effect_result := {
		"coolant_guard": result.get("coolant_guard", false),
		"used": result.get("used", 0.0),
		"chance_threshold": result.get("chance_threshold", 0.0),
		"cool_effect_call": result.get("cool_effect_call", {}),
	}
	var canonical = coolant_effect_state(result.get("coolant_guard", false), result.get("used", 0.0), chance_result, x, y, size, source_tilesize, range_x, range_y)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_EFFECT_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.coolant_effect",
		"result": coolant_effect_result,
		"canonical": canonical,
		"matches": coolant_effect_result.get("chance_threshold", null) == canonical.get("chance_threshold", null) and coolant_effect_result.get("cool_effect_call", null) == canonical.get("cool_effect_call", null),
	}


static func coolant_multiplier_state(coolant_guard: bool, used: float, liquid_heat_capacity: float, coolant_multiplier: float) -> Dictionary:
	var coolant_multiplier_assign_called: bool = coolant_guard
	var coolant_multiplier_after: float = 1.0 + (used * liquid_heat_capacity * coolant_multiplier) if coolant_guard else coolant_multiplier
	var coolant_multiplier_assign_call: Dictionary = {}
	if coolant_multiplier_assign_called:
		coolant_multiplier_assign_call = {"call": "coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);", "value": coolant_multiplier_after}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_MULTIPLIER_STATE,
		"method": "public void updateTile(){",
		"coolant_multiplier_assign_expr": "coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);",
		"coolant_guard": coolant_guard,
		"used": used,
		"liquid_heat_capacity": liquid_heat_capacity,
		"coolant_multiplier": coolant_multiplier,
		"coolant_multiplier_assign_called": coolant_multiplier_assign_called,
		"coolant_multiplier_after": coolant_multiplier_after,
		"coolant_multiplier_assign_call": coolant_multiplier_assign_call,
	}


static func generated_coolant_multiplier_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y])
	var coolant_multiplier_result := {
		"coolant_guard": result.get("coolant_guard", false),
		"used": result.get("used", 0.0),
		"coolant_multiplier_after": result.get("coolant_multiplier_after", coolant_multiplier),
		"coolant_multiplier_assign_call": result.get("coolant_multiplier_assign_call", {}),
	}
	var canonical = coolant_multiplier_state(result.get("coolant_guard", false), result.get("used", 0.0), liquid_heat_capacity, coolant_multiplier)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_COOLANT_MULTIPLIER_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.coolant_multiplier",
		"result": coolant_multiplier_result,
		"canonical": canonical,
		"matches": coolant_multiplier_result.get("coolant_multiplier_after", null) == canonical.get("coolant_multiplier_after", null) and coolant_multiplier_result.get("coolant_multiplier_assign_call", null) == canonical.get("coolant_multiplier_assign_call", null),
	}


static func any_reset_state(activation_returned_early: bool, any_before: bool) -> Dictionary:
	var any_reset_evaluated: bool = not activation_returned_early
	var any_reset_called: bool = any_reset_evaluated
	var any_after: bool = false if any_reset_evaluated else any_before
	var any_reset_call: Dictionary = {}
	if any_reset_called:
		any_reset_call = {"call": "any = false;", "value": any_after}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ANY_RESET_STATE,
		"method": "public void updateTile(){",
		"any_reset_expr": "any = false;",
		"activation_returned_early": activation_returned_early,
		"any_before": any_before,
		"any_reset_evaluated": any_reset_evaluated,
		"any_reset_called": any_reset_called,
		"any_after": any_after,
		"any_reset_call": any_reset_call,
	}


static func generated_any_reset_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before])
	var any_reset_result := {
		"activation_returned_early": result.get("activation_returned_early", false),
		"any_after": result.get("any_after", any_before),
		"any_reset_call": result.get("any_reset_call", {}),
	}
	var canonical = any_reset_state(result.get("activation_returned_early", false), any_before)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ANY_RESET_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.any_reset",
		"result": any_reset_result,
		"canonical": canonical,
		"matches": any_reset_result.get("any_after", null) == canonical.get("any_after", null) and any_reset_result.get("any_reset_call", null) == canonical.get("any_reset_call", null),
	}
