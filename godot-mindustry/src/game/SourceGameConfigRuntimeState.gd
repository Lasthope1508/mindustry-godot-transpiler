extends RefCounted
class_name SourceGameConfigRuntimeState

const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

static func load_config(game: Object) -> void:
	var document := source_ssot_accessor_runtime_state.playable_content_document_state()
	if not bool(document.get("loaded", false)):
		push_error("Missing playable content manifest: playable_content")
		return
	var config: Dictionary = document.get("data", {})
	game.set("config", config)
	if not config.has("tile_size"):
		push_error("Missing playable content tile_size")
		return
	game.set("tile_size", int(config["tile_size"]))
