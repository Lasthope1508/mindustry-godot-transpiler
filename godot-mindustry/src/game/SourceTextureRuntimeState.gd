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
	if game.get("content_catalog") == null:
		return null
	# The real game's placed_block_origins maps a cell to its Vector2i
	# origin, not to a sprite; resolve a cell to its sprite first so the
	# placed power graph (which iterates placed_block_origins) actually
	# sees the placed blocks.
	var resolved = sprite
	if resolved is Vector2i:
		resolved = game.call("block_sprite_at_cell", resolved)
	if not is_instance_valid(resolved):
		return null
	return game.get("content_catalog").get_by_id(str(resolved.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")))

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

static func add_source_tile_batch(parent: Node, textures: Dictionary, key: String, cells: Array, tile_size: int) -> Node:
	if parent == null or cells.is_empty():
		return null
	var batch := MultiMeshInstance2D.new()
	batch.name = "Batch_" + key.replace("-", "_")
	batch.texture = textures.get(key)
	if batch.texture == null:
		return null
	var texture_size := batch.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return null
	var batch_scale := Vector2.ONE
	batch_scale = source_world_grid.sprite_tile_scale(texture_size, tile_size)
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	var mesh := QuadMesh.new()
	mesh.size = texture_size
	multimesh.mesh = mesh
	multimesh.instance_count = cells.size()
	for i in range(cells.size()):
		var cell := _cell_value(cells[i])
		var batch_position := source_world_grid.grid_to_world(cell, tile_size)
		var transform := Transform2D(0.0, batch_position)
		transform.x *= batch_scale.x
		transform.y *= batch_scale.y
		multimesh.set_instance_transform_2d(i, transform)
	batch.multimesh = multimesh
	batch.set_meta("source_tile_batch_key", key)
	batch.set_meta("source_tile_batch_cell_count", cells.size())
	parent.add_child(batch)
	return batch

static func add_ore_cell(game: Object, parent: Node, key: String, item_id: String, cell: Vector2i) -> Sprite2D:
	var ore_items_by_cell: Dictionary = game.get("ore_items_by_cell")
	ore_items_by_cell[source_world_grid.cell_key(cell)] = item_id
	game.set("ore_items_by_cell", ore_items_by_cell)
	return add_sprite(parent, game.get("textures"), key, game.call("grid_to_world", cell), int(game.get("tile_size")))

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

static func _cell_value(value) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Dictionary:
		return Vector2i(int(value.get("x", 0)), int(value.get("y", 0)))
	return Vector2i.ZERO
