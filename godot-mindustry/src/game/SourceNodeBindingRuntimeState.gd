extends RefCounted
class_name SourceNodeBindingRuntimeState

const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_campaign_shell_ui_state := preload("res://src/game/SourceCampaignShellUiState.gd")

static func bind_nodes(game: Node) -> void:
	var camera := game.get_node_or_null(source_ui_defaults.CAMERA_NODE_PATH)
	game.set("camera", camera)
	if camera is Camera2D:
		if camera.is_inside_tree():
			camera.make_current()
		var viewport := game.get_viewport()
		var viewport_fit := Callable(game, "apply_world_viewport_fit")
		if viewport != null and not viewport.size_changed.is_connected(viewport_fit):
			viewport.size_changed.connect(viewport_fit)
	var hud_label := Label.new()
	hud_label.position = source_ui_defaults.HUD_LABEL_POSITION
	game.set("hud_label", hud_label)
	var hud := game.get_node_or_null(source_ui_defaults.HUD_NODE_PATH)
	if hud:
		hud.add_child(hud_label)
	source_campaign_shell_ui_state.bind_campaign_shell_root(game)
