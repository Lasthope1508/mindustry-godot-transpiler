extends RefCounted
class_name SourceUnitDestroyEffectsState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_unit_destroy_source_text_state := preload("res://src/game/SourceUnitDestroySourceTextState.gd")
const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")

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

const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_COMMENT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_COMMENT
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_GUARD
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_EXPLOSIVENESS := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_EXPLOSIVENESS
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_FLAMMABILITY := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_FLAMMABILITY
const SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_POWER := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_INITIAL_PAYLOAD_POWER

const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_GUARD
const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_DYNAMIC_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_DYNAMIC_CALL
const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_ELSE := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_ELSE
const SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_CORE_EFFECT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_EXPLOSION_DISPATCH_CORE_EFFECT

const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SHAKE_FORMULA := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SHAKE_FORMULA
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SCORCH_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SCORCH_GUARD
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SCORCH_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SCORCH_CALL
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SHAKE_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_SHAKE_CALL
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_DEATH_SHAKE_DEFAULT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_DEATH_SHAKE_DEFAULT
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_CREATE_SCORCH_DEFAULT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_CREATE_SCORCH_DEFAULT
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_HIT_SIZE_DEFAULT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_HIT_SIZE_DEFAULT
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SHAKE_POSITION := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SHAKE_POSITION
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SHAKE_POSITION_BODY := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SHAKE_POSITION_BODY
const SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SCORCH_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_VISUAL_EFFECTS_EFFECT_SCORCH_METHOD

const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_CALL
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENT_CALL := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENT_CALL
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_AT_POSITION := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_AT_POSITION
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_AT_POSITION_BODY := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_SOUND_AT_POSITION_BODY
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENTS_FIRE := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENTS_FIRE
const SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENTS_FIRE_BODY := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SOUND_AND_EVENT_EVENTS_FIRE_BODY

const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_METHOD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_METHOD
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_GUARD := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_GUARD
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENT := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENT
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENTS_FIRE_ENUM := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENTS_FIRE_ENUM
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENTS_FIRE_ENUM_BODY := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_EVENTS_FIRE_ENUM_BODY
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_ENUM := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_ENUM
const SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_ENUM_MEMBER := source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_SUICIDE_BOMB_TRIGGER_ENUM_MEMBER

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
