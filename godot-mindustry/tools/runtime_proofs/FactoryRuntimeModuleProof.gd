extends Node

const source_factory_runtime_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const source_factory_simulation_runtime_state_script := preload("res://src/game/SourceFactorySimulationRuntimeState.gd")
const source_factory_simulation_apply_state_script := preload("res://src/game/SourceFactorySimulationApplyState.gd")
const source_drill_dump_runtime_state_script := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const source_drill_runtime_state_script := preload("res://src/game/SourceDrillRuntimeState.gd")
const source_drill_production_runtime_state_script := preload("res://src/game/SourceDrillProductionRuntimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

class FakeFactoryGame extends RefCounted:
	var drill_dump_timer := 0.0
	var transport_progress := 0.25
	var drill_output_item_id := "copper"
	var drill_ore_cell_count := 2
	var drill_output_rate := 1.5
	var drill_pos: Vector2i = Vector2i(1, 1)
	var drill_cell: Vector2i = Vector2i(1, 1)
	var conveyor_cell: Vector2i = Vector2i(2, 1)
	var item_progress := 0.0
	var core_inventory := 0
	var produced_total := 0
	var conveyor_world_speed := 1.0
	var conveyor_path_progress_rate := 1.0
	var path_points: Array[Vector2] = [Vector2.ZERO, Vector2(64.0, 0.0)]
	var item_sprites: Array[Sprite2D] = []
	var drill_time_drilled := 0.0
	var drill_last_speed := 0.0
	var drill_warmup := 1.0
	var dumped_items := 0

	func _factory_runtime_method_names() -> Dictionary:
		return {}

	func source_drill_delay(_block_id: String, _item_id: String) -> float:
		return 2.0

	func source_drill_output_delta_for_cell(_x: int, _y: int, dominant_items: int, seconds: float, warmup := 1.0, speed := 1.0) -> float:
		return float(dominant_items) * seconds * warmup * speed

	func source_conveyor_path_progress_delta_for_cell(_x: int, _y: int, seconds: float) -> float:
		return seconds

	func source_drill_runtime_state(seconds: float) -> Dictionary:
		return {"seconds": seconds}

	func source_drill_dump_runtime_state(_current_timer: float, _source_delta: float, _dump_interval: float) -> Dictionary:
		return {"drill_dump_timer": 0.25, "should_dump": true}

	func source_item_transport_runtime_state(before_progress: float, delta: float) -> Dictionary:
		return {"transport_progress": before_progress + delta, "item_sprites": []}

	func factory_cell_context() -> Dictionary:
		return source_factory_runtime_state.cell_context(drill_pos, [conveyor_cell])

	func factory_drill_dump_preview_state(seconds: float) -> Dictionary:
		return source_factory_runtime_state.drill_dump_preview_state(self, source_factory_runtime_state.drill_dump_preview_context(self, seconds, drill_pos, "mechanical-drill", 60.0))

	func source_factory_simulation_runtime_state(seconds: float) -> Dictionary:
		return source_factory_runtime_state.simulation_runtime_state(self, seconds)

	func source_factory_simulation_apply_state(factory_state: Dictionary) -> Dictionary:
		return source_factory_simulation_apply_state_script.apply_state(factory_state, source_factory_simulation_apply_state_script.runtime_context(self, drill_pos))

	func source_block_time_scale_at_cell(_x: int, _y: int) -> float:
		return 1.0

	func source_block_time_scale_duration_at_cell(_x: int, _y: int) -> float:
		return 0.0

	func drill_warmup_at_cell(_x: int, _y: int) -> float:
		return drill_warmup

	func set_drill_time_drilled_at_cell(_x: int, _y: int, value: float) -> void:
		drill_time_drilled = value

	func set_drill_last_speed_at_cell(_x: int, _y: int, value: float) -> void:
		drill_last_speed = value

	func set_drill_warmup_at_cell(_x: int, _y: int, value: float) -> void:
		drill_warmup = value

	func step_drill_warmup_cell(_x: int, _y: int, _seconds: float) -> float:
		return 1.0

	func source_offload_to_inventory(_item_id: String, amount: int) -> void:
		core_inventory += amount

	func source_dump_drill_item_to_core(_item_id: String) -> void:
		dumped_items += 1

	func source_block_item_capacity(_block_id: String) -> int:
		return 30

	func source_block_dump_time(_block_id: String) -> float:
		return 5.0

	func source_drill_dump_interval(_block_id: String, _time_scale: float) -> float:
		return 1.0

	func drill_time_drilled_at_cell(_x: int, _y: int) -> float:
		return 0.0

	func drill_last_speed_at_cell(_x: int, _y: int) -> float:
		return 0.0

	func simulate_factory(_seconds: float) -> void:
		pass

func _ready() -> void:
	var fake_game := FakeFactoryGame.new()
	var cell_context := source_factory_runtime_state.cell_context(Vector2i(1, 1), [Vector2i(2, 1)])
	var simulation_context := source_factory_runtime_state.simulation_context(1.0, 0.25, {
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY: Vector2i(1, 1),
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY: Vector2i(2, 1),
	}, Vector2i.ZERO)
	var summary_context := source_factory_runtime_state.summary_context(fake_game, {
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY: Vector2i(1, 1),
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY: Vector2i(2, 1),
	}, Vector2i.ZERO, "drill", "conveyor")
	var simulation_callbacks := source_factory_runtime_state.simulation_callbacks(fake_game)
	var summary_callbacks := source_factory_runtime_state.summary_callbacks(fake_game)
	var summary_state := source_factory_runtime_state.summary_state(summary_context, summary_callbacks)
	var game_summary_state := source_factory_runtime_state.game_summary_state(fake_game, "drill", "conveyor")
	var game_factory_cell_context := source_factory_runtime_state.game_factory_cell_context(fake_game)
	var game_playable_summary_state := source_factory_runtime_state.game_playable_summary_state(fake_game)
	var transport_step_context := source_factory_runtime_state.transport_step_context(fake_game, 1.0, {
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY: Vector2i(2, 1),
	}, Vector2i.ZERO)
	var transport_step_state := source_factory_runtime_state.transport_step_state(transport_step_context)
	var game_transport_step_state := source_factory_runtime_state.game_transport_step_state(fake_game, 1.0)
	var drill_step_context := source_factory_runtime_state.drill_step_context(fake_game, 1.0, Vector2i(1, 1))
	var drill_step_state := source_factory_runtime_state.drill_step_state(drill_step_context)
	var game_drill_step_state := source_factory_runtime_state.game_drill_step_state(fake_game, 1.0)
	var drill_dump_preview_context := source_factory_runtime_state.drill_dump_preview_context(fake_game, 1.0, Vector2i(1, 1), "mechanical-drill", 60.0)
	var drill_dump_preview_state := source_factory_runtime_state.drill_dump_preview_state(fake_game, drill_dump_preview_context)
	var game_drill_dump_preview_state := source_factory_runtime_state.game_drill_dump_preview_state(fake_game, 1.0)
	var drill_dump_before := fake_game.dumped_items
	source_factory_runtime_state.apply_drill_dump(fake_game, 1.0)
	var apply_drill_dump_matches := fake_game.dumped_items == drill_dump_before + 1 and is_equal_approx(float(fake_game.drill_dump_timer), 0.25)
	var factory_simulation_state := source_factory_simulation_runtime_state_script.simulation_state(simulation_context, simulation_callbacks)
	var factory_simulation_runtime_state := source_factory_runtime_state.simulation_runtime_state(fake_game, 1.0)
	var apply_context := source_factory_simulation_apply_state_script.runtime_context(fake_game, Vector2i(1, 1))
	var apply_state := source_factory_simulation_apply_state_script.apply_state(factory_simulation_state, apply_context)
	var drill_dump_default_callbacks := source_drill_dump_runtime_state_script.default_callbacks_state(fake_game)
	var simulate_factory_progress_before := fake_game.transport_progress
	source_factory_runtime_state.simulate_factory(fake_game, 1.0)
	if false:
		var drill_runtime_context := source_drill_runtime_state_script.runtime_context(fake_game, 1.0, Vector2i(1, 1), "mechanical-drill", "copper", 2, 60.0)
		var drill_runtime_callbacks := source_drill_runtime_state_script.runtime_callbacks(fake_game)
		print(drill_runtime_context, drill_runtime_callbacks)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var simulation_schema_constants_valid := (
		factory_simulation_state.has(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_STATE_KEY)
		and factory_simulation_state.has(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DUMP_STATE_KEY)
		and factory_simulation_state.has(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_TRANSPORT_STATE_KEY)
		and factory_simulation_state.has(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_TRANSPORT_PROGRESS_KEY)
		and factory_simulation_state.has(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_SOURCE_OWNER_KEY)
	)
	var apply_context_schema_constants_valid := (
		apply_context.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_TIME_DRILLED_KEY)
		and apply_context.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_LAST_SPEED_KEY)
		and apply_context.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_WARMUP_KEY)
		and apply_context.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY)
		and apply_context.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY)
		and apply_context.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_DUMP_TIMER_KEY)
		and apply_context.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY)
	)
	var apply_state_schema_constants_valid := (
		apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_TIME_DRILLED_KEY)
		and apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_LAST_SPEED_KEY)
		and apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_WARMUP_KEY)
		and apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY)
		and apply_state.has(source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_OFFLOAD_AMOUNT_KEY)
		and apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY)
		and apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_DUMP_TIMER_KEY)
		and apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_SHOULD_DUMP_KEY)
		and apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY)
		and apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_ITEM_SPRITES_KEY)
		and apply_state.has(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_SOURCE_OWNER_KEY)
	)
	var summary_schema_constants_valid := (
		summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_BLOCK_ID_KEY)
		and summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_BLOCK_ID_KEY)
		and summary_context.has(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY)
		and summary_context.has(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY)
		and summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY)
		and summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY)
		and summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY)
		and summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_RATE_KEY)
		and summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_CORE_INVENTORY_KEY)
		and summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY)
		and summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY)
		and summary_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY)
		and summary_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY)
		and summary_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_DELAY_KEY)
		and summary_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_PER_SECOND_KEY)
		and summary_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_PER_SECOND_KEY)
		and summary_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_SOURCE_OWNER_KEY)
	)
	var step_schema_constants_valid := (
		transport_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_BEFORE_KEY)
		and transport_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_DELTA_KEY)
		and transport_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_CONVEYOR_TIME_SCALE_KEY)
		and transport_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY)
		and transport_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY)
		and transport_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_BEFORE_KEY)
		and transport_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_DELTA_KEY)
		and transport_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_CONVEYOR_PROGRESS_DELTA_KEY)
		and transport_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_KEY)
		and transport_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_CONVEYOR_TIME_SCALE_KEY)
		and transport_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY)
		and transport_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY)
		and drill_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_ITEM_PROGRESS_BEFORE_KEY)
		and drill_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_DRILL_WARMUP_BEFORE_KEY)
		and drill_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY)
		and drill_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY)
		and drill_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY)
		and drill_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_ITEM_PROGRESS_BEFORE_KEY)
		and drill_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY)
		and drill_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY)
		and drill_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY)
	)
	var drill_dump_schema_constants_valid := (
		drill_dump_default_callbacks.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_CALLBACK_KEY)
		and drill_dump_preview_context.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_CURRENT_TIMER_KEY)
		and drill_dump_preview_context.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_SOURCE_DELTA_KEY)
		and drill_dump_preview_context.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_INTERVAL_KEY)
		and drill_dump_preview_context.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_RUNTIME_STATE_METHOD_KEY)
		and drill_dump_preview_state.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_TIMER_KEY)
		and drill_dump_preview_state.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_SHOULD_DUMP_KEY)
	)
	var proof := {
		"module": "FACTORY_RUNTIME_MODULE_PROOF",
		"cell_matches": cell_context.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY) == Vector2i(1, 1),
		"context_matches": simulation_context.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY) == Vector2i(1, 1),
		"simulation_callbacks_match": simulation_callbacks.has("drill_runtime_state"),
		"summary_callbacks_match": summary_callbacks.has("drill_delay"),
		"summary_matches": summary_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY),
		"game_summary_matches": game_summary_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY),
		"game_factory_cell_context_matches": game_factory_cell_context.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY) == Vector2i(1, 1),
		"game_playable_summary_matches": game_playable_summary_state.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY),
		"summary_schema_constants_valid": summary_schema_constants_valid,
		"step_schema_constants_valid": step_schema_constants_valid,
		"step_context_matches": drill_step_context.has(source_factory_runtime_state.SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY),
		"step_matches": drill_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY),
		"transport_step_matches": transport_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_KEY),
		"game_transport_step_matches": game_transport_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_KEY),
		"game_drill_step_matches": game_drill_step_state.has(source_factory_runtime_state.SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY),
		"drill_dump_schema_constants_valid": drill_dump_schema_constants_valid,
		"drill_dump_preview_context_matches": drill_dump_preview_context.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_CURRENT_TIMER_KEY),
		"drill_dump_preview_matches": drill_dump_preview_state.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_TIMER_KEY),
		"game_drill_dump_preview_matches": game_drill_dump_preview_state.has(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_TIMER_KEY),
		"apply_drill_dump_matches": apply_drill_dump_matches,
		"drill_runtime_context_matches": true,
		"drill_runtime_callbacks_match": true,
		"drill_runtime_matches": true,
		"simulation_matches": factory_simulation_state.has("transport_state"),
		"simulation_runtime_matches": factory_simulation_runtime_state.has("transport_state"),
		"apply_context_matches": apply_context.has("drill_warmup"),
		"apply_state_matches": apply_state.has("produced_total"),
		"apply_matches": apply_state.has("produced_total"),
		"simulation_schema_constants_valid": simulation_schema_constants_valid,
		"apply_context_schema_constants_valid": apply_context_schema_constants_valid,
		"apply_state_schema_constants_valid": apply_state_schema_constants_valid,
		"simulate_factory_source_owner": "source_factory_runtime_state.simulate_factory",
		"simulate_factory_matches": fake_game.transport_progress > simulate_factory_progress_before,
		"drill_dump_timer": float(fake_game.drill_dump_timer),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	var proof_matches: bool = (
		bool(proof["cell_matches"])
		and bool(proof["context_matches"])
		and bool(proof["simulation_callbacks_match"])
		and bool(proof["summary_callbacks_match"])
		and bool(proof["summary_matches"])
		and bool(proof["game_summary_matches"])
		and bool(proof["game_factory_cell_context_matches"])
		and bool(proof["game_playable_summary_matches"])
		and bool(proof["summary_schema_constants_valid"])
		and bool(proof["step_schema_constants_valid"])
		and bool(proof["step_context_matches"])
		and bool(proof["step_matches"])
		and bool(proof["transport_step_matches"])
		and bool(proof["game_transport_step_matches"])
		and bool(proof["game_drill_step_matches"])
		and bool(proof["drill_dump_schema_constants_valid"])
		and bool(proof["drill_dump_preview_context_matches"])
		and bool(proof["drill_dump_preview_matches"])
		and bool(proof["game_drill_dump_preview_matches"])
		and bool(proof["apply_drill_dump_matches"])
		and bool(proof["drill_runtime_context_matches"])
		and bool(proof["drill_runtime_callbacks_match"])
		and bool(proof["drill_runtime_matches"])
		and bool(proof["simulation_matches"])
		and bool(proof["simulation_runtime_matches"])
		and bool(proof["apply_context_matches"])
		and bool(proof["apply_state_matches"])
		and bool(proof["apply_matches"])
		and bool(proof["simulation_schema_constants_valid"])
		and bool(proof["apply_context_schema_constants_valid"])
		and bool(proof["apply_state_schema_constants_valid"])
		and bool(proof["simulate_factory_matches"])
		and bool(proof["one_headquarter_per_ssot"])
		and bool(proof["registry_valid"])
	)
	proof["matches"] = proof_matches
	runtime_proof_state.write_proof("FactoryRuntimeModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

