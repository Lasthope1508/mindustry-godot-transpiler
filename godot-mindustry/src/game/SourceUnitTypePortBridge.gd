extends "res://src/game/SourceUnitUpdatePortBridge.gd"

const source_unit_type_state := preload("res://src/game/SourceUnitTypeState.gd")
func source_unit_type_create_controller_state(controller_get: Callable, unit: Variant) -> Dictionary:
	return source_unit_type_state.create_controller_state(controller_get, unit)

func source_unit_type_has_weapons_state(weapons: Array) -> Dictionary:
	return source_unit_type_state.has_weapons_state(weapons)

func source_unit_type_targetable_state(type_targetable: bool, vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, unit: Variant, targeter: Variant) -> Dictionary:
	return source_unit_type_state.targetable_state(type_targetable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit, targeter)

func source_unit_type_killable_state(type_killable: bool, unit: Variant) -> Dictionary:
	return source_unit_type_state.killable_state(type_killable, unit)

func source_unit_type_hittable_state(type_hittable: bool, vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, unit: Variant) -> Dictionary:
	return source_unit_type_state.hittable_state(type_hittable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit)

func source_unit_type_get_unit_stances_state(controller_is_command_ai: bool, command_is_mine: bool, mine_floor: bool, mine_walls: bool, present_ores: Array, stances: Array, extra_stances: Array, out: Array) -> Dictionary:
	return source_unit_type_state.get_unit_stances_state(controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out)

func source_unit_type_allow_stance_state(stance: Variant, controller_is_command_ai: bool, command_is_mine: bool, mine_floor: bool, mine_walls: bool, present_ores: Array, stances: Array, extra_stances: Array, out: Array) -> Dictionary:
	return source_unit_type_state.allow_stance_state(stance, controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out)

func source_unit_type_allow_command_state(commands: Array, command: Variant) -> Dictionary:
	return source_unit_type_state.allow_command_state(commands, command)

func generated_unit_type_get_unit_stances_bridge_state(controller_is_command_ai: bool, command_is_mine: bool, mine_floor: bool, mine_walls: bool, present_ores: Array, stances: Array, extra_stances: Array, out: Array) -> Dictionary:
	return source_unit_type_state.generated_get_unit_stances_bridge_state(controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out)

func generated_unit_type_allow_stance_bridge_state(stance: Variant, controller_is_command_ai: bool, command_is_mine: bool, mine_floor: bool, mine_walls: bool, present_ores: Array, stances: Array, extra_stances: Array, out: Array) -> Dictionary:
	return source_unit_type_state.generated_allow_stance_bridge_state(stance, controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out)

func generated_unit_type_allow_command_bridge_state(commands: Array, command: Variant) -> Dictionary:
	return source_unit_type_state.generated_allow_command_bridge_state(commands, command)

func source_unit_type_update_state(unit: Variant) -> Dictionary:
	return source_unit_type_state.update_state(unit)

func source_unit_type_update_payload_state(unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_unit_type_state.update_payload_state(unit, unit_holder, building_holder)

func source_unit_type_killed_state(unit: Variant) -> Dictionary:
	return source_unit_type_state.killed_state(unit)

func source_unit_type_landed_state(unit: Variant) -> Dictionary:
	return source_unit_type_state.landed_state(unit)

func generated_unit_type_create_controller_bridge_state(controller_get: Callable, unit: Variant) -> Dictionary:
	return source_unit_type_state.generated_create_controller_bridge_state(controller_get, unit)

func generated_unit_type_has_weapons_bridge_state(weapons: Array) -> Dictionary:
	return source_unit_type_state.generated_has_weapons_bridge_state(weapons)

func generated_unit_type_targetable_bridge_state(type_targetable: bool, vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, unit: Variant, targeter: Variant) -> Dictionary:
	return source_unit_type_state.generated_targetable_bridge_state(type_targetable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit, targeter)

func generated_unit_type_killable_bridge_state(type_killable: bool, unit: Variant) -> Dictionary:
	return source_unit_type_state.generated_killable_bridge_state(type_killable, unit)

func generated_unit_type_hittable_bridge_state(type_hittable: bool, vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, unit: Variant) -> Dictionary:
	return source_unit_type_state.generated_hittable_bridge_state(type_hittable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit)
