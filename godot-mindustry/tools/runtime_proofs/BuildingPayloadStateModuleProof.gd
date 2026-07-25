extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingPayloadState := preload("res://src/game/SourceBuildingPayloadState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceBuildingPayloadState.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get("increment_dump_cursor", Callable()) == Callable(game, "source_increment_dump_cursor")
	var wrapper := game.source_dump_payload_state(3, 0, [false, true, false])
	var module := SourceBuildingPayloadState.dump_payload_state(
		3,
		0,
		[false, true, false],
		callbacks.get("increment_dump_cursor", Callable())
	)
	var empty_wrapper := game.source_dump_payload_state(0, 2, [])
	var empty_module := SourceBuildingPayloadState.dump_payload_state(
		0,
		2,
		[],
		callbacks.get("increment_dump_cursor", Callable())
	)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingPayloadState",
		"matches": wrapper == module and empty_wrapper == empty_module,
		"module_matches": wrapper == module and empty_wrapper == empty_module,
		"default_callbacks_match": default_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("BUILDING_PAYLOAD_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
