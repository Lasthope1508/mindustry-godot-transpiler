extends RefCounted
class_name SourceUnitRuntimeState

const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerGameplayRegistry.gd")

const SOURCE_UNIT_DROWN_HIT_SIZE_DIVISOR := source_unit_defaults.DROWN_HIT_SIZE_DIVISOR
const SOURCE_UNIT_DROWN_UPDATE_EFFECT_CHANCE := source_unit_defaults.DROWN_UPDATE_EFFECT_CHANCE
const SOURCE_UNIT_DROWN_KILL_THRESHOLD := source_unit_defaults.DROWN_KILL_THRESHOLD
const SOURCE_UNIT_DROWN_DRY_DECAY_DIVISOR := source_unit_defaults.DROWN_DRY_DECAY_DIVISOR
const SOURCE_UNIT_HEAL_AMOUNT_POSITIVE_THRESHOLD := source_unit_defaults.HEAL_AMOUNT_POSITIVE_THRESHOLD
const SOURCE_UNIT_HEAL_TIME_RESET_THRESHOLD := source_unit_defaults.HEAL_TIME_RESET_THRESHOLD
const SOURCE_UNIT_HEAL_TIME_RESET_VALUE := source_unit_defaults.HEAL_TIME_RESET_VALUE
const SOURCE_UNIT_HEAL_TIME_DECAY_DIVISOR := source_unit_defaults.HEAL_TIME_DECAY_DIVISOR
const SOURCE_UNIT_UPDATE_ABILITIES_FIELD := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_ABILITIES_FIELD
const SOURCE_UNIT_UPDATE_ABILITIES_LOOP := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_ABILITIES_LOOP
const SOURCE_UNIT_UPDATE_ABILITIES_CALL := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_ABILITIES_CALL
const SOURCE_UNIT_UPDATE_ABILITIES_ABILITY_UPDATE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_ABILITIES_ABILITY_UPDATE_METHOD
const SOURCE_UNIT_UPDATE_AI_CONTROLLER_FIELD := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_CONTROLLER_FIELD
const SOURCE_UNIT_UPDATE_AI_DEAD_IMPORT := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_DEAD_IMPORT
const SOURCE_UNIT_UPDATE_AI_COMMENT := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_COMMENT
const SOURCE_UNIT_UPDATE_AI_GUARD := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_GUARD
const SOURCE_UNIT_UPDATE_AI_CONTROLLER_CALL := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_CONTROLLER_CALL
const SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_METHOD
const SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_DEFAULT := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_DEFAULT
const SOURCE_UNIT_UPDATE_AI_UNIT_CONTROLLER_UPDATE := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_UNIT_CONTROLLER_UPDATE
const SOURCE_UNIT_UPDATE_AI_NET_CLIENT_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_NET_CLIENT_METHOD
const SOURCE_UNIT_UPDATE_AI_NET_CLIENT_BODY := source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_AI_NET_CLIENT_BODY
const SOURCE_UNIT_HEAL_OVERRIDE := source_unit_update_source_text_state.SOURCE_UNIT_HEAL_OVERRIDE
const SOURCE_UNIT_HEAL_GUARD := source_unit_update_source_text_state.SOURCE_UNIT_HEAL_GUARD
const SOURCE_UNIT_HEAL_WAS_HEALED := source_unit_update_source_text_state.SOURCE_UNIT_HEAL_WAS_HEALED
const SOURCE_UNIT_HEAL_HEALTH_COMP_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_HEAL_HEALTH_COMP_METHOD
const SOURCE_UNIT_HEAL_HEALTH_COMP_ADD := source_unit_update_source_text_state.SOURCE_UNIT_HEAL_HEALTH_COMP_ADD
const SOURCE_UNIT_HEAL_HEALTH_COMP_CLAMP := source_unit_update_source_text_state.SOURCE_UNIT_HEAL_HEALTH_COMP_CLAMP

static func drowning_state(floor_exists: bool, floor_is_liquid: bool, floor_drown_time: float, can_drown_value: bool, current_drown_time: float, source_delta: float, hit_size: float, type_drown_time_multiplier: float, chance_delta_result: bool, net_client: bool) -> Dictionary:
	var can_drown_on_floor := floor_exists and floor_is_liquid and floor_drown_time > 0.0 and can_drown_value
	var drown_time_before_clamp := current_drown_time
	var drown_increment := 0.0
	var effect_call: Variant = null
	var kill_unit := false
	var event_call: Variant = null
	var last_drown_floor_set := false
	if can_drown_on_floor:
		last_drown_floor_set = true
		drown_increment = source_delta / (hit_size / SOURCE_UNIT_DROWN_HIT_SIZE_DIVISOR * type_drown_time_multiplier * floor_drown_time)
		drown_time_before_clamp += drown_increment
		if chance_delta_result:
			effect_call = {
				"call": "floor.drownUpdateEffect.at(x, y, hitSize, floor.mapColor)",
				"chance": "Mathf.chanceDelta(0.05f)",
				"chanceValue": SOURCE_UNIT_DROWN_UPDATE_EFFECT_CHANCE,
			}
		kill_unit = drown_time_before_clamp >= SOURCE_UNIT_DROWN_KILL_THRESHOLD and not net_client
		if kill_unit:
			event_call = {"event": "Events.fire(new UnitDrownEvent(self()))"}
	else:
		drown_time_before_clamp -= source_delta / SOURCE_UNIT_DROWN_DRY_DECAY_DIVISOR
	var clamped_drown_time: float = clampf(drown_time_before_clamp, 0.0, 1.0)
	return {
		"canDrownOnFloor": can_drown_on_floor,
		"lastDrownFloorSet": last_drown_floor_set,
		"drownIncrement": drown_increment,
		"drownTimeBeforeClamp": drown_time_before_clamp,
		"drownTime": clamped_drown_time,
		"effectCall": effect_call,
		"kill": kill_unit,
		"eventCall": event_call,
		"netClient": net_client,
	}

