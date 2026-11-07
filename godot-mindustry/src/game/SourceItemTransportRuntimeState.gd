extends RefCounted
class_name SourceItemTransportRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_item_transport_source_text_state := preload("res://src/game/SourceItemTransportSourceTextState.gd")

const ITEM_SPRITE_COUNT_DEFAULT := 3
const ITEM_SPRITE_KEY_DEFAULT := source_item_transport_source_text_state.ITEM_SPRITE_KEY_DEFAULT
const PROP_PATH_POINTS := source_item_transport_source_text_state.PROP_PATH_POINTS
const PROP_ITEM_SPRITES := source_item_transport_source_text_state.PROP_ITEM_SPRITES
const SOURCE_ITEM_TRANSPORT_PROGRESS_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_PROGRESS_KEY
const SOURCE_ITEM_TRANSPORT_SPRITES_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITES_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY
const SOURCE_ITEM_TRANSPORT_PROGRESS_BEFORE_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_PROGRESS_BEFORE_KEY
const SOURCE_ITEM_TRANSPORT_PROGRESS_DELTA_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_PROGRESS_DELTA_KEY
const SOURCE_ITEM_TRANSPORT_SOURCE_OWNER_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SOURCE_OWNER_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_INDEX_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_INDEX_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_KEY_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_KEY_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_X_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_X_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_Y_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_Y_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_VISIBLE_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_VISIBLE_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_PHASE_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_PHASE_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_PATH_INDEX_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_PATH_INDEX_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_NEXT_PATH_INDEX_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_NEXT_PATH_INDEX_KEY
const SOURCE_ITEM_TRANSPORT_SPRITE_LOCAL_T_KEY := source_item_transport_source_text_state.SOURCE_ITEM_TRANSPORT_SPRITE_LOCAL_T_KEY


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

static func game_path_points(game: Object) -> Array[Vector2]:
	var path_points: Array[Vector2] = []
	if game == null:
		return path_points
	var path_points_value = game.get(PROP_PATH_POINTS)
	if not (path_points_value is Array):
		return path_points
	for point in path_points_value:
		if point is Vector2:
			path_points.append(point)
	return path_points

static func game_bootstrap_state(game: Object) -> Dictionary:
	return bootstrap_state(game_path_points(game), ITEM_SPRITE_COUNT_DEFAULT, ITEM_SPRITE_KEY_DEFAULT)


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

static func game_transport_positions_state(game: Object, progress_before: float, progress_delta: float) -> Dictionary:
	var sprite_count := 0
	if game != null:
		var item_sprites_value = game.get(PROP_ITEM_SPRITES)
		if item_sprites_value is Array:
			sprite_count = item_sprites_value.size()
	return transport_positions_state(game_path_points(game), sprite_count, progress_before, progress_delta)
