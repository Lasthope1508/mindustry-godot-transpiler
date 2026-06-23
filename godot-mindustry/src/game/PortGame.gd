extends Node2D
class_name PortGame

const CONFIG_PATH := "res://src/generated/playable_content.json"
const ContentRegistry := preload("res://src/generated/MindustryContentRegistry.gd")
const ContentCatalog := preload("res://src/mindustry/content/ContentCatalog.gd")
const WORLD_W := 24
const WORLD_H := 16

var tile_size := 32
var config: Dictionary = {}
var textures: Dictionary = {}
var content_counts: Dictionary = {"items": 0, "liquids": 0, "blocks": 0}
var content_catalog: RefCounted
var core_inventory := 0
var produced_total := 0
var item_progress := 0.0
var item_sprites: Array[Sprite2D] = []
var path_points: Array[Vector2] = []
var hud_label: Label
var camera: Camera2D
var drill_pos := Vector2i(7, 8)
var core_pos := Vector2i(17, 8)

func _ready() -> void:
	load_config()
	load_content_registry()
	load_textures()
	bind_nodes()
	build_world()
	build_hud()

func load_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("Missing playable content manifest: " + CONFIG_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed
		tile_size = int(config.get("tile_size", 32))

func load_content_registry() -> void:
	content_catalog = ContentCatalog.new()
	content_counts = content_catalog.counts()
	if content_counts != ContentRegistry.counts():
		push_error("Generated registry counts do not match loaded content catalog")

func load_textures() -> void:
	if config.is_empty():
		return
	textures["item"] = load_png_texture(config["item"]["texture"])
	for key in config["blocks"].keys():
		textures[key] = load_png_texture(config["blocks"][key]["texture"])


func load_png_texture(path: String) -> Texture2D:
	var resource := ResourceLoader.load(path)
	if resource is Texture2D:
		return resource
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_error("Could not load texture: " + path)
		return null
	return ImageTexture.create_from_image(image)

func bind_nodes() -> void:
	camera = get_node_or_null("Camera2D")
	if camera:
		camera.make_current()
	hud_label = Label.new()
	hud_label.position = Vector2(16, 16)
	var hud := get_node_or_null("UI/Hud")
	if hud:
		hud.add_child(hud_label)

func build_world() -> void:
	var terrain := get_node("World/TerrainLayer")
	var blocks := get_node("World/BlockLayer")
	var units := get_node("World/UnitLayer")
	for y in WORLD_H:
		for x in WORLD_W:
			add_sprite(terrain, "stone_floor", grid_to_world(Vector2i(x, y)))
	for y in range(6, 11):
		for x in range(5, 8):
			add_sprite(terrain, "ore_copper", grid_to_world(Vector2i(x, y)))
	add_sprite(blocks, "mechanical_drill", grid_to_world(drill_pos))
	for x in range(drill_pos.x + 1, core_pos.x):
		add_sprite(blocks, "conveyor", grid_to_world(Vector2i(x, drill_pos.y)))
	add_sprite(blocks, "core_shard", grid_to_world(core_pos))
	path_points.clear()
	for x in range(drill_pos.x + 1, core_pos.x + 1):
		path_points.append(grid_to_world(Vector2i(x, drill_pos.y)))
	for i in 3:
		var sprite := add_sprite(units, "item", path_points[0])
		sprite.visible = false
		item_sprites.append(sprite)

func add_sprite(parent: Node, key: String, pos: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = textures.get(key)
	sprite.position = pos
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = Vector2(tile_size / size.x, tile_size / size.y)
	parent.add_child(sprite)
	return sprite

func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * tile_size, cell.y * tile_size)

func build_hud() -> void:
	update_hud()

func _process(delta: float) -> void:
	MindustryTime.update(delta)
	simulate_factory(delta)
	update_camera(delta)
	update_hud()

func simulate_factory(delta: float) -> void:
	if path_points.is_empty():
		return
	item_progress += delta * 0.45
	if item_progress >= 1.0:
		item_progress -= 1.0
		core_inventory += 1
		produced_total += 1
	for i in item_sprites.size():
		var phase := fmod(item_progress + float(i) / float(item_sprites.size()), 1.0)
		var idx := int(floor(phase * float(path_points.size() - 1)))
		var next_idx = min(idx + 1, path_points.size() - 1)
		var local_t := fmod(phase * float(path_points.size() - 1), 1.0)
		item_sprites[i].position = path_points[idx].lerp(path_points[next_idx], local_t)
		item_sprites[i].visible = true

func update_camera(delta: float) -> void:
	if camera == null:
		return
	var movement := Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		movement.x += 1.0
	if Input.is_action_pressed("ui_up"):
		movement.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		movement.y += 1.0
	if movement != Vector2.ZERO:
		camera.position += movement.normalized() * 420.0 * delta
	if Input.is_key_pressed(KEY_Q):
		camera.zoom *= 1.0 + delta
	if Input.is_key_pressed(KEY_E):
		camera.zoom *= 1.0 - min(delta, 0.5)

func update_hud() -> void:
	if hud_label == null:
		return
	var copper = content_catalog.get_by_id("copper") if content_catalog else null
	var copper_name: String = copper.display_name() if copper else "Copper"
	hud_label.text = "Mindustry Godot slice\nLoaded content objects: %d items / %d liquids / %d blocks\n%s in core: %d\nTotal produced: %d\nArrows move camera, Q/E zoom" % [content_counts.get("items", 0), content_counts.get("liquids", 0), content_counts.get("blocks", 0), copper_name, core_inventory, produced_total]
