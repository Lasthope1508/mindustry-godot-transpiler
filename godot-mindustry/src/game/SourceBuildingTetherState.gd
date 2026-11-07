extends RefCounted
class_name SourceBuildingTetherState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_entity_comp_source_text_state := preload("res://src/game/SourceEntityCompSourceTextState.gd")

const SOURCE_BUILDING_TETHER_COMP_GENERATED_CLASS := source_entity_comp_source_text_state.SOURCE_BUILDING_TETHER_COMP_GENERATED_CLASS
const SOURCE_BUILDING_TETHER_UPDATE_METHOD := source_entity_comp_source_text_state.SOURCE_BUILDING_TETHER_UPDATE_METHOD
const SOURCE_BUILDING_TETHER_UPDATE_GUARD_EXPR := source_entity_comp_source_text_state.SOURCE_BUILDING_TETHER_UPDATE_GUARD_EXPR
const SOURCE_BUILDING_TETHER_UPDATE_DESPAWN_CALL := source_entity_comp_source_text_state.SOURCE_BUILDING_TETHER_UPDATE_DESPAWN_CALL
const SOURCE_BUILDING_TETHER_UPDATE_JAVA_METHOD := source_entity_comp_source_text_state.SOURCE_BUILDING_TETHER_UPDATE_JAVA_METHOD
const SOURCE_BUILDING_TETHER_UPDATE_GENERATED_OWNER := source_entity_comp_source_text_state.SOURCE_BUILDING_TETHER_UPDATE_GENERATED_OWNER

static func _building_tether_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_TETHER_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func update_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	var guard: bool = (not building_exists) or (not building_is_valid) or building_team_value != team_value
	var despawn_call: Variant = null
	if guard:
		despawn_call = {"call": SOURCE_BUILDING_TETHER_UPDATE_DESPAWN_CALL, "unit": unit_id}
	return {
		"method": SOURCE_BUILDING_TETHER_UPDATE_METHOD,
		"guard_expr": SOURCE_BUILDING_TETHER_UPDATE_GUARD_EXPR,
		"call": SOURCE_BUILDING_TETHER_UPDATE_DESPAWN_CALL,
		"unit": unit_id,
		"despawn": despawn_call,
		"guard": guard,
		"building_exists": building_exists,
		"building_is_valid": building_is_valid,
		"building_team_value": building_team_value,
		"team_value": team_value,
	}

static func generated_building_tether_update_bridge_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	var result = _building_tether_comp_call(SOURCE_BUILDING_TETHER_UPDATE_JAVA_METHOD, [building_exists, building_is_valid, building_team_value, team_value, unit_id])
	var canonical = update_state(building_exists, building_is_valid, building_team_value, team_value, unit_id)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_TETHER_UPDATE_STATE,
		"generated_owner": SOURCE_BUILDING_TETHER_UPDATE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("guard", null) == canonical.get("guard", null) and result.get("despawn", null) == canonical.get("despawn", null),
	}
