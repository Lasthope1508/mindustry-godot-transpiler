extends RefCounted
class_name SourcePuddlesReactionState

const source_puddles_source_text_state := preload("res://src/game/SourcePuddlesSourceTextState.gd")

static func react_puddle_state(destination_liquid: Variant, incoming_liquid: Variant, amount: float, tile: Variant, effect_x: float, effect_y: float, fireball_chance_passed: bool, steam_chance_passed: bool, destination_react_amount: float) -> Dictionary:
	var result := {
		"added": 0.0,
		"fires_create_called": false,
		"fireball_create_called": false,
		"steam_effect_called": false,
		"destination_react_called": false,
		"reason": "",
		"effect_calls": [],
	}
	if destination_liquid == null:
		result["reason"] = "destination_null"
		return result
	var destination: Dictionary = destination_liquid if destination_liquid is Dictionary else {}
	var incoming: Dictionary = incoming_liquid if incoming_liquid is Dictionary else {}
	var destination_flammability := float(destination.get("flammability", 0.0))
	var destination_temperature := float(destination.get("temperature", 0.0))
	var incoming_flammability := float(incoming.get("flammability", 0.0))
	var incoming_temperature := float(incoming.get("temperature", 0.0))
	var fire_reaction := (destination_flammability > 0.3 and incoming_temperature > 0.7) or (incoming_flammability > 0.3 and destination_temperature > 0.7)
	if fire_reaction:
		result["fires_create_called"] = true
		result["effect_calls"].append({"call": "Fires.create(tile)", "tile": tile})
		if fireball_chance_passed:
			result["fireball_create_called"] = true
			result["effect_calls"].append({"call": "Bullets.fireball.createNet(Team.derelict, x, y, Mathf.random(360f), -1f, 1f, 1f)", "x": effect_x, "y": effect_y})
	elif destination_temperature > 0.7 and incoming_temperature < 0.55:
		if steam_chance_passed:
			result["steam_effect_called"] = true
			result["effect_calls"].append({"call": "Fx.steam.at(x, y)", "x": effect_x, "y": effect_y})
		result["added"] = -0.1 * amount
		result["reason"] = "cold_on_hot"
		return result
	elif incoming_temperature > 0.7 and destination_temperature < 0.55:
		if steam_chance_passed:
			result["steam_effect_called"] = true
			result["effect_calls"].append({"call": "Fx.steam.at(x, y)", "x": effect_x, "y": effect_y})
		result["added"] = -0.7 * amount
		result["reason"] = "hot_on_cold"
		return result
	result["destination_react_called"] = true
	result["added"] = destination_react_amount
	result["reason"] = "destination_react"
	return result
