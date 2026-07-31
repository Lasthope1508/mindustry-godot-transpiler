extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_drill_runtime_state_script := preload("res://src/game/SourceDrillRuntimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_drill_runtime_state_script.default_callbacks_state(game)
	var runtime_callbacks := source_drill_runtime_state_script.runtime_callbacks(game)
	var warmup_wrapper := game.step_drill_warmup_cell(0, 0, 0.0)
	var warmup_module := source_drill_runtime_state_script.game_step_drill_warmup_cell(game, 0, 0, 0.0)
	var time_drilled_wrapper := game.step_drill_time_drilled_cell(0, 0, 0.0, 0.0)
	var time_drilled_module := source_drill_runtime_state_script.game_step_drill_time_drilled_cell(game, 0, 0, 0.0, 0.0)
	var last_speed_wrapper := game.source_drill_last_speed_for_cell(0, 0, "copper", 2, 1.0)
	var last_speed_module := source_drill_runtime_state_script.game_last_speed_for_cell(game, 0, 0, "copper", 2, 1.0)
	var output_delta_wrapper := game.source_drill_output_delta_for_cell(0, 0, 2, 1.0)
	var output_delta_module := source_drill_runtime_state_script.game_output_delta_for_cell(game, 0, 0, 2, 1.0)
	var expected_callbacks := {
		source_drill_runtime_state_script.SOURCE_DRILL_OCCUPIED_CELLS_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_OCCUPIED_CELLS_CALLBACK_KEY),
		source_drill_runtime_state_script.SOURCE_DRILL_CELL_KEY_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_CELL_KEY_CALLBACK_KEY),
		source_drill_runtime_state_script.SOURCE_DRILL_DELAY_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_DELAY_METHOD_FALLBACK),
		source_drill_runtime_state_script.SOURCE_DRILL_APPROACH_DELTA_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_APPROACH_DELTA_METHOD),
		source_drill_runtime_state_script.SOURCE_DRILL_BUILDING_DELTA_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_BUILDING_DELTA_METHOD),
	}
	var expected_runtime_callbacks := {
		source_drill_runtime_state_script.SOURCE_DRILL_WARMUP_SPEED_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_WARMUP_SPEED_METHOD_FALLBACK),
		source_drill_runtime_state_script.SOURCE_DRILL_WARMUP_STATE_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_WARMUP_STATE_METHOD_FALLBACK),
		source_drill_runtime_state_script.SOURCE_DRILL_INACTIVE_WARMUP_STATE_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_INACTIVE_WARMUP_STATE_METHOD_FALLBACK),
		source_drill_runtime_state_script.SOURCE_DRILL_TIME_DRILLED_DELTA_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_TIME_DRILLED_DELTA_METHOD_FALLBACK),
		source_drill_runtime_state_script.SOURCE_DRILL_LAST_SPEED_FOR_CELL_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_LAST_SPEED_FOR_CELL_METHOD_FALLBACK),
		source_drill_runtime_state_script.SOURCE_DRILL_DELAY_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_DELAY_METHOD_FALLBACK),
		source_drill_runtime_state_script.SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_FALLBACK),
		source_drill_runtime_state_script.SOURCE_DRILL_PRODUCTION_STATE_CALLBACK_KEY: Callable(game, source_drill_runtime_state_script.SOURCE_DRILL_PRODUCTION_RUNTIME_STATE_METHOD_FALLBACK),
	}
	var direct_method_constants_valid := game.has_method(source_drill_runtime_state_script.SOURCE_DRILL_LAST_SPEED_METHOD) and game.has_method(source_drill_runtime_state_script.SOURCE_DRILL_OUTPUT_DELTA_METHOD)
	var method_key_constants_valid := (
		source_drill_runtime_state_script.SOURCE_DRILL_BLOCK_ITEM_CAPACITY_METHOD_KEY != source_drill_runtime_state_script.SOURCE_DRILL_BLOCK_ITEM_CAPACITY_METHOD_FALLBACK
		and source_drill_runtime_state_script.SOURCE_DRILL_BLOCK_TIME_SCALE_AT_CELL_METHOD_KEY != source_drill_runtime_state_script.SOURCE_DRILL_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK
		and source_drill_runtime_state_script.SOURCE_DRILL_WARMUP_SPEED_METHOD_KEY != source_drill_runtime_state_script.SOURCE_DRILL_WARMUP_SPEED_METHOD_FALLBACK
		and source_drill_runtime_state_script.SOURCE_DRILL_PRODUCTION_RUNTIME_STATE_METHOD_KEY != source_drill_runtime_state_script.SOURCE_DRILL_PRODUCTION_RUNTIME_STATE_METHOD_FALLBACK
		and game.has_method(source_drill_runtime_state_script.SOURCE_DRILL_ITEMS_TOTAL_METHOD)
		and game.has_method(source_drill_runtime_state_script.SOURCE_DRILL_WARMUP_AT_CELL_METHOD)
		and game.has_method(source_drill_runtime_state_script.SOURCE_DRILL_TIME_DRILLED_AT_CELL_METHOD)
		and game.has_method(source_drill_runtime_state_script.SOURCE_DRILL_LAST_SPEED_AT_CELL_METHOD)
	)
	var drill_context := source_drill_runtime_state_script.runtime_context(game, 1.0, Vector2i(0, 0), "mechanical-drill", "copper", 2, 60.0)
	var drill_result := source_drill_runtime_state_script.runtime_state(drill_context, runtime_callbacks)
	var context_schema_constants_valid := (
		drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_ACTIVE_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_CELL_X_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_CELL_Y_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_BLOCK_ID_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_ITEM_ID_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_DOMINANT_ITEMS_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_ITEMS_TOTAL_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_ITEM_CAPACITY_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_CURRENT_WARMUP_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_CURRENT_TIME_DRILLED_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_CURRENT_LAST_SPEED_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_CURRENT_PROGRESS_FRACTION_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_SECONDS_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_SOURCE_DELTA_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_TIME_SCALE_KEY)
		and drill_context.has(source_drill_runtime_state_script.SOURCE_DRILL_CONTEXT_SPEED_KEY)
	)
	var result_schema_constants_valid := (
		drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_ACTIVE_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_WARMUP_BEFORE_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_WARMUP_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_LAST_SPEED_BEFORE_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_LAST_SPEED_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_TIME_DRILLED_BEFORE_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_TIME_DRILLED_DELTA_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_TIME_DRILLED_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_DELAY_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_OUTPUT_DELTA_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_PRODUCTION_STATE_KEY)
		and drill_result.has(source_drill_runtime_state_script.source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_OFFLOAD_AMOUNT_KEY)
		and drill_result.has(source_drill_runtime_state_script.source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_PRODUCED_DELTA_KEY)
		and drill_result.has(source_drill_runtime_state_script.source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_ITEM_PROGRESS_KEY)
		and drill_result.has(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_SOURCE_OWNER_KEY)
	)
	var proof := {
		"module": "SourceDrillRuntimeState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"runtime_callbacks_match": runtime_callbacks == expected_runtime_callbacks,
		"direct_method_constants_valid": direct_method_constants_valid,
		"method_key_constants_valid": method_key_constants_valid,
		"context_schema_constants_valid": context_schema_constants_valid,
		"result_schema_constants_valid": result_schema_constants_valid,
		"warmup_matches": warmup_wrapper == warmup_module,
		"time_drilled_matches": time_drilled_wrapper == time_drilled_module,
		"last_speed_for_cell_matches": last_speed_wrapper == last_speed_module and last_speed_module == 0.0,
		"output_delta_for_cell_matches": output_delta_wrapper == output_delta_module and output_delta_module == 0.0,
		"one_headquarter_per_ssot": bool(source_ssot_catalog.canonical_headquarter_registry_state().get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(source_ssot_catalog.canonical_headquarter_registry_state().get("errors", []).is_empty()),
	}
	print("DRILL_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
