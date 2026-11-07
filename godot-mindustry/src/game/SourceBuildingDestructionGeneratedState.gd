extends RefCounted
class_name SourceBuildingDestructionGeneratedState

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_building_destruction_reactive_state := preload("res://src/game/SourceBuildingDestructionReactiveState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_building_destruction_source_text_state := preload("res://src/game/SourceBuildingDestructionSourceTextState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_DESTRUCTION_AFTER_DESTROYED_JAVA_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_AFTER_DESTROYED_JAVA_METHOD
const SOURCE_BUILDING_DESTRUCTION_EXPLOSION_ITEM_CAP_JAVA_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_EXPLOSION_ITEM_CAP_JAVA_METHOD
const SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_JAVA_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_JAVA_METHOD
const SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_JAVA_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_JAVA_METHOD
const SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD
const SOURCE_BUILDING_DESTRUCTION_PLAY_DESTROY_SOUND_JAVA_METHOD := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_PLAY_DESTROY_SOUND_JAVA_METHOD
const SOURCE_BUILDING_DESTRUCTION_AFTER_DESTROYED_GENERATED_OWNER := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_AFTER_DESTROYED_GENERATED_OWNER
const SOURCE_BUILDING_DESTRUCTION_EXPLOSION_ITEM_CAP_GENERATED_OWNER := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_EXPLOSION_ITEM_CAP_GENERATED_OWNER
const SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_GENERATED_OWNER := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_GENERATED_OWNER
const SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_GENERATED_OWNER := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_GENERATED_OWNER
const SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER
const SOURCE_BUILDING_DESTRUCTION_PLAY_DESTROY_SOUND_GENERATED_OWNER := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_PLAY_DESTROY_SOUND_GENERATED_OWNER
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_RUBBLE_SOURCE_OWNER_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_RUBBLE_SOURCE_OWNER_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_DEFAULTED_ARG_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_DEFAULTED_ARG_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_BLOCK_SIZE_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_BLOCK_SIZE_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_TILESIZE_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_TILESIZE_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_MATCHES_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_MATCHES_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_SPLASH_CANONICAL_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_SPLASH_CANONICAL_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_DYNAMIC_EXPLOSION_CANONICAL_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_DYNAMIC_EXPLOSION_CANONICAL_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_RUBBLE_CANONICAL_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_RUBBLE_CANONICAL_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_BASE_SOUND_CANONICAL_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_BASE_SOUND_CANONICAL_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_REACTIVE_SOUND_CANONICAL_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_REACTIVE_SOUND_CANONICAL_KEY
const SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY := source_building_destruction_source_text_state.SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)
static func generated_after_destroyed_bridge_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_AFTER_DESTROYED_JAVA_METHOD, [has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id])
	var canonical = source_building_destruction_reactive_state.after_destroyed_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id, Callable(source_building_destruction_reactive_state, "_random_seed_float_max"))
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_AFTER_DESTROYED_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_AFTER_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_explosion_item_cap_bridge_state(item_capacity: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_EXPLOSION_ITEM_CAP_JAVA_METHOD, [item_capacity])
	var canonical = source_building_destruction_reactive_state.explosion_item_cap_state(item_capacity)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_EXPLOSION_ITEM_CAP_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_EXPLOSION_ITEM_CAP_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_splash_liquid_bridge_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_JAVA_METHOD, [liquid, amount, source_block_size, source_tilesize])
	var canonical = source_building_destruction_reactive_state.splash_liquid_state(liquid, amount, source_block_size, source_tilesize)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SPLASH_LIQUID_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_splash_liquid_source_tilesize_default_bridge_state(liquid: Variant, amount: float, source_block_size: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_JAVA_METHOD, [liquid, amount, source_block_size])
	var canonical = source_building_destruction_reactive_state.splash_liquid_state(liquid, amount, source_block_size, source_world_defaults.TILESIZE)
	var matches := source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SPLASH_LIQUID_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DEFAULTED_ARG_KEY: "source_tilesize",
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_TILESIZE_KEY: source_world_defaults.TILESIZE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_MATCHES_KEY: matches,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_splash_liquid_source_block_size_default_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_JAVA_METHOD, [liquid, amount])
	var canonical = source_building_destruction_reactive_state.splash_liquid_state(liquid, amount, source_block_defaults.SIZE_DEFAULT, source_world_defaults.TILESIZE)
	var matches := source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SPLASH_LIQUID_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_SPLASH_LIQUID_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DEFAULTED_ARG_KEY: "source_block_size",
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_BLOCK_SIZE_KEY: source_block_defaults.SIZE_DEFAULT,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_TILESIZE_KEY: source_world_defaults.TILESIZE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_MATCHES_KEY: matches,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_deconstructed_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_JAVA_METHOD, [has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size])
	var canonical = source_building_destruction_reactive_state.on_deconstructed_liquid_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DECONSTRUCTED_LIQUID_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_deconstructed_source_block_size_default_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_JAVA_METHOD, [has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid])
	var canonical = source_building_destruction_reactive_state.on_deconstructed_liquid_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_defaults.SIZE_DEFAULT)
	var on_deconstructed_matches = result.get("source_block_size", null) == canonical.get("source_block_size", null) \
		and result.get("can_drop_liquid", null) == canonical.get("can_drop_liquid", null) \
		and result.get("deposit_linked_tiles", null) == canonical.get("deposit_linked_tiles", null) \
		and result.get("per_cell", null) == canonical.get("per_cell", null) \
		and result.get("deposit_call", null) == canonical.get("deposit_call", null)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DECONSTRUCTED_LIQUID_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DECONSTRUCTED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DEFAULTED_ARG_KEY: "source_block_size",
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_BLOCK_SIZE_KEY: source_block_defaults.SIZE_DEFAULT,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_MATCHES_KEY: on_deconstructed_matches,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_item_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap])
	var canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_ITEM_EXPLOSION_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_liquid_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_LIQUID_EXPLOSION_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_buffered_power_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var canonical = source_building_destruction_reactive_state.on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BUFFERED_POWER_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY: liquid_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_splash_liquid_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = source_building_destruction_reactive_state.on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var canonical = source_building_destruction_reactive_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_SPLASH_LIQUID_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY: liquid_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY: buffered_power_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_dynamic_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = source_building_destruction_reactive_state.on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = source_building_destruction_reactive_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var canonical = source_building_destruction_reactive_state.on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY: liquid_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY: buffered_power_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SPLASH_CANONICAL_KEY: splash_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_dynamic_explosion_source_tilesize_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = source_building_destruction_reactive_state.on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = source_building_destruction_reactive_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var canonical = source_building_destruction_reactive_state.on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_world_defaults.TILESIZE, source_block_defaults.SIZE_DEFAULT, damage_explosions, "", 0.0)
	var dynamic_explosion_matches = result.get("dynamic_explosion_x", null) == canonical.get("x", null) \
		and result.get("dynamic_explosion_y", null) == canonical.get("y", null) \
		and result.get("dynamic_explosion_flammability", null) == canonical.get("flammability", null) \
		and result.get("dynamic_explosion_explosiveness", null) == canonical.get("explosiveness", null) \
		and result.get("dynamic_explosion_power", null) == canonical.get("power", null) \
		and result.get("dynamic_explosion_radius", null) == canonical.get("radius", null) \
		and result.get("dynamic_explosion_damage_explosions", null) == canonical.get("damage_explosions", null) \
		and result.get("dynamic_explosion_effect", null) == canonical.get("effect", null) \
		and result.get("dynamic_explosion_shake", null) == canonical.get("shake", null)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DEFAULTED_ARG_KEY: "source_tilesize",
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_TILESIZE_KEY: source_world_defaults.TILESIZE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_BLOCK_SIZE_KEY: source_block_defaults.SIZE_DEFAULT,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_MATCHES_KEY: dynamic_explosion_matches,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY: liquid_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY: buffered_power_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SPLASH_CANONICAL_KEY: splash_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_source_block_size_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = source_building_destruction_reactive_state.on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = source_building_destruction_reactive_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = source_building_destruction_reactive_state.on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_defaults.SIZE_DEFAULT, damage_explosions, "", 0.0)
	var on_destroyed_matches = result.get("dynamic_explosion_radius", null) == dynamic_explosion_canonical.get("radius", null)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_DYNAMIC_EXPLOSION_CALL_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RUBBLE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_RUBBLE_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DEFAULTED_ARG_KEY: "source_block_size",
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_BLOCK_SIZE_KEY: source_block_defaults.SIZE_DEFAULT,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_MATCHES_KEY: on_destroyed_matches,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY: liquid_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY: buffered_power_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SPLASH_CANONICAL_KEY: splash_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DYNAMIC_EXPLOSION_CANONICAL_KEY: dynamic_explosion_canonical,
	}

