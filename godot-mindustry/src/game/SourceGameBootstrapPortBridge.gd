extends "res://src/game/SourceCoreInventoryPortBridge.gd"

const mindustry_time_script := preload("res://src/runtime/Time.gd")
const source_game_loop_runtime_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const source_game_config_runtime_state := preload("res://src/game/SourceGameConfigRuntimeState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_node_binding_runtime_state := preload("res://src/game/SourceNodeBindingRuntimeState.gd")

func _ready() -> void:
	source_game_loop_runtime_state.ready(self)

func load_config() -> void:
	source_game_config_runtime_state.load_config(self)

func load_content_registry() -> void:
	source_content_registry_runtime_state.load_content_registry(self)

func load_all_generated_scripts() -> void:
	source_content_registry_runtime_state.load_all_generated_scripts(self)

func load_selected_generated_scripts() -> void:
	source_content_registry_runtime_state.load_selected_generated_scripts(self)

func load_textures() -> void:
	source_texture_runtime_state.load_textures(self)

func load_png_texture(path: String) -> Texture2D:
	return source_texture_runtime_state.load_png_texture(path)

func bind_nodes() -> void:
	source_node_binding_runtime_state.bind_nodes(self)

func block_from_sprite(sprite):
	return source_texture_runtime_state.block_from_sprite(self, sprite)

func configure_block_sprite(sprite: Sprite2D, block, cell: Vector2i) -> void:
	source_texture_runtime_state.configure_block_sprite(self, sprite, block, cell)

func block_texture(block) -> Texture2D:
	return source_texture_runtime_state.block_texture(self, block)

func add_sprite(parent: Node, key: String, pos: Vector2) -> Sprite2D:
	var runtime_textures: Dictionary = get("textures")
	var runtime_tile_size := int(get("tile_size"))
	return source_texture_runtime_state.add_sprite(parent, runtime_textures, key, pos, runtime_tile_size)

func add_source_tile_batch(parent: Node, key: String, cells: Array) -> Node:
	var runtime_textures: Dictionary = get("textures")
	var runtime_tile_size := int(get("tile_size"))
	return source_texture_runtime_state.add_source_tile_batch(parent, runtime_textures, key, cells, runtime_tile_size)

func add_ore_cell(parent: Node, key: String, item_id: String, cell: Vector2i) -> Sprite2D:
	return source_texture_runtime_state.add_ore_cell(self, parent, key, item_id, cell)

func _process(delta: float) -> void:
	source_game_loop_runtime_state.process_tick(self, delta, mindustry_time_script)
