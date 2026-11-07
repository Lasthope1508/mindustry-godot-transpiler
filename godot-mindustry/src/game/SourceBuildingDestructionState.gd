extends RefCounted
class_name SourceBuildingDestructionState

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_building_destruction_reactive_state := preload("res://src/game/SourceBuildingDestructionReactiveState.gd")
const source_building_destruction_generated_state := preload("res://src/game/SourceBuildingDestructionGeneratedState.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_building_destruction_source_text_state := preload("res://src/game/SourceBuildingDestructionSourceTextState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILD_GENERATED_CLASS := source_block_source_text_state.SOURCE_BUILD_GENERATED_CLASS
const SOURCE_BUILDING_DESTRUCTION_SOURCE := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SOURCE
const SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY
const SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_FALLBACK := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_FALLBACK
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_METHOD
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_VALID_BREAK_GUARD_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_VALID_BREAK_GUARD_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_TILE_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_TILE_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_PERCENT_DEFAULT_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_PERCENT_DEFAULT_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_PERCENT_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_PERCENT_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_ROTATION_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_ROTATION_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREVIOUS_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREVIOUS_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_INSTANT_DECONSTRUCT_GUARD_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_INSTANT_DECONSTRUCT_GUARD_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_INSTANT_DECONSTRUCT_CALL_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_INSTANT_DECONSTRUCT_CALL_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_SUB_BLOCK_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_SUB_BLOCK_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_BUILD_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_BUILD_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_BUILD_ADD_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_BUILD_ADD_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_ON_DECONSTRUCTED_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_ON_DECONSTRUCTED_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_DEAD_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_DEAD_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_SET_BLOCK_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_SET_BLOCK_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_SET_DECONSTRUCT_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_SET_DECONSTRUCT_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_BUILD_ASSIGN_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_BUILD_ASSIGN_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_HEALTH_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_HEALTH_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_LAST_ACCESSED_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_LAST_ACCESSED_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_EVENT_EXPR := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_EVENT_EXPR
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_JAVA_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_JAVA_METHOD
const SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_GENERATED_OWNER := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_GENERATED_OWNER

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func _build_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILD_GENERATED_CLASS, generated_method, generated_args, null)

static func runtime_method_names(game: Object) -> Dictionary:
	return source_building_destruction_reactive_state.runtime_method_names(game)

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return source_building_destruction_reactive_state.runtime_method_name(method_names, key, fallback_name)

static func default_callbacks_state(game: Object) -> Dictionary:
	return source_building_destruction_reactive_state.default_callbacks_state(game)

static func _random_seed_float_max(source_seed: int, max_value: float) -> float:
	return source_math_state.random_seed_float_max(source_seed, max_value)

static func _with_source_owner(source_exprs: Dictionary, state: Dictionary) -> Dictionary:
	var result := source_exprs.duplicate()
	result.merge(state)
	return result

