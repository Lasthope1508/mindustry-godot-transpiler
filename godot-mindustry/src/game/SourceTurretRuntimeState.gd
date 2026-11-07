extends RefCounted
class_name SourceTurretRuntimeState

const source_turret_outputs_items_state := preload("res://src/game/SourceTurretOutputsItemsState.gd")
const source_turret_combat_state := preload("res://src/game/SourceTurretCombatState.gd")
const source_turret_selected_ammo_runtime_state := preload("res://src/game/SourceTurretSelectedAmmoRuntimeState.gd")
const source_turret_runtime_property_stats_state := preload("res://src/game/SourceTurretRuntimePropertyStatsState.gd")
const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")

const SOURCE_TURRET_LIMIT_RANGE_MARGIN_DEFAULT := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_LIMIT_RANGE_MARGIN_DEFAULT
const SOURCE_TURRET_CONSUME_AMMO_ONCE_DEFAULT := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_CONSUME_AMMO_ONCE_DEFAULT
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_UPDATE_RELOAD := source_turret_runtime_property_stats_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_UPDATE_RELOAD
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_METHOD
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_RETURN := source_turret_runtime_property_stats_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_RETURN
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_FORMULA := source_turret_runtime_property_stats_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_FORMULA
const SOURCE_TURRET_UPDATE_SHOOTING_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_UPDATE_SHOOTING_METHOD
const SOURCE_TURRET_USE_AMMO_METHOD := source_turret_ammo_state.SOURCE_TURRET_USE_AMMO_METHOD
const SOURCE_TURRET_USE_AMMO_CHEATING_GUARD := source_turret_ammo_state.SOURCE_TURRET_USE_AMMO_CHEATING_GUARD
const SOURCE_TURRET_USE_AMMO_ENTRY := source_turret_ammo_state.SOURCE_TURRET_USE_AMMO_ENTRY
const SOURCE_TURRET_USE_AMMO_SUBTRACT := source_turret_ammo_state.SOURCE_TURRET_USE_AMMO_SUBTRACT
const SOURCE_TURRET_USE_AMMO_POP_EMPTY := source_turret_ammo_state.SOURCE_TURRET_USE_AMMO_POP_EMPTY
const SOURCE_TURRET_USE_AMMO_TOTAL_SUBTRACT := source_turret_ammo_state.SOURCE_TURRET_USE_AMMO_TOTAL_SUBTRACT
const SOURCE_TURRET_USE_AMMO_TOTAL_CLAMP := source_turret_ammo_state.SOURCE_TURRET_USE_AMMO_TOTAL_CLAMP
const SOURCE_TURRET_USE_AMMO_RETURN := source_turret_ammo_state.SOURCE_TURRET_USE_AMMO_RETURN
const SOURCE_TURRET_PEEK_AMMO_METHOD := source_turret_ammo_state.SOURCE_TURRET_PEEK_AMMO_METHOD
const SOURCE_TURRET_PEEK_AMMO_RETURN := source_turret_ammo_state.SOURCE_TURRET_PEEK_AMMO_RETURN
const SOURCE_TURRET_HAS_AMMO_METHOD := source_turret_ammo_state.SOURCE_TURRET_HAS_AMMO_METHOD
const SOURCE_TURRET_HAS_AMMO_SKIP_COMMENT := source_turret_ammo_state.SOURCE_TURRET_HAS_AMMO_SKIP_COMMENT
const SOURCE_TURRET_HAS_AMMO_SWAP_EXPR := source_turret_ammo_state.SOURCE_TURRET_HAS_AMMO_SWAP_EXPR
const SOURCE_TURRET_RANGE_FOR_AMMO_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_RANGE_FOR_AMMO_METHOD
const SOURCE_TURRET_RANGE_FOR_AMMO_GATE := source_turret_runtime_property_stats_state.SOURCE_TURRET_RANGE_FOR_AMMO_GATE
const SOURCE_TURRET_RANGE_FOR_AMMO_AMMO_RESULT := source_turret_runtime_property_stats_state.SOURCE_TURRET_RANGE_FOR_AMMO_AMMO_RESULT
const SOURCE_TURRET_RANGE_FOR_AMMO_FALLBACK_RESULT := source_turret_runtime_property_stats_state.SOURCE_TURRET_RANGE_FOR_AMMO_FALLBACK_RESULT
const SOURCE_TURRET_SELECTED_RELOAD_SECONDS_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_RELOAD_SECONDS_METHOD
const SOURCE_TURRET_SELECTED_RANGE_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_RANGE_METHOD
const SOURCE_TURRET_SELECTED_SHOOT_Y_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_SHOOT_Y_METHOD
const SOURCE_TURRET_SELECTED_SHOOT_PATTERN_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_SHOOT_PATTERN_METHOD
const SOURCE_TURRET_SELECTED_INACCURACY_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_INACCURACY_METHOD
const SOURCE_TURRET_SELECTED_ROTATE_SPEED_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_ROTATE_SPEED_METHOD
const SOURCE_TURRET_SELECTED_SHOOT_CONE_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_SHOOT_CONE_METHOD
const SOURCE_TURRET_SELECTED_RECOIL_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_RECOIL_METHOD
const SOURCE_TURRET_SELECTED_RECOILS_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_SELECTED_RECOILS_METHOD
const SOURCE_TURRET_SELECTED_DUO_POS_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_SELECTED_DUO_POS_KEY
const SOURCE_TURRET_SELECTED_TOTAL_AMMO_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_SELECTED_TOTAL_AMMO_KEY
const SOURCE_TURRET_SELECTED_COOLDOWNS_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_SELECTED_COOLDOWNS_KEY
const SOURCE_TURRET_SELECTED_AMMO_STACKS_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_SELECTED_AMMO_STACKS_KEY
const SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY
const SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_FALLBACK := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_FALLBACK
const SOURCE_TURRET_RUNTIME_WORLD_SPEED_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_WORLD_SPEED_KEY
const SOURCE_TURRET_RUNTIME_WORLD_SPEED_FALLBACK := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_WORLD_SPEED_FALLBACK
const SOURCE_TURRET_RUNTIME_DIMENSIONS_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_DIMENSIONS_KEY
const SOURCE_TURRET_RUNTIME_DIMENSIONS_FALLBACK := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_DIMENSIONS_FALLBACK
const SOURCE_TURRET_RUNTIME_HIT_SIZE_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_HIT_SIZE_KEY
const SOURCE_TURRET_RUNTIME_HIT_SIZE_FALLBACK := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_HIT_SIZE_FALLBACK
const SOURCE_TURRET_RUNTIME_DAMAGE_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_DAMAGE_KEY
const SOURCE_TURRET_RUNTIME_DAMAGE_FALLBACK := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_DAMAGE_FALLBACK
const SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_KEY
const SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_FALLBACK := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_FALLBACK
const SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_KEY
const SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_FALLBACK := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_FALLBACK
const SOURCE_TURRET_RUNTIME_RANGE_CHANGE_KEY := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_RANGE_CHANGE_KEY
const SOURCE_TURRET_RUNTIME_RANGE_CHANGE_FALLBACK := source_turret_selected_ammo_runtime_state.SOURCE_TURRET_RUNTIME_RANGE_CHANGE_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	return source_turret_selected_ammo_runtime_state.runtime_method_names(game)

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return source_turret_selected_ammo_runtime_state.runtime_method_name(method_names, key, fallback_name)

