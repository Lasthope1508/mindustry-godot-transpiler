extends RefCounted
class_name SourceCampaignLaunchContextState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func game_launch_context_state(game: Object) -> Dictionary:
	return launch_context_state(game.call("source_campaign_sector_selection_state"))

static func launch_context_state(selection_state: Dictionary) -> Dictionary:
	var selected_sector: Dictionary = selection_state.get("selected_sector", {})
	var localization: Dictionary = selection_state.get("selected_sector_localization", {})
	var selected_sector_id := str(selection_state.get("selected_sector_id", selected_sector.get("id", "")))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_LAUNCH_CONTEXT_STATE,
		"planet_id": str(selection_state.get("planet_id", selected_sector.get("planet_id", ""))),
		"sector_id": selected_sector_id,
		"sector_name": str(localization.get("name", selected_sector_id)),
		"sector_description": str(localization.get("description", "")),
		"sector_path": str(selected_sector.get("path", "")),
		"sector_path_exists": FileAccess.file_exists(str(selected_sector.get("path", ""))),
		"selection_source_owner": str(selection_state.get("source_owner", "")),
		"localization_source_owner": str(localization.get("source_owner", "")),
	}
