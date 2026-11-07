extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileAnyResetState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)


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