static func begin_break_state(valid_break: bool, tile_has_building: bool, prev_healthf: float, previous_rotation: int, previous_instant_deconstruct: bool, previous_size: int, unit_has_controller_name: bool, controller_name: String) -> Dictionary:
	var source_exprs := {"source_owner": source_runtime_owner_registry.PORT_GAME_BUILD_BEGIN_BREAK_STATE}
	var prev_percent := prev_healthf if tile_has_building else 1.0
	var instant_deconstruct_call: Variant = null
	if previous_instant_deconstruct and valid_break:
		instant_deconstruct_call = {"call": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_INSTANT_DECONSTRUCT_CALL_EXPR}
	var build_construct_block := valid_break and not previous_instant_deconstruct
	var prev_build_added := build_construct_block and tile_has_building
	var last_accessed_set := build_construct_block and unit_has_controller_name
	return _with_source_owner(source_exprs, {
		"source": SOURCE_BUILDING_DESTRUCTION_SOURCE,
		"method": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_METHOD,
		"valid_break_guard_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_VALID_BREAK_GUARD_EXPR,
		"tile_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_TILE_EXPR,
		"prev_percent_default_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_PERCENT_DEFAULT_EXPR,
		"prev_percent_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_PERCENT_EXPR,
		"rotation_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_ROTATION_EXPR,
		"previous_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREVIOUS_EXPR,
		"instant_deconstruct_guard_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_INSTANT_DECONSTRUCT_GUARD_EXPR,
		"instant_deconstruct_call_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_INSTANT_DECONSTRUCT_CALL_EXPR,
		"sub_block_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_SUB_BLOCK_EXPR,
		"prev_build_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_BUILD_EXPR,
		"prev_build_add_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_BUILD_ADD_EXPR,
		"on_deconstructed_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_ON_DECONSTRUCTED_EXPR,
		"dead_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_DEAD_EXPR,
		"set_block_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_SET_BLOCK_EXPR,
		"set_deconstruct_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_SET_DECONSTRUCT_EXPR,
		"prev_build_assign_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_PREV_BUILD_ASSIGN_EXPR,
		"health_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_HEALTH_EXPR,
		"last_accessed_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_LAST_ACCESSED_EXPR,
		"event_expr": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_EVENT_EXPR,
		"valid_break": valid_break,
		"tile_has_building": tile_has_building,
		"prev_percent": prev_percent,
		"rotation": previous_rotation if tile_has_building else 0,
		"previous_instant_deconstruct": previous_instant_deconstruct,
		"previous_size": previous_size,
		"instant_deconstruct_call": instant_deconstruct_call,
		"construct_block_started": build_construct_block,
		"sub_block_size": previous_size if build_construct_block else 0,
		"prev_build_count": 1 if prev_build_added else 0,
		"on_deconstructed_called": prev_build_added,
		"tile_build_dead": prev_build_added,
		"tile_set_block_called": build_construct_block,
		"set_deconstruct_called": build_construct_block,
		"health_restored_from_prev_percent": build_construct_block,
		"last_accessed_set": last_accessed_set,
		"last_accessed": controller_name if last_accessed_set else "",
		"event_fired": build_construct_block,
		"returned_early": not valid_break or previous_instant_deconstruct,
	})

static func generated_build_begin_break_bridge_state(valid_break: bool, tile_has_building: bool, prev_healthf: float, previous_rotation: int, previous_instant_deconstruct: bool, previous_size: int, unit_has_controller_name: bool, controller_name: String) -> Dictionary:
	var result = _build_call(SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_JAVA_METHOD, [valid_break, tile_has_building, prev_healthf, previous_rotation, previous_instant_deconstruct, previous_size, unit_has_controller_name, controller_name])
	var canonical = begin_break_state(valid_break, tile_has_building, prev_healthf, previous_rotation, previous_instant_deconstruct, previous_size, unit_has_controller_name, controller_name)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_BUILD_BEGIN_BREAK_STATE,
		"generated_owner": SOURCE_BUILDING_DESTRUCTION_BEGIN_BREAK_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("returned_early", null) == canonical.get("returned_early", null) and result.get("construct_block_started", null) == canonical.get("construct_block_started", null) and result.get("instant_deconstruct_call", null) == canonical.get("instant_deconstruct_call", null) and result.get("event_fired", null) == canonical.get("event_fired", null),
	}

static func after_destroyed_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int, random_seed_float_max: Callable) -> Dictionary:
	return source_building_destruction_reactive_state.after_destroyed_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id, random_seed_float_max)

static func game_after_destroyed_state(game: Object, has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	return source_building_destruction_reactive_state.game_after_destroyed_state(game, has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id)

static func explosion_item_cap_state(item_capacity: int) -> int:
	return source_building_destruction_reactive_state.explosion_item_cap_state(item_capacity)

static func splash_liquid_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	return source_building_destruction_reactive_state.splash_liquid_state(liquid, amount, source_block_size, source_tilesize)

static func on_deconstructed_liquid_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	return source_building_destruction_reactive_state.on_deconstructed_liquid_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size)

