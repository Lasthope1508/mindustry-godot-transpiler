extends "res://src/game/SourceBuildingLifecyclePortBridge.gd"

const source_turret_runtime_state := preload("res://src/game/SourceTurretRuntimeState.gd")
const source_turret_runtime_port_bridge_bullet_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_turret_runtime_port_bridge_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_turret_runtime_port_bridge_property_state := preload("res://src/game/SourceTurretPropertyState.gd")
const source_turret_runtime_port_bridge_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_turret_runtime_port_bridge_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

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
