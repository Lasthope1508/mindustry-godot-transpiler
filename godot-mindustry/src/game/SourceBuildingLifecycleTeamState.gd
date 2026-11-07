extends RefCounted
class_name SourceBuildingLifecycleTeamState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_LIFECYCLE_TEAM_JAVA_METHOD_CHANGE_TEAM_180 := source_building_source_text_state.SOURCE_BUILDING_LIFECYCLE_TEAM_JAVA_METHOD_CHANGE_TEAM_180
const SOURCE_BUILDING_LIFECYCLE_TEAM_JAVA_METHOD_CHANGE_TEAM_181 := source_building_source_text_state.SOURCE_BUILDING_LIFECYCLE_TEAM_JAVA_METHOD_CHANGE_TEAM_181
const SOURCE_BUILDING_LIFECYCLE_TEAM_GENERATED_OWNER_CHANGE_TEAM_180 := source_building_source_text_state.SOURCE_BUILDING_LIFECYCLE_TEAM_GENERATED_OWNER_CHANGE_TEAM_180
const SOURCE_BUILDING_LIFECYCLE_TEAM_GENERATED_OWNER_CHANGE_TEAM_181 := source_building_source_text_state.SOURCE_BUILDING_LIFECYCLE_TEAM_GENERATED_OWNER_CHANGE_TEAM_181

static func change_team_delegate_state(next_team: Variant) -> Dictionary:
	return {
		"next_team": next_team,
		"delegates_to_change_team": true,
		"update_power": true,
	}

static func change_team_initial_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	if current_team == next_team:
		return {
			"team": current_team,
			"last_team": current_team,
			"returned": true,
			"remove_index": false,
			"assign_next": false,
		}
	var team_after_force = force_team if force_team != null else current_team
	var last_team = team_after_force
	if last_team == next_team:
		return {
			"team": team_after_force,
			"last_team": last_team,
			"returned": true,
			"remove_index": false,
			"assign_next": false,
		}
	return {
		"team": next_team,
		"last_team": last_team,
		"returned": false,
		"remove_index": was_valid,
		"assign_next": true,
	}

static func change_team_power_proximity_state(power_present: bool, update_power: bool, old_graph: Variant, team: Variant) -> Dictionary:
	if power_present and update_power:
		return {
			"old_graph": old_graph,
			"team": team,
			"proximity_reflow": true,
		}
	return {
		"old_graph": old_graph,
		"team": team,
		"proximity_reflow": false,
	}

static func change_team_power_links_state(link_count: int, team: Variant, old_graph: Variant) -> Dictionary:
	if link_count <= 0:
		return {
			"link_count": link_count,
			"team": team,
			"old_graph": old_graph,
			"remove_index": false,
			"reflow_self": false,
			"update_power_graph": false,
		}
	return {
		"link_count": link_count,
		"team": team,
		"old_graph": old_graph,
		"remove_index": true,
		"reflow_self": true,
		"update_power_graph": true,
	}

static func change_team_final_state(was: bool, last_team: Variant) -> Dictionary:
	return {
		"was": was,
		"add_index": was,
		"team_change_event": was,
		"event_last": last_team,
		"check_allow_update": true,
	}

static func generated_change_team_delegate_bridge_state(next_team: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, SOURCE_BUILDING_LIFECYCLE_TEAM_JAVA_METHOD_CHANGE_TEAM_180, [next_team], null)
	var canonical = change_team_delegate_state(next_team)
	canonical["comment"] = "/** Changes this building's team in a safe manner. */"
	canonical["method"] = "public void changeTeam(Team next){"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHANGE_TEAM_DELEGATE_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_TEAM_GENERATED_OWNER_CHANGE_TEAM_180,
		"result": result,
		"canonical": canonical,
	}

static func generated_change_team_initial_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, SOURCE_BUILDING_LIFECYCLE_TEAM_JAVA_METHOD_CHANGE_TEAM_181, [current_team, next_team, force_team, was_valid], null)
	var canonical = change_team_initial_state(current_team, next_team, force_team, was_valid)
	canonical["comment"] = "/** Changes this building's team in a safe manner. */"
	canonical["method"] = "public void changeTeam(Team next, boolean updatePower){"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHANGE_TEAM_INITIAL_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_TEAM_GENERATED_OWNER_CHANGE_TEAM_181,
		"result": result,
		"canonical": canonical,
	}

static func generated_change_team_power_proximity_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, SOURCE_BUILDING_LIFECYCLE_TEAM_JAVA_METHOD_CHANGE_TEAM_181, [current_team, next_team, force_team, was_valid, power_present, update_power, old_graph], null)
	var canonical = change_team_power_proximity_state(power_present, update_power, old_graph, next_team)
	canonical["gate"] = "if(power != null && updatePower){"
	canonical["method"] = "public void changeTeam(Team next, boolean updatePower){"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHANGE_TEAM_POWER_PROXIMITY_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_TEAM_GENERATED_OWNER_CHANGE_TEAM_181,
		"result": result,
		"canonical": canonical,
	}

static func generated_change_team_power_links_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant, link_count: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, SOURCE_BUILDING_LIFECYCLE_TEAM_JAVA_METHOD_CHANGE_TEAM_181, [current_team, next_team, force_team, was_valid, power_present, update_power, old_graph, link_count], null)
	var canonical = change_team_power_links_state(link_count if power_present and update_power else 0, next_team, old_graph)
	canonical["loop"] = "for(int i = 0; i < power.links.size; i++){"
	canonical["method"] = "public void changeTeam(Team next, boolean updatePower){"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHANGE_TEAM_POWER_LINKS_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_TEAM_GENERATED_OWNER_CHANGE_TEAM_181,
		"result": result,
		"canonical": canonical,
	}

static func generated_change_team_final_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant, link_count: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, SOURCE_BUILDING_LIFECYCLE_TEAM_JAVA_METHOD_CHANGE_TEAM_181, [current_team, next_team, force_team, was_valid, power_present, update_power, old_graph, link_count], null)
	var team_after_force = force_team if force_team != null else current_team
	var last_team = team_after_force
	var canonical = change_team_final_state(was_valid, last_team)
	canonical["method"] = "public void changeTeam(Team next, boolean updatePower){"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHANGE_TEAM_FINAL_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_TEAM_GENERATED_OWNER_CHANGE_TEAM_181,
		"result": result,
		"canonical": canonical,
	}
