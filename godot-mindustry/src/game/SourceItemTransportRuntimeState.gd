extends RefCounted
class_name SourceItemTransportRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const ITEM_SPRITE_COUNT_DEFAULT := 3
const ITEM_SPRITE_KEY_DEFAULT := "item"
const SOURCE_ITEM_TRANSPORT_PROGRESS_KEY := "transport_progress"
const SOURCE_ITEM_TRANSPORT_SPRITES_KEY := "item_sprites"
const SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY := "item_sprite_count"
const SOURCE_ITEM_TRANSPORT_PROGRESS_BEFORE_KEY := "transport_progress_before"
const SOURCE_ITEM_TRANSPORT_PROGRESS_DELTA_KEY := "transport_progress_delta"
const SOURCE_ITEM_TRANSPORT_SOURCE_OWNER_KEY := "source_owner"
const SOURCE_ITEM_TRANSPORT_SPRITE_INDEX_KEY := "index"
const SOURCE_ITEM_TRANSPORT_SPRITE_KEY_KEY := "key"
const SOURCE_ITEM_TRANSPORT_SPRITE_X_KEY := "x"
const SOURCE_ITEM_TRANSPORT_SPRITE_Y_KEY := "y"
const SOURCE_ITEM_TRANSPORT_SPRITE_VISIBLE_KEY := "visible"
const SOURCE_ITEM_TRANSPORT_SPRITE_PHASE_KEY := "phase"
const SOURCE_ITEM_TRANSPORT_SPRITE_PATH_INDEX_KEY := "path_index"
const SOURCE_ITEM_TRANSPORT_SPRITE_NEXT_PATH_INDEX_KEY := "next_path_index"
const SOURCE_ITEM_TRANSPORT_SPRITE_LOCAL_T_KEY := "local_t"


static func bootstrap_state(path_points_input: Array[Vector2], sprite_count: int, sprite_key: String) -> Dictionary:
	var item_sprites: Array[Dictionary] = []
	if path_points_input.is_empty():
		return {SOURCE_ITEM_TRANSPORT_SPRITES_KEY: item_sprites, SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY: 0, SOURCE_ITEM_TRANSPORT_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TRANSPORT_BOOTSTRAP_STATE}
	var origin := path_points_input[0]
	for index in sprite_count:
		item_sprites.append({SOURCE_ITEM_TRANSPORT_SPRITE_INDEX_KEY: index, SOURCE_ITEM_TRANSPORT_SPRITE_KEY_KEY: sprite_key, SOURCE_ITEM_TRANSPORT_SPRITE_X_KEY: origin.x, SOURCE_ITEM_TRANSPORT_SPRITE_Y_KEY: origin.y, SOURCE_ITEM_TRANSPORT_SPRITE_VISIBLE_KEY: false})
	return {
		SOURCE_ITEM_TRANSPORT_SPRITES_KEY: item_sprites,
		SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY: item_sprites.size(),
		SOURCE_ITEM_TRANSPORT_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TRANSPORT_BOOTSTRAP_STATE,
	}


static func transport_positions_state(path_points_input: Array[Vector2], sprite_count: int, progress_before: float, progress_delta: float) -> Dictionary:
	var item_sprites: Array[Dictionary] = []
	if path_points_input.size() < 2 or sprite_count <= 0:
		return {SOURCE_ITEM_TRANSPORT_PROGRESS_KEY: progress_before, SOURCE_ITEM_TRANSPORT_SPRITES_KEY: item_sprites, SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY: 0}
	var transport_progress := fmod(progress_before + progress_delta, 1.0)
	var segment_count := path_points_input.size() - 1
	for index in sprite_count:
		var phase := fmod(transport_progress + float(index) / float(sprite_count), 1.0)
		var segment_float := phase * float(segment_count)
		var idx := int(floor(segment_float))
		var next_idx: int = min(idx + 1, segment_count)
		var local_t := segment_float - float(idx)
		var position: Vector2 = path_points_input[idx].lerp(path_points_input[next_idx], local_t)
		item_sprites.append({SOURCE_ITEM_TRANSPORT_SPRITE_INDEX_KEY: index, SOURCE_ITEM_TRANSPORT_SPRITE_X_KEY: position.x, SOURCE_ITEM_TRANSPORT_SPRITE_Y_KEY: position.y, SOURCE_ITEM_TRANSPORT_SPRITE_VISIBLE_KEY: true, SOURCE_ITEM_TRANSPORT_SPRITE_PHASE_KEY: phase, SOURCE_ITEM_TRANSPORT_SPRITE_PATH_INDEX_KEY: idx, SOURCE_ITEM_TRANSPORT_SPRITE_NEXT_PATH_INDEX_KEY: next_idx, SOURCE_ITEM_TRANSPORT_SPRITE_LOCAL_T_KEY: local_t})
	return {
		SOURCE_ITEM_TRANSPORT_PROGRESS_KEY: transport_progress,
		SOURCE_ITEM_TRANSPORT_SPRITES_KEY: item_sprites,
		SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY: item_sprites.size(),
		SOURCE_ITEM_TRANSPORT_PROGRESS_BEFORE_KEY: progress_before,
		SOURCE_ITEM_TRANSPORT_PROGRESS_DELTA_KEY: progress_delta,
		SOURCE_ITEM_TRANSPORT_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TRANSPORT_RUNTIME_STATE,
	}
