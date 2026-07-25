extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileAngleToTargetState

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"angle_to_target": Callable(game, "source_angle_to_target"),
	}

static func angle_to_target_state(look_target_guard: bool, x: float, y: float, target_after: Variant, angle_to_target: Callable) -> Dictionary:
	var angle_to_target_evaluated: bool = look_target_guard
	var dest: float = float(angle_to_target.call({"x": x, "y": y}, target_after)) if angle_to_target_evaluated else 0.0
	var angle_to_target_call: Dictionary = {}
	if angle_to_target_evaluated:
		angle_to_target_call = {"call": "angleTo(target)", "origin": {"x": x, "y": y}, "target": target_after, "result": dest}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_angle_to_target_state",
		"method": "public void updateTile(){",
		"look_target_guard_expr": "if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){",
		"dest_expr": "float dest = angleTo(target);",
		"rotation_move_expr": "rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);",
		"look_target_guard": look_target_guard,
		"x": x,
		"y": y,
		"target_after": target_after,
		"angle_to_target_evaluated": angle_to_target_evaluated,
		"dest": dest,
		"angle_to_target_call": angle_to_target_call,
	}

static func generated_angle_to_target_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, angle_to_target: Callable) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd")
	var instance = script.new()
	var result = instance.java_inner_class_TractorBeamBuild_method_updateTile_0([activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume])
	var canonical = angle_to_target_state(result.get("look_target_guard", false), x, y, result.get("target_after", null), angle_to_target)
	var angle_to_target_result := {
		"look_target_guard": result.get("look_target_guard", false),
		"x": x,
		"y": y,
		"target_after": result.get("target_after", null),
		"angle_to_target_evaluated": result.get("angle_to_target_evaluated", false),
		"dest": result.get("dest", 0.0),
		"angle_to_target_call": result.get("angle_to_target_call", {}),
	}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_angle_to_target_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.updateTile.angle_to_target",
		"result": angle_to_target_result,
		"canonical": canonical,
		"matches": angle_to_target_result.get("dest", null) == canonical.get("dest", null)
			and angle_to_target_result.get("angle_to_target_call", null) == canonical.get("angle_to_target_call", null)
			and angle_to_target_result.get("angle_to_target_evaluated", null) == canonical.get("angle_to_target_evaluated", null),
	}
