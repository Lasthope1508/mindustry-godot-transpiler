extends RefCounted
class_name SourceUnitSensorState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_unit_sensor_source_text_state := preload("res://src/game/SourceUnitSensorSourceTextState.gd")

static func _number(state: Dictionary, key: String, fallback: float = 0.0) -> float:
	return float(state.get(key, fallback))

static func _flag(state: Dictionary, key: String, fallback: bool = false) -> bool:
	return bool(state.get(key, fallback))

static func _camera_value(state: Dictionary, key: String) -> float:
	if _flag(state, "player_connection_exists"):
		return _number(state, "player_connection_" + key)
	return _number(state, "core_camera_" + key)

static func laccess_state(sensor: String, unit_state: Dictionary, source_tilesize: float) -> Dictionary:
	var value: float = NAN
	var is_player := str(unit_state.get("controller_kind", "")) == "Player"
	var is_logic_ai := str(unit_state.get("controller_kind", "")) == "LogicAI"
	var is_command_ai := str(unit_state.get("controller_kind", "")) == "CommandAI"
	match sensor:
		"totalItems": value = _number(unit_state, "stack_amount")
		"itemCapacity": value = _number(unit_state, "type_item_capacity")
		"rotation": value = _number(unit_state, "rotation")
		"health": value = _number(unit_state, "health")
		"shield": value = _number(unit_state, "shield")
		"maxHealth": value = _number(unit_state, "max_health")
		"x": value = _number(unit_state, "x") / source_tilesize
		"y": value = _number(unit_state, "y") / source_tilesize
		"velocityX": value = _number(unit_state, "vel_x") * 60.0 / source_tilesize
		"velocityY": value = _number(unit_state, "vel_y") * 60.0 / source_tilesize
		"dead": value = 1.0 if _flag(unit_state, "dead") or not _flag(unit_state, "is_added", true) else 0.0
		"team": value = _number(unit_state, "team_id")
		"shooting": value = 1.0 if _flag(unit_state, "is_shooting") else 0.0
		"boosting": value = 1.0 if _flag(unit_state, "type_can_boost") and _flag(unit_state, "is_flying") else 0.0
		"range": value = _number(unit_state, "range") / source_tilesize
		"shootX": value = _number(unit_state, "aim_x") / source_tilesize
		"shootY": value = _number(unit_state, "aim_y") / source_tilesize
		"cameraX": value = _camera_value(unit_state, "x") / source_tilesize if is_player else 0.0
		"cameraY": value = _camera_value(unit_state, "y") / source_tilesize if is_player else 0.0
		"cameraWidth": value = _camera_value(unit_state, "width") / source_tilesize if is_player else 0.0
		"cameraHeight": value = _camera_value(unit_state, "height") / source_tilesize if is_player else 0.0
		"mining": value = 1.0 if _flag(unit_state, "mining") else 0.0
		"mineX": value = _number(unit_state, "mine_tile_x", -1.0) if _flag(unit_state, "mining") else -1.0
		"mineY": value = _number(unit_state, "mine_tile_y", -1.0) if _flag(unit_state, "mining") else -1.0
		"buildX": value = _number(unit_state, "build_plan_x", -1.0) if _flag(unit_state, "is_building") else -1.0
		"buildY": value = _number(unit_state, "build_plan_y", -1.0) if _flag(unit_state, "is_building") else -1.0
		"armor": value = _number(unit_state, "armor_override") if _number(unit_state, "armor_override", -1.0) >= 0.0 else _number(unit_state, "armor")
		"flag": value = _number(unit_state, "flag")
		"speed": value = _number(unit_state, "type_speed") * 60.0 / source_tilesize * _number(unit_state, "speed_multiplier", 1.0)
		"controlled":
			if not _flag(unit_state, "is_valid", true): value = 0.0
			elif is_logic_ai: value = _number(unit_state, "ctrl_processor")
			elif is_player: value = _number(unit_state, "ctrl_player")
			elif is_command_ai and _flag(unit_state, "command_has_command"): value = _number(unit_state, "ctrl_command")
			else: value = 0.0
		"payloadCount": value = _number(unit_state, "payload_count") if _flag(unit_state, "is_payload") else 0.0
		"totalPayload": value = _number(unit_state, "payload_used") / (source_tilesize * source_tilesize) if _flag(unit_state, "is_payload") else 0.0
		"payloadCapacity": value = _number(unit_state, "type_payload_capacity") / _number(unit_state, "tile_payload", 1.0)
		"size": value = _number(unit_state, "hit_size") / source_tilesize
		"color": value = _number(unit_state, "team_color_double_bits")
		"selectedRotation": value = _number(unit_state, "selected_rotation") if is_player else 0.0
		"pingX": value = _number(unit_state, "ping_x") / source_tilesize if is_player and _flag(unit_state, "is_pinging") else NAN
		"pingY": value = _number(unit_state, "ping_y") / source_tilesize if is_player and _flag(unit_state, "is_pinging") else NAN
		_: value = NAN
	var wire_value: Variant = value
	if is_nan(value):
		wire_value = null
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_SENSE_LACCESS_STATE,
		"source": source_unit_sensor_source_text_state.SOURCE_UNIT_SENSOR_SOURCE,
		"method": source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_LACCESS_METHOD,
		"sensor": sensor,
		"value": wire_value,
		"value_is_nan": is_nan(value),
	}

