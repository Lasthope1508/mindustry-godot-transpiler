extends RefCounted
class_name SourceProjectorBoostState

const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")

const PROJECTOR_KIND_MEND := "mend"
const PROJECTOR_KIND_OVERDRIVE := "overdrive"
const SOURCE_PROJECTOR_HEAT_LERP_PROGRESS := source_projector_defaults.PROJECTOR_HEAT_LERP_PROGRESS
const SOURCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS := source_projector_defaults.PROJECTOR_PHASE_HEAT_LERP_PROGRESS

static func boost_input(sprite, block) -> Dictionary:
	var cell := Vector2i.ZERO
	if is_instance_valid(sprite):
		cell = sprite.get_meta("origin_cell", Vector2i.ZERO)
	var item_id := source_block_metadata_state.block_booster_item(block)
	return {
		"key": source_world_grid.cell_key(cell),
		"cell": cell,
		"item_id": item_id,
		"has_booster_item": not item_id.is_empty(),
	}

static func apply_boost_stock(core_items: Dictionary, booster_items: Dictionary, optional_efficiency: Dictionary, boost_state: Dictionary) -> void:
	var item_id := str(boost_state.get("item_id", ""))
	if item_id.is_empty():
		return
	if int(core_items.get(item_id, 0)) <= 0:
		return
	var key := str(boost_state.get("key", ""))
	core_items[item_id] = int(core_items.get(item_id, 0)) - 1
	booster_items[key] = int(booster_items.get(key, 0)) + 1
	optional_efficiency[key] = 1.0

static func game_sprite_at_cell(game: Object, x: int, y: int):
	return source_texture_runtime_state.game_sprite_at_cell(game, x, y)

static func game_block_from_sprite(game: Object, sprite):
	if game == null:
		return null
	return source_texture_runtime_state.block_from_sprite(game, sprite)

static func apply_projector_boost_at_cell(game: Object, x: int, y: int, projector_kind: String, booster_items: Dictionary, optional_efficiency: Dictionary) -> bool:
	var sprite = game_sprite_at_cell(game, x, y)
	var block = game_block_from_sprite(game, sprite)
	if not _is_projector_kind(block, projector_kind):
		return false
	var boost_state := boost_input(sprite, block)
	var item_id := str(boost_state.get("item_id", ""))
	if not bool(boost_state.get("has_booster_item", false)) or int(game.call("core_item_count", item_id)) <= 0:
		return false
	var core_items: Dictionary = game.get("core_items")
	apply_boost_stock(core_items, booster_items, optional_efficiency, boost_state)
	game.set("core_items", core_items)
	return true

static func _is_projector_kind(block, projector_kind: String) -> bool:
	if projector_kind == PROJECTOR_KIND_MEND:
		return bool(source_selected_build_state.is_mend_projector(block))
	if projector_kind == PROJECTOR_KIND_OVERDRIVE:
		return bool(source_selected_build_state.is_overdrive_projector(block))
	return false