static func default_callbacks_state(game: Object) -> Dictionary:
	return source_turret_selected_ammo_runtime_state.default_callbacks_state(game)

static func read_turret_properties(turret) -> Dictionary:
	return source_turret_selected_ammo_runtime_state.read_turret_properties(turret)

static func outputs_items_state() -> Dictionary:
	return source_turret_outputs_items_state.outputs_items_state()

static func generated_outputs_items_bridge_state() -> Dictionary:
	return source_turret_outputs_items_state.generated_outputs_items_bridge_state()

static func turret_reload_seconds(turret, reload_key: String, reload_default: float, tick_rate: float) -> float:
	return source_turret_runtime_property_stats_state.turret_reload_seconds(turret, reload_key, reload_default, tick_rate)

static func turret_reload_seconds_for_ammo(base_reload_seconds: float, data: Dictionary, reload_multiplier: float) -> float:
	return source_turret_runtime_property_stats_state.turret_reload_seconds_for_ammo(base_reload_seconds, data, reload_multiplier)

static func turret_range(turret, range_key: String, range_default: float) -> float:
	return source_turret_runtime_property_stats_state.turret_range(turret, range_key, range_default)

static func turret_range_for_ammo(base_range: float, data: Dictionary, range_change: float) -> float:
	return source_turret_runtime_property_stats_state.turret_range_for_ammo(base_range, data, range_change)

