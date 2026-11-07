extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_input_viewport_runtime_state := preload("res://src/game/SourceInputViewportRuntimeState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

const PROOF_LABEL := "INPUT_VIEWPORT_RUNTIME_MODULE_PROOF"

func seed_port_game_scene(game: Node) -> void:
	game.set("tile_size", 16)
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
	var direct_module_fit := source_input_viewport_runtime_state.viewport_fit_camera_runtime_state(module_game, Vector2(320.0, 180.0))
	var null_wrapper_screen := null_wrapper_game.source_input_viewport_screen_to_world_state(Vector2(24.0, 36.0))
	var null_module_screen := source_input_viewport_runtime_state.screen_to_world_runtime_state(null_module_game, Vector2(24.0, 36.0))
	var null_wrapper_clamp := null_wrapper_game.source_input_viewport_clamped_camera_position_state(Vector2(88.0, 64.0), Vector2(320.0, 180.0))
	var null_module_clamp := source_input_viewport_runtime_state.clamped_camera_position_runtime_state(null_module_game, Vector2(88.0, 64.0), Vector2(320.0, 180.0))
	wrapper_game.apply_world_viewport_fit()
	source_input_viewport_runtime_state.apply_world_viewport_fit(module_game)
	var wrapper_runtime := wrapper_game.world_viewport_fit_runtime_state()
	var module_runtime := source_input_viewport_runtime_state.world_viewport_fit_runtime_state(module_game)
	var viewport_world_cells := source_input_viewport_runtime_state.viewport_world_cells(Vector2(320.0, 180.0))
	var expected_viewport_world_cells := source_playable_scenario_defaults.display_world_size_for_viewport(Vector2i(320, 180))
	var desktop_fit := source_input_viewport_runtime_state.viewport_fit_camera_runtime_state(module_game, Vector2(1280.0, 720.0))
	var mobile_portrait_fit := source_input_viewport_runtime_state.viewport_fit_camera_runtime_state(module_game, Vector2(720.0, 1280.0))
	var wide_fit := source_input_viewport_runtime_state.viewport_fit_camera_runtime_state(module_game, Vector2(1920.0, 1080.0))
	var desktop_coverage: Dictionary = desktop_fit.get("viewport_coverage", {})
	var mobile_portrait_coverage: Dictionary = mobile_portrait_fit.get("viewport_coverage", {})
	var wide_coverage: Dictionary = wide_fit.get("viewport_coverage", {})
	var desktop_viewport_covered := bool(desktop_fit.get("viewport_fully_covered", false)) and bool(desktop_coverage.get("viewport_fully_covered", false))
	var mobile_portrait_viewport_covered := bool(mobile_portrait_fit.get("viewport_fully_covered", false)) and bool(mobile_portrait_coverage.get("viewport_fully_covered", false))
	var wide_viewport_covered := bool(wide_fit.get("viewport_fully_covered", false)) and bool(wide_coverage.get("viewport_fully_covered", false))
	var viewport_coverage_matches := desktop_viewport_covered and mobile_portrait_viewport_covered and wide_viewport_covered
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": PROOF_LABEL,
		"fit_matches": wrapper_fit == module_fit,
		"direct_fit_matches": wrapper_fit == direct_module_fit,
		"screen_matches": null_wrapper_screen == null_module_screen,
		"clamp_matches": null_wrapper_clamp == null_module_clamp,
		"runtime_matches": wrapper_runtime == module_runtime,
		"viewport_world_cells_matches": viewport_world_cells == expected_viewport_world_cells,
		"desktop_viewport_covered": desktop_viewport_covered,
		"mobile_portrait_viewport_covered": mobile_portrait_viewport_covered,
		"wide_viewport_covered": wide_viewport_covered,
		"viewport_coverage_matches": viewport_coverage_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["fit_matches"] and proof["direct_fit_matches"] and proof["screen_matches"] and proof["clamp_matches"] and proof["runtime_matches"] and proof["viewport_world_cells_matches"] and proof["viewport_coverage_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("InputViewportRuntimeModuleProof", proof)
	wrapper_game.queue_free()
	module_game.queue_free()
	null_wrapper_game.free()
	null_module_game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

