extends RefCounted
class_name SourceUnitDestroyState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")

const SOURCE_UNIT_DESTROY_INITIAL_EXPLOSIVENESS_BASE := source_unit_defaults.DESTROY_INITIAL_EXPLOSIVENESS_BASE
const SOURCE_UNIT_DESTROY_INITIAL_EXPLOSIVENESS_MULTIPLIER := source_unit_defaults.DESTROY_INITIAL_EXPLOSIVENESS_MULTIPLIER
const SOURCE_UNIT_DESTROY_INITIAL_FLAMMABILITY_DIVISOR := source_unit_defaults.DESTROY_INITIAL_FLAMMABILITY_DIVISOR
const SOURCE_UNIT_DESTROY_INITIAL_POWER_EXPONENT := source_unit_defaults.DESTROY_INITIAL_POWER_EXPONENT
const SOURCE_UNIT_DESTROY_INITIAL_POWER_MULTIPLIER := source_unit_defaults.DESTROY_INITIAL_POWER_MULTIPLIER
const SOURCE_UNIT_DESTROY_EXPLOSION_LEG_LENGTH_DIVISOR := source_unit_defaults.DESTROY_EXPLOSION_LEG_LENGTH_DIVISOR
const SOURCE_UNIT_DESTROY_EXPLOSION_RADIUS_DIVISOR := source_unit_defaults.DESTROY_EXPLOSION_RADIUS_DIVISOR
const SOURCE_UNIT_DESTROY_EXPLOSION_CORE_ROTATION_DIVISOR := source_unit_defaults.DESTROY_EXPLOSION_CORE_ROTATION_DIVISOR
const SOURCE_UNIT_DESTROY_VISUAL_DEATH_SHAKE_BASE := source_unit_defaults.DESTROY_VISUAL_DEATH_SHAKE_BASE
const SOURCE_UNIT_DESTROY_VISUAL_DEATH_SHAKE_HIT_SIZE_DIVISOR := source_unit_defaults.DESTROY_VISUAL_DEATH_SHAKE_HIT_SIZE_DIVISOR
const SOURCE_UNIT_DESTROY_VISUAL_SCORCH_HIT_SIZE_DIVISOR := source_unit_defaults.DESTROY_VISUAL_SCORCH_HIT_SIZE_DIVISOR
const SOURCE_UNIT_DESTROY_SOUND_PITCH := source_unit_defaults.DESTROY_SOUND_PITCH
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_EXPLOSIVENESS_THRESHOLD := source_unit_defaults.DESTROY_SUICIDE_BOMB_EXPLOSIVENESS_THRESHOLD
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

const SOURCE_UNIT_REMOVE_METHOD := "@Override\n    public void remove(){"
const SOURCE_UNIT_REMOVE_UPDATE_COUNT := "team.data().updateCount(type, -1);"
const SOURCE_UNIT_REMOVE_CONTROLLER_REMOVED := "controller.removed(self());"
const SOURCE_UNIT_REMOVE_TRAIL_GUARD := "if(trail != null && trail.size() > 0){"
const SOURCE_UNIT_REMOVE_TRAIL_FADE := "Fx.trailFade.at(x, y, trail.width(), type.trailColor == null ? team.color : type.trailColor, trail.copy());"

const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_COMMENT := "/** Actually destroys the unit, removing it and creating explosions. **/"
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_GUARD := "if(!isAdded() || !killable()) return;"
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_EXPLOSIVENESS := "float explosiveness = 2f + item().explosiveness * stack().amount * 1.53f;"
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_FLAMMABILITY := "float flammability = item().flammability * stack().amount / 1.9f;"
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_POWER := "float power = item().charge * Mathf.pow(stack().amount, 1.11f) * 160f;"

const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_GUARD := "if(!spawnedByCore){"
const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_DYNAMIC_CALL := "Damage.dynamicExplosion(x, y, flammability, explosiveness, power, (bounds() + type.legLength/1.7f) / 2f, state.rules.damageExplosions && state.rules.unitCrashDamage(team) > 0, item().flammability > 1, team, type.deathExplosionEffect, 0f);"
const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_ELSE := "}else{"
const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_CORE_EFFECT := "type.deathExplosionEffect.at(x, y, bounds() / 2f / 8f);"

