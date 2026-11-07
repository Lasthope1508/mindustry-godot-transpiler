extends RefCounted
class_name SourceTurretSelectedAmmoRuntimeState

const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_turret_selected_ammo_source_text_state := preload("res://src/game/SourceTurretSelectedAmmoSourceTextState.gd")

const SOURCE_TURRET_LIMIT_RANGE_MARGIN_DEFAULT := source_turret_defaults.LIMIT_RANGE_MARGIN_DEFAULT
const SOURCE_TURRET_CONSUME_AMMO_ONCE_DEFAULT := source_turret_defaults.CONSUME_AMMO_ONCE_DEFAULT
const SOURCE_TURRET_SELECTED_DUO_POS_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_DUO_POS_KEY
const SOURCE_TURRET_SELECTED_TOTAL_AMMO_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_TOTAL_AMMO_KEY
const SOURCE_TURRET_SELECTED_COOLDOWNS_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_COOLDOWNS_KEY
const SOURCE_TURRET_SELECTED_AMMO_STACKS_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_AMMO_STACKS_KEY
const SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY
const SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_FALLBACK := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_FALLBACK
const SOURCE_TURRET_RUNTIME_WORLD_SPEED_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_WORLD_SPEED_KEY
const SOURCE_TURRET_RUNTIME_WORLD_SPEED_FALLBACK := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_WORLD_SPEED_FALLBACK
const SOURCE_TURRET_RUNTIME_DIMENSIONS_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_DIMENSIONS_KEY
const SOURCE_TURRET_RUNTIME_DIMENSIONS_FALLBACK := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_DIMENSIONS_FALLBACK
const SOURCE_TURRET_RUNTIME_HIT_SIZE_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_HIT_SIZE_KEY
const SOURCE_TURRET_RUNTIME_HIT_SIZE_FALLBACK := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_HIT_SIZE_FALLBACK
const SOURCE_TURRET_RUNTIME_DAMAGE_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_DAMAGE_KEY
const SOURCE_TURRET_RUNTIME_DAMAGE_FALLBACK := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_DAMAGE_FALLBACK
const SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_KEY
const SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_FALLBACK := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_FALLBACK
const SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_KEY
const SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_FALLBACK := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_FALLBACK
const SOURCE_TURRET_RUNTIME_RANGE_CHANGE_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_RANGE_CHANGE_KEY
const SOURCE_TURRET_RUNTIME_RANGE_CHANGE_FALLBACK := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_RANGE_CHANGE_FALLBACK
const SOURCE_TURRET_SELECTED_PROPERTIES_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_PROPERTIES_KEY
const SOURCE_TURRET_SELECTED_AMMO_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_AMMO_KEY
const SOURCE_TURRET_SELECTED_SPRITE_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_SPRITE_KEY
const SOURCE_TURRET_SELECTED_LIMIT_RANGE_MARGIN_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_LIMIT_RANGE_MARGIN_KEY
const SOURCE_TURRET_SELECTED_MAX_AMMO_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_MAX_AMMO_KEY
const SOURCE_TURRET_SELECTED_AMMO_PER_SHOT_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_AMMO_PER_SHOT_KEY
const SOURCE_TURRET_SELECTED_CONSUME_AMMO_ONCE_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_CONSUME_AMMO_ONCE_KEY
const SOURCE_TURRET_SELECTED_ITEM_KEY := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_ITEM_KEY
const SOURCE_TURRET_RUNTIME_METHOD_NAMES_METHOD := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_RUNTIME_METHOD_NAMES_METHOD
const SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD
const SOURCE_TURRET_SELECTED_CELL_KEY_METHOD := source_turret_selected_ammo_source_text_state.SOURCE_TURRET_SELECTED_CELL_KEY_METHOD

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method(SOURCE_TURRET_RUNTIME_METHOD_NAMES_METHOD):
		var names = game.call(SOURCE_TURRET_RUNTIME_METHOD_NAMES_METHOD)
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY, SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_FALLBACK)),
		SOURCE_TURRET_RUNTIME_WORLD_SPEED_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_RUNTIME_WORLD_SPEED_KEY, SOURCE_TURRET_RUNTIME_WORLD_SPEED_FALLBACK)),
		SOURCE_TURRET_RUNTIME_DIMENSIONS_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_RUNTIME_DIMENSIONS_KEY, SOURCE_TURRET_RUNTIME_DIMENSIONS_FALLBACK)),
		SOURCE_TURRET_RUNTIME_HIT_SIZE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_RUNTIME_HIT_SIZE_KEY, SOURCE_TURRET_RUNTIME_HIT_SIZE_FALLBACK)),
		SOURCE_TURRET_RUNTIME_DAMAGE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_RUNTIME_DAMAGE_KEY, SOURCE_TURRET_RUNTIME_DAMAGE_FALLBACK)),
		SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_KEY, SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_FALLBACK)),
		SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_KEY, SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_FALLBACK)),
		SOURCE_TURRET_RUNTIME_RANGE_CHANGE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_RUNTIME_RANGE_CHANGE_KEY, SOURCE_TURRET_RUNTIME_RANGE_CHANGE_FALLBACK)),
	}

