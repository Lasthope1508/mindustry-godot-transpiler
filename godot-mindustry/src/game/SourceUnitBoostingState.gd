extends RefCounted
class_name SourceUnitBoostingState

const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_unit_motion_state := preload("res://src/game/SourceUnitMotionState.gd")
const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")

const SOURCE_UNIT_FLYING_ELEVATION_MIN := source_unit_defaults.FLYING_ELEVATION_MIN
const SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_METHOD
const SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_CALL := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_CALL
const SOURCE_UNIT_UPDATE_BOOSTING_OVERLOAD_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_OVERLOAD_METHOD
const SOURCE_UNIT_UPDATE_BOOSTING_GUARD := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_GUARD
const SOURCE_UNIT_UPDATE_BOOSTING_SHOULD_BOOST := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_SHOULD_BOOST
const SOURCE_UNIT_UPDATE_BOOSTING_ELEVATION_ASSIGNMENT := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_ELEVATION_ASSIGNMENT
const SOURCE_ARC_MATHF_NUM_RETURN := source_unit_update_source_text_state.SOURCE_ARC_MATHF_NUM_RETURN
const SOURCE_ARC_MATHF_APPROACH_DELTA_METHOD := source_unit_update_source_text_state.SOURCE_ARC_MATHF_APPROACH_DELTA_METHOD
const SOURCE_ARC_MATHF_APPROACH_DELTA_RETURN := source_unit_update_source_text_state.SOURCE_ARC_MATHF_APPROACH_DELTA_RETURN
const SOURCE_ARC_MATHF_APPROACH_METHOD := source_unit_update_source_text_state.SOURCE_ARC_MATHF_APPROACH_METHOD
const SOURCE_ARC_MATHF_APPROACH_RETURN := source_unit_update_source_text_state.SOURCE_ARC_MATHF_APPROACH_RETURN
const SOURCE_ARC_MATHF_CLAMP_FLOAT_METHOD := source_unit_update_source_text_state.SOURCE_ARC_MATHF_CLAMP_FLOAT_METHOD
const SOURCE_ARC_MATHF_CLAMP_FLOAT_RETURN := source_unit_update_source_text_state.SOURCE_ARC_MATHF_CLAMP_FLOAT_RETURN
const SOURCE_UNIT_BOOSTING_TARGET_ELEVATION := source_unit_defaults.BOOSTING_TARGET_ELEVATION
const SOURCE_UNIT_BOOSTING_BASE_ELEVATION := source_unit_defaults.BOOSTING_BASE_ELEVATION
const SOURCE_UNIT_UPDATE_BOOSTING_EVENT_GATE := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_EVENT_GATE
const SOURCE_UNIT_UPDATE_BOOSTING_EVENT_FIRE_TRIGGER := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_EVENT_FIRE_TRIGGER
const SOURCE_EVENT_TYPE_TRIGGER_ENUM := source_unit_update_source_text_state.SOURCE_EVENT_TYPE_TRIGGER_ENUM
const SOURCE_EVENT_TYPE_UNIT_COMMAND_BOOST := source_unit_update_source_text_state.SOURCE_EVENT_TYPE_UNIT_COMMAND_BOOST
const SOURCE_UNIT_IS_FLYING_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_IS_FLYING_RETURN
const SOURCE_UNIT_LANDED_SHAKE_THRESHOLD := source_unit_defaults.LANDED_SHAKE_THRESHOLD
const SOURCE_UNIT_LANDED_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_LANDED_METHOD
const SOURCE_UNIT_LANDED_SHAKE_GUARD := source_unit_update_source_text_state.SOURCE_UNIT_LANDED_SHAKE_GUARD
const SOURCE_UNIT_LANDED_SHAKE_CALL := source_unit_update_source_text_state.SOURCE_UNIT_LANDED_SHAKE_CALL
const SOURCE_UNIT_LANDED_TYPE_CALL := source_unit_update_source_text_state.SOURCE_UNIT_LANDED_TYPE_CALL

static func is_flying(elevation_value: float) -> bool:
	return source_unit_motion_state.is_flying(elevation_value)

