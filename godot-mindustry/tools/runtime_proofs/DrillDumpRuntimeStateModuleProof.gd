extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceDrillDumpRuntimeState := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const SourcePlayableScenarioDefaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceDrillDumpRuntimeState.default_callbacks_state(game)
	var block_id := SourcePlayableScenarioDefaults.BLOCK_MECHANICAL_DRILL
	var default_callbacks_match: bool = callbacks.get("block_dump_time", Callable()) == Callable(game, "source_block_dump_time")
	var wrapper := game.source_drill_dump_interval(block_id, 1.5)
	var module := SourceDrillDumpRuntimeState.dump_interval(block_id, 1.5, callbacks.get("block_dump_time", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceDrillDumpRuntimeState",
		"matches": is_equal_approx(float(wrapper), float(module)),
		"default_callbacks_match": default_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("DRILL_DUMP_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
