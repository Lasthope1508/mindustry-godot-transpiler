extends RefCounted
class_name DisplayProfileRuntime

const source_display_profile_source_text_state := preload("res://src/game/SourceDisplayProfileSourceTextState.gd")

const MODULE_NAME := "display_profile"
const SOURCE_CAMERA_CLAMP_EXPR := source_display_profile_source_text_state.SOURCE_CAMERA_CLAMP_EXPR
const SOURCE_CAMERA_CLAMP_VISIBLE_PADDING_EXPR := source_display_profile_source_text_state.SOURCE_CAMERA_CLAMP_VISIBLE_PADDING_EXPR
const SOURCE_RENDERER_CAMERA_WIDTH_EXPR := source_display_profile_source_text_state.SOURCE_RENDERER_CAMERA_WIDTH_EXPR
const SOURCE_RENDERER_CAMERA_HEIGHT_EXPR := source_display_profile_source_text_state.SOURCE_RENDERER_CAMERA_HEIGHT_EXPR
const SOURCE_RENDERER_MIN_SCALE_EXPR := source_display_profile_source_text_state.SOURCE_RENDERER_MIN_SCALE_EXPR
const SOURCE_RENDERER_MAX_SCALE_EXPR := source_display_profile_source_text_state.SOURCE_RENDERER_MAX_SCALE_EXPR

var catalog: Variant
var profile: Dictionary = {}
var tile_size := 0
var source_tile_size := 0.0
var world_width_tiles := 0
var world_height_tiles := 0
var profile_viewport_size_pixels := Vector2i.ZERO
var viewport_size_pixels := Vector2i.ZERO
var visible_world_size_pixels := Vector2.ZERO
var background_margin_viewports := Vector2.ZERO
var background_margin_tiles := Vector2i.ZERO
var background_min_cell := Vector2i.ZERO
var background_max_cell := Vector2i.ZERO
var camera_initial_position := Vector2.ZERO
var camera_initial_zoom := 0.0
var camera_min_zoom := 0.0
var camera_max_zoom := 0.0
var camera_runtime_zoom := Vector2.ONE

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog

func load() -> bool:
	profile = catalog.document_root_data(MODULE_NAME, "playfield")
	if profile.is_empty():
		push_error("Missing display profile manifest: %s" % MODULE_NAME)
		return false
	var viewport: Dictionary = profile.get("viewport", {})
	var camera_profile: Dictionary = profile.get("camera", {})
	var visible_world: Dictionary = profile.get("visible_world", {})
	var world: Dictionary = profile.get("world", {})
	var margin_viewports: Dictionary = profile.get("background_margin_viewports", {})
	var margin_tiles: Dictionary = profile.get("background_margin_tiles", {})
	tile_size = int(profile.get("tile_size", 0))
	source_tile_size = float(profile.get("source_tile_size", 0.0))
	world_width_tiles = int(world.get("width_tiles", 0))
	world_height_tiles = int(world.get("height_tiles", 0))
	profile_viewport_size_pixels = Vector2i(int(viewport.get("width", 0)), int(viewport.get("height", 0)))
	viewport_size_pixels = profile_viewport_size_pixels
	visible_world_size_pixels = Vector2(float(visible_world.get("width_pixels", 0.0)), float(visible_world.get("height_pixels", 0.0)))
	background_margin_viewports = Vector2(float(margin_viewports.get("x", 0.0)), float(margin_viewports.get("y", 0.0)))
	background_margin_tiles = Vector2i(int(margin_tiles.get("x", 0)), int(margin_tiles.get("y", 0)))
	camera_initial_position = Vector2(float(camera_profile.get("position_x", 0.0)), float(camera_profile.get("position_y", 0.0)))
	camera_initial_zoom = float(camera_profile.get("zoom", 0.0))
	camera_min_zoom = float(camera_profile.get("min_zoom", 0.0))
	camera_max_zoom = float(camera_profile.get("max_zoom", 0.0))
	camera_runtime_zoom = Vector2(camera_initial_zoom, camera_initial_zoom)
	background_min_cell = Vector2i.ZERO
	background_max_cell = Vector2i(world_width_tiles, world_height_tiles)
	return true

