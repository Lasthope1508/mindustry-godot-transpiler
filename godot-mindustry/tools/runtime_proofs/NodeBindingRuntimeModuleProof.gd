extends Node

const port_game := preload("res://src/game/PortGame.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_node_binding_runtime_state := preload("res://src/game/SourceNodeBindingRuntimeState.gd")

func _ready() -> void:
	var game := port_game.new()
	var camera := Camera2D.new()
	camera.name = source_ui_defaults.CAMERA_NODE_PATH
	var ui := Node.new()
	ui.name = "UI"
	var hud := Node.new()
	hud.name = "Hud"
	ui.add_child(hud)
	game.add_child(camera)
	game.add_child(ui)
	source_node_binding_runtime_state.bind_nodes(game)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceNodeBindingRuntimeState",
		"camera_bound": game.camera == camera,
		"hud_label_bound": game.hud_label != null and game.hud_label.get_parent() == hud,
		"hud_label_position_matches": game.hud_label != null and game.hud_label.position == source_ui_defaults.HUD_LABEL_POSITION,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("NODE_BINDING_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(20.0).timeout
