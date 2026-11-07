extends RefCounted
class_name SourceBulletTypeCreateIncendState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")

static func create_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_incend_state: Dictionary, incend_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_create_incend_state: Dictionary = create_incend_state.duplicate(true)
	var update_random_state: Dictionary = incend_random_state.duplicate(true)
	var incend_x := float(update_create_incend_state.get("x", 0.0))
	var incend_y := float(update_create_incend_state.get("y", 0.0))
	var incend_chance := float(update_type_state.get("incendChance", 1.0))
	var incend_spread := float(update_type_state.get("incendSpread", source_bullet_defaults.INCEND_SPREAD_DEFAULT))
	var incend_amount := int(update_type_state.get("incendAmount", 0))
	var chance_passed: Variant = update_random_state.get("chancePassed", null)
	var incend_gate_passed: bool = incend_chance > 0.0 and chance_passed == true
	var create_incend_call: Dictionary = {"called": false}
	if incend_gate_passed:
		create_incend_call = {
			"call": "Damage.createIncend(x, y, incendSpread, incendAmount)",
			"x": incend_x,
			"y": incend_y,
			"incendSpread": incend_spread,
			"incendAmount": incend_amount,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"createIncend": update_create_incend_state,
		"createIncendState": update_create_incend_state,
		"incendRandom": update_random_state,
		"x": incend_x,
		"y": incend_y,
		"incendChance": incend_chance,
		"incendSpread": incend_spread,
		"incendAmount": incend_amount,
		"chancePassed": chance_passed,
		"chancePassedProvided": chance_passed != null,
		"incendGatePassed": incend_gate_passed,
		"createIncendCall": create_incend_call,
		"chanceSource": "Mathf.chance(incendChance)",
		"createIncendSource": "Damage.createIncend(x, y, incendSpread, incendAmount);",
	}
