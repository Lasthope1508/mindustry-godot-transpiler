extends RefCounted
class_name SourceCampaignShellUiState

const source_campaign_shell_state := preload("res://src/game/SourceCampaignShellState.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")

static func bind_campaign_shell_root(game: Node) -> Dictionary:
	var hud := game.get_node_or_null(source_ui_defaults.HUD_NODE_PATH)
	var root: Control = game.get("campaign_shell_root")
	if root == null and hud != null:
		root = PanelContainer.new()
		root.name = source_ui_defaults.CAMPAIGN_SHELL_NODE_NAME
		root.position = source_ui_defaults.CAMPAIGN_SHELL_POSITION
		root.custom_minimum_size = source_ui_defaults.CAMPAIGN_SHELL_MIN_SIZE
		hud.add_child(root)
		game.set("campaign_shell_root", root)
	if root != null:
		root.visible = bool(game.get("campaign_shell_visible"))
	return {
		"root_bound": root != null,
		"visible": root != null and root.visible,
	}

static func build_campaign_shell(game: Node) -> Dictionary:
	var bind_state := bind_campaign_shell_root(game)
	var root: Control = game.get("campaign_shell_root")
	if root == null:
		return bind_state
	var state: Dictionary = source_campaign_shell_state.campaign_shell_state_from_bundle()
	for child in root.get_children():
		root.remove_child(child)
		child.queue_free()
	var layout := VBoxContainer.new()
	layout.name = "CampaignShellContent"
	layout.add_child(_label(str(state.get("title", "")), source_ui_defaults.CAMPAIGN_SHELL_TITLE_FONT_SIZE))
	layout.add_child(_label(str(state.get("planet_map_label", "")), source_ui_defaults.CAMPAIGN_SHELL_BODY_FONT_SIZE))
	for planet in state.get("planets", []):
		layout.add_child(_label(str(planet.get("display_name", "")), source_ui_defaults.CAMPAIGN_SHELL_BODY_FONT_SIZE))
		layout.add_child(_label(str(planet.get("description", "")), source_ui_defaults.CAMPAIGN_SHELL_BODY_FONT_SIZE))
	var sector_state: Dictionary = game.call("source_campaign_sector_list_state")
	var selection_state: Dictionary = game.call("source_campaign_sector_selection_state")
	var selected_localization: Dictionary = selection_state.get("selected_sector_localization", {})
	layout.add_child(_label(str(sector_state.get("visible_sector_count", 0)) + " visible sectors / " + str(sector_state.get("hidden_sector_count", 0)) + " hidden sectors", source_ui_defaults.CAMPAIGN_SHELL_BODY_FONT_SIZE))
	layout.add_child(_label(source_ui_defaults.CAMPAIGN_SHELL_SELECTED_SECTOR_PREFIX + str(selected_localization.get("name", selection_state.get("selected_sector_id", ""))), source_ui_defaults.CAMPAIGN_SHELL_BODY_FONT_SIZE))
	layout.add_child(_label(str(selected_localization.get("description", "")), source_ui_defaults.CAMPAIGN_SHELL_BODY_FONT_SIZE))
	var sector_index := 0
	for sector in sector_state.get("sectors", []):
		if sector.get("hidden", false):
			continue
		if sector_index >= source_ui_defaults.CAMPAIGN_SHELL_SECTOR_PREVIEW_LIMIT:
			break
		var sector_button := Button.new()
		sector_button.text = str(sector.get("display_name", ""))
		sector_button.pressed.connect(func() -> void:
			game.call("select_campaign_sector", str(sector.get("id", "")))
			build_campaign_shell(game)
		)
		layout.add_child(sector_button)
		sector_index += 1
	var launch_button := Button.new()
	launch_button.name = "LaunchCoreButton"
	launch_button.text = str(state.get("launch_core_label", ""))
	launch_button.pressed.connect(Callable(game, "enter_campaign_playable_slice"))
	layout.add_child(launch_button)
	root.add_child(layout)
	return update_campaign_shell(game)

static func update_campaign_shell(game: Node) -> Dictionary:
	var root: Control = game.get("campaign_shell_root")
	var visible := bool(game.get("campaign_shell_visible"))
	if root != null:
		root.visible = visible
	var hud_label := game.get("hud_label") as Label
	if hud_label != null:
		hud_label.visible = not visible
	return {
		"root_bound": root != null,
		"visible": root != null and root.visible,
		"hud_visible": hud_label != null and hud_label.visible,
	}

static func enter_playable_slice(game: Node) -> Dictionary:
	var selection_state: Dictionary = game.call("source_campaign_sector_selection_state")
	game.set("campaign_launched_sector", selection_state.get("selected_sector", {}))
	game.set("campaign_launch_context", game.call("source_campaign_launch_context_state"))
	game.set("campaign_shell_visible", false)
	game.set("campaign_shell_entered_playable", true)
	if game.has_method("apply_world_viewport_fit"):
		game.call("apply_world_viewport_fit")
	return update_campaign_shell(game)

static func _label(text_value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text_value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	return label
