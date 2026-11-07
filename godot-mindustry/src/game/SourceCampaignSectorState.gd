extends RefCounted
class_name SourceCampaignSectorState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_campaign_shell_state := preload("res://src/game/SourceCampaignShellState.gd")

const SOURCE_SECTOR_EXTENSION := "msav"

static func serpulo_sector_list_state() -> Dictionary:
	return sector_list_state("serpulo", source_campaign_shell_state.SOURCE_SERPULO_MAP_ROOT, _collect_sector_paths(source_campaign_shell_state.SOURCE_SERPULO_MAP_ROOT))

static func sector_list_state(planet_id: String, map_root: String, paths: Array) -> Dictionary:
	var sectors := []
	var visible_sectors := []
	var hidden_sector_count := 0
	for path_value in paths:
		var path := str(path_value).replace("\\", "/")
		if not path.ends_with("." + SOURCE_SECTOR_EXTENSION):
			continue
		var hidden := path.contains("/hidden/")
		var sector := {
			"planet_id": planet_id,
			"id": path.get_file().get_basename(),
			"display_name": _display_name_from_id(path.get_file().get_basename()),
			"path": path,
			"hidden": hidden,
		}
		sectors.append(sector)
		if hidden:
			hidden_sector_count += 1
		else:
			visible_sectors.append(sector)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_SECTOR_LIST_STATE,
		"planet_id": planet_id,
		"map_root": map_root,
		"sector_count": sectors.size(),
		"visible_sector_count": visible_sectors.size(),
		"hidden_sector_count": hidden_sector_count,
		"sectors": sectors,
		"visible_sectors": visible_sectors,
	}

static func _collect_sector_paths(root_path: String) -> Array:
	var paths := []
	_collect_sector_paths_into(root_path, paths)
	paths.sort()
	return paths

static func _collect_sector_paths_into(root_path: String, paths: Array) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var entry := dir.get_next()
		if entry == "":
			break
		if entry == "." or entry == "..":
			continue
		var path := root_path.path_join(entry)
		if dir.current_is_dir():
			_collect_sector_paths_into(path, paths)
		elif path.ends_with("." + SOURCE_SECTOR_EXTENSION):
			paths.append(path)
	dir.list_dir_end()

static func _display_name_from_id(sector_id: String) -> String:
	var words := PackedStringArray()
	var current := ""
	for i in sector_id.length():
		var character := sector_id.substr(i, 1)
		if i > 0 and character == character.to_upper() and character != character.to_lower():
			words.append(current)
			current = character
		elif i > 0 and character.is_valid_int() and not sector_id.substr(i - 1, 1).is_valid_int():
			words.append(current)
			current = character
		else:
			current += character
	if not current.is_empty():
		words.append(current)
	var display_words := PackedStringArray()
	for word in words:
		display_words.append(word.capitalize())
	return " ".join(display_words)
