extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_drill_production_runtime_state_script := preload("res://src/game/SourceDrillProductionRuntimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_drill_production_runtime_state_script.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get(source_drill_production_runtime_state_script.SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_KEY, Callable()) == Callable(game, source_drill_production_runtime_state_script.SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_FALLBACK) \
		and callbacks.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_KEY, Callable()) == Callable(game, source_drill_production_runtime_state_script.SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_FALLBACK)
	var override_callbacks := source_drill_production_runtime_state_script.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_drill_production_runtime_state_script.SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_KEY, Callable()) == Callable(self, "proof_drill_output_batch") \
		and override_callbacks.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_KEY, Callable()) == Callable(self, "proof_drill_progress_fraction")
	var wrapper := game.source_drill_production_runtime_state(0.25, 2.0, 1.5, 3, 8, 10)
	var primitive_module := source_drill_production_runtime_state_script.production_state(
		0.25,
		2.0,
		1.5,
		3,
		8,
		10,
		callbacks.get("output_batch", Callable()),
		callbacks.get("progress_fraction", Callable())
	)
	var module := source_drill_production_runtime_state_script.game_production_state(game, 0.25, 2.0, 1.5, 3, 8, 10)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceDrillProductionRuntimeState",
		"matches": wrapper == module,
		"module_matches": module == primitive_module,
		"default_callbacks_match": default_callbacks_match,
		"override_callbacks_match": override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("DRILL_PRODUCTION_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func proof_drill_output_batch(progress: float, delay: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	return source_drill_production_runtime_state_script.output_batch(progress, delay, dominant_items, items_total, item_capacity)

func proof_drill_progress_fraction(progress: float, delay: float, has_dominant_item: bool) -> float:
	return source_drill_production_runtime_state_script.progress_fraction(progress, delay, has_dominant_item)

func _drill_production_method_names() -> Dictionary:
	return {
		source_drill_production_runtime_state_script.SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_KEY: "proof_drill_output_batch",
		source_drill_production_runtime_state_script.SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_KEY: "proof_drill_progress_fraction",
	}
