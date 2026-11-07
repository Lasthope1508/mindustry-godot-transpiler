extends RefCounted
class_name SourceUnitDestroyState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_unit_destroy_source_text_state := preload("res://src/game/SourceUnitDestroySourceTextState.gd")
const source_unit_destroy_effects_state := preload("res://src/game/SourceUnitDestroyEffectsState.gd")
const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")

const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_TOTAL_SHOTS_THRESHOLD := source_unit_defaults.DESTROY_SHOOT_ON_DEATH_TOTAL_SHOTS_THRESHOLD
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_RELOAD_RESET := source_unit_defaults.DESTROY_SHOOT_ON_DEATH_RELOAD_RESET
const SOURCE_WEAPON_SHOOT_ON_DEATH_DEFAULT := source_weapon_defaults.SHOOT_ON_DEATH_DEFAULT
const SOURCE_UNIT_CRASH_DAMAGE_HIT_SIZE_EXPONENT := source_unit_defaults.CRASH_DAMAGE_HIT_SIZE_EXPONENT
const SOURCE_UNIT_CRASH_DAMAGE_MULTIPLIER := source_unit_defaults.CRASH_DAMAGE_MULTIPLIER
const SOURCE_UNIT_CRASH_DAMAGE_RADIUS_EXPONENT := source_unit_defaults.CRASH_DAMAGE_RADIUS_EXPONENT
const SOURCE_UNIT_CRASH_DAMAGE_RADIUS_MULTIPLIER := source_unit_defaults.CRASH_DAMAGE_RADIUS_MULTIPLIER
const SOURCE_UNIT_DESTROY_WRECK_DECAL_RANGE_DIVISOR := source_unit_defaults.WRECK_DECAL_RANGE_DIVISOR
const SOURCE_UNIT_DESTROY_WRECK_DECAL_ROTATION_OFFSET := source_unit_defaults.WRECK_DECAL_ROTATION_OFFSET
const SOURCE_UNIT_KILLED_HEALTH_CLAMP_MAX := source_unit_defaults.KILLED_HEALTH_CLAMP_MAX
const SOURCE_UNIT_KILLED_WRECK_SOUND_PITCH := source_unit_defaults.KILLED_WRECK_SOUND_PITCH

const SOURCE_UNIT_REMOVE_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_REMOVE_METHOD
const SOURCE_UNIT_REMOVE_UPDATE_COUNT := source_unit_destroy_source_text_state.SOURCE_UNIT_REMOVE_UPDATE_COUNT
const SOURCE_UNIT_REMOVE_CONTROLLER_REMOVED := source_unit_destroy_source_text_state.SOURCE_UNIT_REMOVE_CONTROLLER_REMOVED
const SOURCE_UNIT_REMOVE_TRAIL_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_REMOVE_TRAIL_GUARD
const SOURCE_UNIT_REMOVE_TRAIL_FADE := source_unit_destroy_source_text_state.SOURCE_UNIT_REMOVE_TRAIL_FADE

const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_LOOP := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_LOOP
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_GUARD
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_EFFECT_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_EFFECT_GUARD
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_ALLOW_EFFECTS := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_ALLOW_EFFECTS
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_EFFECT_AT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_EFFECT_AT
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_RELOAD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_RELOAD
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_SHOOT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_SHOOT
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_UPDATE := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_UPDATE

const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_COMMENT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_COMMENT
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_GUARD
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_SHIELD_LOOKUP := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_SHIELD_LOOKUP
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_FORMULA := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_FORMULA
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_SHIELD_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_SHIELD_GUARD
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_CALL

const SOURCE_UNIT_DESTROY_WRECK_DECAL_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_WRECK_DECAL_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_WRECK_DECAL_GUARD
const SOURCE_UNIT_DESTROY_WRECK_DECAL_LOOP := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_WRECK_DECAL_LOOP
const SOURCE_UNIT_DESTROY_WRECK_DECAL_FOUND_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_WRECK_DECAL_FOUND_GUARD
const SOURCE_UNIT_DESTROY_WRECK_DECAL_RANGE_FORMULA := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_WRECK_DECAL_RANGE_FORMULA
const SOURCE_UNIT_DESTROY_WRECK_DECAL_RANDOM_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_WRECK_DECAL_RANDOM_CALL
const SOURCE_UNIT_DESTROY_WRECK_DECAL_DECAL_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_WRECK_DECAL_DECAL_CALL

