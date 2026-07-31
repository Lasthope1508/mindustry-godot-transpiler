extends RefCounted
class_name SourceStatusApplyState

const source_status_defaults := preload("res://src/game/SourceStatusDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_STATUS_APPLY_RESULT_METHOD := "public void apply(StatusEffect effect, float duration){"
const SOURCE_STATUS_APPLY_RESULT_GUARD := "if(effect == StatusEffects.none || effect == null || isImmune(effect)) return;"
const SOURCE_STATUS_APPLY_RESULT_WEAPON_SHOOT_STATUS_FIELD := "public StatusEffect shootStatus = StatusEffects.none;"
const SOURCE_STATUS_APPLY_RESULT_WEAPON_DURATION_FIELD := "public float shootStatusDuration = 60f * 5f;"
const SOURCE_STATUS_APPLY_RESULT_WEAPON_CALL := "unit.apply(shootStatus, shootStatusDuration);"

static func apply_result_state(status_effect: String, duration: float, status_immune: bool) -> Dictionary:
	var status_applied := status_effect != "none" and status_effect != "" and status_effect != source_status_defaults.STATUS_EFFECT_NONE and not status_immune
	var status_application: Dictionary = {}
	if status_applied:
		status_application = {
			"call": SOURCE_STATUS_APPLY_RESULT_WEAPON_CALL,
			"effect": status_effect,
			"duration": duration,
		}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_STATUS_APPLY_RESULT,
		"method": SOURCE_STATUS_APPLY_RESULT_METHOD,
		"guard": SOURCE_STATUS_APPLY_RESULT_GUARD,
		"weaponShootStatusField": SOURCE_STATUS_APPLY_RESULT_WEAPON_SHOOT_STATUS_FIELD,
		"weaponDurationField": SOURCE_STATUS_APPLY_RESULT_WEAPON_DURATION_FIELD,
		"weaponCall": SOURCE_STATUS_APPLY_RESULT_WEAPON_CALL,
		"status_effect": status_effect,
		"duration": duration,
		"statusImmune": status_immune,
		"statusApplied": status_applied,
		"statusApplication": status_application,
		"statusApplyGuardSource": SOURCE_STATUS_APPLY_RESULT_GUARD.trim_suffix(";"),
	}
