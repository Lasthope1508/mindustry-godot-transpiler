class_name SourceUnitMetadataState

const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")

const SOURCE_UNIT_SPEED_DEFAULT_VALUE := source_unit_defaults.SPEED_DEFAULT
const SOURCE_UNIT_HIT_SIZE_DEFAULT_VALUE := source_unit_defaults.HIT_SIZE_DEFAULT
const SOURCE_UNIT_HEALTH_DEFAULT_VALUE := source_unit_defaults.HEALTH_DEFAULT
const SOURCE_UNIT_HIT_SIZE_DEFAULT := "hitSize = 6f,"
const SOURCE_UNIT_HIT_SIZE_DAGGER_ASSIGNMENT := "hitSize = 8f;"
const SOURCE_UNIT_HEALTH_DEFAULT := "health = 200f,"
const SOURCE_UNIT_HEALTH_DAGGER_ASSIGNMENT := "health = 150;"
const SOURCE_UNIT_ICON_COMMENT := source_unit_update_source_text_state.SOURCE_UNIT_ICON_COMMENT
const SOURCE_UNIT_ICON_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_ICON_METHOD
const SOURCE_UNIT_ICON_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_ICON_RETURN
const SOURCE_UNIT_ICON_UI_ICON_FIELD := source_unit_update_source_text_state.SOURCE_UNIT_ICON_UI_ICON_FIELD
const SOURCE_UNIT_ICON_UI_ICON_LOAD := source_unit_update_source_text_state.SOURCE_UNIT_ICON_UI_ICON_LOAD
const SOURCE_UNIT_ICON_CALL := source_unit_update_source_text_state.SOURCE_UNIT_ICON_CALL
const SOURCE_UNIT_ICON_RETURN_VALUE := source_unit_update_source_text_state.SOURCE_UNIT_ICON_RETURN_VALUE
const SOURCE_UNIT_ICON_GENERATED_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_ICON_GENERATED_METHOD
const SOURCE_UNIT_ICON_GENERATED_OWNER := source_unit_update_source_text_state.SOURCE_UNIT_ICON_GENERATED_OWNER
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

static func game_unit_world_speed(_game: Object, unit_type) -> float:
	return unit_world_speed(unit_type, source_time_defaults.TICK_RATE)

static func unit_hit_size(unit_type) -> float:
	if unit_type == null:
		return 0.0
	var properties := unit_properties(unit_type)
	return float(properties.get("hitSize", SOURCE_UNIT_HIT_SIZE_DEFAULT_VALUE))

static func physic_size(hit_size: float) -> float:
	return hit_size * source_unit_defaults.PHYSIC_SIZE_MULTIPLIER

static func in_range(unit_x: float, unit_y: float, other_x: float, other_y: float, type_range: float) -> bool:
	return Vector2(unit_x, unit_y).distance_to(Vector2(other_x, other_y)) <= type_range

static func range_state(type_max_range: float) -> Dictionary:
	return {
		"method": source_unit_update_source_text_state.SOURCE_UNIT_RANGE_METHOD,
		"return": source_unit_update_source_text_state.SOURCE_UNIT_RANGE_RETURN,
		"type_max_range": type_max_range,
		"range": type_max_range,
	}

static func clip_size_state(is_building: bool, infinite_resources: bool, type_clip_size: float, type_region_width: float, type_build_range: float, source_tilesize: float, is_mining: bool, type_mine_range: float) -> Dictionary:
	var branch := "building" if is_building else "mining" if is_mining else "default"
	var clip_size: float = type_clip_size
	if is_building:
		clip_size = source_math_defaults.FLOAT_MAX_VALUE if infinite_resources else maxf(type_clip_size, type_region_width) + type_build_range + source_tilesize * 4.0
	elif is_mining:
		clip_size = type_clip_size + type_mine_range
	return {
		"method": source_unit_update_source_text_state.SOURCE_UNIT_CLIP_SIZE_METHOD,
		"building_gate": source_unit_update_source_text_state.SOURCE_UNIT_CLIP_SIZE_BUILDING_GATE,
		"building_return": source_unit_update_source_text_state.SOURCE_UNIT_CLIP_SIZE_BUILDING_RETURN,
		"mining_gate": source_unit_update_source_text_state.SOURCE_UNIT_CLIP_SIZE_MINING_GATE,
		"mining_return": source_unit_update_source_text_state.SOURCE_UNIT_CLIP_SIZE_MINING_RETURN,
		"return": source_unit_update_source_text_state.SOURCE_UNIT_CLIP_SIZE_RETURN,
		"is_building": is_building,
		"infinite_resources": infinite_resources,
		"type_clip_size": type_clip_size,
		"type_region_width": type_region_width,
		"type_build_range": type_build_range,
		"source_tilesize": source_tilesize,
		"is_mining": is_mining,
		"type_mine_range": type_mine_range,
		"branch": branch,
		"clip_size": clip_size,
	}

static func has_weapons(weapons: Array) -> bool:
	return not weapons.is_empty()

static func speed(elevation_value: float, grounded_value: bool, player_value: bool, velocity_angle: float, rotation_value: float, strafe_penalty_value: float, can_boost_value: bool, boost_multiplier_value: float, type_speed_value: float, floor_speed_multiplier_value: float) -> float:
	var strafe_penalty := 1.0
	if not grounded_value and player_value:
		var angle_progress := source_math_state.source_angles_angle_dist(velocity_angle, rotation_value) / 180.0
		strafe_penalty = lerpf(1.0, strafe_penalty_value, angle_progress)
	var boost_target := boost_multiplier_value if can_boost_value else 1.0
	var boost := lerpf(1.0, boost_target, elevation_value)
	return type_speed_value * strafe_penalty * boost * floor_speed_multiplier_value

static func ammof_state() -> Dictionary:
	return {
		"method": source_unit_update_source_text_state.SOURCE_UNIT_AMMOF_METHOD,
		"return": source_unit_update_source_text_state.SOURCE_UNIT_AMMOF_RETURN,
		"ammof": 1.0,
	}

static func displayable_state(type_hoverable: bool) -> Dictionary:
	return {
		"method": source_unit_update_source_text_state.SOURCE_UNIT_DISPLAYABLE_METHOD,
		"return": source_unit_update_source_text_state.SOURCE_UNIT_DISPLAYABLE_RETURN,
		"type_hoverable": type_hoverable,
		"displayable": type_hoverable,
	}

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