const SOURCE_UNIT_DESTROY_ABILITY_DEATH_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_IMPORT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_ABILITY_DEATH_IMPORT
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_FIELD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_ABILITY_DEATH_FIELD
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_LOOP := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_ABILITY_DEATH_LOOP
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_ABILITY_DEATH_CALL
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_DEFAULT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_ABILITY_DEATH_DEFAULT

const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_TYPE_KILLED := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_TYPE_KILLED
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_REMOVE := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_REMOVE
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_UNIT_TYPE_DEFAULT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_UNIT_TYPE_DEFAULT
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_REMOVE_OVERRIDE := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_REMOVE_OVERRIDE
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_SELF_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_SELF_METHOD

const SOURCE_UNIT_KILLED_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_METHOD
const SOURCE_UNIT_KILLED_WAS_PLAYER := source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_WAS_PLAYER
const SOURCE_UNIT_KILLED_HEALTH_CLAMP := source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_HEALTH_CLAMP
const SOURCE_UNIT_KILLED_DEAD_ASSIGNMENT := source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_DEAD_ASSIGNMENT
const SOURCE_UNIT_KILLED_DESTROY_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_DESTROY_GUARD
const SOURCE_UNIT_KILLED_DESTROY_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_DESTROY_CALL
const SOURCE_UNIT_KILLED_WRECK_SOUND_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_WRECK_SOUND_CALL

const SOURCE_UNIT_KILL_SYNC_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_METHOD
const SOURCE_UNIT_KILL_SYNC_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_GUARD
const SOURCE_UNIT_KILL_SYNC_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_CALL
const SOURCE_UNIT_KILL_SYNC_GUARD_EXPR := source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_GUARD_EXPR
const SOURCE_UNIT_KILL_SYNC_CALL_EXPR := source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_CALL_EXPR
const SOURCE_UNIT_KILL_SYNC_REMOTE := source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_REMOTE
const SOURCE_UNIT_KILL_SYNC_SERVER_HANDLER := source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_SERVER_HANDLER

static func destroy_state(input_state: Dictionary) -> Dictionary:
	var initial := initial_payload_state(
		bool(input_state.get("is_added", false)),
		bool(input_state.get("killable", false)),
		float(input_state.get("item_explosiveness", 0.0)),
		float(input_state.get("item_flammability", 0.0)),
		float(input_state.get("item_charge", 0.0)),
		int(input_state.get("stack_amount", 0))
	)
	var phases: Array = ["initial_payload"]
	var states: Array = [initial]
	if bool(initial.get("returnGuard", false)):
		return {
			"source_owner": source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_GENERATED_OWNER,
			"method": source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD,
			"generated_method": source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_GENERATED_METHOD,
			"guard_returned": true,
			"phases": phases,
			"states": states,
		}
	var explosion := explosion_dispatch_state(
		bool(input_state.get("spawned_by_core", false)),
		float(input_state.get("x", 0.0)), float(input_state.get("y", 0.0)),
		float(initial.get("flammability", 0.0)), float(initial.get("explosiveness", 0.0)), float(initial.get("power", 0.0)),
		float(input_state.get("bounds", 0.0)), float(input_state.get("type_leg_length", 0.0)),
		bool(input_state.get("rules_damage_explosions", false)), float(input_state.get("rules_unit_crash_damage", 0.0)),
		float(input_state.get("item_flammability", 0.0)), int(input_state.get("team", 0)), str(input_state.get("death_explosion_effect", ""))
	)
	var visual := visual_effects_state(float(input_state.get("x", 0.0)), float(input_state.get("y", 0.0)), float(input_state.get("hit_size", 0.0)), float(input_state.get("death_shake", -1.0)), bool(input_state.get("create_scorch", false)), int(input_state.get("unit_id", 0)))
	var sound := sound_and_event_state(str(input_state.get("death_sound", "")), float(input_state.get("death_sound_volume", 1.0)), int(input_state.get("unit_id", 0)))
	var suicide := suicide_bomb_trigger_state(float(initial.get("explosiveness", 0.0)), bool(input_state.get("is_local", false)), bool(input_state.get("was_player", false)))
	var mounts := shoot_on_death_mounts_state(input_state.get("mounts", []) as Array, bool(input_state.get("has_target", false)), float(input_state.get("x", 0.0)), float(input_state.get("y", 0.0)), float(input_state.get("rotation", 0.0)), int(input_state.get("unit_id", 0)))
	var crash := crash_landing_damage_state(bool(input_state.get("type_flying", false)), bool(input_state.get("spawned_by_core", false)), bool(input_state.get("create_wreck", false)), float(input_state.get("rules_unit_crash_damage", 0.0)), float(input_state.get("hit_size", 0.0)), float(input_state.get("crash_damage_multiplier", 1.0)), bool(input_state.get("shields_empty", true)), bool(input_state.get("shield_absorbed", false)), int(input_state.get("team", 0)), float(input_state.get("x", 0.0)), float(input_state.get("y", 0.0)))
	var wreck := wreck_decal_state(bool(input_state.get("headless", false)), bool(input_state.get("create_scorch", false)), input_state.get("wreck_regions", []) as Array, input_state.get("tmp_offsets", []) as Array, float(input_state.get("x", 0.0)), float(input_state.get("y", 0.0)), float(input_state.get("rotation", 0.0)), float(input_state.get("hit_size", 0.0)))
	var abilities := ability_death_state(input_state.get("abilities", []) as Array, int(input_state.get("unit_id", 0)))
	var tail := type_killed_remove_state(int(input_state.get("unit_id", 0)))
	phases.append_array(["explosion_dispatch", "visual_effects", "sound_and_event", "suicide_bomb_trigger", "shoot_on_death_mounts", "crash_landing_damage", "wreck_decal", "ability_death", "type_killed_remove"])
	states.append_array([explosion, visual, sound, suicide, mounts, crash, wreck, abilities, tail])
	return {
		"source_owner": source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_GENERATED_OWNER,
		"method": source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD,
		"generated_method": source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_GENERATED_METHOD,
		"guard_returned": false,
		"phases": phases,
		"states": states,
	}

