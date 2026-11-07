extends RefCounted
class_name SourceCampaignSectorLocalizationState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_campaign_shell_state := preload("res://src/game/SourceCampaignShellState.gd")

const KEY_SECTOR_PREFIX := "sector."
const KEY_NAME_SUFFIX := ".name"
const KEY_DESCRIPTION_SUFFIX := ".description"

static func sector_localization_state_from_bundle(sector_id: String) -> Dictionary:
	return sector_localization_state(FileAccess.get_file_as_string(source_campaign_shell_state.SOURCE_BUNDLE_PATH), sector_id)

static func sector_localization_state(bundle_text: String, sector_id: String) -> Dictionary:
	var bundle_state := source_campaign_shell_state.bundle_text_state(bundle_text)
	var name_key := KEY_SECTOR_PREFIX + sector_id + KEY_NAME_SUFFIX
	var description_key := KEY_SECTOR_PREFIX + sector_id + KEY_DESCRIPTION_SUFFIX
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_SECTOR_LOCALIZATION_STATE,
		"bundle_path": source_campaign_shell_state.SOURCE_BUNDLE_PATH,
		"sector_id": sector_id,
		"name_key": name_key,
		"description_key": description_key,
		"name": str(bundle_state.get(name_key, "")),
		"description": str(bundle_state.get(description_key, "")),
	}