static func read_turret_properties(turret) -> Dictionary:
	if turret == null:
		return {}
	var properties = turret.get(SOURCE_TURRET_SELECTED_PROPERTIES_KEY) if turret is Object else turret.get(SOURCE_TURRET_SELECTED_PROPERTIES_KEY, {})
	return properties if typeof(properties) == TYPE_DICTIONARY else {}

static func selected_ammo_payload(turret) -> Dictionary:
	var properties := read_turret_properties(turret)
	var ammo_value = properties.get(SOURCE_TURRET_SELECTED_AMMO_KEY, [])
	var ammo: Array = ammo_value if typeof(ammo_value) == TYPE_ARRAY else []
	if ammo.is_empty():
		return {}
	var data = ammo[0]
	return data if typeof(data) == TYPE_DICTIONARY else {}

static func selected_ammo_sprite(turret, default_sprite: String) -> String:
	var data := selected_ammo_payload(turret)
	if data.is_empty():
		return ""
	return str(data.get(SOURCE_TURRET_SELECTED_SPRITE_KEY, default_sprite))

static func selected_ammo_lifetime_seconds(turret, lifetime_seconds_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(lifetime_seconds_fn.call(data)) if not data.is_empty() and lifetime_seconds_fn.is_valid() else 0.0

static func selected_ammo_world_speed(turret, world_speed_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(world_speed_fn.call(data)) if not data.is_empty() and world_speed_fn.is_valid() else 0.0

static func selected_ammo_dimensions(turret, dimensions_fn: Callable) -> Dictionary:
	var data := selected_ammo_payload(turret)
	return dimensions_fn.call(data) if not data.is_empty() and dimensions_fn.is_valid() else {}

static func selected_ammo_hit_size(turret, hit_size_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(hit_size_fn.call(data)) if not data.is_empty() and hit_size_fn.is_valid() else 0.0

static func selected_ammo_damage(turret, damage_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(damage_fn.call(data)) if not data.is_empty() and damage_fn.is_valid() else 0.0

static func selected_ammo_multiplier(turret, ammo_multiplier_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(ammo_multiplier_fn.call(data)) if not data.is_empty() and ammo_multiplier_fn.is_valid() else 0.0

static func selected_ammo_reload_multiplier(turret, reload_multiplier_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(reload_multiplier_fn.call(data)) if not data.is_empty() and reload_multiplier_fn.is_valid() else 0.0

static func selected_ammo_range_change(turret, range_change_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(range_change_fn.call(data)) if not data.is_empty() and range_change_fn.is_valid() else 0.0

static func selected_ammo_lifetime_seconds_for_game(game: Object) -> float:
	var callbacks := default_callbacks_state(game)
	return selected_ammo_lifetime_seconds(game.call(SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD), callbacks.get(SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY, Callable()))

static func selected_ammo_world_speed_for_game(game: Object) -> float:
	var callbacks := default_callbacks_state(game)
	return selected_ammo_world_speed(game.call(SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD), callbacks.get(SOURCE_TURRET_RUNTIME_WORLD_SPEED_KEY, Callable()))

static func selected_ammo_dimensions_for_game(game: Object) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return selected_ammo_dimensions(game.call(SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD), callbacks.get(SOURCE_TURRET_RUNTIME_DIMENSIONS_KEY, Callable()))

static func selected_ammo_hit_size_for_game(game: Object) -> float:
	var callbacks := default_callbacks_state(game)
	return selected_ammo_hit_size(game.call(SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD), callbacks.get(SOURCE_TURRET_RUNTIME_HIT_SIZE_KEY, Callable()))

static func selected_ammo_damage_for_game(game: Object) -> float:
	var callbacks := default_callbacks_state(game)
	return selected_ammo_damage(game.call(SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD), callbacks.get(SOURCE_TURRET_RUNTIME_DAMAGE_KEY, Callable()))

static func selected_ammo_multiplier_for_game(game: Object) -> float:
	var callbacks := default_callbacks_state(game)
	return selected_ammo_multiplier(game.call(SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD), callbacks.get(SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_KEY, Callable()))

static func selected_ammo_reload_multiplier_for_game(game: Object) -> float:
	var callbacks := default_callbacks_state(game)
	return selected_ammo_reload_multiplier(game.call(SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD), callbacks.get(SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_KEY, Callable()))

static func selected_ammo_range_change_for_game(game: Object) -> float:
	var callbacks := default_callbacks_state(game)
	return selected_ammo_range_change(game.call(SOURCE_TURRET_SELECTED_PLAYABLE_TURRET_METHOD), callbacks.get(SOURCE_TURRET_RUNTIME_RANGE_CHANGE_KEY, Callable()))

static func selected_limit_range_margin(turret, default_limit_range_margin: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	return float(turret_property_map.get(SOURCE_TURRET_SELECTED_LIMIT_RANGE_MARGIN_KEY, default_limit_range_margin))

static func selected_ammo_count(turret) -> int:
	var ammo_value = read_turret_properties(turret).get(SOURCE_TURRET_SELECTED_AMMO_KEY, [])
	var ammo: Array = ammo_value if typeof(ammo_value) == TYPE_ARRAY else []
	return ammo.size()

static func selected_max_ammo(turret, default_max_ammo: int) -> int:
	return int(read_turret_properties(turret).get(SOURCE_TURRET_SELECTED_MAX_AMMO_KEY, default_max_ammo))

static func selected_ammo_per_shot(turret, default_ammo_per_shot: int) -> int:
	return int(read_turret_properties(turret).get(SOURCE_TURRET_SELECTED_AMMO_PER_SHOT_KEY, default_ammo_per_shot))

static func selected_consume_ammo_once(turret, default_consume_ammo_once: bool) -> bool:
	return bool(read_turret_properties(turret).get(SOURCE_TURRET_SELECTED_CONSUME_AMMO_ONCE_KEY, default_consume_ammo_once))

static func selected_total_ammo(total_ammo_by_key: Dictionary, key: String) -> int:
	return int(total_ammo_by_key.get(key, 0))

static func selected_cooldown_seconds(cooldowns_by_key: Dictionary, key: String) -> float:
	return float(cooldowns_by_key.get(key, 0.0))

static func selected_ammo_stacks(stacks_by_key: Dictionary, key: String) -> Array:
	var stacks_value = stacks_by_key.get(key, [])
	return stacks_value if typeof(stacks_value) == TYPE_ARRAY else []

static func selected_ammo_stack_count(stacks_by_key: Dictionary, key: String) -> int:
	return selected_ammo_stacks(stacks_by_key, key).size()

static func selected_loaded_ammo_item(stacks_by_key: Dictionary, key: String) -> String:
	var stacks := selected_ammo_stacks(stacks_by_key, key)
	if stacks.is_empty():
		return ""
	var stack = stacks[stacks.size() - 1]
	return str(stack.get(SOURCE_TURRET_SELECTED_ITEM_KEY, "")) if typeof(stack) == TYPE_DICTIONARY else ""

static func selected_turret_cell_key(game: Object) -> String:
	return str(game.call(SOURCE_TURRET_SELECTED_CELL_KEY_METHOD, game.get(SOURCE_TURRET_SELECTED_DUO_POS_KEY)))

static func selected_total_ammo_for_game(game: Object) -> int:
	return selected_total_ammo(game.get(SOURCE_TURRET_SELECTED_TOTAL_AMMO_KEY), selected_turret_cell_key(game))

static func selected_cooldown_seconds_for_game(game: Object) -> float:
	return selected_cooldown_seconds(game.get(SOURCE_TURRET_SELECTED_COOLDOWNS_KEY), selected_turret_cell_key(game))

static func selected_ammo_stack_count_for_game(game: Object) -> int:
	return selected_ammo_stack_count(game.get(SOURCE_TURRET_SELECTED_AMMO_STACKS_KEY), selected_turret_cell_key(game))

static func selected_loaded_ammo_item_for_game(game: Object) -> String:
	return selected_loaded_ammo_item(game.get(SOURCE_TURRET_SELECTED_AMMO_STACKS_KEY), selected_turret_cell_key(game))
