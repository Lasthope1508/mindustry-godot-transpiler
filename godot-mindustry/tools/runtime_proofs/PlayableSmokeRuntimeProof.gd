extends Node

const main_scene := preload("res://scenes/Main.tscn")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

const SCREENSHOT_PATH := "res://tools/runtime_proofs/PlayableSmokeRuntimeProof.png"
const PROOF_PATH := "res://tools/runtime_proofs/PlayableSmokeRuntimeProof.json"

func _ready() -> void:
	var game := main_scene.instantiate()
	add_child(game)
	await _wait_frames(12)
	if game.has_method("apply_world_viewport_fit"):
		game.call("apply_world_viewport_fit")
	await _wait_frames(4)

	var camera = game.get("camera")
	var camera_before: Vector2 = camera.position if camera is Camera2D else Vector2.ZERO
	var camera_zoom: Vector2 = camera.zoom if camera is Camera2D else Vector2.ZERO
	await RenderingServer.frame_post_draw
	var screenshot_absolute_path := ProjectSettings.globalize_path(SCREENSHOT_PATH)
	var screenshot_image := get_viewport().get_texture().get_image()
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

	var terrain_layer := game.get_node_or_null("World/TerrainLayer")
	var block_layer := game.get_node_or_null("World/BlockLayer")
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "PlayableSmokeRuntimeProof",
		"terrain_sprite_count": terrain_layer.get_child_count() if terrain_layer else 0,
		"block_sprite_count": block_layer.get_child_count() if block_layer else 0,
		"camera_before": {"x": camera_before.x, "y": camera_before.y},
		"camera_after": {"x": camera_after.x, "y": camera_after.y},
		"camera_zoom": {"x": camera_zoom.x, "y": camera_zoom.y},
		"camera_moved_by_input": camera_after.distance_to(camera_before) > 0.5,
		"screenshot_path": screenshot_absolute_path,
		"screenshot_width": screenshot_image.get_width() if screenshot_image != null else 0,
		"screenshot_height": screenshot_image.get_height() if screenshot_image != null else 0,
		"screenshot_save_error": screenshot_save_error,
		"screenshot_nonempty": screenshot_nonempty,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = int(proof["terrain_sprite_count"]) > 0 and int(proof["block_sprite_count"]) > 0 and proof["camera_moved_by_input"] and proof["screenshot_nonempty"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("PLAYABLE_SMOKE_RUNTIME_PROOF " + proof_json)
	var proof_file := FileAccess.open(ProjectSettings.globalize_path(PROOF_PATH), FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()

	game.queue_free()
	await _wait_frames(2)
	get_tree().quit(0)

func _wait_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame
