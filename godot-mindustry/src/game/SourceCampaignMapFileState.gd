extends RefCounted
class_name SourceCampaignMapFileState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_campaign_map_source_text_state := preload("res://src/game/SourceCampaignMapSourceTextState.gd")

const SOURCE_MAP_IO_CREATE_MAP := source_campaign_map_source_text_state.SOURCE_MAP_IO_CREATE_MAP
const SOURCE_MAP_IO_INFLATER_STREAM := source_campaign_map_source_text_state.SOURCE_MAP_IO_INFLATER_STREAM
const SOURCE_SAVE_HEADER := source_campaign_map_source_text_state.SOURCE_MAP_SAVE_HEADER
const SOURCE_GODOT_DECOMPRESS_CALL := "PackedByteArray.decompress_dynamic"
const KEY_VALUES := source_campaign_map_source_text_state.MAP_KEY_VALUES
const KEY_OFFSET := source_campaign_map_source_text_state.MAP_KEY_OFFSET
const KEY_COUNT := source_campaign_map_source_text_state.MAP_KEY_COUNT

static func launch_context_map_file_state(launch_context: Dictionary) -> Dictionary:
	return map_file_state(str(launch_context.get("sector_path", "")), launch_context)

static func map_file_state(path: String, launch_context: Dictionary = {}) -> Dictionary:
	var file_exists := FileAccess.file_exists(path)
	var compressed := FileAccess.get_file_as_bytes(path) if file_exists else PackedByteArray()
	var decompressed := compressed.decompress_dynamic(-1, FileAccess.COMPRESSION_DEFLATE) if not compressed.is_empty() else PackedByteArray()
	var header := decompressed.slice(0, 4).get_string_from_ascii() if decompressed.size() >= 4 else ""
	var version := _read_i32(decompressed, 4) if decompressed.size() >= 8 else -1
	var meta_length := _read_i32(decompressed, 8) if decompressed.size() >= 12 else 0
	var meta_state := _read_string_map(decompressed, 12, 12 + meta_length) if meta_length > 0 else {KEY_VALUES: {}, KEY_OFFSET: 12, KEY_COUNT: 0}
	var meta: Dictionary = meta_state.get(KEY_VALUES, {})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_MAP_FILE_STATE,
		"source": "mindustry.io.MapIO.createMap",
		"source_method": SOURCE_MAP_IO_CREATE_MAP,
		"inflater_stream": SOURCE_MAP_IO_INFLATER_STREAM,
		"path": path,
		"path_exists": file_exists,
		"compressed_size": compressed.size(),
		"decompressed_size": decompressed.size(),
		"header": header,
		"header_matches": header == SOURCE_SAVE_HEADER,
		"version": version,
		"meta_length": meta_length,
		"meta_entry_count": int(meta_state.get(KEY_COUNT, 0)),
		"meta_region_consumed": int(meta_state.get(KEY_OFFSET, -1)) == 12 + meta_length,
		"mapname": str(meta.get("mapname", "")),
		"width": int(meta.get("width", "0")),
		"height": int(meta.get("height", "0")),
		"wave": int(meta.get("wave", "0")),
		"wavetime": float(meta.get("wavetime", "0")),
		"rules": str(meta.get("rules", "{}")),
		"sector_id": str(launch_context.get("sector_id", "")),
		"sector_name": str(launch_context.get("sector_name", "")),
	}

static func _read_string_map(bytes: PackedByteArray, offset: int, byte_limit: int) -> Dictionary:
	var values := {}
	var count := _read_i16(bytes, offset)
	offset += 2
	for i in range(count):
		var key_state := _read_utf(bytes, offset, byte_limit)
		offset = int(key_state.get(KEY_OFFSET, offset))
		var value_state := _read_utf(bytes, offset, byte_limit)
		offset = int(value_state.get(KEY_OFFSET, offset))
		values[str(key_state.get("value", ""))] = str(value_state.get("value", ""))
	return {KEY_VALUES: values, KEY_OFFSET: offset, KEY_COUNT: count}

static func _read_utf(bytes: PackedByteArray, offset: int, byte_limit: int) -> Dictionary:
	var length := _read_u16(bytes, offset)
	offset += 2
	var end := mini(offset + length, byte_limit)
	var value := bytes.slice(offset, end).get_string_from_utf8()
	return {"value": value, KEY_OFFSET: end}

static func _read_i32(bytes: PackedByteArray, offset: int) -> int:
	if offset + 4 > bytes.size():
		return 0
	return (int(bytes[offset]) << 24) | (int(bytes[offset + 1]) << 16) | (int(bytes[offset + 2]) << 8) | int(bytes[offset + 3])

static func _read_i16(bytes: PackedByteArray, offset: int) -> int:
	var value := _read_u16(bytes, offset)
	return value - 65536 if value >= 32768 else value

static func _read_u16(bytes: PackedByteArray, offset: int) -> int:
	if offset + 2 > bytes.size():
		return 0
	return (int(bytes[offset]) << 8) | int(bytes[offset + 1])
