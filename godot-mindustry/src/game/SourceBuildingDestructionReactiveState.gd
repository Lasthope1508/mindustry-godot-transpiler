extends RefCounted
class_name SourceBuildingDestructionReactiveState

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_destruction_source_text_state := preload("res://src/game/SourceBuildingDestructionSourceTextState.gd")

const SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY
const SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_FALLBACK := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_FALLBACK
const SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_METHOD
const SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_SPLASH_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_SPLASH_EXPR
const SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_LOOP_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_LOOP_EXPR
const SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_DELAY_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_DELAY_EXPR
const SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_TILE_WORLD_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_TILE_WORLD_EXPR
const SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_DEPOSIT_GUARD_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_DEPOSIT_GUARD_EXPR
const SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_DEPOSIT_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_DEPOSIT_EXPR
const SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_METHOD
const SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD
const SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_SPLASH_LIQUID_CALL_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_SPLASH_LIQUID_CALL_EXPR
const SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_DYNAMIC_EXPLOSION_COMMENT := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_DYNAMIC_EXPLOSION_COMMENT
const SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_EXPR
const SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_RUBBLE_CALL_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_RUBBLE_CALL_EXPR

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_building_destruction_method_names"):
		var names = game.call("_building_destruction_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY, SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_FALLBACK)),
	}

static func _random_seed_float_max(source_seed: int, max_value: float) -> float:
	return source_math_state.random_seed_float_max(source_seed, max_value)

static func _with_source_owner(source_exprs: Dictionary, state: Dictionary) -> Dictionary:
	var result := source_exprs.duplicate()
	result.merge(state)
	return result

static func after_destroyed_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int, random_seed_float_max: Callable) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_AFTER_DESTROYED_STATE}
	if not has_destroy_bullet:
		return _with_source_owner(source_exprs, {"create_bullet": false})
	return _with_source_owner(source_exprs, {
		"create_bullet": true,
		"team": team_id if destroy_bullet_same_team else "derelict",
		"x": source_x,
		"y": source_y,
		"rotation": float(random_seed_float_max.call(building_id, source_math_defaults.FULL_CIRCLE_DEGREES)),
	})

static func game_after_destroyed_state(game: Object, has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return after_destroyed_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id, callbacks.get(SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY, Callable()))

static func explosion_item_cap_state(item_capacity: int) -> int:
	return item_capacity

static func splash_liquid_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SPLASH_LIQUID_STATE}
	var splash := clampf(amount / 4.0, 0.0, 10.0)
	var deposit_count := int(ceil(clampf(amount / 5.0, 0.0, 30.0)))
	var delays: Array[float] = []
	for i in deposit_count:
		delays.append(float(i) / 2.0)
	return _with_source_owner(source_exprs, {
		"method": SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_METHOD,
		"splash_expr": SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_SPLASH_EXPR,
		"loop": SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_LOOP_EXPR,
		"delay_expr": SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_DELAY_EXPR,
		"tile_world": SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_TILE_WORLD_EXPR,
		"deposit_guard": SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_DEPOSIT_GUARD_EXPR,
		"deposit": SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_DEPOSIT_EXPR,
		"liquid": liquid,
		"amount": amount,
		"source_block_size": source_block_size,
		"source_tilesize": source_tilesize,
		"splash": splash,
		"deposit_count": deposit_count,
		"delays": delays,
		"random_range": float(source_block_size) * source_tilesize / 2.0,
		"deposit_if_tile_exists": true,
	})