static func type_hook_state() -> Dictionary:
	return {
		"call": "type.update(self())",
		"arg": "self()",
		"unitTypeHook": "public void update(Unit unit)",
		"order": "first statement in UnitComp.update()",
	}

static func heal_state(current_health: float, max_health: float, amount: float, current_was_healed: bool) -> Dictionary:
	var next_health := current_health + amount
	next_health = min(next_health, max_health)
	if is_nan(next_health):
		next_health = 0.0
	var set_was_healed := next_health < max_health and amount > SOURCE_UNIT_HEAL_AMOUNT_POSITIVE_THRESHOLD
	return {
		"guard": {"healthLessThanMax": next_health < max_health, "amountPositive": amount > SOURCE_UNIT_HEAL_AMOUNT_POSITIVE_THRESHOLD},
		"health": next_health,
		"healthDelta": next_health - current_health,
		"healthCompAdd": SOURCE_UNIT_HEAL_HEALTH_COMP_ADD,
		"healthCompClamp": SOURCE_UNIT_HEAL_HEALTH_COMP_CLAMP,
		"healthCompHeal": SOURCE_UNIT_HEAL_HEALTH_COMP_METHOD,
		"wasHealed": true if set_was_healed else current_was_healed,
		"setWasHealed": set_was_healed,
		"healthMutationSource": "HealthComp.heal(float amount)",
		"override": SOURCE_UNIT_HEAL_OVERRIDE,
	}

static func heal_time_state(was_healed_value: bool, current_heal_time: float, source_delta: float) -> Dictionary:
	var reset_heal_time := was_healed_value and current_heal_time <= SOURCE_UNIT_HEAL_TIME_RESET_THRESHOLD
	var heal_time := SOURCE_UNIT_HEAL_TIME_RESET_VALUE if reset_heal_time else current_heal_time
	heal_time -= source_delta / SOURCE_UNIT_HEAL_TIME_DECAY_DIVISOR
	return {
		"healTime": heal_time,
		"wasHealed": false,
		"resetHealTime": reset_heal_time,
		"decay": source_delta / SOURCE_UNIT_HEAL_TIME_DECAY_DIVISOR,
		"order": ["updateDrowning", "healTime gate", "healTime decay", "wasHealed reset"],
	}

static func captured_sector_death_state(team_is_only_ai: bool, state_is_campaign: bool, sector_is_captured: bool) -> Dictionary:
	var kill_unit := team_is_only_ai and state_is_campaign and sector_is_captured
	return {
		"guard": {"team.isOnlyAI()": team_is_only_ai, "state.isCampaign()": state_is_campaign, "state.getSector().isCaptured()": sector_is_captured},
		"kill": kill_unit,
		"call": "kill()" if kill_unit else "",
	}

static func sound_loop_state(headless_value: bool, type_loop_sound: String, type_loop_sound_volume: float, type_move_sound: String, type_move_sound_volume: float, type_move_sound_pitch_min: float, type_move_sound_pitch_max: float, velocity_x: float, velocity_y: float, type_speed: float) -> Dictionary:
	var sound_enabled := not headless_value
	var velocity_len := sqrt(velocity_x * velocity_x + velocity_y * velocity_y)
	var progress := clampf(velocity_len / type_speed, 0.0, 1.0) if type_speed != 0.0 else 1.0
	var pitch := type_move_sound_pitch_min + (type_move_sound_pitch_max - type_move_sound_pitch_min) * progress
	var loop_sound_call: Variant = null
	var move_sound_call: Variant = null
	if sound_enabled:
		loop_sound_call = {
			"call": "control.sound.loop(type.loopSound, this, type.loopSoundVolume)",
			"sound": type_loop_sound,
			"volume": type_loop_sound_volume,
		}
		if type_move_sound != "Sounds.none":
			move_sound_call = {
				"call": "control.sound.loop(type.moveSound, this, type.moveSoundVolume * progress, pitch)",
				"sound": type_move_sound,
				"progress": progress,
				"volume": type_move_sound_volume * progress,
				"pitch": pitch,
			}
	return {
		"soundEnabled": sound_enabled,
		"velocityLen": velocity_len,
		"progress": progress,
		"pitch": pitch,
		"loopSound": loop_sound_call,
		"moveSound": move_sound_call,
	}

