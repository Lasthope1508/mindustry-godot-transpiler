extends Node

const main_scene := preload("res://scenes/Main.tscn")
const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const mindustry_time := preload("res://src/runtime/Time.gd")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const consume_power_state := preload("res://src/game/SourceConsumePowerState.gd")
const scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _tick(game: Object, count: int) -> void:
	for iteration in range(count):
		game_loop_state.process_tick(game, 1.0 / 60.0, mindustry_time)


func _power_step(game: Object) -> Dictionary:
	return factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)


func _coverage(step: Dictionary) -> float:
	return float(step.get("update", {}).get("battery_distribute_state", {}).get("coverage", -1.0))


func _battery_stored(game: Object) -> float:
	var stored: Dictionary = placed_power_graph_state.source_battery_power_status_for_cell_state(game, scenario_defaults.BATTERY_POS)
	return float(stored.get("status", 0.0)) * 4000.0


func _set_lancer_enabled(game: Object, enabled: bool) -> void:
	var lancer_sprite: Variant = game.call("block_sprite_at_cell", scenario_defaults.LANCER_POS)
	if lancer_sprite == null:
		return
	var lancer_frame: Dictionary = lancer_sprite.get_meta("source_turret_building", {})
	lancer_frame["enabled"] = enabled
	lancer_sprite.set_meta("source_turret_building", lancer_frame)


func _lancer_enabled(game: Object) -> Variant:
	var lancer_sprite: Variant = game.call("block_sprite_at_cell", scenario_defaults.LANCER_POS)
	if lancer_sprite == null:
		return null
	var lancer_frame: Dictionary = lancer_sprite.get_meta("source_turret_building", {})
	return lancer_frame.get("enabled", null)


