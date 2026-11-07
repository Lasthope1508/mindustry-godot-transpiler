extends RefCounted
class_name SourceGameRuntimeSummaryState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")
const source_game_runtime_summary_source_text_state := preload("res://src/game/SourceGameRuntimeSummarySourceTextState.gd")

const SOURCE_GAME_RUNTIME_SUMMARY_SOURCE := source_game_runtime_summary_source_text_state.SOURCE_GAME_RUNTIME_SUMMARY_SOURCE
const SOURCE_GAME_RUNTIME_SUMMARY_UPDATE_METHOD := source_game_runtime_summary_source_text_state.SOURCE_GAME_RUNTIME_SUMMARY_UPDATE_METHOD


static func playthrough_state(game: Object) -> Dictionary:
	var generated_class_count := int(game.get("generated_class_count"))
	var loaded_generated_class_names: Array = game.get("loaded_generated_class_names")
	var loaded_generated_instance_names: Array = game.get("loaded_generated_instance_names")
	var all_generated_load_failures: Array = _array_field(game, "all_generated_load_failures")
	var all_generated_instance_failures: Array = _array_field(game, "all_generated_instance_failures")
	var all_generated_scripts: Dictionary = _dict_field(game, "all_generated_scripts")
	var all_generated_instances: Dictionary = _dict_field(game, "all_generated_instances")
	var content_counts: Dictionary = _dict_field(game, "content_counts")
	var produced_total := int(game.get("produced_total"))
	var placed_block_origins: Dictionary = _dict_field(game, "placed_block_origins")
	var placed_blocks: Dictionary = _dict_field(game, "placed_blocks")
	var selected_build_index := int(game.get("selected_build_index"))
	var last_placed_cell: Vector2i = game.get("last_placed_cell")
	var last_turret_recoil_offset: Vector2 = game.get("last_turret_recoil_offset")
	var last_placed_block_requirements: Array = game.get("last_placed_block_requirements")
	var last_overdrive_projector_boosted_cell: Vector2i = game.get("last_overdrive_projector_boosted_cell")
	var last_overdrive_projector_boosted_time_scale: float = float(game.call("source_block_time_scale_at_cell", last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y))
	var last_overdrive_projector_boosted_time_scale_duration: float = float(game.call("source_block_time_scale_duration_at_cell", last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y))
	var last_spawned_wave_groups: Array = game.get("last_spawned_wave_groups")
	var drill_items: Dictionary = game.get("drill_items")
	var core_items: Dictionary = game.get("core_items")
	var selected = source_selected_build_state.selected_build(_array_field(game, "build_palette"), selected_build_index)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_GET_RUNTIME_SUMMARY,
		"source_update_owner": SOURCE_GAME_RUNTIME_SUMMARY_SOURCE,
		"source_update_method": SOURCE_GAME_RUNTIME_SUMMARY_UPDATE_METHOD,
		"generated_class_count": generated_class_count,
		"loaded_generated_class_names": loaded_generated_class_names.duplicate(),
		"loaded_generated_instance_names": loaded_generated_instance_names.duplicate(),
		"loaded_generated_load_failures": all_generated_load_failures.duplicate(),
		"loaded_generated_instance_failures": all_generated_instance_failures.duplicate(),
		"content_counts": content_counts.duplicate(),
		"produced_total": produced_total,
		"ssot_headquarter_registry": game.call("ssot_headquarter_registry_state"),
		"selected_build_has_power": game.call("selected_build_has_power"),
		"selected_build_consumes_power": game.call("selected_build_consumes_power"),
		"selected_build_outputs_power": game.call("selected_build_outputs_power"),
		"selected_build_power_usage": game.call("selected_build_power_usage"),
		"selected_build_power_capacity": game.call("selected_build_power_capacity"),
		"selected_build_power_buffered": game.call("selected_build_power_buffered"),
		"selected_build_power_production": game.call("selected_build_power_production"),
		"selected_build_item_duration": game.call("selected_build_item_duration"),
		"selected_build_max_nodes": game.call("selected_build_max_nodes"),
		"selected_build_laser_range": game.call("selected_build_laser_range"),
		"placed_power_graph_roles": game.call("placed_power_graph_role_counts"),
		"placed_power_needed": game.call("placed_power_needed_state"),
		"placed_power_runtime": game.call("placed_power_runtime_state"),
		"placed_power_battery_runtime": game.call("placed_power_battery_runtime_state"),
		"placed_power_distribution_runtime": game.call("placed_power_distribution_runtime_state"),
		"placed_power_produced": game.call("placed_power_produced_state"),
		"placed_power_battery": game.call("placed_power_battery_state"),
		"placed_block_count": placed_block_origins.size(),
		"occupied_cell_count": placed_blocks.size(),
		"selected_build_index": selected_build_index,
		"selected_build_id": _selected_build_id(selected),
		"all_generated_script_count": all_generated_scripts.size(),
		"all_generated_instance_count": all_generated_instances.size(),
		"last_placed_block_id": str(game.get("last_placed_block_id")),
		"last_placed_block_size": int(game.get("last_placed_block_size")),
		"last_placed_cell": _vector_dict(last_placed_cell),
		"player_placed_block_count": int(game.get("player_placed_block_count")),
		"last_placed_block_requirements": last_placed_block_requirements.duplicate(true),
		"last_placed_occupied_cell_count": int(game.get("last_placed_occupied_cell_count")),
		"last_place_blocked": bool(game.get("last_place_blocked")),
		"initial_world_block_count": int(game.get("initial_world_block_count")),
		"initial_occupied_cell_count": int(game.get("initial_occupied_cell_count")),
		"core_items": core_items.duplicate(),
		"core_max_health": float(game.get("core_max_health")),
		"core_item_capacity": int(game.get("core_item_capacity")),
		"selected_build_health": game.call("selected_build_health"),
		"selected_build_scaled_health": game.call("selected_build_scaled_health"),
		"selected_build_heal_percent": game.call("selected_build_heal_percent"),
		"selected_build_phase_boost": game.call("selected_build_phase_boost"),
		"selected_build_phase_range_boost": game.call("selected_build_phase_range_boost"),
		"selected_build_overdrive_real_boost": game.call("selected_build_overdrive_real_boost"),
		"selected_build_overdrive_phase_real_boost": game.call("selected_build_overdrive_phase_real_boost"),
		"selected_build_overdrive_boost_bar_fraction": game.call("selected_build_overdrive_boost_bar_fraction"),
		"selected_build_overdrive_phase_boost_bar_fraction": game.call("selected_build_overdrive_phase_boost_bar_fraction"),
		"selected_build_can_overdrive": game.call("selected_build_can_overdrive"),
		"selected_build_repair_amount": game.call("selected_build_repair_amount"),
		"selected_build_booster_item": game.call("selected_build_booster_item"),
		"selected_build_booster_use_time": game.call("selected_build_booster_use_time"),
		"selected_build_place_state": game.call("selected_build_place_state"),
		"enemy_runtime": game.call("enemy_runtime_state"),
		"selected_turret_ammo_sprite": game.call("selected_turret_ammo_sprite"),
		"selected_turret_ammo_lifetime_seconds": game.call("selected_turret_ammo_lifetime_seconds"),
		"selected_turret_limit_range_margin": game.call("selected_turret_limit_range_margin"),
		"selected_turret_ammo_world_speed": game.call("selected_turret_ammo_world_speed"),
		"selected_turret_ammo_dimensions": game.call("selected_turret_ammo_dimensions"),
		"selected_turret_ammo_hit_size": game.call("selected_turret_ammo_hit_size"),
		"selected_turret_ammo_damage": game.call("selected_turret_ammo_damage"),
		"selected_turret_ammo_count": game.call("selected_turret_ammo_count"),
		"selected_turret_ammo_multiplier": game.call("selected_turret_ammo_multiplier"),
		"last_turret_fired_reload_multiplier": float(game.get("last_turret_fired_reload_multiplier")),
		"selected_turret_ammo_reload_multiplier": game.call("selected_turret_ammo_reload_multiplier"),
		"selected_turret_cooldown_seconds": game.call("selected_turret_cooldown_seconds"),
		"selected_turret_max_ammo": game.call("selected_turret_max_ammo"),
		"selected_turret_ammo_per_shot": game.call("selected_turret_ammo_per_shot"),
		"selected_turret_consume_ammo_once": game.call("selected_turret_consume_ammo_once"),
		"selected_turret_total_ammo": game.call("selected_turret_total_ammo"),
		"selected_turret_ammo_stack_count": game.call("selected_turret_ammo_stack_count"),
		"selected_turret_loaded_ammo_item": game.call("selected_turret_loaded_ammo_item"),
		"turret_shot_count": int(game.get("turret_shot_count")),
		"bullet_hit_count": int(game.get("bullet_hit_count")),
		"last_bullet_hit_damage": float(game.get("last_bullet_hit_damage")),
		"last_bullet_target_health_before": float(game.get("last_bullet_target_health_before")),
		"last_bullet_target_health_after": float(game.get("last_bullet_target_health_after")),
		"last_bullet_target_destroyed": bool(game.get("last_bullet_target_destroyed")),
		"last_turret_fired_ammo_item": str(game.get("last_turret_fired_ammo_item")),
		"last_turret_fired_damage": float(game.get("last_turret_fired_damage")),
		"bootstrapped_selected_turret_ammo_load_count": int(game.get("bootstrapped_selected_turret_ammo_load_count")),
		"selected_turret_reload_seconds": game.call("selected_turret_reload_seconds"),
		"last_turret_fired_range": float(game.get("last_turret_fired_range")),
		"selected_turret_ammo_range_change": game.call("selected_turret_ammo_range_change"),
		"selected_turret_range": game.call("selected_turret_range"),
		"last_turret_fired_shoot_y": float(game.get("last_turret_fired_shoot_y")),
		"selected_turret_shoot_y": game.call("selected_turret_shoot_y"),
		"last_turret_fired_shoot_x_offset": float(game.get("last_turret_fired_shoot_x_offset")),
		"selected_turret_shoot_pattern": game.call("selected_turret_shoot_pattern"),
		"last_turret_fired_inaccuracy_range": float(game.get("last_turret_fired_inaccuracy_range")),
		"last_turret_fired_inaccuracy_offset": float(game.get("last_turret_fired_inaccuracy_offset")),
		"selected_turret_inaccuracy": game.call("selected_turret_inaccuracy"),
		"selected_turret_rotate_speed": game.call("selected_turret_rotate_speed"),
		"selected_turret_shoot_cone": game.call("selected_turret_shoot_cone"),
		"last_turret_target_rotation": float(game.get("last_turret_target_rotation")),
		"last_turret_rotation": float(game.get("last_turret_rotation")),
		"last_turret_angle_delta": float(game.get("last_turret_angle_delta")),
		"selected_turret_recoil": game.call("selected_turret_recoil"),
		"selected_turret_recoils": game.call("selected_turret_recoils"),
		"last_turret_recoil": float(game.get("last_turret_recoil")),
		"last_turret_recoils": int(game.get("last_turret_recoils")),
		"last_turret_cur_recoil": float(game.get("last_turret_cur_recoil")),
		"last_turret_recoil_offset": _vector_dict(last_turret_recoil_offset),
		"last_overdrive_projector_boosted_cell": _vector_dict(last_overdrive_projector_boosted_cell),
		"last_overdrive_projector_boosted_time_scale": game.call("source_block_time_scale_at_cell", last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y),
		"last_overdrive_projector_boosted_time_scale_duration": game.call("source_block_time_scale_duration_at_cell", last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y),
		"last_mend_projector_target_health": float(game.get("last_mend_projector_target_health")),
		"last_mend_projector_target_max_health": float(game.get("last_mend_projector_target_max_health")),
		"selected_mend_projector_target_health": float(game.get("last_mend_projector_target_health")),
		"selected_mend_projector_target_max_health": float(game.get("last_mend_projector_target_max_health")),
		"last_spawned_wave_index": int(game.get("last_spawned_wave_index")),
		"last_spawned_wave_count": int(game.get("last_spawned_wave_count")),
		"last_spawned_wave_groups": last_spawned_wave_groups.duplicate(true),
		"selected_overdrive_projector_boosted_time_scale": last_overdrive_projector_boosted_time_scale,
		"selected_overdrive_projector_boosted_time_scale_duration": last_overdrive_projector_boosted_time_scale_duration,
		"drill_items": drill_items.duplicate(),
		"drill_items_total": game.call("drill_items_total"),
		"drill_dump_timer": float(game.get("drill_dump_timer")),
		"drill_dump_cursor": int(game.get("drill_dump_cursor")),
		"building_dump_accum": float(game.get("building_dump_accum")),
		"factory_runtime": game.call("factory_runtime_state"),
		"world_viewport_fit": game.call("world_viewport_fit_runtime_state"),
	}

