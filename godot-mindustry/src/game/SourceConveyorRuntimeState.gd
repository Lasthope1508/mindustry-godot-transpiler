extends RefCounted
class_name SourceConveyorRuntimeState

const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_factory_defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_conveyor_source_text_state := preload("res://src/game/SourceConveyorSourceTextState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

const SOURCE_CONVEYOR_WORLD_SPEED_SOURCE := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_SOURCE
const SOURCE_CONVEYOR_TILE_SPEED_SCALE := source_factory_defaults.CONVEYOR_TILE_SPEED_SCALE

const SOURCE_CONVEYOR_WORLD_SPEED_SPEED_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_SPEED_FIELD
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_WORLD_SPEED := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_UNIT_WORLD_SPEED
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_IMPULSE := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_UNIT_IMPULSE
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_COMMENT := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_COMMENT
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_FIELD
const SOURCE_CONVEYOR_WORLD_SPEED_KEY := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_KEY
const SOURCE_CONVEYOR_WORLD_SPEED_TILE_SPEED_SCALE := source_factory_defaults.CONVEYOR_TILE_SPEED_SCALE

const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_SPEED_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_SPEED_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_UNIT_WORLD_SPEED := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_UNIT_WORLD_SPEED
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_ITEM_POSITIONS := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_ITEM_POSITIONS
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_MOVED := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_MOVED
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_YS_ADD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_YS_ADD
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_PASS_THRESHOLD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_PASS_THRESHOLD

const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_SPEED_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_SPEED_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MOVED := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MOVED
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MAXMOVE := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MAXMOVE
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_YS_ADD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_YS_ADD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_METHOD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_METHOD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_RETURN := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_RETURN

const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_BLOCK_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_BLOCK_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_X := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_X
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_Y := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_Y
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_METHOD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_METHOD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_RETURN := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_RETURN
const SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY := source_conveyor_source_text_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY
const SOURCE_CONVEYOR_EDELTA_PROVIDER_FALLBACK := source_conveyor_source_text_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_conveyor_runtime_method_names"):
		var names = game.call("_conveyor_runtime_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY: Callable(game, runtime_method_name(method_names, SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY, SOURCE_CONVEYOR_EDELTA_PROVIDER_FALLBACK)),
	}

static func game_path_points(game: Object) -> Array:
	var points = game.get("path_points")
	if points is Array:
		return points
	return []

static func world_speed(block_id: String, tile_size: float, content_catalog) -> float:
	return source_block_metadata_state.block_conveyor_world_speed(block_id, tile_size, content_catalog)

static func game_world_speed(game: Object, block_id: String) -> float:
	return world_speed(block_id, int(game.get("tile_size")), game.get("content_catalog"))

static func path_progress_rate(block_id: String, path_point_count: int, tile_size: float, content_catalog) -> float:
	if path_point_count < 2:
		return 0.0
	var path_length := float(max(1, path_point_count - 1) * tile_size)
	return world_speed(block_id, tile_size, content_catalog) / path_length

static func game_path_progress_rate(game: Object, block_id: String) -> float:
	return path_progress_rate(block_id, game_path_points(game).size(), int(game.get("tile_size")), game.get("content_catalog"))

static func path_progress_delta(block_id: String, seconds: float, path_point_count: int, tile_size: float, source_tick_rate: float, content_catalog, time_scale := 1.0, efficiency := 1.0, edelta_provider := Callable()) -> float:
	if source_tick_rate == 0.0:
		return 0.0
	var scaled_source_delta: float = edelta_provider.call(seconds * source_tick_rate, time_scale, efficiency) if edelta_provider.is_valid() else seconds * source_tick_rate * time_scale * efficiency
	return path_progress_rate(block_id, path_point_count, tile_size, content_catalog) * scaled_source_delta / source_tick_rate

static func game_path_progress_delta(game: Object, block_id: String, seconds: float, time_scale := 1.0, efficiency := 1.0) -> float:
	var callbacks := default_callbacks_state(game)
	return path_progress_delta(block_id, seconds, game_path_points(game).size(), int(game.get("tile_size")), source_time_defaults.TICK_RATE, game.get("content_catalog"), time_scale, efficiency, callbacks.get(SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY, Callable()))

static func game_path_progress_delta_for_cell(game: Object, x: int, y: int, seconds: float, efficiency := 1.0) -> float:
	var sprite = source_texture_runtime_state.game_sprite_at_cell(game, x, y)
	if not is_instance_valid(sprite):
		return 0.0
	return game.call("source_conveyor_path_progress_delta", str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")), seconds, float(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_META_KEY, source_block_defaults.TIME_SCALE_DEFAULT)), efficiency)


static func source_conveyor_accept_item_state(len: int, capacity: int, facing_direction: int, rotation: int, minitem: float, item_space: float, source_block_rotate: bool, next_is_source: bool) -> Dictionary:
	var direction: int = abs(facing_direction - rotation)
	var reason := "accepted"
	if len >= capacity:
		reason = "at_capacity"
	elif facing_direction == -1:
		reason = "no_facing"
	elif not (((direction == 0) and minitem >= item_space) or ((direction % 2 == 1) and minitem > 0.7)):
		reason = "wrong_direction"
	elif source_block_rotate and next_is_source:
		reason = "rotate_loop"
	return {
		"accepted": reason == "accepted",
		"direction": direction,
		"reason": reason,
	}


static func source_conveyor_handle_item_state(len: int, capacity: int, facing_direction: int, rotation: int, mid: int, item_id: String, item_count_before: int) -> Dictionary:
	if len >= capacity:
		return {
			"accepted": false,
			"index": -1,
			"x": 0.0,
			"y": 0.0,
			"len_after": len,
			"item_count_after": item_count_before,
			"no_sleep_called": false,
			"reason": "at_capacity",
		}
	var ang: int = facing_direction - rotation
	var x := 1.0 if (ang == -1 or ang == 3) else (-1.0 if (ang == 1 or ang == -3) else 0.0)
	var straight: bool = abs(ang) == 0
	return {
		"accepted": true,
		"index": 0 if straight else mid,
		"x": x,
		"y": 0.0 if straight else 0.5,
		"len_after": len + 1,
		"item_count_after": item_count_before + 1,
		"no_sleep_called": true,
		"reason": "accepted",
	}


static func source_conveyor_pass_state(item_id: Variant, next_present: bool, next_same_team: bool, next_accepts_hook: Callable, next_handle_hook: Callable) -> Dictionary:
	var reason := "passed"
	if item_id == null:
		reason = "null_item"
	elif not next_present:
		reason = "no_next"
	elif not next_same_team:
		reason = "wrong_team"
	elif next_accepts_hook == Callable() or not bool(next_accepts_hook.call(item_id)):
		reason = "next_rejects"
	elif next_handle_hook == Callable():
		reason = "no_handle"
	if reason != "passed":
		return {
			"passed": false,
			"item_id": item_id,
			"handle_called": false,
			"reason": reason,
		}
	next_handle_hook.call(item_id)
	return {
		"passed": true,
		"item_id": item_id,
		"handle_called": true,
		"reason": "passed",
	}


static func _conveyor_queue_result(ids_after: Array, xs_after: Array, ys_after: Array, len_before: int, len_after: int, shifted: int, reason: String) -> Dictionary:
	return {
		"ids_after": ids_after,
		"xs_after": xs_after,
		"ys_after": ys_after,
		"len_before": len_before,
		"len_after": len_after,
		"shifted": shifted,
		"reason": reason,
	}


static func source_conveyor_queue_add_state(ids: Array, xs: Array, ys: Array, len: int, index: int) -> Dictionary:
	if index < 0 or index > len:
		return _conveyor_queue_result(ids.duplicate(), xs.duplicate(), ys.duplicate(), len, len, 0, "invalid_index")
	var next_ids := ids.duplicate()
	var next_xs := xs.duplicate()
	var next_ys := ys.duplicate()
	next_ids.append(null)
	next_xs.append(0.0)
	next_ys.append(0.0)
	var shifted := 0
	if index < len:
		var i := len
		while i > index:
			next_ids[i] = next_ids[i - 1]
			next_xs[i] = next_xs[i - 1]
			next_ys[i] = next_ys[i - 1]
			shifted += 1
			i -= 1
	return _conveyor_queue_result(next_ids, next_xs, next_ys, len, len + 1, shifted, "shifted")


static func source_conveyor_queue_remove_state(ids: Array, xs: Array, ys: Array, len: int, index: int) -> Dictionary:
	if index < 0 or index >= len:
		return _conveyor_queue_result(ids.duplicate(), xs.duplicate(), ys.duplicate(), len, len, 0, "invalid_index")
	var next_ids := ids.duplicate()
	var next_xs := xs.duplicate()
	var next_ys := ys.duplicate()
	var shifted := 0
	for i in range(index, len - 1):
		next_ids[i] = next_ids[i + 1]
		next_xs[i] = next_xs[i + 1]
		next_ys[i] = next_ys[i + 1]
		shifted += 1
	next_ids.resize(len - 1)
	next_xs.resize(len - 1)
	next_ys.resize(len - 1)
	return _conveyor_queue_result(next_ids, next_xs, next_ys, len, len - 1, shifted, "shifted")


static func source_conveyor_queue_scan_state(ys: Array, passed_by_index: Array) -> Dictionary:
	var mid := 0
	var minitem := 1.0
	var i := ys.size() - 1
	while i >= 0:
		if float(ys[i]) > 0.5 and i > 0:
			mid = i - 1
		var passed := i < passed_by_index.size() and bool(passed_by_index[i])
		if not passed and float(ys[i]) < minitem:
			minitem = float(ys[i])
		i -= 1
	return {
		"mid": mid,
		"minitem": minitem,
	}


static func source_conveyor_remove_stack_state(ids: Array, xs: Array, ys: Array, len: int, item_id: String, amount: int, item_count_before: int) -> Dictionary:
	var next_ids := ids.duplicate()
	var next_xs := xs.duplicate()
	var next_ys := ys.duplicate()
	var next_len := len
	var removed := 0
	for j in range(amount):
		for i in range(next_len):
			if str(next_ids[i]) == item_id:
				var removed_state := source_conveyor_queue_remove_state(next_ids, next_xs, next_ys, next_len, i)
				next_ids = removed_state["ids_after"]
				next_xs = removed_state["xs_after"]
				next_ys = removed_state["ys_after"]
				next_len = int(removed_state["len_after"])
				removed += 1
				break
	return {
		"ids_after": next_ids,
		"xs_after": next_xs,
		"ys_after": next_ys,
		"len_before": len,
		"len_after": next_len,
		"removed": removed,
		"item_count_after": maxi(item_count_before - removed, 0),
		"no_sleep_called": true,
	}


static func source_conveyor_accept_stack_state(minitem: float, item_space: float, amount: int) -> Dictionary:
	if item_space <= 0.0:
		return {
			"accepted": 0,
			"free_slots": 0,
			"reason": "invalid_item_space",
		}
	var free_slots := int(minitem / item_space)
	return {
		"accepted": mini(free_slots, amount),
		"free_slots": free_slots,
		"reason": "accepted",
	}


static func source_conveyor_handle_stack_state(ids: Array, xs: Array, ys: Array, len: int, capacity: int, item_id: String, amount: int, item_space: float, item_count_before: int) -> Dictionary:
	var clamped := mini(amount, capacity - len)
	if amount <= 0:
		return {
			"ids_after": ids.duplicate(),
			"xs_after": xs.duplicate(),
			"ys_after": ys.duplicate(),
			"len_before": len,
			"len_after": len,
			"inserted": 0,
			"item_count_after": item_count_before,
			"no_sleep_called": true,
			"reason": "empty_request",
		}
	if clamped <= 0:
		return {
			"ids_after": ids.duplicate(),
			"xs_after": xs.duplicate(),
			"ys_after": ys.duplicate(),
			"len_before": len,
			"len_after": len,
			"inserted": 0,
			"item_count_after": item_count_before,
			"no_sleep_called": true,
			"reason": "at_capacity",
		}
	var next_ids := ids.duplicate()
	var next_xs := xs.duplicate()
	var next_ys := ys.duplicate()
	var next_len := len
	for i in range(clamped - 1, -1, -1):
		var added := source_conveyor_queue_add_state(next_ids, next_xs, next_ys, next_len, 0)
		next_ids = added["ids_after"]
		next_xs = added["xs_after"]
		next_ys = added["ys_after"]
		next_len = int(added["len_after"])
		next_xs[0] = 0.0
		next_ys[0] = float(i) * item_space
		next_ids[0] = item_id
	return {
		"ids_after": next_ids,
		"xs_after": next_xs,
		"ys_after": next_ys,
		"len_before": len,
		"len_after": next_len,
		"inserted": clamped,
		"item_count_after": item_count_before + clamped,
		"no_sleep_called": true,
		"reason": "inserted",
	}


static func source_conveyor_accept_for_cell_state(queue_ids: Array, queue_xs: Array, queue_ys: Array, queue_len: int, capacity: int, item_space: float, source_cell: Vector2i, conveyor_cell: Vector2i, conveyor_rotation: int, source_block_rotate: bool, next_is_source: bool) -> Dictionary:
	var facing_direction := SourceBlockGeometry.tile_relative_cardinal_state(source_cell.x, source_cell.y, conveyor_cell.x, conveyor_cell.y)
	var passed: Array[bool] = []
	passed.resize(queue_ys.size())
	var scan := source_conveyor_queue_scan_state(queue_ys, passed)
	var accept := source_conveyor_accept_item_state(queue_len, capacity, facing_direction, conveyor_rotation, float(scan.get("minitem", 1.0)), item_space, source_block_rotate, next_is_source)
	return {
		"accepted": bool(accept.get("accepted", false)),
		"direction": int(accept.get("direction", -1)),
		"facing_direction": facing_direction,
		"minitem": float(scan.get("minitem", 1.0)),
		"reason": str(accept.get("reason", "")),
	}


static func source_conveyor_handle_for_cell_state(queue_ids: Array, queue_xs: Array, queue_ys: Array, queue_len: int, capacity: int, item_space: float, source_cell: Vector2i, conveyor_cell: Vector2i, conveyor_rotation: int, item_id: String, item_count_before: int) -> Dictionary:
	var facing_direction := SourceBlockGeometry.tile_relative_cardinal_state(source_cell.x, source_cell.y, conveyor_cell.x, conveyor_cell.y)
	var passed: Array[bool] = []
	passed.resize(queue_ys.size())
	var scan := source_conveyor_queue_scan_state(queue_ys, passed)
	var handle := source_conveyor_handle_item_state(queue_len, capacity, facing_direction, conveyor_rotation, int(scan.get("mid", 0)), item_id, item_count_before)
	if not bool(handle.get("accepted", false)):
		return {
			"ids_after": queue_ids.duplicate(),
			"xs_after": queue_xs.duplicate(),
			"ys_after": queue_ys.duplicate(),
			"len_before": queue_len,
			"len_after": queue_len,
			"index": -1,
			"x": 0.0,
			"y": 0.0,
			"item_count_after": item_count_before,
			"no_sleep_called": false,
			"reason": str(handle.get("reason", "")),
		}
	var index := int(handle.get("index", 0))
	var added := source_conveyor_queue_add_state(queue_ids, queue_xs, queue_ys, queue_len, index)
	var next_ids: Array = added["ids_after"]
	var next_xs: Array = added["xs_after"]
	var next_ys: Array = added["ys_after"]
	next_ids[index] = item_id
	next_xs[index] = float(handle.get("x", 0.0))
	next_ys[index] = float(handle.get("y", 0.0))
	return {
		"ids_after": next_ids,
		"xs_after": next_xs,
		"ys_after": next_ys,
		"len_before": queue_len,
		"len_after": int(added["len_after"]),
		"index": index,
		"x": float(handle.get("x", 0.0)),
		"y": float(handle.get("y", 0.0)),
		"item_count_after": int(handle.get("item_count_after", item_count_before)),
		"no_sleep_called": true,
		"reason": str(handle.get("reason", "")),
	}
