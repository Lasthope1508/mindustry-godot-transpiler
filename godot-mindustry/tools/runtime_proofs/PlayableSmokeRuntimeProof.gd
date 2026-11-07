extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const main_scene := preload("res://scenes/Main.tscn")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const control_input_binding_registry := preload("res://src/game/ControlInputBindingRegistry.gd")

const SCREENSHOT_PATH := "res://tools/runtime_proofs/PlayableSmokeRuntimeProof.png"

func _ready() -> void:
	var game := main_scene.instantiate()
	add_child(game)
	await _wait_frames(12)
	if game.has_method("apply_world_viewport_fit"):
		game.call("apply_world_viewport_fit")
	await _wait_frames(4)
	var launch_state: Dictionary = game.call("enter_campaign_playable_slice")
	await _wait_frames(4)

	var camera = game.get("camera")
	var camera_before: Vector2 = camera.position if camera is Camera2D else Vector2.ZERO
	var camera_zoom: Vector2 = camera.zoom if camera is Camera2D else Vector2.ZERO
	await _wait_for_render_frame()
	var screenshot_absolute_path := ProjectSettings.globalize_path(SCREENSHOT_PATH)
	var screenshot_required := DisplayServer.get_name() != "headless"
	var screenshot_image: Image = null
	if screenshot_required:
		var viewport_texture := get_viewport().get_texture()
		if viewport_texture != null:
			if viewport_texture.get_rid().is_valid():
				screenshot_image = viewport_texture.get_image()
	var screenshot_save_error := ERR_CANT_CREATE
	if screenshot_image != null and screenshot_image.get_width() > 0 and screenshot_image.get_height() > 0:
		screenshot_save_error = screenshot_image.save_png(screenshot_absolute_path)
	var screenshot_nonempty := FileAccess.file_exists(screenshot_absolute_path) and FileAccess.get_file_as_bytes(screenshot_absolute_path).size() > 1024

	Input.action_press("camera.pan.right")
	Input.action_press("camera.pan.down")
	await _wait_frames(24)
	Input.action_release("camera.pan.right")
	Input.action_release("camera.pan.down")
	await _wait_frames(2)
	var camera_after: Vector2 = camera.position if camera is Camera2D else Vector2.ZERO

	if camera is Camera2D:
		camera.position = camera_before
	await _wait_frames(2)
	var camera_before_physical_wasd: Vector2 = camera.position if camera is Camera2D else Vector2.ZERO
	_parse_physical_key("D", true)
	_parse_physical_key("S", true)
	await _wait_frames(24)
	_parse_physical_key("D", false)
	_parse_physical_key("S", false)
	await _wait_frames(2)
	var camera_after_physical_wasd: Vector2 = camera.position if camera is Camera2D else Vector2.ZERO

	var terrain_layer := game.get_node_or_null("World/TerrainLayer")
	var block_layer := game.get_node_or_null("World/BlockLayer")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "PlayableSmokeRuntimeProof",
		"terrain_sprite_count": terrain_layer.get_child_count() if terrain_layer else 0,
		"block_sprite_count": block_layer.get_child_count() if block_layer else 0,
		"camera_before": {"x": camera_before.x, "y": camera_before.y},
		"camera_after": {"x": camera_after.x, "y": camera_after.y},
		"camera_before_physical_wasd": {"x": camera_before_physical_wasd.x, "y": camera_before_physical_wasd.y},
		"camera_after_physical_wasd": {"x": camera_after_physical_wasd.x, "y": camera_after_physical_wasd.y},
		"camera_zoom": {"x": camera_zoom.x, "y": camera_zoom.y},
		"campaign_shell_hidden_after_launch": not launch_state.get("visible", true),
		"hud_visible_after_launch": launch_state.get("hud_visible", false),
		"entered_playable": bool(game.get("campaign_shell_entered_playable")),
		"camera_moved_by_input": camera_after.distance_to(camera_before) > 0.5,
		"camera_moved_by_physical_wasd": camera_after_physical_wasd.distance_to(camera_before_physical_wasd) > 0.5,
		"screenshot_path": screenshot_absolute_path,
		"screenshot_width": screenshot_image.get_width() if screenshot_image != null else 0,
		"screenshot_height": screenshot_image.get_height() if screenshot_image != null else 0,
		"screenshot_save_error": screenshot_save_error,
		"screenshot_nonempty": screenshot_nonempty,
		"screenshot_required": screenshot_required,
		"screenshot_ok": not screenshot_required or screenshot_nonempty,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = int(proof["terrain_sprite_count"]) > 0 and int(proof["block_sprite_count"]) > 0 and proof["campaign_shell_hidden_after_launch"] and proof["hud_visible_after_launch"] and proof["entered_playable"] and proof["camera_moved_by_input"] and proof["camera_moved_by_physical_wasd"] and proof["screenshot_ok"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("PLAYABLE_SMOKE_RUNTIME_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PlayableSmokeRuntimeProof", proof)

	if not bool(proof["matches"]):
		push_error("PLAYABLE_SMOKE_RUNTIME_PROOF failed " + JSON.stringify(proof))
	game.queue_free()
	await _wait_frames(2)
	get_tree().quit(runtime_proof_state.exit_code(proof))

func _wait_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame

func _parse_physical_key(key_label: String, pressed: bool) -> void:
	var event := control_input_binding_registry.key_event_for_label(key_label, pressed)
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _wait_for_render_frame() -> void:
	if DisplayServer.get_name() == "headless":
		await get_tree().process_frame
		return
	await RenderingServer.frame_post_draw

