extends RefCounted
class_name SourceUnitTetherState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func after_read_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	var guard: bool = spawner_unit_id != -1
	var spawner_value: Variant = null
	var groups_unit_get_by_id_call: Variant = null
	if guard:
		groups_unit_get_by_id_call = {"call": "Groups.unit.getByID(spawnerUnitId)", "id": spawner_unit_id}
		spawner_value = groups_unit_get_by_id_result
	return {
		"source_owner": "PortGame.source_unit_tether_after_read_state",
		"method": "public void afterRead(){",
		"guard_expr": "if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);",
		"reset_expr": "spawnerUnitId = -1;",
		"spawnerUnitIdBefore": spawner_unit_id,
		"guard": guard,
		"groupsUnitGetById": groups_unit_get_by_id_call,
		"spawner": spawner_value,
		"spawnerUnitId": -1,
	}

static func after_sync_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	var guard: bool = spawner_unit_id != -1
	var spawner_value: Variant = null
	var groups_unit_get_by_id_call: Variant = null
	if guard:
		groups_unit_get_by_id_call = {"call": "Groups.unit.getByID(spawnerUnitId)", "id": spawner_unit_id}
		spawner_value = groups_unit_get_by_id_result
	return {
		"source_owner": "PortGame.source_unit_tether_after_sync_state",
		"method": "public void afterSync(){",
		"guard_expr": "if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);",
		"reset_expr": "spawnerUnitId = -1;",
		"spawnerUnitIdBefore": spawner_unit_id,
		"guard": guard,
		"groupsUnitGetById": groups_unit_get_by_id_call,
		"spawner": spawner_value,
		"spawnerUnitId": -1,
	}

static func update_state(spawner_exists: bool, spawner_is_valid: bool, spawner_team_value: Variant, team_value: Variant, unit_id: int, spawner_id: int) -> Dictionary:
	var guard: bool = (not spawner_exists) or (not spawner_is_valid) or spawner_team_value != team_value
	var despawn_call: Variant = null
	var next_spawner_unit_id := -1
	if guard:
		despawn_call = {"call": "Call.unitDespawn(self())", "unit": unit_id}
	else:
		next_spawner_unit_id = spawner_id
	return {
		"source_owner": "PortGame.source_unit_tether_update_state",
		"method": "public void update(){",
		"guard_expr": "if(spawner == null || !spawner.isValid() || spawner.team != team){",
		"else_expr": "}else{",
		"else": "else:",
		"assign_expr": "spawnerUnitId = spawner.id;",
		"spawner_exists": spawner_exists,
		"spawner_is_valid": spawner_is_valid,
		"spawner_team_value": spawner_team_value,
		"team_value": team_value,
		"guard": guard,
		"despawn": despawn_call,
		"spawnerUnitId": next_spawner_unit_id,
	}

static func generated_unit_tether_comp_after_read_bridge_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/UnitTetherComp.gd", "java_method_afterRead_0", [spawner_unit_id, groups_unit_get_by_id_result], null)
	var canonical = after_read_state(spawner_unit_id, groups_unit_get_by_id_result)
	return {"source_owner": "PortGame.source_unit_tether_after_read_state", "generated_owner": "UnitTetherComp.java_method_afterRead_0", "result": result, "canonical": canonical, "matches": result.get("guard", null) == canonical.get("guard", null) and result.get("groupsUnitGetById", null) == canonical.get("groupsUnitGetById", null) and result.get("spawner", null) == canonical.get("spawner", null) and result.get("spawnerUnitId", null) == canonical.get("spawnerUnitId", null)}

static func generated_unit_tether_comp_after_sync_bridge_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/UnitTetherComp.gd", "java_method_afterSync_1", [spawner_unit_id, groups_unit_get_by_id_result], null)
	var canonical = after_sync_state(spawner_unit_id, groups_unit_get_by_id_result)
	return {"source_owner": "PortGame.source_unit_tether_after_sync_state", "generated_owner": "UnitTetherComp.java_method_afterSync_1", "result": result, "canonical": canonical, "matches": result.get("guard", null) == canonical.get("guard", null) and result.get("groupsUnitGetById", null) == canonical.get("groupsUnitGetById", null) and result.get("spawner", null) == canonical.get("spawner", null) and result.get("spawnerUnitId", null) == canonical.get("spawnerUnitId", null)}

static func generated_unit_tether_comp_update_bridge_state(spawner_exists: bool, spawner_is_valid: bool, spawner_team_value: Variant, team_value: Variant, unit_id: int, spawner_id: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/UnitTetherComp.gd", "java_method_update_2", [spawner_exists, spawner_is_valid, spawner_team_value, team_value, unit_id, spawner_id], null)
	var canonical = update_state(spawner_exists, spawner_is_valid, spawner_team_value, team_value, unit_id, spawner_id)
	return {"source_owner": "PortGame.source_unit_tether_update_state", "generated_owner": "UnitTetherComp.java_method_update_2", "result": result, "canonical": canonical, "matches": result.get("guard", null) == canonical.get("guard", null) and result.get("despawn", null) == canonical.get("despawn", null) and result.get("spawnerUnitId", null) == canonical.get("spawnerUnitId", null)}
