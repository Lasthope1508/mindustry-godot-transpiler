extends RefCounted
class_name SourceBuildingPayloadState

const SOURCE_PAYLOAD_FORWARD_OFFSET_METHOD := "public boolean movePayload(Payload todump){"
const SOURCE_PAYLOAD_FORWARD_OFFSET_TRNS := "int trns = block.size/2 + 1;"
const SOURCE_PAYLOAD_FORWARD_OFFSET_NEXT_TILE := "Tile next = tile.nearby(Geometry.d4(rotation).x * trns, Geometry.d4(rotation).y * trns);"
const SOURCE_MOVE_PAYLOAD_STATE_METHOD := "public boolean movePayload(Payload todump){"
const SOURCE_MOVE_PAYLOAD_STATE_TRNS := "int trns = block.size/2 + 1;"
const SOURCE_MOVE_PAYLOAD_STATE_NEXT := "Tile next = tile.nearby(Geometry.d4(rotation).x * trns, Geometry.d4(rotation).y * trns);"
const SOURCE_MOVE_PAYLOAD_STATE_GATE := "if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){"
const SOURCE_MOVE_PAYLOAD_STATE_HANDLE_DEFERRED := "next.build.handlePayload(self(), todump);"
const SOURCE_MOVE_PAYLOAD_STATE_RETURN_TRUE := "return true;"
const SOURCE_MOVE_PAYLOAD_STATE_RETURN_FALSE := "return false;"
const SOURCE_DUMP_PAYLOAD_INDEX_DUMP_FIELD := "int dump = this.cdump;"
const SOURCE_DUMP_PAYLOAD_INDEX_PROXIMITY_GET := "Building other = proximity.get((i + dump) % proximity.size);"
const SOURCE_DUMP_PAYLOAD_INDEX_EXPR := "(i + dump) % proximity.size"
const SOURCE_DUMP_PAYLOAD_STATE_METHOD := "public boolean dumpPayload(Payload todump){"
const SOURCE_DUMP_PAYLOAD_STATE_EMPTY_PROXIMITY_GUARD := "if(proximity.size == 0) return false;"
const SOURCE_DUMP_PAYLOAD_STATE_ACCEPT_PAYLOAD := "if(other.acceptPayload(self(), todump)){"
const SOURCE_DUMP_PAYLOAD_STATE_HANDLE_PAYLOAD := "other.handlePayload(self(), todump);"
const SOURCE_DUMP_PAYLOAD_STATE_INCREMENT_DUMP := "incrementDump(proximity.size);"
const SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY := "increment_dump_cursor"
const SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK := "source_increment_dump_cursor"

static func runtime_method_names(game: Object) -> Dictionary:
	if game == null:
		return {}
	if game.has_method("_building_payload_state_method_names"):
		var names = game.call("_building_payload_state_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return str(method_names.get(key, fallback_name))

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	var increment_dump_cursor_method := runtime_method_name(method_names, SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY, SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	return {
		SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY: Callable(game, increment_dump_cursor_method),
	}

static func game_dump_payload_state(game: Object, proximity_size: int, dump_cursor: int, accepts_payload_by_index: Array) -> Dictionary:
	return dump_payload_state(
		proximity_size,
		dump_cursor,
		accepts_payload_by_index,
		default_callbacks_state(game).get(SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable())
	)

static func accept_payload_state() -> bool:
	return false

static func handle_payload_state(payload_state: Variant) -> Variant:
	return payload_state

static func get_payload_default_state() -> Dictionary:
	return {
		"method": "public @Nullable Payload getPayload(){",
		"nullable": "@Nullable",
		"return_null": "return null;",
		"payload": null,
		"has_payload": false,
	}

static func take_payload_default_state() -> Dictionary:
	return {
		"comment": "/** Tries to take the payload. Returns null if no payload is present. */",
		"method": "public @Nullable Payload takePayload(){",
		"nullable": "@Nullable",
		"return_null": "return null;",
		"payload": null,
		"has_payload": false,
		"payload_taken": false,
	}

static func get_payloads_default_state() -> Dictionary:
	return {
		"method": "public @Nullable PayloadSeq getPayloads(){",
		"nullable": "@Nullable",
		"return_null": "return null;",
		"payloads": null,
		"has_payloads": false,
	}

static func payload_forward_offset(payload_block_size: int) -> int:
	return floori(float(payload_block_size) / 2.0) + 1

static func move_payload_state(has_next_tile: bool, has_next_build: bool, same_team: bool, accepts_payload: bool) -> bool:
	return has_next_tile and has_next_build and same_team and accepts_payload

static func dump_payload_index(loop_index: int, dump_cursor: int, proximity_size: int) -> int:
	return (loop_index + dump_cursor) % proximity_size

static func dump_payload_state(proximity_size: int, dump_cursor: int, accepts_payload_by_index: Array, increment_dump_cursor: Callable) -> Dictionary:
	if proximity_size == 0:
		return {"moved": false, "cdump": dump_cursor, "handled_index": -1}
	var dump := dump_cursor
	var next_dump := dump_cursor
	for i in range(proximity_size):
		var other_index := dump_payload_index(i, dump, proximity_size)
		next_dump = int(increment_dump_cursor.call(next_dump, proximity_size))
		if other_index < accepts_payload_by_index.size() and bool(accepts_payload_by_index[other_index]):
			return {"moved": true, "cdump": next_dump, "handled_index": other_index}
	return {"moved": false, "cdump": next_dump, "handled_index": -1}