static func turret_shoot_y(turret, shoot_y_key: String, shoot_y_default: float) -> float:
	return source_turret_runtime_property_stats_state.turret_shoot_y(turret, shoot_y_key, shoot_y_default)

static func turret_inaccuracy(turret, inaccuracy_key: String, inaccuracy_default: float) -> float:
	return source_turret_runtime_property_stats_state.turret_inaccuracy(turret, inaccuracy_key, inaccuracy_default)

static func turret_rotate_speed(turret, rotate_speed_key: String, rotate_speed_default: float) -> float:
	return source_turret_runtime_property_stats_state.turret_rotate_speed(turret, rotate_speed_key, rotate_speed_default)

static func turret_shoot_cone(turret, shoot_cone_key: String, shoot_cone_default: float) -> float:
	return source_turret_runtime_property_stats_state.turret_shoot_cone(turret, shoot_cone_key, shoot_cone_default)

static func turret_recoil(turret, recoil_key: String, recoil_default: float) -> float:
	return source_turret_runtime_property_stats_state.turret_recoil(turret, recoil_key, recoil_default)

static func turret_recoils(turret, recoils_key: String, recoils_default: int) -> int:
	return source_turret_runtime_property_stats_state.turret_recoils(turret, recoils_key, recoils_default)

static func turret_recoil_time(turret, recoil_time_key: String, recoil_time_default: float, reload_key: String, reload_default: float, tick_rate: float) -> float:
	return source_turret_runtime_property_stats_state.turret_recoil_time(turret, recoil_time_key, recoil_time_default, reload_key, reload_default, tick_rate)

static func turret_shoot_pattern(turret, shoot_pattern_key: String) -> Dictionary:
	return source_turret_runtime_property_stats_state.turret_shoot_pattern(turret, shoot_pattern_key)

static func selected_ammo_payload(turret) -> Dictionary:
	return source_turret_selected_ammo_runtime_state.selected_ammo_payload(turret)

static func selected_turret_float_stat(game: Object, source_method: String) -> float:
	return source_turret_runtime_property_stats_state.selected_turret_float_stat(game, source_method)

static func selected_turret_dict_stat(game: Object, source_method: String) -> Dictionary:
	return source_turret_runtime_property_stats_state.selected_turret_dict_stat(game, source_method)

static func selected_turret_int_stat(game: Object, source_method: String) -> int:
	return source_turret_runtime_property_stats_state.selected_turret_int_stat(game, source_method)

static func selected_ammo_sprite(turret, default_sprite: String) -> String:
	return source_turret_selected_ammo_runtime_state.selected_ammo_sprite(turret, default_sprite)

static func selected_ammo_lifetime_seconds(turret, lifetime_seconds_fn: Callable) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_lifetime_seconds(turret, lifetime_seconds_fn)