static func game_over_runtime_state(game: Object) -> Dictionary:
	return {
		"game_over": game.game_over,
		"last_game_over_winner": game.last_game_over_winner,
		"core_health": game.core_health,
		"core_damage_taken_total": game.core_damage_taken_total,
		"source_game_over": game.source_game_over_core_destroyed_state(game.core_health, game.game_over),
	}


static func summary_state(game: Object) -> Dictionary:
	var state := playthrough_state(game)
	var summary_runtime_fields := {
		"playthrough_runtime": game.call("playthrough_runtime_state"),
		"game_over_runtime": game.call("game_over_runtime_state"),
		"player_placed_block_count": int(game.get("player_placed_block_count")),
	}
	for key in summary_runtime_fields.keys():
		state[key] = summary_runtime_fields[key]
	return state


static func _array_field(game: Object, name: String) -> Array:
	var value = game.get(name)
	return value.duplicate() if value is Array else []


static func _dict_field(game: Object, name: String) -> Dictionary:
	var value = game.get(name)
	return value.duplicate() if value is Dictionary else {}


static func _vector_dict(value) -> Dictionary:
	return {"x": value.x, "y": value.y}


static func _selected_build_id(selected) -> String:
	if selected == null:
		return ""
	if selected.has_method("id"):
		return str(selected.id())
	return str(selected.get("id") if selected.has_method("get") else "")
