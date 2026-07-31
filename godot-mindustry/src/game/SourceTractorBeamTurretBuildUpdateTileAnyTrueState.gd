extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileAnyTrueState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd"

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func any_true_state(shoot_within_guard: bool, any_before_shoot: bool) -> Dictionary:
	var any_true_evaluated: bool = shoot_within_guard
	var any_true_called: bool = any_true_evaluated
	var any_after: bool = true if any_true_evaluated else any_before_shoot
	var any_true_call: Dictionary = {}
	if any_true_called:
		any_true_call = {"call": "any = true;", "value": any_after}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ANY_TRUE_STATE,
		"method": "public void updateTile(){",
		"any_true_expr": "any = true;",
		"impulse_next_expr": "target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));",
		"shoot_within_guard": shoot_within_guard,
		"any_before_shoot": any_before_shoot,
		"any_true_evaluated": any_true_evaluated,
		"any_true_called": any_true_called,
		"any_after": any_after,
		"any_true_call": any_true_call,
	}


static func generated_any_true_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float, status: Variant, status_duration: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage, status, status_duration])
	var any_true_result := {
		"shoot_within_guard": result.get("shoot_within_guard", false),
		"any_before_shoot": result.get("any_before_shoot", false),
		"any_after": result.get("any_after", false),
		"any_true_call": result.get("any_true_call", {}) if result.get("any_true_evaluated", false) else {},
	}
	var canonical = any_true_state(result.get("shoot_within_guard", false), result.get("any_before_shoot", false))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ANY_TRUE_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.any_true",
		"result": any_true_result,
		"canonical": canonical,
		"matches": any_true_result.get("any_after", null) == canonical.get("any_after", null),
	}
