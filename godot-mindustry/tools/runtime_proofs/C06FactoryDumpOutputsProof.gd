extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _fresh_module(max_id: int, pairs: Dictionary) -> Dictionary:
	var amounts: Array = []
	for i in range(max_id + 1):
		amounts.append(0.0)
	for liquid_id in pairs.keys():
		amounts[int(liquid_id)] = float(pairs[liquid_id])
	return {"liquids": amounts, "current": 0, "flow": null}


func _ready() -> void:
	var proof: Dictionary = {}
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var cryofluid_id: int = int(liquid_id_by_name.get("cryofluid", -1))
	var ozone_id: int = int(liquid_id_by_name.get("ozone", -1))
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))
	var max_liquid_id := 0
	for liquid_id in liquid_id_by_name.values():
		max_liquid_id = maxi(max_liquid_id, int(liquid_id))

	# --- registry: liquidOutputDirections (GenericCrafter.java:327-328)
	# `int dir = liquidOutputDirections.length > i ?
	# liquidOutputDirections[i] : -1;` — the mixer and the smelter
	# dump to every side (-1), the electrolyzer dumps ozone north
	# (1) and hydrogen south (3). ---
	var mixer = blocks_by_id["cryofluid-mixer"]
	var mixer_dirs: Array = mixer.properties.get("liquidOutputDirections", [])
	proof["dump_mixer_directions_all"] = mixer_dirs.size() == 1 and int(mixer_dirs[0]) == -1
	var electrolyzer = blocks_by_id["electrolyzer"]
	var electrolyzer_dirs: Array = electrolyzer.properties.get("liquidOutputDirections", [])
	proof["dump_electrolyzer_directions_north_south"] = electrolyzer_dirs.size() == 2 and int(electrolyzer_dirs[0]) == 1 and int(electrolyzer_dirs[1]) == 3
	var smelter = blocks_by_id["silicon-smelter"]
	var smelter_dirs: Array = smelter.properties.get("liquidOutputDirections", [])
	proof["dump_smelter_directions_all"] = smelter_dirs.size() == 1 and int(smelter_dirs[0]) == -1
	var mixer_outputs: Array = mixer.properties.get("outputLiquids", [])
	proof["dump_mixer_output_cryofluid"] = mixer_outputs.size() == 1 and String(mixer_outputs[0].get("liquid", "")) == "cryofluid"

	# --- dump interval, direct: `timer(timerDump, dumpTime /
	# timeScale)` (GenericCrafter.java:319); dumpTime is
	# Block.dumpTime, 5 (Block.java:438; no factory initializer
	# overrides it); timeScale is the building time scale, 1f by
	# default (BuildingComp.java:98). A zero time scale makes the
	# interval infinite, and TimerComp.timer (TimerComp.java:11)
	# returns false for an infinite time. ---
	var interval_one: Dictionary = factory_build_state.source_factory_dump_interval_state(5.0, 1.0)
	proof["dump_interval_five_at_unit_scale"] = is_equal_approx(float(interval_one.get("dump_interval", -1.0)), 5.0)
	var interval_double: Dictionary = factory_build_state.source_factory_dump_interval_state(5.0, 2.0)
	proof["dump_interval_halved_at_double_scale"] = is_equal_approx(float(interval_double.get("dump_interval", -1.0)), 2.5)
	var interval_half: Dictionary = factory_build_state.source_factory_dump_interval_state(5.0, 0.5)
	proof["dump_interval_doubled_at_half_scale"] = is_equal_approx(float(interval_half.get("dump_interval", -1.0)), 10.0)
	var interval_zero: Dictionary = factory_build_state.source_factory_dump_interval_state(5.0, 0.0)
	proof["dump_interval_infinite_at_zero_scale"] = is_inf(float(interval_zero.get("dump_interval", 0.0)))

	# --- dump timer, direct: TimerComp.timer (TimerComp.java:10-13)
	# returns false for an infinite interval and otherwise
	# timer.get(index, time): Interval.get fires when Time.time -
	# times[id] >= time and stamps times[id] = Time.time, so the
	# elapsed timer resets to 0.0. Time.time advances in seconds,
	# so the port accumulates the Godot delta in seconds. ---
	var timer_cold: Dictionary = factory_build_state.source_factory_dump_timer_state(0.0, 1.0 / 60.0, 5.0, 1.0)
	proof["dump_timer_cold_no_dump"] = not bool(timer_cold.get("should_dump", true)) and is_equal_approx(float(timer_cold.get("dump_timer", -1.0)), 1.0 / 60.0) and is_equal_approx(float(timer_cold.get("dump_interval", -1.0)), 5.0)
	var timer_near: Dictionary = factory_build_state.source_factory_dump_timer_state(4.99, 1.0 / 60.0, 5.0, 1.0)
	proof["dump_timer_fires_near_five"] = bool(timer_near.get("should_dump", false)) and is_equal_approx(float(timer_near.get("dump_timer", -1.0)), 0.0)
	var timer_exact: Dictionary = factory_build_state.source_factory_dump_timer_state(0.0, 5.0, 5.0, 1.0)
	proof["dump_timer_fires_exact_five"] = bool(timer_exact.get("should_dump", false)) and is_equal_approx(float(timer_exact.get("dump_timer", -1.0)), 0.0)
	var timer_inf: Dictionary = factory_build_state.source_factory_dump_timer_state(0.0, 1.0, 5.0, 0.0)
	proof["dump_timer_infinite_scale_no_dump"] = not bool(timer_inf.get("should_dump", true)) and is_equal_approx(float(timer_inf.get("dump_timer", -1.0)), 1.0) and is_inf(float(timer_inf.get("dump_interval", 0.0)))

	# --- place the blocks the direct dump calls need. The mixer
	# (35,7) and the smelter (30,7) are placed before the direct
	# guard checks so the empty-module and no-neighbor cases run
	# against real placed frames; the conduit (37,7), the
	# electrolyzer conduits (40,5)/(40,9) and the conveyor are
	# placed only when their transfer test needs them. ---
	var mixer_cell := Vector2i(35, 7)
	var mixer_sprite := Sprite2D.new()
	game.add_child(mixer_sprite)
	game.call("record_placed_block", mixer_sprite, mixer, mixer_cell)
	var mixer_frame: Dictionary = mixer_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var mixer_module: Dictionary = mixer_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var smelter_cell := Vector2i(30, 7)
	var smelter_sprite := Sprite2D.new()
	game.add_child(smelter_sprite)
	game.call("record_placed_block", smelter_sprite, smelter, smelter_cell)
	var smelter_frame: Dictionary = smelter_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var smelter_module: Dictionary = smelter_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var electrolyzer_cell := Vector2i(40, 7)
	var electrolyzer_sprite := Sprite2D.new()
	game.add_child(electrolyzer_sprite)
	game.call("record_placed_block", electrolyzer_sprite, electrolyzer, electrolyzer_cell)
	var electrolyzer_frame: Dictionary = electrolyzer_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var electrolyzer_module: Dictionary = electrolyzer_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	# --- dumpLiquid guards, direct: dumpLiquid(liquid, scaling,
	# outputDir) (BuildingComp.java:886-908) returns when the
	# building holds <= 0.0001; a null game or block, or an
	# unknown liquid, dumps nothing. ---
	var null_game_dump: Dictionary = factory_build_state.source_factory_dump_liquid_state(null, mixer_cell, mixer, mixer_module, liquid_id_by_name, "cryofluid", -1)
	proof["dump_liquid_null_game_nothing"] = is_equal_approx(float(null_game_dump.get("amount_dumped", -1.0)), 0.0) and is_equal_approx(float(null_game_dump.get("liquid_amount", -1.0)), 0.0) and String(null_game_dump.get("liquid", "")) == "cryofluid"
	var null_block_dump: Dictionary = factory_build_state.source_factory_dump_liquid_state(game, mixer_cell, null, mixer_module, liquid_id_by_name, "cryofluid", -1)
	proof["dump_liquid_null_block_nothing"] = is_equal_approx(float(null_block_dump.get("amount_dumped", -1.0)), 0.0) and is_equal_approx(float(null_block_dump.get("liquid_amount", -1.0)), 0.0)
	var unknown_dump: Dictionary = factory_build_state.source_factory_dump_liquid_state(game, mixer_cell, mixer, mixer_module, liquid_id_by_name, "not-a-liquid", -1)
	proof["dump_liquid_unknown_liquid_nothing"] = is_equal_approx(float(unknown_dump.get("amount_dumped", -1.0)), 0.0)
	var empty_dump: Dictionary = factory_build_state.source_factory_dump_liquid_state(game, mixer_cell, mixer, mixer_module, liquid_id_by_name, "cryofluid", -1)
	proof["dump_liquid_empty_module_nothing"] = is_equal_approx(float(empty_dump.get("amount_dumped", -1.0)), 0.0) and is_equal_approx(float(empty_dump.get("liquid_amount", -1.0)), 0.0)

	# --- dumpOutputs guards, direct: dumpOutputs()
	# (GenericCrafter.java:317-332) dumps nothing for a null
	# block; the item rows dump only when the timer fires
	# (`outputItems != null && timer(timerDump, dumpTime /
	# timeScale)`), so a cold timer fires nothing and a fired
	# timer with no belt neighbor keeps the item; a liquid-only
	# block never starts its dump timer. ---
	var null_outputs: Dictionary = factory_build_state.source_factory_dump_outputs_state(game, {}, mixer_cell, null, mixer_module, liquid_id_by_name, 1.0 / 60.0, 1.0)
	proof["dump_outputs_null_block_nothing"] = not bool(null_outputs.get("item_dump_fired", true)) and Array(null_outputs.get("dumped_items", ["x"])).is_empty() and Dictionary(null_outputs.get("dumped_liquids", {"x": 1.0})).is_empty()
	smelter_frame["items"] = {"silicon": 5}
	smelter_frame["dumpTimer"] = 0.0
	var smelter_cold: Dictionary = factory_build_state.source_factory_dump_outputs_state(game, smelter_frame, smelter_cell, smelter, smelter_module, liquid_id_by_name, 1.0 / 60.0, 1.0)
	proof["dump_outputs_smelter_timer_cold"] = not bool(smelter_cold.get("item_dump_fired", true)) and Array(smelter_cold.get("dumped_items", ["x"])).is_empty() and int(Dictionary(smelter_cold.get("items_after", {})).get("silicon", -1)) == 5 and is_equal_approx(float(smelter_cold.get("dump_timer", -1.0)), 1.0 / 60.0)
	smelter_frame["items"] = {"silicon": 5}
	smelter_frame["dumpTimer"] = 5.0
	var smelter_fired: Dictionary = factory_build_state.source_factory_dump_outputs_state(game, smelter_frame, smelter_cell, smelter, smelter_module, liquid_id_by_name, 1.0 / 60.0, 1.0)
	proof["dump_outputs_smelter_fired_no_belt"] = bool(smelter_fired.get("item_dump_fired", false)) and Array(smelter_fired.get("dumped_items", ["x"])).is_empty() and int(Dictionary(smelter_fired.get("items_after", {})).get("silicon", -1)) == 5 and is_equal_approx(float(smelter_fired.get("dump_timer", -1.0)), 0.0)
	liquid_module_state.source_add_state(mixer_module, cryofluid_id, 8.0, [])
	var mixer_liquid_only: Dictionary = factory_build_state.source_factory_dump_outputs_state(game, mixer_frame, mixer_cell, mixer, mixer_module, liquid_id_by_name, 1.0 / 60.0, 1.0)
	proof["dump_outputs_mixer_liquid_only_no_neighbor"] = not bool(mixer_liquid_only.get("item_dump_fired", true)) and is_equal_approx(float(Dictionary(mixer_liquid_only.get("dumped_liquids", {})).get("cryofluid", -1.0)), 0.0) and is_equal_approx(float(Array(mixer_module.get("liquids", []))[cryofluid_id]), 8.0)

	# --- dumpLiquid transfer, direct: a mixer holding 8.0
	# cryofluid (capacity 36) dumps to an empty conduit
	# (capacity 20) at scaling 2: flow = (8/36 - 0/20) * 36 / 2
	# = 4.0, capped by the conduit's free space. The conduit
	# accepts: its current is water at 0.0 (< 0.2, Conduit.java:
	# 241-244) and the mixer is not on the side the conduit
	# outputs to. The mixer (35,7) is size 2, so its footprint
	# is (35..36, 7..8) and the conduit must sit on a true
	# ring cell east of it, (37,7) — (36,7) is inside the
	# footprint and placing there replaces the mixer. ---
	var conduit = blocks_by_id["conduit"]
	var conduit_cell := Vector2i(37, 7)
	var conduit_sprite := Sprite2D.new()
	game.add_child(conduit_sprite)
	game.call("record_placed_block", conduit_sprite, conduit, conduit_cell)
	var conduit_module: Dictionary = conduit_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var transfer: Dictionary = factory_build_state.source_factory_dump_liquid_state(game, mixer_cell, mixer, mixer_module, liquid_id_by_name, "cryofluid", -1)
	proof["dump_liquid_transfer_amount"] = is_equal_approx(float(transfer.get("amount_dumped", -1.0)), 4.0)
	proof["dump_liquid_mixer_after"] = is_equal_approx(float(transfer.get("liquid_amount", -1.0)), 4.0)
	proof["dump_liquid_conduit_after"] = is_equal_approx(float(Array(conduit_module.get("liquids", []))[cryofluid_id]), 4.0)
	mixer_frame = mixer_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["dump_liquid_cursor_matches_frame"] = int(transfer.get("dump_cursor", -1)) == int(mixer_frame.get("cdump", -2))

	# --- dumpOutputs liquid transfer, direct: an electrolyzer
	# holding ozone 2.0 + hydrogen 3.0 dumps each output liquid
	# to its own direction every tick (GenericCrafter.java:325-
	# 330): ozone north (dir 1) to the (40,5) conduit, hydrogen
	# south (dir 3) to the (40,9) conduit. With empty
	# destinations the flow is half the held amount each:
	# (held/cap - 0) * cap / 2. The electrolyzer (40,7) is size
	# 3, so its footprint is (39..41, 6..8): true north/south
	# ring cells are (40,5)/(40,9) — (40,6)/(40,8) are inside
	# the footprint and placing there replaces it. ---
	var north_conduit_sprite := Sprite2D.new()
	game.add_child(north_conduit_sprite)
	game.call("record_placed_block", north_conduit_sprite, conduit, Vector2i(40, 5))
	var north_conduit_module: Dictionary = north_conduit_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var south_conduit_sprite := Sprite2D.new()
	game.add_child(south_conduit_sprite)
	game.call("record_placed_block", south_conduit_sprite, conduit, Vector2i(40, 9))
	var south_conduit_module: Dictionary = south_conduit_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(electrolyzer_module, ozone_id, 2.0, [])
	liquid_module_state.source_add_state(electrolyzer_module, hydrogen_id, 3.0, [])
	var electrolyzer_dump: Dictionary = factory_build_state.source_factory_dump_outputs_state(game, electrolyzer_frame, electrolyzer_cell, electrolyzer, electrolyzer_module, liquid_id_by_name, 1.0 / 60.0, 1.0)
	proof["dump_outputs_electrolyzer_ozone"] = is_equal_approx(float(Dictionary(electrolyzer_dump.get("dumped_liquids", {})).get("ozone", -1.0)), 1.0)
	proof["dump_outputs_electrolyzer_hydrogen"] = is_equal_approx(float(Dictionary(electrolyzer_dump.get("dumped_liquids", {})).get("hydrogen", -1.0)), 1.5)
	proof["dump_outputs_electrolyzer_after"] = is_equal_approx(float(Array(electrolyzer_module.get("liquids", []))[ozone_id]), 1.0) and is_equal_approx(float(Array(electrolyzer_module.get("liquids", []))[hydrogen_id]), 1.5)
	proof["dump_outputs_north_conduit_ozone"] = is_equal_approx(float(Array(north_conduit_module.get("liquids", []))[ozone_id]), 1.0)
	proof["dump_outputs_south_conduit_hydrogen"] = is_equal_approx(float(Array(south_conduit_module.get("liquids", []))[hydrogen_id]), 1.5)
	proof["dump_outputs_electrolyzer_no_item_dump"] = not bool(electrolyzer_dump.get("item_dump_fired", true))

	# --- dumpOutputs item transfer, direct: a smelter holding
	# silicon 5 with a fired dump timer dumps one silicon to
	# the belt neighbor east of it (the bootstrap geometry: the
	# drill dumps east onto rotation-0 conveyors). The conveyor
	# at the east ring cell gets an empty queue first. ---
	var smelter_size := int(smelter.properties.get("size", 1))
	var smelter_ring: Array = block_geometry.source_block_proximity_cells_state(smelter_size, smelter_cell.x, smelter_cell.y).get("cells", [])
	var east_cell := Vector2i(31, 7)
	for ring_cell in smelter_ring:
		if int(ring_cell.x) > east_cell.x or (int(ring_cell.x) == east_cell.x and int(ring_cell.y) == smelter_cell.y):
			east_cell = ring_cell
	var conveyor = blocks_by_id["conveyor"]
	var conveyor_sprite := Sprite2D.new()
	game.add_child(conveyor_sprite)
	game.call("record_placed_block", conveyor_sprite, conveyor, east_cell)
	conveyor_sprite.set_meta(block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0)
	conveyor_runtime_state.source_conveyor_set_queue_for_cell_state(game, east_cell, {"ids": [], "xs": [], "ys": [], "len": 0})
	smelter_frame["items"] = {"silicon": 5}
	smelter_frame["dumpTimer"] = 5.0
	var smelter_dump: Dictionary = factory_build_state.source_factory_dump_outputs_state(game, smelter_frame, smelter_cell, smelter, smelter_module, liquid_id_by_name, 1.0 / 60.0, 1.0)
	proof["dump_outputs_smelter_item_fired"] = bool(smelter_dump.get("item_dump_fired", false))
	var smelter_dumped: Array = smelter_dump.get("dumped_items", [])
	proof["dump_outputs_smelter_dumped_silicon"] = smelter_dumped.size() == 1 and String(smelter_dumped[0]) == "silicon"
	proof["dump_outputs_smelter_frame_silicon_four"] = int(Dictionary(smelter_dump.get("items_after", {})).get("silicon", -1)) == 4
	var belt_queues: Dictionary = conveyor_runtime_state.source_conveyor_queues_for_cells_state(game, [east_cell]).get("queues_by_cell", {})
	var belt_queue: Dictionary = belt_queues.get(east_cell, {})
	var belt_ids: Array = belt_queue.get("ids", [])
	proof["dump_outputs_belt_queue_one_silicon"] = int(belt_queue.get("len", -1)) == 1 and belt_ids.size() == 1 and String(belt_ids[0]) == "silicon"

	# --- dumpOutputs, live: a mixer (45,7) with titanium 5 and
	# water 10.0 and a conduit (47,7) tick 40 times through
	# simulate_factory. The mixer produces 0.2 cryofluid per
	# tick (N2118) and dumps half its held cryofluid toward the
	# empty conduit each tick, so after 40 ticks it holds
	# strictly less than the no-dump 8.0 but still more than 0,
	# and the conduit holds some; water, progress and efficiency
	# match the N2118 live numbers exactly. The mixer is size 2,
	# so its footprint is (45..46, 7..8) and the conduit must sit
	# on the true east ring cell (47,7) — (46,7) is inside the
	# footprint and placing there replaces the mixer. ---
	var live_mixer_cell := Vector2i(45, 7)
	# N2145 reads live power.status (ConsumePower.java:39). Supply
	# the live mixer through the graph, as in FactoryShouldConsumeProof.
	var reactor := Sprite2D.new()
	game.add_child(reactor)
	game.call("record_placed_block", reactor, blocks_by_id["thorium-reactor"], Vector2i(55, 7))
	var live_mixer_sprite := Sprite2D.new()
	game.add_child(live_mixer_sprite)
	game.call("record_placed_block", live_mixer_sprite, mixer, live_mixer_cell)
	var live_mixer_frame: Dictionary = live_mixer_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	live_mixer_frame["items"] = {"titanium": 5}
	var live_mixer_module: Dictionary = live_mixer_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(live_mixer_module, water_id, 10.0, [])
	var live_conduit_sprite := Sprite2D.new()
	game.add_child(live_conduit_sprite)
	game.call("record_placed_block", live_conduit_sprite, conduit, Vector2i(47, 7))
	var live_conduit_module: Dictionary = live_conduit_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	for iteration in range(40):
		game.call("simulate_factory", 1.0 / 60.0)
	live_mixer_frame = live_mixer_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	live_mixer_module = live_mixer_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	live_conduit_module = live_conduit_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var live_mixer_amounts: Array = live_mixer_module.get("liquids", [])
	var live_conduit_amounts: Array = live_conduit_module.get("liquids", [])
	proof["dump_live_mixer_water"] = is_equal_approx(float(live_mixer_amounts[water_id]), 10.0 - 40.0 * 0.2)
	proof["dump_live_mixer_progress"] = is_equal_approx(float(live_mixer_frame.get("progress", -1.0)), 40.0 / 120.0)
	proof["dump_live_mixer_efficiency_one"] = is_equal_approx(float(live_mixer_frame.get("efficiency", -1.0)), 1.0)
	proof["dump_live_mixer_cryofluid_dumped_some"] = float(live_mixer_amounts[cryofluid_id]) > 0.0 and float(live_mixer_amounts[cryofluid_id]) < 8.0
	proof["dump_live_conduit_gained"] = float(live_conduit_amounts[cryofluid_id]) > 0.0
	proof["dump_live_mixer_titanium_kept"] = int(Dictionary(live_mixer_frame.get("items", {})).get("titanium", -1)) == 5

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06FactoryDumpOutputsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
