extends RefCounted
class_name DisplayProfileRuntime

const MODULE_NAME := "display_profile"

var catalog: Variant
var profile: Dictionary = {}
var tile_size := 0
var source_tile_size := 0.0
var world_width_tiles := 0
var world_height_tiles := 0
var viewport_size_pixels := Vector2i.ZERO
var visible_world_size_pixels := Vector2.ZERO
var camera_initial_position := Vector2.ZERO
var camera_initial_zoom := 0.0

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog

func load() -> bool:
	var document: Dictionary = catalog.load_document(MODULE_NAME)
	if not bool(document.get("loaded", false)):
		push_error("Missing display profile manifest: %s" % MODULE_NAME)
		return false
	var data: Dictionary = document.get("data", {})
	profile = data.get("playfield", {})
	var viewport: Dictionary = profile.get("viewport", {})
	var camera_profile: Dictionary = profile.get("camera", {})
	var visible_world: Dictionary = profile.get("visible_world", {})
	var world: Dictionary = profile.get("world", {})
	tile_size = int(profile.get("tile_size", 0))
	source_tile_size = float(profile.get("source_tile_size", 0.0))
	world_width_tiles = int(world.get("width_tiles", 0))
	world_height_tiles = int(world.get("height_tiles", 0))
	viewport_size_pixels = Vector2i(int(viewport.get("width", 0)), int(viewport.get("height", 0)))
	visible_world_size_pixels = Vector2(float(visible_world.get("width_pixels", 0.0)), float(visible_world.get("height_pixels", 0.0)))
	camera_initial_position = Vector2(float(camera_profile.get("position_x", 0.0)), float(camera_profile.get("position_y", 0.0)))
	camera_initial_zoom = float(camera_profile.get("zoom", 0.0))
	return true

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
		"camera_zoom": camera_initial_zoom,
		"visible_world_width_pixels": visible_world_size_pixels.x,
		"visible_world_height_pixels": visible_world_size_pixels.y,
		"covers_visible_world": world_width_pixels >= visible_world_size_pixels.x and world_height_pixels >= visible_world_size_pixels.y,
	}
