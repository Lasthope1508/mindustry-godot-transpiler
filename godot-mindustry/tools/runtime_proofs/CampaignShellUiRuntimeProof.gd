extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const port_game := preload("res://src/game/PortGame.gd")
const source_campaign_shell_ui_state := preload("res://src/game/SourceCampaignShellUiState.gd")
const source_node_binding_runtime_state := preload("res://src/game/SourceNodeBindingRuntimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")

func _ready() -> void:
	var game := port_game.new()
	var camera := Camera2D.new()
	camera.name = source_ui_defaults.CAMERA_NODE_PATH
	var ui := CanvasLayer.new()
	ui.name = "UI"
	var hud := Control.new()
	hud.name = "Hud"
	ui.add_child(hud)
	game.add_child(camera)
	game.add_child(ui)
	source_node_binding_runtime_state.bind_nodes(game)
	var build_state := source_campaign_shell_ui_state.build_campaign_shell(game)
	var launch_state := game.enter_campaign_playable_slice()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceCampaignShellUiState",
		"build_state": build_state,
		"launch_state": launch_state,
		"campaign_shell_visible": build_state.get("visible", false),
		"hud_hidden": not build_state.get("hud_visible", true),
		"launch_hides_shell": not launch_state.get("visible", true),
		"launch_shows_hud": launch_state.get("hud_visible", false),
		"entered_playable": bool(game.campaign_shell_entered_playable),
		"root_name": game.campaign_shell_root.name if game.campaign_shell_root != null else "",
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["root_name"] == source_ui_defaults.CAMPAIGN_SHELL_NODE_NAME and proof["campaign_shell_visible"] and proof["hud_hidden"] and proof["launch_hides_shell"] and proof["launch_shows_hud"] and proof["entered_playable"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CAMPAIGN_SHELL_UI_RUNTIME_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("CampaignShellUiRuntimeProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