static func remove_state(trail_exists: bool, trail_size: int, trail_width: float, type_trail_color_exists: bool, team_color: String, type_trail_color: String) -> Dictionary:
	var fade_trail := trail_exists and trail_size > 0
	var trail_color := type_trail_color if type_trail_color_exists else team_color
	var trail_fade_call: Variant = null
	if fade_trail:
		trail_fade_call = {
			"call": "Fx.trailFade.at",
			"width": trail_width,
			"color": trail_color,
			"rotationArg": "trail.width()",
			"dataArg": "trail.copy()",
			"source": SOURCE_UNIT_REMOVE_TRAIL_FADE,
		}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_REMOVE_STATE,
		"method": SOURCE_UNIT_REMOVE_METHOD,
		"updateCount": {"call": SOURCE_UNIT_REMOVE_UPDATE_COUNT, "amount": -1},
		"controllerRemoved": {"call": "controller.removed(self())", "arg": "self()"},
		"trailGuard": SOURCE_UNIT_REMOVE_TRAIL_GUARD,
		"trailFade": fade_trail,
		"trailFadeCall": trail_fade_call,
		"call_order": ["team.data().updateCount(-1)", "controller.removed", "Fx.trailFade.at"] if fade_trail else ["team.data().updateCount(-1)", "controller.removed"],
	}

static func initial_payload_state(is_added_value: bool, killable_value: bool, item_explosiveness: float, item_flammability: float, item_charge: float, stack_amount: int) -> Dictionary:
	return source_unit_destroy_effects_state.initial_payload_state(is_added_value, killable_value, item_explosiveness, item_flammability, item_charge, stack_amount)

static func explosion_dispatch_state(spawned_by_core_value: bool, source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, bounds_value: float, type_leg_length: float, rules_damage_explosions: bool, rules_unit_crash_damage: float, item_flammability: float, team_id: int, death_explosion_effect: String) -> Dictionary:
	return source_unit_destroy_effects_state.explosion_dispatch_state(spawned_by_core_value, source_x, source_y, flammability, explosiveness, power, bounds_value, type_leg_length, rules_damage_explosions, rules_unit_crash_damage, item_flammability, team_id, death_explosion_effect)

static func visual_effects_state(source_x: float, source_y: float, hit_size: float, type_death_shake: float, type_create_scorch: bool, unit_id: int) -> Dictionary:
	return source_unit_destroy_effects_state.visual_effects_state(source_x, source_y, hit_size, type_death_shake, type_create_scorch, unit_id)

static func sound_and_event_state(death_sound: String, death_sound_volume: float, unit_id: int) -> Dictionary:
	return source_unit_destroy_effects_state.sound_and_event_state(death_sound, death_sound_volume, unit_id)

static func suicide_bomb_trigger_state(explosiveness: float, is_local_value: bool, was_player_value: bool) -> Dictionary:
	return source_unit_destroy_effects_state.suicide_bomb_trigger_state(explosiveness, is_local_value, was_player_value)