static func unsupported_env_state(type_supports_env: bool, dead_value: bool) -> Dictionary:
	var env_death := not type_supports_env and not dead_value
	var unit_env_death_call: Variant = null
	var update_count_call: Variant = null
	if env_death:
		unit_env_death_call = {
			"call": "Call.unitEnvDeath(self())",
		}
		update_count_call = {
			"call": "team.data().updateCount(type, -1)",
			"amount": -1,
		}
	return {
		"envDeath": env_death,
		"guard": {"!type.supportsEnv(state.rules.env)": not type_supports_env, "!dead": not dead_value},
		"unitEnvDeath": unit_env_death_call,
		"updateCount": update_count_call,
		"callOrder": ["Call.unitEnvDeath(self())", "team.data().updateCount(type, -1)"] if env_death else [],
	}

static func abilities_loop_state(ability_ids: Array) -> Dictionary:
	var updates := []
	for ability_id in ability_ids:
		updates.append({
			"call": SOURCE_UNIT_UPDATE_ABILITIES_CALL,
			"ability": ability_id,
		})
	return {
		"abilitiesField": SOURCE_UNIT_UPDATE_ABILITIES_FIELD,
		"loop": SOURCE_UNIT_UPDATE_ABILITIES_LOOP,
		"updateCall": SOURCE_UNIT_UPDATE_ABILITIES_CALL,
		"abilityUpdateMethod": SOURCE_UNIT_UPDATE_ABILITIES_ABILITY_UPDATE_METHOD,
		"updates": updates,
		"updateCount": updates.size(),
	}

static func ai_controller_server_gate_state(net_client_value: bool, dead_value: bool, should_update_controller_value: bool, unit_id: int) -> Dictionary:
	var guard := (not net_client_value) and (not dead_value) and should_update_controller_value
	var controller_update: Variant = null
	if guard:
		controller_update = {
			"call": SOURCE_UNIT_UPDATE_AI_CONTROLLER_CALL,
			"unit": unit_id,
		}
	return {
		"controllerField": SOURCE_UNIT_UPDATE_AI_CONTROLLER_FIELD,
		"deadImport": SOURCE_UNIT_UPDATE_AI_DEAD_IMPORT,
		"comment": SOURCE_UNIT_UPDATE_AI_COMMENT,
		"guardSource": SOURCE_UNIT_UPDATE_AI_GUARD,
		"controllerUpdateCall": SOURCE_UNIT_UPDATE_AI_CONTROLLER_CALL,
		"shouldUpdateMethod": SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_METHOD,
		"shouldUpdateDefault": SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_DEFAULT,
		"unitControllerUpdate": SOURCE_UNIT_UPDATE_AI_UNIT_CONTROLLER_UPDATE,
		"netClientMethod": SOURCE_UNIT_UPDATE_AI_NET_CLIENT_METHOD,
		"netClientBody": SOURCE_UNIT_UPDATE_AI_NET_CLIENT_BODY,
		"guard": guard,
		"netClient": net_client_value,
		"dead": dead_value,
		"shouldUpdateController": should_update_controller_value,
		"controllerUpdate": controller_update,
	}

static func invalid_controller_reset_state(controller_is_valid_value: bool, unit_id: int) -> Dictionary:
	var guard := not controller_is_valid_value
	var reset_controller: Variant = null
	if guard:
		reset_controller = {
			"call": "resetController()",
			"effect": "controller(type.createController(self()))",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"controllerIsValid": controller_is_valid_value,
		"resetController": reset_controller,
	}

static func spawned_core_despawn_state(spawned_by_core_value: bool, is_player_value: bool, dead_value: bool, unit_id: int) -> Dictionary:
	var guard := spawned_by_core_value and (not is_player_value) and (not dead_value)
	var despawn_call: Variant = null
	if guard:
		despawn_call = {
			"call": "Call.unitDespawn(self())",
			"effect": "Fx.unitDespawn.at(unit.x, unit.y, 0, unit)",
			"remove": "unit.remove()",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"spawnedByCore": spawned_by_core_value,
		"isPlayer": is_player_value,
		"dead": dead_value,
		"despawn": despawn_call,
	}

static func source_units_can_create_state(use_unit_cap: bool, count_type: int, unit_cap: int, is_banned: bool) -> Dictionary:
	# Units.canCreate(team, type) (Units.java:115-117):
	# `return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());`
	# The cap is Units.getCap(team) (Units.java:118-125):
	# `return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);`
	# — computed by the caller through the existing cap bridge
	# (SourceUnitUpdateState.cap_state), so the formula is not
	# duplicated here; countType is TeamData.countType(type)
	# (Teams.java:442-444) and isBanned is Rules.isBanned
	# (Rules.java:311-313), both computed by the caller. This
	# function only composes the three already-ported pieces with
	# type.useUnitCap into the one predicate.
	var can_create := not use_unit_cap or (count_type < unit_cap and not is_banned)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNITS_CAN_CREATE_STATE,
		"can_create": can_create,
		"unit_cap": unit_cap,
		"count_type": count_type,
		"is_banned": is_banned,
	}
