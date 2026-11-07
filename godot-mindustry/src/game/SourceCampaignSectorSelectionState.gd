extends RefCounted
class_name SourceCampaignSectorSelectionState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_campaign_sector_state := preload("res://src/game/SourceCampaignSectorState.gd")
const source_campaign_sector_preset_source_text_state := preload("res://src/game/SourceCampaignSectorPresetSourceTextState.gd")
const source_campaign_sector_localization_state := preload("res://src/game/SourceCampaignSectorLocalizationState.gd")

static func serpulo_selection_state(requested_sector_id: String = "") -> Dictionary:
	return selection_state(
		source_campaign_sector_state.serpulo_sector_list_state(),
		source_campaign_sector_preset_source_text_state.SOURCE_SERPULO_ALWAYS_UNLOCKED_PRESET_SOURCE,
		requested_sector_id
	)

static func selection_state(sector_list_state: Dictionary, source_text: String, requested_sector_id: String = "") -> Dictionary:
	var planet_id := str(sector_list_state.get("planet_id", "serpulo"))
	var always_unlocked_ids := always_unlocked_sector_ids(source_text, planet_id)
	var visible_sectors: Array = sector_list_state.get("visible_sectors", [])
	var selected_id := requested_sector_id
	var selected_sector := _visible_sector_for_id(visible_sectors, selected_id)
	if selected_sector.is_empty():
		for default_id in always_unlocked_ids:
			selected_sector = _visible_sector_for_id(visible_sectors, str(default_id))
			if not selected_sector.is_empty():
				selected_id = str(default_id)
				break
	if selected_sector.is_empty() and not visible_sectors.is_empty():
		selected_sector = visible_sectors[0]
		selected_id = str(selected_sector.get("id", ""))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_SECTOR_SELECTION_STATE,
		"source": source_campaign_sector_preset_source_text_state.SOURCE_SECTOR_PRESETS_JAVA,
		"planet_id": planet_id,
		"requested_sector_id": requested_sector_id,
		"default_sector_id": str(always_unlocked_ids[0]) if not always_unlocked_ids.is_empty() else "",
		"selected_sector_id": selected_id,
		"selected_sector": selected_sector,
		"selected_sector_localization": source_campaign_sector_localization_state.sector_localization_state_from_bundle(selected_id),
		"always_unlocked_sector_ids": always_unlocked_ids,
		"valid_selection": not selected_sector.is_empty(),
	}

static func always_unlocked_sector_ids(source_text: String, planet_var: String) -> Array:
	var ids := []
	var active_id := ""
	for raw_line in source_text.split("\n"):
		var line := raw_line.strip_edges()
		if line.contains("new SectorPreset(") and line.contains(", " + planet_var + ","):
			active_id = _extract_sector_preset_id(line)
		elif not active_id.is_empty() and line.contains("alwaysUnlocked = true;"):
			ids.append(active_id)
		elif not active_id.is_empty() and line.contains("}};"):
			active_id = ""
	return ids

static func _visible_sector_for_id(visible_sectors: Array, sector_id: String) -> Dictionary:
	if sector_id.is_empty():
		return {}
	for sector in visible_sectors:
		if str(sector.get("id", "")) == sector_id and not bool(sector.get("hidden", false)):
			return sector
	return {}

static func _extract_sector_preset_id(line: String) -> String:
	var marker := "new SectorPreset(\""
	var start := line.find(marker)
	if start < 0:
		return ""
	start += marker.length()
	var end := line.find("\"", start)
	if end < start:
		return ""
	return line.substr(start, end - start)