static func selected_ammo_world_speed(turret, world_speed_fn: Callable) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_world_speed(turret, world_speed_fn)

static func selected_ammo_dimensions(turret, dimensions_fn: Callable) -> Dictionary:
	return source_turret_selected_ammo_runtime_state.selected_ammo_dimensions(turret, dimensions_fn)

static func selected_ammo_hit_size(turret, hit_size_fn: Callable) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_hit_size(turret, hit_size_fn)

static func selected_ammo_damage(turret, damage_fn: Callable) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_damage(turret, damage_fn)

static func selected_ammo_multiplier(turret, ammo_multiplier_fn: Callable) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_multiplier(turret, ammo_multiplier_fn)

static func selected_ammo_reload_multiplier(turret, reload_multiplier_fn: Callable) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_reload_multiplier(turret, reload_multiplier_fn)

static func selected_ammo_range_change(turret, range_change_fn: Callable) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_range_change(turret, range_change_fn)

static func selected_ammo_lifetime_seconds_for_game(game: Object) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_lifetime_seconds_for_game(game)

static func selected_ammo_world_speed_for_game(game: Object) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_world_speed_for_game(game)

static func selected_ammo_dimensions_for_game(game: Object) -> Dictionary:
	return source_turret_selected_ammo_runtime_state.selected_ammo_dimensions_for_game(game)

static func selected_ammo_hit_size_for_game(game: Object) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_hit_size_for_game(game)

static func selected_ammo_damage_for_game(game: Object) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_damage_for_game(game)

static func selected_ammo_multiplier_for_game(game: Object) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_multiplier_for_game(game)

static func selected_ammo_reload_multiplier_for_game(game: Object) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_reload_multiplier_for_game(game)

static func selected_ammo_range_change_for_game(game: Object) -> float:
	return source_turret_selected_ammo_runtime_state.selected_ammo_range_change_for_game(game)

static func selected_limit_range_margin(turret, default_limit_range_margin: float) -> float:
	return source_turret_selected_ammo_runtime_state.selected_limit_range_margin(turret, default_limit_range_margin)

static func selected_ammo_count(turret) -> int:
	return source_turret_selected_ammo_runtime_state.selected_ammo_count(turret)

static func selected_max_ammo(turret, default_max_ammo: int) -> int:
	return source_turret_selected_ammo_runtime_state.selected_max_ammo(turret, default_max_ammo)

static func selected_ammo_per_shot(turret, default_ammo_per_shot: int) -> int:
	return source_turret_selected_ammo_runtime_state.selected_ammo_per_shot(turret, default_ammo_per_shot)

static func selected_consume_ammo_once(turret, default_consume_ammo_once: bool) -> bool:
	return source_turret_selected_ammo_runtime_state.selected_consume_ammo_once(turret, default_consume_ammo_once)

static func selected_total_ammo(total_ammo_by_key: Dictionary, key: String) -> int:
	return source_turret_selected_ammo_runtime_state.selected_total_ammo(total_ammo_by_key, key)

static func selected_cooldown_seconds(cooldowns_by_key: Dictionary, key: String) -> float:
	return source_turret_selected_ammo_runtime_state.selected_cooldown_seconds(cooldowns_by_key, key)

static func selected_ammo_stacks(stacks_by_key: Dictionary, key: String) -> Array:
	return source_turret_selected_ammo_runtime_state.selected_ammo_stacks(stacks_by_key, key)

static func selected_ammo_stack_count(stacks_by_key: Dictionary, key: String) -> int:
	return source_turret_selected_ammo_runtime_state.selected_ammo_stack_count(stacks_by_key, key)

static func selected_loaded_ammo_item(stacks_by_key: Dictionary, key: String) -> String:
	return source_turret_selected_ammo_runtime_state.selected_loaded_ammo_item(stacks_by_key, key)

static func selected_turret_cell_key(game: Object) -> String:
	return source_turret_selected_ammo_runtime_state.selected_turret_cell_key(game)

