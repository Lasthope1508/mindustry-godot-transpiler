extends RefCounted
class_name SourceCampaignMapTileState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_campaign_map_source_text_state := preload("res://src/game/SourceCampaignMapSourceTextState.gd")

const SOURCE_SAVE_VERSION_READ_MAP := source_campaign_map_source_text_state.SOURCE_MAP_SAVE_VERSION_READ_MAP
const SOURCE_READ_FLOOR := source_campaign_map_source_text_state.SOURCE_MAP_READ_FLOOR
const SOURCE_READ_BLOCK := source_campaign_map_source_text_state.SOURCE_MAP_READ_BLOCK
const SOURCE_VERSION_11_PATCH_REGION := source_campaign_map_source_text_state.SOURCE_MAP_VERSION_11_PATCH_REGION
const SOURCE_MAP_FILE_HEADER_SIZE := source_campaign_map_source_text_state.SOURCE_MAP_FILE_HEADER_SIZE
const SOURCE_SET_BLOCK_CENTER_ONLY := source_campaign_map_source_text_state.SOURCE_MAP_SET_BLOCK_CENTER_ONLY
const SOURCE_BLOCK_CONSECUTIVES := source_campaign_map_source_text_state.SOURCE_MAP_BLOCK_CONSECUTIVES
const AIR_BLOCK_NAME := "air"