static func on_destroyed_item_explosion_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	return source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)

static func on_destroyed_liquid_explosion_state(current_explosiveness: float, current_flammability: float, has_liquids: bool, liquid_states: Array) -> Dictionary:
	return source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(current_explosiveness, current_flammability, has_liquids, liquid_states)

static func on_destroyed_buffered_power_state(current_power: float, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	return source_building_destruction_reactive_state.on_destroyed_buffered_power_state(current_power, has_cons_power, cons_power_buffered, power_status, cons_power_capacity)

static func on_destroyed_splash_liquid_state(has_liquids: bool, damage_explosions: bool, liquid_states: Array) -> Dictionary:
	return source_building_destruction_reactive_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)

static func on_destroyed_dynamic_explosion_call_state(source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, damage_explosions: bool, destroy_effect: String, base_shake: float) -> Dictionary:
	return source_building_destruction_reactive_state.on_destroyed_dynamic_explosion_call_state(source_x, source_y, flammability, explosiveness, power, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)

static func on_destroyed_rubble_state(source_x: float, source_y: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, source_block_size: int) -> Dictionary:
	return source_building_destruction_reactive_state.on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)

static func on_destroyed_base_sound_state(headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_reactive_state.on_destroyed_base_sound_state(headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

static func on_destroyed_reactive_sound_state(headless: bool, explosiveness: float, flammability: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_reactive_state.on_destroyed_reactive_sound_state(headless, explosiveness, flammability, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

static func on_destroyed_power_sound_state(headless: bool, power: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_reactive_state.on_destroyed_power_sound_state(headless, power, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

static func generated_after_destroyed_bridge_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	return source_building_destruction_generated_state.generated_after_destroyed_bridge_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id)

static func generated_explosion_item_cap_bridge_state(item_capacity: int) -> Dictionary:
	return source_building_destruction_generated_state.generated_explosion_item_cap_bridge_state(item_capacity)

static func generated_splash_liquid_bridge_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_splash_liquid_bridge_state(liquid, amount, source_block_size, source_tilesize)

static func generated_splash_liquid_source_tilesize_default_bridge_state(liquid: Variant, amount: float, source_block_size: int) -> Dictionary:
	return source_building_destruction_generated_state.generated_splash_liquid_source_tilesize_default_bridge_state(liquid, amount, source_block_size)

static func generated_splash_liquid_source_block_size_default_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_splash_liquid_source_block_size_default_bridge_state(liquid, amount)

static func generated_on_deconstructed_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_deconstructed_bridge_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size)

static func generated_on_deconstructed_source_block_size_default_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_deconstructed_source_block_size_default_bridge_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid)

static func generated_on_destroyed_item_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_item_explosion_bridge_state(base_explosiveness, has_items, item_states, item_cap)

static func generated_on_destroyed_liquid_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_liquid_explosion_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states)

static func generated_on_destroyed_buffered_power_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_buffered_power_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity)

static func generated_on_destroyed_splash_liquid_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_splash_liquid_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions)

static func generated_on_destroyed_dynamic_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_dynamic_explosion_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake)

static func generated_on_destroyed_dynamic_explosion_source_tilesize_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_dynamic_explosion_source_tilesize_default_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale)

static func generated_on_destroyed_source_block_size_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_source_block_size_default_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize)

static func generated_on_destroyed_rubble_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_rubble_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid)

static func generated_on_destroyed_base_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_base_sound_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

static func generated_on_destroyed_reactive_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_reactive_sound_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

static func generated_on_destroyed_power_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_on_destroyed_power_sound_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

static func generated_play_destroy_sound_bridge_state(destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_generated_state.generated_play_destroy_sound_bridge_state(destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
