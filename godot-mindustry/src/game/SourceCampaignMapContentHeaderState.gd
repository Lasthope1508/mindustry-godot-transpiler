extends RefCounted
class_name SourceCampaignMapContentHeaderState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_campaign_map_source_text_state := preload("res://src/game/SourceCampaignMapSourceTextState.gd")

const SOURCE_SAVE_VERSION_READ_CONTENT_HEADER := source_campaign_map_source_text_state.SOURCE_MAP_SAVE_VERSION_READ_CONTENT_HEADER
const SOURCE_READ_MAPPED := source_campaign_map_source_text_state.SOURCE_MAP_READ_MAPPED
const SOURCE_CONTENT_TYPE_ALL := source_campaign_map_source_text_state.SOURCE_MAP_CONTENT_TYPE_ALL
const SOURCE_READ_NAME := source_campaign_map_source_text_state.SOURCE_MAP_READ_NAME
const SOURCE_SET_TEMPORARY_MAPPER := source_campaign_map_source_text_state.SOURCE_MAP_SET_TEMPORARY_MAPPER
const SOURCE_MAP_FILE_HEADER_SIZE := source_campaign_map_source_text_state.SOURCE_MAP_FILE_HEADER_SIZE
const KEY_OFFSET := source_campaign_map_source_text_state.MAP_KEY_OFFSET
const KEY_COUNT := source_campaign_map_source_text_state.MAP_KEY_COUNT
const KEY_VALUE := source_campaign_map_source_text_state.MAP_KEY_VALUE
const CONTENT_TYPE_NAMES := [
	"item",
	"block",
	"mech_UNUSED",
	"bullet",
	"liquid",
	"status",
	"unit",
	"weather",
	"effect_UNUSED",
	"sector",
	"loadout_UNUSED",
	"typeid_UNUSED",
	"error",
	"planet",
	"ammo_UNUSED",
	"team",
	"unitCommand",
	"unitStance",
]

static func campaign_map_content_header_state(map_file_state: Dictionary) -> Dictionary:
	var path := str(map_file_state.get("path", ""))
	var compressed := FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else PackedByteArray()
	var bytes := compressed.decompress_dynamic(-1, FileAccess.COMPRESSION_DEFLATE) if not compressed.is_empty() else PackedByteArray()
	var region := _content_region_offset(bytes, int(map_file_state.get("meta_length", 0)))
	var header_state := _read_content_header_region_state(bytes, int(region.get("offset", 0)), int(region.get("length", 0)))
	header_state["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_MAP_CONTENT_HEADER_STATE
	header_state["source"] = "mindustry.io.SaveVersion.readContentHeader"
	header_state["source_method"] = SOURCE_SAVE_VERSION_READ_CONTENT_HEADER
	header_state["path"] = path
	header_state["version"] = int(map_file_state.get("version", -1))
	header_state["content_region_offset"] = int(region.get("offset", 0))
	header_state["content_region_length"] = int(region.get("length", 0))
	header_state["content_region_kind"] = str(region.get("kind", ""))
	return header_state

static func _content_region_offset(bytes: PackedByteArray, meta_length: int) -> Dictionary:
	var offset := SOURCE_MAP_FILE_HEADER_SIZE + 4 + meta_length
	var length := _read_i32(bytes, offset)
	return {"offset": offset + 4, "length": length, "kind": "content"}

static func _read_content_header_region_state(bytes: PackedByteArray, offset: int, length: int) -> Dictionary:
	var limit := offset + length
	var mapped := _read_u8(bytes, offset)
	offset += 1
	var content_type_counts := {}
	var content_type_ordinals := {}
	var content_type_names_by_id := {}
	var content_id_names_by_type := {}
	var content_names_by_type := {}
	var content_type_samples := []
	for i in range(mapped):
		var type_ordinal := _read_u8(bytes, offset)
		offset += 1
		var type_name := _content_type_name(type_ordinal)
		var total := _read_i16(bytes, offset)
		offset += 2
		content_type_counts[type_name] = total
		content_type_ordinals[type_name] = type_ordinal
		content_type_names_by_id[str(type_ordinal)] = type_name
		var id_names := {}
		var names := []
		for j in range(total):
			var name_state := _read_utf(bytes, offset, limit)
			offset = int(name_state.get(KEY_OFFSET, offset))
			var name := str(name_state.get(KEY_VALUE, ""))
			id_names[str(j)] = name
			names.append(name)
		content_id_names_by_type[type_name] = id_names
		content_names_by_type[type_name] = names
		if content_type_samples.size() < 8:
			content_type_samples.append({"type": type_name, "ordinal": type_ordinal, "count": total, "first": names.slice(0, mini(4, names.size()))})
	return {
		"mapped_count": mapped,
		"content_header_consumed": offset == limit,
		"content_type_counts": content_type_counts,
		"content_type_ordinals": content_type_ordinals,
		"content_type_names_by_id": content_type_names_by_id,
		"content_id_names_by_type": content_id_names_by_type,
		"content_names_by_type": content_names_by_type,
		"content_type_samples": content_type_samples,
	}

static func _content_type_name(type_ordinal: int) -> String:
	if type_ordinal >= 0 and type_ordinal < CONTENT_TYPE_NAMES.size():
		return str(CONTENT_TYPE_NAMES[type_ordinal])
	return "unknown_%s" % type_ordinal

static func _read_utf(bytes: PackedByteArray, offset: int, byte_limit: int) -> Dictionary:
	var length := _read_u16(bytes, offset)
	offset += 2
	var end := mini(offset + length, byte_limit)
	var value := bytes.slice(offset, end).get_string_from_utf8()
	return {KEY_VALUE: value, KEY_OFFSET: end}

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

static func _read_u8(bytes: PackedByteArray, offset: int) -> int:
	return int(bytes[offset]) if offset < bytes.size() else 0