static func on_deconstructed_liquid_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DECONSTRUCTED_LIQUID_STATE}
	var can_drop_liquid := not current_incinerable or deconstruct_drop_all_liquid
	var base := {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_METHOD,
		"has_liquids_module": has_liquids_module,
		"current_amount": current_amount,
		"current_incinerable": current_incinerable,
		"deconstruct_drop_all_liquid": deconstruct_drop_all_liquid,
		"source_block_size": source_block_size,
		"can_drop_liquid": can_drop_liquid,
	}
	if not has_liquids_module or current_amount <= 0.0 or not can_drop_liquid:
		base.merge({"deposit_linked_tiles": false, "per_cell": 0.0, "deposit_call": false}, true)
		return _with_source_owner(source_exprs, base)
	base.merge({
		"deposit_linked_tiles": true,
		"per_cell": current_amount / float(source_block_size * source_block_size) * 2.0,
		"deposit_call": true,
	}, true)
	return _with_source_owner(source_exprs, base)

static func on_destroyed_item_explosion_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_ITEM_EXPLOSION_STATE}
	var explosiveness := base_explosiveness
	var flammability := 0.0
	var power := 0.0
	if has_items:
		for item_state in item_states:
			var item_amount: int = min(int(item_state.get("amount", 0)), item_cap)
			explosiveness += float(item_state.get("explosiveness", 0.0)) * float(item_amount)
			flammability += float(item_state.get("flammability", 0.0)) * float(item_amount)
			power += float(item_state.get("charge", 0.0)) * pow(float(item_amount), 1.1) * 150.0
	return _with_source_owner(source_exprs, {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
		"base_explosiveness": base_explosiveness,
		"has_items": has_items,
		"item_cap": item_cap,
		"explosiveness": explosiveness,
		"flammability": flammability,
		"power": power,
	})

static func on_destroyed_liquid_explosion_state(current_explosiveness: float, current_flammability: float, has_liquids: bool, liquid_states: Array) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_LIQUID_EXPLOSION_STATE}
	var explosiveness := current_explosiveness
	var flammability := current_flammability
	if has_liquids:
		for liquid_state in liquid_states:
			flammability += float(liquid_state.get("flammability", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
			explosiveness += float(liquid_state.get("explosiveness", 0.0)) * float(liquid_state.get("amount", 0.0)) / 2.0
	return _with_source_owner(source_exprs, {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
		"current_explosiveness": current_explosiveness,
		"current_flammability": current_flammability,
		"has_liquids": has_liquids,
		"explosiveness": explosiveness,
		"flammability": flammability,
	})

static func on_destroyed_buffered_power_state(current_power: float, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BUFFERED_POWER_STATE}
	var apply_buffered_power := has_cons_power and cons_power_buffered
	var buffered_power_contribution := power_status * cons_power_capacity if apply_buffered_power else 0.0
	return _with_source_owner(source_exprs, {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
		"current_power": current_power,
		"has_cons_power": has_cons_power,
		"cons_power_buffered": cons_power_buffered,
		"power_status": power_status,
		"cons_power_capacity": cons_power_capacity,
		"apply_buffered_power": apply_buffered_power,
		"buffered_power_contribution": buffered_power_contribution,
		"power": current_power + buffered_power_contribution,
	})

static func on_destroyed_splash_liquid_state(has_liquids: bool, damage_explosions: bool, liquid_states: Array) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_SPLASH_LIQUID_STATE}
	var should_splash := has_liquids and damage_explosions
	return _with_source_owner(source_exprs, {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
		"has_liquids": has_liquids,
		"damage_explosions": damage_explosions,
		"splash_liquids": should_splash,
		"call": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_SPLASH_LIQUID_CALL_EXPR if should_splash else "",
		"liquid_count": liquid_states.size() if should_splash else 0,
		"liquids": liquid_states.duplicate() if should_splash else [],
	})

static func on_destroyed_dynamic_explosion_call_state(source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, damage_explosions: bool, destroy_effect: String, base_shake: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_STATE}
	return _with_source_owner(source_exprs, {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
		"comment": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_DYNAMIC_EXPLOSION_COMMENT,
		"call": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_EXPR,
		"x": source_x,
		"y": source_y,
		"flammability": flammability * flammability_scale,
		"explosiveness": explosiveness * 3.5 * explosiveness_scale,
		"power": power,
		"radius": source_tilesize * float(source_block_size) / 2.0,
		"damage_explosions": damage_explosions,
		"effect": destroy_effect,
		"shake": base_shake,
	})

static func on_destroyed_rubble_state(source_x: float, source_y: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, source_block_size: int) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_RUBBLE_STATE}
	var should_create_rubble := create_rubble and not floor_solid and not floor_is_liquid
	return _with_source_owner(source_exprs, {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
		"source_x": source_x,
		"source_y": source_y,
		"floor_solid": floor_solid,
		"floor_is_liquid": floor_is_liquid,
		"source_block_size": source_block_size,
		"create_rubble": should_create_rubble,
		"call": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_RUBBLE_CALL_EXPR if should_create_rubble else "",
		"x": source_x,
		"y": source_y,
		"size": source_block_size if should_create_rubble else 0,
	})

