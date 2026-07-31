class_name SourceUnitMetadataState

const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")

const SOURCE_UNIT_SPEED_DEFAULT_VALUE := source_unit_defaults.SPEED_DEFAULT
const SOURCE_UNIT_HIT_SIZE_DEFAULT_VALUE := source_unit_defaults.HIT_SIZE_DEFAULT
const SOURCE_UNIT_HEALTH_DEFAULT_VALUE := source_unit_defaults.HEALTH_DEFAULT
const SOURCE_UNIT_HIT_SIZE_DEFAULT := "hitSize = 6f,"
const SOURCE_UNIT_HIT_SIZE_DAGGER_ASSIGNMENT := "hitSize = 8f;"
const SOURCE_UNIT_HEALTH_DEFAULT := "health = 200f,"
const SOURCE_UNIT_HEALTH_DAGGER_ASSIGNMENT := "health = 150;"
const SOURCE_UNIT_ICON_COMMENT := "/** @return a preview UI icon for this unit. */"
const SOURCE_UNIT_ICON_METHOD := "public TextureRegion icon(){"
const SOURCE_UNIT_ICON_RETURN := "return type.uiIcon;"
const SOURCE_UNIT_ICON_UI_ICON_FIELD := "public TextureRegion uiIcon;"
const SOURCE_UNIT_ICON_UI_ICON_LOAD := "uiIcon = Core.atlas.find(getContentType().name() + \"-\" + name + \"-ui\", fullIcon);"
const SOURCE_UNIT_ICON_CALL := "icon()"
const SOURCE_UNIT_ICON_RETURN_VALUE := "type.uiIcon"
const SOURCE_UNIT_METADATA_BULLET_DAMAGE_KEY := "bullet_damage"
const SOURCE_UNIT_METADATA_BULLET_DAMAGE_FALLBACK := "source_bullet_damage"

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_unit_metadata_method_names"):
		var names = game.call("_unit_metadata_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_UNIT_METADATA_BULLET_DAMAGE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_UNIT_METADATA_BULLET_DAMAGE_KEY, SOURCE_UNIT_METADATA_BULLET_DAMAGE_FALLBACK)),
	}

static func game_unit_weapon_damage_state(game: Object, unit_type) -> float:
	var callbacks := default_callbacks_state(game)
	return unit_weapon_damage(unit_type, callbacks.get(SOURCE_UNIT_METADATA_BULLET_DAMAGE_KEY, Callable()))

static func unit_properties(unit_type) -> Dictionary:
	if unit_type == null:
		return {}
	if typeof(unit_type) == TYPE_DICTIONARY:
		var dict_properties = unit_type.get("properties", {})
		return dict_properties if typeof(dict_properties) == TYPE_DICTIONARY else {}
	if unit_type is Object:
		var object_properties = unit_type.get("properties")
		return object_properties if typeof(object_properties) == TYPE_DICTIONARY else {}
	return {}

static func unit_weapons(unit_type) -> Array:
	if unit_type == null:
		return []
	var properties := unit_properties(unit_type)
	return properties.get("weapons", [])

static func unit_weapon_damage(unit_type, bullet_damage: Callable) -> float:
	if unit_type == null:
		return 0.0
	var weapons: Array = unit_weapons(unit_type)
	if weapons.is_empty():
		return 0.0
	var weapon: Dictionary = weapons[0]
	var bullet: Dictionary = weapon.get("bullet", {})
	return float(bullet_damage.call(bullet))

static func unit_world_speed(unit_type, source_tick_rate: float) -> float:
	if unit_type == null:
		return 0.0
	var properties := unit_properties(unit_type)
	return float(properties.get("speed", SOURCE_UNIT_SPEED_DEFAULT_VALUE)) * source_tick_rate

static func unit_hit_size(unit_type) -> float:
	if unit_type == null:
		return 0.0
	var properties := unit_properties(unit_type)
	return float(properties.get("hitSize", SOURCE_UNIT_HIT_SIZE_DEFAULT_VALUE))

static func unit_health(unit_type) -> float:
	if unit_type == null:
		return 0.0
	var properties := unit_properties(unit_type)
	return float(properties.get("health", SOURCE_UNIT_HEALTH_DEFAULT_VALUE))

static func unit_icon_state(type_ui_icon: String) -> Dictionary:
	return {
		"call": SOURCE_UNIT_ICON_CALL,
		"return": SOURCE_UNIT_ICON_RETURN_VALUE,
		"uiIcon": type_ui_icon,
	}
