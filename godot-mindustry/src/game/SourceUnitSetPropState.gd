extends RefCounted
class_name SourceUnitSetPropState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_unit_set_prop_source_text_state := preload("res://src/game/SourceUnitSetPropSourceTextState.gd")

static func laccess_double_state(prop: String, value: float, unit_state: Dictionary, source_tilesize: float) -> Dictionary:
	var action := "ignored"
	var next_value: Variant = null
	match prop:
		"health":
			action = "set_health"
			next_value = clampf(value, 0.0, float(unit_state.get("max_health", 0.0)))
			if float(next_value) <= 0.0 and not bool(unit_state.get("dead", false)):
				action = "kill"
		"shield":
			action = "set_shield"
			next_value = maxf(value, 0.0)
		"x", "y":
			action = "set_position"
			next_value = value * source_tilesize
		"velocityX", "velocityY":
			action = "set_velocity"
			next_value = value * source_tilesize / 60.0
		"rotation":
			action = "set_rotation"
			next_value = value
		"team":
			if not bool(unit_state.get("net_client", false)):
				action = "set_team"
				next_value = int(value)
		"flag":
			action = "set_flag"
			next_value = value
		"speed":
			action = "set_status_speed"
			next_value = clampf(value, 0.0, 1000.0)
		"armor":
			action = "set_status_armor"
			next_value = maxf(value, 0.0)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_SET_PROP_LACCESS_DOUBLE_STATE, "prop": prop, "value": value, "action": action, "next_value": next_value, "source_tilesize": source_tilesize}

static func laccess_object_state(prop: String, value: Variant, unit_state: Dictionary) -> Dictionary:
	var action := "ignored"
	if prop == "team" and value is Dictionary and str(value.get("kind", "")) == "Team" and not bool(unit_state.get("net_client", false)):
		action = "set_team_object"
	elif prop == "payloadType" and not bool(unit_state.get("net_client", false)) and bool(unit_state.get("is_payload", false)):
		if value == null:
			action = "pop_payload"
		elif value is Dictionary and str(value.get("kind", "")) == "Block" and bool(value.get("synthetic", false)):
			action = "add_build_payload_if_pickup"
		elif value is Dictionary and str(value.get("kind", "")) == "UnitType":
			action = "add_unit_payload_if_pickup"
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_SET_PROP_LACCESS_OBJECT_STATE, "prop": prop, "value": value, "action": action}

static func content_state(content: Dictionary, value: float, unit_state: Dictionary) -> Dictionary:
	var action := "ignored"
	var amount := 0
	if str(content.get("kind", "")) == "Item":
		action = "set_stack"
		amount = clampi(int(value), 0, int(unit_state.get("type_item_capacity", 0)))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_SET_PROP_CONTENT_STATE, "content": content, "value": value, "action": action, "amount": amount}