static func campaign_map_tile_state(map_file_state: Dictionary, content_header_state: Dictionary = {}) -> Dictionary:
	var path := str(map_file_state.get("path", ""))
	var compressed := FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else PackedByteArray()
	var bytes := compressed.decompress_dynamic(-1, FileAccess.COMPRESSION_DEFLATE) if not compressed.is_empty() else PackedByteArray()
	var version := int(map_file_state.get("version", -1))
	var region := _map_region_offset(bytes, version, int(map_file_state.get("meta_length", 0)))
	var block_id_names: Dictionary = content_header_state.get("content_id_names_by_type", {}).get("block", {})
	var map_state := _read_map_region_state(bytes, int(region.get("offset", 0)), int(region.get("length", 0)), block_id_names)
	map_state["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_MAP_TILE_STATE
	map_state["source"] = "mindustry.io.SaveVersion.readMap"
	map_state["source_method"] = SOURCE_SAVE_VERSION_READ_MAP
	map_state["path"] = path
	map_state["version"] = version
	map_state["map_region_offset"] = int(region.get("offset", 0))
	map_state["map_region_length"] = int(region.get("length", 0))
	map_state["map_region_kind"] = str(region.get("kind", ""))
	return map_state

static func _map_region_offset(bytes: PackedByteArray, version: int, meta_length: int) -> Dictionary:
	var offset := SOURCE_MAP_FILE_HEADER_SIZE + 4 + meta_length
	if version >= 12:
		offset = _skip_chunk(bytes, offset)
		offset = _skip_chunk(bytes, offset)
	elif version == 11:
		offset = _skip_chunk(bytes, offset)
		offset = _skip_chunk(bytes, offset)
	else:
		offset = _skip_chunk(bytes, offset)
	var length := _read_i32(bytes, offset)
	return {"offset": offset + 4, "length": length, "kind": "map"}

static func _read_map_region_state(bytes: PackedByteArray, offset: int, length: int, block_id_names: Dictionary = {}) -> Dictionary:
	var limit := offset + length
	var width := _read_u16(bytes, offset)
	var height := _read_u16(bytes, offset + 2)
	offset += 4
	var cells := width * height
	var floor_id_counts := {}
	var overlay_id_counts := {}
	var floor_run_count := 0
	var overlay_non_air_cell_count := 0
	var floor_runs := []
	var floor_samples := []
	var i := 0
	while i < cells and offset + 5 <= limit:
		var floor_id := _read_i16(bytes, offset)
		var overlay_id := _read_i16(bytes, offset + 2)
		var consecutives := _read_u8(bytes, offset + 4)
		offset += 5
		var run_length := consecutives + 1
		floor_run_count += 1
		_increment_count(floor_id_counts, floor_id, run_length)
		_increment_count(overlay_id_counts, overlay_id, run_length)
		if overlay_id != 0:
			overlay_non_air_cell_count += run_length
		floor_runs.append({"x": i % width, "y": _cell_y_from_index(i, width), "floor_id": floor_id, "floor_name": _content_name_for_id(block_id_names, floor_id), "overlay_id": overlay_id, "overlay_name": _content_name_for_id(block_id_names, overlay_id), "run_length": run_length})
		if floor_samples.size() < 8:
			floor_samples.append({"x": i % width, "y": _cell_y_from_index(i, width), "floor_id": floor_id, "floor_name": _content_name_for_id(block_id_names, floor_id), "overlay_id": overlay_id, "overlay_name": _content_name_for_id(block_id_names, overlay_id), "run_length": run_length})
		i += run_length
	var block_id_counts := {}
	var block_placements := []
	var block_placement_name_counts := {}
	var block_samples := []
	var block_run_count := 0
	var entity_tile_count := 0
	var center_entity_tile_count := 0
	var non_center_entity_tile_count := 0
	var data_tile_count := 0
	var source_block_origin_count := 0
	i = 0
	while i < cells and offset + 3 <= limit:
		var block_id := _read_i16(bytes, offset)
		var packed := _read_u8(bytes, offset + 2)
		offset += 3
		var had_entity := (packed & 1) != 0
		var had_data := (packed & 4) != 0
		var is_center := true
		var run_length := 1
		if had_data:
			data_tile_count += 1
			offset += 7
		if had_entity:
			entity_tile_count += 1
			is_center = _read_u8(bytes, offset) != 0
			offset += 1
			if is_center:
				center_entity_tile_count += 1
				offset = _skip_chunk(bytes, offset)
			else:
				non_center_entity_tile_count += 1
		elif not had_data:
			var block_consecutives := _read_u8(bytes, offset)
			offset += 1
			run_length = block_consecutives + 1
		block_run_count += 1
		_increment_count(block_id_counts, block_id, run_length)
		var block_name := _content_name_for_id(block_id_names, block_id)
		if block_name != AIR_BLOCK_NAME:
			if had_entity:
				if is_center:
					_append_block_placement(block_placements, block_placement_name_counts, i, width, block_id, block_name, packed, had_entity, had_data, is_center)
					source_block_origin_count += 1
			else:
				for placement_offset in range(run_length):
					_append_block_placement(block_placements, block_placement_name_counts, i + placement_offset, width, block_id, block_name, packed, had_entity, had_data, true)
					source_block_origin_count += 1
		if block_samples.size() < 8:
			block_samples.append({"x": i % width, "y": _cell_y_from_index(i, width), "block_id": block_id, "block_name": _content_name_for_id(block_id_names, block_id), "packed": packed, "run_length": run_length})
		i += run_length
	return {
		"width": width,
		"height": height,
		"cell_count": cells,
		"map_region_consumed": offset == limit,
		"floor_run_count": floor_run_count,
		"floor_runs": floor_runs,
		"floor_id_counts": floor_id_counts,
		"floor_name_counts": _name_counts_from_id_counts(floor_id_counts, block_id_names),
		"unique_floor_id_count": floor_id_counts.size(),
		"overlay_id_counts": overlay_id_counts,
		"overlay_name_counts": _name_counts_from_id_counts(overlay_id_counts, block_id_names),
		"unique_overlay_id_count": overlay_id_counts.size(),
		"overlay_non_air_cell_count": overlay_non_air_cell_count,
		"block_run_count": block_run_count,
		"block_id_counts": block_id_counts,
		"block_name_counts": _name_counts_from_id_counts(block_id_counts, block_id_names),
		"unique_block_id_count": block_id_counts.size(),
		"block_placements": block_placements,
		"block_placement_name_counts": block_placement_name_counts,
		"block_placement_count": source_block_origin_count,
		"entity_tile_count": entity_tile_count,
		"center_entity_tile_count": center_entity_tile_count,
		"non_center_entity_tile_count": non_center_entity_tile_count,
		"data_tile_count": data_tile_count,
		"floor_samples": floor_samples,
		"block_samples": block_samples,
	}

static func _append_block_placement(block_placements: Array, block_placement_name_counts: Dictionary, cell_index: int, width: int, block_id: int, block_name: String, packed: int, had_entity: bool, had_data: bool, is_center: bool) -> void:
	var cell := {"x": cell_index % width, "y": _cell_y_from_index(cell_index, width)}
	block_placements.append({
		"key": block_name,
		"role": "campaign_block",
		"cell": cell,
		"block_id": block_id,
		"packed": packed,
		"had_entity": had_entity,
		"had_data": had_data,
		"is_center": is_center,
	})
	block_placement_name_counts[block_name] = int(block_placement_name_counts.get(block_name, 0)) + 1

static func _cell_y_from_index(cell_index: int, width: int) -> int:
	if width <= 0:
		return 0
	return floori(float(cell_index) / float(width))

static func _increment_count(counts: Dictionary, id_value: int, amount: int) -> void:
	var key := str(id_value)
	counts[key] = int(counts.get(key, 0)) + amount

static func _name_counts_from_id_counts(id_counts: Dictionary, id_names: Dictionary) -> Dictionary:
	var name_counts := {}
	for id_key in id_counts.keys():
		var name := _content_name_for_id(id_names, int(str(id_key)))
		name_counts[name] = int(name_counts.get(name, 0)) + int(id_counts.get(id_key, 0))
	return name_counts

static func _content_name_for_id(id_names: Dictionary, id_value: int) -> String:
	return str(id_names.get(str(id_value), str(id_value)))

static func _skip_chunk(bytes: PackedByteArray, offset: int) -> int:
	var length := _read_i32(bytes, offset)
	return offset + 4 + length

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