const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SHAKE_FORMULA := "float shake = type.deathShake < 0 ? 3f + hitSize / 3f : type.deathShake;"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SCORCH_GUARD := "if(type.createScorch){"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SCORCH_CALL := "Effect.scorch(x, y, (int)(hitSize / 5));"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SHAKE_CALL := "Effect.shake(shake, shake, this);"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_DEATH_SHAKE_DEFAULT := "deathShake = -1f,"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_CREATE_SCORCH_DEFAULT := "createScorch = true,"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_HIT_SIZE_DEFAULT := "hitSize = 6f,"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SHAKE_POSITION := "public static void shake(float intensity, float duration, Position loc){"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SHAKE_POSITION_BODY := "shake(intensity, duration, loc.getX(), loc.getY());"
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SCORCH_METHOD := "public static void scorch(float x, float y, int size){"

const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_CALL := "type.deathSound.at(this, 1f, type.deathSoundVolume);"
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENT_CALL := "Events.fire(new UnitDestroyEvent(self()));"
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_AT_POSITION := "public int at(Position pos, float pitch, float volume){"
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_AT_POSITION_BODY := "return at(pos.getX(), pos.getY(), pitch, volume);"
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENTS_FIRE := "public static <T> void fire(T type){"
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENTS_FIRE_BODY := "fire(type.getClass(), type);"

const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_GUARD := "if(explosiveness > 7f && (isLocal() || wasPlayer)){"
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENT := "Events.fire(Trigger.suicideBomb);"
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENTS_FIRE_ENUM := "public static <T extends Enum<T>> void fire(Enum<T> type){"
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENTS_FIRE_ENUM_BODY := "items[i].get(type);"
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_ENUM := "public enum Trigger{"
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_ENUM_MEMBER := "suicideBomb,"

const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_LOOP := "for(WeaponMount mount : mounts){"
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_GUARD := "if(mount.weapon.shootOnDeath && !(mount.weapon.bullet.killShooter && mount.totalShots > 0)){"
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_EFFECT_GUARD := "if(mount.weapon.shootOnDeathEffect != null && !hasTarget){"
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_ALLOW_EFFECTS := "mount.allowShootEffects = false;"
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_EFFECT_AT := "mount.weapon.shootOnDeathEffect.at(x, y, rotation);"
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_RELOAD := "mount.reload = 0f;"
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_SHOOT := "mount.shoot = true;"
const SOURCE_UNIT_DESTROY_SHOOT_ON_DEATH_MOUNTS_UPDATE := "mount.weapon.update(self(), mount);"

const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_COMMENT := "//if this unit crash landed (was flying), damage stuff in a radius"
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_GUARD := "if(type.flying && !spawnedByCore && type.createWreck && state.rules.unitCrashDamage(team) > 0){"
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_SHIELD_LOOKUP := "var shields = indexer.getEnemy(team, BlockFlag.shield);"
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_FORMULA := "float crashDamage = Mathf.pow(hitSize, 0.75f) * type.crashDamageMultiplier * 2.5f * state.rules.unitCrashDamage(team);"
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_SHIELD_GUARD := "if(shields.isEmpty() || !shields.contains(b -> b instanceof ExplosionShield s && s.absorbExplosion(x, y, crashDamage))){"
const SOURCE_UNIT_DESTROY_CRASH_LANDING_DAMAGE_CALL := "Damage.damage(team, x, y, Mathf.pow(hitSize, 0.94f) * 1.25f, crashDamage, true, false, true);"

const SOURCE_UNIT_DESTROY_WRECK_DECAL_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_WRECK_DECAL_GUARD := "if(!headless && type.createScorch){"
const SOURCE_UNIT_DESTROY_WRECK_DECAL_LOOP := "for(int i = 0; i < type.wreckRegions.length; i++){"
const SOURCE_UNIT_DESTROY_WRECK_DECAL_FOUND_GUARD := "if(type.wreckRegions[i].found()){"
const SOURCE_UNIT_DESTROY_WRECK_DECAL_RANGE_FORMULA := "float range = type.hitSize /4f;"
const SOURCE_UNIT_DESTROY_WRECK_DECAL_RANDOM_CALL := "Tmp.v1.rnd(range);"
const SOURCE_UNIT_DESTROY_WRECK_DECAL_DECAL_CALL := "Effect.decal(type.wreckRegions[i], x + Tmp.v1.x, y + Tmp.v1.y, rotation - 90);"