static func shoot_on_death_mounts_state(mount_states: Array, has_target_value: bool, source_x: float, source_y: float, source_rotation_degrees: float, unit_id: int) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var shoot_on_death := bool(mount_state.get("shootOnDeath", SOURCE_WEAPON_SHOOT_ON_DEATH_DEFAULT))
		var bullet_kill_shooter := bool(mount_state.get("bulletKillShooter", false))
		var total_shots := int(mount_state.get("totalShots", 0))
		var should_update := shoot_on_death and not (bullet_kill_shooter and total_shots > SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_TOTAL_SHOTS_THRESHOLD)
		var shoot_on_death_effect_exists := bool(mount_state.get("shootOnDeathEffectExists", false))
		mounts.append({
			"index": index,
			"method": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_METHOD,
			"loop": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_LOOP,
			"guard": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_GUARD,
			"effectGuard": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_EFFECT_GUARD,
			"allowShootEffectsSource": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_ALLOW_EFFECTS,
			"effectCall": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_EFFECT_AT,
			"effect": shoot_on_death_effect_exists and not has_target_value and should_update,
			"x": source_x,
			"y": source_y,
			"rotation": source_rotation_degrees,
			"reload": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_RELOAD_RESET,
			"shoot": true,
			"reloadSource": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_RELOAD,
			"shootSource": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_SHOOT,
			"update": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_UPDATE,
			"shouldUpdate": should_update,
			"unit": unit_id,
		})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_STATE,
		"method": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_METHOD,
		"loop": SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_LOOP,
		"mounts": mounts,
		"unit": unit_id,
	}

static func crash_landing_damage_state(type_flying: bool, spawned_by_core_value: bool, type_create_wreck: bool, rules_unit_crash_damage: float, hit_size: float, type_crash_damage_multiplier: float, shields_empty: bool, shield_absorbed: bool, team_id: int, source_x: float, source_y: float) -> Dictionary:
	var should_check_crash := type_flying and not spawned_by_core_value and type_create_wreck and rules_unit_crash_damage > 0.0
	var crash_damage := pow(hit_size, SOURCE_UNIT_CRASH_DAMAGE_HIT_SIZE_EXPONENT) * type_crash_damage_multiplier * SOURCE_UNIT_CRASH_DAMAGE_MULTIPLIER * rules_unit_crash_damage
	var damage_radius := pow(hit_size, SOURCE_UNIT_CRASH_DAMAGE_RADIUS_EXPONENT) * SOURCE_UNIT_CRASH_DAMAGE_RADIUS_MULTIPLIER
	var shield_lookup: Variant = null
	var shield_guard: Variant = null
	var damage_call: Variant = null
	if should_check_crash:
		shield_lookup = SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_SHIELD_LOOKUP
		shield_guard = SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_SHIELD_GUARD
		if shields_empty or not shield_absorbed:
			damage_call = {"call": "Damage.damage", "team": team_id, "x": source_x, "y": source_y, "radius": damage_radius, "damage": crash_damage, "complete": true, "air": false, "ground": true}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_STATE,
		"method": SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_METHOD,
		"comment": SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_COMMENT,
		"guard": SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_GUARD,
		"shieldLookup": shield_lookup,
		"formula": SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_FORMULA,
		"shieldGuard": shield_guard,
		"damageCall": SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_CALL,
		"damage": damage_call,
		"crashDamage": crash_damage,
		"radius": damage_radius,
		"complete": true,
		"air": false,
		"ground": true,
	}

static func wreck_decal_state(headless_value: bool, type_create_scorch: bool, wreck_regions: Array, tmp_offsets: Array, source_x: float, source_y: float, source_rotation_degrees: float, type_hit_size: float) -> Dictionary:
	var should_create_decals := not headless_value and type_create_scorch
	var range_value := type_hit_size / SOURCE_UNIT_DESTROY_WRECK_DECAL_RANGE_DIVISOR
	var decal_rotation := source_rotation_degrees - SOURCE_UNIT_DESTROY_WRECK_DECAL_ROTATION_OFFSET
	var decals: Array = []
	if should_create_decals:
		for index in wreck_regions.size():
			var region_state: Dictionary = wreck_regions[index]
			if bool(region_state.get("found", false)):
				var offset: Variant = tmp_offsets[index] if index < tmp_offsets.size() else Vector2.ZERO
				var offset_x: float = offset.x if offset is Vector2 else float(offset.get("x", 0.0))
				var offset_y: float = offset.y if offset is Vector2 else float(offset.get("y", 0.0))
				decals.append({
					"index": index,
					"region": region_state,
					"x": source_x + offset_x,
					"y": source_y + offset_y,
					"rotation": decal_rotation,
					"range": range_value,
				})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_WRECK_DECAL_STATE,
		"method": SOURCE_UNIT_DESTROY_WRECK_DECAL_METHOD,
		"guard": SOURCE_UNIT_DESTROY_WRECK_DECAL_GUARD,
		"loop": SOURCE_UNIT_DESTROY_WRECK_DECAL_LOOP,
		"foundGuard": SOURCE_UNIT_DESTROY_WRECK_DECAL_FOUND_GUARD,
		"rangeFormula": SOURCE_UNIT_DESTROY_WRECK_DECAL_RANGE_FORMULA,
		"randomCall": SOURCE_UNIT_DESTROY_WRECK_DECAL_RANDOM_CALL,
		"decalCall": SOURCE_UNIT_DESTROY_WRECK_DECAL_DECAL_CALL,
		"rotation": decal_rotation,
		"range": range_value,
		"decals": decals,
	}

