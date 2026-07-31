extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileSoundLoopState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd"

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func sound_loop_state(look_target_guard: bool, headless: bool, shoot_sound: Variant, shoot_sound_volume: float) -> Dictionary:
	var sound_loop_evaluated: bool = look_target_guard
	var sound_loop_called: bool = sound_loop_evaluated and not headless
	var shoot_sound_loop_call: Dictionary = {}
	if sound_loop_called:
		shoot_sound_loop_call = {"call": "control.sound.loop(shootSound, this, shootSoundVolume);", "sound": shoot_sound, "target": "this", "volume": shoot_sound_volume}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_SOUND_LOOP_STATE,
		"method": "public void updateTile(){",
		"sound_loop_guard_expr": "if(!headless){",
		"shoot_sound_loop_expr": "control.sound.loop(shootSound, this, shootSoundVolume);",
		"look_target_guard": look_target_guard,
		"headless": headless,
		"shoot_sound": shoot_sound,
		"shoot_sound_volume": shoot_sound_volume,
		"sound_loop_evaluated": sound_loop_evaluated,
		"sound_loop_called": sound_loop_called,
		"shoot_sound_loop_call": shoot_sound_loop_call,
	}

static func generated_sound_loop_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume])
	var canonical = sound_loop_state(result.get("look_target_guard", false), headless, shoot_sound, shoot_sound_volume)
	var sound_loop_result := {
		"look_target_guard": result.get("look_target_guard", false),
		"headless": headless,
		"shoot_sound": shoot_sound,
		"shoot_sound_volume": shoot_sound_volume,
		"sound_loop_evaluated": result.get("sound_loop_evaluated", false),
		"sound_loop_called": result.get("sound_loop_called", false),
		"shoot_sound_loop_call": result.get("shoot_sound_loop_call", {}),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_SOUND_LOOP_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.sound_loop",
		"result": sound_loop_result,
		"canonical": canonical,
		"matches": sound_loop_result.get("shoot_sound_loop_call", null) == canonical.get("shoot_sound_loop_call", null)
			and sound_loop_result.get("sound_loop_called", null) == canonical.get("sound_loop_called", null),
	}