const SOURCE_UNIT_DESTROY_ABILITY_DEATH_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_IMPORT := "import mindustry.entities.abilities.*;"
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_FIELD := "Ability[] abilities = {};"
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_LOOP := "for(Ability a : abilities){"
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_CALL := "a.death(self());"
const SOURCE_UNIT_DESTROY_ABILITY_DEATH_DEFAULT := "public void death(Unit unit){}"

const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_METHOD := "public void destroy(){"
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_TYPE_KILLED := "type.killed(self());"
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_REMOVE := "remove();"
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_UNIT_TYPE_DEFAULT := "public void killed(Unit unit){}"
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_REMOVE_OVERRIDE := "public void remove(){"
const SOURCE_UNIT_DESTROY_TYPE_KILLED_REMOVE_SELF_METHOD := "<T extends Entityc> T self(){"

const SOURCE_UNIT_KILLED_METHOD := "public void killed(){"
const SOURCE_UNIT_KILLED_WAS_PLAYER := "wasPlayer = isLocal();"
const SOURCE_UNIT_KILLED_HEALTH_CLAMP := "health = Math.min(health, 0);"
const SOURCE_UNIT_KILLED_DEAD_ASSIGNMENT := "dead = true;"
const SOURCE_UNIT_KILLED_DESTROY_GUARD := "if(!type.flying || !type.createWreck){"
const SOURCE_UNIT_KILLED_DESTROY_CALL := "destroy();"
const SOURCE_UNIT_KILLED_WRECK_SOUND_CALL := "type.wreckSound.at(this, 1f, type.wreckSoundVolume);"

const SOURCE_UNIT_KILL_SYNC_METHOD := "@Replace\n    public void kill(){"
const SOURCE_UNIT_KILL_SYNC_GUARD := "if(dead || net.client() || !killable()) return;"
const SOURCE_UNIT_KILL_SYNC_CALL := "Call.unitDeath(id);"

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
	var should_return := (not is_added_value) or (not killable_value)
	var explosiveness := 0.0
	var flammability := 0.0
	var power := 0.0
	if not should_return:
		explosiveness = SOURCE_UNIT_DESTROY_INITIAL_EXPLOSIVENESS_BASE + item_explosiveness * float(stack_amount) * SOURCE_UNIT_DESTROY_INITIAL_EXPLOSIVENESS_MULTIPLIER
		flammability = item_flammability * float(stack_amount) / SOURCE_UNIT_DESTROY_INITIAL_FLAMMABILITY_DIVISOR
		power = item_charge * pow(float(stack_amount), SOURCE_UNIT_DESTROY_INITIAL_POWER_EXPONENT) * SOURCE_UNIT_DESTROY_INITIAL_POWER_MULTIPLIER
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_STATE,
		"method": SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_METHOD,
		"comment": SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_COMMENT,
		"sourceGuard": SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_GUARD,
		"explosivenessFormula": SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_EXPLOSIVENESS,
		"flammabilityFormula": SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_FLAMMABILITY,
		"powerFormula": SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_POWER,
		"returnGuard": should_return,
		"explosiveness": explosiveness,
		"flammability": flammability,
		"power": power,
	}

static func explosion_dispatch_state(spawned_by_core_value: bool, source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, bounds_value: float, type_leg_length: float, rules_damage_explosions: bool, rules_unit_crash_damage: float, item_flammability: float, team_id: int, death_explosion_effect: String) -> Dictionary:
	var dispatch: Dictionary
	if not spawned_by_core_value:
		dispatch = {
			"call": "Damage.dynamicExplosion",
			"sourceCall": SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_DYNAMIC_CALL,
			"x": source_x,
			"y": source_y,
			"flammability": flammability,
			"explosiveness": explosiveness,
			"power": power,
			"radius": (bounds_value + type_leg_length / SOURCE_UNIT_DESTROY_EXPLOSION_LEG_LENGTH_DIVISOR) / SOURCE_UNIT_DESTROY_EXPLOSION_RADIUS_DIVISOR,
			"damage": rules_damage_explosions and rules_unit_crash_damage > 0.0,
			"fire": item_flammability > 1.0,
			"team": team_id,
			"explosionFx": death_explosion_effect,
			"baseShake": 0.0,
		}
	else:
		dispatch = {
			"call": "type.deathExplosionEffect.at",
			"sourceCall": SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_CORE_EFFECT,
			"x": source_x,
			"y": source_y,
			"rotation": bounds_value / SOURCE_UNIT_DESTROY_EXPLOSION_RADIUS_DIVISOR / SOURCE_UNIT_DESTROY_EXPLOSION_CORE_ROTATION_DIVISOR,
			"explosionFx": death_explosion_effect,
		}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_STATE,
		"method": SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_METHOD,
		"guard": SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_GUARD,
		"else": SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_ELSE,
		"dispatch": dispatch,
	}