static func on_destroyed_base_sound_state(headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BASE_SOUND_STATE}
	var should_play_sound := not headless
	return _with_source_owner(source_exprs, {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
		"headless": headless,
		"destroy_sound": destroy_sound,
		"destroy_pitch_min": destroy_pitch_min,
		"destroy_pitch_max": destroy_pitch_max,
		"destroy_sound_volume": destroy_sound_volume,
		"play_destroy_sound": should_play_sound,
		"sound": destroy_sound if should_play_sound else "",
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	})

static func on_destroyed_reactive_sound_state(headless: bool, explosiveness: float, flammability: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_REACTIVE_SOUND_STATE}
	var should_play_reactive_sound := not headless
	var silent_state := {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
		"headless": headless,
		"explosiveness": explosiveness,
		"flammability": flammability,
		"play_reactive_sound": false,
		"reactive_sound_kind": "",
		"sound": "",
		"sound_choices": [],
		"chance": 0.0,
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	}
	if not should_play_reactive_sound:
		return _with_source_owner(source_exprs, silent_state)
	if explosiveness > 40.0:
		return _with_source_owner(source_exprs, {
			"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
			"headless": headless,
			"explosiveness": explosiveness,
			"flammability": flammability,
			"play_reactive_sound": true,
			"reactive_sound_kind": "explosive",
			"sound": "",
			"sound_choices": ["blockExplodeExplosive", "blockExplodeExplosiveAlt"],
			"chance": 0.5,
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		})
	if flammability > 5.0:
		return _with_source_owner(source_exprs, {
			"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
			"headless": headless,
			"explosiveness": explosiveness,
			"flammability": flammability,
			"play_reactive_sound": true,
			"reactive_sound_kind": "flammable",
			"sound": "blockExplodeFlammable",
			"sound_choices": [],
			"chance": 0.0,
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		})
	return _with_source_owner(source_exprs, silent_state)

static func on_destroyed_power_sound_state(headless: bool, power: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_POWER_SOUND_STATE}
	var should_play_power_sound := not headless
	var silent_state := {
		"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
		"headless": headless,
		"power": power,
		"play_power_sound": false,
		"power_sound_kind": "",
		"sound": "",
		"pitch_min": destroy_pitch_min,
		"pitch_max": destroy_pitch_max,
		"volume": destroy_sound_volume,
	}
	if not should_play_power_sound:
		return _with_source_owner(source_exprs, silent_state)
	if power > 30000.0:
		return _with_source_owner(source_exprs, {
			"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
			"headless": headless,
			"power": power,
			"play_power_sound": true,
			"power_sound_kind": "big",
			"sound": "blockExplodeElectricBig",
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		})
	if power > 2000.0:
		return _with_source_owner(source_exprs, {
			"method": SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_METHOD,
			"headless": headless,
			"power": power,
			"play_power_sound": true,
			"power_sound_kind": "normal",
			"sound": "blockExplodeElectric",
			"pitch_min": destroy_pitch_min,
			"pitch_max": destroy_pitch_max,
			"volume": destroy_sound_volume,
		})
	return _with_source_owner(source_exprs, silent_state)
