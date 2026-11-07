extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileDamagePierceState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_damage_defaults := preload("res://src/game/SourceDamageDefaults.gd")
const source_rules_defaults := preload("res://src/game/SourceRulesDefaults.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)


static func damage_pierce_state(shoot_within_guard: bool, target_after: Variant, damage: float, eff: float, time_scale: float, rules_block_damage: float, team: Variant) -> Dictionary:
	var damage_gate_evaluated: bool = shoot_within_guard
	var damage_gate: bool = damage_gate_evaluated and damage > 0.0
	var damage_amount: float = damage * eff * time_scale * rules_block_damage if damage_gate else 0.0
	var block_damage_call: Dictionary = {}
	if damage_gate:
		block_damage_call = {"call": "state.rules.blockDamage(team)", "team": team, "result": rules_block_damage}
	var damage_continuous_pierce_call: Dictionary = {}
	if damage_gate:
		damage_continuous_pierce_call = {"call": "target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));", "target": target_after, "amount": damage_amount}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_DAMAGE_PIERCE_STATE,
		"method": "public void updateTile(){",
		"damage_gate_expr": "if(damage > 0){",
		"damage_continuous_pierce_expr": "target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));",
		"rules_block_damage_method": source_rules_defaults.BLOCK_DAMAGE_METHOD,
		"damage_continuous_pierce_method": source_damage_defaults.DAMAGE_CONTINUOUS_PIERCE_METHOD,
		"shoot_within_guard": shoot_within_guard,
		"target_after": target_after,
		"damage": damage,
		"eff": eff,
		"time_scale": time_scale,
		"rules_block_damage": rules_block_damage,
		"team": team,
		"damage_gate_evaluated": damage_gate_evaluated,
		"damage_gate": damage_gate,
		"damage_amount": damage_amount,
		"block_damage_call": block_damage_call,
		"damage_continuous_pierce_call": damage_continuous_pierce_call,
	}


static func generated_damage_pierce_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage])
	var damage_pierce_result := {
		"shoot_within_guard": result.get("shoot_within_guard", false),
		"target_after": result.get("target_after", null),
		"damage_gate": result.get("damage_gate", false),
		"damage_amount": result.get("damage_amount", 0.0) if result.get("damage_gate", false) else 0.0,
		"block_damage_call": result.get("block_damage_call", {}) if result.get("damage_gate", false) else {},
	}
	var canonical = damage_pierce_state(result.get("shoot_within_guard", false), result.get("target_after", null), damage, result.get("eff", 0.0), time_scale, rules_block_damage, team)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_DAMAGE_PIERCE_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.damage_pierce",
		"result": damage_pierce_result,
		"canonical": canonical,
		"matches": damage_pierce_result.get("damage_amount", null) == canonical.get("damage_amount", null) and damage_pierce_result.get("block_damage_call", null) == canonical.get("block_damage_call", null),
	}
