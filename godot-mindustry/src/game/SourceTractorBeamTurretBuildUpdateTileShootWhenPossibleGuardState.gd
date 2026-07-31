extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileShootWhenPossibleGuardState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd"
const SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_KEY := "angle_dist"
const SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_FALLBACK := "source_angles_angle_dist"

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_tractor_beam_shoot_guard_method_names"):
		var names = game.call("_tractor_beam_shoot_guard_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_KEY, SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_FALLBACK)),
	}


static func shoot_when_possible_guard_state(strength_lerp_evaluated: bool, rotation_after: float, dest: float, shoot_cone: float, angle_dist: Callable) -> Dictionary:
	var shoot_when_possible_evaluated: bool = strength_lerp_evaluated
	var shoot_within_angle_dist: float = float(angle_dist.call(rotation_after, dest)) if shoot_when_possible_evaluated else 0.0
	var shoot_within_guard: bool = shoot_when_possible_evaluated and shoot_within_angle_dist <= shoot_cone
	var shoot_within_call: Dictionary = {}
	if shoot_when_possible_evaluated:
		shoot_within_call = {"call": "Angles.within(rotation, dest, shootCone)", "rotation": rotation_after, "dest": dest, "shoot_cone": shoot_cone, "angle_dist": shoot_within_angle_dist, "result": shoot_within_guard}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_SHOOT_WHEN_POSSIBLE_GUARD_STATE,
		"method": "public void updateTile(){",
		"shoot_when_possible_guard_expr": "if(Angles.within(rotation, dest, shootCone)){",
		"shoot_when_possible_evaluated": shoot_when_possible_evaluated,
		"shoot_within_angle_dist": shoot_within_angle_dist,
		"shoot_within_guard": shoot_within_guard,
		"shoot_within_call": shoot_within_call,
	}

static func game_shoot_when_possible_guard_state(game: Object, strength_lerp_evaluated: bool, rotation_after: float, dest: float, shoot_cone: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return shoot_when_possible_guard_state(strength_lerp_evaluated, rotation_after, dest, shoot_cone, callbacks.get(SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_KEY, Callable()))


static func generated_shoot_when_possible_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, angle_dist: Callable) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone])
	var shoot_when_possible_guard_result := {
		"strength_lerp_evaluated": result.get("strength_lerp_evaluated", false),
		"rotation_after": result.get("rotation_after", 0.0),
		"dest": result.get("dest", 0.0),
		"shoot_when_possible_evaluated": result.get("shoot_when_possible_evaluated", false),
		"shoot_within_guard": result.get("shoot_within_guard", false) if result.get("shoot_when_possible_evaluated", false) else false,
		"shoot_within_call": result.get("shoot_within_call", {}) if result.get("shoot_when_possible_evaluated", false) else {},
	}
	var canonical = shoot_when_possible_guard_state(result.get("strength_lerp_evaluated", false), result.get("rotation_after", 0.0), result.get("dest", 0.0), shoot_cone, angle_dist)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_SHOOT_WHEN_POSSIBLE_GUARD_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.shoot_when_possible_guard",
		"result": shoot_when_possible_guard_result,
		"canonical": canonical,
		"matches": shoot_when_possible_guard_result.get("shoot_within_guard", null) == canonical.get("shoot_within_guard", null),
	}

static func game_generated_shoot_when_possible_guard_bridge_state(game: Object, activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return generated_shoot_when_possible_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, callbacks.get(SOURCE_TRACTOR_BEAM_SHOOT_GUARD_ANGLE_DIST_KEY, Callable()))
