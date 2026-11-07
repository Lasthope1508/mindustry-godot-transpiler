extends RefCounted
class_name SourceBulletTypeHitState

const source_bullet_type_hit_entity_state := preload("res://src/game/SourceBulletTypeHitEntityState.gd")

const SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_KEY := "handle_pierce"
const SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_FALLBACK := "source_bullet_type_handle_pierce_state"

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_bullet_type_hit_method_names"):
		var names = game.call("_bullet_type_hit_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_KEY, SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_FALLBACK)),
	}

static func game_entity_handle_pierce_state(game: Object, bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_destroy_event_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_handle_pierce_state(bullet_type_state, bullet_state, entity_state, damage_cap_state, unit_destroy_event_state, default_callbacks_state(game).get(SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_KEY, Callable()))
