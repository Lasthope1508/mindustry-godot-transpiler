extends RefCounted
class_name SourceUnitLifecycleState

const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerGameplayRegistry.gd")
const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_geometry_defaults := preload("res://src/game/SourceGeometryDefaults.gd")

const SOURCE_UNIT_ADD_INITIAL_UPDATE_COUNT := source_unit_update_source_text_state.SOURCE_UNIT_ADD_INITIAL_UPDATE_COUNT
const SOURCE_UNIT_ADD_ROLLBACK_UPDATE_COUNT := source_unit_update_source_text_state.SOURCE_UNIT_ADD_ROLLBACK_UPDATE_COUNT
const SOURCE_UNIT_AFTER_READ_ALL_CALL := source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_ALL_CALL
const SOURCE_UNIT_AFTER_READ_ALL_SELF_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_ALL_SELF_ARG
const SOURCE_UNIT_AFTER_READ_SELF_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_SELF_ARG
const SOURCE_UNIT_AFTER_READ_SET_TYPE_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_SET_TYPE_ARG
const SOURCE_UNIT_AFTER_SYNC_SELF_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AFTER_SYNC_SELF_ARG
const SOURCE_UNIT_AFTER_SYNC_SET_TYPE_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AFTER_SYNC_SET_TYPE_ARG
const SOURCE_UNIT_HITTABLE_CALL := source_unit_update_source_text_state.SOURCE_UNIT_HITTABLE_CALL
const SOURCE_UNIT_PLAYER_CONTROLLABLE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_PLAYER_CONTROLLABLE_METHOD
const SOURCE_UNIT_PLAYER_CONTROLLABLE_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_PLAYER_CONTROLLABLE_RETURN
const SOURCE_UNIT_SET_TYPE_ABILITIES_ARRAY := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_ABILITIES_ARRAY
const SOURCE_UNIT_SET_TYPE_ABILITIES_GUARD := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_ABILITIES_GUARD
const SOURCE_UNIT_SET_TYPE_ABILITY_COPY := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_ABILITY_COPY
const SOURCE_UNIT_SET_TYPE_ABILITY_DATA_CARRY := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_ABILITY_DATA_CARRY
const SOURCE_UNIT_SET_TYPE_ASSIGN_ARMOR := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_ASSIGN_ARMOR
const SOURCE_UNIT_SET_TYPE_ASSIGN_DRAG := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_ASSIGN_DRAG
const SOURCE_UNIT_SET_TYPE_ASSIGN_HIT_SIZE := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_ASSIGN_HIT_SIZE
const SOURCE_UNIT_SET_TYPE_ASSIGN_MAX_HEALTH := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_ASSIGN_MAX_HEALTH
const SOURCE_UNIT_SET_TYPE_ASSIGN_TYPE := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_ASSIGN_TYPE
const SOURCE_UNIT_SET_TYPE_CONTROLLER_GUARD := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_CONTROLLER_GUARD
const SOURCE_UNIT_SET_TYPE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_METHOD
const SOURCE_UNIT_SET_TYPE_SETUP_WEAPONS_GUARD := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_SETUP_WEAPONS_GUARD
const SOURCE_UNIT_SET_TYPE_UNIT_TYPE_CREATE_CONTROLLER := source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_UNIT_TYPE_CREATE_CONTROLLER
const SOURCE_UNIT_TARGETABLE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_TARGETABLE_METHOD
const SOURCE_UNIT_TARGETABLE_TYPE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_TARGETABLE_TYPE_METHOD
const SOURCE_UNIT_TARGETABLE_TYPE_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_TARGETABLE_TYPE_RETURN
const SOURCE_UNIT_TARGETABLE_UNIT_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_TARGETABLE_UNIT_RETURN
const SOURCE_UNIT_IS_SYNC_HIDDEN_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_IS_SYNC_HIDDEN_METHOD
const SOURCE_UNIT_IS_SYNC_HIDDEN_COMMENT := source_unit_update_source_text_state.SOURCE_UNIT_IS_SYNC_HIDDEN_COMMENT
const SOURCE_UNIT_IS_SYNC_HIDDEN_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_IS_SYNC_HIDDEN_RETURN
const SOURCE_UNIT_HANDLE_SYNC_HIDDEN_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_HANDLE_SYNC_HIDDEN_METHOD
const SOURCE_UNIT_HANDLE_SYNC_HIDDEN_REMOVE := source_unit_update_source_text_state.SOURCE_UNIT_HANDLE_SYNC_HIDDEN_REMOVE
const SOURCE_UNIT_HANDLE_SYNC_HIDDEN_CLEAR_REMOVED_ENTITY := source_unit_update_source_text_state.SOURCE_UNIT_HANDLE_SYNC_HIDDEN_CLEAR_REMOVED_ENTITY
const SOURCE_UNIT_IN_FOG_TO_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_IN_FOG_TO_METHOD
const SOURCE_UNIT_IN_FOG_TO_GEOMETRY_SOURCE := source_unit_update_source_text_state.SOURCE_UNIT_IN_FOG_TO_GEOMETRY_SOURCE