static func generated_on_destroyed_rubble_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = source_building_destruction_reactive_state.on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = source_building_destruction_reactive_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = source_building_destruction_reactive_state.on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	var canonical = source_building_destruction_reactive_state.on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_RUBBLE_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY: liquid_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY: buffered_power_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SPLASH_CANONICAL_KEY: splash_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DYNAMIC_EXPLOSION_CANONICAL_KEY: dynamic_explosion_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_base_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = source_building_destruction_reactive_state.on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = source_building_destruction_reactive_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = source_building_destruction_reactive_state.on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	var rubble_canonical = source_building_destruction_reactive_state.on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)
	var canonical = source_building_destruction_reactive_state.on_destroyed_base_sound_state(headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BASE_SOUND_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY: liquid_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY: buffered_power_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SPLASH_CANONICAL_KEY: splash_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DYNAMIC_EXPLOSION_CANONICAL_KEY: dynamic_explosion_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RUBBLE_CANONICAL_KEY: rubble_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_reactive_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = source_building_destruction_reactive_state.on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = source_building_destruction_reactive_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = source_building_destruction_reactive_state.on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	var rubble_canonical = source_building_destruction_reactive_state.on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)
	var base_sound_canonical = source_building_destruction_reactive_state.on_destroyed_base_sound_state(headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	var canonical = source_building_destruction_reactive_state.on_destroyed_reactive_sound_state(headless, float(liquid_canonical["explosiveness"]), float(liquid_canonical["flammability"]), destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_REACTIVE_SOUND_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY: liquid_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY: buffered_power_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SPLASH_CANONICAL_KEY: splash_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DYNAMIC_EXPLOSION_CANONICAL_KEY: dynamic_explosion_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RUBBLE_CANONICAL_KEY: rubble_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BASE_SOUND_CANONICAL_KEY: base_sound_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_on_destroyed_power_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_JAVA_METHOD, [base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume])
	var item_canonical = source_building_destruction_reactive_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)
	var liquid_canonical = source_building_destruction_reactive_state.on_destroyed_liquid_explosion_state(float(item_canonical["explosiveness"]), float(item_canonical["flammability"]), has_liquids, liquid_states)
	var buffered_power_canonical = source_building_destruction_reactive_state.on_destroyed_buffered_power_state(float(item_canonical["power"]), has_cons_power, cons_power_buffered, power_status, cons_power_capacity)
	var splash_canonical = source_building_destruction_reactive_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)
	var dynamic_explosion_canonical = source_building_destruction_reactive_state.on_destroyed_dynamic_explosion_call_state(source_x, source_y, float(liquid_canonical["flammability"]), float(liquid_canonical["explosiveness"]), float(buffered_power_canonical["power"]), flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)
	var rubble_canonical = source_building_destruction_reactive_state.on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)
	var base_sound_canonical = source_building_destruction_reactive_state.on_destroyed_base_sound_state(headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	var reactive_sound_canonical = source_building_destruction_reactive_state.on_destroyed_reactive_sound_state(headless, float(liquid_canonical["explosiveness"]), float(liquid_canonical["flammability"]), destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	var canonical = source_building_destruction_reactive_state.on_destroyed_power_sound_state(headless, float(buffered_power_canonical["power"]), destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_POWER_SOUND_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_ON_DESTROYED_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_ITEM_CANONICAL_KEY: item_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_LIQUID_CANONICAL_KEY: liquid_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BUFFERED_POWER_CANONICAL_KEY: buffered_power_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SPLASH_CANONICAL_KEY: splash_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_DYNAMIC_EXPLOSION_CANONICAL_KEY: dynamic_explosion_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RUBBLE_CANONICAL_KEY: rubble_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_BASE_SOUND_CANONICAL_KEY: base_sound_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_REACTIVE_SOUND_CANONICAL_KEY: reactive_sound_canonical,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}

static func generated_play_destroy_sound_bridge_state(destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESTRUCTION_PLAY_DESTROY_SOUND_JAVA_METHOD, [destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume])
	var canonical = source_building_destruction_reactive_state.on_destroyed_base_sound_state(false, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
	return {
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_DESTROYED_BASE_SOUND_STATE,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_GENERATED_OWNER_KEY: SOURCE_BUILDING_DESTRUCTION_PLAY_DESTROY_SOUND_GENERATED_OWNER,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_RESULT_KEY: result,
		SOURCE_BUILDING_DESTRUCTION_BRIDGE_CANONICAL_KEY: canonical,
	}