func sync_runtime_viewport_size(viewport_size: Vector2i) -> void:
	if viewport_size.x <= 0 or viewport_size.y <= 0 or tile_size <= 0:
		return
	viewport_size_pixels = Vector2i(maxi(viewport_size.x, profile_viewport_size_pixels.x), maxi(viewport_size.y, profile_viewport_size_pixels.y))
	visible_world_size_pixels = camera_visible_size_pixels(Vector2(camera_initial_zoom, camera_initial_zoom))
	background_margin_tiles = Vector2i(
		ceili((visible_world_size_pixels.x / float(tile_size)) * background_margin_viewports.x),
		ceili((visible_world_size_pixels.y / float(tile_size)) * background_margin_viewports.y)
	)
	world_width_tiles = ceili(visible_world_size_pixels.x / float(tile_size)) + background_margin_tiles.x
	world_height_tiles = ceili(visible_world_size_pixels.y / float(tile_size)) + background_margin_tiles.y
	sync_runtime_camera_zoom(Vector2(camera_initial_zoom, camera_initial_zoom))
	camera_initial_position = world_size_pixels() / 2.0

func sync_runtime_camera_zoom(zoom: Vector2) -> void:
	if tile_size <= 0:
		return
	camera_runtime_zoom = Vector2(clampf(zoom.x, camera_min_zoom, camera_max_zoom), clampf(zoom.y, camera_min_zoom, camera_max_zoom))
	visible_world_size_pixels = camera_visible_size_pixels(camera_runtime_zoom)
	var padding_tiles := camera_clamp_visible_padding_tiles(camera_runtime_zoom)
	background_min_cell = Vector2i(-padding_tiles.x, -padding_tiles.y)
	background_max_cell = Vector2i(world_width_tiles + padding_tiles.x, world_height_tiles + padding_tiles.y)

func runtime_summary() -> Dictionary:
	var world_width_pixels := float(world_width_tiles * tile_size)
	var world_height_pixels := float(world_height_tiles * tile_size)
	return {
		"loaded": not profile.is_empty(),
		"tile_size": tile_size,
		"source_tile_size": source_tile_size,
		"world_width_tiles": world_width_tiles,
		"world_height_tiles": world_height_tiles,
		"world_width_pixels": world_width_pixels,
		"world_height_pixels": world_height_pixels,
		"viewport_width": viewport_size_pixels.x,
		"viewport_height": viewport_size_pixels.y,
		"camera_position": {"x": camera_initial_position.x, "y": camera_initial_position.y},
		"camera_zoom": camera_runtime_zoom.x,
		"min_zoom": camera_min_zoom,
		"max_zoom": camera_max_zoom,
		"background_margin_viewports": {"x": background_margin_viewports.x, "y": background_margin_viewports.y},
		"background_margin_tiles": {"x": background_margin_tiles.x, "y": background_margin_tiles.y},
		"background_min_cell": {"x": background_min_cell.x, "y": background_min_cell.y},
		"background_max_cell": {"x": background_max_cell.x, "y": background_max_cell.y},
		"background_width_tiles": background_max_cell.x - background_min_cell.x,
		"background_height_tiles": background_max_cell.y - background_min_cell.y,
		"visible_world_width_pixels": visible_world_size_pixels.x,
		"visible_world_height_pixels": visible_world_size_pixels.y,
		"covers_visible_world": world_width_pixels >= visible_world_size_pixels.x and world_height_pixels >= visible_world_size_pixels.y,
		"camera_clamp_source": SOURCE_CAMERA_CLAMP_EXPR,
		"camera_clamp_bounds": camera_clamp_bounds(camera_runtime_zoom),
		"camera_clamp_visible_bounds": camera_clamp_visible_bounds(camera_runtime_zoom),
		"background_covers_camera_clamp_bounds": background_covers_camera_clamp_bounds(camera_runtime_zoom),
		"camera_viewport_source": [SOURCE_RENDERER_CAMERA_WIDTH_EXPR, SOURCE_RENDERER_CAMERA_HEIGHT_EXPR],
	}

