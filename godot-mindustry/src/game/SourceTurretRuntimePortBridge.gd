extends "res://src/game/SourceBuildingLifecyclePortBridge.gd"

const source_turret_runtime_state := preload("res://src/game/SourceTurretRuntimeState.gd")
const source_turret_runtime_port_bridge_bullet_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_turret_runtime_port_bridge_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_power_turret_build_state := preload("res://src/game/SourcePowerTurretBuildState.gd")
const source_turret_range_state := preload("res://src/game/SourceTurretRangeState.gd")
const source_turret_presentation_state := preload("res://src/game/SourceTurretPresentationState.gd")
const source_turret_placement_state := preload("res://src/game/SourceTurretPlacementState.gd")
const source_turret_combat_state := preload("res://src/game/SourceTurretCombatState.gd")
const source_turret_recoil_state := preload("res://src/game/SourceTurretRecoilState.gd")
const source_tractor_beam_turret_lifecycle_state := preload("res://src/game/SourceTractorBeamTurretLifecycleState.gd")
const source_item_turret_init_state := preload("res://src/game/SourceItemTurretInitState.gd")
const source_turret_runtime_port_bridge_property_state := preload("res://src/game/SourceTurretPropertyState.gd")
const source_turret_runtime_port_bridge_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_turret_runtime_port_bridge_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_turret_runtime_port_bridge_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

func selected_playable_turret():
	return source_turret_runtime_state.selected_playable_turret(get("content_catalog"), source_turret_runtime_port_bridge_scenario_defaults.BLOCK_DUO)

func selected_turret_ammo_sprite() -> String:
	return source_turret_runtime_state.selected_ammo_sprite(selected_playable_turret(), source_turret_runtime_port_bridge_bullet_state.SOURCE_BULLET_TEXTURE_DEFAULT)

func selected_turret_ammo_lifetime_seconds() -> float:
	return source_turret_runtime_state.selected_ammo_lifetime_seconds_for_game(self)

func selected_turret_limit_range_margin() -> float:
	return source_turret_runtime_state.selected_limit_range_margin(selected_playable_turret(), source_turret_runtime_state.SOURCE_TURRET_LIMIT_RANGE_MARGIN_DEFAULT)

func selected_turret_ammo_world_speed() -> float:
	return source_turret_runtime_state.selected_ammo_world_speed_for_game(self)

func selected_turret_ammo_dimensions() -> Dictionary:
	return source_turret_runtime_state.selected_ammo_dimensions_for_game(self)

func selected_turret_ammo_hit_size() -> float:
	return source_turret_runtime_state.selected_ammo_hit_size_for_game(self)

func selected_turret_ammo_damage() -> float:
	return source_turret_runtime_state.selected_ammo_damage_for_game(self)

func selected_turret_ammo_multiplier() -> float:
	return source_turret_runtime_state.selected_ammo_multiplier_for_game(self)

func selected_turret_ammo_reload_multiplier() -> float:
	return source_turret_runtime_state.selected_ammo_reload_multiplier_for_game(self)

func selected_turret_ammo_range_change() -> float:
	return source_turret_runtime_state.selected_ammo_range_change_for_game(self)

func selected_turret_ammo_count() -> int:
	return source_turret_runtime_state.selected_ammo_count(selected_playable_turret())

func selected_turret_max_ammo() -> int:
	return source_turret_runtime_state.selected_max_ammo(selected_playable_turret(), source_turret_runtime_port_bridge_defaults.MAX_AMMO_DEFAULT)

func selected_turret_ammo_per_shot() -> int:
	return source_turret_runtime_state.selected_ammo_per_shot(selected_playable_turret(), source_turret_runtime_port_bridge_defaults.AMMO_PER_SHOT_DEFAULT)

func selected_turret_consume_ammo_once() -> bool:
	return source_turret_runtime_state.selected_consume_ammo_once(selected_playable_turret(), source_turret_runtime_state.SOURCE_TURRET_CONSUME_AMMO_ONCE_DEFAULT)

func selected_turret_total_ammo() -> int:
	return source_turret_runtime_state.selected_total_ammo_for_game(self)

