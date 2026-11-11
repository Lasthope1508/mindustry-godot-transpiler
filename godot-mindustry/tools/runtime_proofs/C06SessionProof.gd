extends Node

const main_scene := preload("res://scenes/Main.tscn")
const snapshot_state := preload("res://src/game/SourceSessionSnapshotState.gd")
const placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- the snapshot reads all zeros for a null game (a game that
	# has not entered the playable slice yet has no placed buildings,
	# no core inventory and no power graph). ---
	var null_snapshot: Dictionary = snapshot_state.source_session_snapshot_state(null)
	proof["session_snapshot_null_game_zeros"] = int(null_snapshot.get("core_copper", -1)) == 0 and is_equal_approx(float(null_snapshot.get("core_health", -1.0)), 0.0) and is_equal_approx(float(null_snapshot.get("battery_stored", -1.0)), 0.0) and is_equal_approx(float(null_snapshot.get("battery_capacity", -1.0)), 0.0) and is_equal_approx(float(null_snapshot.get("power_needed", -1.0)), 0.0) and is_equal_approx(float(null_snapshot.get("power_produced", -1.0)), 0.0) and is_equal_approx(float(null_snapshot.get("power_coverage", -1.0)), 0.0) and is_equal_approx(float(null_snapshot.get("drill_time_drilled", -1.0)), 0.0) and is_equal_approx(float(null_snapshot.get("drill_produced_total", -1)), 0.0) and is_equal_approx(float(null_snapshot.get("conduit_water", -1.0)), 0.0)

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame

	# --- before the slice is entered the bootstrap world is
	# already placed (the Main scene builds it) and the setup
	# frames have run the live loop with real deltas, so the
	# tick-dependent fields are already moving — but nothing has
	# been produced or delivered yet, and the placed power graph
	# already reads the deficit balance. ---
	var pre_slice: Dictionary = snapshot_state.source_session_snapshot_state(game)
	proof["session_snapshot_pre_slice_placed"] = int(pre_slice.get("core_copper", -1)) == 0 and int(pre_slice.get("drill_produced_total", -1)) == 0 and is_equal_approx(float(pre_slice.get("battery_stored", -1.0)), 0.0) and is_equal_approx(float(pre_slice.get("core_health", -1.0)), 1100.0) and is_equal_approx(float(pre_slice.get("battery_capacity", -1.0)), 4000.0) and is_equal_approx(float(pre_slice.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(pre_slice.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(pre_slice.get("power_coverage", -1.0)), 0.02) and float(pre_slice.get("drill_time_drilled", -1.0)) >= 0.0 and float(pre_slice.get("drill_warmup", -1.0)) >= 0.0 and float(pre_slice.get("drill_warmup", 99.0)) <= 1.6 and float(pre_slice.get("pump_warmup", -1.0)) >= 0.0 and float(pre_slice.get("pump_warmup", 99.0)) <= 1.0 and float(pre_slice.get("conduit_water", -1.0)) >= 0.0

	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- reset the measured state to known values before the
	# measured run (the live-loop wall-clock trap: the setup frames
	# run the live loop with real deltas, so the frames already hold
	# unknown amounts). The reset follows the same pattern the
	# N2119 proof uses: drain the networks, zero the counters, and
	# set the drill's legacy per-cell stores (the tick reads them;
	# the frame mirrors them). ---
	var drill_cell: Vector2i = scenario_defaults.DRILL_POS
	var pump_cell: Vector2i = scenario_defaults.PUMP_POS
	game.call("set_core_item_count", "copper", 0)
	game.call("set_drill_warmup_at_cell", drill_cell.x, drill_cell.y, 1.0)
	game.call("set_drill_time_drilled_at_cell", drill_cell.x, drill_cell.y, 0.0)
	game.call("set_drill_last_speed_at_cell", drill_cell.x, drill_cell.y, 0.0)
	game.set("item_progress", 0.0)
	game.set("drill_items", {})
	game.set("drill_dump_timer", 0.0)
	game.set("produced_total", 0)
	var pump_sprite: Variant = game.call("block_sprite_at_cell", pump_cell)
	if pump_sprite != null:
		var pump_frame: Dictionary = pump_sprite.get_meta("source_pump_building", {})
		pump_frame["warmup"] = 0.0
		pump_frame["total_progress"] = 0.0
		pump_sprite.set_meta("source_pump_building", pump_frame)
		var pump_liquids: Variant = pump_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
		if pump_liquids != null:
			liquid_module_state.source_clear_state(pump_liquids)
	var drill_sprite: Variant = game.call("block_sprite_at_cell", drill_cell)
	if drill_sprite != null:
		var drill_liquids: Variant = drill_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
		if drill_liquids != null:
			liquid_module_state.source_clear_state(drill_liquids)
	for conduit_cell in scenario_defaults.conduit_cells():
		var conduit_sprite: Variant = game.call("block_sprite_at_cell", conduit_cell)
		if conduit_sprite == null:
			continue
		conduit_sprite.set_meta("source_conduit_building", {"smooth_liquid": 0.0, "flow_timer": 0.0})
		var conduit_liquids: Variant = conduit_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
		if conduit_liquids != null:
			liquid_module_state.source_clear_state(conduit_liquids)
	for conveyor_cell in scenario_defaults.conveyor_cells():
		conveyor_runtime_state.source_conveyor_set_queue_for_cell_state(game, conveyor_cell, {"ids": [], "xs": [], "ys": [], "len": 0})
	placed_power_graph_state.source_battery_set_power_status_for_cell_state(game, scenario_defaults.BATTERY_POS, 0.0)

	# --- S0: the reset state. The bootstrap world is a deficit
	# world (the lancer needs 6.0/60 per tick, the solar panel
	# produces 0.12/60), so coverage is 0.02 and the battery never
	# charges; the drill is fully warmed up and has produced
	# nothing yet. ---
	var s0: Dictionary = snapshot_state.source_session_snapshot_state(game)
	proof["session_s0_core_empty"] = int(s0.get("core_copper", -1)) == 0
	proof["session_s0_core_health"] = is_equal_approx(float(s0.get("core_health", -1.0)), 1100.0)
	proof["session_s0_battery_empty"] = is_equal_approx(float(s0.get("battery_stored", -1.0)), 0.0)
	proof["session_s0_battery_capacity"] = is_equal_approx(float(s0.get("battery_capacity", -1.0)), 4000.0)
	proof["session_s0_power_needed"] = is_equal_approx(float(s0.get("power_needed", -1.0)), 6.0 / 60.0)
	proof["session_s0_power_produced"] = is_equal_approx(float(s0.get("power_produced", -1.0)), 0.12 / 60.0)
	proof["session_s0_power_coverage"] = is_equal_approx(float(s0.get("power_coverage", -1.0)), 0.02)
	proof["session_s0_drill_reset"] = is_equal_approx(float(s0.get("drill_time_drilled", -1.0)), 0.0) and is_equal_approx(float(s0.get("drill_warmup", -1.0)), 1.0) and is_equal_approx(float(s0.get("drill_last_speed", -1.0)), 0.0) and int(s0.get("drill_produced_total", -1)) == 0
	proof["session_s0_liquids_dry"] = is_equal_approx(float(s0.get("drill_water", -1.0)), 0.0) and is_equal_approx(float(s0.get("pump_water", -1.0)), 0.0) and is_equal_approx(float(s0.get("conduit_water", -1.0)), 0.0)
	proof["session_s0_pump_reset"] = is_equal_approx(float(s0.get("pump_warmup", -1.0)), 0.0) and is_equal_approx(float(s0.get("pump_total_progress", -1.0)), 0.0)

	# --- S1: 300 controlled ticks (5s). The water crossed the
	# conduit line on the first simultaneous flow-timer firing
	# (~tick 60) and reached the drill, so the booster is already
	# engaged: speed 1.0 -> 1.6, warmup follows to 1.6, and
	# lastDrillSpeed is the boosted 1.6 * 2 * 1.6 / 650 (delay =
	# getDrillTime(copper) = (600 + 50 * 1) / 1, Drill.java:170).
	# The drill has produced twice by now, and the first copper is
	# still on the belts (it reaches the core ~tick 398). ---
	for iteration in range(300):
		game.call("simulate_factory", 1.0 / 60.0)
	var s1: Dictionary = snapshot_state.source_session_snapshot_state(game)
	proof["session_s1_core_empty"] = int(s1.get("core_copper", -1)) == 0
	proof["session_s1_drill_time"] = is_equal_approx(float(s1.get("drill_time_drilled", -1.0)), 431.7)
	proof["session_s1_drill_warmup"] = is_equal_approx(float(s1.get("drill_warmup", -1.0)), 1.6)
	proof["session_s1_drill_produced"] = int(s1.get("drill_produced_total", -1)) == 2
	proof["session_s1_drill_speed_boosted"] = is_equal_approx(float(s1.get("drill_last_speed", -1.0)), 5.12 / 650.0)
	proof["session_s1_drill_water"] = is_equal_approx(float(s1.get("drill_water", -1.0)), 8.40547839506171)
	proof["session_s1_pump_warm"] = is_equal_approx(float(s1.get("pump_warmup", -1.0)), 1.0)
	proof["session_s1_pump_progress"] = is_equal_approx(float(s1.get("pump_total_progress", -1.0)), 274.182)
	proof["session_s1_pump_water"] = is_equal_approx(float(s1.get("pump_water", -1.0)), 6.78124999999998)
	proof["session_s1_conduit_wet"] = is_equal_approx(float(s1.get("conduit_water", -1.0)), 7.81327160493828)
	proof["session_s1_power_steady"] = is_equal_approx(float(s1.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(s1.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(s1.get("power_coverage", -1.0)), 0.02) and is_equal_approx(float(s1.get("battery_stored", -1.0)), 0.0)
	proof["session_s1_core_health"] = is_equal_approx(float(s1.get("core_health", -1.0)), 1100.0)

	# --- S2: 600 more controlled ticks (15s total). The belts run
	# at the Java rate now (0.03/tick), so the copper the drill
	# produced has crossed the seven belts and reached the core;
	# the drill stays boosted (water held, warmup 1.6). ---
	for iteration in range(600):
		game.call("simulate_factory", 1.0 / 60.0)
	var s2: Dictionary = snapshot_state.source_session_snapshot_state(game)
	proof["session_s2_core_copper"] = int(s2.get("core_copper", -1)) == 4
	proof["session_s2_core_copper_grew"] = int(s2.get("core_copper", -1)) > int(s1.get("core_copper", -1))
	proof["session_s2_drill_time_grew"] = is_equal_approx(float(s2.get("drill_time_drilled", -1.0)), 1391.7)
	proof["session_s2_drill_warm"] = is_equal_approx(float(s2.get("drill_warmup", -1.0)), 1.6)
	proof["session_s2_drill_water"] = is_equal_approx(float(s2.get("drill_water", -1.0)), 14.2574870338026)
	proof["session_s2_drill_speed_boosted"] = is_equal_approx(float(s2.get("drill_last_speed", -1.0)), 5.12 / 650.0)
	proof["session_s2_drill_produced_grew"] = int(s2.get("drill_produced_total", -1)) == 6
	proof["session_s2_pump_progress_grew"] = is_equal_approx(float(s2.get("pump_total_progress", -1.0)), 874.182)
	proof["session_s2_pump_warm"] = is_equal_approx(float(s2.get("pump_warmup", -1.0)), 1.0)
	proof["session_s2_pump_water"] = is_equal_approx(float(s2.get("pump_water", -1.0)), 10.6592764032448)
	proof["session_s2_conduit_wet"] = is_equal_approx(float(s2.get("conduit_water", -1.0)), 38.0832365629523)
	proof["session_s2_power_steady"] = is_equal_approx(float(s2.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(s2.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(s2.get("power_coverage", -1.0)), 0.02) and is_equal_approx(float(s2.get("battery_stored", -1.0)), 0.0)
	proof["session_s2_core_health"] = is_equal_approx(float(s2.get("core_health", -1.0)), 1100.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06SessionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
