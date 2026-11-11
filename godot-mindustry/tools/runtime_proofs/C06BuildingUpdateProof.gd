extends Node

const main_scene := preload("res://scenes/Main.tscn")
const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const mindustry_time := preload("res://src/runtime/Time.gd")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const conveyor_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const conduit_state := preload("res://src/game/SourceConduitRuntimeState.gd")
const pump_state := preload("res://src/game/SourcePumpRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const building_time_state := preload("res://src/game/SourceBuildingTimeState.gd")
const building_lifecycle_state := preload("res://src/game/SourceBuildingLifecycleState.gd")
const block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _tick(game: Object, count: int) -> void:
	for iteration in range(count):
		game_loop_state.process_tick(game, 1.0 / 60.0, mindustry_time)


func _conduit_frame(game: Object, cell: Vector2i) -> Dictionary:
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {}
	return sprite.get_meta("source_conduit_building", {})


func _set_conduit_enabled(game: Object, cell: Vector2i, enabled: bool) -> void:
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return
	var frame: Dictionary = sprite.get_meta("source_conduit_building", {})
	frame["enabled"] = enabled
	sprite.set_meta("source_conduit_building", frame)


func _conduit_water(game: Object, cell: Vector2i, water_id: int) -> float:
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return -1.0
	var liquids: Dictionary = sprite.get_meta("source_building_liquids", {})
	return float(liquid_module_state.source_get_state(liquids, water_id).get("amount", 0.0))


func _ready() -> void:
	var proof: Dictionary = {}

	# --- the belt advance moves items by speed * edelta()
	# (Conveyor.java:266), and edelta() is efficiency * Time.delta *
	# timeScale (BuildingComp.java:1922-1929): a belt at time scale 2
	# moves twice as far per tick as one at time scale 1.
	var boosted: Dictionary = conveyor_state.source_conveyor_advance_state(["lead", "copper"], [0.2, -0.3], [0.0, 0.5], 2, 0.03, 1.0, 2.0, false, 1.0, 0, 0.0)
	proof["advance_time_scale_two"] = is_equal_approx(float(boosted.get("ys_after")[0]), 0.06) and is_equal_approx(float(boosted.get("ys_after")[1]), 0.56) and is_equal_approx(float(boosted.get("xs_after")[0]), 0.08) and is_equal_approx(float(boosted.get("xs_after")[1]), -0.18) and boosted.get("mid") == 0 and is_equal_approx(float(boosted.get("minitem")), 0.06) and boosted.get("pass_ready") == false and boosted.get("no_sleep_called") == true and is_equal_approx(float(boosted.get("clog_heat")), 1.0 / 60.0) and boosted.get("reason") == "advanced"
	var plain: Dictionary = conveyor_state.source_conveyor_advance_state(["lead", "copper"], [0.2, -0.3], [0.0, 0.5], 2, 0.03, 1.0, 1.0, false, 1.0, 0, 0.0)
	proof["advance_time_scale_one"] = plain.get("ys_after") == [0.03, 0.53] and is_equal_approx(float(plain.get("xs_after")[0]), 0.14) and is_equal_approx(float(plain.get("xs_after")[1]), -0.24) and plain.get("mid") == 0 and is_equal_approx(float(plain.get("minitem")), 0.03) and plain.get("pass_ready") == false and plain.get("no_sleep_called") == true and is_equal_approx(float(plain.get("clog_heat")), 1.0 / 60.0) and plain.get("reason") == "advanced"

	# --- the updateTile gate (BuildingComp.java:2276): updateTile
	# runs when `enabled || !block.noUpdateDisabled`. A conduit sets
	# noUpdateDisabled, so a disabled conduit does not update; a
	# GenericCrafter leaves it false, so a disabled crafter still
	# runs its updateTile half (only its zero efficiency stops it).
	proof["gate_disabled_conduit"] = building_lifecycle_state.update_tile_gate_state(false, true).get("update_tile_called") == false
	proof["gate_enabled_conduit"] = building_lifecycle_state.update_tile_gate_state(true, true).get("update_tile_called") == true
	proof["gate_disabled_crafter_vacuous"] = building_lifecycle_state.update_tile_gate_state(false, false).get("update_tile_called") == true
	proof["gate_enabled_crafter"] = building_lifecycle_state.update_tile_gate_state(true, false).get("update_tile_called") == true

	# --- the timeScale expiry (BuildingComp.java:2265-2267): the
	# duration decays by Time.delta, and when it reaches zero the
	# time scale resets to 1f.
	proof["decay_expiry"] = is_equal_approx(float(building_time_state.time_scale_decay_state(2.0, 1.0, 1.0, 1.0).get("time_scale", -1.0)), 1.0) and is_equal_approx(float(building_time_state.time_scale_decay_state(2.0, 1.0, 1.0, 1.0).get("time_scale_duration", -1.0)), 0.0)
	proof["decay_keeps_boost"] = is_equal_approx(float(building_time_state.time_scale_decay_state(2.0, 600.0, 1.0, 1.0).get("time_scale", -1.0)), 2.0) and is_equal_approx(float(building_time_state.time_scale_decay_state(2.0, 600.0, 1.0, 1.0).get("time_scale_duration", -1.0)), 599.0)
	proof["apply_boost_conveyor"] = is_equal_approx(float(building_time_state.apply_boost_state(1.0, 0.0, 2.0, 600.0, true, block_defaults.TIME_SCALE_BOOST_EPSILON).get("time_scale", -1.0)), 2.0) and is_equal_approx(float(building_time_state.apply_boost_state(1.0, 0.0, 2.0, 600.0, true, block_defaults.TIME_SCALE_BOOST_EPSILON).get("time_scale_duration", -1.0)), 600.0) and building_time_state.apply_boost_state(1.0, 0.0, 2.0, 600.0, true, block_defaults.TIME_SCALE_BOOST_EPSILON).get("applied", false) == true

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

	var line: Array = []
	for x in range(15, 8, -1):
		line.append(Vector2i(x, 8))

	# --- BOOSTED BELT: the (9, 8) belt is boosted to time scale 2.0
	# for 600 ticks (applyBoost, BuildingComp.java:461-469), so the
	# live-loop wrapper advances its item twice as far per tick.
	var belt_cell := Vector2i(9, 8)
	var belt_sprite: Variant = game.call("block_sprite_at_cell", belt_cell)
	var boost: Dictionary = building_time_state.apply_boost_state(1.0, 0.0, 2.0, 600.0, true, block_defaults.TIME_SCALE_BOOST_EPSILON)
	belt_sprite.set_meta(placed_block_state.SOURCE_BLOCK_TIME_SCALE_META_KEY, float(boost.get("time_scale", 1.0)))
	belt_sprite.set_meta(placed_block_state.SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY, float(boost.get("time_scale_duration", 0.0)))
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(10, 8), {"ids": [], "xs": [], "ys": [], "len": 0})
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, belt_cell, {"ids": ["lead"], "xs": [0.2], "ys": [0.0], "len": 1})
	factory_state.source_factory_advance_conveyors_state(game, line, 1.0)
	var belt_after: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, belt_cell)
	proof["belt_boosted_advance"] = is_equal_approx(float(placed_block_state.time_scale(belt_sprite, 1.0)), 2.0) and is_equal_approx(float(belt_after.get("ys")[0]), 0.06) and is_equal_approx(float(belt_after.get("xs")[0]), 0.08) and belt_after.get("len") == 1

	# --- EXPIRY: one tick of decay left on the duration, so the
	# per-tick decay (simulate_block_time_scales, BuildingComp
	# .java:2265-2267) resets the belt to time scale 1.0, and the
	# next advance moves at the normal speed again.
	belt_sprite.set_meta(placed_block_state.SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY, 1.0)
	game.call("simulate_block_time_scales", 1.0 / 60.0)
	proof["belt_time_scale_expires"] = is_equal_approx(float(placed_block_state.time_scale(belt_sprite, 1.0)), 1.0)
	factory_state.source_factory_advance_conveyors_state(game, line, 1.0)
	var belt_expired: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, belt_cell)
	proof["belt_expired_advance_normal"] = is_equal_approx(float(belt_expired.get("ys")[0]), 0.09) and belt_expired.get("len") == 1

	# --- CONDUIT GATE, direct: one second of pumping fills the pump
	# and dumps half to (5, 13) (the ConduitUpdateProof setup), so
	# the first conduit holds water and the second holds what the
	# setup frames left it.
	var catalog: Dictionary = content_registry_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(catalog["liquid_id_by_name"].get("water", -1))
	pump_state.source_pump_update_state(game, Vector2i(5, 14), 1.0)
	pump_state.source_pump_dump_liquid_state(game, Vector2i(5, 14))
	var first_before: float = _conduit_water(game, Vector2i(5, 13), water_id)
	var second_before: float = _conduit_water(game, Vector2i(5, 12), water_id)
	# The setup frames already ran the conduit tick, so the frame
	# carries nonzero smoothLiquid/flowTimer: the gate must leave
	# both exactly as they were, not reset them.
	var smooth_before: float = float(_conduit_frame(game, Vector2i(5, 13)).get("smooth_liquid", 0.0))
	var timer_before: float = float(_conduit_frame(game, Vector2i(5, 13)).get("flow_timer", 0.0))
	_set_conduit_enabled(game, Vector2i(5, 13), false)
	var gated: Dictionary = conduit_state.source_conduit_update_state(game, Vector2i(5, 13), 1.0)
	proof["conduit_disabled_no_flow"] = is_equal_approx(float(gated.get("flowed", -1.0)), 0.0) and is_equal_approx(_conduit_water(game, Vector2i(5, 13), water_id), first_before) and is_equal_approx(_conduit_water(game, Vector2i(5, 12), water_id), second_before) and gated.get("update_tile_called") == false and is_equal_approx(float(gated.get("flow_timer", -1.0)), timer_before) and is_equal_approx(float(gated.get("smooth_liquid", -1.0)), smooth_before) and _conduit_frame(game, Vector2i(5, 13)).get("enabled", null) == false
	_set_conduit_enabled(game, Vector2i(5, 13), true)
	var flowed: Dictionary = conduit_state.source_conduit_update_state(game, Vector2i(5, 13), 1.0)
	proof["conduit_reenabled_flows"] = is_equal_approx(float(flowed.get("flowed", -1.0)), first_before - second_before) and is_equal_approx(_conduit_water(game, Vector2i(5, 13), water_id), second_before) and is_equal_approx(_conduit_water(game, Vector2i(5, 12), water_id), first_before) and flowed.get("update_tile_called") == true and float(flowed.get("flow_timer", -1.0)) < 1.0

	# --- CONDUIT GATE, live loop: with (5, 13) disabled for 120
	# ticks the pump keeps dumping into it while nothing flows out,
	# so it accumulates, and (5, 12) drains with no inflow; the
	# disable survives the live loop because the conduit tick writes
	# its frame back. Re-enabled, (5, 13) forwards again and drains.
	_set_conduit_enabled(game, Vector2i(5, 13), false)
	var disabled_before: float = _conduit_water(game, Vector2i(5, 13), water_id)
	var downstream_before: float = _conduit_water(game, Vector2i(5, 12), water_id)
	_tick(game, 120)
	proof["live_disabled_frame_preserved"] = _conduit_frame(game, Vector2i(5, 13)).get("enabled", null) == false
	var disabled_after: float = _conduit_water(game, Vector2i(5, 13), water_id)
	var downstream_after: float = _conduit_water(game, Vector2i(5, 12), water_id)
	proof["live_disabled_conduit_accumulates"] = disabled_after > disabled_before
	proof["live_disabled_downstream_starved"] = downstream_after < downstream_before
	_set_conduit_enabled(game, Vector2i(5, 13), true)
	_tick(game, 120)
	proof["live_reenabled_conduit_drains"] = _conduit_water(game, Vector2i(5, 13), water_id) < disabled_after
	proof["live_reenabled_frame_preserved"] = _conduit_frame(game, Vector2i(5, 13)).get("enabled", null) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06BuildingUpdateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
