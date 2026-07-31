extends RefCounted
class_name SourceTextureRuntimeState

const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")

static func load_textures(game: Object) -> void:
	var config: Dictionary = game.get("config")
	if config.is_empty():
		return
	var textures_value = game.get("textures")
	if not (textures_value is Dictionary):
		return
	var textures: Dictionary = textures_value
	textures["item"] = load_png_texture(config["item"]["texture"])
	for key in config["blocks"].keys():
		textures[key] = load_png_texture(config["blocks"][key]["texture"])
	var content_catalog = game.get("content_catalog")
	if content_catalog == null:
		return
	for unit in content_catalog.get_many("unit"):
		if unit.has_texture():
			textures["unit:" + unit.id] = load_png_texture(unit.texture_path)

static func block_from_sprite(game: Object, sprite) -> Variant:
	if game.get("content_catalog") == null or not is_instance_valid(sprite):
		return null
	return game.get("content_catalog").get_by_id(str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")))

static func block_from_sprite_callback(game: Object) -> Callable:
	return func(sprite):
		return block_from_sprite(game, sprite)

static func game_sprite_at_cell(game: Object, x: int, y: int):
	return game.call("block_sprite_at_cell", Vector2i(x, y))

static func add_sprite(parent: Node, textures: Dictionary, key: String, pos: Vector2, tile_size: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = textures.get(key)
	sprite.position = pos
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = source_world_grid.sprite_tile_scale(size, tile_size)
	parent.add_child(sprite)
	return sprite

static func block_texture(game: Object, block) -> Texture2D:
	var block_texture_cache: Dictionary = game.get("block_texture_cache")
	if block_texture_cache.has(block.id):
		return block_texture_cache[block.id]
	var texture := load_png_texture(block.texture_path)
	block_texture_cache[block.id] = texture
	game.set("block_texture_cache", block_texture_cache)
	return texture

static func configure_block_sprite(game: Object, sprite: Sprite2D, block, cell: Vector2i) -> void:
	sprite.texture = block_texture(game, block)
	sprite.position = game.source_block_sprite_base_position(block, cell)
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = source_block_geometry.block_sprite_scale(size, game.block_size(block), game.tile_size)

static func load_png_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		push_error("Could not find texture: " + path)
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open texture: " + path)
		return null
	var bytes := file.get_buffer(file.get_length())
	var image := Image.new()
	var error := image.load_png_from_buffer(bytes)
	if error != OK:
		push_error("Could not load texture: " + path)
		return null
	return ImageTexture.create_from_image(image)
