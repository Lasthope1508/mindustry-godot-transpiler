extends RefCounted
class_name SourceLiquidReactionState

const source_liquid_defaults := preload("res://src/game/SourceLiquidDefaults.gd")

static func fire_reaction_state(block_reactive_guard_passed: bool, other_flammability: float, liquid_temperature: float, liquid_flammability: float, other_temperature: float, fire_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	var fire_reaction_guard_passed: bool = block_reactive_guard_passed and (
		(other_flammability > source_liquid_defaults.FIRE_REACTION_FLAMMABILITY_THRESHOLD and liquid_temperature > source_liquid_defaults.FIRE_REACTION_TEMPERATURE_THRESHOLD)
		or (liquid_flammability > source_liquid_defaults.FIRE_REACTION_FLAMMABILITY_THRESHOLD and other_temperature > source_liquid_defaults.FIRE_REACTION_TEMPERATURE_THRESHOLD)
	)
	var fire_effect_called: bool = fire_reaction_guard_passed and fire_chance_delta_passed
	return {
		"fire_reaction_guard": "if((other.flammability > 0.3f && liquid.temperature > 0.7f) || (liquid.flammability > 0.3f && other.temperature > 0.7f)){",
		"self_damage_call": "damageContinuous(1);",
		"next_damage_call": "next.damageContinuous(1);",
		"fire_chance_guard": "if(Mathf.chanceDelta(0.1)){",
		"fire_effect_call": "Fx.fire.at(fx, fy);",
		"block_reactive_guard_passed": block_reactive_guard_passed,
		"other_flammability": other_flammability,
		"liquid_temperature": liquid_temperature,
		"liquid_flammability": liquid_flammability,
		"other_temperature": other_temperature,
		"fire_chance_delta_passed": fire_chance_delta_passed,
		"fx": fx,
		"fy": fy,
		"fire_reaction_guard_passed": fire_reaction_guard_passed,
		"self_damage_called": fire_reaction_guard_passed,
		"next_damage_called": fire_reaction_guard_passed,
		"fire_effect_called": fire_effect_called,
	}

static func steam_reaction_state(block_reactive_guard_passed: bool, fire_reaction_guard_passed: bool, liquid_temperature: float, other_temperature: float, current_liquid_amount: float, source_delta: float, steam_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	var steam_reaction_guard_passed: bool = block_reactive_guard_passed and not fire_reaction_guard_passed and (
		(liquid_temperature > source_liquid_defaults.STEAM_REACTION_TEMPERATURE_THRESHOLD and other_temperature < source_liquid_defaults.STEAM_REACTION_COOL_TEMPERATURE_THRESHOLD)
		or (other_temperature > source_liquid_defaults.STEAM_REACTION_TEMPERATURE_THRESHOLD and liquid_temperature < source_liquid_defaults.STEAM_REACTION_COOL_TEMPERATURE_THRESHOLD)
	)
	var reduction: float = min(current_liquid_amount, source_liquid_defaults.STEAM_REACTION_REDUCTION_RATE * source_delta) if steam_reaction_guard_passed else 0.0
	var current_liquid_amount_after: float = current_liquid_amount - reduction
	var steam_effect_called: bool = steam_reaction_guard_passed and steam_chance_delta_passed
	return {
		"steam_reaction_guard": "}else if((liquid.temperature > 0.7f && other.temperature < 0.55f) || (other.temperature > 0.7f && liquid.temperature < 0.55f)){",
		"remove_liquid_call": "liquids.remove(liquid, Math.min(liquids.get(liquid), 0.7f * Time.delta));",
		"steam_chance_guard": "if(Mathf.chanceDelta(0.2f)){",
		"steam_effect_call": "Fx.steam.at(fx, fy);",
		"block_reactive_guard_passed": block_reactive_guard_passed,
		"fire_reaction_guard_passed": fire_reaction_guard_passed,
		"liquid_temperature": liquid_temperature,
		"other_temperature": other_temperature,
		"current_liquid_amount": current_liquid_amount,
		"source_delta": source_delta,
		"steam_chance_delta_passed": steam_chance_delta_passed,
		"fx": fx,
		"fy": fy,
		"steam_reaction_guard_passed": steam_reaction_guard_passed,
		"current_liquid_amount_after": current_liquid_amount_after,
		"steam_effect_called": steam_effect_called,
	}
