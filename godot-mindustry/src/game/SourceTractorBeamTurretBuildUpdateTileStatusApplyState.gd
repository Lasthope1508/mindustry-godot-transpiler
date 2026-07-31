extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileStatusApplyState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_status_defaults := preload("res://src/game/SourceStatusDefaults.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd"

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)


static func status_apply_state(shoot_within_guard: bool, target_after: Variant, status: Variant, status_duration: float) -> Dictionary:
	var status_gate_evaluated: bool = shoot_within_guard
	var status_is_none: bool = status is String and status == source_status_defaults.STATUS_EFFECT_NONE
	var status_gate: bool = status_gate_evaluated and not status_is_none
	var status_apply_call: Dictionary = {}
	if status_gate:
		status_apply_call = {"call": "target.apply(status, statusDuration);", "target": target_after, "status": status, "duration": status_duration}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_STATUS_APPLY_STATE,
		"method": "public void updateTile(){",
		"status_gate_expr": "if(status != StatusEffects.none){",
		"status_apply_expr": "target.apply(status, statusDuration);",
		"status_field_expr": source_status_defaults.STATUS_FIELD_EXPR,
		"status_duration_field_expr": source_status_defaults.STATUS_DURATION_FIELD_EXPR,
		"status_apply_method": source_status_defaults.STATUS_APPLY_METHOD,
		"shoot_within_guard": shoot_within_guard,
		"target_after": target_after,
		"status": status,
		"status_duration": status_duration,
		"status_gate_evaluated": status_gate_evaluated,
		"status_is_none": status_is_none,
		"status_gate": status_gate,
		"status_apply_call": status_apply_call,
	}


static func generated_status_apply_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float, status: Variant, status_duration: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage, status, status_duration])
	var status_apply_result := {
		"shoot_within_guard": result.get("shoot_within_guard", false),
		"target_after": result.get("target_after", null),
		"status_gate": result.get("status_gate", false),
		"status_apply_call": result.get("status_apply_call", {}) if result.get("status_gate", false) else {},
	}
	var canonical = status_apply_state(result.get("shoot_within_guard", false), result.get("target_after", null), status, status_duration)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_STATUS_APPLY_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.status_apply",
		"result": status_apply_result,
		"canonical": canonical,
		"matches": status_apply_result.get("status_gate", null) == canonical.get("status_gate", null),
	}
