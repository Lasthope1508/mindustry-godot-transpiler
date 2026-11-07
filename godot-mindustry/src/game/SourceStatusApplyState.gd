extends RefCounted
class_name SourceStatusApplyState

const source_status_defaults := preload("res://src/game/SourceStatusDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_STATUS_APPLY_RESULT_METHOD := source_status_defaults.STATUS_APPLY_RESULT_METHOD
const SOURCE_STATUS_APPLY_RESULT_GUARD := source_status_defaults.STATUS_APPLY_RESULT_GUARD
const SOURCE_STATUS_APPLY_RESULT_WEAPON_SHOOT_STATUS_FIELD := source_status_defaults.STATUS_APPLY_RESULT_WEAPON_SHOOT_STATUS_FIELD
const SOURCE_STATUS_APPLY_RESULT_WEAPON_DURATION_FIELD := source_status_defaults.STATUS_APPLY_RESULT_WEAPON_DURATION_FIELD
const SOURCE_STATUS_APPLY_RESULT_WEAPON_CALL := source_status_defaults.STATUS_APPLY_RESULT_WEAPON_CALL

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
