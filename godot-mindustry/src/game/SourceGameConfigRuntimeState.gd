extends RefCounted
class_name SourceGameConfigRuntimeState

const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

static func load_config(game: Object) -> void:
	var document := source_ssot_catalog.load_document("playable_content")
	if not bool(document.get("loaded", false)):
		push_error("Missing playable content manifest: playable_content")
		return
	var config: Dictionary = document.get("data", {})
	game.set("config", config)
	if not config.has("tile_size"):
		push_error("Missing playable content tile_size")
		return
	game.set("tile_size", int(config["tile_size"]))