static func player_controllable_state(type_player_controllable: bool, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_block_privileged: bool) -> Dictionary:
	var logic_privileged_blocked := controller_is_logic_ai and logic_controller_exists and logic_controller_block_privileged
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PLAYER_CONTROLLABLE_STATE,
		"method": SOURCE_UNIT_PLAYER_CONTROLLABLE_METHOD,
		"returnExpr": SOURCE_UNIT_PLAYER_CONTROLLABLE_RETURN,
		"playerControllable": type_player_controllable and not logic_privileged_blocked,
		"logicPrivilegedBlocked": logic_privileged_blocked,
		"call": "playerControllable()",
	}

static func is_sync_hidden_state(is_shooting_value: bool, in_fog_to_value: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_IS_SYNC_HIDDEN_STATE,
		"method": SOURCE_UNIT_IS_SYNC_HIDDEN_METHOD,
		"comment": SOURCE_UNIT_IS_SYNC_HIDDEN_COMMENT,
		"return_expr": SOURCE_UNIT_IS_SYNC_HIDDEN_RETURN,
		"is_shooting": is_shooting_value,
		"in_fog_to": in_fog_to_value,
		"is_sync_hidden": not is_shooting_value and in_fog_to_value,
	}

static func in_fog_to_state(same_team: bool, rules_fog: bool, hit_size: float, unit_x: float, unit_y: float, center_visible: bool, d8_visible: Array) -> Dictionary:
	var initial_gate := same_team or not rules_fog
	if initial_gate:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_IN_FOG_TO_STATE,
			"method": SOURCE_UNIT_IN_FOG_TO_METHOD,
			"geometry_source": SOURCE_UNIT_IN_FOG_TO_GEOMETRY_SOURCE,
			"initial_gate": true,
			"unit_x": unit_x,
			"unit_y": unit_y,
			"in_fog": false,
			"branch": "initial_gate",
		}
	if hit_size <= source_unit_defaults.FOG_SMALL_HIT_SIZE_MAX:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_IN_FOG_TO_STATE,
			"method": SOURCE_UNIT_IN_FOG_TO_METHOD,
			"geometry_source": SOURCE_UNIT_IN_FOG_TO_GEOMETRY_SOURCE,
			"initial_gate": false,
			"branch": "center",
			"unit_x": unit_x,
			"unit_y": unit_y,
			"center_visible": center_visible,
			"checked_probes": [{"offset": Vector2i.ZERO, "position": Vector2(unit_x, unit_y), "visible": center_visible}],
			"in_fog": not center_visible,
		}
	var visible_probe_count := 0
	var checked_probes := []
	var trns := hit_size / source_unit_defaults.FOG_LARGE_TRANSLATION_DIVISOR
	for index in range(source_geometry_defaults.D8_OFFSETS.size()):
		var offset: Vector2i = source_geometry_defaults.D8_OFFSETS[index]
		var visible := bool(d8_visible[index] if index < d8_visible.size() else false)
		var position := Vector2(unit_x + float(offset.x) * trns, unit_y + float(offset.y) * trns)
		checked_probes.append({"offset": offset, "position": position, "visible": visible})
		if bool(visible):
			return {
				"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_IN_FOG_TO_STATE,
				"method": SOURCE_UNIT_IN_FOG_TO_METHOD,
				"geometry_source": SOURCE_UNIT_IN_FOG_TO_GEOMETRY_SOURCE,
				"d8_offsets": source_geometry_defaults.D8_OFFSETS,
				"initial_gate": false,
				"branch": "d8",
				"hit_size": hit_size,
				"trns": trns,
				"visible_probe_count": visible_probe_count + 1,
				"checked_probes": checked_probes,
				"in_fog": false,
			}
		visible_probe_count += 1
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_IN_FOG_TO_STATE,
		"method": SOURCE_UNIT_IN_FOG_TO_METHOD,
		"geometry_source": SOURCE_UNIT_IN_FOG_TO_GEOMETRY_SOURCE,
		"d8_offsets": source_geometry_defaults.D8_OFFSETS,
		"initial_gate": false,
		"branch": "d8",
		"hit_size": hit_size,
		"trns": trns,
		"visible_probe_count": visible_probe_count,
		"checked_probes": checked_probes,
		"in_fog": true,
	}

