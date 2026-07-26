extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var source_state := game.source_block_is_darkened_state(true, false, false, true, false, "tile")
	var bridge_state := game.generated_block_is_darkened_bridge_state(true, false, false, true, false, "tile")
	var proof := {
		"module": "SourceBlockQueryState",
		"source_matches_module": source_state == game.source_block_is_darkened_state(true, false, false, true, false, "tile"),
		"bridge_matches": bridge_state.get("matches", false),
	}
	print("BLOCK_QUERY_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(10.0).timeout
	get_tree().quit(0)
