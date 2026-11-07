extends RefCounted
class_name SourcePuddlesDepositState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_puddles_source_text_state := preload("res://src/game/SourcePuddlesSourceTextState.gd")
const source_puddles_reaction_state := preload("res://src/game/SourcePuddlesReactionState.gd")

const SOURCE_OWNER := source_runtime_owner_registry.PORT_GAME_SOURCE_PUDDLES_DEPOSIT_TILE_LIQUID_STATE
const MAX_LIQUID_DEFAULT := source_puddles_source_text_state.MAX_LIQUID_DEFAULT

static func deposit_tile_liquid_state(tile: Variant, liquid: Variant, amount: float, existing_puddle: Variant = null, floor_solid: bool = false, net_client: bool = false, max_liquid: float = MAX_LIQUID_DEFAULT, context: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {
		source_puddles_source_text_state.RESULT_KEY: {},
		source_puddles_source_text_state.TILE_KEY: tile,
		source_puddles_source_text_state.LIQUID_KEY: liquid,
		source_puddles_source_text_state.AMOUNT_KEY: amount,
		source_puddles_source_text_state.EXISTING_PUDDLE_KEY: existing_puddle,
		source_puddles_source_text_state.FLOOR_SOLID_KEY: floor_solid,
		source_puddles_source_text_state.NET_CLIENT_KEY: net_client,
		source_puddles_source_text_state.MAX_LIQUID_KEY: max_liquid,
		source_puddles_source_text_state.SOURCE_OWNER_KEY: SOURCE_OWNER,
		source_puddles_source_text_state.SOURCE_KEY: source_puddles_source_text_state.SOURCE,
		source_puddles_source_text_state.METHOD_KEY: source_puddles_source_text_state.METHOD_DEPOSIT_FULL,
		source_puddles_source_text_state.CONTEXT_KEY: context,
	}
	var state: Dictionary = {
		source_puddles_source_text_state.DEPOSITED_KEY: false,
		source_puddles_source_text_state.CREATED_KEY: false,
		source_puddles_source_text_state.UPDATED_KEY: false,
		source_puddles_source_text_state.REASON_KEY: "",
		source_puddles_source_text_state.PUDDLE_KEY: existing_puddle,
		source_puddles_source_text_state.AMOUNT_AFTER_KEY: 0.0,
		source_puddles_source_text_state.DEFERRED_REACTION_KEY: false,
		source_puddles_source_text_state.EFFECT_CALLS_KEY: [],
		source_puddles_source_text_state.REACTION_KEY: {},
	}
	if tile == null:
		state[source_puddles_source_text_state.REASON_KEY] = "tile_null"
		result[source_puddles_source_text_state.RESULT_KEY] = state
		return result
	var tile_x := float(context.get(source_puddles_source_text_state.TILE_X_KEY, 0.0))
	var tile_y := float(context.get(source_puddles_source_text_state.TILE_Y_KEY, 0.0))
	var source_x := float(context.get(source_puddles_source_text_state.SOURCE_X_KEY, tile_x))
	var source_y := float(context.get(source_puddles_source_text_state.SOURCE_Y_KEY, tile_y))
	var effect_x := (tile_x + source_x) / 2.0
	var effect_y := (tile_y + source_y) / 2.0
	if bool(context.get(source_puddles_source_text_state.LIQUID_WILL_BOIL_KEY, false)):
		if bool(context.get(source_puddles_source_text_state.VAPOR_CHANCE_PASSED_KEY, false)):
			state[source_puddles_source_text_state.EFFECT_CALLS_KEY].append({"call": "liquid.vaporEffect.at(ax, ay, liquid.gasColor)", "x": effect_x, "y": effect_y})
		state[source_puddles_source_text_state.REASON_KEY] = "boiled"
		result[source_puddles_source_text_state.RESULT_KEY] = state
		return result
	if bool(context.get(source_puddles_source_text_state.HAS_SPACE_ENVIRONMENT_KEY, false)):
		if bool(context.get(source_puddles_source_text_state.SPACE_BULLET_CHANCE_PASSED_KEY, false)) and not bool(context.get(source_puddles_source_text_state.TILE_IS_SOURCE_KEY, true)):
			state[source_puddles_source_text_state.EFFECT_CALLS_KEY].append({"call": "Bullets.spaceLiquid.create(null, source.team(), ax, ay, source.angleTo(tile) + Mathf.range(50f), -1f, Mathf.random(0f, 0.2f), Mathf.random(0.6f, 1f), liquid)", "x": effect_x, "y": effect_y})
		state[source_puddles_source_text_state.REASON_KEY] = "space"
		result[source_puddles_source_text_state.RESULT_KEY] = state
		return result
	var floor_liquid: Variant = context.get(source_puddles_source_text_state.FLOOR_LIQUID_KEY, null)
	if bool(context.get(source_puddles_source_text_state.FLOOR_IS_LIQUID_KEY, false)) and floor_liquid != null and not bool(context.get(source_puddles_source_text_state.LIQUID_CAN_STAY_ON_FLOOR_KEY, false)):
		var floor_reaction := source_puddles_reaction_state.react_puddle_state(floor_liquid, liquid, amount, tile, effect_x, effect_y, bool(context.get(source_puddles_source_text_state.FIREBALL_CHANCE_PASSED_KEY, false)), bool(context.get(source_puddles_source_text_state.STEAM_CHANCE_PASSED_KEY, false)), float(context.get(source_puddles_source_text_state.DEST_REACT_AMOUNT_KEY, 0.0)))
		state[source_puddles_source_text_state.REACTION_KEY] = floor_reaction
		state[source_puddles_source_text_state.EFFECT_CALLS_KEY] = floor_reaction.get("effect_calls", [])
		if bool(context.get(source_puddles_source_text_state.FLOOR_RIPPLE_DUE_KEY, false)) and bool(context.get(source_puddles_source_text_state.INITIAL_KEY, true)) and existing_puddle != null:
			state[source_puddles_source_text_state.EFFECT_CALLS_KEY].append({"call": "Fx.ripple.at(ax, ay, 1f, tile.floor().liquidDrop.color)", "x": effect_x, "y": effect_y})
		state[source_puddles_source_text_state.REASON_KEY] = "floor_liquid_reaction"
		result[source_puddles_source_text_state.RESULT_KEY] = state
		return result
	if floor_solid:
		state[source_puddles_source_text_state.REASON_KEY] = "floor_solid"
		result[source_puddles_source_text_state.RESULT_KEY] = state
		return result
	if existing_puddle == null:
		if net_client:
			state[source_puddles_source_text_state.REASON_KEY] = "client_no_create"
		else:
			var created: Dictionary = {
				source_puddles_source_text_state.LIQUID_ID_KEY: liquid,
				source_puddles_source_text_state.AMOUNT_KEY: minf(amount, max_liquid),
				source_puddles_source_text_state.ACCEPTING_KEY: 0.0,
			}
			state[source_puddles_source_text_state.PUDDLE_KEY] = created
			state[source_puddles_source_text_state.DEPOSITED_KEY] = true
			state[source_puddles_source_text_state.CREATED_KEY] = true
			state[source_puddles_source_text_state.AMOUNT_AFTER_KEY] = float(created.get(source_puddles_source_text_state.AMOUNT_KEY, 0.0))
			state[source_puddles_source_text_state.REASON_KEY] = "created"
		result[source_puddles_source_text_state.RESULT_KEY] = state
		return result
	if existing_puddle is Dictionary and existing_puddle.get(source_puddles_source_text_state.LIQUID_ID_KEY) == liquid:
		var updated: Dictionary = existing_puddle.duplicate(true)
		updated[source_puddles_source_text_state.ACCEPTING_KEY] = maxf(amount, float(updated.get(source_puddles_source_text_state.ACCEPTING_KEY, 0.0)))
		state[source_puddles_source_text_state.PUDDLE_KEY] = updated
		state[source_puddles_source_text_state.DEPOSITED_KEY] = true
		state[source_puddles_source_text_state.UPDATED_KEY] = true
		state[source_puddles_source_text_state.AMOUNT_AFTER_KEY] = float(updated.get(source_puddles_source_text_state.AMOUNT_KEY, 0.0))
		state[source_puddles_source_text_state.REASON_KEY] = "same_liquid"
		if bool(context.get(source_puddles_source_text_state.PUDDLE_RIPPLE_DUE_KEY, false)) and bool(context.get(source_puddles_source_text_state.INITIAL_KEY, true)) and float(updated.get(source_puddles_source_text_state.AMOUNT_KEY, 0.0)) >= max_liquid / 2.0:
			state[source_puddles_source_text_state.EFFECT_CALLS_KEY].append({"call": "Fx.ripple.at(ax, ay, 1f, p.liquid.color)", "x": effect_x, "y": effect_y})
		result[source_puddles_source_text_state.RESULT_KEY] = state
		return result
	var reaction := source_puddles_reaction_state.react_puddle_state(existing_puddle.get(source_puddles_source_text_state.LIQUID_ID_KEY), liquid, amount, existing_puddle.get("tile", tile), (float(existing_puddle.get("x", tile_x)) + source_x) / 2.0, (float(existing_puddle.get("y", tile_y)) + source_y) / 2.0, bool(context.get(source_puddles_source_text_state.FIREBALL_CHANCE_PASSED_KEY, false)), bool(context.get(source_puddles_source_text_state.STEAM_CHANCE_PASSED_KEY, false)), float(context.get(source_puddles_source_text_state.DEST_REACT_AMOUNT_KEY, 0.0)))
	var added := float(reaction.get(source_puddles_source_text_state.ADDED_KEY, 0.0))
	if bool(context.get(source_puddles_source_text_state.CAP_KEY, false)):
		added = clampf(max_liquid - float(existing_puddle.get(source_puddles_source_text_state.AMOUNT_KEY, 0.0)), 0.0, added)
	var reacted_puddle: Dictionary = existing_puddle.duplicate(true)
	reacted_puddle[source_puddles_source_text_state.AMOUNT_KEY] = float(reacted_puddle.get(source_puddles_source_text_state.AMOUNT_KEY, 0.0)) + added
	state[source_puddles_source_text_state.PUDDLE_KEY] = reacted_puddle
	state[source_puddles_source_text_state.AMOUNT_AFTER_KEY] = float(reacted_puddle.get(source_puddles_source_text_state.AMOUNT_KEY, 0.0))
	state[source_puddles_source_text_state.REACTION_KEY] = reaction
	state[source_puddles_source_text_state.EFFECT_CALLS_KEY] = reaction.get("effect_calls", [])
	state[source_puddles_source_text_state.DEPOSITED_KEY] = true
	state[source_puddles_source_text_state.UPDATED_KEY] = true
	state[source_puddles_source_text_state.REASON_KEY] = "different_liquid_reaction"
	result[source_puddles_source_text_state.RESULT_KEY] = state
	return result