static func object_state(sensor: String, unit_state: Dictionary, no_sensed: Variant) -> Dictionary:
	var value: Variant = no_sensed
	var controller_kind := str(unit_state.get("controller_kind", ""))
	match sensor:
		"type": value = unit_state.get("type", null)
		"name": value = unit_state.get("player_name", null) if controller_kind == "Player" else null
		"firstItem": value = unit_state.get("stack_item", null) if _number(unit_state, "stack_amount") != 0.0 else null
		"controller":
			if _flag(unit_state, "is_valid", true):
				value = unit_state.get("logic_controller", null) if controller_kind == "LogicAI" else unit_state.get("controller", null)
			else:
				value = null
		"payloadType":
			var payloads: Array = unit_state.get("payloads", []) if unit_state.get("payloads", []) is Array else []
			if not payloads.is_empty():
				var first_payload: Variant = payloads[0]
				if first_payload is Dictionary:
					value = first_payload.get("unit_type", null) if str(first_payload.get("kind", "")) == "UnitPayload" else first_payload.get("block", null) if str(first_payload.get("kind", "")) == "BuildPayload" else null
		"building": value = unit_state.get("building", null) if _flag(unit_state, "is_building") and not _flag(unit_state, "build_plan_breaking") else null
		"breaking": value = unit_state.get("breaking", null) if _flag(unit_state, "is_building") and _flag(unit_state, "build_plan_breaking") else null
		"selectedBlock": value = unit_state.get("selected_block", null) if controller_kind == "Player" else null
		"pingText": value = unit_state.get("ping_text", null) if controller_kind == "Player" and _flag(unit_state, "is_pinging") else null
		_: value = no_sensed
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_SENSE_OBJECT_STATE, "sensor": sensor, "value": value, "no_sensed": no_sensed}

static func content_state(content: Dictionary, unit_state: Dictionary, source_tilesize: float) -> Dictionary:
	var value: float = NAN
	var content_kind := str(content.get("kind", ""))
	var content_id := str(content.get("id", ""))
	var stack_item_id := str(unit_state.get("stack_item_id", ""))
	if content_kind == "Item" and content_id == stack_item_id:
		value = _number(unit_state, "stack_amount")
	elif content_kind == "UnitType" or content_kind == "Block":
		var payloads: Array = unit_state.get("payloads", []) if unit_state.get("payloads", []) is Array else []
		var count := 0
		for payload in payloads:
			if payload is Dictionary:
				var payload_kind := str(payload.get("kind", ""))
				if content_kind == "UnitType" and payload_kind == "UnitPayload" and str(payload.get("unit_type_id", "")) == content_id:
					count += 1
				elif content_kind == "Block" and payload_kind == "BuildPayload" and str(payload.get("block_id", "")) == content_id:
					count += 1
		value = float(count)
	var wire_value: Variant = value
	if is_nan(value):
		wire_value = null
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_SENSE_CONTENT_STATE, "content": content, "value": wire_value, "value_is_nan": is_nan(value), "source_tilesize": source_tilesize}