func world_size_pixels() -> Vector2:
	return Vector2(float(world_width_tiles * tile_size), float(world_height_tiles * tile_size))

func camera_visible_size_pixels(zoom: Vector2) -> Vector2:
	var safe_zoom_x := zoom.x if zoom.x != 0.0 else 1.0
	var safe_zoom_y := zoom.y if zoom.y != 0.0 else 1.0
	return Vector2(float(viewport_size_pixels.x) / safe_zoom_x, float(viewport_size_pixels.y) / safe_zoom_y)

func camera_clamp_bounds(zoom: Vector2) -> Dictionary:
	var visible_size := camera_visible_size_pixels(zoom)
	var world_size := world_size_pixels()
	return {
		"source": SOURCE_CAMERA_CLAMP_EXPR,
		"min_x": -visible_size.x / 4.0,
		"min_y": -visible_size.y / 4.0,
		"max_x": world_size.x + visible_size.x / 4.0,
		"max_y": world_size.y + visible_size.y / 4.0,
		"visible_width": visible_size.x,
		"visible_height": visible_size.y,
		"world_width": world_size.x,
		"world_height": world_size.y,
	}

func camera_clamp_visible_padding_tiles(zoom: Vector2) -> Vector2i:
	var visible_size := camera_visible_size_pixels(zoom)
	return Vector2i(
		ceili((visible_size.x * 0.75) / float(tile_size)),
		ceili((visible_size.y * 0.75) / float(tile_size))
	)

func camera_clamp_visible_bounds(zoom: Vector2) -> Dictionary:
	var clamp_bounds := camera_clamp_bounds(zoom)
	var visible_size := camera_visible_size_pixels(zoom)
	return {
		"source": SOURCE_CAMERA_CLAMP_VISIBLE_PADDING_EXPR,
		"left": float(clamp_bounds.get("min_x", 0.0)) - visible_size.x / 2.0,
		"top": float(clamp_bounds.get("min_y", 0.0)) - visible_size.y / 2.0,
		"right": float(clamp_bounds.get("max_x", 0.0)) + visible_size.x / 2.0,
		"bottom": float(clamp_bounds.get("max_y", 0.0)) + visible_size.y / 2.0,
	}

func background_covers_camera_clamp_bounds(zoom: Vector2) -> bool:
	var visible_bounds := camera_clamp_visible_bounds(zoom)
	return (
		float(background_min_cell.x * tile_size) <= float(visible_bounds.get("left", 0.0))
		and float(background_min_cell.y * tile_size) <= float(visible_bounds.get("top", 0.0))
		and float(background_max_cell.x * tile_size) >= float(visible_bounds.get("right", 0.0))
		and float(background_max_cell.y * tile_size) >= float(visible_bounds.get("bottom", 0.0))
	)

func clamp_camera_position(position: Vector2, zoom: Vector2) -> Vector2:
	var bounds := camera_clamp_bounds(zoom)
	return Vector2(
		clampf(position.x, float(bounds.get("min_x", position.x)), float(bounds.get("max_x", position.x))),
		clampf(position.y, float(bounds.get("min_y", position.y)), float(bounds.get("max_y", position.y)))
	)

func background_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(background_min_cell.y, background_max_cell.y):
		for x in range(background_min_cell.x, background_max_cell.x):
			cells.append(Vector2i(x, y))
	return cells

func background_size() -> Vector2i:
	return Vector2i(background_max_cell.x - background_min_cell.x, background_max_cell.y - background_min_cell.y)

func world_size_cells() -> Vector2i:
	return Vector2i(world_width_tiles, world_height_tiles)
