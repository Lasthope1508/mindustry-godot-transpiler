extends RefCounted
class_name SourceInputViewportRuntimeState

const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_world_viewport := preload("res://src/game/SourceWorldViewport.gd")


static func camera_pan_delta(movement: Vector2, boosted: bool, delta: float, source_tick_rate: float) -> Vector2:
	return movement * source_input_defaults.camera_pan_speed_per_second(boosted, source_tick_rate) * delta

static func game_camera_pan_delta(_game: Object, movement: Vector2, boosted: bool, delta: float) -> Vector2:
	return camera_pan_delta(movement, boosted, delta, source_time_defaults.TICK_RATE)


static func camera_zoom_state(current_zoom: Vector2, zoom_factor: float) -> Dictionary:
	var zoom := current_zoom * zoom_factor
	return {"x": zoom.x, "y": zoom.y, "zoom_factor": zoom_factor}


static func viewport_fit_camera_state(world_cells: Vector2i, tile_size: int, viewport_size: Vector2) -> Dictionary:
	return source_world_viewport.fit_state(world_cells, tile_size, viewport_size)

static func viewport_fit_camera_state_with_zoom(world_cells: Vector2i, tile_size: int, viewport_size: Vector2, camera_zoom: Vector2) -> Dictionary:
	return source_world_viewport.fit_state_with_zoom(world_cells, tile_size, viewport_size, camera_zoom)

static func viewport_fit_camera_runtime_state(game: Object, viewport_size: Vector2) -> Dictionary:
	var world_cells := viewport_world_cells(viewport_size)
	var tile_size := int(game.get("tile_size"))
	var camera_zoom := source_playable_scenario_defaults.display_camera_zoom_for_viewport(Vector2i(int(viewport_size.x), int(viewport_size.y)))
	return viewport_fit_camera_state_with_zoom(world_cells, tile_size, viewport_size, camera_zoom)

static func playable_camera_focus_position(game: Object) -> Variant:
	if game == null or not bool(game.get("campaign_shell_entered_playable")):
		return null
	if game.has_method("grid_to_world"):
		return game.call("grid_to_world", game.get("core_pos"))
	return null


static func screen_to_world_state(screen_position: Vector2, camera_position: Vector2, camera_zoom: Vector2, viewport_size: Vector2) -> Dictionary:
	var safe_zoom := source_world_viewport.safe_camera_zoom(camera_zoom)
	var centered_screen := screen_position - (viewport_size * 0.5)
	var world_position := camera_position + Vector2(centered_screen.x / safe_zoom.x, centered_screen.y / safe_zoom.y)
	return {"x": world_position.x, "y": world_position.y}


static func clamped_camera_position_state(proposed_position: Vector2, world_cells: Vector2i, tile_size: int, viewport_size: Vector2, camera_zoom: Vector2) -> Dictionary:
	return source_world_viewport.clamped_camera_position_state(proposed_position, world_cells, tile_size, viewport_size, camera_zoom)

static func viewport_world_cells(viewport_size: Vector2) -> Vector2i:
	return source_playable_scenario_defaults.display_world_size_for_viewport(Vector2i(int(viewport_size.x), int(viewport_size.y)))


static func screen_to_world_runtime_state(game: Object, screen_position: Vector2) -> Dictionary:
	var camera = game.get("camera")
	if camera == null:
		return {"x": screen_position.x, "y": screen_position.y}
	var viewport = game.call("get_viewport")
	var viewport_size: Vector2 = viewport.get_visible_rect().size if viewport else Vector2.ZERO
	return screen_to_world_state(screen_position, camera.position, camera.zoom, viewport_size)


static func clamped_camera_position_runtime_state(game: Object, proposed_position: Vector2, viewport_size: Vector2) -> Dictionary:
	var camera = game.get("camera")
	if camera == null:
		return {"x": proposed_position.x, "y": proposed_position.y, "clamped": false}
	return clamped_camera_position_state(proposed_position, viewport_world_cells(viewport_size), int(game.get("tile_size")), viewport_size, camera.zoom)

static func apply_world_viewport_fit(game: Object) -> void:
	if game.camera == null:
		return
	var playable_focus: Variant = playable_camera_focus_position(game)
	if playable_focus is Vector2:
		game.camera.position = playable_focus
		return
	var fit: Dictionary = game.source_input_viewport_fit_camera_state(game.get_viewport().get_visible_rect().size)
	var camera_position: Dictionary = fit.get("camera_position", {})
	var camera_zoom: Dictionary = fit.get("camera_zoom", {})
	game.camera.position = Vector2(float(camera_position.get("x", 0.0)), float(camera_position.get("y", 0.0)))
	game.camera.zoom = Vector2(float(camera_zoom.get("x", 1.0)), float(camera_zoom.get("y", 1.0)))

static func world_viewport_fit_runtime_state(game: Object) -> Dictionary:
	var fit: Dictionary = game.source_input_viewport_fit_camera_state(game.get_viewport().get_visible_rect().size)
	fit["camera_position_actual"] = {"x": game.camera.position.x if game.camera else 0.0, "y": game.camera.position.y if game.camera else 0.0}
	fit["camera_zoom_actual"] = {"x": game.camera.zoom.x if game.camera else 1.0, "y": game.camera.zoom.y if game.camera else 1.0}
	fit["camera_bounds"] = game.source_input_viewport_clamped_camera_position_state(game.camera.position if game.camera else Vector2.ZERO, game.get_viewport().get_visible_rect().size).get("camera_bounds", {})
	return fit


static func update_camera(game: Object, delta: float) -> void:
	var camera = game.get("camera")
	if camera == null:
		return
	var input_runtime = game.get("input_runtime")
	if input_runtime == null:
		return
	var movement: Vector2 = input_runtime.movement_vector()
	if movement == Vector2.ZERO:
		return
	var viewport = game.call("get_viewport")
	var viewport_size: Vector2 = viewport.get_visible_rect().size if viewport else Vector2.ZERO
	var pan_delta := game_camera_pan_delta(game, movement, source_input_defaults.boost_pressed(), delta)
	var world_cells := viewport_world_cells(viewport_size)
	var clamp_state := clamped_camera_position_state(camera.position + pan_delta, world_cells, int(game.get("tile_size")), viewport_size, camera.zoom)
	camera.position = Vector2(float(clamp_state.get("x", camera.position.x)), float(clamp_state.get("y", camera.position.y)))
