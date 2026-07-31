extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileLookTargetGuardState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd"
const SOURCE_TURRET_LOOK_TARGET_EFFICIENCY_MIN := source_turret_defaults.LOOK_TARGET_EFFICIENCY_MIN

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)


static func look_target_guard_state(activation_returned_early: bool, target_after: Variant, range_value: float, target_hit_size: float, target_within_result: bool, target_team: Variant, team: Variant, target_air: bool, target_ground: bool, target_check_result: bool, efficiency: float) -> Dictionary:
	var look_target_evaluated: bool = not activation_returned_early
	var target_exists_for_look: bool = look_target_evaluated and target_after != null
	var target_within_radius: float = range_value + target_hit_size / 2.0 if target_exists_for_look else 0.0
	var target_within_evaluated: bool = target_exists_for_look
	var target_within_call: Dictionary = {}
	if target_within_evaluated:
		target_within_call = {"call": "target.within(this, range + target.hitSize/2f)", "target": target_after, "radius": target_within_radius, "result": target_within_result}
	var target_team_evaluated: bool = target_within_evaluated and target_within_result
	var target_enemy: bool = target_team != team if target_team_evaluated else false
	var target_check_evaluated: bool = target_team_evaluated and target_enemy
	var target_check_call: Dictionary = {}
	if target_check_evaluated:
		target_check_call = {"call": "target.checkTarget(targetAir, targetGround)", "target_air": target_air, "target_ground": target_ground, "result": target_check_result}
	var efficiency_gate_evaluated: bool = target_check_evaluated and target_check_result
	var look_target_guard: bool = efficiency_gate_evaluated and efficiency > SOURCE_TURRET_LOOK_TARGET_EFFICIENCY_MIN
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_LOOK_TARGET_GUARD_STATE,
		"method": "public void updateTile(){",
		"look_target_comment_expr": "//look at target",
		"look_target_guard_expr": "if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){",
		"activation_returned_early": activation_returned_early,
		"target_after": target_after,
		"range_value": range_value,
		"target_hit_size": target_hit_size,
		"target_within_result": target_within_result,
		"target_team": target_team,
		"team": team,
		"target_air": target_air,
		"target_ground": target_ground,
		"target_check_result": target_check_result,
		"efficiency": efficiency,
		"look_target_evaluated": look_target_evaluated,
		"target_exists_for_look": target_exists_for_look,
		"target_within_radius": target_within_radius,
		"target_within_evaluated": target_within_evaluated,
		"target_within_call": target_within_call,
		"target_team_evaluated": target_team_evaluated,
		"target_enemy": target_enemy,
		"target_check_evaluated": target_check_evaluated,
		"target_check_call": target_check_call,
		"efficiency_gate_evaluated": efficiency_gate_evaluated,
		"look_target_guard": look_target_guard,
	}


static func generated_look_target_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size])
	var look_target_guard_result := {
		"activation_returned_early": result.get("activation_returned_early", false),
		"target_after": result.get("target_after", null),
		"look_target_guard": result.get("look_target_guard", false),
		"target_within_call": result.get("target_within_call", {}),
	}
	var canonical = look_target_guard_state(result.get("activation_returned_early", false), result.get("target_after", null), range_value, target_hit_size, target_within_result, target_team, team, target_air, target_ground, target_check_result, efficiency)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_LOOK_TARGET_GUARD_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.look_target_guard",
		"result": look_target_guard_result,
		"canonical": canonical,
		"matches": look_target_guard_result.get("look_target_guard", null) == canonical.get("look_target_guard", null),
	}
