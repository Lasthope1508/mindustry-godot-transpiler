extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const port_game := preload("res://src/game/PortGame.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")

func _ready() -> void:
	var game := port_game.new()
	game.load_config()
	game.load_content_registry()
	source_texture_runtime_state.load_textures(game)
	var sprite := Sprite2D.new()
	sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, source_playable_scenario_defaults.BLOCK_CONVEYOR)
	var block_from_sprite: Variant = source_texture_runtime_state.block_from_sprite(game, sprite)
	var block_lookup_matches := block_from_sprite != null and str(block_from_sprite.id) == source_playable_scenario_defaults.BLOCK_CONVEYOR
	var item_loaded := game.textures.get("item", null) is Texture2D
	var conveyor_loaded := game.textures.get(source_playable_scenario_defaults.BLOCK_CONVEYOR, null) is Texture2D
	var unit_loaded := game.textures.get("unit:dagger", null) is Texture2D
	var added_sprite := source_texture_runtime_state.add_sprite(self, game.textures, source_playable_scenario_defaults.BLOCK_CONVEYOR, Vector2(16.0, 24.0), game.tile_size)
	var add_sprite_scaled := added_sprite.texture is Texture2D and added_sprite.position == Vector2(16.0, 24.0) and added_sprite.scale.x > 0.0 and added_sprite.scale.y > 0.0 and added_sprite.get_parent() == self
	var added_ore_sprite := source_texture_runtime_state.add_ore_cell(game, self, source_playable_scenario_defaults.BLOCK_ORE_COPPER, source_playable_scenario_defaults.ITEM_COPPER, Vector2i(5, 6))
	var add_ore_cell_matches: bool = added_ore_sprite.texture is Texture2D and game.ore_items_by_cell.get("5,6", "") == source_playable_scenario_defaults.ITEM_COPPER and added_ore_sprite.position == game.grid_to_world(Vector2i(5, 6)) and added_ore_sprite.get_parent() == self
	var conveyor_block = game.content_catalog.get_by_id(source_playable_scenario_defaults.BLOCK_CONVEYOR)
	var cached_texture := source_texture_runtime_state.block_texture(game, conveyor_block)
	var cached_texture_again := source_texture_runtime_state.block_texture(game, conveyor_block)
	var block_texture_cached := cached_texture is Texture2D and cached_texture_again == cached_texture and game.block_texture_cache.has(source_playable_scenario_defaults.BLOCK_CONVEYOR)
	var configured_sprite := Sprite2D.new()
	source_texture_runtime_state.configure_block_sprite(game, configured_sprite, conveyor_block, Vector2i(2, 3))
	var configured_sprite_scaled := configured_sprite.texture is Texture2D and configured_sprite.position == game.source_block_sprite_base_position(conveyor_block, Vector2i(2, 3)) and configured_sprite.scale.x > 0.0 and configured_sprite.scale.y > 0.0
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTextureRuntimeState",
		"item_loaded": item_loaded,
		"conveyor_loaded": conveyor_loaded,
		"block_lookup_matches": block_lookup_matches,
		"add_sprite_scaled": add_sprite_scaled,
		"add_ore_cell_matches": add_ore_cell_matches,
		"block_texture_cached": block_texture_cached,
		"configured_sprite_scaled": configured_sprite_scaled,
		"unit_loaded": unit_loaded,
		"texture_count": game.textures.size(),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = item_loaded and conveyor_loaded and block_lookup_matches and add_sprite_scaled and add_ore_cell_matches and block_texture_cached and configured_sprite_scaled and unit_loaded and bool(proof.get("one_headquarter_per_ssot", false)) and bool(proof.get("registry_valid", false))
	print("TEXTURE_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TextureRuntimeModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