func selected_turret_cooldown_seconds() -> float:
	return source_turret_runtime_state.selected_cooldown_seconds_for_game(self)

func selected_turret_ammo_stack_count() -> int:
	return source_turret_runtime_state.selected_ammo_stack_count_for_game(self)

func selected_turret_loaded_ammo_item() -> String:
	return source_turret_runtime_state.selected_loaded_ammo_item_for_game(self)

func source_turret_outputs_items_state() -> Dictionary:
	return source_turret_runtime_state.outputs_items_state()

func generated_turret_outputs_items_bridge_state() -> Dictionary:
	return source_turret_runtime_state.generated_outputs_items_bridge_state()

func selected_turret_reload_seconds() -> float:
	return source_turret_runtime_state.selected_turret_float_stat(self, source_turret_runtime_state.SOURCE_TURRET_SELECTED_RELOAD_SECONDS_METHOD)

func selected_turret_range() -> float:
	return source_turret_runtime_state.selected_turret_float_stat(self, source_turret_runtime_state.SOURCE_TURRET_SELECTED_RANGE_METHOD)

func selected_turret_shoot_y() -> float:
	return source_turret_runtime_state.selected_turret_float_stat(self, source_turret_runtime_state.SOURCE_TURRET_SELECTED_SHOOT_Y_METHOD)

func selected_turret_shoot_pattern() -> Dictionary:
	return source_turret_runtime_state.selected_turret_dict_stat(self, source_turret_runtime_state.SOURCE_TURRET_SELECTED_SHOOT_PATTERN_METHOD)

func selected_turret_inaccuracy() -> float:
	return source_turret_runtime_state.selected_turret_float_stat(self, source_turret_runtime_state.SOURCE_TURRET_SELECTED_INACCURACY_METHOD)

func selected_turret_rotate_speed() -> float:
	return source_turret_runtime_state.selected_turret_float_stat(self, source_turret_runtime_state.SOURCE_TURRET_SELECTED_ROTATE_SPEED_METHOD)

func selected_turret_shoot_cone() -> float:
	return source_turret_runtime_state.selected_turret_float_stat(self, source_turret_runtime_state.SOURCE_TURRET_SELECTED_SHOOT_CONE_METHOD)

func selected_turret_recoil() -> float:
	return source_turret_runtime_state.selected_turret_float_stat(self, source_turret_runtime_state.SOURCE_TURRET_SELECTED_RECOIL_METHOD)

func selected_turret_recoils() -> int:
	return source_turret_runtime_state.selected_turret_int_stat(self, source_turret_runtime_state.SOURCE_TURRET_SELECTED_RECOILS_METHOD)

func source_turret_reload_seconds(turret) -> float:
	return source_turret_runtime_state.turret_reload_seconds(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_RELOAD_KEY, source_turret_runtime_port_bridge_defaults.RELOAD_DEFAULT, source_turret_runtime_port_bridge_time_defaults.TICK_RATE)

func source_turret_reload_seconds_for_ammo(turret, data: Dictionary) -> float:
	return source_turret_runtime_state.turret_reload_seconds_for_ammo(source_turret_reload_seconds(turret), data, source_turret_runtime_port_bridge_bullet_state.reload_multiplier(data))

func source_turret_range(turret) -> float:
	return source_turret_runtime_state.turret_range(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_RANGE_KEY, source_turret_runtime_port_bridge_defaults.RANGE_DEFAULT)

func source_turret_shoot_y(turret) -> float:
	return source_turret_runtime_state.turret_shoot_y(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_SHOOT_Y_KEY, source_turret_runtime_port_bridge_defaults.SHOOT_Y_DEFAULT)

func source_turret_inaccuracy(turret) -> float:
	return source_turret_runtime_state.turret_inaccuracy(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_INACCURACY_KEY, source_turret_runtime_port_bridge_defaults.INACCURACY_DEFAULT)

func source_turret_rotate_speed(turret) -> float:
	return source_turret_runtime_state.turret_rotate_speed(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_ROTATE_SPEED_KEY, source_turret_runtime_port_bridge_defaults.ROTATE_SPEED_DEFAULT)

