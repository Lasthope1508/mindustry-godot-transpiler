extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileRotationMoveState

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"move_toward_angle": Callable(game, "source_arc_angles_move_toward"),
	}

static func rotation_move_state(angle_to_target_evaluated: bool, rotation_before: float, dest: float, rotate_speed: float, edelta: float, move_toward_angle: Callable) -> Dictionary:
	var rotation_move_evaluated: bool = angle_to_target_evaluated
	var rotation_max_delta: float = rotate_speed * edelta if rotation_move_evaluated else 0.0
	var rotation_after: float = float(move_toward_angle.call(rotation_before, dest, rotation_max_delta)) if rotation_move_evaluated else rotation_before
	var rotation_move_call: Dictionary = {}
	if rotation_move_evaluated:
		rotation_move_call = {"call": "Angles.moveToward(rotation, dest, rotateSpeed * edelta)", "rotation": rotation_before, "dest": dest, "speed": rotation_max_delta, "result": rotation_after}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_rotation_move_state",
		"method": "public void updateTile(){",
		"dest_expr": "float dest = angleTo(target);",
		"rotation_move_expr": "rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);",
		"angle_to_target_evaluated": angle_to_target_evaluated,
		"rotation_before": rotation_before,
		"dest": dest,
		"rotate_speed": rotate_speed,
		"edelta": edelta,
		"rotation_move_evaluated": rotation_move_evaluated,
		"rotation_max_delta": rotation_max_delta,
		"rotation_after": rotation_after,
		"rotation_move_call": rotation_move_call,
	}

static func generated_rotation_move_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, move_toward_angle: Callable) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd")
	var instance = script.new()
	var result = instance.java_inner_class_TractorBeamBuild_method_updateTile_0([activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed])
	var canonical = rotation_move_state(result.get("angle_to_target_evaluated", false), rotation_before, result.get("dest", 0.0), rotate_speed, result.get("edelta", 0.0), move_toward_angle)
	var rotation_move_result := {
		"angle_to_target_evaluated": result.get("angle_to_target_evaluated", false),
		"rotation_before": rotation_before,
		"dest": result.get("dest", 0.0),
		"rotate_speed": rotate_speed,
		"edelta": result.get("edelta", 0.0),
		"rotation_move_evaluated": result.get("rotation_move_evaluated", false),
		"rotation_max_delta": result.get("rotation_max_delta", 0.0),
		"rotation_after": result.get("rotation_after", rotation_before),
		"rotation_move_call": result.get("rotation_move_call", {}),
	}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_rotation_move_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.updateTile.rotation_move",
		"result": rotation_move_result,
		"canonical": canonical,
		"matches": rotation_move_result.get("rotation_after", null) == canonical.get("rotation_after", null)
			and rotation_move_result.get("rotation_move_call", null) == canonical.get("rotation_move_call", null)
			and rotation_move_result.get("rotation_max_delta", null) == canonical.get("rotation_max_delta", null),
	}
