extends RefCounted
class_name SourceSessionSnapshotState

const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const source_power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerGameplayRegistry.gd")
const source_pump_runtime_state := preload("res://src/game/SourcePumpRuntimeState.gd")

# One live-loop tick in seconds. simulate_factory passes the Godot
# _process delta in seconds, and the live loop recomputes the power
# balance from it every tick, so the snapshot groups the placed graph
# at the same delta the live update uses (the N2107 proof pins the
# live balance at power_needed = 6.0/60, power_produced = 0.12/60,
# coverage 0.02). The game_runtime_state helper instead uses the
# 60-ticks-per-second source delta, which is a different convention.
const SESSION_TICK_DELTA := 1.0 / 60.0


static func _zero_snapshot() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SESSION_SNAPSHOT_STATE,
		"core_copper": 0,
		"core_health": 0.0,
		"battery_stored": 0.0,
		"battery_capacity": 0.0,
		"power_needed": 0.0,
		"power_produced": 0.0,
		"power_coverage": 0.0,
		"drill_time_drilled": 0.0,
		"drill_warmup": 0.0,
		"drill_last_speed": 0.0,
		"drill_water": 0.0,
		"drill_produced_total": 0,
		"pump_warmup": 0.0,
		"pump_total_progress": 0.0,
		"pump_water": 0.0,
		"conduit_water": 0.0,
	}


static func _liquid_amount(game: Object, cell: Vector2i, liquid_name: String) -> float:
	# LiquidModule.get(liquid) (LiquidModule.java:102): the amount
	# of the named liquid held in the building's liquid module at
	# the cell; 0.0 when there is no building or no liquid module.
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return 0.0
	var liquids: Variant = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
	if liquids == null:
		return 0.0
	var catalog: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(game.get("content_catalog"))
	var liquid_id: int = int(catalog["liquid_id_by_name"].get(liquid_name, -1))
	if liquid_id < 0:
		return 0.0
	return float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))


static func source_session_snapshot_state(game: Object) -> Dictionary:
	# The C06 session snapshot: one pure read of the live session's
	# inventory, health, production and energy, so a session proof
	# can verify the whole factory -> core -> defense chain
	# before/after a fixed number of deterministic live-loop ticks
	# (backlog C06 gate). A null game, or a game that has not entered
	# the playable slice yet, reads all zeros.
	var snapshot := _zero_snapshot()
	if game == null:
		return snapshot
	# Inventory: the core's held copper, ItemModule.get(Item)
	# (ItemModule.java:209) through the core inventory accessor.
	snapshot["core_copper"] = int(game.call("core_item_count", "copper"))
	# Health: the core's current health, HealthComp.health
	# (HealthComp.java:11), through the placed-block health read.
	snapshot["core_health"] = float(source_placed_block_state.game_health_at_cell(game, source_playable_scenario_defaults.CORE_POS.x, source_playable_scenario_defaults.CORE_POS.y))
	# Energy: the placed power graph grouped at one live tick
	# (PowerGraph.add, PowerGraph.java:277-301, groups each building
	# once). The grouped battery dicts rebuild power_status as 0.0
	# every frame, so the stored charge is read from the live status
	# on the battery sprite meta instead (PowerGraph.getBatteryStored,
	# PowerGraph.java:123-132: status * capacity over enabled
	# batteries); the capacity is the graph total
	# (PowerGraph.getTotalBatteryCapacity, PowerGraph.java:145-154).
	var callbacks: Dictionary = source_placed_power_graph_state.default_callbacks_state(game)
	var grouped: Dictionary = source_placed_power_graph_state._group_state(game.get("placed_block_origins"), callbacks.get("block_from_sprite", Callable()), callbacks.get("role_for_block", Callable()), SESSION_TICK_DELTA)
	var consumers: Array = grouped.get("consumers", [])
	var producers: Array = grouped.get("producers", [])
	var batteries: Array = grouped.get("batteries", [])
	snapshot["power_needed"] = float(source_power_graph_state.power_needed_state(consumers).get("power_needed", 0.0))
	snapshot["power_produced"] = float(source_power_graph_state.power_produced_state(producers).get("power_produced", 0.0))
	var battery_stored := 0.0
	for battery in batteries:
		if not (battery is Dictionary):
			continue
		if not bool(battery.get("enabled", false)):
			continue
		var origin_cell: Variant = battery.get("origin_cell", null)
		if not (origin_cell is Vector2i):
			continue
		var stored_state: Dictionary = source_placed_power_graph_state.source_battery_power_status_for_cell_state(game, origin_cell)
		battery_stored += float(stored_state.get("status", 0.0)) * float(battery.get("capacity", 0.0))
	snapshot["battery_stored"] = battery_stored
	snapshot["battery_capacity"] = float(source_power_graph_state.battery_state(batteries).get("total_capacity", 0.0))
	# Coverage follows PowerGraph.distributePower
	# (PowerGraph.java:190): 0 when needed, produced and the stored
	# charge are all zero and nothing charged, 1 when needed is zero,
	# else min(1, produced / needed). The graph charges only on a
	# surplus (produced > needed), so charged is that comparison.
	var charged: bool = float(snapshot["power_produced"]) > float(snapshot["power_needed"])
	snapshot["power_coverage"] = float(source_power_graph_state.distribute_power_state(consumers, float(snapshot["power_needed"]), float(snapshot["power_produced"]), charged, battery_stored).get("coverage", 0.0))
	# Production: the drill's DrillBuild fields. The live-loop tick
	# reads them from the legacy per-cell stores (the frame mirrors
	# them), so the snapshot reads the same stores:
	# timeDrilled += warmup * delta() (Drill.java:296), warmup
	# approaches speed (Drill.java:304), lastDrillSpeed =
	# (speed * dominantItems * warmup) / delay (Drill.java:303), and
	# the produced count is the drill's offloads
	# (offload(dominantItem), Drill.java:317).
	var drill_cell: Vector2i = source_playable_scenario_defaults.DRILL_POS
	snapshot["drill_time_drilled"] = float(game.call("drill_time_drilled_at_cell", drill_cell.x, drill_cell.y))
	snapshot["drill_warmup"] = float(game.call("drill_warmup_at_cell", drill_cell.x, drill_cell.y))
	snapshot["drill_last_speed"] = float(game.call("drill_last_speed_at_cell", drill_cell.x, drill_cell.y))
	snapshot["drill_water"] = _liquid_amount(game, drill_cell, "water")
	snapshot["drill_produced_total"] = int(game.get("produced_total"))
	# Pump: the PumpBuild frame (warmup, totalProgress,
	# Pump.java:111) plus its liquid module water.
	var pump_cell: Vector2i = source_playable_scenario_defaults.PUMP_POS
	var pump_sprite: Variant = game.call("block_sprite_at_cell", pump_cell)
	if pump_sprite != null:
		var pump_frame: Dictionary = pump_sprite.get_meta(source_pump_runtime_state.SOURCE_PUMP_BUILDING_META_KEY, {})
		snapshot["pump_warmup"] = float(pump_frame.get("warmup", 0.0))
		snapshot["pump_total_progress"] = float(pump_frame.get("total_progress", 0.0))
	snapshot["pump_water"] = _liquid_amount(game, pump_cell, "water")
	# Conduit line: the water held across the whole line, one
	# LiquidModule.get per conduit cell.
	var conduit_water := 0.0
	for conduit_cell in source_playable_scenario_defaults.conduit_cells():
		conduit_water += _liquid_amount(game, conduit_cell, "water")
	snapshot["conduit_water"] = conduit_water
	return snapshot