static func ability_death_state(ability_states: Array, unit_id: int) -> Dictionary:
	var calls: Array = []
	for index in ability_states.size():
		calls.append({"index": index, "call": SOURCE_UNIT_DESTROY_ABILITY_DEATH_CALL, "ability": ability_states[index], "unit": unit_id})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_ABILITY_DEATH_STATE,
		"method": SOURCE_UNIT_DESTROY_ABILITY_DEATH_METHOD,
		"import": SOURCE_UNIT_DESTROY_ABILITY_DEATH_IMPORT,
		"field": SOURCE_UNIT_DESTROY_ABILITY_DEATH_FIELD,
		"loop": SOURCE_UNIT_DESTROY_ABILITY_DEATH_LOOP,
		"call": SOURCE_UNIT_DESTROY_ABILITY_DEATH_CALL,
		"abilityDefault": SOURCE_UNIT_DESTROY_ABILITY_DEATH_DEFAULT,
		"calls": calls,
		"unit": unit_id,
	}

static func type_killed_remove_state(unit_id: int) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_STATE,
		"method": SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_METHOD,
		"typeKilled": {"call": SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_TYPE_KILLED},
		"unitTypeDefault": SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_UNIT_TYPE_DEFAULT,
		"remove": {"call": SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_REMOVE},
		"unitRemoveOverride": SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_REMOVE_OVERRIDE,
		"selfMethod": SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_SELF_METHOD,
		"unit": unit_id,
	}

static func killed_state(is_local_value: bool, current_health: float, type_flying: bool, type_create_wreck: bool, wreck_sound: String, wreck_sound_volume: float, unit_id: int) -> Dictionary:
	var should_destroy := not type_flying or not type_create_wreck
	var clamped_health: float = minf(current_health, SOURCE_UNIT_KILLED_HEALTH_CLAMP_MAX)
	var destroy_call: Variant = null
	if should_destroy:
		destroy_call = SOURCE_UNIT_KILLED_DESTROY_CALL
	var wreck_sound_call: Variant = null
	if not should_destroy:
		wreck_sound_call = {"call": SOURCE_UNIT_KILLED_WRECK_SOUND_CALL.trim_suffix(";"), "sound": wreck_sound, "pitch": SOURCE_UNIT_KILLED_WRECK_SOUND_PITCH, "volume": wreck_sound_volume}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_KILLED_STATE,
		"method": SOURCE_UNIT_KILLED_METHOD,
		"wasPlayerSource": SOURCE_UNIT_KILLED_WAS_PLAYER,
		"healthClampSource": SOURCE_UNIT_KILLED_HEALTH_CLAMP,
		"deadSource": SOURCE_UNIT_KILLED_DEAD_ASSIGNMENT,
		"wasPlayer": is_local_value,
		"health": clamped_health,
		"dead": true,
		"guard": SOURCE_UNIT_KILLED_DESTROY_GUARD,
		"destroyCall": destroy_call,
		"wreckSound": wreck_sound_call,
		"unit": unit_id,
	}

static func kill_sync_state(dead_value: bool, net_client: bool, killable_value: bool, unit_id: int) -> Dictionary:
	var should_return := dead_value or net_client or not killable_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_KILL_SYNC_STATE,
		"method": SOURCE_UNIT_KILL_SYNC_METHOD,
		"sourceGuard": SOURCE_UNIT_KILL_SYNC_GUARD,
		"guard": SOURCE_UNIT_KILL_SYNC_GUARD_EXPR,
		"returnGuard": should_return,
		"sourceCall": SOURCE_UNIT_KILL_SYNC_CALL,
		"call": SOURCE_UNIT_KILL_SYNC_CALL_EXPR,
		"remote": SOURCE_UNIT_KILL_SYNC_REMOTE,
		"serverHandler": SOURCE_UNIT_KILL_SYNC_SERVER_HANDLER,
		"unit": unit_id,
	}
