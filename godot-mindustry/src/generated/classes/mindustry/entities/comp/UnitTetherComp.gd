# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/UnitTetherComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitTetherComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Unitc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": ["public", "transient"], "name": "spawner", "type": "Unit"}, {"modifiers": ["public"], "name": "spawnerUnitId", "type": "int"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "afterRead", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterSync", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_afterRead_0(_args: Array = []) -> Variant:
	var spawner_unit_id := int(_args[0] if _args.size() > 0 else -1)
	var groups_unit_get_by_id_result: Variant = _args[1] if _args.size() > 1 else null
	var guard: bool = spawner_unit_id != -1
	var spawner_value: Variant = null
	var groups_unit_get_by_id_call: Variant = null
	if guard:
		groups_unit_get_by_id_call = {"call": "Groups.unit.getByID(spawnerUnitId)", "id": spawner_unit_id}
		spawner_value = groups_unit_get_by_id_result
	return {"source_owner": "PortGame.source_unit_tether_after_read_state", "method": "public void afterRead(){", "guard_expr": "if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);", "reset_expr": "spawnerUnitId = -1;", "spawnerUnitIdBefore": spawner_unit_id, "guard": guard, "groupsUnitGetById": groups_unit_get_by_id_call, "spawner": spawner_value, "spawnerUnitId": -1}

func java_method_afterSync_1(_args: Array = []) -> Variant:
	var spawner_unit_id := int(_args[0] if _args.size() > 0 else -1)
	var groups_unit_get_by_id_result: Variant = _args[1] if _args.size() > 1 else null
	var guard: bool = spawner_unit_id != -1
	var spawner_value: Variant = null
	var groups_unit_get_by_id_call: Variant = null
	if guard:
		groups_unit_get_by_id_call = {"call": "Groups.unit.getByID(spawnerUnitId)", "id": spawner_unit_id}
		spawner_value = groups_unit_get_by_id_result
	return {"source_owner": "PortGame.source_unit_tether_after_sync_state", "method": "public void afterSync(){", "guard_expr": "if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);", "reset_expr": "spawnerUnitId = -1;", "spawnerUnitIdBefore": spawner_unit_id, "guard": guard, "groupsUnitGetById": groups_unit_get_by_id_call, "spawner": spawner_value, "spawnerUnitId": -1}

func java_method_update_2(_args: Array = []) -> Variant:
	var spawner_exists := bool(_args[0] if _args.size() > 0 else false)
	var spawner_is_valid := bool(_args[1] if _args.size() > 1 else false)
	var spawner_team_value: Variant = _args[2] if _args.size() > 2 else null
	var team_value: Variant = _args[3] if _args.size() > 3 else null
	var unit_id := int(_args[4] if _args.size() > 4 else 0)
	var spawner_id := int(_args[5] if _args.size() > 5 else -1)
	var guard: bool = (not spawner_exists) or (not spawner_is_valid) or spawner_team_value != team_value
	var despawn_call: Variant = null
	var next_spawner_unit_id := -1
	if guard:
		despawn_call = {"call": "Call.unitDespawn(self())", "unit": unit_id}
	if not guard:
		next_spawner_unit_id = spawner_id
	return {"source_owner": "PortGame.source_unit_tether_update_state", "method": "public void update(){", "guard_expr": "if(spawner == null || !spawner.isValid() || spawner.team != team){", "else_expr": "}else{", "assign_expr": "spawnerUnitId = spawner.id;", "spawner_exists": spawner_exists, "spawner_is_valid": spawner_is_valid, "spawner_team_value": spawner_team_value, "team_value": team_value, "guard": guard, "despawn": despawn_call, "spawnerUnitId": next_spawner_unit_id}
