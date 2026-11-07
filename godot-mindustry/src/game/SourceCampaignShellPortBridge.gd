extends "res://src/game/SourcePlayableWorldRuntimePortBridge.gd"

const source_campaign_shell_state_module := preload("res://src/game/SourceCampaignShellState.gd")
const source_campaign_shell_ui_state := preload("res://src/game/SourceCampaignShellUiState.gd")
const source_campaign_sector_state := preload("res://src/game/SourceCampaignSectorState.gd")
const source_campaign_sector_selection_state_module := preload("res://src/game/SourceCampaignSectorSelectionState.gd")
const source_campaign_launch_context_state_module := preload("res://src/game/SourceCampaignLaunchContextState.gd")
const source_campaign_map_file_state_module := preload("res://src/game/SourceCampaignMapFileState.gd")
const source_campaign_map_content_header_state_module := preload("res://src/game/SourceCampaignMapContentHeaderState.gd")
const source_campaign_map_tile_state_module := preload("res://src/game/SourceCampaignMapTileState.gd")

func source_campaign_shell_state() -> Dictionary:
	return source_campaign_shell_state_module.campaign_shell_state_from_bundle()

func source_campaign_sector_list_state() -> Dictionary:
	return source_campaign_sector_state.serpulo_sector_list_state()

func source_campaign_sector_selection_state() -> Dictionary:
	return source_campaign_sector_selection_state_module.serpulo_selection_state(str(get("campaign_selected_sector_id")))

func select_campaign_sector(sector_id: String) -> Dictionary:
	set("campaign_selected_sector_id", sector_id)
	return source_campaign_sector_selection_state()

func source_campaign_launch_context_state() -> Dictionary:
	return source_campaign_launch_context_state_module.game_launch_context_state(self)

func source_campaign_map_file_state() -> Dictionary:
	return source_campaign_map_file_state_module.launch_context_map_file_state(source_campaign_launch_context_state())

func source_campaign_map_content_header_state() -> Dictionary:
	return source_campaign_map_content_header_state_module.campaign_map_content_header_state(source_campaign_map_file_state())

func source_campaign_map_tile_state() -> Dictionary:
	return source_campaign_map_tile_state_module.campaign_map_tile_state(source_campaign_map_file_state(), source_campaign_map_content_header_state())

func build_campaign_shell() -> Dictionary:
	return source_campaign_shell_ui_state.build_campaign_shell(self)

func update_campaign_shell() -> Dictionary:
	return source_campaign_shell_ui_state.update_campaign_shell(self)

func enter_campaign_playable_slice() -> Dictionary:
	return source_campaign_shell_ui_state.enter_playable_slice(self)