func source_turret_shoot_cone(turret) -> float:
	return source_turret_runtime_state.turret_shoot_cone(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_SHOOT_CONE_KEY, source_turret_runtime_port_bridge_defaults.SHOOT_CONE_DEFAULT)

func source_turret_recoil(turret) -> float:
	return source_turret_runtime_state.turret_recoil(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_RECOIL_KEY, source_turret_runtime_port_bridge_defaults.RECOIL_DEFAULT)

func source_turret_recoils(turret) -> int:
	return source_turret_runtime_state.turret_recoils(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_RECOILS_KEY, source_turret_runtime_port_bridge_defaults.RECOILS_DEFAULT)

func source_turret_recoil_time(turret) -> float:
	return source_turret_runtime_state.turret_recoil_time(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_RECOIL_TIME_KEY, source_turret_runtime_port_bridge_defaults.RECOIL_TIME_DEFAULT, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_RELOAD_KEY, source_turret_runtime_port_bridge_defaults.RELOAD_DEFAULT, source_turret_runtime_port_bridge_time_defaults.TICK_RATE)

func source_turret_shoot_pattern(turret) -> Dictionary:
	return source_turret_runtime_state.turret_shoot_pattern(turret, source_turret_runtime_port_bridge_property_state.SOURCE_TURRET_SHOOT_PATTERN_KEY)

func source_turret_range_for_ammo(turret, data: Dictionary) -> float:
	return source_turret_runtime_state.turret_range_for_ammo(source_turret_range(turret), data, source_turret_runtime_port_bridge_bullet_state.range_change(data))

func source_turret_load_state() -> Dictionary:
	return source_turret_presentation_state.load_state()

func generated_turret_load_bridge_state() -> Dictionary:
	return source_turret_presentation_state.generated_turret_load_bridge_state()

func source_turret_draw_plan_region_state(plan: Variant, list: Variant) -> Dictionary:
	return source_turret_presentation_state.draw_plan_region_state(plan, list)

func generated_turret_draw_plan_region_bridge_state(plan: Variant, list: Variant) -> Dictionary:
	return source_turret_presentation_state.generated_turret_draw_plan_region_bridge_state(plan, list)

func source_turret_icons_state() -> Dictionary:
	return source_turret_presentation_state.icons_state()

func generated_turret_icons_bridge_state() -> Dictionary:
	return source_turret_presentation_state.generated_turret_icons_bridge_state()

func source_turret_get_regions_to_outline_state(out: Variant) -> Dictionary:
	return source_turret_presentation_state.get_regions_to_outline_state(out)

func generated_turret_get_regions_to_outline_bridge_state(out: Variant) -> Dictionary:
	return source_turret_presentation_state.generated_get_regions_to_outline_bridge_state(out)

@warning_ignore("shadowed_variable_base_class")
func source_turret_draw_place_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float, block_offset: float, min_range: float) -> Dictionary:
	return source_turret_placement_state.draw_place_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range)

@warning_ignore("shadowed_variable_base_class")
func generated_turret_draw_place_bridge_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float, block_offset: float, min_range: float) -> Dictionary:
	return source_turret_placement_state.generated_draw_place_bridge_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range)

@warning_ignore("shadowed_variable_base_class")
func generated_turret_draw_place_source_tilesize_default_bridge_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool) -> Dictionary:
	return source_turret_placement_state.generated_draw_place_source_tilesize_default_bridge_state(tile_x, tile_y, rotation, valid, draw_min_range, source_turret_runtime_port_bridge_world_defaults.TILESIZE)

func source_turret_rotated_output_state(tile_x: int, tile_y: int) -> Dictionary:
	return source_turret_placement_state.rotated_output_state(tile_x, tile_y)

func generated_turret_rotated_output_bridge_state(tile_x: int, tile_y: int) -> Dictionary:
	return source_turret_placement_state.generated_rotated_output_bridge_state(tile_x, tile_y)

@warning_ignore("shadowed_variable_base_class")
@warning_ignore("shadowed_variable")
func source_turret_place_ended_state(tile: Variant, builder: Variant, rotation: int, config: Variant, rotate: bool, tile_build_is_turret_build: bool, turret_rotation: float, tile_build_rotdeg: float) -> Dictionary:
	return source_turret_placement_state.place_ended_state(tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg)