static func selected_total_ammo_for_game(game: Object) -> int:
	return source_turret_selected_ammo_runtime_state.selected_total_ammo_for_game(game)

static func selected_cooldown_seconds_for_game(game: Object) -> float:
	return source_turret_selected_ammo_runtime_state.selected_cooldown_seconds_for_game(game)

static func selected_ammo_stack_count_for_game(game: Object) -> int:
	return source_turret_selected_ammo_runtime_state.selected_ammo_stack_count_for_game(game)

static func selected_loaded_ammo_item_for_game(game: Object) -> String:
	return source_turret_selected_ammo_runtime_state.selected_loaded_ammo_item_for_game(game)

static func selected_playable_turret(content_catalog: Variant, block_id: String) -> Variant:
	if content_catalog == null:
		return null
	return content_catalog.get_by_id(block_id)

static func ammo_data(turret_property_map: Dictionary, item_id: String) -> Dictionary:
	return source_turret_ammo_state.ammo_data(turret_property_map, item_id)

static func peek_ammo_stack_state(stacks: Array, ammo_per_shot: int, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_state.peek_ammo_stack_state(stacks, ammo_per_shot, ammo_entries)

static func use_ammo_stack_state(stacks: Array, total_ammo: int, ammo_per_shot: int, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_state.use_ammo_stack_state(stacks, total_ammo, ammo_per_shot, ammo_entries)

static func item_turret_build_handle_item_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

static func item_turret_build_accept_item_state(item: Variant, total_ammo: int, max_ammo_value: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_accept_item_state(item, total_ammo, max_ammo_value, ammo_multiplier, ammo_type_null)

static func cooldown_state(cooldown_seconds: float, seconds: float) -> Dictionary:
	return source_turret_combat_state.cooldown_state(cooldown_seconds, seconds)

static func fire_cycle_state(current_rotation: float, target_rotation: float, seconds: float, rotate_speed: float, shoot_cone: float, cooldown_seconds: float, reload_seconds: float, tick_rate: float, move_angle_toward: Callable, angle_distance: Callable) -> Dictionary:
	return source_turret_combat_state.fire_cycle_state(current_rotation, target_rotation, seconds, rotate_speed, shoot_cone, cooldown_seconds, reload_seconds, tick_rate, move_angle_toward, angle_distance)

static func total_inaccuracy(base_turret_inaccuracy: float, bullet_inaccuracy: float) -> float:
	return source_turret_combat_state.total_inaccuracy(base_turret_inaccuracy, bullet_inaccuracy)

static func recoil_offset(recoil_rotation_degrees: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Vector2:
	return source_turret_combat_state.recoil_offset(recoil_rotation_degrees, cur_recoil, recoil_pow, recoil)

static func recoil_step_state(cur_recoil: float, seconds: float, tick_rate: float, recoil_time: float) -> Dictionary:
	return source_turret_combat_state.recoil_step_state(cur_recoil, seconds, tick_rate, recoil_time)

static func shoot_x_offset_state(pattern: Dictionary, counter: int) -> Dictionary:
	return source_turret_combat_state.shoot_x_offset_state(pattern, counter)

static func bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret_property_map: Dictionary, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	return source_turret_combat_state.bullet_origin_state(origin_x, origin_y, turret_rotation_degrees, turret_property_map, shoot_x_offset, y_offset, x_spread, shoot_x_default, block_size_default, tilesize, trns_vec)

static func turret_bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	return source_turret_combat_state.turret_bullet_origin_state(origin_x, origin_y, turret_rotation_degrees, turret, shoot_x_offset, y_offset, x_spread, shoot_x_default, block_size_default, tilesize, trns_vec)

static func target_selection_state(origin: Vector2, range_pixels: float, candidates: Array) -> Dictionary:
	return source_turret_combat_state.target_selection_state(origin, range_pixels, candidates)