static func landed_state(type_mech_land_shake: float) -> Dictionary:
	var shake := type_mech_land_shake > SOURCE_UNIT_LANDED_SHAKE_THRESHOLD
	var shake_call: Variant = null
	if shake:
		shake_call = {
			"call": SOURCE_UNIT_LANDED_SHAKE_CALL.trim_suffix(";"),
			"intensity": type_mech_land_shake,
			"duration": type_mech_land_shake,
			"locArg": "this",
		}
	return {
		"shake": shake,
		"shakeCall": shake_call,
		"typeLanded": {"call": SOURCE_UNIT_LANDED_TYPE_CALL.trim_suffix(";"), "arg": "self()"},
		"call_order": ["Effect.shake", "type.landed"] if shake else ["type.landed"],
	}

static func boosting_default_event_state(boost: bool) -> Dictionary:
	return {
		"method": SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_METHOD,
		"delegateCall": SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_CALL,
		"overloadMethod": SOURCE_UNIT_UPDATE_BOOSTING_OVERLOAD_METHOD,
		"boost": boost,
		"event": false,
	}

static func boosting_guard_state(type_can_boost: bool, dead_state: bool, elevation_value: float) -> Dictionary:
	var returned: bool = (not type_can_boost) or dead_state
	return {
		"overloadMethod": SOURCE_UNIT_UPDATE_BOOSTING_OVERLOAD_METHOD,
		"guard": SOURCE_UNIT_UPDATE_BOOSTING_GUARD,
		"returned": returned,
		"can_update_boosting": not returned,
		"elevation": elevation_value,
	}

static func boosting_should_boost_state(boost: bool, on_solid_result: bool, elevation_value: float, can_land_result: bool) -> Dictionary:
	var flying: bool = is_flying(elevation_value)
	var should_boost: bool = boost or on_solid_result or (flying and not can_land_result)
	return {
		"shouldBoostSource": SOURCE_UNIT_UPDATE_BOOSTING_SHOULD_BOOST,
		"isFlyingReturn": SOURCE_UNIT_IS_FLYING_RETURN,
		"flying": flying,
		"should_boost": should_boost,
	}

static func boosting_elevation_state(current_elevation: float, type_can_boost: bool, should_boost: bool, type_rise_speed: float, type_descent_speed: float, source_delta: float) -> Dictionary:
	var target_elevation: float = SOURCE_UNIT_BOOSTING_TARGET_ELEVATION if should_boost else SOURCE_UNIT_BOOSTING_BASE_ELEVATION
	if not type_can_boost:
		target_elevation = SOURCE_UNIT_BOOSTING_BASE_ELEVATION
	var speed: float = type_rise_speed if should_boost else type_descent_speed
	var next_elevation: float = source_math_state.source_approach_delta(current_elevation, target_elevation, speed, source_delta)
	return {
		"elevationAssignment": SOURCE_UNIT_UPDATE_BOOSTING_ELEVATION_ASSIGNMENT,
		"target_elevation": target_elevation,
		"speed": speed,
		"elevation": next_elevation,
		"mathfNumMethod": source_math_state.SOURCE_ARC_MATHF_NUM_METHOD,
		"mathfNumReturn": SOURCE_ARC_MATHF_NUM_RETURN,
		"mathfApproachDeltaMethod": SOURCE_ARC_MATHF_APPROACH_DELTA_METHOD,
		"mathfApproachDeltaReturn": SOURCE_ARC_MATHF_APPROACH_DELTA_RETURN,
		"mathfApproachMethod": SOURCE_ARC_MATHF_APPROACH_METHOD,
		"mathfApproachReturn": SOURCE_ARC_MATHF_APPROACH_RETURN,
		"mathfClampFloatMethod": SOURCE_ARC_MATHF_CLAMP_FLOAT_METHOD,
		"mathfClampFloatReturn": SOURCE_ARC_MATHF_CLAMP_FLOAT_RETURN,
	}

static func boosting_event_state(event: bool) -> Dictionary:
	return {
		"eventGate": SOURCE_UNIT_UPDATE_BOOSTING_EVENT_GATE,
		"fireTrigger": SOURCE_UNIT_UPDATE_BOOSTING_EVENT_FIRE_TRIGGER,
		"triggerEnum": SOURCE_EVENT_TYPE_TRIGGER_ENUM,
		"unitCommandBoost": SOURCE_EVENT_TYPE_UNIT_COMMAND_BOOST,
		"event_fired": event,
		"trigger": "unitCommandBoost" if event else "",
	}
