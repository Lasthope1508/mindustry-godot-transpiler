extends Node

const main_scene := preload("res://scenes/Main.tscn")
const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const mindustry_time := preload("res://src/runtime/Time.gd")
const snapshot_state := preload("res://src/game/SourceSessionSnapshotState.gd")
const placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _tick(game: Object, count: int) -> void:
	for iteration in range(count):
		game_loop_state.process_tick(game, 1.0 / 60.0, mindustry_time)


func _ready() -> void:
	var proof: Dictionary = {}

	# --- the pause read is pure: a null game has no pause state, so
	# it reads unpaused (GameState.isPaused is `state == State.paused`,
	# GameState.java:93-95; there is no state to read before the game
	# exists).
	var null_paused: Dictionary = game_loop_state.source_game_loop_paused_state(null)
	proof["pause_null_game_unpaused"] = bool(null_paused.get("paused", true)) == false

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame

	# --- the pause flag defaults to false: a fresh game is playing.
	proof["pause_default_unpaused"] = bool(game_loop_state.source_game_loop_paused_state(game).get("paused", true)) == false
	game.set("paused", true)
	proof["pause_flag_reads_true"] = bool(game_loop_state.source_game_loop_paused_state(game).get("paused", false)) == true
	game.set("paused", false)

	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- the setup frames run the live loop with real deltas, and the
	# wave timer starts at 0 with no enemies, so a wave may already
	# have spawned: clear the board and pin the wave timer far out,
	# so process_tick runs only the factory chain (the defense proof
	# uses the same pin).
	game.set("wave_cooldown", 100000.0)
	for enemy in game.get("enemy_units"):
		var enemy_dict: Dictionary = enemy
		var sprite = enemy_dict.get("sprite", null)
		if is_instance_valid(sprite):
			sprite.queue_free()
	game.set("enemy_units", [])
	game.set("bullet_hit_count", 0)

	# --- reset the measured state to known values before the
	# measured run (the same reset the session proof uses: the setup
	# frames run the live loop with real deltas, so the frames already
	# hold unknown amounts).
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

	# --- S0: the reset state (the session proof's S0: core empty,
	# battery empty at capacity 4000, power needed 0.1 / produced
	# 0.002 / coverage 0.02, drill reset, liquids dry).
	var s0: Dictionary = snapshot_state.source_session_snapshot_state(game)
	proof["pause_s0_core_empty"] = int(s0.get("core_copper", -1)) == 0
	proof["pause_s0_core_health"] = is_equal_approx(float(s0.get("core_health", -1.0)), 1100.0)
	proof["pause_s0_battery_empty"] = is_equal_approx(float(s0.get("battery_stored", -1.0)), 0.0)
	proof["pause_s0_battery_capacity"] = is_equal_approx(float(s0.get("battery_capacity", -1.0)), 4000.0)
	proof["pause_s0_power_steady"] = is_equal_approx(float(s0.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(s0.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(s0.get("power_coverage", -1.0)), 0.02)
	proof["pause_s0_drill_reset"] = is_equal_approx(float(s0.get("drill_time_drilled", -1.0)), 0.0) and is_equal_approx(float(s0.get("drill_warmup", -1.0)), 1.0) and int(s0.get("drill_produced_total", -1)) == 0
	proof["pause_s0_liquids_dry"] = is_equal_approx(float(s0.get("drill_water", -1.0)), 0.0) and is_equal_approx(float(s0.get("pump_water", -1.0)), 0.0) and is_equal_approx(float(s0.get("conduit_water", -1.0)), 0.0)
	proof["pause_s0_pump_reset"] = is_equal_approx(float(s0.get("pump_warmup", -1.0)), 0.0) and is_equal_approx(float(s0.get("pump_total_progress", -1.0)), 0.0)

	# --- PAUSED: 300 process_tick calls while paused. Logic.update
	# (Logic.java:507) gates the whole game update on
	# !state.isPaused(), so nothing advances: no drill time, no pump
	# warmup, no water, no core deliveries — and Time.update never
	# runs, so MindustryTime.time is frozen too.
	game.set("paused", true)
	var time_before_pause: float = mindustry_time.time
	_tick(game, 300)
	var frozen: Dictionary = snapshot_state.source_session_snapshot_state(game)
	proof["pause_frozen_drill"] = is_equal_approx(float(frozen.get("drill_time_drilled", -1.0)), 0.0) and is_equal_approx(float(frozen.get("drill_warmup", -1.0)), 1.0) and int(frozen.get("drill_produced_total", -1)) == 0
	proof["pause_frozen_core"] = int(frozen.get("core_copper", -1)) == 0 and is_equal_approx(float(frozen.get("core_health", -1.0)), 1100.0)
	proof["pause_frozen_pump"] = is_equal_approx(float(frozen.get("pump_warmup", -1.0)), 0.0) and is_equal_approx(float(frozen.get("pump_total_progress", -1.0)), 0.0)
	proof["pause_frozen_liquids"] = is_equal_approx(float(frozen.get("drill_water", -1.0)), 0.0) and is_equal_approx(float(frozen.get("pump_water", -1.0)), 0.0) and is_equal_approx(float(frozen.get("conduit_water", -1.0)), 0.0)
	proof["pause_frozen_power"] = is_equal_approx(float(frozen.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(frozen.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(frozen.get("battery_stored", -1.0)), 0.0)
	proof["pause_frozen_time"] = is_equal_approx(mindustry_time.time, time_before_pause)

	# --- UNPAUSED: 300 ticks (5s). The session proof's S1 numbers
	# hold through the real per-frame entry point: the drill is
	# boosted (speed 5.12/650, warmup 1.6), has produced twice, and
	# the first copper is still on the belts.
	game.set("paused", false)
	_tick(game, 300)
	var s1: Dictionary = snapshot_state.source_session_snapshot_state(game)
	proof["pause_s1_core_empty"] = int(s1.get("core_copper", -1)) == 0
	proof["pause_s1_drill_time"] = is_equal_approx(float(s1.get("drill_time_drilled", -1.0)), 431.7)
	proof["pause_s1_drill_warmup"] = is_equal_approx(float(s1.get("drill_warmup", -1.0)), 1.6)
	proof["pause_s1_drill_produced"] = int(s1.get("drill_produced_total", -1)) == 2
	proof["pause_s1_drill_speed_boosted"] = is_equal_approx(float(s1.get("drill_last_speed", -1.0)), 5.12 / 650.0)
	proof["pause_s1_drill_water"] = is_equal_approx(float(s1.get("drill_water", -1.0)), 8.40547839506171)
	proof["pause_s1_pump_warm"] = is_equal_approx(float(s1.get("pump_warmup", -1.0)), 1.0)
	proof["pause_s1_pump_progress"] = is_equal_approx(float(s1.get("pump_total_progress", -1.0)), 274.182)
	proof["pause_s1_pump_water"] = is_equal_approx(float(s1.get("pump_water", -1.0)), 6.78124999999998)
	proof["pause_s1_conduit_wet"] = is_equal_approx(float(s1.get("conduit_water", -1.0)), 7.81327160493828)
	proof["pause_s1_power_steady"] = is_equal_approx(float(s1.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(s1.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(s1.get("power_coverage", -1.0)), 0.02) and is_equal_approx(float(s1.get("battery_stored", -1.0)), 0.0)
	proof["pause_s1_core_health"] = is_equal_approx(float(s1.get("core_health", -1.0)), 1100.0)
	proof["pause_s1_time_advanced"] = mindustry_time.time > time_before_pause

	# --- PAUSED AGAIN: 300 more ticks mid-run. The snapshot must be
	# identical to S1 on every measured field, and time frozen again.
	game.set("paused", true)
	var time_before_second_pause: float = mindustry_time.time
	_tick(game, 300)
	var frozen2: Dictionary = snapshot_state.source_session_snapshot_state(game)
	proof["pause_refrozen_drill"] = is_equal_approx(float(frozen2.get("drill_time_drilled", -1.0)), float(s1.get("drill_time_drilled", -1.0))) and is_equal_approx(float(frozen2.get("drill_warmup", -1.0)), float(s1.get("drill_warmup", -1.0))) and int(frozen2.get("drill_produced_total", -1)) == int(s1.get("drill_produced_total", -1))
	proof["pause_refrozen_liquids"] = is_equal_approx(float(frozen2.get("drill_water", -1.0)), float(s1.get("drill_water", -1.0))) and is_equal_approx(float(frozen2.get("pump_water", -1.0)), float(s1.get("pump_water", -1.0))) and is_equal_approx(float(frozen2.get("conduit_water", -1.0)), float(s1.get("conduit_water", -1.0)))
	proof["pause_refrozen_pump"] = is_equal_approx(float(frozen2.get("pump_total_progress", -1.0)), float(s1.get("pump_total_progress", -1.0)))
	proof["pause_refrozen_core"] = int(frozen2.get("core_copper", -1)) == int(s1.get("core_copper", -1))
	proof["pause_refrozen_time"] = is_equal_approx(mindustry_time.time, time_before_second_pause)

	# --- UNPAUSED AGAIN: 600 more ticks (15s total). The session
	# proof's S2 numbers hold: the core receives 4 copper and the
	# drill has produced 6.
	game.set("paused", false)
	_tick(game, 600)
	var s2: Dictionary = snapshot_state.source_session_snapshot_state(game)
	proof["pause_s2_core_copper"] = int(s2.get("core_copper", -1)) == 4
	proof["pause_s2_core_copper_grew"] = int(s2.get("core_copper", -1)) > int(s1.get("core_copper", -1))
	proof["pause_s2_drill_time_grew"] = is_equal_approx(float(s2.get("drill_time_drilled", -1.0)), 1391.7)
	proof["pause_s2_drill_warm"] = is_equal_approx(float(s2.get("drill_warmup", -1.0)), 1.6)
	proof["pause_s2_drill_water"] = is_equal_approx(float(s2.get("drill_water", -1.0)), 14.2574870338026)
	proof["pause_s2_drill_speed_boosted"] = is_equal_approx(float(s2.get("drill_last_speed", -1.0)), 5.12 / 650.0)
	proof["pause_s2_drill_produced_grew"] = int(s2.get("drill_produced_total", -1)) == 6
	proof["pause_s2_pump_progress_grew"] = is_equal_approx(float(s2.get("pump_total_progress", -1.0)), 874.182)
	proof["pause_s2_pump_warm"] = is_equal_approx(float(s2.get("pump_warmup", -1.0)), 1.0)
	proof["pause_s2_pump_water"] = is_equal_approx(float(s2.get("pump_water", -1.0)), 10.6592764032448)
	proof["pause_s2_conduit_wet"] = is_equal_approx(float(s2.get("conduit_water", -1.0)), 38.0832365629523)
	proof["pause_s2_power_steady"] = is_equal_approx(float(s2.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(s2.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(s2.get("power_coverage", -1.0)), 0.02) and is_equal_approx(float(s2.get("battery_stored", -1.0)), 0.0)
	proof["pause_s2_core_health"] = is_equal_approx(float(s2.get("core_health", -1.0)), 1100.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06PauseProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