static func visual_effects_state(source_x: float, source_y: float, hit_size: float, type_death_shake: float, type_create_scorch: bool, unit_id: int) -> Dictionary:
	var shake := SOURCE_UNIT_DESTROY_VISUAL_DEATH_SHAKE_BASE + hit_size / SOURCE_UNIT_DESTROY_VISUAL_DEATH_SHAKE_HIT_SIZE_DIVISOR if type_death_shake < 0.0 else type_death_shake
	var scorch_call: Variant = null
	if type_create_scorch:
		scorch_call = {"call": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SCORCH_CALL, "x": source_x, "y": source_y, "size": int(hit_size / SOURCE_UNIT_DESTROY_VISUAL_SCORCH_HIT_SIZE_DIVISOR)}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_STATE,
		"method": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_METHOD,
		"shakeFormula": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SHAKE_FORMULA,
		"scorchGuard": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SCORCH_GUARD,
		"scorchCall": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SCORCH_CALL,
		"scorch": scorch_call,
		"size": int(hit_size / SOURCE_UNIT_DESTROY_VISUAL_SCORCH_HIT_SIZE_DIVISOR),
		"shakeCall": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SHAKE_CALL,
		"deathShakeDefault": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_DEATH_SHAKE_DEFAULT,
		"createScorchDefault": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_CREATE_SCORCH_DEFAULT,
		"hitSizeDefault": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_HIT_SIZE_DEFAULT,
		"effectShakePosition": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SHAKE_POSITION,
		"effectShakePositionBody": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SHAKE_POSITION_BODY,
		"effectScorchMethod": SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SCORCH_METHOD,
		"intensity": shake,
		"duration": shake,
		"unit": unit_id,
	}

static func sound_and_event_state(death_sound: String, death_sound_volume: float, unit_id: int) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_STATE,
		"method": SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_METHOD,
		"call": SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_CALL,
		"sourcePositionOverload": SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_AT_POSITION,
		"sourcePositionBody": SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_AT_POSITION_BODY,
		"sound": death_sound,
		"pitch": SOURCE_UNIT_DESTROY_SOUND_PITCH,
		"volume": death_sound_volume,
		"event": SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENT_CALL,
		"eventsFire": SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENTS_FIRE,
		"eventsFireBody": SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENTS_FIRE_BODY,
		"eventClass": "UnitDestroyEvent",
		"unit": unit_id,
	}

static func suicide_bomb_trigger_state(explosiveness: float, is_local_value: bool, was_player_value: bool) -> Dictionary:
	var trigger := explosiveness > SOURCE_UNIT_DESTROY_SUICIDE_BOMB_EXPLOSIVENESS_THRESHOLD and (is_local_value or was_player_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_STATE,
		"method": SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_METHOD,
		"guard": SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_GUARD,
		"trigger": trigger,
		"event": SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENT if trigger else "",
		"eventsFire": SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENTS_FIRE_ENUM,
		"eventsFireBody": SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENTS_FIRE_ENUM_BODY,
		"triggerEnum": SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_ENUM,
		"triggerMember": SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_ENUM_MEMBER,
	}

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
		"guard": "dead || net.client() || !killable()",
		"returnGuard": should_return,
		"sourceCall": SOURCE_UNIT_KILL_SYNC_CALL,
		"call": "Call.unitDeath(id)",
		"remote": "@Remote(called = Loc.server)",
		"serverHandler": "unit.killed()",
		"unit": unit_id,
	}
