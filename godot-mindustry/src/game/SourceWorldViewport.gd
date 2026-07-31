extends RefCounted
class_name SourceWorldViewport

const CAMERA_ZOOM_MIN_COMPONENT := 0.001

static func safe_camera_zoom(camera_zoom: Vector2) -> Vector2:
	return Vector2(float(max(camera_zoom.x, CAMERA_ZOOM_MIN_COMPONENT)), float(max(camera_zoom.y, CAMERA_ZOOM_MIN_COMPONENT)))

static func world_pixel_size(world_cells: Vector2i, tile_size: int) -> Vector2:
	return Vector2(world_cells.x * tile_size, world_cells.y * tile_size)


static func world_center(world_cells: Vector2i, tile_size: int) -> Vector2:
	return world_pixel_size(world_cells, tile_size) * 0.5


static func visible_world_size(viewport_size: Vector2, camera_zoom: Vector2) -> Vector2:
	var safe_zoom := safe_camera_zoom(camera_zoom)
	return Vector2(viewport_size.x / safe_zoom.x, viewport_size.y / safe_zoom.y)


static func cover_zoom(viewport_size: Vector2, world_cells: Vector2i, tile_size: int) -> Vector2:
	var world_pixels := world_pixel_size(world_cells, tile_size)
	if world_pixels.x <= 0.0 or world_pixels.y <= 0.0:
		return Vector2.ONE
	var zoom_value: float = max(viewport_size.x / world_pixels.x, viewport_size.y / world_pixels.y)
	return Vector2(zoom_value, zoom_value)


static func camera_bounds_state(world_cells: Vector2i, tile_size: int, viewport_size: Vector2, camera_zoom: Vector2) -> Dictionary:
	var world_pixels := world_pixel_size(world_cells, tile_size)
	var visible_size := visible_world_size(viewport_size, camera_zoom)
	var slack := visible_size * 0.25
	var min_position := -slack
	var max_position := world_pixels + slack
	var center := world_center(world_cells, tile_size)
	return {
		"min": {"x": min_position.x, "y": min_position.y},
		"max": {"x": max_position.x, "y": max_position.y},
		"center": {"x": center.x, "y": center.y},
		"visible_world_size": {"x": visible_size.x, "y": visible_size.y},
	}


static func clamped_camera_position_state(proposed_position: Vector2, world_cells: Vector2i, tile_size: int, viewport_size: Vector2, camera_zoom: Vector2) -> Dictionary:
	var bounds := camera_bounds_state(world_cells, tile_size, viewport_size, camera_zoom)
	var min_state: Dictionary = bounds.get("min", {})
	var max_state: Dictionary = bounds.get("max", {})
	var visible_size := visible_world_size(viewport_size, camera_zoom)
	var min_position := Vector2(float(min_state.get("x", proposed_position.x)), float(min_state.get("y", proposed_position.y)))
	var max_position := Vector2(float(max_state.get("x", proposed_position.x)), float(max_state.get("y", proposed_position.y)))
	var clamped_position := Vector2(
		clampf(proposed_position.x, min_position.x, max_position.x),
		clampf(proposed_position.y, min_position.y, max_position.y)
	)
	return {
		"x": clamped_position.x,
		"y": clamped_position.y,
		"clamped": clamped_position != proposed_position,
		"visible_world_size": {"x": visible_size.x, "y": visible_size.y},
	}


static func fit_state(world_cells: Vector2i, tile_size: int, viewport_size: Vector2) -> Dictionary:
	var zoom := cover_zoom(viewport_size, world_cells, tile_size)
	return fit_state_with_zoom(world_cells, tile_size, viewport_size, zoom)

static func fit_state_with_zoom(world_cells: Vector2i, tile_size: int, viewport_size: Vector2, camera_zoom: Vector2) -> Dictionary:
	var center := world_center(world_cells, tile_size)
	return {
		"camera_position": {"x": center.x, "y": center.y},
		"camera_zoom": {"x": camera_zoom.x, "y": camera_zoom.y},
		"camera_bounds": camera_bounds_state(world_cells, tile_size, viewport_size, camera_zoom),
	}