static func handle_sync_hidden_state(unit_id: int) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_HANDLE_SYNC_HIDDEN_STATE,
		"method": SOURCE_UNIT_HANDLE_SYNC_HIDDEN_METHOD,
		"remove": {"call": SOURCE_UNIT_HANDLE_SYNC_HIDDEN_REMOVE, "unit_id": unit_id},
		"clear_removed_entity": {"call": SOURCE_UNIT_HANDLE_SYNC_HIDDEN_CLEAR_REMOVED_ENTITY, "id": unit_id},
		"unit_id": unit_id,
		"handled": true,
	}

static func targetable_state(type_targetable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, targeter_id: int) -> Dictionary:
	var payload_targetable := type_vulnerable_with_payloads and unit_is_payloadc and unit_has_payload
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TARGETABLE_STATE,
		"method": SOURCE_UNIT_TARGETABLE_METHOD,
		"unitReturn": SOURCE_UNIT_TARGETABLE_UNIT_RETURN,
		"typeMethod": SOURCE_UNIT_TARGETABLE_TYPE_METHOD,
		"typeReturn": SOURCE_UNIT_TARGETABLE_TYPE_RETURN,
		"targetable": type_targetable or payload_targetable,
		"payloadTargetable": payload_targetable,
		"targeter_id": targeter_id,
		"call": "type.targetable(self(), targeter)",
	}

static func killable_state(type_killable: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_KILLABLE_STATE,
		"killable": type_killable,
		"call": "type.killable(self())",
	}

static func hittable_state(type_hittable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool) -> Dictionary:
	var payload_hittable := type_vulnerable_with_payloads and unit_is_payloadc and unit_has_payload
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_HITTABLE_STATE,
		"hittable": type_hittable or payload_hittable,
		"payloadHittable": payload_hittable,
		"call": SOURCE_UNIT_HITTABLE_CALL,
	}

static func after_sync_state(type_id: int, controller_exists: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_AFTER_SYNC_STATE,
		"type_id": type_id,
		"controller_exists": controller_exists,
		"call_order": ["setType", "controller.unit"],
		"setType_arg": SOURCE_UNIT_AFTER_SYNC_SET_TYPE_ARG,
		"controllerUnitArg": SOURCE_UNIT_AFTER_SYNC_SELF_ARG,
	}

static func after_read_state(type_id: int, controller_is_ai_controller: bool, ai_keep_state: bool, controller_exists: bool) -> Dictionary:
	var reset_controller := not (controller_is_ai_controller and ai_keep_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_AFTER_READ_STATE,
		"type_id": type_id,
		"controller_exists": controller_exists,
		"controllerIsAIController": controller_is_ai_controller,
		"aiKeepState": ai_keep_state,
		"resetController": reset_controller,
		"call_order": ["setType", "controller.unit", "controller(type.createController)"] if reset_controller else ["setType", "controller.unit"],
		"setType_arg": SOURCE_UNIT_AFTER_READ_SET_TYPE_ARG,
		"controllerUnitArg": SOURCE_UNIT_AFTER_READ_SELF_ARG,
		"createControllerArg": SOURCE_UNIT_AFTER_READ_SELF_ARG,
	}

static func after_read_all_state(controller_exists: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_AFTER_READ_ALL_STATE,
		"controller_exists": controller_exists,
		"call": SOURCE_UNIT_AFTER_READ_ALL_CALL,
		"afterReadArg": SOURCE_UNIT_AFTER_READ_ALL_SELF_ARG,
	}

static func add_state(type_use_unit_cap: bool, count_after_add: int, cap_value: int, spawned_by_core: bool, dead: bool, rules_editor: bool) -> Dictionary:
	var over_cap := type_use_unit_cap and count_after_add > cap_value and not spawned_by_core and not dead and not rules_editor
	var rollback_update_count: Variant = null
	if over_cap:
		rollback_update_count = {"call": SOURCE_UNIT_ADD_ROLLBACK_UPDATE_COUNT, "amount": -1}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_ADD_STATE,
		"initialUpdateCount": {"call": SOURCE_UNIT_ADD_INITIAL_UPDATE_COUNT, "amount": 1},
		"guard": {
			"typeUseUnitCap": type_use_unit_cap,
			"countAfterAdd": count_after_add,
			"cap": cap_value,
			"spawnedByCore": spawned_by_core,
			"dead": dead,
			"rulesEditor": rules_editor,
		},
		"unitCapDeath": over_cap,
		"rollbackUpdateCount": rollback_update_count,
		"call_order": ["team.data().updateCount(+1)", "Call.unitCapDeath", "team.data().updateCount(-1)"] if over_cap else ["team.data().updateCount(+1)"],
	}

