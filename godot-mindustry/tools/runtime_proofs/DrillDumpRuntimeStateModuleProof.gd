extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_drill_dump_runtime_state_script := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_drill_dump_runtime_state_script.default_callbacks_state(game)
	var block_id := source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL
	var default_callbacks_match: bool = callbacks.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_CALLBACK_KEY, Callable()) == Callable(game, source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_METHOD_FALLBACK)
	var wrapper := game.source_drill_dump_interval(block_id, 1.5)
	var module := source_drill_dump_runtime_state_script.game_dump_interval(game, block_id, 1.5)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceDrillDumpRuntimeState",
		"matches": is_equal_approx(float(wrapper), float(module)),
		"game_interval_matches": is_equal_approx(float(wrapper), float(module)),
		"default_callbacks_match": default_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("DRILL_DUMP_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
