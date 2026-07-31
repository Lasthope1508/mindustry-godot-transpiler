extends RefCounted
class_name SourceBuildingTetherState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func update_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	var guard: bool = (not building_exists) or (not building_is_valid) or building_team_value != team_value
	var despawn_call: Variant = null
	if guard:
		despawn_call = {"call": "Call.unitDespawn(self())", "unit": unit_id}
	return {
		"method": "public void update(){",
		"guard_expr": "if(building == null || !building.isValid() || building.team != team){",
		"call": "Call.unitDespawn(self())",
		"unit": unit_id,
		"despawn": despawn_call,
		"guard": guard,
		"building_exists": building_exists,
		"building_is_valid": building_is_valid,
		"building_team_value": building_team_value,
		"team_value": team_value,
	}

static func generated_building_tether_update_bridge_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingTetherComp.gd", "java_method_update_0", [building_exists, building_is_valid, building_team_value, team_value, unit_id], null)
	var canonical = update_state(building_exists, building_is_valid, building_team_value, team_value, unit_id)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_TETHER_UPDATE_STATE,
		"generated_owner": "building_tether_comp.java_method_update_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("guard", null) == canonical.get("guard", null) and result.get("despawn", null) == canonical.get("despawn", null),
	}