func _ready() -> void:
	var proof: Dictionary = {}

	# --- the helper is pure: a null game reads the true default, so
	# the graph keeps its static behavior when there is no building
	# to read a frame from.
	var null_helper: Dictionary = placed_power_graph_state.source_consumer_should_consume_for_cell_state(null, scenario_defaults.LANCER_POS)
	proof["should_consume_null_game_default"] = bool(null_helper.get("should_consume", false)) == true and bool(null_helper.get("shouldConsumePower", false)) == true and bool(null_helper.get("found", true)) == false

	# --- ConsumePower.requestedPower (ConsumePower.java:60-63) charges
	# an unbuffered consumer `usage * (entity.shouldConsume() ? 1f
	# : 0f)`: a disabled building requests nothing, an enabled one
	# its full usage.
	proof["requested_power_disabled_zero"] = is_equal_approx(float(consume_power_state.requested_power_state(false, 6.0, 0.0, 0.0, false).get("requested_power", -1.0)), 0.0)
	proof["requested_power_enabled_usage"] = is_equal_approx(float(consume_power_state.requested_power_state(false, 6.0, 0.0, 0.0, true).get("requested_power", -1.0)), 6.0)

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame

	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- the setup frames run the live loop with real deltas, and the
	# wave timer starts at 0 with no enemies, so a wave may already
	# have spawned: clear the board and pin the wave timer far out,
	# so process_tick runs only the factory chain (the pause proof
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
	# measured run: the battery starts empty (the live-loop step
	# writes its status back to the sprite meta every tick, so a
	# charge from the setup frames would leak into the measurement).
	placed_power_graph_state.source_battery_set_power_status_for_cell_state(game, scenario_defaults.BATTERY_POS, 0.0)

	# --- the helper reads each placed building's live frame: the
	# lancer and the drill carry enabled frames, a conduit has no
	# tick frame, and an empty cell has no sprite at all.
	var lancer_helper: Dictionary = placed_power_graph_state.source_consumer_should_consume_for_cell_state(game, scenario_defaults.LANCER_POS)
	proof["helper_lancer_enabled"] = bool(lancer_helper.get("should_consume", false)) == true and bool(lancer_helper.get("shouldConsumePower", false)) == true and bool(lancer_helper.get("found", false)) == true
	var drill_helper: Dictionary = placed_power_graph_state.source_consumer_should_consume_for_cell_state(game, scenario_defaults.DRILL_POS)
	proof["helper_drill_enabled"] = bool(drill_helper.get("should_consume", false)) == true and bool(drill_helper.get("shouldConsumePower", false)) == true and bool(drill_helper.get("found", false)) == true
	var conduit_helper: Dictionary = placed_power_graph_state.source_consumer_should_consume_for_cell_state(game, scenario_defaults.conduit_cells()[0])
	proof["helper_conduit_no_frame"] = bool(conduit_helper.get("should_consume", false)) == true and bool(conduit_helper.get("shouldConsumePower", false)) == true and bool(conduit_helper.get("found", true)) == false
	var empty_helper: Dictionary = placed_power_graph_state.source_consumer_should_consume_for_cell_state(game, Vector2i(99, 99))
	proof["helper_empty_no_sprite"] = bool(empty_helper.get("should_consume", false)) == true and bool(empty_helper.get("shouldConsumePower", false)) == true and bool(empty_helper.get("found", true)) == false

	# --- BASELINE: the lancer is enabled, so the graph needs the
	# full 6.0/60 from it, produces 0.12/60, and sits at coverage
	# 0.02 with an empty battery (the session proof's S0 numbers).
	var baseline: Dictionary = _power_step(game)
	proof["baseline_needed"] = is_equal_approx(float(baseline.get("power_needed", -1.0)), 6.0 / 60.0)
	proof["baseline_produced"] = is_equal_approx(float(baseline.get("power_produced", -1.0)), 0.12 / 60.0)
	proof["baseline_coverage"] = is_equal_approx(_coverage(baseline), 0.02)
	proof["baseline_battery_empty"] = is_equal_approx(_battery_stored(game), 0.0)

	# --- DISABLED: the lancer frame is disabled, so
	# ConsumePower.requestedPower reads shouldConsume() false and the
	# graph needs nothing — the only consumer with usage left is
	# gone, coverage goes to 1.0 (PowerGraph.java:190, needed zero),
	# and the solar surplus starts charging the battery.
	_set_lancer_enabled(game, false)
	var disabled: Dictionary = _power_step(game)
	proof["disabled_needed_zero"] = is_equal_approx(float(disabled.get("power_needed", -1.0)), 0.0)
	proof["disabled_produced"] = is_equal_approx(float(disabled.get("power_produced", -1.0)), 0.12 / 60.0)
	proof["disabled_coverage_one"] = is_equal_approx(_coverage(disabled), 1.0)

	# --- 60 live ticks (1s) through the real per-frame entry point:
	# the turret tick preserves the disabled frame (N2125's
	# frame["enabled"] preservation), so the graph still needs
	# nothing — the disable survives the live loop.
	_tick(game, 60)
	proof["disabled_frame_preserved"] = _lancer_enabled(game) == false
	var still_disabled: Dictionary = _power_step(game)
	proof["disabled_needed_stays_zero"] = is_equal_approx(float(still_disabled.get("power_needed", -1.0)), 0.0)

	# --- 600 more live ticks (10s): the solar surplus (0.002/tick
	# over a 0.0 need) charges the battery, so its stored charge
	# grows from 0.0 while coverage stays 1.0.
	_tick(game, 600)
	proof["disabled_battery_charges"] = _battery_stored(game) > 0.0
	var charged: Dictionary = _power_step(game)
	proof["disabled_coverage_stays_one"] = is_equal_approx(_coverage(charged), 1.0)

	# --- RE-ENABLED: the lancer frame is enabled again, so the
	# graph needs the full 6.0/60 — and the charge banked while it
	# was disabled now covers the deficit (PowerGraph.update's
	# deficit branch, the N2082/N2083 discharge path), so coverage
	# reads 1.0 on the first step back. Over live ticks the battery
	# then drains back down.
	_set_lancer_enabled(game, true)
	var reenabled: Dictionary = _power_step(game)
	proof["reenabled_needed_restored"] = is_equal_approx(float(reenabled.get("power_needed", -1.0)), 6.0 / 60.0)
	proof["reenabled_coverage_battery_covers"] = is_equal_approx(_coverage(reenabled), 1.0)
	var stored_charged: float = _battery_stored(game)
	_tick(game, 60)
	proof["reenabled_battery_discharges"] = _battery_stored(game) < stored_charged

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06PowerShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
