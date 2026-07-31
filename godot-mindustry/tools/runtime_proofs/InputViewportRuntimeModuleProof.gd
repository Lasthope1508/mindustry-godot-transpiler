extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_input_viewport_runtime_state := preload("res://src/game/SourceInputViewportRuntimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func seed_port_game_scene(game: Node) -> void:
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	game.add_child(camera)
	var world := Node2D.new()
	world.name = "World"
	game.add_child(world)
	for layer_name in ["TerrainLayer", "BlockLayer", "UnitLayer"]:
		var layer := Node2D.new()
		layer.name = layer_name
		world.add_child(layer)
	var ui := CanvasLayer.new()
	ui.name = "UI"
	game.add_child(ui)
	var hud := Control.new()
	hud.name = "Hud"
	ui.add_child(hud)

func _ready() -> void:
	var wrapper_game := PortGameScript.new()
	var module_game := PortGameScript.new()
	var null_wrapper_game := PortGameScript.new()
	var null_module_game := PortGameScript.new()
	seed_port_game_scene(wrapper_game)
	seed_port_game_scene(module_game)
	add_child(wrapper_game)
	add_child(module_game)
	wrapper_game.camera.position = Vector2(64.0, 32.0)
	module_game.camera.position = Vector2(64.0, 32.0)
	wrapper_game.camera.zoom = Vector2(1.5, 1.5)
	module_game.camera.zoom = Vector2(1.5, 1.5)
	var wrapper_fit := wrapper_game.source_input_viewport_fit_camera_state(Vector2(320.0, 180.0))
	var module_fit := module_game.source_input_viewport_fit_camera_state(Vector2(320.0, 180.0))
	var null_wrapper_screen := null_wrapper_game.source_input_viewport_screen_to_world_state(Vector2(24.0, 36.0))
	var null_module_screen := source_input_viewport_runtime_state.screen_to_world_runtime_state(null_module_game, Vector2(24.0, 36.0))
	var null_wrapper_clamp := null_wrapper_game.source_input_viewport_clamped_camera_position_state(Vector2(88.0, 64.0), Vector2(320.0, 180.0))
	var null_module_clamp := source_input_viewport_runtime_state.clamped_camera_position_runtime_state(null_module_game, Vector2(88.0, 64.0), Vector2(320.0, 180.0))
	wrapper_game.apply_world_viewport_fit()
	source_input_viewport_runtime_state.apply_world_viewport_fit(module_game)
	var wrapper_runtime := wrapper_game.world_viewport_fit_runtime_state()
	var module_runtime := source_input_viewport_runtime_state.world_viewport_fit_runtime_state(module_game)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceInputViewportRuntimeState",
		"fit_matches": wrapper_fit == module_fit,
		"screen_matches": null_wrapper_screen == null_module_screen,
		"clamp_matches": null_wrapper_clamp == null_module_clamp,
		"runtime_matches": wrapper_runtime == module_runtime,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["fit_matches"] and proof["screen_matches"] and proof["clamp_matches"] and proof["runtime_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("INPUT_VIEWPORT_RUNTIME_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/InputViewportRuntimeModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	wrapper_game.queue_free()
	module_game.queue_free()
	null_wrapper_game.free()
	null_module_game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