static func controller_predicates_state(controller_is_ai_controller: bool, controller_is_command_ai: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CONTROLLER_PREDICATES_STATE,
		"is_ai": controller_is_ai_controller,
		"allow_command": controller_is_command_ai,
		"is_commandable": controller_is_command_ai,
	}

static func can_target_state(other_exists: bool, other_is_unit: bool, other_unit_check_target_result: bool, other_is_building: bool, type_target_air: bool, type_target_ground: bool) -> Dictionary:
	if not other_exists:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CAN_TARGET_STATE, "branch": "null", "can_target": false}
	if other_is_unit:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CAN_TARGET_STATE,
			"branch": "unit",
			"can_target": other_unit_check_target_result,
			"unit_check_target_air": type_target_air,
			"unit_check_target_ground": type_target_ground,
		}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CAN_TARGET_STATE,
		"branch": "building" if other_is_building else "other",
		"can_target": other_is_building and type_target_ground,
	}

static func command_state(controller_is_command_ai: bool) -> Dictionary:
	if controller_is_command_ai:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_COMMAND_STATE,
			"returned_command_ai": true,
			"throws": false,
			"exception_type": "",
			"message": "",
		}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_COMMAND_STATE,
		"returned_command_ai": false,
		"throws": true,
		"exception_type": "IllegalArgumentException",
		"message": "Unit cannot be commanded - check isCommandable() first.",
	}

static func is_missile_state(unit_is_timed_killc: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_IS_MISSILE_STATE,
		"is_missile": unit_is_timed_killc,
		"instanceof": "TimedKillc",
	}

static func count_state(team_data_count_type_result: int, type_id: int) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_COUNT_STATE,
		"count": team_data_count_type_result,
		"type_id": type_id,
		"call": "team.data().countType(type)",
	}

static func cap_state(team_is_wave_team: bool, rules_pvp: bool, state_is_campaign: bool, rules_disable_unit_cap: bool, team_ignore_unit_cap: bool, rules_unit_cap_variable: bool, rules_unit_cap: int, team_data_unit_cap: int) -> Dictionary:
	if (team_is_wave_team and not rules_pvp) or (state_is_campaign and team_is_wave_team) or rules_disable_unit_cap or team_ignore_unit_cap:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CAP_STATE,
			"cap": 2147483647,
			"uncapped": true,
			"call": "Units.getCap(team)",
		}
	if rules_unit_cap_variable:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CAP_STATE,
			"cap": max(0, rules_unit_cap + team_data_unit_cap),
			"uncapped": false,
			"call": "Units.getCap(team)",
		}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CAP_STATE,
		"cap": max(0, rules_unit_cap),
		"uncapped": false,
		"call": "Units.getCap(team)",
	}

static func set_type_state(type_id: int, type_health: float, type_drag: float, type_armor: float, type_hit_size: float, mounts_length: int, type_weapons_size: int, abilities_length: int, type_abilities_size: int, first_ability_is_empty_data_ability: bool, controller_is_null: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_SET_TYPE_STATE,
		"method": SOURCE_UNIT_SET_TYPE_METHOD,
		"assignType": SOURCE_UNIT_SET_TYPE_ASSIGN_TYPE,
		"assignMaxHealth": SOURCE_UNIT_SET_TYPE_ASSIGN_MAX_HEALTH,
		"assignDrag": SOURCE_UNIT_SET_TYPE_ASSIGN_DRAG,
		"assignArmor": SOURCE_UNIT_SET_TYPE_ASSIGN_ARMOR,
		"assignHitSize": SOURCE_UNIT_SET_TYPE_ASSIGN_HIT_SIZE,
		"setupWeaponsGuard": SOURCE_UNIT_SET_TYPE_SETUP_WEAPONS_GUARD,
		"abilitiesGuard": SOURCE_UNIT_SET_TYPE_ABILITIES_GUARD,
		"abilitiesArray": SOURCE_UNIT_SET_TYPE_ABILITIES_ARRAY,
		"abilityCopy": SOURCE_UNIT_SET_TYPE_ABILITY_COPY,
		"abilityDataCarry": SOURCE_UNIT_SET_TYPE_ABILITY_DATA_CARRY,
		"controllerGuard": SOURCE_UNIT_SET_TYPE_CONTROLLER_GUARD,
		"unitTypeCreateControllerMethod": SOURCE_UNIT_SET_TYPE_UNIT_TYPE_CREATE_CONTROLLER,
		"assigned_type_id": type_id,
		"maxHealth": type_health,
		"drag": type_drag,
		"armor": type_armor,
		"hitSize": type_hit_size,
		"setupWeapons": mounts_length != type_weapons_size,
		"refreshAbilities": abilities_length != type_abilities_size or (abilities_length > 0 and first_ability_is_empty_data_ability),
		"createController": controller_is_null,
		"call": "setType(UnitType type)",
	}