@warning_ignore("shadowed_variable_base_class")
@warning_ignore("shadowed_variable")
func generated_turret_place_ended_bridge_state(tile: Variant, builder: Variant, rotation: int, config: Variant, rotate: bool, tile_build_is_turret_build: bool, turret_rotation: float, tile_build_rotdeg: float) -> Dictionary:
	return source_turret_placement_state.generated_place_ended_bridge_state(tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg)

func source_tractor_beam_turret_icons_state(base_region: Variant, region: Variant) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.icons_state(base_region, region)

func generated_tractor_beam_turret_icons_bridge_state(base_region: Variant, region: Variant) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_icons_bridge_state(base_region, region)

func source_tractor_beam_turret_init_state(range_value: float, source_tilesize: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.init_state(range_value, source_tilesize)

func generated_tractor_beam_turret_init_bridge_state(range_value: float, source_tilesize: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_init_bridge_state(range_value, source_tilesize)

func source_tractor_beam_turret_build_should_consume_state(super_should_consume: bool, target: Variant) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.build_should_consume_state(super_should_consume, target)

func generated_tractor_beam_turret_build_should_consume_bridge_state(super_should_consume: bool, target: Variant) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_build_should_consume_bridge_state(super_should_consume, target)

func source_tractor_beam_turret_build_estimate_dps_state(any_state: bool, damage: float, efficiency: float, coolant_multiplier: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.build_estimate_dps_state(any_state, damage, efficiency, coolant_multiplier)

func generated_tractor_beam_turret_build_estimate_dps_bridge_state(any_state: bool, damage: float, efficiency: float, coolant_multiplier: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_build_estimate_dps_bridge_state(any_state, damage, efficiency, coolant_multiplier)

func source_tractor_beam_turret_build_write_state(rotation_value: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.build_write_state(rotation_value)

func generated_tractor_beam_turret_build_write_bridge_state(rotation_value: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_build_write_bridge_state(rotation_value)

func source_tractor_beam_turret_build_read_state(read_f_value: float, revision_value: int) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.build_read_state(read_f_value, revision_value)

func generated_tractor_beam_turret_build_read_bridge_state(read_f_value: float, revision_value: int) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_build_read_bridge_state(read_f_value, revision_value)

func source_turret_limit_range_state(bullet: Dictionary, margin: float, turret_range: float) -> Dictionary:
	return source_turret_range_state.game_limit_range_state(self, bullet, margin, turret_range)

func generated_turret_limit_range_bridge_state(bullet: Dictionary, margin: float, turret_range: float) -> Dictionary:
	return source_turret_range_state.game_generated_limit_range_bridge_state(self, bullet, margin, turret_range)

func source_power_turret_limit_range_state(shoot_type: Variant, margin: float) -> Dictionary:
	return source_turret_range_state.power_turret_limit_range_state(shoot_type, margin)

func generated_power_turret_limit_range_bridge_state(shoot_type: Variant, margin: float) -> Dictionary:
	return source_turret_range_state.generated_power_turret_limit_range_bridge_state(shoot_type, margin)

func source_item_turret_limit_range_default_state() -> Dictionary:
	return source_turret_range_state.item_turret_limit_range_default_state()

func generated_item_turret_limit_range_default_bridge_state() -> Dictionary:
	return source_turret_range_state.generated_item_turret_limit_range_default_bridge_state()

func source_item_turret_limit_range_entries_state(margin: float, ammo_entries: Array) -> Dictionary:
	return source_turret_range_state.item_turret_limit_range_entries_state(margin, ammo_entries)

func generated_item_turret_limit_range_entries_bridge_state(margin: float, ammo_entries: Array) -> Dictionary:
	return source_turret_range_state.generated_item_turret_limit_range_entries_bridge_state(margin, ammo_entries)

func source_item_turret_init_ground_overlap_state(target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, ammo_entries: Array) -> Dictionary:
	return source_item_turret_init_state.ground_overlap_state(target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries)

func generated_item_turret_init_ground_overlap_bridge_state(target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, ammo_entries: Array) -> Dictionary:
	return source_item_turret_init_state.generated_item_turret_init_ground_overlap_bridge_state(target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries)

func generated_item_turret_init_ground_overlap_default_bridge_state() -> Dictionary:
	return source_item_turret_init_state.generated_item_turret_init_ground_overlap_default_bridge_state()

func source_power_turret_build_get_ammo_fraction_state(power_null: bool, power_status: float) -> Dictionary:
	return source_power_turret_build_state.get_ammo_fraction_state(power_null, power_status)

func generated_power_turret_build_get_ammo_fraction_bridge_state(power_null: bool, power_status: float) -> Dictionary:
	return source_power_turret_build_state.generated_get_ammo_fraction_bridge_state(power_null, power_status)

func source_power_turret_build_sense_state(sensor: String, power_null: bool, power_status: float, super_sense_value: float) -> Dictionary:
	return source_power_turret_build_state.sense_state(sensor, power_null, power_status, super_sense_value)

func generated_power_turret_build_sense_bridge_state(sensor: String, power_null: bool, power_status: float, super_sense_value: float) -> Dictionary:
	return source_power_turret_build_state.generated_sense_bridge_state(sensor, power_null, power_status, super_sense_value)

func source_power_turret_build_use_ammo_state(shoot_type: Variant) -> Dictionary:
	return source_power_turret_build_state.use_ammo_state(shoot_type)

func generated_power_turret_build_use_ammo_bridge_state(shoot_type: Variant) -> Dictionary:
	return source_power_turret_build_state.generated_use_ammo_bridge_state(shoot_type)

func source_power_turret_build_has_ammo_state() -> Dictionary:
	return source_power_turret_build_state.has_ammo_state()

func generated_power_turret_build_has_ammo_bridge_state() -> Dictionary:
	return source_power_turret_build_state.generated_has_ammo_bridge_state()

func source_power_turret_build_peek_ammo_state(shoot_type: Variant) -> Dictionary:
	return source_power_turret_build_state.peek_ammo_state(shoot_type)

func generated_power_turret_build_peek_ammo_bridge_state(shoot_type: Variant) -> Dictionary:
	return source_power_turret_build_state.generated_peek_ammo_bridge_state(shoot_type)

func source_turret_recoil_offset(turret, recoil_rotation_degrees: float, cur_recoil: float) -> Vector2:
	return source_turret_combat_state.recoil_offset(recoil_rotation_degrees, cur_recoil, source_turret_recoil_state.SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_DEFAULT, source_turret_recoil(turret))

func update_turret_recoil(cell: Vector2i, turret, delta: float, recoil_rotation_degrees: float) -> void:
	source_turret_combat_state.update_turret_recoil(self, cell, turret, delta, recoil_rotation_degrees)

func apply_turret_recoil_offset(cell: Vector2i, turret, offset: Vector2) -> void:
	source_turret_combat_state.apply_turret_recoil_offset(self, cell, turret, offset)

func use_turret_shoot_x_offset(cell: Vector2i, turret) -> float:
	return source_turret_combat_state.use_turret_shoot_x_offset(self, cell, turret)

func source_turret_bullet_origin(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset := 0.0, y_offset := 0.0, x_spread := 0.0) -> Dictionary:
	return source_turret_combat_state.game_turret_bullet_origin_state(self, origin_x, origin_y, turret_rotation_degrees, turret, shoot_x_offset, y_offset, x_spread)

func source_angle_to_target(origin, target) -> float:
	return source_turret_combat_state.game_angle_to_target(self, origin, target)

func source_turret_total_inaccuracy(turret, data: Dictionary) -> float:
	var bullet_inaccuracy := float(call("source_bullet_inaccuracy", data))
	return source_turret_combat_state.total_inaccuracy(source_turret_inaccuracy(turret), bullet_inaccuracy)

func find_enemy_target(origin: Vector2, range_pixels: float):
	var runtime_enemy_units = get("enemy_units")
	var target_state := source_turret_combat_state.enemy_target_state(origin, range_pixels, runtime_enemy_units if runtime_enemy_units is Array else [])
	return target_state.get("target", null)
