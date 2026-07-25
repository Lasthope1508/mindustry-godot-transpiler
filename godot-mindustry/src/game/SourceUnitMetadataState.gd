class_name SourceUnitMetadataState

const SourceUnitDefaults := preload("res://src/game/SourceUnitDefaults.gd")

const SOURCE_UNIT_SPEED_DEFAULT_VALUE := SourceUnitDefaults.SPEED_DEFAULT
const SOURCE_UNIT_HIT_SIZE_DEFAULT_VALUE := SourceUnitDefaults.HIT_SIZE_DEFAULT
const SOURCE_UNIT_HEALTH_DEFAULT_VALUE := SourceUnitDefaults.HEALTH_DEFAULT
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

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"bullet_damage": Callable(game, "source_bullet_damage"),
	}

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
